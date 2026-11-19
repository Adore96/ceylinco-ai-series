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

### S4: Task Definition approval: PASS (20 Nov)
- A "Human Task - Create" page process plus a Unified Task List page created a Spike Review task (state Assigned); Approve set it to COMPLETED / APPROVED (checked in `APEX_TASKS`).
- Decision: Week 2 Case 1 review uses a Task Definition (approval). The status-column fallback is not needed.
- APEX 26.2 fills in a locked kebab-case Static ID from the name (`spike-review`).
- The create wizard can finish with no participants: add Potential Owner and Business Administrator explicitly.
- Task APIs do not work from SQL Workshop: `APEX_HUMAN_TASK.CREATE_TASK` raises ORA-20987 "Task definition not found".
- Never call `apex_session.create_session` / `delete_session` in SQL Workshop: it replaces the builder session and signs you out. Test anything that needs an app session from an app page.
