import Cocoa

//let bounds = CGRect(x: 0, y: 0, width: 100, height: 100);

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

func DrawImageInNSGraphicsContext(_ size: CGSize, _ drawFunc: ()->()) -> NSImage {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
				colorSpaceName: NSColorSpaceName.calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0)
    
    let context = NSGraphicsContext(bitmapImageRep: rep!)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    
    drawFunc()
    
    NSGraphicsContext.restoreGraphicsState()
    
    let image = NSImage(size: size)
    image.addRepresentation(rep!)
    
    return image
}

let attributes:[NSAttributedString.Key:Any] = [.font: NSFont(name: "Times", size: 250)!, .foregroundColor:NSColor(cgColor: .white)!]
let attrString = NSAttributedString(string: "test", attributes: attributes)
let array = Array(repeating: attrString, count: 25)
let gridSizeX = 5
let gridSizeY = 5
let gridSize = 5
let edge_width:CGFloat = 100
let tag = 3
var offsetX:CGFloat = 0
var offsetY:CGFloat = 0
let lineWidth:CGFloat = 1
let size = 512 + 2*edge_width
let rect = CGRect(x: 0, y: 0, width: size, height:size)
let tileSizey:CGFloat = CGFloat(size)/CGFloat(gridSizeY)
let tileSizex:CGFloat = CGFloat(size)/CGFloat(gridSizeX)
let tileSize:CGFloat = CGFloat(size)/CGFloat(gridSize)
let font = NSFont(name: "Helvetica", size: 128)
/*
let image1 = DrawImageInCGContext(rect.size) { (context) -> () in
	for ii in 0..<array.count {
		if tag == 3 {offsetX = tileSizex * CGFloat(ii%gridSizeX)}
		
		offsetY = tileSizey * CGFloat(ii/gridSizeY)
		var path = CGMutablePath()
		var point:CGPoint
		point = CGPoint(x:edge_width + offsetX, y:edge_width + offsetY)
		path.move(to: point)
		point = CGPoint(x: edge_width + offsetX, y: tileSizey - edge_width + offsetY)
		path.addLine(to: point)
		point = CGPoint(x: tileSizex - edge_width + offsetX, y: tileSizey - edge_width + offsetY)
		path.addLine(to: point)
		point = CGPoint(x: tileSizex - edge_width + offsetX, y: edge_width + offsetY)
		path.addLine(to: point)
		path.closeSubpath()
		
		path.move(to: CGPoint(x: 0.0 + offsetX, y: 0.0 + offsetY))
		path.addLine(to: CGPoint(x: 0.0 + offsetX, y: tileSizey + offsetY))
		path.addLine(to: CGPoint(x: tileSizex + offsetX, y: tileSizey + offsetY))
		path.addLine(to: CGPoint(x: tileSizex + offsetX, y: 0.0 + offsetY))
		path.closeSubpath()
		
		context.saveGState()
		
		context.setShadow(offset: CGSize(width: 20.0, height: 20.0), blur: 0, color: .black)
		
		context.addPath(path)
		context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
		context.fillPath()
		
		context.setShadow(offset: CGSize(width: -20, height: -20), blur: 0, color: .white)
		context.addPath(path)
		context.setFillColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0)
		context.fillPath()
		context.restoreGState()
		
		path = CGMutablePath()
		
		path.move(to: CGPoint(x: 0.0 + offsetX, y: 0.0 + offsetY))
		// can I just use path.addRect ??
		path.addLine(to: CGPoint(x: 0.0 + offsetX, y: tileSizey + offsetY))
		path.addLine(to: CGPoint(x: tileSizex + offsetX, y: tileSizey + offsetY))
		path.addLine(to: CGPoint(x: tileSizex + offsetX, y: 0.0 + offsetY))
		path.closeSubpath()
		
		context.setLineWidth(lineWidth * CGFloat(size)/512.0)
		context.addPath(path)
		context.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
		context.strokePath()
		
	}
	
	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.alignment = .center

	let attrs = [NSAttributedString.Key.font: NSFont(name: "HelveticaNeue-Thin", size: 36)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]

	let string = "How much wood would a woodchuck\nchuck if a woodchuck would chuck wood?"
	string.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

/*	context.setFillColor(gray: 1.0, alpha: 1.0)
	
	let uiFont = NSFont(name: "Helvetica-Bold", size: 36.0)
	let cgFont = CGFont(uiFont!.fontName as CFString)
	
	context.setFont(cgFont!)
	context.setShadow(offset: CGSize(width: 2.0, height: 2.0), blur: 4.0, color: .black)
	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.lineBreakMode = .byWordWrapping
	paragraphStyle.alignment = .center
	for ii in 0..<array.count {
		let string = array[ii]
		//withAttributes: [font: font, paragraphStyle: paragraphStyle]
		let stringSize = array[ii].size()
		let x:CGFloat = tileSizex*CGFloat(ii%gridSizeX) + (tileSizex - stringSize.width)/2 - tileSizex/2 - stringSize.width/2
		let y:CGFloat = tileSizey*CGFloat(ii/gridSizeY) + (tileSizey - stringSize.height)/2
		array[ii].draw(at: CGPoint(x: x, y: y))
	}
	context.setShadow(offset: CGSize(width: -2.0, height: -2.0), blur: 4.0, color: .white)
	for ii in 0..<array.count {
		let stringSize = array[ii].size()
		let x:CGFloat = tileSizex*CGFloat(ii%gridSizeX) + (tileSizex - stringSize.width)/2 - tileSizex/2 - stringSize.width/2
		let y:CGFloat = tileSizey*CGFloat(ii%gridSizeY) + (tileSizey - stringSize.height)/2
		array[ii].draw(at: CGPoint(x: x, y: y))
	}
*/
}
*/

