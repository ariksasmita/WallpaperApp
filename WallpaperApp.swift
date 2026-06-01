import Cocoa
import UniformTypeIdentifiers

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
        
        // Set window level to be BELOW widgets and desktop icons
        // Use kCGDesktopWindowLevel to sit behind desktop icons/widgets
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
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
        statusItem = NSStatusBar.system.statusItem(withLength: 22)
        if let button = statusItem?.button {
            // Load icon from app bundle
            if let iconPath = Bundle.main.path(forResource: "menubar-icon", ofType: "png"),
               let icon = NSImage(contentsOfFile: iconPath) {
                icon.size = NSSize(width: 18, height: 18)
                button.image = icon
            } else {
                // Fallback to emoji if icon not found
                button.title = "🖼️"
            }
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Select Wallpaper Image...", action: #selector(selectWallpaper), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        
        let loginItemTitle = isLoginItemEnabled() ? "✓ Login at startup" : "Add to login items"
        menu.addItem(NSMenuItem(title: loginItemTitle, action: #selector(toggleLoginItem), keyEquivalent: "l"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit WallpaperApp", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func selectWallpaper() {
        // Activate app to bring file picker to front
        NSApp.setActivationPolicy(.regular)
        
        let panel = NSOpenPanel()
        panel.title = "Select Wallpaper Image"
        panel.message = "Choose an image to use as your wallpaper. It will be optimized and saved to ~/Pictures/wallpaper.png"
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.processSelectedImage(url)
            }
            
            // Return to background mode
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    func processSelectedImage(_ url: URL) {
        print("Processing selected image: \(url.path)")
        
        // Get screen resolution
        let screens = NSScreen.screens
        guard let mainScreen = screens.first else { return }
        
        let screenScale = mainScreen.backingScaleFactor
        let screenWidth = Int(mainScreen.frame.width * screenScale)
        let screenHeight = Int(mainScreen.frame.height * screenScale)
        
        print("Screen resolution: \(screenWidth)x\(screenHeight)")
        
        // Load the selected image
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let originalImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("Failed to load image")
            showAlert(title: "Error", message: "Failed to load the selected image.")
            return
        }
        
        let originalWidth = originalImage.width
        let originalHeight = originalImage.height
        
        print("Original image: \(originalWidth)x\(originalHeight)")
        
        // Calculate target dimensions
        let aspectRatio = CGFloat(originalWidth) / CGFloat(originalHeight)
        let screenAspectRatio = mainScreen.frame.width / mainScreen.frame.height
        
        var targetWidth = screenWidth
        var targetHeight = screenHeight
        
        if aspectRatio > screenAspectRatio {
            targetHeight = screenHeight
            targetWidth = Int(CGFloat(screenHeight) * aspectRatio)
        } else {
            targetWidth = screenWidth
            targetHeight = Int(CGFloat(screenWidth) / aspectRatio)
        }
        
        print("Target size: \(targetWidth)x\(targetHeight)")
        
        // Create optimized image
        guard let resizedImage = resizeImage(originalImage, to: CGSize(width: targetWidth, height: targetHeight)) else {
            print("Failed to resize image")
            showAlert(title: "Error", message: "Failed to resize the image.")
            return
        }
        
        // Save to ~/Pictures/wallpaper.png
        let picturesPath = "\(NSHomeDirectory())/Pictures"
        let outputPath = "\(picturesPath)/wallpaper.png"
        
        // Create Pictures directory if it doesn't exist
        try? FileManager.default.createDirectory(atPath: picturesPath, withIntermediateDirectories: true)
        
        // Backup existing wallpaper if it exists
        if FileManager.default.fileExists(atPath: outputPath) {
            let backupPath = "\(picturesPath)/wallpaper_backup.png"
            try? FileManager.default.removeItem(atPath: backupPath)
            try? FileManager.default.copyItem(atPath: outputPath, toPath: backupPath)
            print("Backup saved to: \(backupPath)")
        }
        
        // Save the optimized image
        guard let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outputPath) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            print("Failed to create image destination")
            showAlert(title: "Error", message: "Failed to save the image.")
            return
        }
        
        CGImageDestinationAddImage(destination, resizedImage, nil)
        
        if CGImageDestinationFinalize(destination) {
            print("✅ Wallpaper saved to: \(outputPath)")
            showAlert(title: "Success!", message: "Wallpaper has been optimized and saved to ~/Pictures/wallpaper.png\n\nPlease quit and restart WallpaperApp to see changes.")
        } else {
            print("Failed to finalize image")
            showAlert(title: "Error", message: "Failed to save the wallpaper.")
        }
    }
    
    func resizeImage(_ image: CGImage, to size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return context.makeImage()
    }
    
    func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
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
    
    func updateMenu() {
        if let menu = statusItem?.menu {
            menu.removeAllItems()
            
            menu.addItem(NSMenuItem(title: "Select Wallpaper Image...", action: #selector(selectWallpaper), keyEquivalent: "o"))
            menu.addItem(NSMenuItem.separator())
            
            let loginItemTitle = isLoginItemEnabled() ? "✓ Login at startup" : "Add to login items"
            menu.addItem(NSMenuItem(title: loginItemTitle, action: #selector(toggleLoginItem), keyEquivalent: "l"))
            
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
