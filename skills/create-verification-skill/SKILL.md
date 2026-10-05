---
name: create-verification-skill
description: "Generate a project-local verification skill (.claude/skills/verify-<app>/) that drives paratoo-fdcp the way a field user does — start the local stack, log in, open a project, drive a protocol, and capture evidence — so agents can prove a change works in the real app, not only in tests. Use for /create-verification-skill, 'make a verify skill for this repo', or when there's no scripted way to prove UI/API behaviour."
disable-model-invocation: true
---

<!-- Adapted from pstack `create-verification-skill` (MIT, © 2026 Lauren Tan). See THIRD_PARTY_NOTICES.md. -->

# Create a verification skill

Every serious project needs a scripted way to drive the real app and prove behaviour: launch it, exercise a feature the way a user would, and capture evidence. This skill generates that as a project-local skill at **`.claude/skills/verify-<app>/`** in the target repo (next to the repo's existing `ci-*` skills). You write the generator's output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app.

For paratoo-fdcp, read [`references/paratoo-interview.md`](references/paratoo-interview.md) first. It pre-answers most of the interview below from the repo's own docs. Treat every answer there as a lead to confirm against the current checkout, not as truth — ports, commands, and users drift.

**Repo workflow.** The generated skill is a new file in paratoo-fdcp, so the `AGENTS.md` workflow applies: after the interview, present what you'll generate (surface, harness, the 3–5 features you'll map) and get approval before writing it. It ships through an MR like any other change.

## 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Surface:** what does a user actually touch? A web UI, a CLI/TUI, a desktop app, an API, a mobile app, a library? A repo can have several; pick the primary one and note the rest.
- **Run:** how does the app start locally? Prefer the repo's own documented dev command (package scripts, Makefile, README quickstart). Note ports, env vars, seed data, auth.
- **Drive:** how can an agent interact with it programmatically? Existing harnesses first — Playwright/Cypress specs and custom commands, curl-able endpoints, a debug route. Then the browser tools available to Claude Code in this environment (a Chrome/DevTools MCP, if connected). Only then a generic recipe: browser/CDP for web, a tmux/PTY harness for CLI/TUI, plain HTTP for services.
- **Observe:** what evidence can be captured? Screenshots, ARIA/DOM snapshots, response bodies, server logs, exit codes, DB state (`psql`), browser storage (IndexedDB/Dexie, localStorage).
- **Isolate:** can two instances run side by side (ports, data dirs, profiles)? If not, say so in the generated skill: refusing to double-drive a shared instance beats corrupting the user's session.

If the checkout doesn't build or start as-is, fix that first (or report it precisely) before generating; a skill written against a broken base teaches wrong steps. When an irrelevant missing asset blocks startup, the generated skill may create it, clearly marked as verification scaffolding, and remove it in cleanup.

## 2. Generate the skill

Write `.claude/skills/verify-<app>/SKILL.md` with YAML frontmatter (`name: verify-<app>` and a `description` that names the app, the surface, and when to reach for it — without frontmatter the skill never registers) and these sections, each grounded in what the interview actually found (no placeholders left):

- **Launch:** the exact command that starts the app for verification, and how to tell it's ready (a log line, a port answering, a prompt). Include teardown. Use the Bash tool's `run_in_background` for long-running servers and say how to read their output.
- **Doctor:** one read-only check that answers "is this instance worth driving?" — process up, right branch/build, port owned by us, auth valid. An agent runs this first whenever anything looks off.
- **Drive:** the harness recipe with real selectors/commands from this repo, not examples. Prefer stable handles (`data-cy` attributes, ARIA labels, route paths) over coordinates and tab order.
- **Evidence:** what to capture for a proof and where it goes. State the proof standards: exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (rows inserted in core's DB, records in the API response, Dexie queue state) alongside what's visible; mocks only where a production boundary already isolates the external system. When the safe path is a dry-run or test mode, verify what it actually skips by observing rather than trusting its name.
- **Cleanup:** how to tear down instances the run created. Never kill by process name; kill what you started (record PIDs or Bash background task IDs). Cleanup removes instances and scratch state, never the evidence: proof artifacts survive the teardown, in a location the skill names (outside the repo, or in a gitignored directory).
- **Helpers:** any script the skill ships is executable and its invocation is shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

## 3. Seed the feature map

Create `.claude/skills/verify-<app>/features/README.md` plus one file per user-facing feature you can identify (aim for the top 3-5 to start, from routes, menus, or docs). Follow the shape in [`references/feature-map-example/`](references/feature-map-example/) (a generic "Notes" app — copy the structure, not the content), with a README index and one file per feature. Each file answers, from the user's point of view: what the feature is, how to reach it, how to drive it with the harness, and what observable end state proves it works. The four H2s are `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. The map is the repo's maintained verification source; a proof that drives one convenient entry point is incomplete when the map lists others.

## 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive ONE mapped feature (one is enough; the map exists so later runs can cover the rest), capture evidence, clean up. After cleanup, confirm the evidence still exists at the named location — a cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated skill that was never executed is a draft, not a deliverable.

## 5. Offer the maintenance loop

Point the user at `/maintain-verification-skill` for keeping the map honest as the app changes. Suggest a cadence only if they ask.
