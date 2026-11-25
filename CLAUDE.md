# Working rules for this repo

Three-session series (brand: Noob Dev) on AI in Oracle APEX for senior technical leads at an insurer. Audience is strong in Oracle and SQL, new to APEX and AI. The presenter is also new to APEX, so **accuracy matters more than anything**.

## Read first

- `docs/plan.html`: the client plan (sessions, timings, the application).
- `docs/environment.md`: what the free APEX workspace supports, including spike test results.
- `docs/spikes.md`: the spike tests and their fallbacks.
- `data/reference-ids.md`: IDs that seed data, transcripts and estimates must share.

## Hard rules

- **Synthetic data only.** Fictional insurer: Lanka Shield Assurance.
- **Never commit** API keys, credentials, workspace names, schema names, App IDs, usernames, or the client's original workflow images.
- **No database connection from here.** Every SQL script is pasted by hand into SQL Workshop. So:
    - one idea per script, short;
    - the header says where to paste it (SQL Commands or SQL Scripts), and the expected output;
    - comments explain **why**, not what.
- **Verify every** package, function, parameter and click path against the official Oracle docs for **APEX 26.2** and **Oracle AI Database 26ai**. If only an older docs version confirms it, say which. Mark anything not confirmed with `UNVERIFIED:`.
- **Not available** on the workspace: `DBMS_CLOUD`, Select AI (`DBMS_CLOUD_AI`), ONNX models. Do not use them.
- **APEX 26.2 removed the RESTful Services pages** in SQL Workshop. Define ORDS endpoints with the ORDS PL/SQL API.
- **Commit after each file**, with a message that says why.

## Conventions

- AI service static ID: `claude`. Vector Provider static ID: `gemini_embed`.
- Shared schema: `sql/00_schema.sql` (source of truth); reset with `sql/99_drop_schema.sql`.
- Per-week SQL: `sql/week1/`, `sql/week2/`, `sql/week3/`, numbered in run order.
- Spike objects start with `SPIKE_` and are removed by `sql/spikes/S9_cleanup.sql`.
- Writing style for docs: simple English, short sentences, active voice. Each teaching point gets a one-line anchor (for example "APEX is SQL with a screen").
