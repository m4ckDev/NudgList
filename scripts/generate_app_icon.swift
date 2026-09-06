import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let arguments = CommandLine.arguments
let defaultOutputPath = "NudgeList/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
let outputPath = arguments.dropFirst().first ?? defaultOutputPath
let outputURL = URL(fileURLWithPath: outputPath)

let width = 1024
let height = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

guard let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: bitmapInfo
) else {
    fputs("Unable to create Core Graphics context.\n", stderr)
    exit(1)
}

context.setFillColor(CGColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1.0))
context.fill(CGRect(x: 0, y: 0, width: width, height: height))

context.setStrokeColor(CGColor(gray: 1.0, alpha: 1.0))
context.setLineWidth(54)
context.strokeEllipse(in: CGRect(x: 202, y: 202, width: 620, height: 620))

context.setLineWidth(70)
context.setLineCap(.round)
context.setLineJoin(.round)
context.beginPath()
context.move(to: CGPoint(x: 340, y: 515))
context.addLine(to: CGPoint(x: 455, y: 395))
context.addLine(to: CGPoint(x: 690, y: 650))
context.strokePath()

guard let image = context.makeImage() else {
    fputs("Unable to create icon image.\n", stderr)
    exit(1)
}

do {
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
} catch {
    fputs("Unable to create icon directory: \(error)\n", stderr)
    exit(1)
}

guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
) else {
    fputs("Unable to create PNG destination.\n", stderr)
    exit(1)
}

CGImageDestinationAddImage(destination, image, nil)

guard CGImageDestinationFinalize(destination) else {
    fputs("Unable to encode PNG.\n", stderr)
    exit(1)
}

print("Generated \(outputURL.path)")
