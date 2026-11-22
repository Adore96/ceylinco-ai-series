# Week 2 build guide: Case 1, garage estimate document AI

Presenter script for Wednesday 2 December 2026. Use it in rehearsal (26 November to 1 December) and on the day.

> **The AI reads. SQL decides. A person signs off when SQL says no.**

How to read each step:

- **Clicks**: the exact path in APEX 26.2. Click only. **Never type a URL in the builder tab.** It ends the builder session (`docs/environment.md`).
- **Say**: the teaching point. Read it, or say it in your own words.
- **Expect**: what the screen shows when the step works.
- **Fallback**: what to do when it does not. Stages are in `docs/checkpoints.md`.
- **Source**: where each fact comes from. "env" = `docs/environment.md`, "results" = `docs/week2-extraction-results.md`, "docs" = the Oracle APEX 26.2 documentation page named. `UNVERIFIED:` = not tested and not in the docs. Rehearse it.

Times are minutes from the start of the session (0:00).

| Block | Minutes | Clock | Steps |
|---|---|---|---|
| Recap of Week 1 | 10 | 0:00 to 0:10 | slides only |
| Data model | 20 | 0:10 to 0:30 | 1, 2 |
| Core app | 45 | 0:30 to 1:15 | 3, 4 |
| Break | 15 | 1:15 to 1:30 | |
| Case 1a: upload and AI extract | 35 | 1:30 to 2:05 | 5 to 8 |
| Break | 10 | 2:05 to 2:15 | |
| Case 1b: checks, approval, save as claim | 50 | 2:15 to 3:05 | 9 to 15 |
| Q&A | 25 | 3:05 to 3:30 | step 16 if time is left over |

---

## Pre-flight (the evening before, and again 30 minutes before the session)

The live build must create claims **CLM-26-0011, 0012 and 0013** in that order. Week 3 callers ask about those numbers (`data/reference-ids.md`). The rehearsal workspace already holds them, so reset first.

1. **Export the rehearsal app** into `apex/week2/` (see `docs/checkpoints.md`). Check that every stage file is there.
2. **Delete the rehearsal apps.** App Builder > the app > Delete Application (in Tasks on the right). Do this for "Lanka Shield Claims" and "Noob Dev Spikes".
   - Why: the Unified Task List shows **every task in the workspace**. The old "Spike Review" task and the rehearsal E03 task would appear in My Reviews (env).
   - Deleting the app also removes its Task Definition (`sql/spikes/S9_cleanup.sql` header).
   - UNVERIFIED: that deleting the app also removes its task rows. If old tasks still show in a Unified Task List after the delete, open each one and approve or reject it before the session.
3. **Run `sql/spikes/S9_cleanup.sql`** (SQL Workshop > SQL Scripts) if the spike objects still exist.
4. **Run `sql/99_drop_schema.sql`** (SQL Scripts). Why: `00_schema.sql` fails if the tables still exist.
   - Do not run `00_schema.sql` yet. Step 1 runs it live.
5. **Keep** the Generative AI Service `claude` and the Vector Provider `gemini_embed`. They are workspace settings, not app settings.
6. **Sign in** to the workspace in Chrome. Keep one tab for the builder. When you first run the new app, it opens its own login page in a new tab. Sign in there too (env).
7. **Check the outage notices** on the workspace home page. On 22 November the service announced a maintenance window.
8. **Break-the-AI tools** (step 16), on the presenter laptop: Python with Pillow, Edge, and a Caveat `.ttf` font file. Run one test render the day before (see step 16).
   - UNVERIFIED: the Caveat font path on the presenter laptop. No path is recorded in the repo.
9. **Open these files** in an editor, ready to copy: `sql/00_schema.sql`, `sql/week2/01_seed_data.sql`, `02_extract_estimate.sql`, `03_check_estimate.sql`, `04_create_claim.sql`, and this guide. Keep `data/estimates/` open in Explorer for uploads.

---

## Data model (0:10 to 0:30)

