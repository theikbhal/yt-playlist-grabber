#!/usr/bin/env python3
"""Fetch all video URLs + titles from a YouTube playlist using yt-dlp.

Usage:
    python3 youtube_playlist.py "PLAYLIST_URL" [--out FILE]

Examples:
    python3 youtube_playlist.py "https://www.youtube.com/playlist?list=PLrhtnEKV0NXrJioK7sIPVpq0wIqp6QMvB"
    python3 youtube_playlist.py "https://www.youtube.com/watch?v=-aK81TAWbEQ&list=PLrhtnEKV0NXrJioK7sIPVpq0wIqp6QMvB" --out videos.csv
"""
import argparse
import csv
import subprocess
import sys


def fetch_playlist(url):
    """Return list of (title, url) using yt-dlp in flat mode."""
    cmd = [
        "yt-dlp", "--flat-playlist", "--print", "%(title)s\t%(id)s", url,
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        print("yt-dlp failed:", proc.stderr, file=sys.stderr)
        sys.exit(1)
    videos = []
    for line in proc.stdout.splitlines():
        if "\t" not in line:
            continue
        title, vid = line.split("\t", 1)
        videos.append((title, f"https://www.youtube.com/watch?v={vid}"))
    return videos


def main():
    parser = argparse.ArgumentParser(description="Fetch YouTube playlist videos")
    parser.add_argument("url", help="YouTube playlist URL")
    parser.add_argument("--out", help="Output file (.md or .csv). Prints if omitted")
    args = parser.parse_args()

    videos = fetch_playlist(args.url)
    if not videos:
        print("No videos found. Check URL / network.")
        sys.exit(1)

    print(f"{len(videos)} videos fetched\n")
    for i, (title, url) in enumerate(videos, 1):
        line = f"{i:3}. {title}\n     {url}"
        print(line)

    if args.out:
        if args.out.endswith(".csv"):
            with open(args.out, "w", newline="") as f:
                writer = csv.writer(f)
                writer.writerow(["#", "title", "url"])
                writer.writerows((i, t, u) for i, (t, u) in enumerate(videos, 1))
            print(f"\nSaved CSV -> {args.out}")
        else:
            with open(args.out, "w") as f:
                for i, (title, url) in enumerate(videos, 1):
                    f.write(f"{i}. [{title}]({url})\n")
            print(f"\nSaved Markdown -> {args.out}")


if __name__ == "__main__":
    main()