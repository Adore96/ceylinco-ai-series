# APEX and Oracle AI: questions from Oracle people

Short answers for senior Oracle and SQL staff who are new to APEX. Each answer was checked against Oracle's documentation on the date shown. Anything not confirmed is marked **UNVERIFIED**.

Week 3 questions are added when that session is built.

---

## Week 1 (checked 19 November 2026, APEX 26.2, Oracle AI Database 26ai)

### What is APEX, in one line?

**"APEX is SQL with a screen."** It is a low-code tool that runs inside the Oracle database. Applications are stored as metadata in the database, and pages are built from SQL queries and PL/SQL.

### Where does an APEX app actually run?

Browser > ORDS (Oracle REST Data Services, the web listener) > the APEX engine, which is PL/SQL inside the database > your tables. ORDS only passes requests through; the logic runs in the database next to the data.

### Does APEX cost extra?

No. Oracle describes APEX as a no-cost, fully supported feature of the Oracle Database, included with all supported editions. You still need the database licence, and AI providers (Anthropic, Google) bill separately for what you send them.
Source: Oracle APEX product page on oracle.com, section "Pricing: Free with Oracle Database".

### Is the free workspace we use the same as production APEX?

Same APEX version (26.2) and database (Oracle AI Database 26ai). It has limits: no `DBMS_CLOUD`, no Select AI, and no permission to load ONNX models. See `docs/environment.md`. On your own database or on Autonomous Database these limits do not apply.

### Where are AI API keys stored? Do they end up in exported apps?

In **Web Credentials** (Workspace Utilities). Code refers to the Generative AI Service by its static ID (for example `'claude'`), never to the key. Oracle documents that an application export leaves out the Web Credential secret.
Source: "Understanding Generative AI Support in APEX", APEX App Builder User's Guide.

### When we call the AI, does our data leave the database?

Yes. The prompt, and any attachment or rows you put in it, are sent to the AI provider. Design for it: send only what the task needs, and check your provider's data terms. (On Google's free Gemini tier, Google's pricing page says prompts may be used to improve its products. Our demos use synthetic data only.)

### What is the difference between `APEX_AI` and Select AI?

- **`APEX_AI`** (PL/SQL package in APEX): you write the prompt and call the model, for example `APEX_AI.GENERATE`. Works on our free workspace. Requires an APEX session.
- **Select AI** (`DBMS_CLOUD_AI`, `SELECT AI ...`): the database turns a plain-language question into SQL using your schema's metadata, and can run it, show it, or explain it. It needs `DBMS_CLOUD_AI`, which our free workspace does not have, so Week 1 explains it but does not demo it.
Source: "About Select AI", Oracle Select AI documentation; `APEX_AI` package, APEX 26.2 API Reference.

### The natural-language Interactive Report: does the AI write and run SQL against my tables?

No. Oracle documents that it turns the request into normal report settings (filters, highlights, sorts, breaks, charts, pivots) instead of running AI-generated SQL. The user can see and undo each setting.
Source: "What's New in Oracle APEX 26.1" (oracle.com/apex) and "Adding Natural Language Support to Interactive Reports", APEX App Builder User's Guide.

### Can we do vector search without an embedding model in the database?

Yes. The `VECTOR` type and `VECTOR_DISTANCE` are plain SQL. The embeddings can come from an outside provider through an APEX **Vector Provider** (we use Google Gemini) and are stored in a normal table column. Week 1 demo 1 uses hand-made vectors to show the SQL with no model at all.

### What is "chunking" and why does the database do it?

Cutting long documents into short pieces before embedding them, so a search returns a focused paragraph instead of a whole manual. `DBMS_VECTOR_CHAIN.UTL_TO_CHUNKS` does it in one SQL call, with settings for size, overlap and where to split. Week 1 demo 2 shows it.

### We have REST APIs today. Where do they go in APEX 26.2?

