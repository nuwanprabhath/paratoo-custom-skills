# Install instructions for agents

You are a Claude Code agent asked to install the skills in this repository for the user. Follow these steps in order. Don't skip the checks, and don't change anything outside the locations named here.

## 1. Locate the repo

- If the user gave a **local path**, use it.
- If they gave a **git URL**, ask where to clone it. Default: `~/projects/paratoo-custom-skills`. Then `git clone <url> <dir>`.
- Confirm `<dir>/.claude-plugin/marketplace.json` and `<dir>/skills/*/SKILL.md` exist. If not, stop and tell the user this isn't the right repo.

## 2. Check for conflicts

```bash
claude plugin list 2>/dev/null
ls ~/.claude/skills 2>/dev/null
```

Look for skills already installed under the same names: `blast-radius`, `why`, `correct`, `create-verification-skill`, `maintain-verification-skill`. A common source is the upstream `pstack` plugin. If you find any, tell the user which ones and ask whether to keep theirs or replace them. Don't decide for them.

## 3. Choose the install method

Unless the user already said which one, ask:

- **Plugin (recommended):** namespaced names (`/paratoo-skills:why`), updated with `claude plugin marketplace update`.
- **Symlinks:** short names (`/why`), updated live by `git pull`. Best for people who will edit the skills.

## 4. Install

Plugin:

```bash
claude plugin marketplace add <dir-or-git-url>
claude plugin install paratoo-skills@paratoo-custom-skills
claude plugin details paratoo-skills    # expect "Skills (5)"
```

Symlinks:

```bash
<dir>/install.sh --dry-run    # show the user what will happen
<dir>/install.sh              # add --force only if the user agreed to replace conflicts
ls -la ~/.claude/skills       # expect 5 symlinks into <dir>/skills
```

## 5. Check prerequisites and report

Run these and include the results in your report. They are warnings, not blockers:

```bash
glab auth status                 # why/correct need it for GitLab MRs and issues
node -v                          # paratoo-fdcp expects Node 20
```

Also say whether a Sentry MCP and a browser MCP (Claude in Chrome or Chrome DevTools) are connected. `why` uses Sentry when it's available, and the verification skills need a browser MCP to drive the UI.

Tell the user:

1. Which method you used and where the skills are installed
2. Any conflicts and what was decided
3. Prerequisite warnings
4. That they need a **new Claude Code session** before the skills appear
5. How to try one, e.g. "ask *why does `paratooWarnHandler` report to Sentry at warning level?*" or run `/blast-radius` on their current diff

## Uninstall

- Plugin: `claude plugin uninstall paratoo-skills` and optionally `claude plugin marketplace remove paratoo-custom-skills`
- Symlinks: `<dir>/install.sh --uninstall` (removes only what this repo installed)
