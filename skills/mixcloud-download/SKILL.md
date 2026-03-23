---
name: mixcloud-download
description: Download a Mixcloud mix, convert to MP3, move to NAS DJ Mixes folder, and verify metadata
---

You are downloading a mix from Mixcloud and adding it to the NAS music library.

The user will provide a Mixcloud URL. Follow these steps:

## 1. Download with yt-dlp

```bash
/home/scon/.local/bin/yt-dlp --no-playlist -x "<URL>" -o "%(title)s.%(ext)s"
```

Run this in the background (it may take several minutes). The output will be an `.m4a` file in the
current directory. Note the exact filename from the yt-dlp output.

## 2. Convert to MP3

Once the download completes:

```bash
ffmpeg -i "<input.m4a>" -codec:a libmp3lame -q:a 2 "<Title>.mp3"
```

Use `-q:a 2` for high quality VBR. The output filename should be clean (no yt-dlp ID suffix):
e.g. `Artist Name - Mix Title.mp3`

## 3. Move to NAS

```bash
mv "<Title>.mp3" "/marvin/Music & Audio/DJ Mixes/<Title>.mp3"
```

Delete the original `.m4a` after confirming the MP3 is in place.

## 4. Set metadata

Read the existing tags with ffprobe, then rewrite them to match this structure — inferring values
from the Mixcloud page title, URL, and uploader where possible:

| Tag | Value | Source |
|-----|-------|--------|
| `title` | The mix name only (e.g. "Sparky's Magic Piano Mix") | Right-hand part of the page title, after the event name |
| `album` | The event or series name (e.g. "Forget the Restival") | Left-hand part of the page title, or event context |
| `artist` | The DJ's real name or stage name | Mixcloud uploader name or page metadata |
| `album_artist` | Same as `artist` — always | Must match `artist` exactly |
| `date` | Year of the mix | Mixcloud upload date or event year |

Use ffmpeg to write all tags without re-encoding:

```bash
ffmpeg -i "<input.mp3>" -codec:a copy \
  -metadata title="<mix name>" \
  -metadata album="<event/series name>" \
  -metadata artist="<DJ name>" \
  -metadata album_artist="<DJ name>" \
  -metadata date="<year>" \
  "<input.tmp.mp3>"
mv "<input.tmp.mp3>" "<input.mp3>"
```

Show the user the proposed tags before writing and ask for confirmation or corrections.

## 6. Confirm

Report back:
- Final filename on NAS
- Duration and file size
- Final metadata tags
