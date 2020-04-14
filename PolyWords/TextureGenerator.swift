import Foundation
import Cocoa

extension NSImage {
	func convertedToGrayImage() -> NSImage? {
		let width = self.size.width
		let height = self.size.height
		let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
		let colorSpace = CGColorSpaceCreateDeviceGray()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
		
		guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
			return nil
		}
		let cg = cgImage as! CGImage
		
		context.draw(cg, in: rect)
		guard let imageRef = context.makeImage() else { return nil }
		let newImage = NSImage(cgImage: imageRef.copy()!, size: CGSize(width: width, height: height))
		
		return newImage
	}
	
	func areaAverage() -> NSColor {
		
		var bitmap = [UInt8](repeating: 0, count: 4)
		
		let context = CIContext(options: nil)
		let cgImg = context.createCGImage(CoreImage.CIImage(cgImage: self.cgImage as! CGImage), from: CoreImage.CIImage(cgImage: self.cgImage as! CGImage).extent)
		
		let inputImage = CIImage(cgImage: cgImg!)
		let extent = inputImage.extent
		let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
		let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
		let outputImage = filter.outputImage!
		let outputExtent = outputImage.extent
		assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
		
		// Render to bitmap.
		context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
		
		// Compute result.
		let result = NSColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
		return result
	}
	
}

class TextureGenerator {
	
	let colorSpace:CGColorSpace
	
	init () {
		colorSpace = CGColorSpaceCreateDeviceRGB()
	}
	
