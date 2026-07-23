import AppKit

private enum Icon {
  static let canvasSize = NSSize(width: 1024, height: 1024)
  static let bodyRect = NSRect(x: 72, y: 72, width: 880, height: 880)
  static let cornerRadius: CGFloat = 220
}

guard CommandLine.arguments.count == 2 else {
  fputs("Usage: swift tool/generate_macos_icon.swift <output.png>\n", stderr)
  exit(64)
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

NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.34)
shadow.shadowBlurRadius = 38
shadow.shadowOffset = NSSize(width: 0, height: -18)
shadow.set()

let bodyPath = NSBezierPath(
  roundedRect: Icon.bodyRect,
  xRadius: Icon.cornerRadius,
  yRadius: Icon.cornerRadius
)
NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.13, alpha: 1).setFill()
bodyPath.fill()
NSGraphicsContext.restoreGraphicsState()

NSGraphicsContext.saveGraphicsState()
bodyPath.addClip()
let bodyGradient = NSGradient(colors: [
  NSColor(calibratedRed: 0.16, green: 0.24, blue: 0.26, alpha: 1),
  NSColor(calibratedRed: 0.06, green: 0.10, blue: 0.11, alpha: 1),
])!
bodyGradient.draw(in: Icon.bodyRect, angle: -56)

let highlightGradient = NSGradient(colors: [
  NSColor.white.withAlphaComponent(0.16),
  NSColor.white.withAlphaComponent(0),
])!
highlightGradient.draw(
  in: NSRect(x: 72, y: 510, width: 880, height: 442),
  angle: -90
)

let glowGradient = NSGradient(colors: [
  NSColor(calibratedRed: 0.13, green: 0.72, blue: 0.65, alpha: 0.22),
  NSColor(calibratedRed: 0.13, green: 0.72, blue: 0.65, alpha: 0),
])!
glowGradient.draw(
  fromCenter: NSPoint(x: 350, y: 674),
  radius: 0,
  toCenter: NSPoint(x: 350, y: 674),
  radius: 300,
  options: [.drawsBeforeStartingLocation, .drawsAfterEndingLocation]
)
NSGraphicsContext.restoreGraphicsState()

NSColor.white.withAlphaComponent(0.22).setStroke()
bodyPath.lineWidth = 3
bodyPath.stroke()

let teal = NSColor(calibratedRed: 0.13, green: 0.72, blue: 0.65, alpha: 1)
let mutedWhite = NSColor.white.withAlphaComponent(0.58)
let rows: [(centerY: CGFloat, checked: Bool, lineWidth: CGFloat)] = [
  (674, true, 326),
  (512, false, 270),
  (350, false, 306),
]

for row in rows {
  let checkboxRect = NSRect(x: 246, y: row.centerY - 42, width: 84, height: 84)
  let checkboxPath = NSBezierPath(
    roundedRect: checkboxRect,
    xRadius: 25,
    yRadius: 25
  )

  if row.checked {
    teal.setFill()
    checkboxPath.fill()

    let checkmark = NSBezierPath()
    checkmark.move(to: NSPoint(x: 266, y: row.centerY))
    checkmark.line(to: NSPoint(x: 282, y: row.centerY - 17))
    checkmark.line(to: NSPoint(x: 313, y: row.centerY + 20))
    checkmark.lineWidth = 10
    checkmark.lineCapStyle = .round
    checkmark.lineJoinStyle = .round
    NSColor.white.setStroke()
    checkmark.stroke()
  } else {
    mutedWhite.setStroke()
    checkboxPath.lineWidth = 6
    checkboxPath.stroke()
  }

  let lineRect = NSRect(
    x: 388,
    y: row.centerY - 12,
    width: row.lineWidth,
    height: 24
  )
  let linePath = NSBezierPath(
    roundedRect: lineRect,
    xRadius: 12,
    yRadius: 12
  )
  (row.checked ? NSColor.white.withAlphaComponent(0.92) : mutedWhite).setFill()
  linePath.fill()
}

NSGraphicsContext.restoreGraphicsState()

guard
  let pngData = bitmap.representation(using: .png, properties: [:])
else {
  fputs("Could not encode the icon as PNG.\n", stderr)
  exit(1)
}

try pngData.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
