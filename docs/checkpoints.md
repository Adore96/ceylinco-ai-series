# Week 2 checkpoints: recover a failed live step

> **If a step breaks on stage, import the stage before it and keep going.**

During rehearsal, export the app after each block of `docs/week2-build-guide.md`. On the day, a failed step costs one import, not ten minutes of debugging in front of the room.

## What an import does and does not restore

| Restores | Does not restore |
|---|---|
| Pages, items, processes, regions | Table rows (estimates, claims) |
| The Task Definition `Estimate Review` (it belongs to the app) | Procedures `extract_estimate`, `check_estimate`, function `create_claim` |
| | The AI service `claude` (a workspace setting; it stays as it is) |
| | Tasks already created in the workspace |

So recovery is always **SQL scripts for the database + an import for the app**.

## The stages

Folder: `apex/week2/`. File names: `stage-N.sql`.

| Stage | Export after | Contains | Use it when this step fails | Database needs |
|---|---|---|---|---|
| (none) | step 1 | no app | step 1 | `sql/00_schema.sql`, `sql/week2/01_seed_data.sql` |
| stage-1 | step 3 | wizard pages: Customers (report + form), Policies, Vehicles, Claims, Estimates, Customer 360 drill down | step 3 | step 1 |
| stage-2 | step 4 | + Vehicles and Claims regions on Customer 360 | step 4 | step 1 |
| stage-3 | step 6 | + page 10 Upload Estimate (P10_FILE, P10_ESTIMATE_ID, UPLOAD) | step 6 | step 1 |
| stage-4 | step 7 | + Save estimate, Read check and claim (extract only), Latest estimate region | step 7 or 8 | step 1, `02_extract_estimate.sql` |
| stage-5 | step 11 | + Read check and claim with check and claim | step 10 or 11 | + `03_check_estimate.sql`, `04_create_claim.sql` |
| stage-6 | step 14 | + Task Definition Estimate Review (with Task Details page), Send to review, page 20 My Reviews | step 12, 13 or 14 | same as stage-5 |

stage-6 is the finished Week 2 app. Week 3 can start from it.

## Export a stage (rehearsal)

**Clicks**: App Builder > the app > **Export / Import** > Export.

- Export type: **Standard**.
- Format: **SQL**. Why not APEXlang: importing an APEXlang file needs ORDS 26.3.0 or later and a REST-enabled schema (docs). UNVERIFIED: the ORDS version on oracleapex.com.
- Save the file as `apex/week2/stage-N.sql`.

**Source**: docs, "Exporting an Application" (formats SQL and APEXlang; types Standard, Runtime, Full, Custom; Tip: application > Export / Import > Export). Page Designer > Utilities also lists Export (env).

## Import a stage (on stage)

**Clicks**
1. App Builder > **Import**. Choose `apex/week2/stage-N.sql`. Next.
2. Parsing Schema: the workspace schema. Build Status: Run and Build Application.
3. Import As Application: **Auto Assign New Application ID**. Install.
4. Run the new app and sign in on its login page.
5. Optional, after the session: delete the broken app so only one "Lanka Shield Claims" is left.

**Say**: "This is how you move an APEX app between environments: export, version control, import. Your DBAs already do this with schema scripts."

**Source**: docs, "Importing Export Files" (App Builder > Import; Parsing Schema; Build Status; Import As Application with Auto Assign New Application ID, Reuse Application ID, Change Application ID).

UNVERIFIED: the full round trip on the free workspace. Export one stage, import it with a new ID, and run it once in rehearsal.

## Data reset (before any re-upload)

The claim numbers must come out as CLM-26-0011, 0012, 0013 (`data/reference-ids.md`). `create_claim` returns the old claim only for the **same estimate row**. A second upload of the same file is a new row and takes the next number. So reset the Case 1 data before you upload again.

**SQL Commands**:

```sql
-- WHY this order: ESTIMATES.claim_id and CLAIMS.estimate_id point at each
-- other. Break the link, remove the live claims, then the estimates.
-- The 10 seeded claims (CLM-26-0001 to 0010) stay.
update estimates set claim_id = null;
delete from claims where claim_no > 'CLM-26-0010';
delete from estimates;
commit;
```

Then upload again from E01, in order: E01 (and step 10), E02, E03.

Tasks created for deleted estimates stay in My Reviews. Approve-or-reject them only if they block the demo. Their approve action would fail on a missing row.

UNVERIFIED: what a Task Details page shows when the estimate row is gone.

## Full reset (worst case)

1. `sql/99_drop_schema.sql` (SQL Scripts).
2. `sql/00_schema.sql`, then `sql/week2/01_seed_data.sql` (SQL Scripts).
3. `02_extract_estimate.sql`, `03_check_estimate.sql`, `04_create_claim.sql` (SQL Commands). Why: dropping the tables invalidates the procedures, so compile them again.
4. Import the stage you need.

## Never commit the exports

An APEX SQL export holds the application ID and workspace details. CLAUDE.md forbids committing those. `.gitignore` excludes `apex/**/*.sql` and `apex/**/*.zip`. Keep the files on the presenter laptop and on a USB stick.

UNVERIFIED: which IDs a 26.2 export embeds. The 26.2 docs do not list them. Check one file with a text search for the application number and the workspace name before you copy it anywhere shared.

## Rehearsal checklist

- [ ] Export stage-1 to stage-6 while following the guide.
- [ ] Round trip: import one stage with Auto Assign New Application ID, run it, upload E01.
- [ ] Run the data reset once and confirm E01 becomes CLM-26-0011 again.
- [ ] Copy `apex/week2/` to a USB stick.