### Step 1. Create the tables and the seed data (8 min, 0:10 to 0:18)

**Clicks**
1. SQL Workshop > SQL Scripts > Create.
2. Paste `sql/00_schema.sql`. Name it `00_schema`. Click Run, then Run Now.
3. SQL Scripts > Create. Paste `sql/week2/01_seed_data.sql`. Name it `week2_01_seed_data`. Run, Run Now.

**Say**
- "APEX is SQL with a screen. Everything we build today sits on these eight tables."
- "The seed data is generated from one spec file. The estimates you will see later are drawn from the same file. That is why every reg number on paper exists in our tables."

**Expect**
- Seed script: "Statements processed: 136, successful: 136, with errors: 0" (header of `01_seed_data.sql`).
- Rows: customers 40, policies 60 (35 life, 25 motor), vehicles 25, claims 10.

**Fallback**
- An error in `00_schema` that says the name is already used: the reset was skipped. Run `sql/99_drop_schema.sql`, then both scripts again.
- Any seed row fails: run `99_drop_schema.sql`, `00_schema.sql`, then `01_seed_data.sql` again. Do not fix rows by hand. The generator is the source of truth.

**Source**: script headers; env ("DEFAULT ON NULL" lesson).

### Step 2. Tour the model (12 min, 0:18 to 0:30)

**Clicks**
1. SQL Workshop > Object Browser > ESTIMATES. Show the columns.
2. Optional: SQL Workshop > Utilities > Quick SQL. Paste `docs/quick-sql.txt` below its dashed line. Click Generate SQL.

**Say**
- Walk the mind map slide: customer, policy, vehicle, claim, estimate.
- On ESTIMATES: "`image` is a BLOB. `extracted_json` is the native JSON type. That is where the AI's answer goes. `check_results` is where SQL writes its verdict."
- "`created_on` is DEFAULT ON NULL. An APEX form sends an explicit NULL for an empty item, and a plain DEFAULT does not fire for an explicit NULL. We learned that in rehearsal."

**Expect**: Object Browser lists the eight tables.

**Fallback**: none needed. Use the EER slide.

**Source**: `sql/00_schema.sql`; `docs/quick-sql.txt` header; env.

---

## Core app (0:30 to 1:15)

### Step 3. Create the app with the wizard (20 min, 0:30 to 0:50)

**Clicks**
1. App Builder > Create. A quick Name box appears first. Click **Use Create App Wizard** (env).
2. Name: `Lanka Shield Claims`.
3. Click Add Page > **Interactive Report**. Table `CUSTOMERS`. Turn on **Include Form**. Add Page.
4. Add Page > Interactive Report > `POLICIES`. Include Form off.
5. Add Page > Interactive Report > `VEHICLES`. Include Form off.
6. Add Page > Interactive Report > `CLAIMS`. Include Form off.
7. Add Page > Interactive Report > `ESTIMATES`. Include Form off. Why: we will look at what the AI read on this report. The upload page comes later.
8. Add Page > **Master Detail** > **Drill Down**. Name `Customer 360`. Master table `CUSTOMERS`, detail table `POLICIES`.
9. Click Create Application.

**Say**
- "One wizard, six pages, no code. Each page is a SQL query on our tables."
- "Interactive Report: the user can filter, sort and download without us writing anything."

**Expect**: the application home lists the new pages. Run the app and sign in on its login page (it opens in a new tab).

**Fallback**: import **stage-1** (`docs/checkpoints.md`).

**Source**
- Quick Name box and "Use Create App Wizard"; Interactive Report with Include Form gives a report and a modal form: env (tested 22 Nov on ESTIMATES).
- Page types in the Create Application wizard (Interactive Report, Master Detail with Stacked, Side by Side, Drill Down): docs, "Understanding Page Types, Features, and Settings".
- UNVERIFIED: the exact Master Detail dialog fields (master table, detail table) in the 26.2 Create App wizard. Not built yet. Rehearse first.

