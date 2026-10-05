# Third-party notices

This repository adapts skills from the projects listed below. Each adapted `SKILL.md` carries a one-line attribution comment pointing here. When you adopt a skill from a new source, add a section to this file in the same shape (see "Adding a skill" in `README.md`).

---

## pstack (cursor/plugins)

- **Source:** https://github.com/cursor/plugins/tree/main/pstack
- **Author:** Lauren Tan
- **License:** MIT (full text below)
- **Upstream commit adopted from:** `e43c7ee26e0038c6c1fa8380dd34ce86ff94cb2a` (fetched 2026-10-05)

### Files adapted

| This repo | Upstream (`pstack/skills/…`) | Changes |
|---|---|---|
| `skills/blast-radius/SKILL.md` | `blast-radius/SKILL.md` | Model-invocable (dropped `disable-model-invocation`). Replaced `arena`/`unslop`/`how` references with Claude Code subagents and plain-writing guidance. GitHub → GitLab (`glab`). Added the "Paratoo's hidden edges" section: core↔org↔webapp sync scripts, schema auto-migration, offline/Dexie payload tail, PDP auth path, shared webapp helpers, Cypress pinned-group dependencies, Sentry handlers. Tied to the repo's `AGENTS.md` research-only step. |
| `skills/correct/SKILL.md` | `correct/SKILL.md` | Added the repo workflow gate (present → approve → MR). Pointed mistake discovery at `docs/review-standards.md`, `glab` MR comments, handovers, and `AGENTS.md`. Replaced the type-system level with ESLint local rules, the existing changed-files ratchet (`lint:cypress:changed`), and CI guard scripts, since the repo is JavaScript. Added the rule-table format and the eslint-disable exception convention. |
| `skills/why/SKILL.md` | `why/SKILL.md` | Model-invocable. Removed Cursor model-role routing (`pstack-models.mdc`, Task tool slugs, `readonly`) in favour of the Claude Code Agent tool with `general-purpose`/`Explore` subagents. Replaced the seven generic MCP categories with this repo's sources (git + GitLab MRs, GitLab issues, in-repo docs, Sentry if connected). Added GitLab-specific anchoring (branch-name issue numbers, `!`/`#` conventions, commit→MR lookup) and merge-commit failure modes. |
| `skills/why/references/epistemics.md` | `why/references/epistemics.md` | Terminology only (PR → MR, ticket → issue). |
| `skills/why/references/investigator-prompt.md` | `why/references/investigator-prompt.md` | Terminology and placeholder names (MR/issue numbers); source list. |
| `skills/why/references/synthesizer-prompt.md` | `why/references/synthesizer-prompt.md` | Terminology; "Sources Consulted" list rewritten for this repo's sources. |
| `skills/why/references/source-playbook.md` | `why/references/source-playbook.md` | Rewritten index for the sources kept. |
| `skills/why/references/sources/code-archaeology.md` | `why/references/sources/code-archaeology.md` | `gh` → `glab`; merge-commit and back-merge handling; terminology. |
| `skills/why/references/sources/sentry.md` | `why/references/sources/sentry.md` | Terminology only. |
| `skills/why/references/sources/incident-postmortem.md` | `why/references/sources/incident-postmortem.md` | Source list rewritten (GitLab issues, in-repo postmortem docs, git, Sentry handlers). |
| `skills/create-verification-skill/SKILL.md` | `create-verification-skill/SKILL.md` | Output path `.cursor/skills/` → `.claude/skills/`. Added the paratoo interview reference, the repo workflow gate, Bash `run_in_background` launch guidance, and paratoo-relevant evidence types (core DB, Dexie). |
| `skills/create-verification-skill/references/feature-map-example/*` | same path | Verbatim. |
| `skills/maintain-verification-skill/SKILL.md` | `maintain-verification-skill/SKILL.md` | `.cursor` → `.claude` paths; PR → MR via `glab`; subagents via the Agent tool (`Explore`); approval step before shipping; churn sweep pointed at webapp pages/router. |

### Files written for this repo (not from pstack)

- `skills/why/references/sources/gitlab-issues.md`
- `skills/why/references/sources/in-repo-docs.md`
- `skills/create-verification-skill/references/paratoo-interview.md`

### Upstream files not adopted

`why/references/sources/{linear,notion,slack,datadog,databricks}.md` — paratoo-fdcp doesn't use those tools. Restore them from the upstream commit above if that changes.

### License

```
MIT License

Copyright (c) 2026 Lauren Tan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
