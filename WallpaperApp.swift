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
        
        // Load and display wallpaper
        if let imagePath = findWallpaperPath() {
            if let image = NSImage(contentsOfFile: imagePath) {
                // Create image view with proper layer backing for efficiency
                let imageView = NSImageView(frame: NSRect(origin: .zero, size: screenFrame.size))
                imageView.imageScaling = .scaleAxesIndependently
                imageView.image = image
                imageView.wantsLayer = true
                imageView.layer?.contentsGravity = .resizeAspectFill
                
                window.contentView = imageView
                
                // Enable layer backing for the window (more efficient)
                window.contentView?.wantsLayer = true
                window.contentView?.layer?.contentsGravity = .resizeAspectFill
            }
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
