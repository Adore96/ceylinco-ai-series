# Environment

Environment (verified 17 Nov 2026 on the free workspace at oracleapex.com)
- APEX 26.2.1, Oracle AI Database 26ai (23.26.2)
- VECTOR type and VECTOR_DISTANCE work in SQL Workshop
- DBMS_VECTOR and DBMS_VECTOR_CHAIN are available
- NOT available: DBMS_CLOUD, DBMS_CLOUD_AI (no Select AI); no privilege to load ONNX models
- Generative AI Service "claude" (Anthropic Claude) is configured and used by App Builder
- Verified: select apex_ai.generate(p_prompt => '...', p_service_static_id => 'claude') from dual
  returns a classification in ~1.3s
- Present in Shared Components: AI Attributes, AI Agents, AI Services, Task Definitions, Workflows
- Create App Using Generative AI is available
- Vector Provider types: Database ONNX Model, Generative AI Service, Custom PL/SQL
- Vector Provider "gemini_embed" (Google Gemini, gemini-embedding-001, 3072 dimensions) is configured (S6, 21 Nov)
- No direct database connection from outside (no SQLcl); all SQL runs in SQL Workshop
- Natural-language Interactive Report and a full AI Agent run both work (S7, 21 Nov)

## Spike tests (19 Nov)

Results recorded here as S1 to S7 are run.

### S1: Image attachment through APEX_AI ("claude"): PASS (20 Nov)
- `sql/spikes/S1.sql` in SQL Commands: image 779 bytes; answer "Garage: Spike Test Motors, Total: LKR 12,500.00"; 1.4 s.
- Decision: Week 2 extraction uses `APEX_AI.GENERATE` with `p_attachments`. The `APEX_WEB_SERVICE` fallback is not needed.

### S2: JSON schema output from "claude": FAIL, fallback chosen (20 Nov)
- `p_response_json_schema` raised ORA-20959 "The incoming JSON Object does not match the specified JSON Schema" on every run, even with a one-field schema (`intent` enum only). APEX validates the reply against the schema (Oracle AI Database 26ai), and the reply did not match.
- The same call with no schema and the prompt "Reply with only a JSON object like {"intent":"POLICY"}" returned exactly `{"intent":"POLICY"}`.
- Decision: use the planned fallback everywhere (Week 1 classify, Week 2 extraction, Week 3 intent): ask for JSON in the prompt, check it with `IS JSON` and `JSON_VALUE`, retry once.
- UNVERIFIED: why schema mode fails with the Anthropic provider (APEX may not pass the schema to Anthropic). Re-test if APEX is patched.

### S3: PL/SQL tool through APEX_AI.GENERATE: PASS (20 Nov)
- DBMS Output showed `TOOL CALLED with policy_no = LSL-10034`, then "Policy LSL-10034 is **lapsed**. It lapsed on 15 August 2026." (1.4 s). No `apex_session` call was needed in SQL Workshop.
- Decision: Week 3 tools can be tested from SQL with inline `p_tools`. The AI Agents shared component stays the on-stage UI path.
- Note: the reply used Markdown bold. Week 3 prompts should ask for plain text.

### S5: ORDS GET endpoint via ORDS.DEFINE_SERVICE: PASS (20 Nov)
- The schema was already REST-enabled (`USER_ORDS_SCHEMAS` returned one row, status ENABLED), so STEP 1B was not needed.
- `ORDS.DEFINE_SERVICE` with `source_type_collection_item` worked from SQL Commands. In a browser, `https://oracleapex.com/ords/<alias>/spike/policies/LSM-20015` returned one JSON object (policy_no, holder_name, policy_type, status, premium_lkr, next_due_date, links).
- Dates come back as ISO timestamps in UTC (`2026-12-20T00:00:00Z`).
- The endpoint has no authentication. That is fine for synthetic show-only data; the Week 3 production block must mention ORDS privileges/OAuth.

### S4: Task Definition approval: PASS (20 Nov)
- A "Human Task - Create" page process plus a Unified Task List page created a Spike Review task (state Assigned); Approve set it to COMPLETED / APPROVED (checked in `APEX_TASKS`).
- Decision: Week 2 Case 1 review uses a Task Definition (approval). The status-column fallback is not needed.
- APEX 26.2 fills in a locked kebab-case Static ID from the name (`spike-review`).
- The create wizard can finish with no participants: add Potential Owner and Business Administrator explicitly.
- Task APIs do not work from SQL Workshop: `APEX_HUMAN_TASK.CREATE_TASK` raises ORA-20987 "Task definition not found".
- Never call `apex_session.create_session` / `delete_session` in SQL Workshop: it replaces the builder session and signs you out. Test anything that needs an app session from an app page.

### S6: Gemini Vector Provider embeds a sentence: PASS (21 Nov)
- Click path in 26.2: App Builder > Workspace Utilities > Vector Providers > Create. Provider Type **Generative AI Service**, AI Provider **Google Gemini**.
- The 26.2 form fills in Base URL `https://generativelanguage.googleapis.com/v1` and AI Model `gemini-embedding-001` by default. The AI Model field is under **Advanced**.
- Credential "Create New" with the API key creates the Web Credential inline. Test Connection passed.
- `sql/spikes/S6.sql` in SQL Commands: one row, DIMENSIONS 3072, first values `[2.45889695E-003,2.05405001E-002,...`; 0.72 s.
- Decision: Week 3 RAG embeds live through `APEX_AI.GET_VECTOR_EMBEDDINGS` with `gemini_embed`. The "embeddings computed outside" fallback is not needed. Model `gemini-embedding-001`, 3072 dimensions; the schema keeps `VECTOR(*, FLOAT32)`.

