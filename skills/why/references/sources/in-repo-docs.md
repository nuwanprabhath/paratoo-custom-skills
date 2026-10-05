# In-repo long-form docs

## What this source contains

paratoo-fdcp keeps a lot of written rationale inside the repo itself rather than in a wiki:

- `docs/*.md` — design guides (`org-pdp-policy.md`, `redis-caching.md`, `binary_storage_with_dexiedb.md`, `custom-rules-validation.md`, …), plans, and audits
- `docs/HANDOVER-*.md` — dated handover notes between contributors; often the only place a half-finished decision is explained
- `docs/ARCHITECTURE/`, `docs/superpowers/`, root-level `plans/`, `*_ANALYSIS.md`, `ACTUAL_FIX.md`
- Every `AGENTS.md` and `README.md` (root and per service)
- `docs/review-standards.md` and `docs/code-standards.md` — rules that exist because of past mistakes
- Changelogs (see `helper-scripts/changelog/`) and release notes
- Strapi `schema.json` `description` fields and JSDoc on helpers

## How to search it

```bash
# Where is the target mentioned in prose?
rg -n -i '<symbol|feature|protocol name>' --glob '*.md' --glob '!**/node_modules/**'

# Which docs changed around the same time as the target commit?
git log --since=<date-2w> --until=<date+2w> --name-only --oneline -- docs plans '*.md'

# Who wrote a doc and when, and the commit that introduced it
git log --follow --format='%h %ad %an %s' --date=short -- docs/<file>.md

# Handovers in date order around the change
ls docs/HANDOVER-* | sort
```

Read the whole document, not just the grep hit. Handover notes often explain a decision paragraphs away from the keyword.

## What good evidence looks like here

- A design doc section that names the alternatives and says why one was chosen
- A handover note saying "we did X because Y; Z is still open"
- A review standard whose example is exactly the target pattern
- An `AGENTS.md` rule written in bold or `CRITICAL`, with the incident it came from

## Common pitfalls

- **Docs drift.** A doc can describe a plan that was later changed. Check the doc's last-modified date against the target code's history and say which is newer.
- **Plans aren't decisions.** `plans/` and `*-plan.md` record intent. Only cite them as the reason if the code matches the plan.
- **Agent-written docs.** Some docs were drafted by agents. Treat their rationale as an author's claim, and prefer the MR/issue they cite.

## What to return

For each relevant document:
- Path and the specific section/heading
- The exact text (quoted)
- The doc's author and last-modified date (`git log -1`)
- Whether it was written before or after the target code, and whether it's direct or circumstantial
