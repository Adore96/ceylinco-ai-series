# Spike tests S1 to S7

Seven short tests on the free APEX 26.2 workspace. Each one answers one question before the build depends on it. Each has a planned fallback, so a FAIL is useful, not a problem.

Results go into `docs/environment.md` once all seven are run.

| # | Question | File | If it fails |
|---|---|---|---|
| S1 | Can `APEX_AI.GENERATE` send an image to "claude"? | `sql/spikes/S1.sql` | Call the Anthropic API with `APEX_WEB_SERVICE` + base64 image |
| S2 | Does "claude" follow a JSON schema every time? | `sql/spikes/S2.sql` | JSON asked for in the prompt, checked with `IS JSON`, one retry |
| S3 | Can the model call a PL/SQL tool? | `sql/spikes/S3.sql` | AI Agents shared component only; else route by intent in PL/SQL |
| S4 | Can we create and approve a Task Definition task? | clicks below + `sql/spikes/S4.sql` | Status column + review page |
| S5 | Can we publish a GET endpoint and open it in a browser? | `sql/spikes/S5.sql` | Slide only |
| S6 | Can a Gemini Vector Provider embed a sentence? | clicks below + `sql/spikes/S6.sql` | Embeddings computed outside, loaded as data |
| S7 | Do natural-language Interactive Reports and an AI Agent run work? | clicks below + `sql/spikes/S7.sql` | Leave them out of live demos |

Every spike object is named `SPIKE_...` and is removed by `sql/spikes/S9_cleanup.sql`.

## Where to paste SQL

- **SQL Commands** (SQL Workshop > SQL Commands): one statement or one PL/SQL block at a time. Output appears under Results; `DBMS_OUTPUT` lines appear there too.
- **SQL Scripts** (SQL Workshop > SQL Scripts > Create): many statements in one run. Used only for S7 STEP 1 and S9.

Files with several steps say "STEP 1", "STEP 2". Paste one step, run it, then the next.

## Time needed

About 60 to 75 minutes in total. S6 needs a Gemini key first (5 minutes).

---

## Setup (do this first, about 10 minutes)

**A. Create the spike table.** SQL Workshop > SQL Scripts > Create. Paste **STEP 1 of `sql/spikes/S7.sql`** only. Run. Expect 8 statements, 0 errors.

**B. Create the spike app.**
1. App Builder > Create.
2. Choose the plain **Create App** wizard (not "Create App Using Generative AI").
3. Name: `Noob Dev Spikes`.
4. Add Page > **Interactive Report** > Table: `SPIKE_POLICIES`. Page name: `Policies`.
5. Create Application.
6. Write down the **App ID** (on the app home page, top left). Do not commit it.

UNVERIFIED: the exact wizard labels in 26.2. If they differ, any wizard path that ends with an Interactive Report page on `SPIKE_POLICIES` is fine.

**C. Point the app at the "claude" service.** App > Shared Components > Generative AI > **AI Attributes**. Generative AI Service: `claude`. Apply Changes.
(Docs: "Adding Natural Language Support to Interactive Reports", APEX 26.1 App Builder Guide: the service must be selected in AI Attributes.)

**D. Your username.** S3 STEP 2B, S4 and S7 ask for `YOUR_APEX_USERNAME`. Use your APEX login name in capitals. S3/S4/S7 also ask for the App ID from step B. Replace them in the SQL Commands editor only, never in the repo file.

---

## S1, S2, S3

Run the files in order. Each file's header lists the expected output and the PASS rule. S3 has STEP 1 and STEP 2 (STEP 2B only if STEP 2 fails with a session or application error).

---

## S4: Task Definition (clicks, then SQL)

1. App `Noob Dev Spikes` > Shared Components > Workflows and Automations > **Task Definitions** > Create.
2. Name: `Spike Review`. Type: **Approval Task**. Subject: `Spike review`. Static ID: `SPIKE_REVIEW`. Priority: 3.
3. Potential Owner: `YOUR_APEX_USERNAME`. Business Admin: `YOUR_APEX_USERNAME`. Create.
4. On the Task Definition page: **Initiator Can Complete** = On. If it asks for a Task Details Page, click **Create Task Details Page**. Apply Changes.
5. Run `sql/spikes/S4.sql` in SQL Commands (replace App ID and username first).

Why "Initiator Can Complete": by default the person who starts an approval cannot approve it. In this solo test you are both.

Docs: "Creating a Task Definition", APEX 26.1 App Builder Guide (wizard fields Name, Type, Subject, Static ID, Priority, Potential Owner, Business Admin).

Optional, for the Week 1 tour: App > Create Page > **Unified Task List**. Run it to see the task in the inbox UI.

---

