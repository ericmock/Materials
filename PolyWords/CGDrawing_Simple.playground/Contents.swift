import Cocoa
import XCPlayground

func DrawImageInCGContext(_ size: CGSize, _ drawFunc: (_ context: CGContext) -> ()) -> NSImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
	let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
	let context = CGContext(
		data: nil,
		width: Int(size.width),
		height: Int(size.height),
		bitsPerComponent: 8,
		bytesPerRow: 0,
		space: colorSpace,
		bitmapInfo: bitmapInfo.rawValue)
    
	drawFunc(context!)
    
	let image = context!.makeImage()!
	return NSImage(cgImage: image, size: size)
}

let image = DrawImageInCGContext(CGSize(width: 512, height: 512)) { (context) -> () in
	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.alignment = .center

	let attrs = [NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-Thin", size: 36)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]

	let string = "How much wood would a woodchuck\nchuck if a woodchuck would chuck wood?"
	string.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

}
