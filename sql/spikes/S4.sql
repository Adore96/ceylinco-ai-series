-- =====================================================================
-- S4: Can we create and approve a task from a Task Definition?
-- =====================================================================
-- WHY: Week 2 (Case 1) sends doubtful estimates to a human. The planned
--      tool is an APEX Task Definition (approval). Fallback: a status
--      column plus a plain review page.
--
-- BEFORE YOU RUN: create the Task Definition by clicking (docs/spikes.md,
--   section S4). Static ID must be SPIKE_REVIEW.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Replace the two values below
--   (App ID and username, same as the Task Definition). Paste. Run.
--
-- EXPECTED OUTPUT (DBMS Output pane), roughly:
--   Task created: 12345678
--   State after create: ASSIGNED   (or UNASSIGNED)
--   State after approve: COMPLETED, outcome: APPROVED
--
-- PASS: the last line says COMPLETED and APPROVED.
-- FAIL: any error. Copy it into the chat.
--
-- Docs checked (19 Nov 2026), APEX 26.1 API Reference:
--   APEX_HUMAN_TASK.CREATE_TASK (p_application_id, p_task_def_static_id,
--   p_subject, p_initiator, p_initiator_can_complete ...)
--   APEX_HUMAN_TASK.APPROVE_TASK (p_task_id, p_autoclaim)
--   APEX_HUMAN_TASK.GET_TASKS (p_context => 'SINGLE_TASK', p_task_id)
--     "only returns data in the context of a valid Oracle APEX session"
--   Troubleshooting Tasks: outside a page, create a session with
--     apex_session.create_session, passing the approver as username.
-- UNVERIFIED: the 26.2 pages for APPROVE_TASK; the 23.2 to 26.1 signature
--   is unchanged, so no change is expected.
-- =====================================================================
declare
    c_app_id   constant number       := 100;                  -- your "Noob Dev Spikes" App ID
    c_user     constant varchar2(255) := 'YOUR_APEX_USERNAME'; -- your login, in capitals

    l_task_id  number;
    l_state    varchar2(32);
    l_outcome  varchar2(32);

    -- WHY a helper: we read the state twice.
    procedure read_state is
    begin
        select state_code, outcome_code
          into l_state, l_outcome
          from table ( apex_human_task.get_tasks (
                           p_context => 'SINGLE_TASK',
                           p_task_id => l_task_id ) );
    end read_state;
begin
    -- WHY a session: task APIs act "as a user". SQL Workshop is not inside
    -- our app, so we open a session for the app as the approver.
    apex_session.create_session (
        p_app_id   => c_app_id,
        p_page_id  => 1,
        p_username => c_user );

    l_task_id := apex_human_task.create_task (
        p_application_id         => c_app_id,
        p_task_def_static_id     => 'SPIKE_REVIEW',
        p_subject                => 'S4 spike: review estimate EST-TEST',
        p_initiator              => c_user,
        -- WHY: by default the person who starts an approval cannot approve it.
        -- In this solo test we are both, so we allow it.
        p_initiator_can_complete => true );
    sys.dbms_output.put_line( 'Task created: ' || l_task_id );

    read_state;
    sys.dbms_output.put_line( 'State after create: ' || l_state );

    -- WHY p_autoclaim: if nobody owns the task yet, claim it, then approve.
    apex_human_task.approve_task (
        p_task_id   => l_task_id,
        p_autoclaim => true );

    read_state;
    sys.dbms_output.put_line( 'State after approve: ' || l_state
                           || ', outcome: ' || l_outcome );

    apex_session.delete_session;
exception
    when others then
        apex_session.delete_session;
        raise;
end;
/
