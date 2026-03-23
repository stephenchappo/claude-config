#!/usr/bin/env bash
# install.sh — symlink Claude config files into place
# Run once on each machine after cloning this repo.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME="$(hostname)"

echo "Installing Claude config from $REPO_DIR (hostname: $HOSTNAME)"

# User-level CLAUDE.md → ~/.claude/CLAUDE.md (universal rules, loaded in every session)
mkdir -p ~/.claude
if [ -L ~/.claude/CLAUDE.md ]; then
  echo "  ~/.claude/CLAUDE.md already symlinked — skipping"
elif [ -f ~/.claude/CLAUDE.md ]; then
  echo "  ~/.claude/CLAUDE.md exists as a regular file — review and remove manually, then re-run"
else
  ln -s "$REPO_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
  echo "  Linked ~/.claude/CLAUDE.md"
fi

# Machine-specific CLAUDE.md → ~/CLAUDE.md
MACHINE_FILE="$REPO_DIR/machines/$HOSTNAME.md"
if [ -f "$MACHINE_FILE" ]; then
  if [ -L ~/CLAUDE.md ]; then
    echo "  ~/CLAUDE.md already symlinked — skipping"
  elif [ -f ~/CLAUDE.md ]; then
    echo "  ~/CLAUDE.md exists as a regular file — review and remove manually, then re-run"
  else
    ln -s "$MACHINE_FILE" ~/CLAUDE.md
    echo "  Linked ~/CLAUDE.md → machines/$HOSTNAME.md"
  fi
else
  echo ""
  echo "  WARNING: No machine file found at machines/$HOSTNAME.md"
  echo "  Create it and re-run to get machine-specific context."
fi

# Skills
mkdir -p ~/.claude/skills
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$HOME/.claude/skills/$skill_name"
  if [ -e "$target" ]; then
    echo "  ~/.claude/skills/$skill_name already exists — skipping"
  else
    ln -s "$skill_dir" "$target"
    echo "  Linked ~/.claude/skills/$skill_name"
  fi
done

# Secrets file reminder
if [ ! -f ~/.claude/secrets.md ]; then
  echo ""
  echo "  ACTION REQUIRED: ~/.claude/secrets.md not found."
  echo "  Create it with your machine-specific credentials."
  echo "  See secrets.md.example for the expected format."
fi

echo ""
echo "Done. Restart Claude Code to pick up changes."