### Step 4. Make Customer 360 show vehicles and claims (20 min, 0:50 to 1:10)

Customer 360 must show a customer with their policies, vehicles and claims. The Drill Down page shows the customer and the policies. Add two report regions for vehicles and claims.

**Clicks**
1. App Builder > the app > open the **detail** page of Customer 360 (the page with the customer form and the policies grid). Note the name of the customer key item, for example `P<n>_CUSTOMER_ID`.
2. Rendering tree: right-click **Body** > Create Region. Title `Vehicles`. Type **Classic Report**. Source > Type SQL Query:

   ```sql
   select v.reg_no, v.make, v.model, p.policy_no, p.status
     from vehicles v
     join policies p on p.policy_id = v.policy_id
    where p.customer_id = :P<n>_CUSTOMER_ID
   ```

3. Right-click Body > Create Region. Title `Claims`. Type Classic Report. SQL Query:

   ```sql
   select c.claim_no, c.claim_type, c.status, c.amount_lkr, c.incident_date
     from claims c
     join policies p on p.policy_id = c.policy_id
    where p.customer_id = :P<n>_CUSTOMER_ID
    order by c.claim_no
   ```

4. For both regions: Source > **Page Items to Submit** = `P<n>_CUSTOMER_ID`. Save. Run.
5. Open customer **Kasun Ranasinghe** (NIC 198812304567).

**Say**
- "Customer 360 is three queries on one screen. You already write these queries every day."
- "Bind variables, never string concatenation. `:P<n>_CUSTOMER_ID` is a bind variable."

**Expect**: policy LSM-20007, vehicle WP CAB-4521, and no claim yet. The claim appears after Case 1 (CLM-26-0011). Come back to this page at the end of step 14.

**Fallback**: import **stage-2**.

**Source**
- No 26.2 page type shows a parent with several related child regions. Master Detail Drill Down is the closest: docs, "Understanding Page Types in the Create Page Wizard".
- Region > Create Region in the Rendering tree context menu: env (used 22 Nov on the upload test page).
- UNVERIFIED: the item name the wizard gives the customer key, and whether Page Items to Submit is needed for a Classic Report on page load. Column names of VEHICLES and POLICIES: check `sql/00_schema.sql` before rehearsal.

Spare 5 minutes (1:10 to 1:15): questions, or show the Interactive Report search on CLAIMS.

**Break (1:15 to 1:30).** During the break, check that SQL Commands is open in a second builder tab.

---

## Case 1a: upload and AI extract (1:30 to 2:05)

### Step 5. Compile the extraction procedure (4 min, 1:30 to 1:34)

**Clicks**: SQL Workshop > SQL Commands. Paste `sql/week2/02_extract_estimate.sql`. Run.

**Say**
- "The AI reads. SQL decides. This procedure is the 'reads' part."
- Point at three lines in the code:
  - `apex_ai.generate` with `p_attachments`: the image goes with the prompt.
  - The prompt asks for JSON only. "We asked APEX to enforce a JSON schema. On our Claude service that failed every time, so we ask in the prompt and check with `IS JSON`."
  - "Copy the total exactly as written. Do not add up the lines yourself." "Remember this line. It matters in an hour."

**Expect**: "Procedure created."

**Fallback**: errors mean the tables are missing or the paste was cut. Paste again. If the tables are missing, run step 1.

**Source**: `02_extract_estimate.sql` header; env S1 (attachment PASS) and S2 (schema mode FAIL).

### Step 6. Build the upload page (15 min, 1:34 to 1:49)

The generated form failed to fill MIME_TYPE and FILE_NAME on insert (ORA-01400). We use the documented temporary-file pattern instead. It was tested on 22 November (env).

**Clicks**
1. App Builder > the app > **Create Page** > Component tab > **Blank Page** > Next.
2. Page Number `10`. Name `Upload Estimate`. Leave Use Navigation on. Create Page.
   - Why page 10: the item names below (`P10_...`) then match this guide.
