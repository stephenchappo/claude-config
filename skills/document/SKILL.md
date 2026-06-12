---
name: document
description: Save a link to the shared links library with automatic categorisation. Use when the user says /document followed by a URL.
---

You are saving a link to the shared homelab links library so it's available to all Claude machines.

The user has provided a URL (in args or in their message). Work through the steps below.

## Step 1 — Fetch the URL

Use WebFetch to retrieve the page and extract:
- **Title** — the page or document title
- **Summary** — one sentence describing what it is
- **Suggested category** — pick the best fit from:
  - `homelab` — self-hosting, Docker, infrastructure, networking
  - `ai-ml` — AI models, inference, training, tools
  - `dev-tools` — programming utilities, CLIs, libraries, frameworks
  - `reference` — specs, RFCs, official docs, man pages
  - `media` — streaming, music, video, media servers
  - `finance` — budgeting, banking, taxes
  - `misc` — anything that doesn't fit above

## Step 2 — Confirm with user

Present your findings and ask for confirmation before saving:

```
Title:       <title>
URL:         <url>
Category:    <category>
Description: <2-3 sentence description of what this is and why it's useful>
Tags:        <tag1>, <tag2>, <tag3>  (lowercase, hyphenated, e.g. docker, self-hosted, api, python)

Save this? (or suggest corrections)
```

Wait for the user to confirm or correct any field.

## Step 3 — Append to links file

The shared links file is `/srv/wiki-content/links.md`. If it doesn't exist yet, create it with this header:

```markdown
# Links Library

A shared reference library, available on all Claude machines. Updated via `/document`.

```

Append the new entry under a `## <Category>` heading (create the heading if it doesn't exist yet, keep headings alphabetical):

```markdown
### [<Title>](<URL>)
*Added: YYYY-MM-DD · Tags: `<tag1>` `<tag2>` `<tag3>`*

<Description>

```

## Step 4 — Commit and push

```bash
cd /srv/wiki-content
git add links.md
git commit -m "links: add <title>"
git push
```

## Step 5 — Tell Trillian to pull

```bash
ssh trillian 'cd /srv/wiki-content && git pull'
```

Confirm to the user with:
- A success message: "Saved and pushed."
- The direct URL that was just saved (as a clickable link)
- Where to browse the full library: `http://192.168.42.189:3000/en/links` (wiki) or `/srv/wiki-content/links.md` on any machine after `git pull`
