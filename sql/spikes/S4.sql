-- =====================================================================
-- S4: Can we create and approve a task from a Task Definition?
-- =====================================================================
-- WHY: Week 2 (Case 1) sends doubtful estimates to a human. The planned
--      tool is an APEX Task Definition (approval). Fallback: a status
--      column plus a plain review page.
--
-- RESULT (20 Nov 2026): PASS. See docs/environment.md.
--
-- HOW THE TEST RUNS: by clicks inside the app, not from SQL Workshop.
--   See docs/spikes.md, section S4. This file only checks the result.
--
-- WHY NOT FROM SQL WORKSHOP (learned the hard way, 20 Nov 2026):
--   * APEX_HUMAN_TASK.CREATE_TASK called from SQL Commands fails with
--     "ORA-20987: APEX - Task definition not found", even with the right
--     p_application_id and static ID. The task API needs the app's own
--     session.
--   * Opening that session with apex_session.create_session inside SQL
--     Workshop replaces your builder session, and delete_session then
--     signs you out of APEX. Never call either from SQL Workshop.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- EXPECTED: one row per test task, for example
--   TASK_DEF_STATIC_ID  STATE_CODE  OUTCOME_CODE
--   spike-review        COMPLETED   APPROVED
--
-- Docs checked (19 Nov 2026): APEX_TASKS runtime view, "Runtime Views for
--   Tasks", APEX App Builder User's Guide.
-- =====================================================================
select task_id,
       task_def_static_id,
       state_code,
       outcome_code,
       initiator,
       actual_owner
  from apex_tasks
 where task_def_static_id = 'spike-review'
 order by task_id;
