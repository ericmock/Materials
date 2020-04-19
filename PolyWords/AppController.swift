import Foundation
import Cocoa

let numPolygonTypes = 15
struct AppConstants {
	static let kScoreToObtainStatic:UInt = 0
	static let kStaticTimedMode:UInt = 0
	static let kStaticScoredMode:UInt = 1
	static let kDynamicTimedMode:UInt = 2
	static let kDynamicScoredMode:UInt = 3
	static let kTwoPlayerClientMode:UInt = 4
	static let kTwoPlayerServerMode:UInt = 5
	static let kTimeToCompleteStatic:Float = 0
	static let kTimeToCompleteDynamic:Float = 0
	static let kScoreToObtainDynamic:UInt = 0
	static let kGameStart:UInt = 0
	static let kGameRestart:UInt = 1
	static let kGameContinue:UInt = 1
	static let kPolygonTypeNames = ["triangle", "square", "pentagon", "hexagon", "heptagon", "octagon", "decagon", "twelvegon", "square_2", "square_3", "square_4", "triangle_2", "triangle_3", "triangle_4"]
	static let kPolygonTypesVertexCount = [3, 4, 5, 6, 7, 8, 10, 12, 4, 4, 4, 3, 3, 3]

	static let kPolyhedronNames:[String] = ["Truncated Icosahedron",
						 "Parabigyrate Rhombicosidodecahedron",
						 "Parabidiminished Rhombicosidodecahedron",
						 "Deca-faced Polyhedron",
						 "Rhombic Triacontahedron",
						 "Great Dodecacronic Hexecontahedron",
						 "Truncated Dodecahedron",
						 "Octagon-Drilled Truncated Cuboctahedron",
						 "Rhombicosidodecahedron",
						 "Truncated Truncated Icosahedron",
						 "Drilled Truncated Cube",
						 "Truncated Cuboctahedron",
						 "Gyroelongated Square Bicupola",
						 "Nameless Blob",
						 "Stewart K4'",
						 "Pentagonal Orthobirotunda",
						 "Truncated Icosidodecahedron",
						 "Gyroelongated Pentagonal Rotunda",
						 "Drilled Truncated Dodecahedron",
						 "Half-truncated Truncated Icosahedron",
						 "Truncated Octahedron 8",
						 "Truncated Octahedron",
						 "Strombic Hexecontahedron",
						 "Disdyakisdodecahedron",
						 "Antiprism-Extended Dodecahedrahedron Ring",
						 "Gyro-Expanded Cuboctahedron",
						 "Tetrakishexahedron",
						 "Icosahedra 8-ring",
						 "Cupola-Drilled Truncated Icosidodecahedron",
						 "Gyro-Double-Expanded Cuboctahedron",
						 "Rotunda-Drilled Truncated Icosidodecahedron",
						 "Prism-Expanded Truncated Cube",
						 "Eight-Octahedron Ring",
						 "Torus Slice",
						 "Gyroelongated Pentagonal Cupola"]
	static let kNumPolygonTypes = 15
	static let kWordNumbers = ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven"]
	static let kAlphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	static let kCommonLetters = ["A", "E", "I", "O", "T", "N"]
	static let kUncommonLetters = ["J", "Q", "X", "Z"]
	static let kLetterValues:[Int] = [1, 3, 2, 2, 1, 2, 2, 1, 1, 4, 3, 2, 2, 1, 1, 3, 4, 1, 1, 1, 2, 3, 2, 4, 3, 4]
}

class AppController: AppDelegate {
	
	let screenRect:CGRect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(10.0), height: CGFloat(10.0))
	let darkColor:NSColor = NSColor(red: 43.0/256.0, green: 34.0/256.0, blue: 20.0/256.0, alpha: 1.0)
	static var polyhedraInfo:[Dictionary<String,Any>] = []
	static var polyhedronInfo:Dictionary<String,Any> = [:]
//	var polyhedronInfo:NSDictionary?
	var polyhedra:[Any] = []
	var polyhedronNames:[String] = []
	var polyhedronNumbers:[Int] = []
	var polyhedronLevels:[Int] = []
//	static var highScores:HighScores = HighScores()
	static var highest_completed = repeatElement(UInt(), count: 4)
	var accelQ = false
	var recordTimeQ = true
	var continuingQ = false
	var purchasingQ = false
	var connection_failed = false
	var resign_state = 0
