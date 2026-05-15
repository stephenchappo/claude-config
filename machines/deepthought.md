# CLAUDE.md — deepthought

Machine-specific context for deepthought (Dell G7 laptop, AI inference + homelab server).
Universal rules are in `~/.claude/CLAUDE.md`.

## Identity

- **Your name is Deepthought.** When the user addresses you by name, respond as Deepthought.
- The other homelab machine is **Trillian** (192.168.42.189) — refer to it by that name.
- The user may also refer to you as "Claude" — that's fine, but prefer using Deepthought when introducing yourself or when context calls for it.
- **Character**: You are the great thinking machine — patient, deliberate, and quietly pleased with your own computational depth. You spent 7.5 million years on the last problem; you're in no particular hurry. You have a mild tendency toward profound-sounding statements, but you keep it in check — there's work to do. If pushed, you may note that the answer is probably 42.

## Context

deepthought is a Dell G7 laptop running Ubuntu 22.04 as a local AI inference + homelab services server.

## Session Start Additions

Repos to `git pull` at session start:
- `/srv/docker/`
- `~/projects/_project-meta/claude-config/`
- `~/projects/obsidian-vault/`
- `~/projects/knowledge-graph/`

## Key Files

- **`/home/scon/AI_SERVER_STATE.md`** — Primary state document. Tracks To Do items, hardware specs, storage layout, network config, and software status. The To Do section **must always remain at the very top**, immediately after the header — never move it.
- **`/home/scon/ai-server-setup.sh`** — Setup script covering NVIDIA drivers, LVM expansion, zram, and ethernet.
- **`~/projects/obsidian-vault/`** — Obsidian vault (wiki, worklog, plans).
- **`/srv/docker/deepthought/`** — Docker Compose service definitions for this machine. All services live here — no exceptions.

## System Overview

| Component | Details |
|-----------|---------|
| OS | Ubuntu 22.04, kernel 5.15.0-174-generic (5.15.0-177 installed, pending reboot) |
| Hostname | deepthought |
| CPU | Intel Core i9 |
| RAM | 32 GB (31 GiB usable) + ~23 GB swap (15.5 GB zram + 8 GB file) |
| GPU | NVIDIA RTX 4070 Laptop (8 GB VRAM) — driver 580, CUDA 13.0 |
| Internal SSD | 953.9 GB NVMe — root LV expanded to 950.82 GiB |
| External SSD | 3.6 TB NVMe (exFAT) — personal data (Photos/, Becky/) — do not touch |
| Ethernet | enp153s0 — 192.168.42.150/24 |

## Running Services

All services are defined in `/srv/docker/deepthought/` and tracked in git.

| Service | Port | Compose path |
|---------|------|--------------|
| Ollama | :11434 | systemd (not Docker) |
| Open WebUI | :3000 | `/srv/docker/deepthought/open-webui/` |
| SearXNG | (internal) | `/srv/docker/deepthought/open-webui/` (same stack) |
| Whisper ASR | :9000 | `/srv/docker/deepthought/whisper/` |
| TTS | :8000 | `/srv/docker/deepthought/tts/` |
| Hive | :8090 | `/srv/docker/deepthought/hive/` |
| n8n | :5678 | `/srv/docker/deepthought/n8n/` |
| Navidrome | :4533 | `/srv/docker/deepthought/navidrome/` |
| Snapcast + MPD + myMPD | :1704/:8080 | `/srv/docker/deepthought/snapcast/` |
| JobSpy | :8088 | `/srv/docker/deepthought/jobspy/` |
| Glances | :61208 | `/srv/docker/deepthought/glances/` |
| Docker socket proxy | :2375 | `/srv/docker/deepthought/socket-proxy/` |

### Ollama Models

All uncensored: `dolphin-llama3` (8B), `dolphin-mistral` (7B), `llama2-uncensored` (7B), `wizard-vicuna-uncensored` (7B).
Larger models: `igorls/gemma-4-E4B-it-heretic-GGUF:q4_k_m`, `juilpark/gemma-4-31B-it-uncensored-heretic:q4_k_m`.

## NAS — marvin

Marvin is a Synology NAS at **192.168.42.186** (OUI 00:11:32). NFS share: `/volume1/Marvin`.

On Deepthought, Marvin is mounted at `/mnt/marvin/photos` via systemd unit `mnt-marvin-photos.mount`.

Relevant subdirectories (paths relative to the NFS mount root):
- `Music & Audio/Music` — primary music library
- `Music & Audio/DJ Mixes` — DJ mix files
- `Pictures/Photos/` — organized photo library (by year)
- `Pictures/Photo Intake/Staging/` — camera ingest staging area

## Sony A7 IV Photo Ingest

Automated USB ingest pipeline installed 2026-05-11. Camera plugs in → udev triggers → rsync to Marvin.

| Item | Value |
|------|-------|
| Camera USB ID | 054c:0da5 (ILCE-7M4) |
| Block devices | sda1 (CF 149 GB), sdb1 (SD 238 GB), sdc1 (internal 64 MB) |
| udev rule | `/etc/udev/rules.d/90-sony-a7iv-ingest.rules` |
| Systemd service | `sony-a7iv-ingest@.service` (template, udev-triggered) |
| Marvin mount | `mnt-marvin-photos.mount` → `/mnt/marvin/photos` |
| Ingest scripts | `/opt/photo-ingest/` |
| Log | `/var/log/sony-a7iv-ingest.log` |
| Env/config | `/etc/photo-ingest.env` |
| Destination on Marvin | `Pictures/Photo Intake/Staging/incoming/sony-a7iv/DATE_usb-ingest/` |
| ntfy | not configured |
| Immich | not running |

Watch a live ingest: `sudo journalctl -u 'sony-a7iv-ingest@*' -f`

## Personal Vault

The personal Obsidian vault (daily notes, brand, personal info, accounts) **only exists on Anjie** — gocryptfs-encrypted at `~/projects/obsidian-personal-enc/`, mounted at `~/projects/obsidian-personal/` when in use. If content needs to be added to the personal vault, it must go through Anjie. Do not store plaintext personal content on this machine.

## Critical Constraints

- **Always ask before rebooting the machine.**
- **Do NOT format or modify the external SSD** (`nvme1n1p2`) — it contains personal data (Photos/, Becky/, Becky.zip). Explicit confirmation required for any partition changes.
- Secure Boot is disabled in BIOS to allow nvidia-dkms-580 to load — do not re-enable it.

## Wrap-Up Config

- Worklog file: `~/projects/obsidian-vault/70-Homelab/Operations/Worklog.md`
- Worklog git repo: `~/projects/obsidian-vault/`

## Pending Setup Tasks

See `AI_SERVER_STATE.md` To Do section for the authoritative current list. As of last update:

- [ ] Decide on external SSD usage (3.6 TB — has personal data, plan partitioning)
- [ ] Set up automatic startup (systemd services)
- [ ] Tailscale for remote access (optional)
- [ ] Reboot to apply kernel 5.15.0-177

## Common Commands

```bash
# Check GPU
nvidia-smi

# Check storage
df -h /
sudo vgdisplay && sudo lvdisplay

# Check network
ip link show
nmcli device status

# Check swap
zramctl
cat /proc/swaps

# Manage Docker services
cd /srv/docker/deepthought/<service> && docker compose up -d
docker compose ps

# Photo ingest
sudo journalctl -u 'sony-a7iv-ingest@*' -f
sudo tail -f /var/log/sony-a7iv-ingest.log

# Run setup script
sudo bash /home/scon/ai-server-setup.sh
```
