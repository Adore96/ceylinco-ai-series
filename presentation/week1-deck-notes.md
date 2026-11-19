# Week 1 deck: companion notes

Deck: "AI in Oracle APEX · Week 1 · Noob Dev for Ceylinco" (Claude Slides artifact, private to Kasun)
Link: https://claude.ai/artifact/1G8wqUz8YUFn93rP7fPwoz
Session: Wednesday 25 November 2026, 210 minutes. 54 slides. Full speaker notes (what to say, timing checkpoint, transition, likely questions) are in each slide's notes.

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
6. What you saw: AI basics and n8n (`recap-18nov`): 3 min. Checkpoint 0:06.5 -> 0:09.5.
7. n8n and APEX side by side (`n8n-vs-apex`): 3 min. Checkpoint 0:09.5 -> 0:12.5.
8. Ask: who is the user? (`when-which`): 2.5 min. Checkpoint 0:12.5 -> 0:15.

### Block 2 · APEX tour

9. APEX tour (`d-tour`): 0.5 min. Checkpoint 0:15. Block 2 runs to 0:35.
10. The app lives in the database (`architecture`): 5 min. Checkpoint 0:15.5 -> 0:20.5.
11. Inside a workspace (`workspace-map`): 3 min. Checkpoint 0:20.5 -> 0:23.5.
12. A report page is a query (`page-is-query`): 3 min. Checkpoint 0:23.5 -> 0:26.5.
13. What we have, what we don’t (`free-workspace`): 3 min. Checkpoint 0:26.5 -> 0:29.5.
14. Walk the workspace (`demo-tour`): 5.5 min. Checkpoint 0:29.5 -> 0:35.

### Block 3 · Oracle AI Database updates

15. Oracle AI Database updates (`d-oracle-ai`): 0.5 min. Checkpoint 0:35. Block 3 runs to 1:05.
16. Search by meaning, not by words (`vector-idea`): 3.5 min. Checkpoint 0:35.5 -> 0:39.
17. We search for “accident repair”. What ranks first? (`predict-vector`): 2 min. Checkpoint 0:39 -> 0:41.
18. Meaning search is an ORDER BY (`sql-vector`): 2.5 min. Checkpoint 0:41 -> 0:43.5.
19. Run demo 1 (`demo-vector`): 2 min. Checkpoint 0:43.5 -> 0:45.5.
20. No shared words, still first (`result-vector`): 2 min. Checkpoint 0:45.5 -> 0:47.5.
21. Cut the document before you search it (`chunk-idea`): 2.5 min. Checkpoint 0:47.5 -> 0:50.
22. One call returns the chunks as rows (`sql-chunk`): 2.5 min. Checkpoint 0:50 -> 0:52.5.
23. 110 words, at most 40 per chunk. How many chunks? (`demo-chunk`): 4.5 min. Checkpoint 0:52.5 -> 0:57.
24. Select AI: a question becomes SQL (`select-ai`): 4.5 min. Checkpoint 0:57 -> 1:01.5.
25. APEX_AI and Select AI (`apexai-vs-selectai`): 3.5 min. Checkpoint 1:01.5 -> 1:05.

### Break

26. Back at 1:20 (`break1`): 15 min break. Checkpoint 1:05 -> 1:20.

### Block 4 · Components and their AI

27. Components and their AI (`d-components`): 1 min. Checkpoint 1:20 -> 1:21. Block 4 runs to 2:45.
28. Tables in, working app out (`c1-normal`): 4 min. Checkpoint 1:21 -> 1:25.
29. Describe the app in plain words (`c1-ai`): 10 min (includes the live demo). Checkpoint 1:25 -> 1:35.
30. A page is a stack of regions (`c2-normal`): 5 min. Checkpoint 1:35 -> 1:40.
31. AI chat on a page, and reports that understand words (`c2-ai`): 5 min. Checkpoint 1:40 -> 1:45.
32. Business logic runs on submit (`c3-normal`): 4 min. Checkpoint 1:45 -> 1:49.
33. One AI call from SQL (`c3-ai`): 5 min. Checkpoint 1:49 -> 1:54.
34. Three calls. Which label for each? (`c3-demo`): 9 min. Checkpoint 1:54 -> 2:03.
35. Configure the connection once (`c4-normal`): 4 min. Checkpoint 2:03 -> 2:07.
36. Connect an AI model (`c4-ai`): 7 min (live). Checkpoint 2:07 -> 2:14.
37. Turning text into embeddings (`c5-normal`): 4 min. Checkpoint 2:14 -> 2:18.
38. The basis of AI search over documents (`c5-ai`): 5 min. Checkpoint 2:18 -> 2:23.
39. Reusable logic, and tools you approve (`c6-normal`): 4 min. Checkpoint 2:23 -> 2:27.
40. An assistant that calls approved tools (`c6-ai`): 5 min. Checkpoint 2:27 -> 2:32.
41. Approvals and human tasks (`c7-normal`): 4 min. Checkpoint 2:32 -> 2:36.
42. A person approves what the AI proposes (`c7-ai`): 5 min. Checkpoint 2:36 -> 2:41.
43. Seven components, normal first (`c-recap`): 4 min. Checkpoint 2:41 -> 2:45.

### Break

44. Back at 2:55 (`break2`): 10 min break. Checkpoint 2:45 -> 2:55.

### Block 5 · The two cases, mapped to APEX

