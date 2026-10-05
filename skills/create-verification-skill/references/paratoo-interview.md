# paratoo-fdcp interview: starting answers

Written from the repo's own docs (root `AGENTS.md`, `docs/agent-workflow.md`, `docs/multiple-instances.md`, `helper-scripts/run_stack_for_pipeline.sh`, `paratoo-webapp/test/cypress/`). **Confirm each answer in the current checkout before you build on it.** If an answer here is wrong, fix this file in the skills repo too.

## Surface

- **Primary:** `paratoo-webapp`, a Vue 3 / Quasar PWA branded **Monitor**. Field users log in, pick a project, pick a protocol, fill a multi-step form, and submit (online, or queued offline and synced later).
- **Secondary:** the two Strapi v4 REST APIs — `paratoo-core` (domain data) and `paratoo-org` (auth, projects, roles, PDP). Useful for verifying side effects, not as the user path.
- **Not in scope by default:** `paratoo-data-export`, `paratoo-cas-server`, `paratoo-json-to-xlsx`, Strapi admin UIs.

## Run

Prereqs: Docker running, Node 20 (`v20.20.1` known good; Node 25 breaks `better-sqlite3`), deps installed per app (core/org yarn 3, webapp yarn 1).

Start order, each long-running (use `run_in_background`):

1. `cd paratoo-core && ./pcore` — Postgres + Strapi. **First boot takes 3–5 minutes** (admin build, migrations, LUT/init data seeding). Ready when the log prints "Server started" or `/admin` answers.
2. `cd paratoo-org && ./porg` — creates test users from `paratoo-org/test_users.env` on bootstrap.
3. `cd paratoo-webapp && yarn start` — dev server.

Default ports: core `1337`, org `1338`, webapp `8080`. **Worktrees use different ports** — read `.stack-config` in the worktree root or run `./worktree-list`; never hard-code `1337/1338/8080` in the generated skill without that fallback.

Test users: `helper-scripts/run_stack_for_pipeline.sh` is the source of truth for which `TEST_USER*` entries the tests expect (e.g. `TestUser`, `ProjectAdmin`) and the projects each can see. Reference the script from the generated skill rather than copying passwords into it.

## Drive

Options, best first:

1. **Browser MCP** (Claude in Chrome or Chrome DevTools MCP, if connected): drive the real UI at the webapp URL. Selectors: the app uses `data-cy` attributes widely (Cypress `cy.dataCy(...)`); prefer those, then ARIA roles/labels.
2. **Cypress custom commands** as a recipe source: `paratoo-webapp/test/cypress/support/commands.js` (`cy.login`, `cy.dataCy`, `cy.testRoute`, navigation helpers in `nav-commands.js`). They encode the real wait conditions — e.g. after login wait for `.q-loading__backdrop` to disappear and `[data-cy=api-models-loaded]` to exist. Running one focused spec (`yarn cypress run --browser chrome --spec <spec>`) is also valid evidence for flows a browser MCP can't drive cleanly.
3. **HTTP**: log in against org to get a JWT, then call core with `Authorization: Bearer <jwt>` to read back what the UI submitted.

Login gotcha: logging in mounts `MainLayout`, which starts a large offline map-tile download (#2821). Expect slow first loads and don't treat them as hangs.

## Observe

- Screenshots and ARIA/DOM snapshots from the browser MCP
- Core API responses for the submitted records; `psql postgresql://strapi:strapi@localhost:5432/paratoo_core_localdev` (port/DB name differ per worktree — check `.stack-config`)
- Browser storage: Pinia persisted state and Dexie (IndexedDB) for offline queues; `/zzDebug` in the webapp has Dexie inspect/clear tools
- Strapi server logs from the background tasks

## Isolate

- `./worktree-new <slot> <name> <ref>` creates a sibling worktree with its own ports, Docker container names, and volumes, and writes `.stack-config`. `./worktree-remove <name>` tears it down. This is the safe way to run a verification stack beside the user's own.
- The generated skill must **never drive the user's main localdev stack** without saying so first: submitting protocols writes real rows to their DB.

## Good first features to map

Pick 3–5 that cover the main paths; confirm the routes and `data-cy` handles in source:

- **Log in and land on projects** (`/projects`)
- **Open a project and start a protocol** (the Kitchen Sink project is used for testing many protocols)
- **Fill and submit a simple protocol online**, then read the record back from core
- **Offline submit then sync** — the riskiest path; queue while offline, reconnect, confirm the record arrives
- **A field validation rule** (custom rules in `src/misc/customRules.js`) blocking "Next"

## Cleanup

- Stop only the background tasks this run started (track their IDs/PIDs).
- Remove records the run created, or run in a throwaway worktree and `./worktree-remove` it.
- Clear browser state the run created (`/zzDebug` or the browser MCP), not the user's.
- Keep evidence in a named directory outside the worktree being removed.