3. Rendering tree: right-click **Body** > **Create Region**. Name `Upload`.
4. Right-click the region > **Create Page Item**:
   - Name `P10_FILE`. Type **File Upload**. Label `Estimate image`.
   - Storage > Type: **Table APEX_APPLICATION_TEMP_FILES** (the default for this item).
   - Storage > Purge File at: **End of Request**.
   - File Types: `image/*`.
   - Validation > **Value Required: On**. Why: with no file, the next steps would run on an empty ID.
5. Right-click the region > Create Page Item. Name `P10_ESTIMATE_ID`. Type **Hidden**.
6. Right-click the region > **Create Button**. Button Name `UPLOAD`. Label `Upload and read`.
7. Click Save.

**Say**
- "A File Upload item puts the file in a temporary table, `APEX_APPLICATION_TEMP_FILES`. The item's value is the key of that row. Our process copies the row into our own table."
- "End of Request: APEX deletes the temporary file when this page submit ends. We have already copied it by then."

**Expect**: Page Designer shows region Upload with P10_FILE, P10_ESTIMATE_ID and the UPLOAD button.

**Fallback**: import **stage-3**.

**Source**
- Storage Type options "Table APEX_APPLICATION_TEMP_FILES" and "BLOB column specified in Item Source attribute"; query by `name = :item`: docs, "About Item Types", File Upload section.
- Purge File at "End of Session" / "End of Request": seen in the 26.2 Property Editor (env). The docs list these labels under Image Upload on the same page.
- Default storage for a new File Upload item, page creation clicks: env (tested 22 Nov).
- UNVERIFIED: the "Value Required" switch on a File Upload item. Not tested.

### Step 7. Add the save and read processes (8 min, 1:49 to 1:57)

**Clicks**
1. Page Designer > **Processing** tab (third icon at the top of the left pane). Right-click **Processing** > **Create Process**.
2. Name `Save estimate`. Type **Execute Code**. PL/SQL Code (open the Code Editor, paste, click Validate, then OK):

   ```sql
   declare
       l_id estimates.estimate_id%type;
   begin
       -- WHY copy from the temporary table: it holds the file name and
       -- MIME type that the generated form failed to fill (ORA-01400).
       for f in ( select filename, mime_type, blob_content
                    from apex_application_temp_files
                   where name = :P10_FILE ) loop
           insert into estimates ( file_name, mime_type, image )
           values ( f.filename, f.mime_type, f.blob_content )
           returning estimate_id into l_id;
       end loop;
       :P10_ESTIMATE_ID := l_id;
   end;
   ```

   Server-side Condition > **When Button Pressed**: `UPLOAD`. Success Message: `Estimate &P10_ESTIMATE_ID. saved.`
3. Right-click Processing > Create Process. Name `Read, check and claim`. Type Execute Code. For now, the code only reads:

   ```sql
   begin
       extract_estimate( :P10_ESTIMATE_ID );
   end;
   ```

   When Button Pressed: `UPLOAD`. Check that it runs **after** Save estimate (Sequence 20 or higher).
4. Rendering tab: right-click Body > Create Region. Name `Latest estimate`. Type Classic Report. SQL Query:

   ```sql
   select estimate_id, file_name, garage_name, model_score, review_status,
          json_serialize( check_results ) as checks,
          ( select claim_no from claims c where c.claim_id = e.claim_id ) as claim_no
     from estimates e
    where e.estimate_id = :P10_ESTIMATE_ID
   ```

5. Save.

**Say**
- "Two processes, run in order on one button. First save the file. Then call the same procedure we compiled in SQL Commands. The page is a thin screen over database code."
- "Why a procedure and not code in the page? Because we can run and test it from SQL, without the screen."

**Expect**: three components under Processing > Processes, both with When Button Pressed UPLOAD.

**Fallback**: import **stage-4**.

