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
}

class AppController: AppDelegate {
	
	let screenRect:CGRect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(10.0), height: CGFloat(10.0))
	let darkColor:NSColor = NSColor(red: 43.0/256.0, green: 34.0/256.0, blue: 20.0/256.0, alpha: 1.0)
	var polyhedronInfoArray:NSMutableArray?
	var polyhedraInfo:NSDictionary?
	let polyhedronArray = NSMutableArray()
	let polyhedronNamesArray = NSMutableArray()
	let polyhedronNumbersArray = NSMutableArray()
	let polyhedronLevelsArray = NSMutableArray()
	lazy var highScores:HighScores = HighScores()
	var highest_completed = repeatElement(UInt(), count: 4)
	var accelQ = false
	var recordTimeQ = true
	var continuingQ = false
	var purchasingQ = false
	var connection_failed = false
	var resign_state = 0
	let wordNumbers = ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven"]
	let alphabetArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	let nowTime = Date()
	var mode:UInt!
	var unlocked = true
	var upgrading = true
	var sendDataQ = true
	var upgraded = true
	var levelAborted = false
	var checking = 0
	var bgTexture = 3
	var axesQ = false
	var fontSelected = 1
	var sound = true
	var adSize:CGSize!
	var textures = UnsafeMutablePointer<UInt>.allocate(capacity: numPolygonTypes + 5)
	var textureExists = [Bool](repeating: false, count: numPolygonTypes + 5)
	var gameViewInitializedQ = false
	let polyWordsView:PolyWordsView!
	var polyWordsViewController:PolyWordsViewController!
	var level:UInt = 0
	var level_aborted = false
	var level_completed = false
	var game_id:UInt = 0
	let swipeSound:NSSound = NSSound(contentsOfFile: Bundle.main.path(forResource: "Select", ofType: "caf")!, byReference: false)!
	var wordString:String = ""
	var currentAlertView:NSResponder!
	var upgradeDelegate:UpgradeDelegate!
	var highScore:HighScores!
	var send_data_q = false

	required init(aCoder:NSCoder) {
		polyWordsView = PolyWordsView(coder: aCoder)
		super.init()
	}
	
	func removeAllStoredData() {
		
	}
	
	func initializeGame() {
		
	}
	
	func loadData(forMode mode:UInt) {
		var saveData = NSArray()
		switch mode {
		case AppConstants.kStaticTimedMode:
			saveData = NSArray.init(contentsOfFile: self.getStaticTimedSavePath())!
			break
		case AppConstants.kStaticScoredMode:
			saveData = NSArray.init(contentsOfFile: self.getStaticScoredSavePath())!
			break
		case AppConstants.kDynamicTimedMode:
			saveData = NSArray.init(contentsOfFile: self.getDynamicTimedSavePath())!
			break
		case AppConstants.kDynamicScoredMode:
			saveData = NSArray.init(contentsOfFile: self.getDynamicScoredSavePath())!
			break
		default:
			break
		}
		self.removeAllStoredData()
		if !gameViewInitializedQ {
			self.initializeGame()
		}
		self.mode = mode
		let decodedDataArray = EncodeDecode.decode(gameData: saveData, withTimeHistory:polyWordsView.timeHistory, withWordsFound:polyWordsView.wordsFound)
		polyWordsView.score = decodedDataArray.object(at: 0) as! Int
		polyWordsView.playTime = decodedDataArray.object(at: 1) as! Float
		polyWordsView.lastSubmitTime = decodedDataArray.object(at: 1) as! Float
		continuingQ = true
		polyhedraInfo = saveData.object(at: 0) as? NSDictionary
		polyWordsView.selectPolyhedron(withInfo: polyhedraInfo!)
		
		var ii = 0
		for num in decodedDataArray.object(at: 2) as! [Int] {
			polyWordsView.assignLetter(with: num, toPolyNumber: ii)
			ii += 1
		}
	}
	
	func copyDatabasesIfNeeded() {
		let fileManager = FileManager()
//		var error:NSError
		var dbPath:String
		var success:Bool
//		var defaultDBPath:String
		
		dbPath = self.getWordDBPath()
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
		var filePath = self.getHighWordsPath()
		var success = fileManager.fileExists(atPath: filePath)
		let numPolyhedra:Int = polyhedronInfoArray!.count
		
		if !success {
			let tempArray = NSMutableArray(capacity: numPolyhedra)
			for ii in 0..<numPolyhedra {
				tempArray.add([ii, "", 0.0, 0.0, 0.0])
			}
			tempArray.write(toFile: filePath, atomically: true)
		}
		
		filePath = self.getHighScoresPath()
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			let tempArray = NSMutableArray(capacity: numPolyhedra)
			for ii in 0..<numPolyhedra {
				tempArray.add([ii, 0.0, 0.0, 0.0, 0.0, 0.0])
			}
			tempArray.write(toFile: filePath, atomically: true)
		}
		
		filePath = self.getStaticWordsFoundPath()
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			let tempArray = NSArray()
			tempArray.write(toFile: filePath, atomically: true)
		}

		filePath = self.getDynamicWordsFoundPath()
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			let tempArray = NSArray()
			tempArray.write(toFile: filePath, atomically: true)
		}

		filePath = self.getDynamicWordsFoundPath() + "_string"
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}

		filePath = self.getAdventureScorePath() + "_string"
		success = fileManager.fileExists(atPath: filePath)
		if !success {
			fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
		}

		filePath = self.getStaticWordsFoundPath() + "_string"
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
				let newEncodedData = highScores.encodeDataForPolyhedron(ofType: newDecodedData.object(at: 1) as! Int, forMode: UInt(newDecodedData.object(at: 0) as! Int), forTime: newDecodedData.object(at: 3) as! Float, withScore: newDecodedData.object(at: 2) as! Int)
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
	
	func initializePolyhedronInfo() {
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
	
	func startGame() {
		if !continuingQ {
			polyWordsView.playTime = 0.0
			polyWordsView.lastSubmitTime = 0.0
			levelAborted = false
		}
		
		if polyhedraInfo != nil {
			self.level = polyhedraInfo?.object(forKey: "level") as! UInt
			recordTimeQ = true
//			if (aNavigationController.visibleViewController != alphaHedraViewController)
//				[aNavigationController pushViewController:alphaHedraViewController animated:NO];
//			else
//				[alphaHedraViewController startGame];
		}
	}
	
	func resetGame() {
		polyWordsView.wordString = ""
		polyWordsView.score = 0
		polyWordsView.opponent_score = 0
		polyWordsView.word_score = 0
		polyWordsView.points_avail = 0
		polyWordsView.points_avail_display = 0
		polyWordsView.show_get_ready = true
		polyWordsView.opponent_ready = false
		self.level_aborted = false
		self.level_completed = false
		polyWordsView.wordsFound = NSMutableArray()
		polyWordsView.wordScores = NSMutableArray()
		polyWordsView.wordsFoundOpponent = NSMutableArray()
		polyWordsView.wordScoresOpponent = NSMutableArray()
		polyWordsView.timeHistory = NSMutableArray()
		polyWordsView.oldWordsFound = NSMutableArray()
		polyWordsView.playTime = 0.0
		polyWordsView.lastSubmitTime = 0.0
		polyWordsView.setWorldRotation(angle:0.0, X:0.0, Y:0.0, Z:1.0)
		polyWordsView.setRotation(angle:0.0, X:0.0, Y:0.0, Z:1.0)
		polyWordsView.endSpin()
//TODO		polyWordsViewController.gameState = kGameStart
	}
}
