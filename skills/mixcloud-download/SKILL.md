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

## 4. Check metadata

```bash
ffprobe -v quiet -print_format json -show_format "/marvin/Music & Audio/DJ Mixes/<Title>.mp3"
```

Show the user the current tags and ask them to confirm or edit. Key tags to check:
- `title` — the mix name
- `artist` — the DJ/artist name
- `album_artist` — should match `artist`
- `album` — event or series name (optional)
- `date` — year

## 5. Fix metadata if needed

If the user wants changes, use ffmpeg to rewrite tags without re-encoding:

```bash
ffmpeg -i "<input.mp3>" -codec:a copy \
  -metadata title="..." \
  -metadata artist="..." \
  -metadata album_artist="..." \
  -metadata album="..." \
  -metadata date="..." \
  "<input.tmp.mp3>"
mv "<input.tmp.mp3>" "<input.mp3>"
```

Always ensure `artist` and `album_artist` are set and match each other.

## 6. Confirm

Report back:
- Final filename on NAS
- Duration and file size
- Final metadata tags
