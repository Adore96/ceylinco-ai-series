# AI in Oracle APEX: three-session series

Material for a three-session series by **Noob Dev** on building AI features with Oracle APEX 26.2 on Oracle AI Database 26ai. The audience knows Oracle and SQL well and is new to APEX.

> **APEX is SQL with a screen.** Every component starts from a query you could already write; every AI feature is shown after the normal version, never instead of it.

All data is synthetic. The insurer, **Lanka Shield Assurance**, is fictional.

## Get the material

Clone this repository before the first session. It holds the documents, SQL scripts and data used in all three weeks.

```
git clone https://github.com/Adore96/ceylinco-ai-series.git
```

The Week 1 deck opens with a QR code that links here.

## The sessions

| Week | Topic                                      | Builds                                                                        |
|------|--------------------------------------------|-------------------------------------------------------------------------------|
| 1    | APEX and Oracle AI, component by component | Demos only: vector search and chunking in SQL, classifying call transcripts   |
| 2    | Core app and garage estimate AI            | Customer 360 app; image to JSON extraction, SQL checks, human approval, claim |
| 3    | Intelligent call centre                    | Triage, intent, an AI agent with PL/SQL tools, RAG in SQL, replies            |

Full plan: `docs/plan.html`.

## Repository map

```
sql/
  00_schema.sql        shared 8-table model for Weeks 2 and 3
  99_drop_schema.sql   reset between rehearsals (deletes all data)
  spikes/              platform checks run before building (S1 to S7, S9 cleanup)
  week1/               Week 1 demo scripts, in run order
data/
  calls/               30 synthetic call transcripts with expected labels
  reference-ids.md     policy, claim and vehicle numbers shared by all data
docs/
  plan.html            the session plan
  environment.md       what the free APEX workspace supports
  spikes.md            how to run the spike tests
  week1-component-map.md   each workflow step mapped to its APEX feature
  quick-sql.txt        the shared schema in Quick SQL shorthand
  apex-faq.md          questions from Oracle people, with sources
presentation/
  week1/               Week 1 deck (week1-deck.pptx), its slide source and the repo QR code
```

## How to run the SQL

There is no installer. Each script is pasted into **SQL Workshop** in APEX:

- **SQL Commands** for a single statement or PL/SQL block.
- **SQL Scripts** for files with many statements.

Each file's header says which one to use and what output to expect.

## What you need

- An Oracle APEX workspace (the free one at oracleapex.com is enough).
- A **Generative AI Service** with static ID `claude` (Anthropic). Weeks 1 to 3.
- A **Vector Provider** with static ID `gemini_embed` (Google Gemini). Week 3.

API keys are entered only in APEX Web Credentials. They are never stored in this repository.

## Further reading

Plain-language articles on the main AI concepts: [medium.com/@adorekasun](https://medium.com/@adorekasun).
