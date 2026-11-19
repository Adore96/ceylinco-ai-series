-- =====================================================================
-- S7: Natural-language Interactive Report + AI Agent full run
-- =====================================================================
-- WHY: both were still unverified in v2 of the plan. If they work, they
--      go into the Week 1 tour and the Week 3 agent block. If not, we
--      leave them out of the live demos.
--
-- This file has 2 steps. STEP 1 makes a small table that both tests use.
-- The clicks for the Interactive Report and the AI Agent are in
-- docs/spikes.md, section S7. Run STEP 2 after those clicks.
--
-- Docs checked (19 Nov 2026):
--   Adding Natural Language Support to Interactive Reports,
--   APEX 26.1 App Builder Guide (needs a Generative AI Service selected in
--   Shared Components > AI Attributes).
--   Managing AI Agents and AI Tools, APEX 26.1 App Builder Guide
--   (AI Agent is an application Shared Component; tool type Retrieve Data,
--   Execution Point On Demand).
--   APEX_AI.GENERATE Signature 1 (p_agent_static_id, p_prompt),
--   APEX 26.1 API Reference.
-- UNVERIFIED: that an agent's On Demand tool runs when called from
--   SQL Workshop through apex_session. That is what STEP 2 tests.
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 1: a tiny policy table with 6 synthetic rows.
-- HOW TO RUN: SQL Workshop > SQL Scripts > Create. Paste STEP 1 only.
--   Run. (SQL Scripts runs many statements in one go; SQL Commands runs
--   one at a time.)
-- Expected: "Statements processed: 8, successful: 8, with errors: 0".
-- ---------------------------------------------------------------------
create table spike_policies (
    policy_no       varchar2(20)  primary key,
    holder_name     varchar2(100) not null,
    policy_type     varchar2(10)  not null check ( policy_type in ('LIFE','MOTOR') ),
    status          varchar2(10)  not null check ( status in ('ACTIVE','LAPSED','CANCELLED') ),
    premium_lkr     number(12,2)  not null,
    next_due_date   date
);

insert into spike_policies values ('LSL-10021','Sunil Jayawardena',     'LIFE', 'ACTIVE', 18500, date '2026-12-01');
insert into spike_policies values ('LSL-10034','Chamari Fernando',      'LIFE', 'LAPSED', 12000, null);
insert into spike_policies values ('LSL-10045','Tharushi Wickramasinghe','LIFE','ACTIVE', 22750, date '2027-01-15');
insert into spike_policies values ('LSM-20007','Kasun Ranasinghe',      'MOTOR','ACTIVE', 64200, date '2027-03-10');
insert into spike_policies values ('LSM-20015','Nuwan Bandara',         'MOTOR','ACTIVE', 58900, date '2026-12-20');
insert into spike_policies values ('LSM-20022','Dhammika Pathirana',    'MOTOR','CANCELLED', 47300, null);
commit;


-- ---------------------------------------------------------------------
-- STEP 2: run the AI Agent from SQL (after the clicks in docs/spikes.md).
-- HOW TO RUN: SQL Workshop > SQL Commands. Replace the App ID and
--   username. Paste STEP 2 only. Run.
-- Expected DBMS Output, roughly:
--   Answer: One policy: LSM-20015, Nuwan Bandara, due 20 December 2026.
--   (LSM-20007 is due in March 2027 and LSM-20022 is CANCELLED, so both
--   must be left out.)
-- PASS: the answer names LSM-20015 and Nuwan Bandara, and nothing else.
-- FAIL: an error, or a reply that says it has no data.
-- ---------------------------------------------------------------------
declare
    c_app_id constant number        := 100;                  -- your "Noob Dev Spikes" App ID
    c_user   constant varchar2(255) := 'YOUR_APEX_USERNAME'; -- your login, in capitals
    l_answer clob;
begin
    -- WHY a session: the agent is a Shared Component of one app, so APEX
    -- must know which app we are in.
    apex_session.create_session (
        p_app_id   => c_app_id,
        p_page_id  => 1,
        p_username => c_user );

    l_answer := apex_ai.generate (
        p_agent_static_id => 'spike_agent',
        p_prompt          => 'Which ACTIVE motor policies have a premium due before 31 January 2027? Give policy number, holder and due date.' );

    sys.dbms_output.put_line( 'Answer: ' || l_answer );
    apex_session.delete_session;
exception
    when others then
        apex_session.delete_session;
        raise;
end;
/
