# Call transcripts (synthetic)

30 calls for Lanka Shield Assurance (fictional). `transcripts.json` has every call with expected labels; `txt/` has one file per call for pasting into demos.

| Scenario | Calls |
|---|---|
| Policy questions | 001 to 008 |
| Claim questions (011 to 013 refer to Week 2 estimate claims) | 009 to 016 |
| Product and branch questions | 017 to 022 |
| Accident or complaint, routed to specialist | 023 to 025 |
| Accident or complaint missed by human triage (AI flag should catch) | 026, 027 |
| Ambiguous or out of scope | 028 to 030 |

Expected labels: `triage_route` (BOT/SPECIALIST, the human's choice), `intent` (POLICY/CLAIM/PRODUCT_BRANCH/OTHER), `complaint_flag` (Y/N), `reference` (policy, claim, NIC or vehicle number mentioned).

Week 1 classify demo suggestion: CALL-001 (policy), CALL-009 (claim), CALL-017 (branch).
