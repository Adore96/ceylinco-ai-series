# Week 2: extraction results on the 12 test estimates

Tested 22 Nov 2026 on the free workspace (APEX 26.2.1, service `claude`).
Images and truth JSON: `data/estimates/` (made by `render_estimates.py` from `data/spec.py`).
Code: `sql/week2/02_extract_estimate.sql` (AI reads) and `sql/week2/03_check_estimate.sql` (SQL decides).

> **The AI reads. SQL decides.** The model was 93% sure about E03. One SQL sum sent it to a person.

## Results

"Fields" = document type, garage, town, estimate number, date, reg number, vehicle, total (8).
"Lines" = line items where description, qty, unit price and amount all match.

| Image | Kind | Score | Fields | Lines | Status (got) | Status (expected) | Why |
|---|---|---|---|---|---|---|---|
| E01 | clean | 0.97 | 8 of 8 | 6 of 6 | AUTO_OK | AUTO_OK | all checks pass; becomes CLM-26-0011 |
| E02 | clean | 0.97 | 8 of 8 | 6 of 6 | AUTO_OK | AUTO_OK | becomes CLM-26-0012 |
| E03 | handwritten total | 0.93 | 8 of 8 | 6 of 6 | NEEDS_REVIEW | NEEDS_REVIEW | written total 145,000; lines add up to 118,500 |
| E04 | clean | 0.97 | 8 of 8 | 4 of 4 | AUTO_OK | AUTO_OK | |
| E05 | clean | 0.97 | 8 of 8 | 5 of 5 | AUTO_OK | AUTO_OK | |
| E06 | clean | 0.97 | 8 of 8 | 5 of 5 | AUTO_OK | AUTO_OK | |
| E07 | clean | 0.97 | 8 of 8 | 4 of 4 | AUTO_OK | AUTO_OK | |
| E08 | clean | 0.97 | 8 of 8 | 4 of 4 | NEEDS_REVIEW | NEEDS_REVIEW | vehicle is on a LAPSED policy |
| E09 | clean | 0.97 | 8 of 8 | 4 of 4 | NEEDS_REVIEW | NEEDS_REVIEW | vehicle not insured with us |
| E10 | phone photo (skewed) | 0.95 | 8 of 8 | 3 of 3 | AUTO_OK | AUTO_OK | |
| E11 | rubber stamp over text | 0.93 | 8 of 8 | 4 of 4 | AUTO_OK | AUTO_OK | |
| E12 | fuel bill | 0.97 | 4 of 8 | 0 of 1 | NEEDS_REVIEW | NEEDS_REVIEW | document_type OTHER |

- **Review status: 12 of 12 as expected.**
- **Garage estimates: 11 of 11 with every field and every line item exact.**
- E12: the model said OTHER and left garage, town, number and date empty, which is the right behaviour for a document we do not process. The truth file holds the printed values, so "4 of 8" is expected, not an error.
- Time: 2.2 to 3.1 s per image (extract + check). Images are 39 to 77 KB JPEG.

## Talking points for the deck

1. **E03 is the story.** The model read the wrong handwritten total correctly and was 0.93 confident. It did not "fix" the total, because the prompt says to copy it as written. The `items_add_up` check (JSON_TABLE + SUM) caught the mismatch.
2. **The model's score is not a check.** Every score was between 0.93 and 0.97, including the two estimates that must not become claims (E08 lapsed policy, E09 not insured). Only SQL against our own tables can know that.
3. **Messy is fine.** The skewed photo and the stamped page read perfectly. Production still adds image checks, but the stage demo does not need a clean-up step.

## Re-running

```sql
-- SQL Commands: re-extract and re-check every estimate
begin
    for e in ( select estimate_id from estimates order by file_name ) loop
        extract_estimate( e.estimate_id );
        check_estimate( e.estimate_id );
    end loop;
    commit;
end;
```
