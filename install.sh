#!/usr/bin/env bash
# install.sh — symlink Claude config files into place
# Run once on each machine after cloning this repo.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude config from $REPO_DIR"

# Root-level CLAUDE.md (requires sudo if /CLAUDE.md is owned by root)
if [ -f /CLAUDE.md ]; then
  echo "  /CLAUDE.md already exists — skipping (review manually)"
else
  sudo cp "$REPO_DIR/CLAUDE.md" /CLAUDE.md
  echo "  Installed /CLAUDE.md"
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
echo "Done. Restart Claude Code to pick up skill changes."
