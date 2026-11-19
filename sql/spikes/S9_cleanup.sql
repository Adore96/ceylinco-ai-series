-- =====================================================================
-- S9: Remove spike objects from the schema
-- =====================================================================
-- WHY: the Week 2 build starts from a clean schema. Spike objects all
--      start with SPIKE_ so they are easy to find and remove.
--
-- WHEN: only after every spike result is recorded in docs/environment.md.
--
-- HOW TO RUN: SQL Workshop > SQL Scripts > Create. Paste. Run.
-- Expected: "Statements processed: 3, successful: 3" (an error on a
--   statement only means that object was never created; that is fine).
--
-- Clicks (not SQL), when you are done with the spike app:
--   1. App Builder > "Noob Dev Spikes" > Delete this Application.
--      This also removes the SPIKE_REVIEW Task Definition and spike_agent.
--   KEEP: the "claude" Generative AI Service and the gemini_embed Vector
--   Provider. Weeks 1 to 3 use them.
-- =====================================================================
-- WHY first: the endpoint reads SPIKE_POLICIES. Remove it before the table.
begin
    ords.delete_module( p_module_name => 'spike' );
    commit;
end;
/
drop procedure spike_tool_policy_status;
drop table spike_policies purge;
