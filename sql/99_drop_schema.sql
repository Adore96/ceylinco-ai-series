-- =====================================================================
-- 99_drop_schema.sql: remove the shared schema to start a rehearsal again
-- =====================================================================
-- WARNING: this deletes all 8 tables and every row in them. There is no
--          undo. Use it only on the rehearsal workspace.
--
-- HOW TO RUN: SQL Workshop > SQL Scripts > Create. Paste. Run.
-- EXPECTED: "Statements processed: 8". An error on one line only means
--   that table did not exist.
--
-- WHY "cascade constraints": ESTIMATES and CLAIMS point at each other,
--   so neither can be dropped first without it.
-- WHY "purge": skip the recycle bin so names are free at once.
-- =====================================================================
drop table kb_chunks    cascade constraints purge;
drop table kb_documents cascade constraints purge;
drop table calls        cascade constraints purge;
drop table claims       cascade constraints purge;
drop table estimates    cascade constraints purge;
drop table vehicles     cascade constraints purge;
drop table policies     cascade constraints purge;
drop table customers    cascade constraints purge;
