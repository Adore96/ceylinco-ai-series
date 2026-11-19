# The two cases, mapped to APEX

Week 1 block "The two cases, mapped to APEX" (25 minutes). For each step of each workflow: which APEX or database feature builds it, and in which week. The decks redraw these flows in generic form; the client's original diagrams are never shown or committed.

Anchor for the block: **"Every box in the diagram is a feature you already have."**

Spike column: the spike test that must pass for the main approach. If it fails, the fallback column applies. Results are in `docs/environment.md`.

---

## Case 1: Garage estimate document AI (Week 2)

A garage or adjuster sends a photo or scan of a repair estimate. The system reads it, checks it, asks a person when unsure, and saves a claim.

| # | Workflow step | APEX / database feature | Week | Spike | Fallback |
|---|---|---|---|---|---|
| 1 | Garage or adjuster uploads the estimate | Page with a **File Upload** item, saved to `ESTIMATES.image` (BLOB) | 2 | none | none |
| 2 | Clean up the image | Not a separate step on stage. The model reads skewed or stamped photos directly; the 3 messy test images prove it. Production may add an image service before step 3. | 3 (production slide) | none | none |
| 3 | AI reads the document and returns structured data | **`APEX_AI.GENERATE`** with the image as an attachment and a **JSON schema**, called from a page **process** (PL/SQL). Output goes to `ESTIMATES.extracted_json`. | 2 | S1, S2 | `APEX_WEB_SERVICE` call to the Anthropic API; JSON asked for in the prompt and checked with `IS JSON` |
| 4 | Is the result good enough? | **SQL checks** on the JSON: required fields present, line items add up (`JSON_TABLE` + `SUM`), vehicle matches an ACTIVE motor policy. Plus the model's own score (`model_score`). Any failure sets `review_status = NEEDS_REVIEW`. | 2 | none | none |
| 5 | A person reviews uncertain estimates | **Task Definition** (approval task) and a **Unified Task List** page | 2 | S4 | Status column + a plain review page |
| 6 | Save to the core system | PL/SQL procedure creates a row in `CLAIMS` from an AUTO_OK or APPROVED estimate | 2 | none | none |
| 7 | See the customer's whole picture | **Create App wizard**, Customer 360 page (customer, policies, vehicles, claims) | 2 | none | none |

**One deliberate change from the usual flow:** many document-AI flows ask the model for a confidence score and trust it. Here the SQL checks run first and the score is only one input. Anchor: **"Trust the checks, not the model's opinion of itself."**

---

## Case 2: Intelligent call centre (Week 3)

A caller phones the insurer. A person routes the call. The system finds out what the caller wants, looks up the answer, and replies, sending anything uncertain to a person.

| # | Workflow step | APEX / database feature | Week | Spike | Fallback |
|---|---|---|---|---|---|
| 1 | Customer calls | Out of scope on stage: we start from **text transcripts** in `CALLS.transcript` | 3 (production slide) | none | none |
| 2 | First-level human triage | **Triage page**: the agent picks BOT or SPECIALIST (`CALLS.triage_route`) | 3 | none | none |
| 3 | Accident or complaint goes to a specialist | Human choice in step 2, plus an **AI safety flag** (`APEX_AI.GENERATE`, `ai_complaint_flag`) that catches calls the person missed | 3 | S2 | Prompt-only JSON |
| 4 | Telephony and speech-to-text | Production slide only: where a SIP gateway and speech-to-text plug in | 3 (production slide) | none | none |
| 5 | Find the caller's intent | **`APEX_AI.GENERATE`** with a JSON schema: POLICY / CLAIM / PRODUCT_BRANCH / OTHER, saved to `CALLS.ai_intent`. **Shown first in Week 1** on three calls. | 1 and 3 | S2 | Prompt-only JSON |
| 6a | Policy question | **AI Agent** (Shared Component) with a **PL/SQL tool** `get_policy_status`; the same function as an **ORDS GET endpoint** for show | 3 | S3, S5, S7 | Route by intent in PL/SQL and call the function directly; REST shown on a slide |
| 6b | Claim question | Same pattern, tool `get_claim_status`. The caller asks about the claim created in Week 2. | 3 | S3, S5, S7 | As 6a |
| 6c | Product or branch question | **RAG in SQL**: `KB_DOCUMENTS` chunked with `DBMS_VECTOR_CHAIN.UTL_TO_CHUNKS`, embedded through a **Vector Provider** (Gemini), searched with `VECTOR_DISTANCE`, answered by `APEX_AI.GENERATE` with clause citations | 3 | S6 | Embeddings computed outside and loaded as data; the query part stays live |
| 7 | Write the reply | `APEX_AI.GENERATE` writes `CALLS.ai_reply`. Low confidence or "I don't know" sets `reply_status = NEEDS_HUMAN` | 3 | none | none |
| 8 | Speak the reply | Production slide only: text-to-speech | 3 (production slide) | none | none |

Anchor for 6c: **"RAG is a search query before the answer."**

---

## Component index (for the Week 1 tour)

| APEX / database feature | Case 1 step | Case 2 step |
|---|---|---|
| Create App wizard | 7 | |
| Pages, regions, File Upload item | 1, 7 | 2 |
| Processes and PL/SQL | 3, 4, 6 | 3, 5, 7 |
| Generative AI Service ("claude") | 3 | 3, 5, 6c, 7 |
| Vector Provider (Gemini) | | 6c |
| AI Agents and tools | | 6a, 6b |
| Task Definitions and Unified Task List | 5 | |
| ORDS REST endpoint | | 6a, 6b |
| `JSON_TABLE`, `IS JSON`, `JSON_VALUE` | 4 | 3, 5 |
| `VECTOR`, `VECTOR_DISTANCE`, `UTL_TO_CHUNKS` | | 6c |
