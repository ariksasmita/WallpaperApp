#!/bin/bash

# Wallpaper image optimization script for WallpaperApp
# Optimizes wallpaper images to match screen resolution for lower memory usage

echo "🖼️  WallpaperApp Image Optimizer"
echo ""

# Check if image path is provided
if [ -z "$1" ]; then
    echo "Usage: ./optimize-wallpaper.sh <path-to-image>"
    echo ""
    echo "Example: ./optimize-wallpaper.sh ~/Pictures/my-wallpaper.jpg"
    echo ""
    echo "This will:"
    echo "1. Detect your screen resolution"
    echo "2. Resize the image to match (maintaining aspect ratio)"
    echo "3. Replace the original with optimized version"
    echo ""
    exit 1
fi

IMAGE_PATH="$1"

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ Error: File not found: $IMAGE_PATH"
    exit 1
fi

# Get screen resolution
echo "📺 Detecting screen resolution..."
SCREEN_WIDTH=$(system_profiler SPDisplaysDataType | grep "Resolution" | head -1 | grep -oE "[0-9]+ x [0-9]+" | cut -d' ' -f1)
SCREEN_HEIGHT=$(system_profiler SPDisplaysDataType | grep "Resolution" | head -1 | grep -oE "[0-9]+ x [0-9]+" | cut -d' ' -f3)

if [ -z "$SCREEN_WIDTH" ] || [ -z "$SCREEN_HEIGHT" ]; then
    echo "⚠️  Could not detect screen resolution, using default 1920x1080"
    SCREEN_WIDTH=1920
    SCREEN_HEIGHT=1080
fi

echo "   Target resolution: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"

# Backup original
BACKUP_PATH="${IMAGE_PATH}.backup"
echo "💾 Creating backup: $BACKUP_PATH"
cp "$IMAGE_PATH" "$BACKUP_PATH"

# Get file extension
EXT="${IMAGE_PATH##*.}"

# Create temp file
TEMP_PATH="${IMAGE_PATH}.tmp.${EXT}"

# Optimize image
echo "🔧 Optimizing image..."
sips -z "$SCREEN_WIDTH" "$SCREEN_HEIGHT" "$IMAGE_PATH" --out "$TEMP_PATH" > /dev/null 2>&1

# Get file sizes
ORIGINAL_SIZE=$(du -h "$IMAGE_PATH" | cut -f1)
OPTIMIZED_SIZE=$(du -h "$TEMP_PATH" | cut -f1)

# Replace original
mv "$TEMP_PATH" "$IMAGE_PATH"

echo ""
echo "✅ Optimization complete!"
echo "   Original size: $ORIGINAL_SIZE"
echo "   Optimized size: $OPTIMIZED_SIZE"
echo "   Backup saved at: $BACKUP_PATH"
echo ""
echo "🚀 Reload WallpaperApp to see the memory savings:"
echo "   Click 🖼️ → Reload Wallpaper"
echo "   Or: pkill WallpaperApp && open ~/Applications/WallpaperApp.app"
