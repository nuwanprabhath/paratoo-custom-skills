---
name: correct
description: "Find the mistakes agents (and people) keep repeating in paratoo-fdcp and make each one impossible: architecture first, then a lint rule whose error names the fix, then a test, and docs last. Proves each new check fails on a real past mistake. Use for /correct, 'stop agents doing X again', or after the same review comment shows up twice."
disable-model-invocation: true
---

<!-- Adapted from pstack `correct` (MIT, © 2026 Lauren Tan). See THIRD_PARTY_NOTICES.md. -->

# Correct

Reviewers and the operator keep correcting agents in this repo for the same mistakes. Change the repo so the next agent can't make them.

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that passes lint. Design the repo so a change that looks right from one file is right for the whole repo.

paratoo-fdcp already writes a lot of rules down: `AGENTS.md` files (several hundred lines each), `docs/review-standards.md` (30+ numbered standards), `docs/code-standards.md`, and `paratoo-webapp/test/cypress/AGENTS.md`. Text rules fail silently when an agent skips them. This skill moves the rules that keep being broken out of prose and into checks.

## 0. Follow the repo workflow

This skill changes the repo, so the mandatory workflow in `AGENTS.md` applies: do sections 1 and 2 (research), then **present the classes and the proposed level for each and wait for approval** before writing any check. Each fix lands as its own commit on a branch and goes through an MR like any other change.

## 1. Find the mistake classes

Read, in this order:

- `docs/review-standards.md` — every numbered standard is a past mistake class. The `[blocking]` ones are the expensive ones.
- Review comments on recent MRs: `glab mr list --merged --per-page 30`, then `glab mr view <n> --comments` (human and CodeRabbit comments both count).
- Fix and revert commits: `git log --oneline -200 --grep='^fix' -i`, `git log --oneline --grep=revert -i`. A `fix:` that undoes a recent `feat:` is a strong signal.
- Workaround comments: `rg -n '(HACK|XXX|WORKAROUND|do not|don.t|never|always)' --glob '!**/node_modules/**' paratoo-*/src`.
- Every `AGENTS.md` and `docs/agent-workflow.md`: rules written in bold, `CRITICAL`, or `NEVER` are rules someone already got burned by.
- `docs/HANDOVER-*.md` — they often record "the agent kept doing X".

Group the mistakes into classes. **A class counts once it has happened twice** — cite both occurrences (commit SHA, MR note, or file:line).

## 2. Fix each class at the highest level that works

1. **Eliminate it with architecture.** Give each piece of state one owner and each task one supported way. Replace hand-synced copies with one source of truth where feasible (the `helper-scripts/diff-*.sh` / `sync-*.sh` pairs mark today's hand-synced copies). Delete old ways and dead code an agent would copy.
2. **Enforce it with a check whose error names the fix.** The repo is JavaScript, not TypeScript, so "make it a type error" mostly isn't available — the practical level-2 tools are:
   - **ESLint local rules** — `paratoo-webapp/eslint-local-rules.js` already has repo-specific rules (`no-return-router-push-in-guard`, `check-paratoo-warn-handler-args`). Add new rules there, and the same pattern in core/org `.eslintrc` if needed. The `message` must name the file, helper, or function to use instead (e.g. "use `doCoreApiGet()` from `src/misc/api.js`, not raw axios" — review standard #21).
   - **Changed-files ratchet** — if the bad pattern is already common, fail only when a change adds more. `yarn lint:cypress:changed` (CI job `cypress-lint-gate`) is the existing example: it lints only what the branch changed against `git merge-base`. Copy that approach rather than fixing the whole codebase in one MR.
   - **CI guards** — scripts like `helper-scripts/check_initial_data_order.py` and the `diff-*.sh` scripts, wired into a `*-build-lint` job in `.gitlab-ci.yml`.
3. **Test the behavior.** Jest in core/org, Vitest in webapp (see the `vitest-component-test` skill in the repo), or the Cypress fixture harness (`docs/cypress-fixture-harness.md`) for DOM-level classes that static analysis can't see. Fix or delete any test that would still pass if every function it calls returned `undefined`.
4. **Write docs or agent rules last, only for judgment calls.** Nothing fails when an agent skips them.

## 3. Fix and prove

Fix the most frequent classes first, one commit each (conventional commit format — `commitlint` runs in CI). **Prove each new check fails on a real past mistake**: check out or re-create the offending code from the cited commit, run the check, paste the failure. A rule that has never failed is not proven. Then show it passes on the current tree (or on the changed-files set, for a ratchet).

Run the same command locally that CI runs — `yarn lint` in the affected service, or the exact `script:` line from the CI job.

Exceptions go on the offending line (`// eslint-disable-next-line <rule> -- <reason>, expires <YYYY-MM-DD>, approved by <human>`), never as a blanket disable.

## 4. Keep the rule table

Keep one table in the nearest `AGENTS.md` (root for cross-service rules, service-level otherwise) that pairs each rule with what enforces it:

| Rule | Enforced by | Since |
|---|---|---|
| Don't return `router.push()` from a navigation guard | `local-rules/no-return-router-push-in-guard` | MR !NNN |

When you are corrected during a session, fix the mistake and add the row. If the row was already there and nothing enforces it, that's a repeat, so move it up a level in the same change. Delete the row (and the prose it replaced) once the mistake can't happen any more — shrinking `AGENTS.md` is part of the job.

**Reply:** each class with its evidence (two citations minimum), the level you picked, why a higher level didn't work, and — for anything implemented — the pasted failure on the real past mistake.
