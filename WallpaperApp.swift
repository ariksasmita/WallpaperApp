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
        
        // Load and scale wallpaper to FILL the screen (may crop)
        if let imagePath = findWallpaperPath(), let image = NSImage(contentsOfFile: imagePath) {
            let imageView = NSImageView(frame: window.contentView!.bounds)
            
            // Scale to fill - will crop if aspect ratios don't match
            imageView.imageScaling = .scaleAxesIndependently
            imageView.image = image
            imageView.autoresizingMask = [.width, .height]
            
            // Center the image
            if let view = window.contentView {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(imageView)
                
                // Constrain to fill completely
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: view.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
            
            window.contentView = imageView
            window.backgroundColor = NSColor.black
        }
        
        window.makeKeyAndOrderFront(nil)
        windows.append(window)
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
        
        // Add login item status and toggle
        let loginItemTitle = isLoginItemEnabled() ? "✓ Login at startup" : "Add to login items"
        menu.addItem(NSMenuItem(title: loginItemTitle, action: #selector(toggleLoginItem), keyEquivalent: "l"))
        
        menu.addItem(NSMenuItem.separator())
        
        // Add "Reload Wallpaper" option
        menu.addItem(NSMenuItem(title: "Reload Wallpaper", action: #selector(reloadWallpaper), keyEquivalent: "r"))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit WallpaperApp", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    func isLoginItemEnabled() -> Bool {
        // Check if we're in login items by searching for our app path
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
            // Remove from login items
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
            // Add to login items
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
        // Close all windows and recreate them
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
        // Refresh the menu to show updated login item status
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
        // Clean up status bar
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
