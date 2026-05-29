---
name: spankbang-feed
description: Fetch recent SpankBang clips matching selected tag groups and post the results
---

Run exactly this bash command. Do not call any web APIs, do not scrape SpankBang yourself, do not use any fetch or web tools. The script handles everything.

```bash
ssh -o StrictHostKeyChecking=no scon@192.168.42.189 "python3 /home/scon/projects/stashdb/spankbang_discord.py --groups all --top 20"
```

If the user specified groups (e.g. "religious", "bondage", "femdom", "kink"), substitute them into `--groups`. Multiple groups are space-separated: `--groups bondage femdom`. If the user specified a different top count, substitute into `--top`. Otherwise use the defaults above.

Available groups: `religious`, `bondage`, `discipline`, `femdom`, `submission`, `pain`, `machines`, `electro`, `fantasy`, `kink` (all non-religious), `all`.

Wait for the command to finish — it takes 60–120 seconds.

When it completes:
- If the output contains `---SPLIT---`, post each part as a separate message.
- Otherwise post the output as-is.
- If the command exits non-zero or prints "Feed failed:", relay the error message to the user.

Do not summarise, reformat, or add anything to the output.
