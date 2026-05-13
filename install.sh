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

# Machine config JSON → ~/.claude/machine-config.json (used by VSCode dashboard extension)
MACHINE_JSON="$REPO_DIR/machines/$HOSTNAME.json"
if [ -f "$MACHINE_JSON" ]; then
  cp "$MACHINE_JSON" ~/.claude/machine-config.json
  echo "  Wrote ~/.claude/machine-config.json"
else
  echo "  No machines/$HOSTNAME.json found — dashboard will use defaults"
fi

# VS Code settings → ~/.config/Code/User/settings.json
VSCODE_SETTINGS_SRC="$REPO_DIR/dotfiles/vscode/settings.json"
if [ -f "$VSCODE_SETTINGS_SRC" ]; then
  VSCODE_USER_DIR="$HOME/.config/Code/User"
  mkdir -p "$VSCODE_USER_DIR"
  TARGET="$VSCODE_USER_DIR/settings.json"
  if [ -L "$TARGET" ]; then
    echo "  $TARGET already symlinked — skipping"
  elif [ -f "$TARGET" ]; then
    echo "  $TARGET exists as a regular file — review and remove manually, then re-run"
  else
    ln -s "$VSCODE_SETTINGS_SRC" "$TARGET"
    echo "  Linked $TARGET"
  fi
fi

# SSH config → ~/.ssh/config
SSH_CONFIG_SRC="$REPO_DIR/dotfiles/ssh/config"
if [ -f "$SSH_CONFIG_SRC" ]; then
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  TARGET="$HOME/.ssh/config"
  if [ -L "$TARGET" ]; then
    echo "  ~/.ssh/config already symlinked — skipping"
  elif [ -f "$TARGET" ]; then
    echo "  ~/.ssh/config exists as a regular file — review and remove manually, then re-run"
  else
    ln -s "$SSH_CONFIG_SRC" "$TARGET"
    chmod 600 "$SSH_CONFIG_SRC"
    echo "  Linked ~/.ssh/config"
  fi
fi

# Git config → ~/.gitconfig
GITCONFIG_SRC="$REPO_DIR/dotfiles/git/gitconfig"
if [ -f "$GITCONFIG_SRC" ]; then
  TARGET="$HOME/.gitconfig"
  if [ -L "$TARGET" ]; then
    echo "  ~/.gitconfig already symlinked — skipping"
  elif [ -f "$TARGET" ]; then
    echo "  ~/.gitconfig exists as a regular file — review and remove manually, then re-run"
  else
    ln -s "$GITCONFIG_SRC" "$TARGET"
    echo "  Linked ~/.gitconfig"
  fi
fi

# Claude MCP config → ~/.claude/mcp.json
MCP_SRC="$REPO_DIR/dotfiles/claude/mcp.json"
if [ -f "$MCP_SRC" ]; then
  mkdir -p ~/.claude
  TARGET="$HOME/.claude/mcp.json"
  if [ -L "$TARGET" ]; then
    echo "  ~/.claude/mcp.json already symlinked — skipping"
  elif [ -f "$TARGET" ]; then
    echo "  ~/.claude/mcp.json exists as a regular file — review and remove manually, then re-run"
  else
    ln -s "$MCP_SRC" "$TARGET"
    echo "  Linked ~/.claude/mcp.json"
  fi
fi

# VSCode dashboard extension
EXTENSION_SRC="$REPO_DIR/vscode-extension"
if [ -d "$EXTENSION_SRC" ]; then
  # Install into both .vscode and .vscode-server (local and remote)
  for vscode_dir in "$HOME/.vscode" "$HOME/.vscode-server"; do
    EXTENSION_DEST="$vscode_dir/extensions/homelab-welcome"
    if [ -d "$vscode_dir" ]; then
      rm -rf "$EXTENSION_DEST"
      cp -r "$EXTENSION_SRC" "$EXTENSION_DEST"
      echo "  Installed VSCode extension → $EXTENSION_DEST"
    fi
  done
else
  echo "  No vscode-extension/ directory found — skipping"
fi

# Secrets file reminder
if [ ! -f ~/.claude/secrets.md ]; then
  echo ""
  echo "  ACTION REQUIRED: ~/.claude/secrets.md not found."
  echo "  Create it with your machine-specific credentials."
  echo "  See secrets.md.example for the expected format."
fi

# wiki-content repo reminder
if [ ! -d "$HOME/wiki-content" ]; then
  echo ""
  echo "  ACTION REQUIRED: ~/wiki-content not found."
  echo "  Clone it with:"
  echo "    git clone https://github.com/stephenchappo/wiki-content.git ~/wiki-content"
fi

echo ""
echo "Done. Restart Claude Code to pick up changes."
