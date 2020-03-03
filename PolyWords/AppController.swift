import Foundation
import Cocoa
//import UIKit

let numPolygonTypes = 15

class AppController {
	
	let screenRect = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
	let darkColor:NSColor = NSColor(red: 43.0/256.0, green: 34.0/256.0, blue: 20.0/256.0, alpha: 1.0)
	let polyhedronInfoArray:NSMutableArray?
	let polyhedronArray = NSMutableArray()
	let polyhedronNamesArray = NSMutableArray()
	let polyhedronNumbersArray = NSMutableArray()
	let polyhedronLevelsArray = NSMutableArray()
	lazy var highScores:HighScores = HighScores()
	var highest_completed = repeatElement(UInt(), count: 4)
	var accelQ = false
	var recordTimeQ = true
	var purchasingQ = false
	var connection_failed = false
	var resign_state = 0
	var polyhedraInfo = NSMutableArray()
//	var wordThread = nil
	let wordNumbers = ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven"]
	let alphabetArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	let nowTime = Date()
	var mode:UInt!
	var unlocked = true
	var upgrading = true
	var sendDataQ = true
	var upgraded = true
	var checking = 0
	var bgTexture = 3
	var axesQ = false
	var fontSelected = 1
	var sound = true
	var adSize:CGSize!
	var textures = UnsafeMutablePointer<UInt>.allocate(capacity: numPolygonTypes + 5)
	//	textures = (GLuint *)calloc(sizeof(GLuint),(num_polygon_types + 5));
	var textureExists = [Bool](repeating: false, count: numPolygonTypes + 5)

	init() {
		if unlocked {
			polyhedronArray.addObjects(from: ["Truncated Icosahedron", 2, 1,
								 "Parabigyrate Rhombicosidodecahedron", 14, 2,
								 "Parabidiminished Rhombicosidodecahedron", 16, 3,
								 "Deca-faced Polyhedron", 20, 4,
								 "Rhombic Triacontahedron", 23, 5,
								 "Great Dodecacronic Hexecontahedron", 25, 6,
								 "Truncated Dodecahedron", 24, 7,
								 "Octagon-Drilled Truncated Cuboctahedron", 11, 8,
								 "Rhombicosidodecahedron", 12, 9,
								 "Truncated Truncated Icosahedron", 26, 10,
								 "Drilled Truncated Cube", 9, 11,
								 "Truncated Cuboctahedron", 18, 12,
								 "Gyroelongated Square Bicupola", 19, 13,
								 "Nameless Blob", 35, 14,
								 "Stewart K4'", 10, 15,
								 "Pentagonal Orthobirotunda", 15, 16,
								 "Truncated Icosidodecahedron", 13, 17,
								 "Gyroelongated Pentagonal Rotunda", 21, 18,
								 "Drilled Truncated Dodecahedron", 37, 19,
								 "Half-truncated Truncated Icosahedron", 17, 20,
								 "Truncated Octahedron 8", 32, 21,
								 "Truncated Octahedron", 6, 22,
								 "Strombic Hexecontahedron", 3, 23,
								 "Disdyakisdodecahedron", 31, 24,
								 "Antiprism-Extended Dodecahedrahedron Ring", 34, 25,
								 "Gyro-Expanded Cuboctahedron", 28, 26,
								 "Tetrakishexahedron", 7, 27,
								 "Icosahedra 8-ring", 29, 28,
								 "Cupola-Drilled Truncated Icosidodecahedron", 5, 29,
								 "Gyro-Double-Expanded Cuboctahedron", 36, 30,
								 "Rotunda-Drilled Truncated Icosidodecahedron", 27, 31,
								 "Prism-Expanded Truncated Cube", 33, 32,
								 "Eight-Octahedron Ring", 8, 33,
								 "Torus Slice", 4, 34,
								 "Gyroelongated Pentagonal Cupola", 22, 35])
		}	else {
			polyhedronArray.addObjects(from: ["Truncated Icosahedron", 2, 1,
								 "Parabigyrate Rhombicosidodecahedron", 14, 2,
								 "Parabidiminished Rhombicosidodecahedron", 16, 3,
								 "Deca-faced Polyhedron", 20, 4,
								 "Rhombic Triacontahedron", 23, 5,
								 "Great Dodecacronic Hexecontahedron", 25, 6,
								 "Truncated Dodecahedron", 24, 7,
								 "Octagon-Drilled Truncated Cuboctahedron", 11, 8,
								 "Rhombicosidodecahedron", 12, 9,
								 "Truncated Truncated Icosahedron", 26, 10])
		}
		
		for ii in stride(from: 0, through: polyhedronArray.count, by: 3) {
			polyhedronNamesArray.add(polyhedronArray.object(at: ii))
		}
		
		for ii in stride(from: 1, through: polyhedronArray.count, by: 3) {
			polyhedronNumbersArray.add(polyhedronArray.object(at: ii))
		}
		
		for ii in stride(from: 2, through: polyhedronArray.count, by: 3) {
			polyhedronLevelsArray.add(polyhedronArray.object(at: ii))
		}
		
		polyhedronInfoArray = NSMutableArray()
		highScores.reset(withFile: "**", delegate: self)

		var loc:Int
		var polyID:NSNumber
		var completed = [Bool(), Bool(), Bool(), Bool()]
		for ii in 1..<polyhedronLevelsArray.count + 1 {
			loc = polyhedronLevelsArray.object(at: ii) as! Int
			polyID = polyhedronNumbersArray.object(at: loc) as! NSNumber
			for jj in 0..<4 {
				highScores.mode = UInt(jj)
				completed[jj] = highScores.checkLevelCompleted(num: polyID)
				if completed[jj],
					ii > highest_completed[jj] {
				}
			}
			let values = [polyhedronNamesArray.object(at: loc), polyID, [completed[0],completed[1],completed[2],completed[4],true,true],ii]
			let keys = ["name", "polyID", "completed", "level"]
			let dict = Dictionary(uniqueKeysWithValues: zip(keys, values))
			polyhedronInfoArray?.add(dict)
		}
		
		highScores.mode = mode

	}
	
