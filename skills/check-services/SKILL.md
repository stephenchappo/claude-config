---
name: check-services
description: Check the status of all homelab services by probing each HTTP endpoint, with optional SSH fallback to diagnose downed services on Trillian
---

You are checking the status of all homelab services. Work through the steps below.

## Step 1 — Probe all endpoints

Use `curl` with a 5-second timeout to probe each endpoint. Retrieve only the HTTP status code:

```bash
curl -s -o /dev/null -w "%{http_code}" --max-time 5 <url>
```

Run all probes. Endpoints grouped by host:

**Trillian (192.168.1.100)**

| Service | URL |
|---------|-----|
| Wiki.js | http://192.168.1.100:3000 |
| Plex | http://192.168.1.100:32400 |
| Prowlarr | http://192.168.1.100:9696 |
| Sonarr | http://192.168.1.100:8989 |
| Radarr | http://192.168.1.100:7878 |
| Lidarr | http://192.168.1.100:8686 |
| Whisparr | http://192.168.1.100:6969 |
| Readarr | http://192.168.1.100:8787 |
| Stash | http://192.168.1.100:9999 |
| Booklore | http://192.168.1.100:6060 |
| Portainer | http://192.168.1.100:9000 |
| Homepage | http://192.168.1.100:3001 |
| FlareSolverr | http://192.168.1.100:8191 |
| OpenVPN AS | http://192.168.1.100:943 |

**Deepthought (192.168.1.151)**

| Service | URL |
|---------|-----|
| Ollama | http://192.168.1.151:11434 |
| Open WebUI | http://192.168.1.151:3000 |
| ComfyUI | http://192.168.1.151:8188 |
| Whisper ASR | http://192.168.1.151:9000 |
| Navidrome | http://192.168.1.151:4533 |
| n8n | http://192.168.1.151:5678 |

## Step 2 — Interpret results

- `200`, `301`, `302`, `401`, `403` → **UP** (responding, even if auth-gated)
- `000`, connection refused, or timeout → **DOWN** (not reachable)
- `5xx` → **UNHEALTHY** (responding but erroring)

Special case: if ALL Trillian services return `000`, the whole machine is likely offline — note
this rather than listing each service individually as down. Same logic applies to Deepthought.

## Step 3 — Report

Print results as a markdown table:

```
| Service      | Host        | Status       |
|--------------|-------------|--------------|
| Wiki.js      | Trillian    | ✅ UP (200)  |
| Sonarr       | Trillian    | ❌ DOWN      |
| Ollama       | Deepthought | ✅ UP (200)  |
...
```

End with a one-line summary: e.g. **19/20 services up. 1 down: Sonarr (Trillian).**

## Step 4 — SSH fallback for downed Trillian services

If any Trillian services are DOWN (and Trillian itself is reachable):

Ask the user: *"Sonarr appears to be down. Would you like me to SSH to Trillian to check
the container status and suggest a restart command?"*

**Only proceed with SSH after the user confirms.**

If confirmed, run:
```bash
ssh scon@192.168.1.100 "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -i <service>"
```

If the container is stopped or restarting, suggest:
```bash
ssh scon@192.168.1.100 "cd /srv/docker/<service> && docker compose up -d"
```

Present the command for the user to approve — do not run it automatically.

For Deepthought services (Ollama, ComfyUI — systemd; others — Docker):
```bash
# Docker services
ssh scon@192.168.1.151 "docker ps --format 'table {{.Names}}\t{{.Status}}'"

# Systemd services (Ollama, ComfyUI)
ssh scon@192.168.1.151 "systemctl status ollama comfyui"
```
