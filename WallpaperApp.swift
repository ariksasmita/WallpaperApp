import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a window for EACH screen
        let screens = NSScreen.screens
        for screen in screens {
            createWindow(for: screen)
        }
        
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()
    }
    
    func createWindow(for screen: NSScreen) {
        let screenFrame = screen.frame
        let screenSize = screenFrame.size
        
        // Create fullscreen window for this screen
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Set window level to be behind everything
        window.level = NSWindow.Level(rawValue: -20)
        window.isOpaque = true
        window.backgroundColor = NSColor.black
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces]
        
        // Load and display wallpaper
        if let imagePath = findWallpaperPath() {
            if let image = loadOptimizedImage(for: imagePath, screenSize: screenSize, scale: screen.backingScaleFactor) {
                let contentView = NSView(frame: NSRect(origin: .zero, size: screenSize))
                contentView.wantsLayer = true
                
                let imageLayer = CALayer()
                imageLayer.frame = contentView.bounds
                imageLayer.contents = image
                imageLayer.contentsGravity = .resizeAspectFill
                
                contentView.layer = imageLayer
                window.contentView = contentView
            }
        }
        
        window.makeKeyAndOrderFront(nil)
        windows.append(window)
    }
    
    func loadOptimizedImage(for path: String, screenSize: CGSize, scale: CGFloat) -> CGImage? {
        let url = URL(fileURLWithPath: path)
        
        // Calculate max dimensions (with 2x buffer for retina)
        let maxWidth = Int(screenSize.width * scale * 1.5)
        let maxHeight = Int(screenSize.height * scale * 1.5)
        
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        // Get original image dimensions
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
            return nil
        }
        
        let originalWidth = properties[kCGImagePropertyPixelWidth] as? Int ?? 0
        let originalHeight = properties[kCGImagePropertyPixelHeight] as? Int ?? 0
        
        // Calculate target dimensions maintaining aspect ratio
        let aspectRatio = CGFloat(originalWidth) / CGFloat(originalHeight)
        let screenAspectRatio = screenSize.width / screenSize.height
        
        var targetWidth = maxWidth
        var targetHeight = maxHeight
        
        if aspectRatio > screenAspectRatio {
            // Image is wider - fit to height
            targetHeight = maxHeight
            targetWidth = Int(CGFloat(maxHeight) * aspectRatio)
        } else {
            // Image is taller - fit to width
            targetWidth = maxWidth
            targetHeight = Int(CGFloat(maxWidth) / aspectRatio)
        }
        
        // Only downsample, never upsample
        targetWidth = min(targetWidth, originalWidth)
        targetHeight = min(targetHeight, originalHeight)
        
        // Decode with target size using ImageIO for efficient loading
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(targetWidth, targetHeight)
        ]
        
        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    }
    
    func findWallpaperPath() -> String? {
        let extensions = ["jpg", "jpeg", "png", "JPG", "JPEG", "PNG"]
        let basePath = "\(NSHomeDirectory())/Pictures/wallpaper"
        
        for ext in extensions {
            let path = "\(basePath).\(ext)"
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: 40)
        if let button = statusItem?.button {
            button.title = "🖼️"
        }
        
        let menu = NSMenu()
        
        let loginItemTitle = isLoginItemEnabled() ? "✓ Login at startup" : "Add to login items"
        menu.addItem(NSMenuItem(title: loginItemTitle, action: #selector(toggleLoginItem), keyEquivalent: "l"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Reload Wallpaper", action: #selector(reloadWallpaper), keyEquivalent: "r"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit WallpaperApp", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    func isLoginItemEnabled() -> Bool {
        let appPath = Bundle.main.bundleURL.path
        let script = """
        tell application "System Events"
            set loginItems to every login item
            repeat with item in loginItems
                if path of item is "\(appPath)" then
                    return "true"
                end if
            end repeat
            return "false"
        end tell
        """
        
        if let scriptObject = NSAppleScript(source: script) {
            var errorInfo: NSDictionary?
            let result = scriptObject.executeAndReturnError(&errorInfo)
            
            if let resultString = result.stringValue {
                return resultString == "true"
            }
        }
        
        return false
    }
    
    @objc func toggleLoginItem() {
        let appPath = Bundle.main.bundleURL.path
        
        if isLoginItemEnabled() {
            let script = """
            tell application "System Events"
                set loginItems to every login item
                repeat with item in loginItems
                    if path of item is "\(appPath)" then
                        delete item
                        return "removed"
                    end if
                end repeat
            end tell
            """
            
            if let scriptObject = NSAppleScript(source: script) {
                var errorInfo: NSDictionary?
                scriptObject.executeAndReturnError(&errorInfo)
            }
            
            print("Removed from login items")
        } else {
            let script = """
            tell application "System Events"
                make login item at end with properties {path:"\(appPath)", hidden:false}
            end tell
            """
            
            if let scriptObject = NSAppleScript(source: script) {
                var errorInfo: NSDictionary?
                scriptObject.executeAndReturnError(&errorInfo)
                
                if let error = errorInfo {
                    print("Error adding to login items: \(error)")
                } else {
                    print("Added to login items")
                }
            }
        }
        
        updateMenu()
    }
    
    @objc func reloadWallpaper() {
        for window in windows {
            window.close()
        }
        windows.removeAll()
        
        let screens = NSScreen.screens
        for screen in screens {
            createWindow(for: screen)
        }
    }
    
    func updateMenu() {
        if let menu = statusItem?.menu {
            menu.removeAllItems()
            
            let loginItemTitle = isLoginItemEnabled() ? "✓ Login at startup" : "Add to login items"
            menu.addItem(NSMenuItem(title: loginItemTitle, action: #selector(toggleLoginItem), keyEquivalent: "l"))
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Reload Wallpaper", action: #selector(reloadWallpaper), keyEquivalent: "r"))
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit WallpaperApp", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
