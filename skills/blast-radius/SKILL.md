---
name: blast-radius
description: "Find what a change could break somewhere else in paratoo-fdcp before it ships — beyond the diff, across core/org/webapp, offline data, and Cypress spec coupling — and prove the one fact it's safe because of by running real code instead of writing it up. Use for 'blast radius of X', 'what could this break', 'is this MR safe', or reviewing a small diff you don't trust."
---

<!-- Adapted from pstack `blast-radius` (MIT, © 2026 Lauren Tan). See THIRD_PARTY_NOTICES.md. -->

# Blast radius

Find what a change breaks somewhere else, before it ships. Use for "blast radius of X", "what could this break", or reviewing a small diff you don't trust yet.

Companion to `why`. The code tells you what it does. `why` tells you why it's shaped that way. Blast radius tells you what it breaks somewhere else.

Listing the callers is not the job. You can grep those in a second. The job is the breakage grep won't show you.

This skill is read-only analysis plus throwaway proof scripts. It does not change product code, so it fits inside step 1 (Research) of the repo's mandatory workflow in `AGENTS.md`. If the analysis says the change needs fixing, report it — don't fix it without the plan/approval steps.

## Don't trust your own writeup

A blast-radius writeup that sounds right is worthless. It reads as convincing whether or not it's true. So don't hand back the writeup. Find the one or two facts the whole thing depends on and prove them by running code.

### How sure are you

For each fact the change's safety depends on, get it as far down this list as is cheap, and say where it stopped.

1. You said so. Worthless on its own.
2. You pointed at the line. A real `file:line`, or the library's own source in `node_modules`.
3. You showed the bad case can't happen. You walked the failure step by step and it doesn't reach.
4. You ran it. A script or test that calls the real code and fails loud if you're wrong.
5. You reproduced it in the running app (local stack, or a `verify-*` skill if the repo has one).

Step 4 is usually one small `node` script that requires the same module or library version the app ships and calls the exact function you're worried about. Put it in your scratchpad, not the repo.

## Steps

1. **Read the change.** The diff, the symbols it adds, changes, and deletes, and what it now does differently, including the part the diff doesn't spell out. For an MR: `glab mr view <n> --comments` and `glab mr diff <n>`. For history behind the touched lines, use `why` step 2.
2. **Find the one fact it's safe because of.** Most changes that look risky are safe because of a single fact, like "this only runs for records created after the migration" or "the webapp never sends this field offline". Find that fact. If it holds, most risky cases are cleared at once. Spend your time here, not on a long list of maybes.
3. **Look where grep stops.** Read the library source and its pinned version (`yarn.lock` per service — core/org use yarn 3, webapp yarn 1) and any `patches/`. Work out when things run: Strapi lifecycle hooks and policies vs controllers, Vue `watch`/`onMounted`/unmount order, Pinia store hydration, async Dexie writes. Then walk the paratoo-specific hidden edges below.
4. **Be honest about each risk.** Give it a real chance of happening and a real cost if it does. Keep the risks you confirmed. List the ones you checked and cleared separately. Cite a real `file:line`; a search that finds nothing is still an answer; never make up a caller or an API.
5. **Prove the one fact.** Write a script or test that runs the real code, run it, and paste what happened. Jest in `paratoo-core`/`paratoo-org` (`yarn test`), Vitest in `paratoo-webapp`, or a plain `node` script.
6. **For a big or wide change, get independent reads.** Spawn 2–3 `general-purpose` subagents with the same question and no view of each other's answers (optionally with different `model` overrides), then merge. Different reviewers catch different real bugs.

## Paratoo's hidden edges

These are the places a change in one file silently breaks another. Check every one the diff could touch.

**Copies kept in sync by script, not by import.** A change to one side without the other passes local tests and fails elsewhere. Run the matching diff script from `helper-scripts/`:

| Edited | Must match | Check with |
|---|---|---|
| Custom validation rules (core) | webapp copy | `diff-custom-rules.sh` |
| `src/policies/is-validated.js` (core) | org copy | `diff-policies.sh` |
| Protocol models (core) | org copy | `diff-protocol-models.sh` |
| `paratooErrorHandler.js` (core) | org copy | `diff-error-handlers.sh` |
| plot-selection `initialData` | core ↔ org | `diff-plot-selections-init-data.sh` |
| LUT `initialData` / vocab | webapp client init state | `node diff_lut_core_web.js` |
| Protocol schema / names | Cypress `PROTOCOL_NAME_MAPPER` | `diff-protocol-name-mapper.sh` |
| Protocol / LUT `initialData` order | append-only | `check_initial_data_order.py` |

**Wire formats and stored data.**
- A `schema.json` change auto-migrates the Postgres DB on boot. Renames drop data unless a migration exists. Check whether a data migration is needed and whether it re-throws on error.
- The webapp builds requests from API models. Removing or renaming an attribute breaks submits from any client still running the old bundle.
- **Offline is the longest tail.** Field tablets queue submissions in Dexie/persisted Pinia state and may sync days later on an older app version. Ask: what happens when a payload shaped by the *old* code reaches the *new* server, and when the new app rehydrates state persisted by the old one?
- Bulk submission flows and `paratoo-data-export` read the same records. A field the UI doesn't show may still be exported.

**Auth path.** `core` asks `org` for authorization decisions (PDP). A change to roles, project membership, or the `org-interface` controller can lock users out of core endpoints without any core diff. See `docs/org-pdp-policy.md`.

**Shared webapp helpers.** `src/misc/helpers.js`, `src/misc/api.js`, shared stores, and generic components (`FieldGroupContainer`, CRUD components) fan out to every protocol. Grep usage count before calling something "local".

**Tests that depend on other tests.** Cypress specs in pinned groups produce state that later specs consume. If the change alters a producer spec or the data it creates, use the `ci-spec-dependencies` skill to find consumers, and `ci-shard-lookup` to say which CI job will show the failure.

**Sentry and error handling.** Changing what is thrown vs warned (`paratooErrorHandler`, `paratooWarnHandler`) changes alerting, not just behaviour.

## What to hand back

- **What it does.** What changed, including the part that isn't obvious.
- **The one fact it's safe because of.** State it, say which step you got it to, and show the proof. If you couldn't prove it, write **unproven**.
- **Risks.** Each names how it breaks, the `file:line`, how likely and how bad, and how to check. Paste the proof for the ones that matter.
- **Cleared.** What you checked and why it's fine — including which hidden-edge rows above you checked and found irrelevant.
- **Before you merge.** The cheapest test or repro that catches the real bug, including the script you wrote, and the specific Cypress spec(s) or diff scripts worth running.

Write plainly: short sentences, no filler, cite real code. Strip anything private (tokens, user data from the DB) before it goes into an MR comment.

**Reply:** the writeup above, with the one safety fact either proven or marked unproven.
