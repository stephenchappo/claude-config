# Homelab Network Reference

Shared network and service inventory for the claude-config repo.
This is the single source of truth for IPs, ports, and service URLs.
Referenced by machine files at session start — keep updated when services change.

---

## Network

| Item | Value |
|------|-------|
| Subnet | 192.168.1.0/24 |
| Gateway | 192.168.1.1 (TP-Link router) |
| External domain | fake-dom.com (Cloudflare) |
| Cloudflare tunnel | Runs on Trillian — routes external traffic to LAN services |

---

## Servers

### Trillian — 192.168.1.100

Primary homelab server. Runs all media, automation, and infrastructure Docker services.
Docker configs: `/srv/docker/<service>/docker-compose.yml` — global env: `/srv/docker/.env`

| Service | Internal URL | External URL | Notes |
|---------|-------------|--------------|-------|
| Wiki.js | http://192.168.1.100:3000 | http://wiki.fake-dom.com | GraphQL API at /graphql |
| Jellyseerr | — | https://requests.fake-dom.com | Tunnel-only, Google OAuth required |
| Plex | http://192.168.1.100:32400 | — | network_mode: host |
| Prowlarr | http://192.168.1.100:9696 | — | Indexer/tracker hub for all arr apps |
| Sonarr | http://192.168.1.100:8989 | — | TV management |
| Radarr | http://192.168.1.100:7878 | — | Movie management |
| Lidarr | http://192.168.1.100:8686 | — | Music management |
| Whisparr | http://192.168.1.100:6969 | — | Adult video manager (v2 only) |
| Readarr | http://192.168.1.100:8787 | — | Ebook / audiobook manager |
| Stash | http://192.168.1.100:9999 | — | Adult content manager |
| Booklore | http://192.168.1.100:6060 | — | Book library |
| Portainer | http://192.168.1.100:9000 | — | Docker management UI |
| Homepage | http://192.168.1.100:3001 | — | Service dashboard |
| FlareSolverr | http://192.168.1.100:8191 | — | Cloudflare bypass (for Prowlarr) |
| OpenVPN AS | http://192.168.1.100:943 | — | VPN server |

Docker networks of note:
- `tunnel-net` — cloudflared + Jellyseerr (no published ports)
- `prowlarr_default` — Prowlarr + FlareSolverr + Readarr

### Deepthought — 192.168.1.151

AI inference server (Dell G7 laptop, Ubuntu 22.04, RTX 4070 Laptop 8 GB VRAM).
Also reachable as `deepthought` via mDNS / hosts file.

| Service | URL | Notes |
|---------|-----|-------|
| Ollama | http://192.168.1.151:11434 | GPU-accelerated, systemd service |
| Open WebUI | http://192.168.1.151:3000 | Docker, connects to Ollama |
| ComfyUI | http://192.168.1.151:8188 | systemd service, CUDA |
| Whisper ASR | http://192.168.1.151:9000 | Docker, OpenAI-compatible API, medium model |
| Navidrome | http://192.168.1.151:4533 | Docker, music library |
| n8n | http://192.168.1.151:5678 | Docker, automation platform, SQLite |

Ollama models (all uncensored): `dolphin-llama3` (8B), `dolphin-mistral` (7B),
`llama2-uncensored` (7B), `wizard-vicuna-uncensored` (7B).

---

## NAS — Marvin (192.168.1.101)

Synology NAS. Mounted via NFS on Trillian and Deepthought at `/marvin/`.
**Not mounted on Arthur.**

| Share | Mount path | Used by |
|-------|-----------|---------|
| Videos/Movies | /marvin/Videos/Movies | Radarr, Plex |
| Videos/TV | /marvin/Videos/TV | Sonarr, Plex |
| Videos/Porn | /marvin/Videos/Porn | Stash, Whisparr |
| Music & Audio/Music | /marvin/Music & Audio/Music | Lidarr, Navidrome |
| Music & Audio/DJ Mixes | /marvin/Music & Audio/DJ Mixes | Navidrome |
| ultraseedbox/downloads | /marvin/ultraseedbox/downloads | rclone SFTP seedbox mount |
| Books | /marvin/Books | Readarr, Booklore |

---

## Network Devices

| IP | Device | Notes |
|----|--------|-------|
| 192.168.1.1 | TP-Link Router | Gateway |
| 192.168.1.100 | Trillian | Primary homelab server (wired) |
| 192.168.1.101 | Marvin NAS | Synology |
| 192.168.1.151 | Deepthought | AI inference server (WiFi) |
| 192.168.1.171 | Marvin (Windows PC) | SMB/FTP |

### Smart Home / IoT

| Device | Notes |
|--------|-------|
| Home Assistant | mDNS: `homeassistant` — smart home hub |
| Philips Hue Bridge | mDNS: `_hue._tcp` |
| HP OfficeJet Pro 9010 | Printer/scanner |
| Prusa MK4 | 3D printer |
| iRobot Roomba | Robot vacuum |
| Google Nest Hubs (×2) | Thread/Matter border routers, Cast targets |

---

## External Access (Cloudflare Tunnel)

| Public URL | Internal Service | Auth |
|------------|-----------------|------|
| https://requests.fake-dom.com | Jellyseerr :5055 | Google OAuth (Cloudflare Access) |
| http://wiki.fake-dom.com | Wiki.js :3000 | Internal |

Adding a new service to the tunnel: join target container to `tunnel-net` Docker network,
add public hostname in Cloudflare Zero Trust → Tunnels → <tunnel> → Public Hostnames.

---

## Integrations

| Integration | Details |
|-------------|---------|
| Wiki GraphQL API | http://192.168.1.100:3000/graphql |
| Wiki API token | `WIKI_TOKEN` env var (in `~/.claude/settings.json` on each machine) |
| Wiki worklog page | ID: 6, path: `worklog` |
| Vikunja | Task source of truth |
| GitHub | repos: `stephenchappo/claude-config`, `stephenchappo/wiki-content` |
| Download client | qBittorrent on Ultraseedbox (`r0xyd0g.agate.usbx.me:443/qbittorrent`) |
