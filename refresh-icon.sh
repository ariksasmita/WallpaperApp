#!/bin/bash

# Script to refresh macOS app icon cache for WallpaperApp

echo "🔄 Refreshing WallpaperApp icon cache..."

# Kill WallpaperApp if running
pkill WallpaperApp 2>/dev/null

# Touch the app to update modification time
touch ~/Applications/WallpaperApp.app

# Restart Dock
killall Dock

echo "✅ Icon cache refreshed!"
echo ""
echo "⚠️  If you still don't see the icon:"
echo "   1. Remove WallpaperApp from Dock (if present)"
echo "   2. Drag WallpaperApp from Applications to Dock"
echo "   3. Or restart your Mac for guaranteed refresh"