//	let nowTime = Date()
//	var mode:UInt = 0
//	var polyWordsViewController:PolyWordsViewController!
//	var level:UInt = 0
//	var level_aborted = false
//	var level_completed = false
//	var game_id:UInt = 0
	static let swipeSound:NSSound = NSSound(contentsOfFile: Bundle.main.path(forResource: "swipe", ofType: "caf")!, byReference: false)!
	static let touchSound:NSSound = NSSound(contentsOfFile: Bundle.main.path(forResource: "Select", ofType: "caf")!, byReference: false)!
	static let wordSound:NSSound = NSSound(contentsOfFile: Bundle.main.path(forResource: "word", ofType: "caf")!, byReference: false)!
	var wordString:String = ""
	var currentAlertView:NSResponder!
	var upgradeDelegate:UpgradeDelegate!
	var send_data_q = false
	var letterString = ""
	static var unlocked = true
	var checking = 0
	var bgTexture = 0
	var sendDataQ = false
	var axesQ = false
	var fontSelected = 0
	var textureExists:[Bool] = []
	var gameViewInitializedQ = false
	var upgrading = false
	var sound = true
	static var upgraded = false
	static var gameMode = 0
	static var gameViewInitialized = false

//	required init(coder aCoder: NSCoder) {
	override init() {
		super.init()
		AppController.initializePolyhedraInfo()
//		do {
//			AppController.highScores = try HighScores()
//		} catch {
//			print("Error initializing high scores database.")
//			return
//		}
	}
	
	static func initializeGame() {
		
	}
	
	static func resetGame() {
		
	}
	
	func loadData(forMode mode:UInt) {
		var saveData = NSArray()
		switch mode {
		case AppConstants.kStaticTimedMode:
			saveData = NSArray.init(contentsOfFile: AppController.getStaticTimedSavePath())!
			break
		case AppConstants.kStaticScoredMode:
			saveData = NSArray.init(contentsOfFile: AppController.getStaticScoredSavePath())!
			break
		case AppConstants.kDynamicTimedMode:
			saveData = NSArray.init(contentsOfFile: AppController.getDynamicTimedSavePath())!
			break
		case AppConstants.kDynamicScoredMode:
			saveData = NSArray.init(contentsOfFile: AppController.getDynamicScoredSavePath())!
			break
		default:
			break
		}
		AppController.removeAllStoredData()
		if !gameViewInitializedQ {
			AppController.self.initializeGame()
		}
//		self.mode = mode
//		let decodedDataArray = EncodeDecode.decode(gameData: saveData, withTimeHistory:gameScene!.timeHistory, withWordsFound:gameScene.wordsFound)
//		gameScene.score = decodedDataArray.object(at: 0) as! Int
//		gameScene.playTime = decodedDataArray.object(at: 1) as! Float
//		gameScene.lastSubmitTime = decodedDataArray.object(at: 1) as! Float
//		continuingQ = true
//		polyhedraInfo = saveData.object(at: 0) as? Dictionary
//		gameScene.selectPolyhedron(withInfo: polyhedraInfo!)
//
//		var ii = 0
//		for num in decodedDataArray.object(at: 2) as! [Int] {
//			polyWordsView.assignLetter(toPolygon: ii, ofType: -1, withNumber: num)
//			ii += 1
//		}
	}
	
	func copyDatabasesIfNeeded() {
		let fileManager = FileManager()
//		var error:NSError
		var dbPath:String
		var success:Bool
//		var defaultDBPath:String
		
		dbPath = AppController.getWordDBPath()
		success = fileManager.fileExists(atPath: dbPath)
		if !success {
			let defaultDBPath = Bundle.main.resourcePath! + "wordlist.sqlite"
			do {
				try fileManager.copyItem(atPath: defaultDBPath, toPath: dbPath)
			} catch {
				print("Failed to create writable database file.")
			}
		}
	}
	
	func createFilesIfNeeded() -> Bool {
		let fileManager = FileManager()
		var filePath = AppController.getHighWordsPath()
		var success = fileManager.fileExists(atPath: filePath)
		let numPolyhedra:Int = AppController.polyhedraInfo.count
		
		if !success {
			let tempArray = NSMutableArray(capacity: numPolyhedra)
			for ii in 0..<numPolyhedra {
				tempArray.add([ii, "", 0.0, 0.0, 0.0])
			}
			tempArray.write(toFile: filePath, atomically: true)
		}
		
		filePath = AppController.getHighScoresPath()
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			let tempArray = NSMutableArray(capacity: numPolyhedra)
			for ii in 0..<numPolyhedra {
				tempArray.add([ii, 0.0, 0.0, 0.0, 0.0, 0.0])
			}
			tempArray.write(toFile: filePath, atomically: true)
		}
		
		filePath = AppController.getStaticWordsFoundPath()
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			let tempArray = NSArray()
			tempArray.write(toFile: filePath, atomically: true)
		}

		filePath = AppController.getDynamicWordsFoundPath()
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			let tempArray = NSArray()
			tempArray.write(toFile: filePath, atomically: true)
		}

		filePath = AppController.getDynamicWordsFoundPath() + "_string"
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}

		filePath = AppController.getAdventureScorePath() + "_string"
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}

		filePath = AppController.getStaticWordsFoundPath() + "_string"
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
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
	
