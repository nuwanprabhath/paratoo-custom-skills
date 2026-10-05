#!/usr/bin/env bash
# Install the skills in this repo as personal Claude Code skills (~/.claude/skills).
#
# Usage:
#   ./install.sh                 symlink every skill into ~/.claude/skills (default)
#   ./install.sh --copy          copy instead of symlink (no auto-update on git pull)
#   ./install.sh --force         replace an existing skill of the same name
#   ./install.sh --uninstall     remove only the skills this repo installed
#   ./install.sh --dry-run       print what would happen, change nothing
#   ./install.sh --target <dir>  install somewhere other than ~/.claude/skills
#
# Prefer the plugin install (see README.md) for teams; use this script when you
# want un-namespaced skill names (/why rather than /paratoo-skills:why) or are
# editing the skills and want changes picked up live.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
TARGET="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
MODE=link
FORCE=0
DRY=0
UNINSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --copy) MODE=copy ;;
    --force) FORCE=1 ;;
    --dry-run) DRY=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --target) shift; TARGET="$1" ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

run() {
  if [ "$DRY" = 1 ]; then echo "  would run: $*"; else "$@"; fi
}

# A skill at $dest belongs to this repo if it is a symlink into it, or a copy
# carrying the marker file we write on --copy.
ours() {
  local dest="$1"
  if [ -L "$dest" ]; then
    case "$(readlink "$dest")" in "$SKILLS_SRC"/*) return 0 ;; esac
  fi
  [ -f "$dest/.installed-from-paratoo-custom-skills" ]
}

run mkdir -p "$TARGET"
installed=0 skipped=0 removed=0

for src in "$SKILLS_SRC"/*/; do
  src="${src%/}"
  name="$(basename "$src")"
  [ -f "$src/SKILL.md" ] || continue
  dest="$TARGET/$name"

  if [ "$UNINSTALL" = 1 ]; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      if ours "$dest"; then
        run rm -rf "$dest"; echo "removed   $name"; removed=$((removed + 1))
      else
        echo "kept      $name (not installed by this repo)"
      fi
    fi
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if ours "$dest" || [ "$FORCE" = 1 ]; then
      run rm -rf "$dest"
    else
      echo "skipped   $name — $dest already exists and isn't from this repo (use --force to replace)"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  if [ "$MODE" = link ]; then
    run ln -s "$src" "$dest"
  else
    run cp -R "$src" "$dest"
    run touch "$dest/.installed-from-paratoo-custom-skills"
  fi
  echo "installed $name -> $dest ($MODE)"
  installed=$((installed + 1))
done

if [ "$UNINSTALL" = 1 ]; then
  echo "Done: $removed removed from $TARGET."
else
  echo "Done: $installed installed, $skipped skipped, in $TARGET."
  echo "Start a new Claude Code session to pick them up."
fi
