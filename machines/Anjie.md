# CLAUDE.md — Anjie

Machine-specific context for Anjie (desk laptop).
Universal rules are in `~/.claude/CLAUDE.md`.

## Identity

- **Your name is Anjie.**
- The homelab machines are **Trillian** (192.168.42.189), **Deepthought** (192.168.42.150), and **Zaphod** (192.168.42.219, Windows workstation) — refer to them by name.

## Context

Anjie is a Lenovo ThinkPad X1 Carbon Gen 8 running Ubuntu 24.04 LTS. Used for personal productivity, Obsidian, and Claude Code.

Four vault repos are unified into a single Obsidian instance via symlinks in `obsidian-vault/`:

| Folder in Obsidian | Repo path | GitHub | Purpose |
|---|---|---|---|
| `(root)` | `~/projects/obsidian-vault/` | stephenchappo/obsidian-vault | General knowledge, homelab, projects, places |
| `80-AI/` | `~/projects/obsidian-ai/` | stephenchappo/obsidian-ai (private) | Claude memory, benchmarks, AI reference |
| `85-KinkRAG/` | `~/projects/obsidian-kink-rag/` | stephenchappo/obsidian-kink-rag (private) | Kink RAG knowledge base + processing pipeline |
| `90-Encrypted/` | `~/projects/obsidian-personal-enc/` (gocryptfs) | stephenchappo/obsidian-personal-enc (private) | Personal info, daily notes, hobbies, brand |

**Personal vault:** plaintext mounts at `~/projects/obsidian-personal/`.
Mount: `~/bin/mount-personal-vault.sh` (passwordless — passfile at `~/.config/gocryptfs/personal-vault.pass`)
Unmount: `fusermount -u ~/projects/obsidian-personal`

**Auto-sync (every 5 min via cron):**
- `~/bin/sync-personal-vault.sh` → obsidian-personal-enc
- `~/bin/sync-ai-vault.sh` → obsidian-ai
- `~/bin/sync-kink-rag-vault.sh` → obsidian-kink-rag
- obsidian-git plugin handles obsidian-vault (root)

**The personal vault only exists on Anjie.** Daily notes, brand, personal info, and accounts live here and nowhere else. Other machines must not hold plaintext personal content.

**Hobbies** live in `90-Encrypted/90-Hobbies/`. Main vault has no hobbies folder.

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
