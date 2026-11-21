-- =====================================================================
-- Week 2 / 02_extract_estimate.sql: AI reads an estimate image into JSON
-- =====================================================================
-- ANCHOR: "The AI reads. SQL decides." (Case 1, step 3)
--
-- WHY a procedure: the page process calls one line,
--   extract_estimate( :P3_ESTIMATE_ID ), and the same code runs from SQL
--   Commands when we rehearse or when the room tries to break it.
--
-- WHAT IT DOES:
--   1. Reads the image BLOB from ESTIMATES.
--   2. Calls APEX_AI.GENERATE once, with the image as an attachment
--      (spike S1 PASSED) and a prompt that asks for JSON only.
--   3. Stores the reply, then checks it with IS JSON. If the reply is not
--      JSON it asks once more. If it is still not JSON, the estimate goes
--      to review: we never guess.
--   4. Saves extracted_json, model_score (the model's own confidence) and
--      garage_name.
--
-- WHY JSON in the prompt and not p_response_json_schema: schema mode fails
--   with ORA-20959 on our "claude" service (spike S2, docs/environment.md).
-- WHY "copy the total exactly as written": the check in 03 compares the
--   written total with the sum of the lines. If the model added the lines
--   itself, a wrong total on paper would slip through.
-- WHY call once and store: an AI call is slow, paid and not repeatable.
--   Week 1 showed what happens when SQL calls it more than once.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- EXPECTED: "Procedure created."
-- THEN TEST: begin extract_estimate( <estimate_id> ); end;
--   then: select estimate_id, model_score, json_serialize( extracted_json pretty )
--           from estimates where estimate_id = <estimate_id>;
--
-- Docs checked (21 Nov 2026):
--   APEX_AI.GENERATE Signature 2 (p_prompt, p_attachments,
--   p_service_static_id), APEX_AI.T_ATTACHMENT, APEX 26.2 API Reference.
--   IS JSON condition, JSON data type, JSON_VALUE, Oracle AI Database 26ai
--   JSON Developer's Guide.
-- =====================================================================
create or replace procedure extract_estimate ( p_estimate_id in number )
is
    c_prompt constant varchar2(4000) :=
        'You read documents sent to an insurance company. Look at the attached image. '
     || 'Reply with ONLY one JSON object, no other text, no code fences, with exactly these keys: '
     || '{"document_type": "GARAGE_ESTIMATE" or "OTHER", '
     || '"garage_name": text, "garage_town": text, "estimate_no": text, '
     || '"estimate_date": "YYYY-MM-DD", "reg_no": vehicle registration number as printed, '
     || '"vehicle": make and model, '
     || '"line_items": [{"description": text, "qty": number, "unit_price_lkr": number, "amount_lkr": number}], '
     || '"total_lkr": number, "confidence": number from 0 to 1}. '
     || 'Rules: amounts are plain numbers without commas or currency. '
     || 'Copy total_lkr exactly as written on the document, even if it is handwritten '
     || 'and even if it does not match the line items. Do not add up the lines yourself. '
     || 'Use null for anything you cannot read. '
     || 'confidence = how sure you are that every field is read correctly. '
     || 'If the document is not a vehicle repair estimate, set document_type to "OTHER".';

    l_image     blob;
    l_mime      varchar2(100);
    l_file      varchar2(255);
    l_reply     clob;
    l_ok        number;
begin
    select image, mime_type, file_name
      into l_image, l_mime, l_file
      from estimates
     where estimate_id = p_estimate_id;

    for attempt in 1 .. 2 loop
        l_reply := apex_ai.generate (
            p_service_static_id => 'claude',
            p_prompt            => c_prompt,
            p_attachments       => apex_ai.t_attachments (
                                       apex_ai.t_attachment (
                                           mime_type    => l_mime,
                                           content_blob => l_image,
                                           file_name    => l_file ) ) );

        -- WHY trim to the outer braces: a polite model may still wrap the
        -- JSON in a sentence or a code fence. The check below still decides.
        l_reply := regexp_substr( l_reply, '\{.*\}', 1, 1, 'n' );

        select case when l_reply is json then 1 else 0 end into l_ok from dual;
        exit when l_ok = 1;
    end loop;

    if l_ok = 1 then
        update estimates
           set extracted_json = l_reply,
               model_score    = least( greatest( nvl( json_value( l_reply, '$.confidence' returning number ), 0 ), 0 ), 1 ),
               garage_name    = substr( json_value( l_reply, '$.garage_name' ), 1, 100 ),
               check_results  = null,
               review_status  = null
         where estimate_id = p_estimate_id;
    else
        update estimates
           set extracted_json = null,
               model_score    = 0,
               check_results  = json_object( 'error' value 'The model reply was not JSON after 2 tries' ),
               review_status  = 'NEEDS_REVIEW'
         where estimate_id = p_estimate_id;
    end if;
end extract_estimate;
/
