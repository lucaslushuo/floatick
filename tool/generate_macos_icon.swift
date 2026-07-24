import AppKit

private enum Icon {
  static let canvasSize = NSSize(width: 1024, height: 1024)
  static let sourcePath = "tool/floatick_app_icon.svg"
}

guard CommandLine.arguments.count == 2 else {
  fputs("Usage: swift tool/generate_macos_icon.swift <output.png>\n", stderr)
  exit(64)
}

let sourceURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  .appendingPathComponent(Icon.sourcePath)

guard let sourceImage = NSImage(contentsOf: sourceURL) else {
  fputs("Could not load \(Icon.sourcePath).\n", stderr)
  exit(1)
}

guard
  let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(Icon.canvasSize.width),
    pixelsHigh: Int(Icon.canvasSize.height),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  ),
  let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap)
else {
  fputs("Could not create an icon graphics context.\n", stderr)
  exit(1)
}

bitmap.size = Icon.canvasSize
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphicsContext
guard let context = NSGraphicsContext.current?.cgContext else {
  fputs("Could not activate the icon graphics context.\n", stderr)
  exit(1)
}

context.setShouldAntialias(true)
context.setAllowsAntialiasing(true)

sourceImage.draw(
  in: NSRect(origin: .zero, size: Icon.canvasSize),
  from: .zero,
  operation: .copy,
  fraction: 1
)

NSGraphicsContext.restoreGraphicsState()

guard
  let pngData = bitmap.representation(using: .png, properties: [:])
else {
  fputs("Could not encode the icon as PNG.\n", stderr)
  exit(1)
}

try pngData.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