	func createFilesIfNeeded() -> Bool {
		let fileManager = FileManager()
		var filePath = self.getHighWordsPath()
		let success = fileManager.fileExists(atPath: filePath)
		let numPolyhedra:Int = polyhedronInfoArray!.count
		
		if !success {
			let tempArray = NSMutableArray(capacity: numPolyhedra)
			for ii in 0..<numPolyhedra {
				tempArray.add([ii, "", 0.0, 0.0, 0.0])
			}
			tempArray.write(toFile: filePath, atomically: true)
		}
		
		
		
		return true
	}

	func setSendData(sendDataQ: Bool) {
		if sendDataQ != self.sendDataQ {
			self.sendDataQ = sendDataQ
			UserDefaults.standard.set(self.sendDataQ, forKey: "sendDataQ")
			UserDefaults.standard.synchronize()
		}
	}

	func setGameMode(newMode: UInt) {
		if newMode != mode {
			mode = newMode
			UserDefaults.standard.set(mode, forKey: "gameMode")
			UserDefaults.standard.synchronize()
		}
	}

	func setWordChecking(newChecking: Int) {
		if newChecking != checking {
			checking = newChecking
			UserDefaults.standard.set(checking, forKey: "checking")
			UserDefaults.standard.synchronize()
		}
	}

	func setAxesQ(newAxesQ: Bool) {
		if newAxesQ != axesQ {
			axesQ = newAxesQ
			UserDefaults.standard.set(axesQ, forKey: "axesQ")
			UserDefaults.standard.synchronize()
		}
	}