## S5: ORDS endpoint (SQL only)

APEX 26.2 removed the RESTful Services pages from SQL Workshop. Run `sql/spikes/S5.sql` step by step. It uses the ORDS PL/SQL API, which ORDS still provides.

Setup A must be done first (the endpoint reads `SPIKE_POLICIES`).

---

## S6: Gemini key, Vector Provider, then SQL

**Get a key (5 minutes):**
1. Open `https://aistudio.google.com` and sign in with a Google account.
2. Click **Get API key** > **Create API key**. Copy the key.
3. Paste it **only** into the APEX form below. Never into chat, a file, or the repo.

Free-tier note: Google's pricing page says free-tier prompts may be used to improve Google products. Our data is synthetic, so that is acceptable. Never send real customer data on the free tier.

**Create the Vector Provider:**
1. App Builder > **Workspace Utilities** > **Vector Providers** > Create.
2. Provider Type: **Generative AI Service**. AI Provider: **Google Gemini**. Name: `Gemini Embeddings`.
3. Credential: create a new one, paste the API key.
4. AI Model (if the form shows it): `gemini-embedding-001`.
5. Advanced > Static ID: `gemini_embed`.
6. Create.
7. Run `sql/spikes/S6.sql` in SQL Commands.

If the result is an error about the model, edit the Vector Provider, set AI Model to `gemini-embedding-2`, and run S6 again. Record which model worked.

Why `gemini-embedding-001` first: it is Google's text-only embedding model and the RAG data is text. `gemini-embedding-2` is newer and multimodal. Both use Gemini's `embedContent` method, which is the one APEX calls for Gemini embeddings.

Docs: "Managing Vector Providers" and "Creating Generative AI Service Objects", APEX 26.1 App Builder Guide (Vector Providers are workspace-level; Gemini uses `embedContent`; APEX adds the key itself). Google "Embeddings" page, Gemini API docs.
UNVERIFIED: which Gemini model names the APEX 26.2 form accepts, and whether the form asks for a model at all.

---

## S7: Natural-language Interactive Report, then AI Agent

**S7a, Interactive Report (clicks only):**
1. App `Noob Dev Spikes` > page `Policies` > Page Designer.
2. Select the Interactive Report region > Attributes tab.
3. Generative AI > **Natural Language Support**: On. Default Search Mode: **Search with AI**.
4. Report Context: `Synthetic insurance policies for Lanka Shield Assurance: policy number, holder, type (LIFE or MOTOR), status, premium in LKR, next due date.`
5. Save and Run Page.
6. In the search bar ("Search or ask a question"), type:
   `Show only ACTIVE MOTOR policies and highlight rows where premium is more than 60000`
7. PASS: the report shows LSM-20007 and LSM-20015 only, and LSM-20007 is highlighted.

Docs: "Adding Natural Language Support to Interactive Reports", APEX 26.1 App Builder Guide. It applies filters, highlights, sorts, breaks and charts. It does not answer open questions like "why".

**S7b, AI Agent (clicks, then SQL):**
1. App > Shared Components > Generative AI > **AI Agents** > Create.
2. Name: `Spike Agent`. Service: `claude`. Response Format: **Text**.
3. System Prompt: `You answer questions about insurance policies. Use the get_policies tool. Only use data the tool returns. If the data does not answer the question, say so.`
4. Advanced > Static ID: `spike_agent`. Create.
5. Tools tab > **Add Tool**.
6. Name: `get_policies`. Type: **Retrieve Data**. Execution Point: **On Demand**.
7. Description: `Returns all policies with number, holder, type, status, premium in LKR and next due date.`
8. Settings > Type: **SQL Query**:
   `select policy_no, holder_name, policy_type, status, premium_lkr, next_due_date from spike_policies`
9. Create.
10. Run **STEP 2 of `sql/spikes/S7.sql`** in SQL Commands (replace App ID and username).

Docs: "Managing AI Agents and AI Tools", APEX 26.1 App Builder Guide. `APEX_AI.GENERATE` Signature 1 (`p_agent_static_id`), APEX 26.1 API Reference.

---

## What to paste back into the chat

Copy this, fill it in, paste it. Include the full output or error text for anything that is not a clean PASS.

```
S1: PASS/FAIL  -
S2: PASS/FAIL  - clean runs: _ of 3
S3: PASS/FAIL  - needed STEP 2B? yes/no
S4: PASS/FAIL  -
S5: PASS/FAIL  - ORDS enabled already? yes/no
S6: PASS/FAIL  - model: ____  dimensions: ____
S7a (NL report): PASS/FAIL  -
S7b (agent run): PASS/FAIL  -
Anything odd you noticed:
```

Do not run `S9_cleanup.sql` until the results are recorded.
