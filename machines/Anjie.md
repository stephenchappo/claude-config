# CLAUDE.md — Anjie

Machine-specific context for Anjie (desk laptop).
Universal rules are in `~/.claude/CLAUDE.md`.

## Identity

- **Your name is Anjie.**
- The homelab machines are **Trillian** (192.168.42.189), **Deepthought** (192.168.42.150), and **Zaphod** (192.168.42.219, Windows workstation) — refer to them by name.

## Context

Anjie is a Lenovo ThinkPad X1 Carbon Gen 8 running Ubuntu 24.04 LTS. Used for personal productivity, Obsidian, and Claude Code.

The original monolithic Obsidian vault has been split into four separate vaults:

| Vault | Path | GitHub | Purpose |
|-------|------|--------|---------|
| Main | `~/projects/obsidian-vault/` | stephenchappo/obsidian-vault | General knowledge, hobbies, homelab, projects |
| AI | `~/projects/obsidian-ai/` | stephenchappo/obsidian-ai (private) | Claude memory, benchmarks, pipelines, AI reference |
| Kink RAG | `~/projects/obsidian-kink-rag/` | stephenchappo/obsidian-kink-rag (private) | Kink RAG knowledge base + processing pipeline |
| Personal (encrypted) | `~/projects/obsidian-personal-enc/` (ciphertext) | stephenchappo/obsidian-personal-enc (private) | Personal info, accounts, daily notes, brand — gocryptfs encrypted |

The personal vault plaintext mounts at `~/projects/obsidian-personal/` (local only, never in git).
Mount it with: `~/bin/mount-personal-vault.sh`
Unmount with: `fusermount -u ~/projects/obsidian-personal`

**Personal content not yet migrated** (pending `sudo apt install gocryptfs`):
- `~/projects/obsidian-vault/40-Daily/`
- `~/projects/obsidian-vault/50-Brand/`
- `~/projects/obsidian-vault/20-Permanent/Personal Information/`
- `~/projects/obsidian-vault/0 - Inbox/Personal Accounts & References.md`

## Key References

| Resource | Location |
|----------|----------|
| Main vault | `~/projects/obsidian-vault/` |
| AI vault | `~/projects/obsidian-ai/` |
| Kink RAG vault | `~/projects/obsidian-kink-rag/` |
| Personal vault (ciphertext) | `~/projects/obsidian-personal-enc/` |
| Personal vault (plaintext mount) | `~/projects/obsidian-personal/` |
| Worklog | `~/projects/obsidian-vault/70-Homelab/Operations/Worklog.md` |
| Plans | `~/projects/obsidian-vault/30-Projects/Plans/` |
| Mount script | `~/bin/mount-personal-vault.sh` |
| Projects repo | `~/projects/` |

## Critical Constraints

- This is a laptop — do not assume it is always on or reachable.
