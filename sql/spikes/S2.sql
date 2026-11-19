-- =====================================================================
-- S2: Does the "claude" service follow a JSON schema every time?
-- =====================================================================
-- WHY: Week 1 classify, Week 2 extraction and Week 3 intent all save AI
--      output into columns. Clean JSON means plain SQL (JSON_VALUE) can
--      read it. If the schema option fails, the fallback is: ask for JSON
--      in the prompt, check it with IS JSON, retry once.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste this whole block. Run.
--
-- WHAT IT DOES: classifies the same call (CALL-001, a policy question)
--   three times with p_response_json_schema, then checks each answer:
--   is it valid JSON, and does it have the three fields we asked for?
--
-- EXPECTED OUTPUT (DBMS Output pane), three times:
--   Run 1: {"intent":"POLICY","reference":"LSL-10021","confidence":0.9...}
--   Run 1: valid JSON = Y, intent = POLICY, reference = LSL-10021
--   ... then a last line:
--   Clean runs: 3 of 3
--
-- PASS: "Clean runs: 3 of 3" and intent = POLICY each time.
-- FAIL: an error, or fewer than 3 clean runs. Copy all output into chat.
--
-- Docs checked (19 Nov 2026): APEX_AI.GENERATE Signature 2, APEX 26.2
--   API Reference. "When in JSON mode, this function returns a
--   stringified JSON object." Example 2 on that page uses the same
--   schema style (type, properties, required, additionalProperties).
-- UNVERIFIED: the docs do not say whether every provider supports
--   p_response_json_schema. This spike tests it for Anthropic.
-- =====================================================================
declare
    -- Transcript copied from data/calls/txt/CALL-001.txt (synthetic).
    l_transcript clob := q'~AGENT: Good morning, Lanka Shield Assurance, Nadeesha speaking. How can I help you?
CALLER: Good morning. I want to know when my next premium is due. Policy number is LSL-10021.
AGENT: Thank you, Mr. Jayawardena. Can I have your NIC number to confirm, please?
CALLER: Yes, 671234567V.
AGENT: Thank you. One moment please.
CALLER: Also tell me the amount, I think it went up this year?
AGENT: Let me check that for you.~';

    -- WHY an enum: the model can only answer with one of our four labels,
    -- so the column never gets "Policy query" or "policy".
    l_schema clob := q'~{
        "type": "object",
        "properties": {
            "intent":     { "type": "string",
                            "enum": ["POLICY", "CLAIM", "PRODUCT_BRANCH", "OTHER"] },
            "reference":  { "type": "string",
                            "description": "Policy, claim, NIC or vehicle number mentioned, or empty" },
            "confidence": { "type": "number",
                            "description": "0 to 1, how sure you are of the intent" }
        },
        "required": ["intent", "reference", "confidence"],
        "additionalProperties": false
    }~';

    l_answer   clob;
    l_is_json  number;
    l_intent   varchar2(30);
    l_ref      varchar2(50);
    l_clean    pls_integer := 0;
begin
    for i in 1 .. 3 loop
        l_answer := apex_ai.generate (
            p_service_static_id    => 'claude',
            p_system_prompt        => 'You classify insurance call-centre transcripts.',
            p_prompt               => 'Classify this call:' || chr(10) || l_transcript,
            p_response_json_schema => l_schema );

        sys.dbms_output.put_line( 'Run ' || i || ': ' || l_answer );

        -- WHY check with SQL: this is the same check Week 2 and 3 code will use.
        -- JSON_VALUE returns NULL (not an error) when the text is not JSON.
        select case when l_answer is json then 1 else 0 end,
               json_value( l_answer, '$.intent' ),
               json_value( l_answer, '$.reference' )
          into l_is_json, l_intent, l_ref
          from dual;

        if l_is_json = 1 and l_intent is not null then
            l_clean := l_clean + 1;
        end if;

        sys.dbms_output.put_line( 'Run ' || i
            || ': valid JSON = ' || case l_is_json when 1 then 'Y' else 'N' end
            || ', intent = '     || l_intent
            || ', reference = '  || l_ref );
    end loop;

    sys.dbms_output.put_line( 'Clean runs: ' || l_clean || ' of 3' );
end;
/
