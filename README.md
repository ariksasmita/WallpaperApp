# WallpaperApp

<img src="image-frame.svg" width="100" height="100" alt="WallpaperApp Icon">

> **A simple macOS app that displays a full-screen image behind all other windows.**
>
> Perfect for managed Macs where you can't change the desktop wallpaper.

## 📖 About

**WallpaperApp** was born out of frustration with managed MacBooks that lock down the desktop wallpaper setting. This lightweight background app creates a full-screen window that sits behind all other applications, effectively "faking" a custom wallpaper.

### Why WallpaperApp?

- 🏢 **Corporate Macs** often restrict wallpaper changes via MDM
- 🎨 **Personalization** shouldn't be limited by IT policy
- 🔒 **Privacy** - runs locally, no cloud, no tracking
- 💡 **Simple** - just build, add your image, and run

### How It Works

Instead of changing the actual desktop wallpaper (which is often locked), WallpaperApp:

1. Creates a borderless full-screen window on **each connected monitor**
2. Sets the window level **below all other apps** but **above the desktop**
3. Displays your chosen image with **fill scaling** (covers entire screen)
4. Stays out of your way - **clicks pass through** to other apps
5. Lives in the **menu bar** (🖼️) for easy quitting

### Tech Stack

- **Language:** Swift
- **Framework:** Cocoa (AppKit)
- **Build:** Native Swift compiler
- **Icon:** Custom SVG → .icns conversion

## 🎯 Features

- ✅ Full-screen wallpaper behind all other apps
- ✅ Multi-monitor support (shows on all connected screens)
- ✅ Fill scaling (wallpaper fills screen completely)
- ✅ Clicks pass through (doesn't interfere with other apps)
- ✅ Menu bar icon for easy quitting
- ✅ No dock icon (runs as background app)
- ✅ Supports PNG, JPEG, JPG formats

## 🚀 Quick Start

1. **Build the app:**
   ```bash
   ./build.sh
   ```

2. **Add your wallpaper:**
   ```bash
   cp /path/to/your/wallpaper.jpg ~/Pictures/wallpaper.jpg
   ```

3. **Run it:**
   ```bash
   open ~/Applications/WallpaperApp.app
   ```

## 📦 Building

The build script:
- Compiles the Swift code
- Creates the app bundle
- Adds the custom icon
- Signs the app for macOS
- Installs to `~/Applications/WallpaperApp.app`

```bash
./build.sh
```

## 🖼️ Adding Your Wallpaper

Place your image in `~/Pictures/` with one of these names:

- `wallpaper.jpg` (recommended for photos)
- `wallpaper.jpeg`
- `wallpaper.png`

The app searches in order and uses the first one found.

## 🎮 Usage

### Running

```bash
open ~/Applications/WallpaperApp.app
```

### Menu Bar Options

Click the **🖼️ icon** in your menu bar to access:

- **Select Wallpaper Image...** (⌘+O) - Open file picker to choose and auto-optimize a new wallpaper
- **Add to login items** / **✓ Login at startup** - Toggle auto-start on login
- **Quit WallpaperApp** (⌘+Q) - Close the app

### Selecting Wallpaper via Menu

The easiest way to set your wallpaper:

1. Click **🖼️** → **Select Wallpaper Image...**
2. Choose any image (JPG, PNG, etc.)
3. The app will:
   - Detect your screen resolution
   - Optimize the image to match
   - Save it to `~/Pictures/wallpaper.png`
   - Create a backup of your old wallpaper
   - Automatically reload the wallpaper

### Quitting

- Click the **🖼️ icon** → "Quit WallpaperApp"
- Or via Terminal: `pkill WallpaperApp`

### After selecting a new wallpaper

Quit and restart the app:

```bash
pkill WallpaperApp && open ~/Applications/WallpaperApp.app
```

## 🎨 Tips

- Use a high-resolution image that matches your screen resolution
- The image scales to fill (may crop if aspect ratios differ)
- Each monitor gets its own window with the same wallpaper
- If no image is found, shows a black screen

### Image Optimization for Lower Memory Usage

**Memory usage depends on your image resolution!**

- **Optimized image** (matches screen): ~110-180 MB
- **Large image** (2x screen): ~340 MB
- **Very large image** (4K+): 500+ MB

To optimize your wallpaper:

```bash
# Automatic optimization (included in repo)
./optimize-wallpaper.sh ~/Pictures/wallpaper.jpg

# Or manually with sips (built-in macOS tool)
sips -z 1920 1080 ~/Pictures/wallpaper.jpg --out ~/Pictures/wallpaper_optimized.jpg
```

## 💻 Resource Usage

**With optimized image (recommended):**
- **Memory:** ~110-180 MB (~0.5% of 24GB RAM)
- **CPU:** 0.0% when idle

**With large image:**
- **Memory:** ~340 MB (~1.4% of 24GB RAM)
- **CPU:** 0.0% when idle

The app uses direct CALayer rendering and ImageIO for efficient image loading with on-the-fly downsampling.

## 🔄 Auto-Start on Login

To automatically start on login:

1. **System Settings** → **General** → **Login Items**
2. Click **+** button
3. Navigate to `~/Applications/WallpaperApp.app`
4. Add it

Your custom wallpaper will appear every time you log in! 🎨

## 🛠️ Development

### Requirements

- macOS 10.15+
- Xcode Command Line Tools (for Swift compiler)

### Project Structure

```
WallpaperApp/
├── WallpaperApp.swift    # Main app code
├── Info.plist            # App configuration
├── WallpaperApp.icns     # App icon
├── image-frame.svg       # Icon source
├── build.sh              # Build script
├── .gitignore
└── README.md
```

### Icon Customization

To change the app icon:

1. Replace `image-frame.svg` with your own SVG
2. Run the build script
3. The icon will be automatically converted and applied

## 📝 License

MIT License - feel free to use and modify!

## 🙏 Acknowledgments

- Icon: [image-frame](https://www.svgrepo.com/svg/532476/image-frame) from SVG Repo

---

Made with ❤️ for managed Macs everywhere
