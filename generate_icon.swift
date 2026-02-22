import AppKit

let size: CGFloat = 512
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

let ctx = NSGraphicsContext.current!.cgContext

// Background circle - blue gradient
let center = CGPoint(x: size/2, y: size/2)
let radius = size/2 - 20

// Shadow
ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 20, color: CGColor(gray: 0, alpha: 0.3))

// Outer circle - dark blue
ctx.setFillColor(CGColor(red: 0.15, green: 0.35, blue: 0.85, alpha: 1.0))
ctx.addEllipse(in: CGRect(x: 20, y: 20, width: size-40, height: size-40))
ctx.fillPath()

ctx.setShadow(offset: .zero, blur: 0, color: nil)

// Inner circle - slightly lighter
ctx.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0))
ctx.addEllipse(in: CGRect(x: 40, y: 40, width: size-80, height: size-80))
ctx.fillPath()

// Clock face - white circle
ctx.setFillColor(CGColor(red: 0.97, green: 0.97, blue: 1.0, alpha: 1.0))
ctx.addEllipse(in: CGRect(x: 70, y: 70, width: size-140, height: size-140))
ctx.fillPath()

// Hour markers
for i in 0..<12 {
    let angle = CGFloat(i) * .pi / 6 - .pi / 2
    let outerR = radius - 60
    let innerR = i % 3 == 0 ? radius - 90 : radius - 80
    let lineWidth: CGFloat = i % 3 == 0 ? 6 : 3

    let x1 = center.x + cos(angle) * innerR
    let y1 = center.y + sin(angle) * innerR
    let x2 = center.x + cos(angle) * outerR
    let y2 = center.y + sin(angle) * outerR

    ctx.setStrokeColor(CGColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0))
    ctx.setLineWidth(lineWidth)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: x1, y: y1))
    ctx.addLine(to: CGPoint(x: x2, y: y2))
    ctx.strokePath()
}

// Hour hand (pointing to ~10 o'clock position)
let hourAngle: CGFloat = -2.0 * .pi / 6 - .pi / 2
ctx.setStrokeColor(CGColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0))
ctx.setLineWidth(10)
ctx.setLineCap(.round)
ctx.move(to: center)
ctx.addLine(to: CGPoint(x: center.x + cos(hourAngle) * 110, y: center.y + sin(hourAngle) * 110))
ctx.strokePath()

// Minute hand (pointing to ~2 o'clock position)
let minAngle: CGFloat = 1.0 * .pi / 6 - .pi / 2
ctx.setLineWidth(6)
ctx.move(to: center)
ctx.addLine(to: CGPoint(x: center.x + cos(minAngle) * 155, y: center.y + sin(minAngle) * 155))
ctx.strokePath()

// Center dot
ctx.setFillColor(CGColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0))
ctx.addEllipse(in: CGRect(x: center.x-8, y: center.y-8, width: 16, height: 16))
ctx.fillPath()

// Second hand (red, pointing to ~8 seconds)
let secAngle: CGFloat = 8.0 * .pi / 30 - .pi / 2
ctx.setStrokeColor(CGColor(red: 0.9, green: 0.25, blue: 0.2, alpha: 1.0))
ctx.setLineWidth(2.5)
ctx.move(to: CGPoint(x: center.x - cos(secAngle) * 30, y: center.y - sin(secAngle) * 30))
ctx.addLine(to: CGPoint(x: center.x + cos(secAngle) * 165, y: center.y + sin(secAngle) * 165))
ctx.strokePath()

image.unlockFocus()

// Save as PNG
guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    print("Failed to generate image")
    exit(1)
}

let url = URL(fileURLWithPath: "icon_512.png")
try! png.write(to: url)
print("Icon saved to icon_512.png")