**Source**
- Save block: tested 22 Nov as `P6_` items; it printed "Estimate 8 saved." (env).
- Process in Processing > Create Process, Execute Code, When Button Pressed, Success Message, Code Editor Validate: env (tested 22 Nov).
- UNVERIFIED: the `Latest estimate` region. It is a plain Classic Report on a session-state item. Not tested.

### Step 8. Upload E01 and look at the JSON (8 min, 1:57 to 2:05)

**Clicks**
1. Click Run (top right of Page Designer). In the app tab, open **Upload Estimate** from the menu.
   - If the app tab is already open, Run shows a "Focus Page" dialog. Close it and switch tabs by hand (env).
2. Choose `data/estimates/E01.jpg`. Click **Upload and read**.
3. Builder tab > SQL Commands:

   ```sql
   select estimate_id, model_score, json_serialize( extracted_json pretty ) as json
     from estimates
    order by created_on desc
    fetch first 1 row only;
   ```

**Say**
- "Garage, reg number, six line items, total. Read from a picture, in about two or three seconds."
- "The model also gives itself a score: 0.97. Hold that thought. We will not trust it on its own."
- "Order by `created_on`, not by ID. On this cloud service, identity values are not in insert order."

**Expect**
- Success message "Estimate N saved." The Latest estimate region shows garage **Dulanjana Auto Works**, model_score about 0.97, review_status empty (no checks yet).
- JSON: reg_no WP CAB-4521, 6 line items, total_lkr 139200. Compare with `data/estimates/truth/E01.json`. All 8 fields and 6 of 6 lines matched in rehearsal (results).
- Time per image 2.2 to 3.1 s including checks (results).

**Fallback**
- The upload fails: reset the Case 1 data (`docs/checkpoints.md`, "Data reset"), import stage-4, upload again.
- The AI call fails or hangs (service down): fill the row by hand from the truth file, then carry on. In SQL Commands:

  ```sql
  update estimates
     set extracted_json = json( '<paste data/estimates/truth/E01.json here>' ),
         model_score    = 0.97,
         garage_name    = 'Dulanjana Auto Works'
   where estimate_id = <id>;
  commit;
  ```

  Say so honestly: "The service is down. Here is what it returned in rehearsal."
- **Never upload E01 a second time without the data reset.** `create_claim` is idempotent per estimate row, not per file. A second E01 row would take CLM-26-0012 later and shift every number.

**Source**: results (E01 row, timings); env (identity order, Focus Page dialog).

**Break (2:05 to 2:15).** Leave the E01 row as it is. Step 10 uses it.

---

## Case 1b: checks, approval, save as claim (2:15 to 3:05)

### Step 9. Compile the checks and the claim gate (4 min, 2:15 to 2:19)

**Clicks**: SQL Commands. Paste `sql/week2/03_check_estimate.sql`. Run. Paste `sql/week2/04_create_claim.sql`. Run.

**Say**
- "Trust the checks, not the model's opinion of itself."
- Show the four checks in the header of `03`: required fields; line items add up (`JSON_TABLE` + `SUM`); vehicle on an ACTIVE motor policy (reg compared without spaces or hyphens); model score at least 0.80. "Any one failure sends it to a person."
- `04`: "Only AUTO_OK or APPROVED estimates become claims. Anything else raises an error. No page can skip the review."

**Expect**: "Procedure created." then "Function created."

**Fallback**: paste again. If objects are invalid, run step 5 first.

**Source**: headers of `03_check_estimate.sql` and `04_create_claim.sql`.

### Step 10. Check E01 from SQL and make CLM-26-0011 (5 min, 2:19 to 2:24)

**Clicks**: SQL Commands, using the E01 row from step 8:

```sql
declare
    l_id estimates.estimate_id%type;
begin
    select estimate_id into l_id
      from estimates where file_name = 'E01.jpg' and claim_id is null;
    check_estimate( l_id );
    dbms_output.put_line( create_claim( l_id ) );
    commit;
end;
```

Then:

```sql
select file_name, review_status, json_serialize( check_results pretty ) as checks
  from estimates where file_name = 'E01.jpg';
```

