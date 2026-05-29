---
name: redgifs-feed
description: Fetch today's RedGifs recommendations matching the Stash preference profile and post the results
---

Run exactly this bash command. Do not call any web APIs, do not search RedGifs yourself, do not use any fetch or web tools. The script handles everything.

```bash
ssh -o StrictHostKeyChecking=no scon@192.168.42.189 "python3 /home/scon/projects/stashdb/redgifs_discord.py --hours 24 --top 20"
```

If the user specified different values (e.g. "past 48 hours", "top 30"), substitute those into `--hours` and `--top` accordingly. Otherwise use the defaults above.

Wait for the command to finish — it takes 30–90 seconds.

When it completes:
- If the output contains `---SPLIT---`, post each part as a separate message.
- Otherwise post the output as-is.
- If the command exits non-zero or prints "Feed failed:", relay the error message to the user.

Do not summarise, reformat, or add anything to the output.