APEX 26.2 removed the RESTful Services pages ("REST Workshop") from SQL Workshop. Authoring moved to SQL Developer Web; existing ORDS modules keep working. We define our Week 3 endpoints with the ORDS PL/SQL API (`ORDS.DEFINE_SERVICE`), which is a script and easy to repeat.
Source: APEX 26.2 new features (oracle.com) and the APEX blog's 26.2 update post; ORDS PL/SQL Package Reference.

### How do we put APEX apps under version control?

Export the application and commit the files. APEX 26.2 offers two export formats, SQL and APEXlang (a .zip), and the export types Standard, Runtime, Full and Custom. In this series every build stage is exported so a failed live step can be replaced by importing the stage (`docs/checkpoints.md`). We keep those exports out of this repo because they hold our app and workspace details.
Source: "Exporting an Application", APEX App Builder User's Guide 26.2. Importing APEXlang needs ORDS 26.3.0 or later (same guide, "Importing Export Files").

### Is it secure to build pages from SQL?

The same rules as any Oracle code apply: use bind variables (`:P1_POLICY_NO`), never string-concatenated SQL. APEX adds authentication schemes, authorization schemes on pages and components, and session state protection. Week 3's ORDS endpoint and agent tools use bind variables for the same reason.

---

## Week 2 (checked 22 November 2026, APEX 26.2, Oracle AI Database 26ai)

Anchor: **"The AI reads. SQL decides. A person signs off when SQL says no."**

### Where does the uploaded image live before it reaches our table?

In `APEX_APPLICATION_TEMP_FILES`. A File Upload item with Storage Type "Table APEX_APPLICATION_TEMP_FILES" stores the file there. The item's value is the key of that row (`where name = :P10_FILE`). Our page process copies the file name, MIME type and BLOB into ESTIMATES. "Purge File at: End of Request" deletes the temporary row when the page submit ends.
Source: "About Item Types", File Upload section, APEX App Builder User's Guide 26.2. Tested on our workspace on 22 Nov (`docs/environment.md`).

### Why not let the generated form save the BLOB directly?

The generated form did not fill the NOT NULL columns `mime_type` and `file_name` on insert, so the insert failed with ORA-01400. Setting "MIME Type Column" and "Filename Column" did not help. The temporary-file pattern fills them from `APEX_APPLICATION_TEMP_FILES` and worked first time (`docs/environment.md`).
UNVERIFIED: why the form's BLOB settings did not fill those columns on 26.2.

### Does the image leave the database?

Yes. `APEX_AI.GENERATE` sends the prompt and the image attachment to the AI provider behind the `claude` service (Anthropic). Treat it like any outside processor: check the provider's data terms and send only what the task needs. Our estimates are synthetic.

### Why ask for JSON in the prompt instead of using a JSON schema?

`APEX_AI.GENERATE` has `p_response_json_schema`. On our Claude service it raised ORA-20959 on every run, even with a one-field schema (spike S2). So we ask for JSON in the prompt, check it with `IS JSON`, and retry once. If it is still not JSON, the estimate goes to review. We never guess.
UNVERIFIED: why schema mode fails with the Anthropic provider.

### Why not trust the model's confidence score?

On our 12 test images the score was 0.93 to 0.97 every time. That includes E08 (lapsed policy) and E09 (not insured), which must never become claims. The model cannot know our policy data. The score is one check of four; the other three are plain SQL. E03 went to review because one `SUM` disagreed with the written total, while the model was 93% sure.
Source: `docs/week2-extraction-results.md`.

### Why does the model copy a wrong total instead of fixing it?

The prompt tells it to copy the total exactly as written and not to add up the lines. If the model "fixed" totals, a wrong total on paper would slip through, and the `items_add_up` check would have nothing to catch. Reading and checking are separate jobs.

### How does SQL read the JSON?

With standard SQL/JSON on the native JSON type: `JSON_VALUE` for single fields, `JSON_TABLE` to turn the `line_items` array into rows for `SUM`, `JSON_EXISTS` for "at least one line", and `JSON_OBJECT` to write the check results.
Source: Oracle AI Database 26ai JSON Developer's Guide; `sql/week2/03_check_estimate.sql`.

### Why are the AI call and the checks in stored procedures, not in the page?