**Say**: "Same code, no screen. The page will call exactly this."

**Expect**: DBMS Output `CLM-26-0011`. review_status AUTO_OK; all four checks true.

**Fallback**
- "exact fetch returns more than requested number of rows": E01 was uploaded twice. Run the data reset and upload E01 again on the page, then repeat this step.
- Any other error: import stage-5 and use the data reset, then upload E01 on the page (the stage-5 process creates the claim itself).

**Source**: results (E01 AUTO_OK, CLM-26-0011); `04_create_claim.sql` header ("cannot be called from a SELECT").

### Step 11. Let the page check and claim (4 min, 2:24 to 2:28)

**Clicks**: Page Designer, page 10 > Processing > `Read, check and claim`. Replace the code:

```sql
declare
    l_status estimates.review_status%type;
    l_claim  claims.claim_no%type;
begin
    extract_estimate( :P10_ESTIMATE_ID );
    check_estimate( :P10_ESTIMATE_ID );
    select review_status into l_status
      from estimates where estimate_id = :P10_ESTIMATE_ID;
    -- WHY only AUTO_OK here: NEEDS_REVIEW goes to a person (next process).
    if l_status = 'AUTO_OK' then
        l_claim := create_claim( :P10_ESTIMATE_ID );
    end if;
end;
```

Save.

**Say**: "Read, check, and only then claim. In that order, every time."

**Expect**: the code validates in the Code Editor.

**Fallback**: import **stage-5**.

**Source**: env (the same three calls ran in the page 3 process on 22 Nov; that version had When Button Pressed CREATE).

### Step 12. Create the Task Definition "Estimate Review" (12 min, 2:28 to 2:40)

Create it before the "Send to review" process. A Human Task - Create process needs a Task Definition to exist (docs).

**Clicks**
1. App Builder > the app > Shared Components > Workflows and Automations > **Task Definitions** > Create.
2. Name `Estimate Review`. Type **Approval Task**. APEX fills in a locked Static ID: `estimate-review` (env S4).
3. Subject: `Review estimate &FILE_NAME. from &GARAGE_NAME.`
4. Participants: add **Potential Owner** = your APEX user, and **Business Administrator** = your APEX user. The wizard can finish with no participants, so add both on purpose (env S4).
5. Create. On the edit page:
   - **Initiator Can Complete**: On. Why: on stage, you upload and you approve. In production, turn it off so nobody approves their own estimate.
   - Actions Source: **Table**, ESTIMATES, primary key ESTIMATE_ID.
   - Click **Create Task Details Page**. Accept the next free page number.
6. Actions > Add Action. Name `Approved`. On Event **Complete**. Outcome **Approved**. Type Execute Code:

   ```sql
   declare
       l_claim claims.claim_no%type;
   begin
       update estimates
          set review_status = 'APPROVED', reviewer = v('APP_USER')
        where estimate_id = :ESTIMATE_ID;
       -- WHY after the update: create_claim accepts only AUTO_OK or APPROVED.
       l_claim := create_claim( :ESTIMATE_ID );
   end;
   ```

   UNVERIFIED: this exact block. Rehearsal ran the same update and then `create_claim( :ESTIMATE_ID )` (env); the text of that action is not in the repo.
7. Add Action. Name `Rejected`. On Event Complete. Outcome **Rejected**. Code:

   ```sql
   update estimates
      set review_status = 'REJECTED', reviewer = v('APP_USER')
    where estimate_id = :ESTIMATE_ID;
   ```

8. Apply Changes.

**Say**
- "A Task Definition is an approval built into APEX: who may approve, what they see, and what happens on Approve or Reject."
- "`:ESTIMATE_ID` is a column of the Actions Source table, used as a bind variable."

**Expect**: Task Definitions lists Estimate Review with two actions and a Task Details page.

**Fallback**: import **stage-6**. It contains the Task Definition, Send to review and My Reviews. Skip to step 15.