### S7a: Natural-language Interactive Report: PASS (21 Nov)
- Region Attributes > Generative AI: Natural Language Support on, Default Search Mode **Search with AI**, Report Context set. The app's AI Attributes use the `claude` service.
- The search bar placeholder is "Search or ask a question...". The question "Show only ACTIVE MOTOR policies and highlight rows where premium is more than 60000" added three report settings: filters `Status = 'ACTIVE'` and `Policy Type = 'MOTOR'`, and a highlight `Premium Lkr > 60000`. The report showed LSM-20007 (highlighted) and LSM-20015 only. Answer in a few seconds.
- The AI result is ordinary report settings: the room can see each filter as a chip and remove it. This is a good Week 1 point: the AI writes the filter, the database runs it.
- Decision: show it live in Week 1 (Block 4, c2-ai slide).

### S7b: AI Agent with a Retrieve Data tool: PASS (21 Nov)
- Shared Components > Generative AI > AI Agents (the list page title is "Generative AI Agents"): `Spike Agent`, service Claude, 1 tool (`get_policies`, Retrieve Data, SQL query on `SPIKE_POLICIES`), Response Format Text.
- Button `Ask agent` with a Dynamic Action **Show AI Assistant** opens a chat dialog titled "Assistant".
- Question 1, "Which ACTIVE motor policies have a premium due before 31 January 2027?": answer was only LSM-20015, Nuwan Bandara, due 20 December 2026. It also explained why LSM-20007 (due 10 March 2027) and LSM-20022 (cancelled) were left out.
- Question 2, about LSL-10034: answer "life policy held by Chamari Fernando, LAPSED, LKR 12,000, no next due date". That row was hidden by the report filter at the time, so the answer came from the tool, not from the page.
- Running the app from Page Designer opens a new tab with the app's own login page. Sign in there before the demo.
- Decision: Week 3 uses the AI Agents shared component with Show AI Assistant as the on-stage path. Week 1 can show it live (Block 4, c6-ai slide).

## Lessons from building the demos

- Week 2 Create App wizard (22 Nov): App Builder > Create shows a quick Name box first; "Use Create App Wizard" opens the full wizard. Add Page > Interactive Report > Table ESTIMATES > Include Form gives a report (page 2) and a modal form (page 3).
- The generated form's File Upload item (P3_IMAGE) does not fill MIME_TYPE or FILE_NAME on insert, so the NOT NULL columns raise ORA-01400. Setting "MIME Type Column" and "Filename Column" on the item did not help on insert. For the test we filled P3_FILE_NAME and P3_MIME_TYPE before submit (P3_MIME_TYPE: Value Protected off). For the live build, use the documented pattern instead: File Upload storage "Table APEX_APPLICATION_TEMP_FILES", then a process that does INSERT INTO estimates ... SELECT blob_content, mime_type, filename FROM apex_application_temp_files WHERE name = :P3_IMAGE. UNVERIFIED: that pattern on 26.2 (to rehearse).
- An APEX form sends an explicit NULL for an empty item, which bypasses a plain column DEFAULT (ORA-01400 on created_on). Fixed in `00_schema.sql` with DEFAULT ON NULL.
- Week 2 review flow, end to end (22 Nov), PASS:
  - Task Definition `Estimate Review` (static ID `estimate-review`): Approval Task, Subject `Review estimate &FILE_NAME. from &GARAGE_NAME.` (column substitutions work), Initiator Can Complete on, Actions Source = Table ESTIMATES, primary key ESTIMATE_ID, two participants (Potential Owner, Business Administrator = your APEX user), Task Details Page created by the "Create Task Details Page" link (it asks to use the next free page number).
  - Two actions On Event = Complete: Outcome Approved runs `update estimates set review_status = 'APPROVED', reviewer = v('APP_USER') where estimate_id = :ESTIMATE_ID;` then `create_claim( :ESTIMATE_ID )`; Outcome Rejected sets REJECTED. `:ESTIMATE_ID` (a column of the Actions Source table) works as a bind variable in the action code.
  - Page 3 processes after the form's own DML: `Read, check and claim` (Execute Code, When Button Pressed CREATE: extract_estimate, check_estimate, create_claim if AUTO_OK) and `Send to review` (Human Task - Create, Definition Estimate Review, Details Primary Key Item P3_ESTIMATE_ID, condition Rows returned: the estimate is NEEDS_REVIEW).
  - Inbox: Create Page > Component > Unified Task List, name `My Reviews`. It lists every task in the workspace, so the old S4 "Spike Review" task shows too; run `sql/spikes/S9_cleanup.sql` or approve it before the session.
  - Result: E01 and E02 became CLM-26-0011 and 0012 on upload; E03 created a task "Review estimate E03.jpg from HILL CAPITAL AUTO CARE"; Approve made CLM-26-0013 (LKR 145,000, reviewer recorded). Upload to claim or task: 4.6 s.
- Chrome asks "allow access to local network" when a page on oracleapex.com fetches from 127.0.0.1. Only needed for our automated uploads, not for the session.

- `APEX_AI.GENERATE` in a WITH clause (21 Nov): if the outer query uses the reply column in several places, Oracle merges the view and calls the model once per use. Three rows took 18 s instead of 3.4 s. `/*+ materialize */` did not help; `rownum` in the inner select did. In app code, call the model once, store the reply, then check it. See `sql/week1/03_classify_calls.sql`.