let image3 = DrawImageInCGContext(rect.size) { (context) -> () in

	var path = CGMutablePath()
	var pathOutline = CGMutablePath()
	var point:CGPoint
	var pointOutline:CGPoint
	let sides:Int = 8
	var jj:UInt = 0
	let height:CGFloat = tileSize
	let radius:CGFloat = (height - 6.0)/2.0
	offsetX = 2.0
	var	angleOffset:CGFloat = 0
	var offsetFactor:CGFloat = 0.9


	for ii in 0..<array.count {
		point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		pointOutline = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + (radius + offsetX) * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - (radius + offsetX) * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		path.move(to: point)
		pathOutline.move(to: pointOutline)
		for jj in 1..<sides {
			point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			pointOutline = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + (radius + offsetX) * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - (radius + offsetX) * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			path.addLine(to: point)
			pathOutline.addLine(to: pointOutline)
		}
		path.closeSubpath()
		pathOutline.closeSubpath()
		jj = 0
		point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + offsetFactor * radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - offsetFactor * radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		path.move(to: point)
		for jj in 1..<sides {
			point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + offsetFactor * radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - offsetFactor * radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			path.addLine(to: point)
		}
		path.closeSubpath()
		
		context.saveGState()
		context.setFillColor(gray: 1.0, alpha: 1.0)
		context.fill(CGRect(x: 0.0, y: 0.0, width: CGFloat(size), height: CGFloat(size)))
		context.setShadow(offset: CGSize(width: 2.0, height: 2.0), blur: 5.0, color: .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
		context.addPath(path)
		context.setFillColor(gray: 0.5, alpha: 1.0)
		context.fillPath()
		
		context.setShadow(offset: CGSize(width: -2.0, height: -2.0), blur: 5.0, color: .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0))
		context.addPath(path)
		context.setFillColor(gray: 0.5, alpha: 1.0)
		context.fillPath()
		
		context.restoreGState()

		context.saveGState()
		context.addPath(pathOutline)
		context.setLineWidth(1.0)
		context.setStrokeColor(gray: 0.9, alpha: 1.0)
		
		context.setLineJoin(.bevel)
		context.strokePath()
		context.restoreGState()

	}
}

let image2 = DrawImageInNSGraphicsContext(rect.size) { () -> () in
	NSColor.blue.set()
	NSRect.fill(rect)
}