**Source**
- Path Shared Components > Workflows and Automations > Task Definitions > Create; Approval Task; participant types; Initiator Can Complete (default Off); actions On Event: docs, "Creating a Task Definition" and "Adding and Editing Task Definition Actions".
- Subject with column substitutions, Actions Source table, Task Details page link, Outcome Approved and Rejected, `:ESTIMATE_ID` bind: env (tested 22 Nov). The docs do not list Approved and Rejected as Outcome values.

### Step 13. Add "Send to review" (5 min, 2:40 to 2:45)

**Clicks**
1. Page 10 > Processing > right-click Processing > Create Process.
2. Name `Send to review`. Type **Human Task - Create**.
3. Settings: Definition **Estimate Review**. **Details Primary Key Item** `P10_ESTIMATE_ID`.
4. Server-side Condition: When Button Pressed `UPLOAD`. Type **Rows returned**. SQL Query:

   ```sql
   select 1 from estimates
    where estimate_id = :P10_ESTIMATE_ID
      and review_status = 'NEEDS_REVIEW'
   ```

5. Check the order: Save estimate, then Read check and claim, then Send to review. Save.

**Say**: "If any check failed, a person gets a task. If not, nothing happens and the claim already exists."

**Expect**: three processes in that order.

**Fallback**: import stage-6.

**Source**: process type and settings (Definition, Subject, Details Primary Key Item): docs, "Creating Tasks from Task Definitions". Condition and order: env (page 3, 22 Nov).

UNVERIFIED: steps 11 to 13 on the new page 10 together. The same processes passed on the generated form page (env). Rehearse the full chain on page 10.

### Step 14. Inbox, then demo E02 and E03 (12 min, 2:45 to 2:57)

**Clicks**
1. App Builder > the app > Create Page > Component tab > **Unified Task List**. Name `My Reviews`. Page Number `20`. Report Context **My Tasks**. Create.
2. Run. In the app, open Upload Estimate.
3. Upload `E02.jpg`. Latest estimate shows AUTO_OK and **CLM-26-0012**.
4. Upload `E03.jpg`. Latest estimate shows NEEDS_REVIEW, no claim.
5. SQL Commands: show why.

   ```sql
   select file_name, model_score, json_serialize( check_results pretty ) as checks
     from estimates where file_name = 'E03.jpg';
   ```

6. App: open **My Reviews**. Click the task "Review estimate E03.jpg from HILL CAPITAL AUTO CARE". Click **Approve**.
7. Back on Upload Estimate (or the Estimates report): E03 is APPROVED, claim **CLM-26-0013**, amount LKR 145,000, reviewer recorded.
8. Open Customer 360 for Kasun Ranasinghe: CLM-26-0011 now shows under Claims.

**Say**
- E03 is the story: "The model was 0.93 sure. The handwritten total says 145,000. The lines add up to 118,500. The model copied the paper correctly, because we told it to. One SQL `SUM` sent it to a person."
- "The model's score was between 0.93 and 0.97 on every image, including two that must never become claims. Only SQL against our own tables can know that a policy has lapsed."
- "The claim takes the written total, 145,000, because the reviewer approved the paper as it is. Correcting the amount is a claims-handling step, not an AI step."

**Expect**
- E02: AUTO_OK, CLM-26-0012. E03: NEEDS_REVIEW, then APPROVED, CLM-26-0013, LKR 145,000 (env, results).
- Upload to claim or task: about 4.6 s (env).

**Fallback**
- Wrong claim number: stop. Run the data reset and redo E01 (step 8 upload, then step 10), E02, E03. If time is short, say the numbers out loud and fix the data in the break before Week 3.
- No task appears: check that Send to review has When Button Pressed UPLOAD and the Rows returned query. Do not try to create the task from SQL: task APIs fail in SQL Workshop (env S4). Import stage-6 and upload E03 again **after** removing the E03 row only:

  ```sql
  delete from estimates where file_name = 'E03.jpg' and claim_id is null;
  commit;
  ```

