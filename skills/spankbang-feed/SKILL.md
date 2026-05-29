---
name: spankbang-feed
description: Fetch recent SpankBang clips matching selected tag groups and post the results
---

Run exactly this bash command. Do not call any web APIs, do not fetch any URLs, do not search SpankBang yourself, do not use any web or fetch tools. The script handles everything.

```bash
ssh -o StrictHostKeyChecking=no scon@host.docker.internal "python3 /home/scon/projects/stashdb/spankbang_discord.py --groups all --top 20"
```

If the user specified groups (e.g. "religious", "bondage femdom", "kink"), substitute them into `--groups`. If they specified a top count, substitute into `--top`. Otherwise use the defaults above.

Wait for the command to finish — it takes 60–180 seconds.

When it completes:
- If the output contains `---SPLIT---`, post each part as a separate message.
- Otherwise post the output as-is.
- If the command exits non-zero or prints "Feed failed:", relay the error message to the user.

Do not summarise, reformat, or add anything to the output.