So the same code runs from SQL Commands, a page process, or a task action. We test it without a screen. The page process is one line per call.

### What happens if the AI call fails in the middle of a page submit?

An unhandled error stops the page processing and APEX shows the error. The save and the AI call run in the same request, so expect the whole submit to roll back, including the new estimate row.
UNVERIFIED: that the insert rolls back in every failure case. Test it in rehearsal before you say it.

### Who can approve a review? Can someone approve their own estimate?

The Task Definition lists participants: Potential Owners (who may approve) and Business Administrators. On stage we turn on "Initiator Can Complete", because the presenter both uploads and approves. In production leave it off (the default) so nobody approves their own work.
Source: "Creating a Task Definition", APEX App Builder User's Guide 26.2.

### Is there an audit trail for approvals?

APEX keeps each task with its state and outcome; we read them from the `APEX_TASKS` view in spike S4. The task action also writes the reviewer into `estimates.reviewer`.
UNVERIFIED: the full list of task history views in 26.2.

### Task Definition or Workflow: which one?

A Task Definition is one human step: approve or reject, with actions on each outcome. A Workflow chains several steps, including human tasks. Case 1 needs one approval, so a Task Definition is enough. Both live under Shared Components > Workflows and Automations.
Source: "Creating a Task Definition", APEX App Builder User's Guide 26.2. UNVERIFIED: the Workflow description; read the Workflows chapter before quoting it.

### Can we create a task from SQL, for a batch of estimates?

Not from SQL Workshop. `APEX_HUMAN_TASK.CREATE_TASK` raised "Task definition not found" there, because it needs an APEX application session (spike S4). From inside the app, a "Human Task - Create" page process works.
UNVERIFIED: creating tasks from an APEX Automation.

### Why can a claim not be created twice?

`create_claim` locks the estimate row (`SELECT ... FOR UPDATE`) and returns the existing claim number if the estimate already has one. It also refuses any estimate that is not AUTO_OK or APPROVED. A double click, or a page that skips the review, cannot make a claim.
This protects one estimate row. Uploading the same file twice makes two rows and two claims. Production would add a duplicate check (same garage, estimate number and reg).

### Why are claim numbers MAX + 1 and not a sequence?

So the live demo continues the seeded series (CLM-26-0011 onwards), which Week 3 callers quote. In production, use a sequence: MAX + 1 is not safe when many estimates arrive at once.

### Why did estimate IDs jump from 31 to 8?

The IDs come from an identity column. On our cloud service the second test row got a lower ID than the first. Most likely each database instance caches its own block of values. Identity values are unique, not ordered. Sort by `created_on` to find the latest row.
Source: test on 22 Nov (`docs/environment.md`). UNVERIFIED: the cause on this service.

### How long does one estimate take?

About 2.2 to 3.1 seconds to read and check, and about 4.6 seconds from upload to claim or task. Each estimate is one model call with a 39 to 77 KB image. The provider bills per call by tokens.
Source: `docs/week2-extraction-results.md`, `docs/environment.md`.

### Can the AI step run in the background so the user does not wait?

UNVERIFIED: APEX has background page processing (execution chains) and Automations, but we have not run `APEX_AI.GENERATE` that way on 26.2. We run it in the page so the room sees the result.

### How do we move this app to test and production?

Export the app (SQL or APEXlang) and import it with App Builder > Import, or script the import with `APEX_APPLICATION_INSTALL` (set the application ID, workspace and schema, then run the export file). Tables and procedures move with your normal schema scripts. Web Credential secrets are not exported, so set the AI key in each environment.
Source: "Exporting an Application" and "Importing Export Files", APEX App Builder User's Guide 26.2; "Import Script Examples", APEX API Reference 26.2.

### Can we limit what users upload?

Yes. The File Upload item has File Types (we use `image/*`) and Maximum File Size. Treat these as convenience, not security: the server still decides. `check_estimate` sends anything that is not a garage estimate to review.
Source: "About Item Types", File Upload section, APEX App Builder User's Guide 26.2; Property Editor on 26.2 (`docs/environment.md`).
