# APEX and Oracle AI: questions from Oracle people

Short answers for senior Oracle and SQL staff who are new to APEX. Each answer was checked against Oracle's documentation on the date shown. Anything not confirmed is marked **UNVERIFIED**.

Week 2 and Week 3 questions are added as those sessions are built.

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

Export the application (as SQL, or in APEXlang format since 26.1) and commit the files. In this series every build stage is exported so a failed live step can be replaced by importing the stage.
UNVERIFIED: the exact APEXlang export options in 26.2 on the free workspace; to be checked in the Week 2 build.

### Is it secure to build pages from SQL?

The same rules as any Oracle code apply: use bind variables (`:P1_POLICY_NO`), never string-concatenated SQL. APEX adds authentication schemes, authorization schemes on pages and components, and session state protection. Week 3's ORDS endpoint and agent tools use bind variables for the same reason.