	func setFontSelected(fontNumber: Int) {
		if fontNumber != fontSelected {
			for ii in 3..<numPolygonTypes + 5 {
				textureExists[ii] = false
			}
			fontSelected = fontNumber
			UserDefaults.standard.set(fontSelected, forKey: "font")
			UserDefaults.standard.synchronize()
		}
	}

	func setBackgroundTexture(textureNumber: Int) {
		if textureNumber != bgTexture {
			for ii in 3..<numPolygonTypes + 5 {
				textureExists[ii] = false
			}
			bgTexture = textureNumber
			UserDefaults.standard.set(bgTexture, forKey: "texture")
			UserDefaults.standard.synchronize()
		}
	}
	
	func anchorPoint() -> CGPoint {
		let anchorPoint:CGPoint
		if adSize.height > 50 {
			anchorPoint = CGPoint(x: 0.0, y: self.screenRect.size.height + adSize.height)
		} else {
			anchorPoint = CGPoint(x: 0.0, y: self.screenRect.size.height)
		}
		return anchorPoint
	}
	
	func decodeConvert(oldScores:NSArray) -> NSArray {
		var gameMode = oldScores.object(at: 0) as! Int
		let factor = oldScores.object(at: 2) as! Float
		let timeEncoded = oldScores.object(at: 3) as! Float
		
		let hundreds_encoded = oldScores.object(at: 4) as! Float//[[encodedScore objectAtIndex:4] floatValue]
		let tens_encoded = oldScores.object(at: 5) as! Float//[[encodedScore objectAtIndex:5] floatValue]
		let ones_encoded = oldScores.object(at: 6) as! Float//[[encodedScore objectAtIndex:6] floatValue]
		
		let thousands = 0
		let hundreds = Int(round(10.0 * asin(hundreds_encoded)))
		let tens = Int(round(10.0 * asin(tens_encoded)))
		let ones = Int(round(10.0 * asin(ones_encoded)))
		
		var timeFactor:Float
		var newScore:Int
		
		if (gameMode == 3 || gameMode == 0) {
			timeFactor = 2.0
		} else {
			timeFactor = 1.0
		}
		
		if (gameMode == 1 || gameMode == 2) {
			newScore = Int(Float(1000*thousands + 100*hundreds + 10*tens + ones)*7.3)
		} else {
			newScore = 2500
		}
		
		if gameMode == 2 {
			gameMode = 3
		} else if gameMode == 3 {
			gameMode = 2
		}
		
		return NSArray(array: [gameMode, oldScores.object(at: 1), newScore, Float(timeFactor*factor*asin(timeEncoded))])

	}
	
