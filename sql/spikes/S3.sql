-- =====================================================================
-- S3: Can the model call a PL/SQL tool through APEX_AI.GENERATE?
-- =====================================================================
-- WHY: Week 3 (Case 2) lets the AI look up policy and claim status by
--      calling PL/SQL functions ("tools"). If tools work from code, we can
--      test the agent from SQL Workshop. Fallbacks: the AI Agents shared
--      component only (see S7), else route by intent in PL/SQL and call
--      the function directly.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. This file has 2 steps.
--   Paste STEP 1 alone and run it. Then paste STEP 2 alone and run it.
--   If STEP 2 fails with a session or application error, do NOT add
--   apex_session.create_session: in SQL Workshop it signs you out of APEX
--   (seen in S4, 20 Nov 2026). Record the error; S7 then tests tools
--   through an AI Agent inside the app.
--
-- Docs checked (19 Nov 2026): APEX_AI.GENERATE Signature 2, Example 3
--   (tool with callback_procedure), APEX 26.1 and 26.2 API Reference.
--   APEX_AI Data Types, APEX 26.2 (t_tool, t_tool_parameter,
--   t_tool_exec_param, t_tool_exec_result).
-- UNVERIFIED: Oracle's tool examples first call apex_session.create_session
--   with an app ID. SQL Workshop already has an APEX session (docs/environment.md
--   shows APEX_AI.GENERATE works there), so STEP 2 runs without it.
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 1: the tool. A fake policy lookup with two hard-coded policies.
-- WHY hard-coded: this spike tests the plumbing, not the data model.
-- WHY this signature: APEX calls the callback with exactly these two
--   parameters. The model's arguments arrive in p_param.args_json.
-- Expected: "Procedure created."
-- ---------------------------------------------------------------------
create or replace procedure spike_tool_policy_status (
    p_param  in            apex_ai.t_tool_exec_param,
    p_result in out nocopy apex_ai.t_tool_exec_result )
as
    l_policy_no varchar2(30) := upper( p_param.args_json.get_string( 'policy_no' ) );
begin
    -- Proof that the model really called the tool (shows in DBMS Output).
    sys.dbms_output.put_line( 'TOOL CALLED with policy_no = ' || l_policy_no );

    p_result.result :=
        case l_policy_no
            when 'LSL-10021' then '{"policy_no":"LSL-10021","status":"ACTIVE","next_premium_due":"2026-12-01"}'
            when 'LSL-10034' then '{"policy_no":"LSL-10034","status":"LAPSED","lapsed_on":"2026-08-15"}'
            else '{"error":"Policy not found"}'
        end;
end spike_tool_policy_status;
/


-- ---------------------------------------------------------------------
-- STEP 2: ask a question that needs the tool.
-- Expected DBMS Output, roughly:
--   TOOL CALLED with policy_no = LSL-10034
--   Answer: Policy LSL-10034 is LAPSED (since 15 August 2026) ...
-- PASS: the TOOL CALLED line appears AND the answer says LAPSED.
-- FAIL: no TOOL CALLED line (the model guessed), or an error.
-- ---------------------------------------------------------------------
declare
    l_answer clob;
begin
    l_answer := apex_ai.generate (
        p_service_static_id => 'claude',
        p_prompt            => 'What is the status of policy LSL-10034?',
        p_system_prompt     => 'You are a call-centre assistant. Always use the tool to check a policy. Never guess.',
        p_tools             =>
            apex_ai.t_tools (
                apex_ai.t_tool (
                    name               => 'get_policy_status',
                    description        => 'Returns the status of one insurance policy as JSON.',
                    parameters         =>
                        apex_ai.t_tool_parameters (
                            apex_ai.t_tool_parameter (
                                name        => 'policy_no',
                                description => 'Policy number, for example LSL-10021',
                                data_type   => apex_ai.c_tool_param_type_varchar2,
                                is_required => true ) ),
                    callback_procedure => 'spike_tool_policy_status' ) ),
        -- WHY a limit: a broken loop must not keep calling the model.
        p_max_tool_roundtrips => 3 );

    sys.dbms_output.put_line( 'Answer: ' || l_answer );
end;
/
