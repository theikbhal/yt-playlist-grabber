# YouTube Playlist Grabber 🎬

Fetch **all video URLs + titles** from any YouTube playlist into the terminal, CSV, or Markdown.

Powered by `yt-dlp` under the hood.

## Why it exists

- Pull every video from a playlist in seconds (no copy-pasting links).
- Export the list as CSV / Markdown for docs, blogs, or tracking.
- CLI + native macOS app.

## Requirements

- Python 3.8+
- `yt-dlp` (`brew install yt-dlp`)

## Usage

```bash
# Print all videos to terminal
python3 scripts/fetch_playlist.py "URL"

# Save as CSV
python3 scripts/fetch_playlist.py "URL" --out videos.csv

# Save as Markdown
python3 scripts/fetch_playlist.py "URL" --out videos.md
```

### Example

```bash
python3 scripts/fetch_playlist.py "https://www.youtube.com/watch?v=-aK81TAWbEQ&list=PLrhtnEKV0NXrJioK7sIPVpq0wIqp6QMvB"
```

Output:

```
100 videos fetched

  1. UPSC Topper Samiksha Dwivedi (AIR 56) Live Interaction l Toppers Talk l UPSC TIME
     https://www.youtube.com/watch?v=-aK81TAWbEQ
  2. UPSC Topper Shubhra Roy (AIR 147) Live Interaction l Toppers Talk l UPSC TIME
     https://www.youtube.com/watch?v=mr-CC5S_EDI
  ...
```

## macOS App

Double-click `Playlist Grabber.app` (or run `make app`) for a native GUI:

1. Paste a playlist URL
2. Click **Fetch**
3. Copy results or export CSV / Markdown

Built with Swift + AppKit.

## Development

| Command | What it does |
|---------|--------------|
| `make app` | Rebuilds `Playlist Grabber.app` |
| `make run` | Runs the Python CLI |
| `scripts/fetch_playlist.py` | Core logic (yt-dlp wrapper) |

## Repo

https://github.com/theikbhal/yt-playlist-grabber