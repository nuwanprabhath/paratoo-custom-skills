# paratoo-custom-skills

Claude Code skills adopted from other projects and adapted for the [paratoo-fdcp](https://gitlab.com/ternandsparrow/paratoo-fdcp) monorepo (Strapi core/org + Vue/Quasar webapp, GitLab CI, Cypress).

These skills are separate from the ones checked into paratoo-fdcp itself (`.claude/skills/ci-*`, `vitest-component-test`). Those are repo tooling that everyone gets on checkout. These are opt-in: each developer installs them on their own machine.

## Skills

| Skill | Invoke | What it does |
|---|---|---|
| **blast-radius** | auto, or `/blast-radius` | Finds what a change breaks *outside* the diff: core↔org↔webapp copies kept in sync by script, schema auto-migrations, offline tablets sending old-shape payloads, the PDP auth path, Cypress spec coupling. Proves the one fact the change is safe because of by running code. |
| **why** | auto, or `/why` | Answers "why is this code like this?" Parallel investigators search git history and GitLab MRs, GitLab issues, in-repo docs and handovers, and Sentry if connected, then a synthesizer writes a cited, confidence-tiered answer. |
| **correct** | `/correct` only | Turns review comments that keep coming back into ESLint local rules, changed-files ratchets, CI guards, or tests, and proves each check fails on a real past mistake. Keeps a rule → enforcer table in `AGENTS.md`. |
| **create-verification-skill** | `/create-verification-skill` only | Generates `.claude/skills/verify-<app>/` in paratoo-fdcp: launch the local stack, health-check it, log in, drive a protocol, capture evidence, clean up. Includes a pre-filled paratoo interview. |
| **maintain-verification-skill** | `/maintain-verification-skill` only | Upkeep pass for a `verify-*` skill: re-reads every feature from source, drives every feature live, and ships at most one MR of proven fixes. |

"auto" means Claude can pick the skill on its own when your request matches its description. "only" skills are heavy or change the repo, so they run only when you type the command.

All of them respect paratoo-fdcp's mandatory agent workflow (research → ask → plan → approve → implement → report). The analysis skills are read-only. The ones that change the repo stop for approval before they write anything.

## Install

**Ask an agent:** point Claude Code at this repo and say:

> Install the skills from https://github.com/nuwanprabhath/paratoo-custom-skills by following its INSTALL.md.

**Or do it yourself.** Pick one of the two options below.

### Option A: plugin (recommended for most people)

```bash
claude plugin marketplace add nuwanprabhath/paratoo-custom-skills
claude plugin install paratoo-skills@paratoo-custom-skills
```

Inside a Claude Code session, `/plugin marketplace add …` and `/plugin install …` do the same. Skills show up namespaced, e.g. `/paratoo-skills:why`. Auto-invocation works the same either way.

To update: `claude plugin marketplace update paratoo-custom-skills`. To remove: `claude plugin uninstall paratoo-skills`.

### Option B: symlinked personal skills (for people editing the skills)

```bash
git clone https://github.com/nuwanprabhath/paratoo-custom-skills.git ~/projects/paratoo-custom-skills
~/projects/paratoo-custom-skills/install.sh
```

This symlinks each skill into `~/.claude/skills/`, so `git pull` updates them in place and names stay short (`/why`). It never overwrites a skill of the same name that it didn't install; pass `--force` to replace one. Other options: `--copy`, `--dry-run`, `--uninstall`, `--target <dir>`.

Either way, start a new Claude Code session to pick up the skills.

### Prerequisites the skills expect

- A paratoo-fdcp checkout as the working directory
- `glab` installed and authenticated (`glab auth status`). Without it, `why` and `correct` lose MR/issue history and report that as a gap.
- Optional: a Sentry MCP server (used by `why`), and a browser MCP (Claude in Chrome or Chrome DevTools) for the verification skills

## Adding a skill

1. Put it in `skills/<name>/SKILL.md` with `name` and `description` frontmatter. Use `disable-model-invocation: true` if it changes the repo or is expensive.
2. Adapt it to paratoo-fdcp: GitLab and `glab`, not GitHub and `gh`. Use real paths, scripts and commands from the repo, and check that each one exists. Respect the `AGENTS.md` workflow. Drop references to tools we don't have.
3. If it came from somewhere else, check that the source license allows reuse. Add the one-line attribution comment under the frontmatter and a section in `THIRD_PARTY_NOTICES.md` with the source URL, author, license text, upstream commit SHA, and a per-file change list.
4. Add a row to the Skills table above and bump `version` in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
5. Run `claude plugin validate .` and `./install.sh --dry-run`.

### Considered and not adopted (pstack, 2026-10-05)

- `tdd`, `interrogate`, `swarm`, `arena`, `architect`, `figure-it-out`: superpowers / GSD / `/code-review` already cover them.
- `typescript-best-practices`, `principle-type-system-discipline`: the repo is JavaScript.
- `principle-never-block-on-the-human`, `poteto-mode`: contradict the mandatory ask/approve workflow.
- `principle-*` in general: good reading, but each installed skill costs always-on context. Fold the useful ideas into the skills above instead.

## License

MIT. See [LICENSE](LICENSE). Adapted material keeps its original copyright and license; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
