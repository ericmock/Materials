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
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
		let textureContext = CGContext(data: textureData, width: texWidth, height: texHeight, bitsPerComponent: 8, bytesPerRow: texWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
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
		
	
	static func generateTexture(fromArray array:[String], intoLocation location:UInt, withTag tag:UInt, ofSize size:Int, withFont font:NSFont, withOutline outlined:Bool, withSides sides:Int, withBGTexture textureNum:Int) {
		let texWidth = size
		let texHeight = size
		let fontName = font.fontName
//		let rangeItalic = fontName(rangeOfString:"italic", options: NSCaseInsensitiveSearch)
//		let rangeOblique = fontName(rangeOfString:"oblique", options: NSCaseInsensitiveSearch)
		
		let slanted = (fontName.contains("italic")) || (fontName.contains("oblique"))
		
		var grid_size_x = Int(ceil(sqrt(Float(array.count))))
		var grid_size_y = grid_size_x
		let grid_size = grid_size_x
		if tag == 1 {
			grid_size_x = 1
			grid_size_y = array.count
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
		var path:CGMutablePath
		var path_outline:CGMutablePath
		var offset_x:CGFloat
		var offset_y:CGFloat
//		var point:CGPoint
		var point_outline:CGPoint
		var imagePath:String
		var tile_size_x:CGFloat
		var tile_size_y:CGFloat
		var tile_size:CGFloat
		
		tile_size_x = CGFloat(size)/CGFloat(grid_size)
		tile_size_y = tile_size_x
		tile_size = tile_size_x
		
		if tag == 1 {
			tile_size_x = CGFloat(size)/CGFloat(grid_size_x)
			tile_size_y = CGFloat(size)/CGFloat(grid_size_y)
		}
		
//		let white:CGColor = .white
//		let black:CGColor = .black
		
		var textureImage:CGImage
//		var lightness:Float = 0.0
		
		if tag == 2 {
			if textureNum == 1 {
//				lightness = 0
			} else if textureNum == 2 {
//				lightness = 1
			} else if textureNum > 2 {
				let backgroundTextures = getBackgroundTextures()
				imagePath = "BackgroundTexture" + (backgroundTextures[textureNum - 3]).lastPathComponent
				textureImage = (NSImage.init(contentsOfFile: imagePath)!).convertedToGrayImage() as! CGImage
			} else {
				imagePath = NSHomeDirectory() + "/Documents/temp.png"
				textureImage = (NSImage.init(contentsOfFile: imagePath)!).convertedToGrayImage() as! CGImage
			}
		}
		
		var edge_width:CGFloat = 8.0
		if tag == 1 {
			edge_width = 10.0
		}
		
		// make embossed outline for the mode items and menu items
		if (tag == 3 || tag == 1) {makeEmbossedOutline(array, grid_size, edge_width, textureContext, tag, size)}
		
		// make embossed outline for the menu items
//		if (tag == 1) {makeEmbossedOutline(array, grid_size, edge_width, textureContext, tag, size)}
		
		if tag == 3 {
			
		} else if tag == 1 {
			
		} else if tag == 2 {
			let height:CGFloat = tile_size
			let radius:CGFloat = (height - 6.0)/2.0
			offset_x = 2.0
			var offset_factor:CGFloat = 0.9
			textureContext.translateBy(x: 0.0, y: -CGFloat(texHeight))
			var polygon_sides:Int = 0
//			var point:CGPoint
//			var point_outline:CGPoint
			
			for ii in 0..<array.count {
				var angle_offset:CGFloat = 0
				if sides == 3 {
					angle_offset = 0
				} else if sides == 4 {
					angle_offset = .pi/4
				} else if sides == 5 {
					angle_offset = 0
				} else if sides == 6 {
					angle_offset = 0
				} else if sides == 8 {
					angle_offset = .pi/8
				} else if sides == 10 {
					angle_offset = 0
				} else if sides == 12 {
					angle_offset = .pi/12
				}
				// handle regular polygons
				if sides <= 12 {
					outlinePolygon(tile_size, ii, grid_size, height, radius, angle_offset, sides, offset_x, offset_factor)
				// handle irregular polygons
				} else {
					var temp2:[CGFloat] = []
					var temp3:[CGFloat] = []
					if sides == 104 {
						temp2 = [0.5, CGFloat(1.0 - 0.0871677), 0.879126, CGFloat(1.0 - 0.456416), 0.5, 0.0, 0.120874, CGFloat(1.0 - 0.456416)]
						temp3 = [0.5, 0.912832 - 0.0558365*offset_factor, 0.879126 - 0.0522314*offset_factor, 0.543584 - 0.00496589*offset_factor, 0.5, 0.0699226*offset_factor, 0.120874 + 0.0522314*offset_factor, 0.543584 - 0.00496589*offset_factor]
						polygon_sides = 4
					} else if sides == 204 {
						temp2 = [0.0, 0.5, 0.5, 0.191, 1.0, 0.5, 0.5, 0.809]
						temp3 = [0.0760875*offset_factor, 0.5, 0.5, 0.191 + 0.0470221*offset_factor, 1.0 - 0.0760875*offset_factor, 0.5, 0.5, 0.809 - 0.0470221*offset_factor]
						polygon_sides = 4
					} else if sides == 304 {
						
					} else if sides == 103 {
						
					} else if sides == 105 {
						
					} else if sides == 203 {
						
					}
					outlineWeirdPolygon(temp2, temp3, tile_size, height, grid_size, ii, polygon_sides)
				}
			}
		}
	}
	
	fileprivate static func makeEmbossedOutline(_ array: [String], _ grid_size: Int, _ edge_width: CGFloat, _ textureContext: CGContext, _ tag: UInt, _ size: Int) {
		var offset_x:CGFloat = 0
		var grid_size_x:Int
		var grid_size_y:Int
		var tile_size_x:CGFloat
		var tile_size_y:CGFloat
		var lineWidth:CGFloat
		
		if tag == 3 {
			grid_size_x = grid_size
			grid_size_y = grid_size
			lineWidth = 10.0
		} else {
			grid_size_x = 1
			grid_size_y = array.count
			lineWidth = 2.0
		}

		tile_size_x = CGFloat(size)/CGFloat(grid_size_x)
		tile_size_y = CGFloat(size)/CGFloat(grid_size_y)

		for ii in 0..<array.count {
			if tag == 3 {offset_x = tile_size_x * CGFloat(ii%grid_size_x)}

			let offset_y = tile_size_y * CGFloat(ii/grid_size_y)
			var path = CGMutablePath()
			
			path.move(to: CGPoint(x:edge_width + offset_x, y:edge_width + offset_y))
			path.addLine(to: CGPoint(x: edge_width + offset_x, y: tile_size_y - edge_width + offset_y))
			path.addLine(to: CGPoint(x: tile_size_x - edge_width + offset_x, y: tile_size_y - edge_width + offset_y))
			path.addLine(to: CGPoint(x: tile_size_x - edge_width + offset_x, y: edge_width + offset_y))
			path.closeSubpath()
			
			path.move(to: CGPoint(x: 0.0 + offset_x, y: 0.0 + offset_y))
			path.addLine(to: CGPoint(x: 0.0 + offset_x, y: tile_size_y + offset_y))
			path.addLine(to: CGPoint(x: tile_size_x + offset_x, y: tile_size_y + offset_y))
			path.addLine(to: CGPoint(x: tile_size_x + offset_x, y: 0.0 + offset_y))
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
			
			path.move(to: CGPoint(x: 0.0 + offset_x, y: 0.0 + offset_y))
			// can I just use path.addRect ??
			path.addLine(to: CGPoint(x: 0.0 + offset_x, y: tile_size_y + offset_y))
			path.addLine(to: CGPoint(x: tile_size_x + offset_x, y: tile_size_y + offset_y))
			path.addLine(to: CGPoint(x: tile_size_x + offset_x, y: 0.0 + offset_y))
			path.closeSubpath()
			
			textureContext.setLineWidth(lineWidth * CGFloat(size)/512.0)
			textureContext.addPath(path)
			textureContext.setStrokeColor(gray: 0.0, alpha: 1.0)
			textureContext.strokePath()
			
		}
	}

	fileprivate static func outlinePolygon(_ tile_size: CGFloat, _ ii: Int, _ grid_size: Int, _ height: CGFloat, _ radius: CGFloat, _ angle_offset: CGFloat, _ sides: Int, _ offset_x: CGFloat, _ offset_factor: CGFloat) {
		var point:CGPoint
		var point_outline:CGPoint
		let path = CGMutablePath()
		let path_outline = CGMutablePath()
		var jj:UInt = 0
		point = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height/2 + radius * sin(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tile_size*CGFloat(ii/grid_size) + height/2 - radius * cos(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		point_outline = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height/2 + (radius + offset_x) * sin(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tile_size*CGFloat(ii/grid_size) + height/2 - (radius + offset_x) * cos(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		path.move(to: point)
		path_outline.move(to: point_outline)
		for jj in 1..<sides {
			point = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height/2 + radius * sin(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tile_size*CGFloat(ii/grid_size) + height/2 - radius * cos(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			point_outline = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height/2 + (radius + offset_x) * sin(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tile_size*CGFloat(ii/grid_size) + height/2 - (radius + offset_x) * cos(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			path.addLine(to: point)
			path_outline.addLine(to: point_outline)
		}
		path.closeSubpath()
		path_outline.closeSubpath()
		jj = 0
		point = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height/2 + offset_factor * radius * sin(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tile_size*CGFloat(ii/grid_size) + height/2 - offset_factor * radius * cos(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
		path.move(to: point)
		for jj in 1..<sides {
			point = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height/2 + offset_factor * radius * sin(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)), y: tile_size*CGFloat(ii/grid_size) + height/2 - offset_factor * radius * cos(angle_offset + 2.0 * .pi * CGFloat(jj)/CGFloat(sides)))
			path.addLine(to: point)
		}
		path.closeSubpath()
	}

	fileprivate static func outlineWeirdPolygon(_ temp2:[CGFloat], _ temp3:[CGFloat], _ tile_size: CGFloat, _ height:CGFloat, _ grid_size:Int, _ ii:Int, _ sides:Int) {
		let path = CGMutablePath()
		let path_outline = CGMutablePath()
		var point:CGPoint
//		var point_outline:CGPoint
		
		path.move(to: CGPoint(x: tile_size*CGFloat(ii%grid_size) + height*temp2[0], y: tile_size*CGFloat(ii/grid_size) + height*temp2[1]))
		path_outline.move(to: CGPoint(x: tile_size*CGFloat(ii%grid_size) + height*temp2[0], y: tile_size*CGFloat(ii/grid_size) + height*temp2[1]))
		for jj in 1..<sides {
			point = CGPoint(x: tile_size*CGFloat(ii%grid_size) + height*temp2[2*jj], y: tile_size*CGFloat(ii/grid_size) + height*temp2[2*jj+1])
			path.addLine(to: point)
			path_outline.addLine(to: point)
		}
		path.move(to: CGPoint(x: tile_size*CGFloat(ii%grid_size) + height*temp3[0], y: tile_size*CGFloat(ii/grid_size) + height*temp3[1]))
		for jj in 1..<sides {
			path.addLine(to: CGPoint(x: tile_size*CGFloat(ii%grid_size) + height*temp3[2*jj], y: tile_size*CGFloat(ii/grid_size) + height*temp3[2*jj+1]))
		}
		path.closeSubpath()
	}
}
