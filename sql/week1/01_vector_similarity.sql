-- =====================================================================
-- Week 1 demo 1: vector similarity in plain SQL
-- =====================================================================
-- ANCHOR: "A vector is a list of numbers. Close numbers = close meaning."
--
-- WHY this demo: before any AI model, show that "search by meaning" is
--      just a distance calculation and an ORDER BY. A SQL audience
--      already knows ORDER BY ... FETCH FIRST.
--
-- WHAT IT DOES: six caller questions, each with a hand-made 3-number
--   vector. The numbers mean [motor, life, branch]. A real embedding
--   model makes hundreds of numbers, but the SQL is the same.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- No tables needed: everything is in the WITH clause.
--
-- EXPECTED RESULT (6 rows, closest first):
--   DISTANCE  QUESTION
--   .0038     Windscreen cracked on the highway
--   .0082     Car hit at a junction, how do I claim?
--   .8314     Is there a branch near Galle?
--   .8325     When is my life premium due?
--   .8776     Kandy branch opening hours
--   .8896     Hospital cover on my life policy
--
-- TALKING POINT: the search phrase "accident repair" shares no words with
--   "Windscreen cracked on the highway", yet it ranks first. That is the
--   difference between keyword search and meaning search.
--
-- Docs checked (19 Nov 2026), Oracle AI Database 26ai, AI Vector Search
--   User's Guide: TO_VECTOR, VECTOR_DISTANCE (metric COSINE).
-- =====================================================================
with questions ( question, v ) as (
    -- [motor, life, branch]
    select 'Car hit at a junction, how do I claim?', to_vector('[0.90, 0.10, 0.00]') from dual union all
    select 'When is my life premium due?',           to_vector('[0.10, 0.90, 0.00]') from dual union all
    select 'Kandy branch opening hours',             to_vector('[0.00, 0.10, 0.90]') from dual union all
    select 'Windscreen cracked on the highway',      to_vector('[0.95, 0.00, 0.05]') from dual union all
    select 'Hospital cover on my life policy',       to_vector('[0.05, 0.95, 0.00]') from dual union all
    select 'Is there a branch near Galle?',          to_vector('[0.05, 0.00, 0.95]') from dual
),
search ( v ) as (
    -- The search phrase "accident repair", as a hand-made vector.
    select to_vector('[0.85, 0.05, 0.10]') from dual
)
select round( vector_distance( q.v, s.v, cosine ), 4 ) as distance,
       q.question
  from questions q
 cross join search s
 order by distance;
