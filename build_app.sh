#!/bin/bash
# Build the "Playlist Grabber" macOS app (Swift + AppKit).
set -e

APP="Playlist Grabber.app"
BIN="PlaylistGrabber" # binary name inside Contents/MacOS

cd "$(dirname "$0")"
APP_DIR="$PWD/dist/$APP"
# Compile to a stable temp location (avoids spaces-in-path issues)
TMP_BIN="$TMPDIR/pg_bin_$$"
swiftc -O macapp/main.swift -o "$TMP_BIN"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
mv "$TMP_BIN" "$APP_DIR/Contents/MacOS/$BIN"
cp scripts/fetch_playlist.py "$APP_DIR/Contents/Resources/fetch_playlist.py"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Playlist Grabber</string>
    <key>CFBundleDisplayName</key>
    <string>Playlist Grabber</string>
    <key>CFBundleIdentifier</key>
    <string>com.theikbhal.playlist-grabber</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>PlaylistGrabber</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
</dict>
</plist>
PLIST

echo "Built: $APP_DIR"
open "$APP_DIR"