	func getHighScoresPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"high_scores"
		return fullPath
	}
	
	func getHighWordsPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"high_words"
		return fullPath
	}
	
	func getAdventureScorePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"adv_score"
		return fullPath
	}
	
	func getStaticWordsFoundPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"static_words_found"
		return fullPath
	}
	
	func getDynamicWordsFoundPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"dynamic_words_found"
		return fullPath
	}
	
	func getStaticSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"bg_data"
		return fullPath
	}

	func getStaticScoredSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"ss_data"
		return fullPath
	}

	func getStaticTimedSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"st_data"
		return fullPath
	}

	func getDynamicScoredSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"ds_data"
		return fullPath
	}

	func getDynamicTimedSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"dt_data"
		return fullPath
	}

	func getScoreDBPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"data.sqlite"
		return fullPath
	}

	func getWordDBPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"wordlist.sqlite"
		return fullPath
	}
	
	func upgradeFromTwoPointOne() {
		guard let oldEncodedDataArray = NSArray(contentsOfFile: self.getHighScoresPath()) else { return }
		let newEncodedDataArray = NSMutableArray(capacity: 3)
		for oldEncodedData in oldEncodedDataArray where oldEncodedData is NSArray {
			if (oldEncodedData as AnyObject).count <= 7 {
				let newDecodedData = self.decodeConvert(oldScores: oldEncodedData as! NSArray)
				let newEncodedData = highScores.encodeDataForPolyhedron(ofType: newDecodedData.object(at: 1) as! Int, forMode: newDecodedData.object(at: 0) as! Int, forTime: newDecodedData.object(at: 3) as! Float, withScore: newDecodedData.object(at: 2) as! Int)
				newEncodedDataArray.add(newEncodedData)
			}
		}
		newEncodedDataArray.write(toFile: self.getHighScoresPath(), atomically: true)
		highScores = HighScores()
	}
	
	func initializeSetting() {
		let firstTimeQ = !self.createFilesIfNeeded()
		var selectModeQ = false
		var throwBackQ = false
		var keyData:Data!
		var codeData:Data!
		
		if (upgrading) {
			sendDataQ = true
			UserDefaults.standard.set(sendDataQ, forKey: "sendDataQ")
			UserDefaults.standard.set(upgraded, forKey: "upgraded")
			UserDefaults.standard.synchronize()
		} else if (firstTimeQ) {
			sendDataQ = true
			UserDefaults.standard.set(sendDataQ, forKey: "sendDataQ")
			selectModeQ = false
			UserDefaults.standard.set(selectModeQ, forKey: "selectModeShownQ")
			throwBackQ = false
			UserDefaults.standard.set(throwBackQ, forKey: "throwBackShownQ")
			mode = 3
			UserDefaults.standard.set(mode, forKey: "gameMode")
			checking = 0
			UserDefaults.standard.set(checking, forKey: "checking")
			bgTexture = 3
			UserDefaults.standard.set(bgTexture, forKey: "texture")
			axesQ = false
			UserDefaults.standard.set(axesQ, forKey: "axesQ")
			fontSelected = 1
			UserDefaults.standard.set(fontSelected, forKey: "font")
			sound = true
			UserDefaults.standard.set(sound, forKey: "sound")
			UserDefaults.standard.synchronize()
		} else {
			upgraded = UserDefaults.standard.bool(forKey: "upgraded")
			sendDataQ = UserDefaults.standard.bool(forKey: "sendDataQ")
			selectModeQ = UserDefaults.standard.bool(forKey: "selectModeShownQ")
			throwBackQ = UserDefaults.standard.bool(forKey: "throwBackShownQ")
			mode = UInt(UserDefaults.standard.integer(forKey: "gameMode"))
			checking = UserDefaults.standard.integer(forKey: "checking")
			bgTexture = UserDefaults.standard.integer(forKey: "texture")
			axesQ = UserDefaults.standard.bool(forKey: "axesQ")
			fontSelected = UserDefaults.standard.integer(forKey: "font")
			sound = UserDefaults.standard.bool(forKey: "sound")
			keyData = UserDefaults.standard.data(forKey: "key")
			codeData = UserDefaults.standard.data(forKey: "code")
			let keyLength = keyData.count
			let codeLength = codeData.count
			let keyCString = UnsafeMutablePointer<UInt8>.allocate(capacity: MemoryLayout<UInt8>.size * keyLength)
			let codeCString = UnsafeMutablePointer<UInt8>.allocate(capacity: MemoryLayout<UInt8>.size * codeLength)
			keyData.copyBytes(to: keyCString, from: 0..<keyLength)
			codeData.copyBytes(to: codeCString, from: 0..<codeLength)
			unlocked = false
		}
		
		let values2 = [upgraded, sound, fontSelected, mode ?? 0, checking, bgTexture, axesQ, firstTimeQ, throwBackQ, selectModeQ] as [Any]
		let keys2 = ["upgraded", "sound", "font", "gameMode", "checking", "texture", "axesQ", "firstTimeQ","throwBackShownQ", "selectModeShownQ"]
		let resourceDict = Dictionary(uniqueKeysWithValues: zip(keys2, values2))
		UserDefaults.standard.register(defaults: resourceDict)
		UserDefaults.standard.synchronize()
	}
	
}
