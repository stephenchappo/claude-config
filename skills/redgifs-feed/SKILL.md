---
name: redgifs-feed
description: Fetch today's RedGifs recommendations matching the Stash preference profile and post the top results
---

You are fetching today's RedGifs feed. Run the script on Trillian and format the output for Discord.

## Step 1 — Parse arguments

The user may provide optional flags. Defaults:
- `--hours 24` — look back 24 hours (user can say "past 48 hours" etc.)
- `--top 20` — return top 20 results for Discord (default reduced from CLI default of 40 for readability)
- `--min-score 0.5`

## Step 2 — Run the feed script

SSH to Trillian and run the script. Use the defaults unless the user specified different values:

```bash
ssh -o StrictHostKeyChecking=no scon@192.168.42.189 "cd /home/scon/projects/stashdb && python3 redgifs_feed.py --hours 24 --top 20 --output /tmp/redgifs_discord.json" 2>&1
```

If the user specified custom hours/top/min-score, substitute those values.

Wait for it to complete (it takes 30–90 seconds). Do not give up early.

## Step 3 — Read the JSON output

```bash
ssh -o StrictHostKeyChecking=no scon@192.168.42.189 "cat /tmp/redgifs_discord.json"
```

## Step 4 — Format for Discord

Post a summary in this format — keep it compact, Discord-friendly:

```
**RedGifs Feed** — past {hours}h  ({count} clips)

{rank}. `[{score}]` **@{userName}**{flags}
↳ {top 4 tags}
🔗 {watch_url}

{rank}. ...
```

Where:
- `{flags}` — append ` · lesbian` if the clip has lesbian tags, ` · predicament` if predicament bondage
- Only show the top 4 tags per clip
- Group results with a blank line between each entry
- After the list, add a one-line footer: `Saved to redgifs_discord.json on Trillian`

Keep the full list in a single message if under 2000 chars; otherwise split into two messages with "**[1/2]**" and "**[2/2]**" headers.

## Step 5 — Handle errors

If the script fails (no results, network error, API error):
- Check the stderr output for clues
- Report the error clearly: "Feed failed: {reason}"
- Do not post a partial/empty list