**Source**: Unified Task List path and Report Context options: docs, "Managing Unified Task Lists". Results: env and results.

### Step 15. Wrap up Case 1 (8 min, 2:57 to 3:05)

**Clicks**: Estimates report page. Show all three rows with status, score and claim.

**Say**: the three anchors.
1. "The AI reads. SQL decides."
2. "Trust the checks, not the model's opinion of itself."
3. "Only checked data becomes a claim."

Then point at the production slide: image checks before the AI, separation of duties (Initiator Can Complete off), a sequence for claim numbers, and data terms with the AI provider (the image leaves the database).

**Fallback**: use the results table from `docs/week2-extraction-results.md` on a slide.

---

## Step 16. Break-the-AI challenge (in Q&A, 3:05 to 3:30, about 10 min)

The room changes the data spec. We render a new estimate image, upload it and watch the checks react. Run it only after E01, E02 and E03 are done. Any claim it makes is CLM-26-0014 or later, which Week 3 does not use.

**Rule**: add a new estimate **E13**. Never edit E01 to E12: the renderer overwrites their committed images and truth files.

**Clicks (presenter laptop, PowerShell)**
1. Open `data/spec.py`. Copy the E02 dict in `ESTIMATES` and paste it at the end of the list. Change `id="E02"` to `id="E13"`. Remove `claim="CLM-26-0012"`.
2. Let the room choose **one** change that a check can see:

   | Change in the E13 dict | Check that reacts | Expected status |
   |---|---|---|
   | `reg="WP CAD-1187"` | active_motor_policy (policy LAPSED, like E08) | NEEDS_REVIEW |
   | `reg="WP KM-5521"` | active_motor_policy (not insured with us, like E09) | NEEDS_REVIEW |
   | `kind="handwritten_total", written_total=150000` | items_add_up | NEEDS_REVIEW |
   | a line price, for example `("Labour", 1, 99000)` | none: a clean estimate prints the sum of its lines | AUTO_OK, new claim |

   The last row is a good trap: "Changing a price is not fraud the checks can see. The paper still adds up."
3. Render only E13. Run from the PowerShell tool or a PowerShell window (the Bash sandbox blocks Edge):

   ```powershell
   python data/estimates/render_estimates.py --edge "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --hand-font "<path to Caveat .ttf>" E13
   ```

4. App: Upload Estimate > `data/estimates/E13.jpg` > Upload and read. Show Latest estimate and the checks.
5. After the session: `git checkout data/spec.py` and delete `data/estimates/E13.jpg` and `data/estimates/truth/E13.json`. Do not commit them.

**Say**: "The model will read whatever is on the paper. The checks decide what we do with it."

**Expect**: the status in the table above. The model should read E13 as well as E02 (results: 11 of 11 estimates exact).

**Fallback**: if rendering fails, upload E08 (lapsed) or E09 (not insured) from `data/estimates/`. They show the same reactions (results).

**Source**: `data/spec.py` (E02, E08, E09 dicts; vehicles); `render_estimates.py` usage line; results (E08, E09 statuses).

---

## Still needs a live rehearsal

1. **Customer 360** (steps 3 and 4): the Master Detail Drill Down dialog, the customer key item name, and the two extra report regions. Never built.
2. **Page 10 end to end** (steps 6, 7, 11, 13): the save block passed alone; the chain save > read, check and claim > send to review has not run on this page. Also the Value Required switch and the Latest estimate region.
3. **Task action code** (step 12): the update plus `create_claim` call in one action.
4. **Break-the-AI render** on the presenter laptop, with the real Caveat font path. Time it.
5. **Checkpoint round trip**: export one stage, import it with a new application ID, run it (`docs/checkpoints.md`).
6. **Pre-flight**: delete the rehearsal apps, then confirm My Reviews is empty in the new app.
7. **Timing**: run the whole script once against a clock. Steps 12 to 14 are the tightest.
