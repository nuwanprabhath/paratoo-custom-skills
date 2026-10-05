---
name: why
description: "Use for 'why does X work this way', 'why did we pick Y', 'why is this here', design rationale, regressions, postmortems, or where a threshold came from in paratoo-fdcp. Investigates git history, GitLab MRs and issues (via glab), in-repo docs and handovers, and Sentry (if connected) in parallel, then returns a cited, confidence-tiered answer. Not for what code does at runtime — read the code for that."
---

<!-- Adapted from pstack `why` (MIT, © 2026 Lauren Tan). See THIRD_PARTY_NOTICES.md. -->

# Why

Investigate the motivation and intent behind code.

Reading the code answers what it does. `why` answers what forces led to its shape. Use `blast-radius` for what a change to it would break.

## Operating posture

Operate as a **careful, cautious, and precise investigator**. Be honest about what you know vs what you're inferring. Read `references/epistemics.md` for the confidence framework and phrasing guide. The synthesizer must follow it.

This skill is read-only. Investigators and the synthesizer never write files, comment on issues/MRs, or change any external state.

## Step 1. Understand the target and the question

Parse what the user is asking. The **target** is usually a chunk of code, a pattern, a feature, a protocol, or a named design decision. The **question** is usually a design rationale, a tradeoff, a motivating edge case, an external constraint (a field-team requirement, a TERN/DCCEEW data standard, an offline/tablet limitation), dead code, or a broad history sweep.

If the target is vague, make your best guess from conversation context (open files, recent edits, what was just discussed). State your interpretation in one line so the user can redirect, then proceed.

## Step 2. Establish the code anchor

Before spawning investigators, anchor the investigation in concrete code:

- The relevant file path(s) and line range(s)
- The key symbols (function names, Strapi content-type names, store names, constants)
- An initial commit list — the last few commits touching the target
- MR numbers and issue numbers referenced in those commits

```bash
git blame -L <start>,<end> <file>
git log --follow --oneline -20 -- <file>
git log -1 --format=%B <commit>
```

paratoo-fdcp conventions that help here:

- Merge commits read `Merge branch '<issue>-<slug>' into '<target>'` — the leading number of the branch is usually the **GitLab issue** number.
- Commit subjects often carry `#1234` (an issue) and MR descriptions carry `!1234` (an MR).
- Find the MR that introduced a commit: `glab api "projects/:id/repository/commits/<sha>/merge_requests"`.

Pull the MR and issue context for the substantive commits:

```bash
glab mr view <mr> --comments
glab issue view <issue> --comments
```

Capture this as seed context (files, symbols, commits, MR numbers, issue numbers) and pass it to every investigator.

If `glab auth status` fails, say so up front: GitLab MRs and issues will be listed as unsearched gaps.

## Step 3. Spawn parallel investigators (default posture)

**Default to the full parallel investigation.** Launch all investigators **in a single message** using the Agent tool so they run concurrently. One investigator per evidence source; don't ask one agent to cover several.

Each investigator:

- `subagent_type`: `general-purpose` (it needs Bash for `git`/`glab` and access to any MCP tools; `Explore` is fine for the in-repo docs investigator)
- `run_in_background`: false is fine here — you need every result before synthesis
- Prompt = `references/investigator-prompt.md` with placeholders filled + the single playbook for its source + `references/sources/incident-postmortem.md` **if the target looks defensive** (null/zero guards, retries, timeouts, `try/catch` that swallows, Sentry calls, feature flags, offline-sync fallbacks) + the code anchor + the user's question verbatim.

### Investigator roster for this repo

| # | Source | Playbook | Availability | Uniquely surfaces |
|---|---|---|---|---|
| 1 | Source control (git + GitLab MRs) | `sources/code-archaeology.md` | Always | Implementation-time rationale captured in commit messages and MR review |
| 2 | GitLab issues | `sources/gitlab-issues.md` | Needs `glab` authenticated | The product/field-team forcing function; scope decisions in comments |
| 3 | In-repo long-form docs | `sources/in-repo-docs.md` | Always | Design write-ups, handovers, plans, changelogs — rationale written before or after the code |
| 4 | Error tracking (Sentry) | `sources/sentry.md` | Only if a Sentry MCP is connected | The exceptions that motivated defensive code |
| 5 | Other connected sources | adapt the closest playbook | Check available MCP tools (chat, docs, observability) | Whatever that source holds |

Before spawning, check the available tool list for MCP servers (e.g. names containing `sentry`, `slack`, `gitlab`, `confluence`, `notion`, `drive`). Map each to one row. A GitLab MCP, if authenticated, can back rows 1–2 in place of `glab`.

### When to skip an investigator

Only skip with an **explicit, written justification** that goes in the final "Sources Consulted" section. Two valid reasons:

- **The source isn't available** here (no Sentry MCP; `glab` not authenticated). Flag it as a gap, not a choice.
- **The source is provably irrelevant**, not just probably. Example: "Sentry skipped — target is a build-time helper script with no runtime path."

If the target is a single-commit change and its MR description already answers the question completely, you may answer inline — but say explicitly that you checked and the other sources would be redundant. This should be rare.

## Step 4. Synthesize

Spawn one synthesizer with the Agent tool:

- `subagent_type`: `general-purpose` (it spot-checks citations, which may need `glab` or MCP access)
- Prompt = `references/synthesizer-prompt.md` filled in with: all investigator findings (including null results and skipped sources with reasons), the code anchor, the user's question, and an instruction to read `references/epistemics.md` in full first.

The synthesizer may read code and run read-only commands to verify citations. It must not write files or change external state.

## Step 5. Present

Present the synthesizer's output. You may lightly edit for clarity or add context from the conversation, but **do not rewrite the confidence language**.

The output structure is the one in `references/synthesizer-prompt.md`: The Question, The Code in Question, What We Found, What We Can Reasonably Infer, Competing Hypotheses, What We Don't Know, Sources Consulted, Confidence Summary. Keep Sources Consulted as one line per investigator, including the ones that returned nothing or were skipped, with the reason.

If the `why` question is a precursor to changing this code, finish with a **Preserve / Change / Avoid / Risk** constraint list for the plan — and suggest running `blast-radius` on the eventual diff.

## Common failure modes

- **Recency bias.** The most recent commit is rarely the origin. The current shape is often an accretion. Trace back — `git log -S` / `-G` on the exact literal.
- **Merge-commit dead ends.** `git blame` on this repo often lands on a `Merge branch ...` or a big `dev/x.y.z` back-merge. Use `git blame -w -C -C` and `git log --first-parent` vs `--no-merges` to get past them.
- **Stale branch history.** Release branches (`dev/1.0.x`) get merged into each other. The same change can appear under several SHAs; dedupe by MR.

## Reference files

- `references/epistemics.md` — confidence tiers and phrasing guide. The synthesizer must follow it.
- `references/investigator-prompt.md` — base prompt template for investigators.
- `references/synthesizer-prompt.md` — prompt template and output format for the synthesizer.
- `references/source-playbook.md` — index of the per-source playbooks.
- `references/sources/*.md` — one playbook per source, plus cross-cutting `incident-postmortem.md`.