45. The two cases, mapped to APEX (`d-cases`): 0.5 min. Checkpoint 2:55. Block 5 runs to 3:20.
46. One app, one data model, two cases (`one-app`): 2.5 min. Checkpoint 2:55.5 -> 2:58.
47. From an estimate photo to a claim (`case1-flow`): 6 min. Checkpoint 2:58 -> 3:04.
48. Trust the checks, not the model’s opinion of itself (`case1-trust`): 3 min. Checkpoint 3:04 -> 3:07.
49. From a call to a reply (`case2-flow`): 6 min. Checkpoint 3:07 -> 3:13.
50. Three kinds of question, three ways to answer (`case2-answers`): 3 min. Checkpoint 3:13 -> 3:16.
51. On stage vs in production (`stage-vs-prod`): 2 min. Checkpoint 3:16 -> 3:18.
52. The next two Wednesdays (`next-weeks`): 2 min. Checkpoint 3:18 -> 3:20.

### Block 6 · Q&A

53. Questions (`qa`): 9 min. Checkpoint 3:20 -> 3:29.
54. Thank you (`closing`): 1 min. Checkpoint 3:29 -> 3:30. END at 3:30 (210 min).

## Demo cues

| When | Slide | What to run | Expected result | Fallback |
|---|---|---|---|---|
| 0:29.5 | 14 Walk the workspace | Clicks only: Workspace home > SQL Workshop > SQL Commands > App Builder > a page in Page Designer > Shared Components (Generative AI entries, Task Definitions, Workflows) | Room predicts where a saved page goes: answer, into the database as metadata | Talk over the architecture slide |
| 0:39 | 17 Predict | Show of hands: which question ranks first for "accident repair"? | Most pick "Car hit at a junction" | |
| 0:43.5 | 19 Run demo 1 | SQL Workshop > SQL Commands, paste `sql/week1/01_vector_similarity.sql`, Run | 6 rows; top `.0038 Windscreen cracked on the highway`, then `.0082 Car hit at a junction` | Show slide 20 (expected result) |
| 0:52.5 | 23 Predict + demo 2 | Predict chunk count; paste `sql/week1/02_chunking.sql`, Run; change `"max": "40"` to `"20"`, Run again | 3 or 4 rows ending at full stops; then more, smaller chunks | Explain from slide 22 |
| 1:25 | 29 Create App Using Generative AI | App Builder > Create > Create App Using Generative AI; suggested prompt in slide notes | A proposed claims-desk app (output varies) | Plain Create App wizard |
| 1:54 | 34 Classify three calls | SQL Commands: `select apex_ai.generate(p_prompt => ... || q'[<transcript>]', p_service_static_id => 'claude') from dual` with `data/calls/txt/CALL-001.txt`, `CALL-009.txt`, `CALL-017.txt` | POLICY, CLAIM, PRODUCT_BRANCH; about 1.3 s each | Read the expected labels |
| 2:07 | 36 Connect an AI model | Open Generative AI Service `claude`; show provider, model, credential; then the app's AI Attributes | Fields visible; key never shown | Describe from slide |

Not demoed (explained only): Select AI (no DBMS_CLOUD_AI on the free workspace), natural-language Interactive Report and AI Agent run (spike S7 pending), vector provider with Gemini (S6 pending).

## Open items

1. **18 Nov recap (slide 6):** placeholder "[Kasun: add 2-3 points from the 18 Nov session]" on three cards. Get the colleague's summary; also check slide 7's n8n rows agree with it.
2. **Ceylinco logo slot** on the cover and closing slides is empty on purpose. Add only an approved logo.
3. **No classify script yet:** `sql/week1/` has only 01 and 02. Script 1 (v3) asks for the classify demo on 3 transcripts. Until a `03_` file exists, slide 33's query (the verified environment.md pattern) is the demo. Rehearse it.
4. **S1 status mismatch:** the brief says S1 (image attachments) PASSED, but `docs/environment.md` records only S4 PASS. Slide 47 notes say "planned; fallback ready" until S1 is written into environment.md.
5. **Rehearsal checks (24 Nov):** exact chunk row counts for max 40 and max 20; Create App Using Generative AI screens; 26.2 menu labels for the workspace tour and the Generative AI Service page.
6. **Oracle doc links on the closing slide** were not opened from this session (no web access). Click each; switch the APEX_AI.GENERATE link from 26.1 to 26.2 if a 26.2 page exists; add the AI Vector Search User's Guide URL.
7. **Fonts:** deck uses Syne (headings), DM Sans (body), JetBrains Mono (code) from Google Fonts. If the venue has no internet when presenting, export to PDF beforehand.
8. **Deck format:** v2 asked for PowerPoint in presentation/week1/; Kasun approved a Claude Slides artifact instead. If a .pptx is needed, export from the artifact (Share > Export).

## UNVERIFIED points (in speaker notes, not on slides as facts)

- "MCP servers" in the architecture slide's external-services box (asked for by the v3 brief): not in environment.md or apex-faq.md, not used in this series.
- n8n descriptions (slides 7-8) are general, not checked against the 18 Nov material; n8n calling an ORDS endpoint was not tested.
- Select AI: exact profile setup (`DBMS_CLOUD_AI.SET_PROFILE`), the full action list in 26ai, and whether Select AI runs on non-Autonomous Oracle AI Database 26ai. Slide says "Available on Autonomous Database".
- Create App wizard "from a spreadsheet creates the table" (usual behaviour, not in spike notes).
- Create App Using Generative AI: exact screens and whether it proposes tables or only pages in 26.2.
- Whether a dedicated "AI chat region" exists in 26.2 besides the Show AI Assistant dynamic action (slide uses the spike wording).
- 26.2 click path to Generative AI Services (workspace level vs Shared Components > AI Services) and the model name shown there.
- Workflows card wording (Workflows present in Shared Components but not spike-tested).
- APEXlang export options in 26.2 on the free workspace (from apex-faq.md).
- Exact 26.2 menu labels for the workspace tour.
