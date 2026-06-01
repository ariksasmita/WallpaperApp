#!/bin/bash

# Build script for WallpaperApp

echo "🔨 Building WallpaperApp..."

# Kill any running instance
pkill -x WallpaperApp 2>/dev/null

# Create build directory
rm -rf build
mkdir -p build/WallpaperApp.app/Contents/MacOS
mkdir -p build/WallpaperApp.app/Contents/Resources

# Compile Swift code
echo "📦 Compiling Swift..."
swiftc -o build/WallpaperApp.app/Contents/MacOS/WallpaperApp \
    WallpaperApp.swift \
    -framework Cocoa \
    -O

# Copy Info.plist
echo "📝 Copying Info.plist..."
cp Info.plist build/WallpaperApp.app/Contents/

# Copy icon
echo "🎨 Copying app icon..."
cp WallpaperApp.icns build/WallpaperApp.app/Contents/Resources/AppIcon.icns

# Update Info.plist with icon reference
/usr/libexec/PlistBuddy -c "Add :CFBundleIconKey string AppIcon" build/WallpaperApp.app/Contents/Info.plist 2>/dev/null || true

# Make executable
chmod +x build/WallpaperApp.app/Contents/MacOS/WallpaperApp

# Sign the app
echo "🔐 Signing app..."
codesign --force --deep --sign - build/WallpaperApp.app

# Copy to ~/Applications
echo "📱 Installing to ~/Applications..."
rm -rf ~/Applications/WallpaperApp.app
cp -R build/WallpaperApp.app ~/Applications/WallpaperApp.app

echo "✅ Build complete!"
echo ""
echo "App location: ~/Applications/WallpaperApp.app"
echo ""
echo "📸 To add your wallpaper:"
echo "   Place your image as wallpaper.png/jpg/jpeg in ~/Pictures/"
echo ""
echo "🚀 To run:"
echo "   open ~/Applications/WallpaperApp.app"
echo ""
echo "🚫 To quit:"
echo "   Click the 🖼️ icon in menu bar → Quit WallpaperApp"
echo "   Or run: pkill WallpaperApp"
