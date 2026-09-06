import AppKit
import Foundation

let arguments = CommandLine.arguments
let defaultOutputPath = "NudgeList/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
let outputPath = arguments.dropFirst().first ?? defaultOutputPath
let outputURL = URL(fileURLWithPath: outputPath)

let width = 1024
let height = 1024

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 3,
    hasAlpha: false,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 24
) else {
    fputs("Unable to create bitmap.\n", stderr)
    exit(1)
}

guard let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fputs("Unable to create graphics context.\n", stderr)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphicsContext

let canvas = NSRect(x: 0, y: 0, width: width, height: height)
NSColor(calibratedRed: 0.10, green: 0.12, blue: 0.16, alpha: 1.0).setFill()
NSBezierPath(rect: canvas).fill()

let ringRect = NSRect(x: 202, y: 202, width: 620, height: 620)
let ring = NSBezierPath(ovalIn: ringRect)
ring.lineWidth = 54
NSColor.white.setStroke()
ring.stroke()

let check = NSBezierPath()
check.move(to: NSPoint(x: 340, y: 515))
check.line(to: NSPoint(x: 455, y: 395))
check.line(to: NSPoint(x: 690, y: 650))
check.lineWidth = 70
check.lineCapStyle = .round
check.lineJoinStyle = .round
NSColor.white.setStroke()
check.stroke()

NSGraphicsContext.restoreGraphicsState()

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Unable to encode PNG.\n", stderr)
    exit(1)
}

do {
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try pngData.write(to: outputURL, options: .atomic)
    print("Generated \(outputURL.path)")
} catch {
    fputs("Unable to write icon: \(error)\n", stderr)
    exit(1)
}