//	func anchorPoint() -> CGPoint {
//		let anchorPoint:CGPoint
//		if adSize.height > 50 {
//			anchorPoint = CGPoint(x: 0.0, y: self.screenRect.size.height + adSize.height)
//		} else {
//			anchorPoint = CGPoint(x: 0.0, y: self.screenRect.size.height)
//		}
//		return anchorPoint
//	}
	
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
	
	static func getHighScoresPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"high_scores"
		return fullPath
	}
	
	static func getHighWordsPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"high_words"
		return fullPath
	}
	
	static func getAdventureScorePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"adv_score"
		return fullPath
	}
	
	static func getStaticWordsFoundPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"static_words_found"
		return fullPath
	}
	
	static func getDynamicWordsFoundPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"dynamic_words_found"
		return fullPath
	}
	
	static func getStaticSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"bg_data"
		return fullPath
	}

	static func getStaticScoredSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"ss_data"
		return fullPath
	}

	static func getStaticTimedSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"st_data"
		return fullPath
	}

	static func getDynamicScoredSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"ds_data"
		return fullPath
	}

	static func getDynamicTimedSavePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"dt_data"
		return fullPath
	}

	static func getScoreDBPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"data.sqlite"
		return fullPath
	}

	static func getWordDBPath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let fullPath = paths[0]+"wordlist.sqlite"
		return fullPath
	}
	
	static func removeAllStoredData() {
		
	}

	func upgradeFromTwoPointOne() {
//		guard let oldEncodedDataArray = NSArray(contentsOfFile: AppController.getHighScoresPath()) else { return }
//		let newEncodedDataArray = NSMutableArray(capacity: 3)
//		for oldEncodedData in oldEncodedDataArray where oldEncodedData is NSArray {
//			if (oldEncodedData as AnyObject).count <= 7 {
//				let newDecodedData = self.decodeConvert(oldScores: oldEncodedData as! NSArray)
//				let newEncodedData = AppController.highScores.encodeDataForPolyhedron(ofType: newDecodedData.object(at: 1) as! Int, forMode: UInt(newDecodedData.object(at: 0) as! Int), forTime: newDecodedData.object(at: 3) as! Float, withScore: newDecodedData.object(at: 2) as! Int)
//				newEncodedDataArray.add(newEncodedData)
//			}
//		}
//		newEncodedDataArray.write(toFile: AppController.getHighScoresPath(), atomically: true)
//		do {
//			AppController.highScores = try HighScores()
//		} catch {
//			print("Error initializing high scores database.")
//			return
//		}
	}
	
	func initializeSetting() {
		let firstTimeQ = true//!self.createFilesIfNeeded()
		var selectModeQ = false
		var throwBackQ = false
		var keyData:Data!
		var codeData:Data!
		var mode:Int = 0
		
		if (upgrading) {
			sendDataQ = true
			UserDefaults.standard.set(sendDataQ, forKey: "sendDataQ")
			UserDefaults.standard.set(AppController.upgraded, forKey: "upgraded")
			UserDefaults.standard.synchronize()
		} else if (firstTimeQ) {
			sendDataQ = true
			UserDefaults.standard.set(sendDataQ, forKey: "sendDataQ")
			selectModeQ = false
			UserDefaults.standard.set(selectModeQ, forKey: "selectModeShownQ")
			throwBackQ = false
			UserDefaults.standard.set(throwBackQ, forKey: "throwBackShownQ")
			let mode = 3
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
			AppController.upgraded = UserDefaults.standard.bool(forKey: "upgraded")
			sendDataQ = UserDefaults.standard.bool(forKey: "sendDataQ")
			selectModeQ = UserDefaults.standard.bool(forKey: "selectModeShownQ")
			throwBackQ = UserDefaults.standard.bool(forKey: "throwBackShownQ")
			mode = UserDefaults.standard.integer(forKey: "gameMode")
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
			AppController.unlocked = false
		}
		
		let values2 = [AppController.upgraded, sound, fontSelected, mode, checking, bgTexture, axesQ, firstTimeQ, throwBackQ, selectModeQ] as [Any]
		let keys2 = ["upgraded", "sound", "font", "gameMode", "checking", "texture", "axesQ", "firstTimeQ","throwBackShownQ", "selectModeShownQ"]
		let resourceDict = Dictionary(uniqueKeysWithValues: zip(keys2, values2))
		UserDefaults.standard.register(defaults: resourceDict)
		UserDefaults.standard.synchronize()
	}
	
	static func initializePolyhedraInfo() {
		var polyhedra:[Any]
		var polyhedraNames:[String] = []
		var polyhedraLevels:[Int] = []
		var polyhedraNumbers:[Int] = []
		if AppController.unlocked {
			polyhedra = ["Truncated Icosahedron", 2, 1,
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
								 "Gyroelongated Pentagonal Cupola", 22, 35]
		}	else {
			polyhedra = ["Truncated Icosahedron", 2, 1,
								 "Parabigyrate Rhombicosidodecahedron", 14, 2,
								 "Parabidiminished Rhombicosidodecahedron", 16, 3,
								 "Deca-faced Polyhedron", 20, 4,
								 "Rhombic Triacontahedron", 23, 5,
								 "Great Dodecacronic Hexecontahedron", 25, 6,
								 "Truncated Dodecahedron", 24, 7,
								 "Octagon-Drilled Truncated Cuboctahedron", 11, 8,
								 "Rhombicosidodecahedron", 12, 9,
								 "Truncated Truncated Icosahedron", 26, 10]
		}
		
		for ii in stride(from: 0, through: polyhedra.count - 1, by: 3) {
			polyhedraNames.append(polyhedra[ii] as! String)
		}
		
		for ii in stride(from: 1, through: polyhedra.count - 1, by: 3) {
			polyhedraNumbers.append(polyhedra[ii] as! Int)
		}
		
		for ii in stride(from: 2, through: polyhedra.count - 1, by: 3) {
			polyhedraLevels.append(polyhedra[ii] as! Int)
		}
		
//		var polyhedraInfo:[Dictionary<String,Any>] = []

		var loc:Int
		var polyID:Int
		let completed = [false, false, false, false]
		for ii in 0..<polyhedraLevels.count - 1 {
			loc = polyhedraLevels[ii]
			polyID = polyhedraNumbers[loc]
//			for jj in 0..<4 {
//				highScores.mode = UInt(jj)
//				completed[jj] = highScores.checkLevelCompleted(num: polyID)
//				if completed[jj],
//					ii > AppController.highest_completed[jj] {
//				}
//			}
			let values:[Any] = [polyhedraNames[loc], polyID, [completed[0],completed[1],completed[2],completed[3],true,true],ii]
			let keys = ["name", "polyID", "completed", "level"]
			let dict = Dictionary(uniqueKeysWithValues: zip(keys, values))
			AppController.polyhedraInfo.append(dict)
		}
//		highScores.mode = mode
	}
	
	@objc func startGame() {
//		if !continuingQ {
//			gameScene.playTime = 0.0
//			gameScene.lastSubmitTime = 0.0
//			levelAborted = false
//		}
		
//		if polyhedraInfo != nil {
//			self.level = polyhedraInfo?.object(forKey: "level") as! UInt
//			recordTimeQ = true
//			if (aNavigationController.visibleViewController != alphaHedraViewController)
//				[aNavigationController pushViewController:alphaHedraViewController animated:NO];
//			else
//				[alphaHedraViewController startGame];
//		}
	}
	
}
