import Foundation
import CoreGraphics

// Vector artwork for the OS launch screen. No text or runtime animation.
let directory = CommandLine.arguments[1]
let brand = CGColor(red: 1, green: 88/255, blue: 87/255, alpha: 1)
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(red: r, green: g, blue: b, alpha: a) }
for dark in [false, true] {
    let url = URL(fileURLWithPath: directory).appendingPathComponent(dark ? "launch-dark.pdf" : "launch-light.pdf")
    var box = CGRect(x: 0, y: 0, width: 320, height: 360)
    let context = CGContext(url as CFURL, mediaBox: &box, nil)!
    context.beginPDFPage(nil)
    let space = CGColorSpaceCreateDeviceRGB()
    let background = dark ? color(0.125, 0.075, 0.098) : color(1, 0.965, 0.957)
    context.setFillColor(background); context.fill(box)
    let glow = CGGradient(colorsSpace: space, colors: [dark ? color(0.34, 0.13, 0.16) : color(1, 0.82, 0.80), background] as CFArray, locations: [0, 1])!
    context.drawRadialGradient(glow, startCenter: CGPoint(x: 160, y: 167), startRadius: 14, endCenter: CGPoint(x: 160, y: 167), endRadius: 156, options: [])

    // A coral disc behind the translucent panel provides the brand color.
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -8), blur: 23, color: color(0.8, 0.16, 0.2, 0.18))
    context.setFillColor(brand)
    context.fillEllipse(in: CGRect(x: 79, y: 135, width: 157, height: 157))
    context.restoreGState()

    let tile = CGPath(roundedRect: CGRect(x: 66, y: 73, width: 188, height: 212), cornerWidth: 48, cornerHeight: 48, transform: nil)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: color(0.25, 0.03, 0.08, dark ? 0.35 : 0.13))
    context.addPath(tile)
    context.setFillColor(dark ? color(0.4, 0.24, 0.27, 0.65) : color(1, 0.99, 0.98, 0.68))
    context.fillPath()
    context.restoreGState()
    context.saveGState()
    context.addPath(tile); context.clip()
    context.setAlpha(0.23)
    let glass = CGGradient(colorsSpace: space, colors: [color(1,1,1), color(1,0.9,0.89), color(1,0.78,0.77)] as CFArray, locations: [0,0.55,1])!
    context.drawLinearGradient(glass, start: CGPoint(x: 82, y: 282), end: CGPoint(x: 240, y: 75), options: [])
    context.restoreGState()
    context.addPath(tile); context.setLineWidth(1.4); context.setStrokeColor(color(1,1,1,dark ? 0.55 : 0.88)); context.strokePath()

    // Discreet lower rim reflection.
    context.setStrokeColor(color(1,1,1,0.55)); context.setLineWidth(2)
    context.move(to: CGPoint(x: 112, y: 87)); context.addLine(to: CGPoint(x: 203, y: 87)); context.strokePath()
    context.endPDFPage(); context.closePDF()
}
