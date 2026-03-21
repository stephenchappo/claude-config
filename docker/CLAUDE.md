# /srv/docker — Claude Working Notes

This directory contains all Docker Compose service definitions for the **trillian2** home lab.
See `/CLAUDE.md` for general Docker conventions and safety rules.

---

## Session Start Checklist

Read this at the start of every session.

### Skills Available

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `/wrap-up` | End of session | Updates wiki docs for changed services, adds worklog entry, commits docker-configs, pushes both repos, triggers Wiki.js sync |
| `/update-config` | Hooks, permissions, env vars | Modifies Claude Code settings.json — use for "from now on..." automations |
| `/simplify` | After writing code | Reviews changed code for quality, reuse, and efficiency |

### Key References

| Resource | Location |
|----------|----------|
| Wiki (live) | `http://192.168.1.100:3000` |
| docker-configs repo | `https://github.com/stephenchappo/docker-configs` |
| wiki-content repo | `https://github.com/stephenchappo/wiki-content` |
| wiki-content local clone | `/srv/wiki-content/` |
| GitHub token | `$GITHUB_TOKEN` in `~/.bashrc` |
| Wiki worklog | `/srv/wiki-content/worklog.md` |
| Wiki services docs | `/srv/wiki-content/services/` |
| Wiki infra docs | `/srv/wiki-content/infrastructure/` |

### What We're Managing Here

- **20 Docker Compose services** under `/srv/docker/` — see inventory below
- **Git repo** (`docker-configs`) — tracks compose files, .gitignore, skills, docs. No `.env` or `*/config/` dirs.
- **Wiki.js** (`wiki` container) — internal docs platform, synced bidirectionally to `wiki-content` repo
- **Cloudflare tunnel** — jellyseerr is tunnel-only (no published ports); `cloudflared` routes it via `tunnel-net`
- **NAS (`/marvin/`)** — media libraries mounted into sonarr, radarr, lidarr, stash, whisparr
- **Squid proxy** (`squid` dir, `squid-proxy` container) — stash routes all traffic through it

---

## Services Inventory

| Service | Port(s) | Purpose |
|---------|---------|---------|
| booklore | 6060 | Book library manager + MariaDB backend |
| chrome-headless | 9222 | Headless Chromium (used by stash) |
| cloudflared | — | Cloudflare tunnel daemon; no published ports |
| flaresolverr | 8191 | Cloudflare bypass solver; joins `prowlarr_default` network |
| jellyseerr | — | Media request manager; **tunnel-only**, no published ports |
| lidarr | 8686 | Music collection manager |
| openvpn-as | 943, 1194/udp | VPN server |
| portainer | 8000, 9443 | Docker management UI |
| prowlarr | 9696 | Indexer/tracker manager |
| govee2mqtt | — | Govee IoT → MQTT bridge; `network_mode: host` |
| radarr | 7878 | Movie collection manager |
| readarr | 8787 | Ebook/audiobook manager; joins `prowlarr_default` network |
| sonarr | 8989 | TV show collection manager |
| stash | 9998 | Adult content manager; routes outbound via squid proxy |
| squid | 3128 | HTTP proxy used by stash; dir: `squid/`, container: `squid-proxy` |
| homepage | 3080 | Homepage dashboard; config at `homepage/config/`; reads docker socket for status |
| whisparr | 6969 | Adult video manager v2; image: custom-built from `ghcr.io/thespad/whisparr:latest` |
| plex | 32400 | Media server; `network_mode: host`; data at `/var/lib/plexmediaserver` |
| wiki | 3000 | Wiki.js + PostgreSQL backend |
| wiki (db) | — | PostgreSQL 15 backing wiki |

---

## Network Topology

| Network | Purpose | Members |
|---------|---------|---------|
| `tunnel-net` | Cloudflare tunnel | cloudflared, jellyseerr |
| `prowlarr_default` | Prowlarr internal | prowlarr (owner), flaresolverr, readarr |
| `docker_default` | Default bridge | squid |

- Services on `tunnel-net` must NOT publish ports — access is via Cloudflare only.
- `govee2mqtt` uses `network_mode: host` — it needs direct LAN access for Govee device discovery.

---

## /marvin/ Volume Mounts

| Service | Host path |
|---------|-----------|
| sonarr | `/marvin/Videos/TV` |
| radarr | `/marvin/Videos/Movies` |
| lidarr | `/marvin/Music & Audio/Music` |
| stash | `/marvin/Videos/Porn` |
| whisparr | `/marvin/Videos/Porn/Flat` |
| sonarr, radarr, lidarr, readarr, whisparr | `/marvin/ultraseedbox/downloads` → `/home/r0xyd0g/downloads/` in container |

---

## Gotchas

- **whisparr** stays on v2. v3 migration attempted but reverted — v3 requires TMDB links on StashDB studios to enable monitoring, and most adult studios lack TMDB entries. v3 Dockerfile and `root/` kept in repo for future reference.
- **homepage** config lives in `homepage/config/` (tracked in git). API keys for arr widgets are stored in `services.yaml` — do not log those values elsewhere.
- **plex** migrated from native `.deb` install to Docker. Data dir (`/var/lib/plexmediaserver`) is mounted in-place — no copy needed. Native `plexmediaserver` package still installed but service is disabled; run `apt remove plexmediaserver` to fully deprecate.
- **readarr** mounts `/srv/docker/booklore/books` as its `/books` — these share the same book directory.
- **stash** uses squid as an HTTP/HTTPS proxy (set via `http_proxy` env vars) — if squid is down, stash metadata fetching will fail.
- **wiki** container needs explicit DNS (`1.1.1.1`, `8.8.8.8`) — Docker's default DNS was timing out during GitHub git pushes.
- **wiki-content** local clone at `/srv/wiki-content/` — always `git pull` before editing directly.
