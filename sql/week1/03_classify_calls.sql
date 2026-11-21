-- =====================================================================
-- Week 1 demo 3: classify three call transcripts with one SQL query
-- =====================================================================
-- ANCHOR: "An AI call is a function in a SELECT."
--
-- WHY this demo: the room knows SELECT and JSON_VALUE. Here an AI model
--   is just one more function in the select list, and SQL checks its
--   answer. This is the first step of Case 2 (Week 3): every call gets an
--   intent label before anything else happens.
--
-- WHAT IT DOES: three synthetic transcripts (CALL-001, CALL-009,
--   CALL-017 from data/calls/txt/) sit in a WITH clause. For each row,
--   APEX_AI.GENERATE asks the "claude" service for a JSON object with one
--   intent. The outer query checks the reply with IS JSON and reads the
--   label with JSON_VALUE.
--
-- WHY JSON in the prompt and not p_response_json_schema: spike S2 showed
--   that schema mode fails with ORA-20959 on our "claude" service, while
--   "reply with only a JSON object" works (docs/environment.md, S2).
--   Never trust the reply blindly: IS JSON catches anything that is not
--   JSON, and the CASE turns it into INVALID instead of an error.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- No tables needed: everything is in the WITH clause.
-- Needs: the Generative AI Service with static ID "claude".
--
-- EXPECTED RESULT (3 rows, about 3.5 seconds in total; tested 21 Nov):
--   CALL_ID   EXPECTED        AI_INTENT       MATCH
--   CALL-001  POLICY          POLICY          Y
--   CALL-009  CLAIM           CLAIM           Y
--   CALL-017  PRODUCT_BRANCH  PRODUCT_BRANCH  Y
--   RAW_REPLY shows the model's exact text, for example {"intent":"POLICY"}.
--
-- TALKING POINT: the model only proposes a label. The database decides
--   what to do with it: the MATCH column is a plain SQL comparison, and in
--   Week 3 a label that is INVALID or OTHER goes to a person.
--
-- Docs checked (21 Nov 2026):
--   APEX_AI.GENERATE (p_prompt, p_service_static_id), APEX 26.1 API
--   Reference; the same call is verified on our 26.2 workspace
--   (docs/environment.md).
--   IS JSON and JSON_VALUE, Oracle AI Database 26ai JSON Developer's Guide.
-- =====================================================================
with calls ( call_id, expected, transcript ) as (
    select 'CALL-001', 'POLICY', q'[AGENT: Good morning, Lanka Shield Assurance, Nadeesha speaking. How can I help you?
CALLER: Good morning. I want to know when my next premium is due. Policy number is LSL-10021.
AGENT: Thank you, Mr. Jayawardena. Can I have your NIC number to confirm, please?
CALLER: Yes, 671234567V.
AGENT: Thank you. One moment please.
CALLER: Also tell me the amount, I think it went up this year?
AGENT: Let me check that for you.]' from dual union all
    select 'CALL-009', 'CLAIM', q'[AGENT: Lanka Shield Assurance, Nadeesha speaking.
CALLER: Hi, I want to know what happened to my claim. Number is CLM-26-0004.
AGENT: Thank you, Mr. Kumara. Let me check the status.
CALLER: The garage is asking when they can start the work.
AGENT: One moment please.]' from dual union all
    select 'CALL-017', 'PRODUCT_BRANCH', q'[AGENT: Lanka Shield Assurance, Nadeesha speaking.
CALLER: Hi, is your Kandy branch open on Saturday?
AGENT: Let me check the branch hours for you.
CALLER: I want to come and pay in cash, what time does it close?]' from dual
),
replies as (
    -- ROWNUM stops the optimizer from merging this view into the outer
    -- query. Without it, Oracle copies the APEX_AI.GENERATE call into each
    -- place RAW_REPLY is used below: one row made about five paid AI calls
    -- (18 s instead of 3.4 s, tested 21 Nov). A /*+ materialize */ hint
    -- did not help. Lesson for production: call the model once, store the
    -- reply, then check it.
    select rownum as rn,
           c.call_id,
           c.expected,
           apex_ai.generate(
               p_prompt => 'Classify the intent of this insurance call. '
                        || 'Choose exactly one: POLICY (premiums, cover, policy details), '
                        || 'CLAIM (a claim and its status), '
                        || 'PRODUCT_BRANCH (products, branches, opening hours), '
                        || 'OTHER (anything else). '
                        || 'Reply with only a JSON object like {"intent":"POLICY"}. No other text.'
                        || chr(10) || chr(10) || 'Transcript:' || chr(10) || c.transcript,
               p_service_static_id => 'claude' ) as raw_reply
      from calls c
)
select call_id,
       expected,
       case when raw_reply is json
            then json_value( raw_reply, '$.intent' )
            else 'INVALID'
       end as ai_intent,
       case when raw_reply is json
             and json_value( raw_reply, '$.intent' ) = expected
            then 'Y' else 'N'
       end as match,
       raw_reply
  from replies
 order by call_id;
