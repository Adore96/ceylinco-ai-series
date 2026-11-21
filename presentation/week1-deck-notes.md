# Week 1 deck: companion notes

Deck: `presentation/week1/week1-deck.pptx` (PowerPoint, rebuilt on 21 Nov from the Claude Slides artifact, same look, fully editable).
Source artifact (older version, not updated): https://claude.ai/artifact/1G8wqUz8YUFn93rP7fPwoz
Session: Wednesday 25 November 2026, 210 minutes. 56 slides. Full speaker notes (what to say, timing checkpoint, transition, likely questions) are in each slide's notes.

Sources: docs/plan.html (running order), files/ceylinco-build-scripts.md Script 2 (v2) with the v3 changes in files/ceylinco-build-scripts-v3.md, docs/environment.md, docs/apex-faq.md, docs/week1-component-map.md, docs/spikes.md, sql/week1/, data/calls/. All data synthetic (Lanka Shield Assurance). The client's workflow images in images/ were not opened or used; both case flows are redrawn from week1-component-map.md.

## Block timings (sum 210)

| Block | Minutes | Ends at | Anchor |
|---|---|---|---|
| 1 · Bridge (includes 4 opening slides) | 15 | 0:15 | Right tool, right job. |
| 2 · APEX tour | 20 | 0:35 | APEX is SQL with a screen. |
| 3 · Oracle AI Database updates | 30 | 1:05 | A vector is a list of numbers. Close numbers mean close meaning. (Chunking: Cut the document before you search it.) |
| Break | 15 | 1:20 | |
| 4 · Components and their AI | 85 | 2:45 | Normal first, then AI. Never the other way round. |
| Break | 10 | 2:55 | |
| 5 · The two cases, mapped to APEX | 25 | 3:20 | Every box in the diagram is a feature you already have. (Case 1: Trust the checks, not the model's opinion of itself. Case 2: RAG is a search query before the answer.) |
| 6 · Q&A (+ closing slide) | 10 | 3:30 | |
| **Total** | **210** | | |

## Slide list (time per slide and clock checkpoint)

### Opening (inside Block 1, Bridge)

1. AI in Oracle APEX (`cover`): 1 min (block Bridge 15 min starts). Checkpoint 0:00 -> 0:01.
2. APEX is SQL with a screen. (`anchor`): 2 min. Checkpoint 0:01 -> 0:03.
3. Running order (`agenda`): 2 min. Checkpoint 0:03 -> 0:05.
4. Ground rules (`rules`): 1 min. Checkpoint 0:05 -> 0:06.

### Block 1 · Bridge

5. Bridge from 18 November (`d-bridge`): 0.5 min. Checkpoint 0:06 -> 0:06.5.
6. n8n and APEX side by side (`n8n-vs-apex`): 6 min (includes the 3 min from the dropped 18 Nov recap). Checkpoint 0:06.5 -> 0:12.5.
7. Ask: who is the user? (`when-which`): 2.5 min. Checkpoint 0:12.5 -> 0:15.

### Block 2 · APEX tour

8. APEX tour (`d-tour`): 0.5 min. Checkpoint 0:15. Block 2 runs to 0:35.
9. The app lives in the database (`architecture`): 5 min. Checkpoint 0:15.5 -> 0:20.5.
10. Inside a workspace (`workspace-map`): 3 min. Checkpoint 0:20.5 -> 0:23.5.
11. A report page is a query (`page-is-query`): 3 min. Checkpoint 0:23.5 -> 0:26.5.
12. What we have, what we don’t (`free-workspace`): 3 min. Checkpoint 0:26.5 -> 0:29.5.
13. Walk the workspace (`demo-tour`): 5.5 min. Checkpoint 0:29.5 -> 0:35.

### Block 3 · Oracle AI Database updates

14. Oracle AI Database updates (`d-oracle-ai`): 0.5 min. Checkpoint 0:35. Block 3 runs to 1:05.
15. Search by meaning, not by words (`vector-idea`): 3.5 min. Checkpoint 0:35.5 -> 0:39.
16. We search for “accident repair”. What ranks first? (`predict-vector`): 2 min. Checkpoint 0:39 -> 0:41.
17. Meaning search is an ORDER BY (`sql-vector`): 2.5 min. Checkpoint 0:41 -> 0:43.5.
18. Run demo 1 (`demo-vector`): 2 min. Checkpoint 0:43.5 -> 0:45.5.
19. No shared words, still first (`result-vector`): 2 min. Checkpoint 0:45.5 -> 0:47.5.
20. Cut the document before you search it (`chunk-idea`): 2.5 min. Checkpoint 0:47.5 -> 0:50.
21. One call returns the chunks as rows (`sql-chunk`): 2.5 min. Checkpoint 0:50 -> 0:52.5.
22. 110 words, at most 40 per chunk. How many chunks? (`demo-chunk`): 4.5 min. Checkpoint 0:52.5 -> 0:57.
23. Select AI: a question becomes SQL (`select-ai`): 4.5 min. Checkpoint 0:57 -> 1:01.5.
24. APEX_AI and Select AI (`apexai-vs-selectai`): 3.5 min. Checkpoint 1:01.5 -> 1:05.

### Break

25. Back at T + 15 (`break1`): 15 min break. Checkpoint 1:05 -> 1:20.

### Block 4 · Components and their AI

26. Components and their AI (`d-components`): 1 min. Checkpoint 1:20 -> 1:21. Block 4 runs to 2:45.
27. Tables in, working app out (`c1-normal`): 4 min. Checkpoint 1:21 -> 1:25.
28. Describe the app in plain words (`c1-ai`): 10 min (includes the live demo). Checkpoint 1:25 -> 1:35.
29. A page is a stack of regions (`c2-normal`): 5 min. Checkpoint 1:35 -> 1:40.
30. AI chat on a page, and reports that understand words (`c2-ai`): 5 min. Checkpoint 1:40 -> 1:45.
31. Business logic runs on submit (`c3-normal`): 4 min. Checkpoint 1:45 -> 1:49.
32. One AI call from SQL (`c3-ai`): 4.5 min. Checkpoint 1:49 -> 1:53.5.
33. Meme: what can happen if you skip the check (`meme-json`): 0.5 min. Checkpoint 1:53.5 -> 1:54.
34. Three calls. Which label for each? (`c3-demo`): 8 min. Checkpoint 1:54 -> 2:02.
35. Meme: a true story about the 18-second query (`meme-optimizer`): 1 min. Checkpoint 2:02 -> 2:03.
36. Configure the connection once (`c4-normal`): 4 min. Checkpoint 2:03 -> 2:07.
37. Connect an AI model (`c4-ai`): 7 min (live). Checkpoint 2:07 -> 2:14.
38. Turning text into embeddings (`c5-normal`): 4 min. Checkpoint 2:14 -> 2:18.
39. The basis of AI search over documents (`c5-ai`): 5 min. Checkpoint 2:18 -> 2:23.
40. Reusable logic, and tools you approve (`c6-normal`): 4 min. Checkpoint 2:23 -> 2:27.
41. An assistant that calls approved tools (`c6-ai`): 5 min. Checkpoint 2:27 -> 2:32.
42. Approvals and human tasks (`c7-normal`): 4 min. Checkpoint 2:32 -> 2:36.
43. A person approves what the AI proposes (`c7-ai`): 5 min. Checkpoint 2:36 -> 2:41.
44. Seven components, normal first (`c-recap`): 4 min. Checkpoint 2:41 -> 2:45.

### Break

45. Back at T + 10 (`break2`): 10 min break. Checkpoint 2:45 -> 2:55.

### Block 5 · The two cases, mapped to APEX

46. The two cases, mapped to APEX (`d-cases`): 0.5 min. Checkpoint 2:55. Block 5 runs to 3:20.
47. One app, one data model, two cases (`one-app`): 1.5 min. Checkpoint 2:55.5 -> 2:57.
48. Eight tables, two cases (`data-model`): 1.5 min, EER diagram. Checkpoint 2:57 -> 2:58.5.
49. From an estimate photo to a claim (`case1-flow`): 5.5 min. Checkpoint 2:58.5 -> 3:04.
50. Trust the checks, not the model’s opinion of itself (`case1-trust`): 3 min. Checkpoint 3:04 -> 3:07.
51. From a call to a reply (`case2-flow`): 6 min. Checkpoint 3:07 -> 3:13.
52. Three kinds of question, three ways to answer (`case2-answers`): 3 min. Checkpoint 3:13 -> 3:16.
53. On stage vs in production (`stage-vs-prod`): 2 min. Checkpoint 3:16 -> 3:18.
54. The next two Wednesdays (`next-weeks`): 2 min. Checkpoint 3:18 -> 3:20.

### Block 6 · Q&A

55. Questions (`qa`): 9 min. Checkpoint 3:20 -> 3:29.
56. Thank you (`closing`): 1 min. Checkpoint 3:29 -> 3:30. END at 3:30 (210 min).

## Demo cues

| When | Slide | What to run | Expected result | Fallback |
|---|---|---|---|---|
| 0:29.5 | 13 Walk the workspace | Clicks only: Workspace home > SQL Workshop > SQL Commands > App Builder > a page in Page Designer > Shared Components (Generative AI entries, Task Definitions, Workflows) | Room predicts where a saved page goes: answer, into the database as metadata | Talk over the architecture slide |
| 0:39 | 16 Predict | Show of hands: which question ranks first for "accident repair"? | Most pick "Car hit at a junction" | |
| 0:43.5 | 18 Run demo 1 | SQL Workshop > SQL Commands, paste `sql/week1/01_vector_similarity.sql`, Run | 6 rows; top `.0038 Windscreen cracked on the highway`, then `.0082 Car hit at a junction` | Show slide 19 (expected result) |
| 0:52.5 | 22 Predict + demo 2 | Predict chunk count; paste `sql/week1/02_chunking.sql`, Run; change `"max": "40"` to `"20"`, Run again | 3 or 4 rows ending at full stops; then more, smaller chunks | Explain from slide 21 |
| 1:25 | 28 Create App Using Generative AI | App Builder > Create > Create App Using Generative AI; suggested prompt in slide notes | A proposed claims-desk app (output varies) | Plain Create App wizard |
| 1:40 | 30 Natural-language report | Spike app, page Policies; search bar: "Show only ACTIVE MOTOR policies and highlight rows where premium is more than 60000" | Filters Status = ACTIVE and Policy Type = MOTOR, highlight Premium > 60000; LSM-20007 (highlighted) and LSM-20015 | Describe from slide |
| 1:54 | 34 Classify three calls | SQL Commands: paste `sql/week1/03_classify_calls.sql`, Run | 3 rows, MATCH = Y: POLICY, CLAIM, PRODUCT_BRANCH; about 3.5 s in total | Read the expected labels |
| 2:07 | 37 Connect an AI model | Open Generative AI Service `claude`; show provider, model, credential; then the app's AI Attributes | Fields visible; key never shown | Describe from slide |
| 2:27 | 41 AI agent | Spike app, page Policies, Ask agent: "Which ACTIVE motor policies have a premium due before 31 January 2027?" | Only LSM-20015, Nuwan Bandara, 20 December 2026 | Route by intent in PL/SQL, explained |

Before the session: sign in to the spike app once (running it opens its own login page).

Not demoed (explained only): Select AI (no DBMS_CLOUD_AI on the free workspace). Spikes S1 to S7 are all recorded in `docs/environment.md` (S2 failed; the prompt-JSON fallback is in use).

## Open items

1. **Ceylinco logo slot** on the cover and closing slides is empty on purpose. Add only an approved logo.
2. **Rehearsal checks (24 Nov):** exact chunk row counts for max 40 and max 20; Create App Using Generative AI screens; 26.2 menu labels for the workspace tour and the Generative AI Service page.
3. **Oracle doc links on the closing slide** were not opened from this session. Click each; switch the APEX_AI.GENERATE link from 26.1 to 26.2 if a 26.2 page exists; add the AI Vector Search User's Guide URL.
4. **Fonts:** the .pptx uses Syne (headings) and DM Sans (body), installed on this PC from Google Fonts, and Consolas for code (JetBrains Mono joined `=>` into an arrow in PowerPoint). Install Syne and DM Sans on any other presenting laptop, or export to PDF on this PC beforehand.
5. **Engagement (22 Nov):** two meme slides around the classify demo (slides 33 and 35), our own text in the deck style, no copied images. A third meme (Case 1 checks) waits for Week 2 so it can show real tested numbers. Break-the-AI challenge planned for Weeks 2 and 3.
6. **EER diagram (22 Nov):** slide 48 shows the 8 tables from `presentation/diagrams/eer-all.png` (generator `make_eer.py`); Weeks 2 and 3 use `eer-week2.png` and `eer-week3.png`.
7. **Closed on 21 Nov:** the 18 Nov recap slide was dropped (its 3 min went to the n8n slide); `sql/week1/03_classify_calls.sql` exists and is tested; S1 is recorded as PASS; the deck is now a .pptx in `presentation/week1/`.

## UNVERIFIED points (in speaker notes, not on slides as facts)

- "MCP servers" in the architecture slide's external-services box (asked for by the v3 brief): not in environment.md or apex-faq.md, not used in this series.
- n8n descriptions (slides 6-7) are general, not checked against the 18 Nov material; n8n calling an ORDS endpoint was not tested.
- Select AI: exact profile setup (`DBMS_CLOUD_AI.SET_PROFILE`), the full action list in 26ai, and whether Select AI runs on non-Autonomous Oracle AI Database 26ai. Slide says "Available on Autonomous Database".
- Create App wizard "from a spreadsheet creates the table" (usual behaviour, not in spike notes).
- Create App Using Generative AI: exact screens and whether it proposes tables or only pages in 26.2.
- Whether a dedicated "AI chat region" exists in 26.2 besides the Show AI Assistant dynamic action (slide uses the spike wording).
- 26.2 click path to Generative AI Services (workspace level vs Shared Components > AI Services) and the model name shown there.
- Workflows card wording (Workflows present in Shared Components but not spike-tested).
- APEXlang export options in 26.2 on the free workspace (from apex-faq.md).
- Exact 26.2 menu labels for the workspace tour.
