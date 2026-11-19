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
- No direct database connection from outside (no SQLcl); all SQL runs in SQL Workshop
- Not yet verified: natural-language interactive reports; full AI agent run

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
