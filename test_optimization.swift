import Cocoa

// Test image loading and optimization
let imagePath = "\(NSHomeDirectory())/Pictures/wallpaper.png"

if let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: imagePath) as CFURL, nil),
   let originalImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
    
    let originalWidth = originalImage.width
    let originalHeight = originalImage.height
    let originalPixels = originalWidth * originalHeight
    let originalMB = Double(originalPixels * 4) / 1024 / 1024
    
    print("Original image: \(originalWidth) x \(originalHeight) = ~\(String(format: "%.1f", originalMB)) MB")
    
    let screenSize = CGSize(width: 3024, height: 1964)
    let screenScale = 2.0
    let targetWidth = Int(screenSize.width * screenScale)
    let targetHeight = Int(screenSize.height * screenScale)
    let targetPixels = targetWidth * targetHeight
    let targetMB = Double(targetPixels * 4) / 1024 / 1024
    
    print("Target size: \(targetWidth) x \(targetHeight) = ~\(String(format: "%.1f", targetMB)) MB")
    
    let shouldResize = originalWidth > targetWidth * 3 / 2 || originalHeight > targetHeight * 3 / 2
    print("Should resize: \(shouldResize)")
    
    let imageAspect = CGFloat(originalWidth) / CGFloat(originalHeight)
    let screenAspect = screenSize.width / screenSize.height
    
    var finalWidth = targetWidth
    var finalHeight = targetHeight
    
    if imageAspect > screenAspect {
        finalHeight = targetHeight
        finalWidth = Int(CGFloat(targetHeight) * imageAspect)
    } else {
        finalWidth = targetWidth
        finalHeight = Int(CGFloat(targetWidth) / imageAspect)
    }
    
    let finalPixels = finalWidth * finalHeight
    let finalMB = Double(finalPixels * 4) / 1024 / 1024
    
    print("Optimized to: \(finalWidth) x \(finalHeight) = ~\(String(format: "%.1f", finalMB)) MB")
    print("Memory savings: ~\(String(format: "%.1f", originalMB - finalMB)) MB (\(String(format: "%.0f", (originalMB - finalMB) / originalMB * 100))%)")
}
