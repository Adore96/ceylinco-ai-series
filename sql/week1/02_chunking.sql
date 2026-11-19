-- =====================================================================
-- Week 1 demo 2: chunking a document inside the database
-- =====================================================================
-- ANCHOR: "Cut the document before you search it."
--
-- WHY this demo: an AI model answers best from short, focused pieces of
--      text, not a whole manual. Oracle can cut text into pieces (chunks)
--      with one SQL call, no Python. Week 3 stores these chunks in
--      KB_CHUNKS and embeds them.
--
-- WHAT IT DOES: cuts a short, made-up motor product sheet into chunks of
--   at most 40 words, breaking at sentence ends, with a 4-word overlap so
--   a sentence split across two chunks is not lost.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- No tables needed.
--
-- EXPECTED RESULT: 3 or 4 rows (the text is 110 words). Columns CHUNK_ID (1, 2, 3 ...),
--   CHUNK_OFFSET (where the chunk starts), CHUNK_LENGTH (characters),
--   CHUNK_DATA (the text). Each chunk should end at a full stop.
--
-- TALKING POINT: change "max" to 20 and run again: more, smaller chunks.
--   Chunk size is a design choice, not a magic number.
--
-- Docs checked (19 Nov 2026), Oracle AI Database 26ai, PL/SQL Packages
--   and Types Reference, DBMS_VECTOR_CHAIN.UTL_TO_CHUNKS: returns one JSON
--   document per chunk (chunk_id, chunk_offset, chunk_length, chunk_data).
--   Parameters: by (words), max (10 to 1000 for words), overlap (0 or 5%
--   to 20% of max), split (sentence works with by = words).
-- =====================================================================
with doc ( body ) as (
    select to_clob(
        '1. Cover. Lanka Shield Motor Comprehensive covers accidental damage, fire and theft of the insured vehicle anywhere in Sri Lanka. '
     || '2. Excess. The first LKR 15,000 of every accident claim is paid by the policyholder. '
     || '3. Windscreen. Windscreen and glass damage is paid in full without excess, once per policy year. '
     || '4. Claims. Report an accident within 48 hours by calling the hotline or visiting any branch. An assessor visits within two working days. '
     || '5. Garages. Repairs can be done at any garage, but the garage must send an itemised estimate before work starts. '
     || '6. Exclusions. Racing, driving without a valid licence and driving under the influence are not covered.' )
    from dual
)
select jt.chunk_id,
       jt.chunk_offset,
       jt.chunk_length,
       jt.chunk_data
  from doc d,
       -- WHY table(): the function returns a collection; table() turns it
       -- into rows. Each row's COLUMN_VALUE is one chunk as JSON.
       table( dbms_vector_chain.utl_to_chunks(
                  d.body,
                  json('{ "by": "words", "max": "40", "overlap": "4", "split": "sentence" }') ) ) c,
       json_table( c.column_value, '$'
           columns (
               chunk_id     number         path '$.chunk_id',
               chunk_offset number         path '$.chunk_offset',
               chunk_length number         path '$.chunk_length',
               chunk_data   varchar2(4000) path '$.chunk_data' ) ) jt
 order by jt.chunk_id;
