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
        menu.addItem(NSMenuItem(title: "Quit WallpaperApp", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
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