	static func getBackgroundTextures() -> Array<URL> {
		let backgroundTextures = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "BackgroundTextures")!
		return backgroundTextures
	}
	
	
	func generateTexture(intoLocation location:UInt) {
		let texWidth = 256
		let texHeight = 256
		//		GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
		let textureData = UnsafeMutablePointer<UInt8>.allocate(capacity: texWidth * texHeight * 4)
//		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

//		let textureContext = CGContext(data: textureData, width: texWidth, height: texHeight, bitsPerComponent: 8, bytesPerRow: texWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

		for ii in stride(from: 0, to: texWidth * texHeight * 4, by: 4) {
			let denom = UInt32(2/RAND_MAX/255)
			let rannum = UInt8(127 + arc4random()/denom)
			textureData[ii+0] = rannum
			textureData[ii+1] = rannum/2
			textureData[ii+2] = rannum/2
			textureData[ii+3] = 255
		}
		
		//		glBindTexture(GL_TEXTURE_2D, location);
		//		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
		//
		//		free(textureData);
		//
		//		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		//		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		
	}
	/*
	tag:  the type of texture to make (menu item, polygon letter, etc.)
	array:  the array of text we want to use for words or letters
	textureNum:  the number of the background texture to use
	*/
	
	
	static func generateTexture(fromArray array:[NSString], intoLocation location:UInt, withTag tag:UInt, ofSize size:Int, withFont fontIn:NSFont, withOutline outlined:Bool, withSides sides:Int, withBGTexture textureNum:Int) -> CGImage {
		let texWidth = size
		let texHeight = size
		let fontName = fontIn.fontName
		var font = fontIn
		//		let rangeItalic = fontName(rangeOfString:"italic", options: NSCaseInsensitiveSearch)
		//		let rangeOblique = fontName(rangeOfString:"oblique", options: NSCaseInsensitiveSearch)
		
		let slanted = (fontName.contains("italic")) || (fontName.contains("oblique"))
		
		var gridSizeX = Int(ceil(sqrt(Float(array.count))))
		var gridSizeY = gridSizeX
		let gridSize = gridSizeX
		if tag == 1 {
			gridSizeX = 1
			gridSizeY = array.count
		}
		
		//		GLubyte *textureData = (GLubyte *)calloc(texWidth * texHeight, 4);
		let textureData = UnsafeMutablePointer<Int8>.allocate(capacity: texWidth * texHeight * 4)
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let textureContext = CGContext(data: textureData, width: texWidth, height: texHeight, bitsPerComponent: 8, bytesPerRow: texWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		if tag == 1 || tag == 3 {
			textureContext.setFillColor(gray: 1.0, alpha: 1.0)
		}
		if tag == 2 {
			textureContext.setFillColor(gray: 0.3, alpha: 1.0)
		}
		
		textureContext.fill(CGRect(x: 0, y: 0, width: texWidth, height: texHeight))
		textureContext.saveGState()
		textureContext.setShouldAntialias(true)
		//		var path:CGMutablePath
		//		var pathOutline:CGMutablePath
		var offsetX:CGFloat
		//		var offsetY:CGFloat
		//		var point:CGPoint
		//		var pointOutline:CGPoint
//		var imagePath:String
		var tileSizeX:CGFloat
		var tileSizeY:CGFloat
		var tileSize:CGFloat
		
		tileSizeX = CGFloat(size)/CGFloat(gridSize)
		tileSizeY = tileSizeX
		tileSize = tileSizeX
		
		if tag == 1 {
			tileSizeX = CGFloat(size)/CGFloat(gridSizeX)
			tileSizeY = CGFloat(size)/CGFloat(gridSizeY)
		}
		
		//		let white:CGColor = .white
		//		let black:CGColor = .black
		
//		imagePath = NSHomeDirectory() + "/Documents/temp.png"
//		var textureImage = (NSImage.init(contentsOfFile: imagePath)!).convertedToGrayImage() as! CGImage
//		var lightness:CGFloat = ((NSImage.init(contentsOfFile: imagePath)!).areaAverage()).brightnessComponent
		var lightness:CGFloat = 1.0
		
		if tag == 2 {
			if textureNum == 1 {
				lightness = 0
			} else if textureNum == 2 {
				lightness = 1
			} else if textureNum > 2 {
//				let backgroundTextures = getBackgroundTextures()
//				imagePath = "BackgroundTexture" + (backgroundTextures[textureNum - 3]).lastPathComponent
//				textureImage = (NSImage.init(contentsOfFile: imagePath)!).convertedToGrayImage() as! CGImage
			}
		}
		
		var edgeWidth:CGFloat = 8.0
		if tag == 1 {
			edgeWidth = 10.0
		}
		
		// make embossed outline for the mode items and menu items
		if (tag == 3 || tag == 1) {makeEmbossedOutline(array, gridSize, edgeWidth, textureContext, tag, size)}
		
		// make embossed outline for the menu items
		//		if (tag == 1) {makeEmbossedOutline(array, gridSize, edge_width, textureContext, tag, size)}
		
		if tag == 3 {
			textureContext.setFillColor(gray: 0.0, alpha: 1.0)
			textureContext.setShadow(offset: CGSize(width: 2.0, height: 2.0), blur: 4.0, color: .black)
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineBreakMode = .byWordWrapping
			paragraphStyle.alignment = .center
			for ii in 0..<array.count {
				let stringSize = array[ii].size(withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
				let x:CGFloat = tileSize*CGFloat(ii%gridSize) + (tileSize - stringSize.width)/2 - tileSize/2 - stringSize.width/2
				let y:CGFloat = tileSize*CGFloat(ii%gridSize) + (tileSize - stringSize.height)/2
				array[ii].draw(in: CGRect(x: x, y: y, width: stringSize.width, height: stringSize.height), withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
			}
			textureContext.setShadow(offset: CGSize(width: -2.0, height: -2.0), blur: 4.0, color: .white)
			for ii in 0..<array.count {
				let stringSize = array[ii].size(withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
				let x:CGFloat = tileSize*CGFloat(ii%gridSize) + (tileSize - stringSize.width)/2 - tileSize/2 - stringSize.width/2
				let y:CGFloat = tileSize*CGFloat(ii%gridSize) + (tileSize - stringSize.height)/2
				array[ii].draw(in: CGRect(x: x, y: y, width: stringSize.width, height: stringSize.height), withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
			}

		}
		else if tag == 1 {
			textureContext.setFillColor(gray: 0.0, alpha: 1.0)
			textureContext.setShadow(offset: CGSize(width: 2.0, height: 2.0), blur: 4.0, color: .black)
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineBreakMode = .byWordWrapping
			paragraphStyle.alignment = .center
			for ii in 0..<array.count {
				let stringSize = array[ii].size(withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
				let x:CGFloat = tileSizeX/2 - stringSize.width/2
				let y:CGFloat = tileSizeY*CGFloat(ii%gridSizeY) + (tileSizeY - stringSize.height)/2
				array[ii].draw(in: CGRect(x: x, y: y, width: stringSize.width, height: stringSize.height), withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
			}
		}
		else if tag == 2 {
			let height:CGFloat = tileSize
			let radius:CGFloat = (height - 6.0)/2.0
			offsetX = 2.0
			let offsetFactor:CGFloat = 0.9
			textureContext.translateBy(x: 0.0, y: -CGFloat(texHeight))
			var polygonSides:Int = 0
			
			textureContext.translateBy(x: 1.0, y: -1.0)
			if textureNum == 0 {
				textureContext.setFillColor(gray: 1.0, alpha: 1.0)
				textureContext.fill(CGRect(x: 0, y: 0, width: texWidth, height: texHeight))
			} else if textureNum == 1{
				textureContext.setFillColor(gray: 0.0, alpha: 1.0)
				textureContext.fill(CGRect(x: 0, y: 0, width: texWidth, height: texHeight))
			}
//			else {
//				for ii in 0..<array.count {
//					textureContext.draw(textureImage, in: CGRect(x: tileSize * CGFloat(ii%gridSize), y: CGFloat(texHeight) - tileSize - tileSizeY*CGFloat(ii/gridSize), width: tileSize, height: tileSize))
//				}
//			}
			
			for ii in 0..<array.count {
				var angleOffset:CGFloat = 0
				if sides == 3 {
					angleOffset = 0
				} else if sides == 4 {
					angleOffset = .pi/4
				} else if sides == 5 {
					angleOffset = 0
				} else if sides == 6 {
					angleOffset = 0
				} else if sides == 8 {
					angleOffset = .pi/8
				} else if sides == 10 {
					angleOffset = 0
				} else if sides == 12 {
					angleOffset = .pi/12
				}
				
				// handle regular polygons
				if sides <= 12 {
					outlinePolygon(tileSize, ii, gridSize, height, radius, angleOffset, sides, offsetX, offsetFactor, textureContext, textureNum, lightness)
				}
					// handle irregular polygons
				else {
					var temp2:[CGFloat] = []
					var temp3:[CGFloat] = []
					if sides == 104 {
						temp2 = [0.5, CGFloat(1.0 - 0.0871677), 0.879126, CGFloat(1.0 - 0.456416), 0.5, 0.0, 0.120874, CGFloat(1.0 - 0.456416)]
						temp3 = [0.5, 0.912832 - 0.0558365*offsetFactor, 0.879126 - 0.0522314*offsetFactor, 0.543584 - 0.00496589*offsetFactor, 0.5, 0.0699226*offsetFactor, 0.120874 + 0.0522314*offsetFactor, 0.543584 - 0.00496589*offsetFactor]
						polygonSides = 4
					}
					else if sides == 204 {
						temp2 = [0.0, 0.5, 0.5, 0.191, 1.0, 0.5, 0.5, 0.809]
						temp3 = [0.0760875*offsetFactor, 0.5, 0.5, 0.191 + 0.0470221*offsetFactor, 1.0 - 0.0760875*offsetFactor, 0.5, 0.5, 0.809 - 0.0470221*offsetFactor]
						polygonSides = 4
					}
					else if sides == 304 {
						temp2 = [0.5, 0.0, 0.105022, 0.587977, 0.5, 0.824045, 0.894978, 0.587977]
						temp3 = [0.0760875*offsetFactor, 0.5, 0.5, 0.191 + 0.0470221*offsetFactor, 1.0 - 0.0760875*offsetFactor, 0.5, 0.5, 0.809 - 0.0470221*offsetFactor]
						polygonSides = 4
					}
					else if sides == 103 {
						temp2 = [0.352115, 0, 0.318793, 0.681818, 0.829092, 0.681818]
						temp3 = [0.352115 + 0.034245*offsetFactor, 0.118733*offsetFactor, 0.318793 + 0.0420026*offsetFactor, 0.681818 - 0.04*offsetFactor, 0.829092 - 0.0767989*offsetFactor, 0.681818 - 0.04*offsetFactor]
						polygonSides = 3
					}
					else if sides == 105 {
						temp2 = [0.647885, 0.0, 0.681207, 0.681818, 0.170908, 0.681818]
						temp3 = [0.647885 - 0.034245*offsetFactor, 0.118733*offsetFactor, 0.681207 - 0.0420026*offsetFactor, 0.681818 - 0.04*offsetFactor, 0.170908 + 0.0767989*offsetFactor, 0.681818 - 0.04*offsetFactor]
						polygonSides = 3
					}
					else if sides == 203 {
						temp2 = [0.512355, 0.258226, -0.0123553, 0.658387, 1.0, 0.658387]
						temp3 = [0.512355 - 0.0227212*offsetFactor/25.0, 0.258226 + 1.27495*offsetFactor/25.0, -0.0123553 + 2.9603*offsetFactor/25.0, 0.658387 - offsetFactor/25.0, 1.0 - 2.79502*offsetFactor/25.0, 0.658387 - offsetFactor/25.0]
						polygonSides = 3
						
					}
					outlineWeirdPolygon(temp2, temp3, tileSize, height, gridSize, ii, polygonSides, textureContext, textureNum, lightness)
					
				}
			}
			textureContext.setLineWidth(2.0)
			if outlined {
				textureContext.setTextDrawingMode(.fillStroke)
			} else {
				textureContext.setTextDrawingMode(.fill)
			}
			
			var shiftY:CGFloat = 0.0
			var shiftX:CGFloat = 0.0
			if sides == 3 {shiftY = 2.0}
			if sides == 104 {shiftY = 2.0}
			if sides == 204 {shiftY = 2.0}
			if sides == 203 {shiftX = 2.0}
			if slanted {shiftX = -2.0}
			if sides == 103 || sides == 105 || sides == 203 {
				font = NSFont(name: fontIn.familyName!, size: 0.75*(fontIn.pointSize))!
			}
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineBreakMode = .byWordWrapping
			paragraphStyle.alignment = .center
			if sides == 105 {
				textureContext.scaleBy(x: -1.0, y: 1.0)
				textureContext.translateBy(x: -CGFloat(texWidth), y: 0.0)
				for ii in 0..<array.count {
					let stringSize:CGSize = array[ii].size(withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
					let x:CGFloat = CGFloat(texWidth) - (shiftX + tileSize*CGFloat(ii%gridSize)) - tileSize/2 - stringSize.width/2
					let y:CGFloat = shiftY + tileSize*CGFloat(ii/gridSize) + (tileSize - stringSize.height)/2
					array[ii].draw(in: CGRect(x: x, y: y, width: stringSize.width, height: stringSize.height), withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
				}
			}
			else {
				for ii in 0..<array.count {
					let stringSize = array[ii].size(withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
					let x:CGFloat = (shiftX + tileSize*CGFloat(ii%gridSize)) - tileSize/2 - stringSize.width/2
					let y:CGFloat = shiftY + tileSize*CGFloat(ii/gridSize) + (tileSize - stringSize.height)/2
					array[ii].draw(in: CGRect(x: x, y: y, width: stringSize.width, height: stringSize.height), withAttributes: [.font: font, .paragraphStyle: paragraphStyle])
				}
			}
		}

		let image = CGImage(width: texWidth, height: texHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: texWidth * 4, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo.rawValue), provider: textureData as! CGDataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
		
		return image
//
//		glBindTexture(GL_TEXTURE_2D, location);
//		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
//
//		free(textureData);
//		CGContextRelease(textureContext);
//		CGColorSpaceRelease(color_space);
//
//		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//		glEnable(GL_TEXTURE_2D);

	}
	
	fileprivate static func makeEmbossedOutline(_ array: [NSString], _ gridSize: Int, _ edge_width: CGFloat, _ textureContext: CGContext, _ tag: UInt, _ size: Int) {
		var offsetX:CGFloat = 0
		var gridSizeX:Int
		var gridSizeY:Int
		var tileSizex:CGFloat
		var tileSizey:CGFloat
		var lineWidth:CGFloat
		
		if tag == 3 {
			gridSizeX = gridSize
			gridSizeY = gridSize
			lineWidth = 10.0
		} else {
			gridSizeX = 1
			gridSizeY = array.count
			lineWidth = 2.0
		}
		
		tileSizex = CGFloat(size)/CGFloat(gridSizeX)
		tileSizey = CGFloat(size)/CGFloat(gridSizeY)
		
		for ii in 0..<array.count {
			if tag == 3 {offsetX = tileSizex * CGFloat(ii%gridSizeX)}
			
			let offsetY = tileSizey * CGFloat(ii/gridSizeY)
			var path = CGMutablePath()
			
			path.move(to: CGPoint(x:edge_width + offsetX, y:edge_width + offsetY))
			path.addLine(to: CGPoint(x: edge_width + offsetX, y: tileSizey - edge_width + offsetY))
			path.addLine(to: CGPoint(x: tileSizex - edge_width + offsetX, y: tileSizey - edge_width + offsetY))
			path.addLine(to: CGPoint(x: tileSizex - edge_width + offsetX, y: edge_width + offsetY))
			path.closeSubpath()
			
			path.move(to: CGPoint(x: 0.0 + offsetX, y: 0.0 + offsetY))
			path.addLine(to: CGPoint(x: 0.0 + offsetX, y: tileSizey + offsetY))
			path.addLine(to: CGPoint(x: tileSizex + offsetX, y: tileSizey + offsetY))
			path.addLine(to: CGPoint(x: tileSizex + offsetX, y: 0.0 + offsetY))
			path.closeSubpath()
			
			textureContext.saveGState()
			
			textureContext.setShadow(offset: CGSize(width: 2.0, height: 2.0), blur: 4.0, color: .black)
			
			textureContext.addPath(path)
			textureContext.setFillColor(gray: 0.5, alpha: 1.0)
			textureContext.fillPath()
			
			textureContext.setShadow(offset: CGSize(width: -2, height: -2), blur: 4.0, color: .white)
			textureContext.addPath(path)
			textureContext.setFillColor(gray: 0.5, alpha: 1.0)
			textureContext.fillPath()
			textureContext.restoreGState()
			
			path = CGMutablePath()
			
			path.move(to: CGPoint(x: 0.0 + offsetX, y: 0.0 + offsetY))
			// can I just use path.addRect ??
			path.addLine(to: CGPoint(x: 0.0 + offsetX, y: tileSizey + offsetY))
			path.addLine(to: CGPoint(x: tileSizex + offsetX, y: tileSizey + offsetY))
			path.addLine(to: CGPoint(x: tileSizex + offsetX, y: 0.0 + offsetY))
			path.closeSubpath()
			
			textureContext.setLineWidth(lineWidth * CGFloat(size)/512.0)
			textureContext.addPath(path)
			textureContext.setStrokeColor(gray: 0.0, alpha: 1.0)
			textureContext.strokePath()
			
		}
	}
	
	fileprivate static func drawEmbossedPath(_ textureContext: CGContext, _ path: CGMutablePath) {
		textureContext.saveGState()
		textureContext.setShadow(offset: CGSize(width: 1.0, height: 1.0), blur: 2.0, color: .black)
		textureContext.addPath(path)
		textureContext.setFillColor(gray: 0.5, alpha: 1.0)
		textureContext.fillPath()
		
		textureContext.setShadow(offset: CGSize(width: -1.0, height: -1.0), blur: 2.0, color: .black)
		textureContext.addPath(path)
		textureContext.setFillColor(gray: 0.5, alpha: 1.0)
		textureContext.fillPath()
		
		textureContext.restoreGState()
	}
	
	fileprivate static func drawOutlinePath(_ textureContext: CGContext, _ pathOutline: CGMutablePath, _ textureNum: Int, _ lightness: CGFloat) {
		textureContext.saveGState()
		textureContext.addPath(pathOutline)
		textureContext.setLineWidth(3.0)
		if (textureNum == 0) {
			textureContext.setFillColor(gray: 0.1, alpha: 1.0)
		}
		else if (textureNum == 1) {
			textureContext.setFillColor(gray: 0.1, alpha: 1.0)
		}
		else {
			if (lightness > 0.25) {
				textureContext.setStrokeColor(gray: 0.1, alpha: 1.0)
			} else {
				textureContext.setStrokeColor(gray: 0.9, alpha: 1.0)
			}
		}
		
		textureContext.setLineJoin(.bevel)
		textureContext.strokePath()
		textureContext.restoreGState()
	}
	
	fileprivate static func outlinePolygon(_ tileSize:CGFloat, _ ii:Int, _ gridSize:Int, _ height:CGFloat, _ radius:CGFloat, _ angleOffset:CGFloat, _ sides:Int, _ offset_x:CGFloat, _ offset_factor:CGFloat, _ textureContext:CGContext, _ textureNum:Int, _ lightness:CGFloat) {
		var point:CGPoint
		var pointOutline:CGPoint
		let path = CGMutablePath()
		let pathOutline = CGMutablePath()
		var jj:UInt = 0
		point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		pointOutline = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + (radius + offset_x) * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - (radius + offset_x) * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		path.move(to: point)
		pathOutline.move(to: pointOutline)
		for jj in 1..<sides {
			point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			pointOutline = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + (radius + offset_x) * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - (radius + offset_x) * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			path.addLine(to: point)
			pathOutline.addLine(to: pointOutline)
		}
		path.closeSubpath()
		pathOutline.closeSubpath()
		jj = 0
		point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + offset_factor * radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - offset_factor * radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		path.move(to: point)
		for jj in 1..<sides {
			point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height/2 + offset_factor * radius * sin(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tileSize*CGFloat(ii/gridSize) + height/2 - offset_factor * radius * cos(angleOffset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			path.addLine(to: point)
		}
		path.closeSubpath()
		
		drawEmbossedPath(textureContext, path)
		
		drawOutlinePath(textureContext, pathOutline, textureNum, lightness)
	}
	
	fileprivate static func outlineWeirdPolygon(_ temp2:[CGFloat], _ temp3:[CGFloat], _ tileSize: CGFloat, _ height:CGFloat, _ gridSize:Int, _ ii:Int, _ sides:Int, _ textureContext:CGContext, _ textureNum:Int, _ lightness:CGFloat) {
		let path = CGMutablePath()
		let pathOutline = CGMutablePath()
		var point:CGPoint
		//		var pointOutline:CGPoint
		
		path.move(to: CGPoint(x: tileSize*CGFloat(ii%gridSize) + height*temp2[0], y: tileSize*CGFloat(ii/gridSize) + height*temp2[1]))
		pathOutline.move(to: CGPoint(x: tileSize*CGFloat(ii%gridSize) + height*temp2[0], y: tileSize*CGFloat(ii/gridSize) + height*temp2[1]))
		for jj in 1..<sides {
			point = CGPoint(x: tileSize*CGFloat(ii%gridSize) + height*temp2[2*jj], y: tileSize*CGFloat(ii/gridSize) + height*temp2[2*jj+1])
			path.addLine(to: point)
			pathOutline.addLine(to: point)
		}
		path.move(to: CGPoint(x: tileSize*CGFloat(ii%gridSize) + height*temp3[0], y: tileSize*CGFloat(ii/gridSize) + height*temp3[1]))
		for jj in 1..<sides {
			path.addLine(to: CGPoint(x: tileSize*CGFloat(ii%gridSize) + height*temp3[2*jj], y: tileSize*CGFloat(ii/gridSize) + height*temp3[2*jj+1]))
		}
		path.closeSubpath()
		
		drawEmbossedPath(textureContext, path)
		
		drawOutlinePath(textureContext, pathOutline, textureNum, lightness)
		
	}
}
