-- =====================================================================
-- S6: Can a Gemini Vector Provider turn a sentence into an embedding?
-- =====================================================================
-- WHY: Week 3 RAG stores the knowledge base as vectors. Our workspace
--      cannot load ONNX models and has no DBMS_CLOUD, so embeddings must
--      come from an outside provider through APEX. Fallback: compute the
--      embeddings outside, load them as data, and show only the query
--      part live.
--
-- BEFORE YOU RUN: get a Gemini API key and create the Vector Provider by
--   clicking (docs/spikes.md, section S6). Static ID must be gemini_embed.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
--
-- EXPECTED OUTPUT (Results grid, one row):
--   DIMENSIONS   FIRST_VALUES
--   3072         [1.23E-002, -4.5E-003, ...   (numbers will differ)
--   The dimension count depends on the model: write down what you see.
--   The schema will use VECTOR(*, FLOAT32) so the count does not lock us in.
--
-- PASS: one row with a number in DIMENSIONS.
-- FAIL: an error (for example ORA-20001 or a 400/403 from Google).
--       Copy it into the chat.
--
-- Docs checked (19 Nov 2026):
--   APEX_AI.GET_VECTOR_EMBEDDINGS Signature 1 (p_value, p_service_static_id
--   = the Vector Provider static ID), APEX 26.1 API Reference.
--   Managing Vector Providers, APEX 26.1 App Builder Guide (Workspace
--   Utilities > Vector Providers, Provider Type Generative AI Service,
--   AI Provider Google Gemini).
--   VECTOR_DIMENSION_COUNT and VECTOR_SERIALIZE, Oracle AI Database 26ai
--   AI Vector Search User's Guide.
-- =====================================================================
select vector_dimension_count( v )                         as dimensions,
       substr( vector_serialize( v returning clob ), 1, 60 ) as first_values
  from ( select apex_ai.get_vector_embeddings (
                    p_value             => 'Where is the nearest Lanka Shield branch in Kandy?',
                    p_service_static_id => 'gemini_embed' ) as v
           from dual );
