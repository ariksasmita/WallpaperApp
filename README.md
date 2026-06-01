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

### Quitting

- Click the **🖼️ icon** in your menu bar → "Quit WallpaperApp"
- Or via Terminal: `pkill WallpaperApp`

### Restarting with new wallpaper

```bash
pkill WallpaperApp && open ~/Applications/WallpaperApp.app
```

## 🎨 Tips

- Use a high-resolution image that matches your screen resolution
- The image scales to fill (may crop if aspect ratios differ)
- Each monitor gets its own window with the same wallpaper
- If no image is found, shows a black screen

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
