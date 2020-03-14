//
//  HighScores.h
//  AlphaHedra
//
//  Created by Eric Mockensturm on 6/6/09.
//  Copyright 2009 Small Feats Software. All rights reserved.
//

import Foundation
import SQLite3

class HighScores : NSObject {
	var high_score: Int = 0
	var score: Int = 0
	var longest_word: Int = 0
	var max_occurences: Int = 0
	var best_word: Int = 0
	var mode: UInt = 0
	var time: Float = 0
	var filePath: String = ""
	var appController: AppController
	var decodedScoreDataArray:[[Any]] = [[]]
	var encodedScoreDataArray:[[Any]] = [[]]
	var wordArray: [String] = []
	var db:HighScoresDatabase!
	
	init (withAppController d:AppController) throws {
		appController = d
		super.init()
		openDatabase()
		
		let querySql = "select * from highScores;"
		guard let queryStatement = try? db.prepareStatement(sql: querySql) else {
			throw SQLiteError.Step(message: "Error")
		}
		defer {
			sqlite3_finalize(queryStatement)
		}
		print("Query Result:")
		
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			let polyhedronType = Int(sqlite3_column_int(queryStatement, 0))
			let mode = Int(sqlite3_column_int(queryStatement, 1))
			let score = Float(sqlite3_column_double(queryStatement, 2))
			print("type: \(polyhedronType), mode: \(mode), score: \(score)")
			encodedScoreDataArray.append([polyhedronType, mode, score])
		}
	}
	
	func openDatabase() {
		let dbPath = Bundle.main.resourceURL?.appendingPathComponent("highs.sqlite").absoluteString//directoryUrl?.appendingPathComponent("data.sqlite").relativePath
		
		do {
			db = try HighScoresDatabase.open(path: dbPath!)
			print("Successfully opened connection to database.")
		} catch SQLiteError.OpenDatabase(_) {
			print("Unable to open database.")
			return
		} catch {
			return
		}
	}

	func reset(withFile path:String, delegate d:AppController) {
		mode = 0
		score = 0
		time = 0
		appController = d
		filePath = path
		let rawData = Data()
		if let dataFileHandle = FileHandle(forReadingAtPath: filePath) {
			let rawData = dataFileHandle.readDataToEndOfFile()//Data(contentsOf: URL(fileURLWithPath: filePath))
		} else {
			//TODO:  Create the file
//			let rawData = Data()
		}
//		encodedScoreDataArray = try! (PropertyListSerialization.propertyList(from: rawData, format: nil) as? [[String]] ?? [[String]])
//
//		for encodedScoreData in encodedScoreDataArray {
//			if (encodedScoreData.count > 7) {
//				let decodedScores = decodeScore(arrayWithObjects: [encodedScoreData[2], encodedScoreData[3], encodedScoreData[4], encodedScoreData[5], encodedScoreData[6], encodedScoreData[7]])
//			}
//		}
	}
	
//		- (HighScores *) initializeWithFile:(NSString *)path appController:(AppController *)d  {
//			if ((self = [super init])) {
//				for (NSArray *array in encodedScoreDataArray) {
//					if ([array count] > 7) {  // old data files might have less data
//						NSArray *decodedScores = [self decodeScore:[NSArray arrayWithObjects:[array objectAtIndex:2], [array objectAtIndex:3], [array objectAtIndex:4], [array objectAtIndex:5], [array objectAtIndex:6], [array objectAtIndex:7], nil]];
//						[decodedScoreDataArray addObject:[NSArray arrayWithObjects:[array objectAtIndex:0], [array objectAtIndex:1], [decodedScores objectAtIndex:1], [decodedScores objectAtIndex:0], nil]];
//					}
//				}
//			}
//			return self;
//		}
//	}
	
	func getHighScoreForEachLevel() -> [Float] {
		var array:[Float] = []
		var counter = 1
		for tempDict in (appController.polyhedronInfoArray as! [NSDictionary]) {
			let num = getHighScore(forPolyhedron: tempDict.object(forKey: "polyID") as! Int)
			array.append(Float(counter))
			if num < Float.greatestFiniteMagnitude {
				array.append(num)
			} else {
				array.append(0)
			}
			counter += 1
		}
		return array
	}
	
	func letterUse() -> NSArray {
		var wordsFoundFileHandle:FileHandle
		if (mode == AppConstants.kDynamicTimedMode || mode == AppConstants.kDynamicScoredMode) {
			wordsFoundFileHandle = FileHandle(forReadingAtPath: appController.getDynamicWordsFoundPath()+"_string")!
		} else if (mode == AppConstants.kStaticTimedMode || mode == AppConstants.kStaticScoredMode) {
			wordsFoundFileHandle = FileHandle(forReadingAtPath: appController.getStaticWordsFoundPath()+"_string")!
		} else {
			wordsFoundFileHandle = FileHandle.nullDevice
		}
		
		let wordsFoundData = wordsFoundFileHandle.readDataToEndOfFile()
		let string = NSString(data: wordsFoundData, encoding: String.Encoding.utf8.rawValue)
		
		let array = NSMutableArray()
		let alphabet = "abcdefghijklmnopqrstuvwxyz"

		for letter in alphabet {
			let tok = string?.components(separatedBy: String(letter))
			array.add(tok?.count ?? 0)
		}
		return array
	}
	
	func getHighScore(forPolyhedron type:Int) -> Float {
		var highScore:Float = 0
		var count = 0
		for array in decodedScoreDataArray {
			if array[1] as! Int == type,
			array[3] as! Float > highScore,
				abs(array[2] as! Float - Float(AppConstants.kTimeToCompleteDynamic)) < 1.1,
				array[0] as! UInt == mode {
				highScore = array[3] as! Float
				count += 1
			}
		}
		return highScore
	}

	func getTimes(forPolyhedron type:Int) -> NSArray {
		let timeArray = NSMutableArray()
		for array in decodedScoreDataArray {
			if array[1] as! Int == type,
				array[0] as! UInt == AppConstants.kScoreToObtainDynamic {
				timeArray.add(array[2])
			}
		}
		return NSArray(array: timeArray)
	}

	func getScores(forPolyhedron type:Int) -> NSArray {
		let timeArray = NSMutableArray()
		for array in decodedScoreDataArray {
			if array[1] as! Int == type,
				array[0] as! UInt == mode {
				timeArray.add(array[3])
			}
		}
		return NSArray(array: timeArray)
	}
	
	func getAverageScore(forPolyhedron type:Int) -> NSArray {
		var totalScore:Int = 0
		var plays:Int = 0
		for array in decodedScoreDataArray {
			if array[1] as! Int == type,
				array[0] as! UInt == mode {
				totalScore += array[3] as! Int
				plays += 1
			}
		}
		return NSArray(array: [totalScore, plays])
	}
	
	func getAverageTime(forPolyhedron type:Int) -> NSArray {
		var totalTime:Float = 0
		var plays:Int = 0
		for array in decodedScoreDataArray {
			if array[1] as! Int == type,
				array[0] as! UInt == mode {
				totalTime += array[2] as! Float
				plays += 1
			}
		}
		return NSArray(array: [totalTime, plays])
	}
	
	func checkLevelCompleted(num:NSNumber) -> Bool {
//		print("into checkLevelCompleted:  \(num) of \(self.className)")
		var complete = false
/*		if (mode == AppConstants.kStaticTimedMode) {
			for array in decodedScoreDataArray {
				if num.isEqual(to: array[1]),
					Uarray[1] as! Int! >= AppConstants.kScoreToObtainStatic,
					Uarray[0] as! Int == mode {
						complete = true
					break
				}
			}
		}
		else if mode == AppConstants.kStaticScoredMode {
			for array in decodedScoreDataArray {
				let test = Float("3.14")
				if num.isEqual(to: array[1]),
					array[1] as! Float! <= AppConstants.kTimeToCompleteStatic,
					Uarray[0] as! Int == mode {
						complete = true
					break
				}
			}
		}
		else if mode == AppConstants.kDynamicScoredMode {
			for array in decodedScoreDataArray {
				if num.isEqual(to: array[1]),
					(array[1] as! Float)! <= AppConstants.kTimeToCompleteDynamic,
					Uarray[0] as! Int == mode {
						complete = true
					break
				}
			}
		}
		else if mode == AppConstants.kDynamicTimedMode {
			for array in decodedScoreDataArray {
				if num.isEqual(to: array[1]),
					(Uarray[1] as! Int)! >= AppConstants.kScoreToObtainDynamic,
					Uarray[0] as! Int == mode {
						complete = true
					break
				}
			}
		}*/
		return complete
	}
	
	func decodeScore(arrayWithObjects encodedScore:NSArray) -> NSArray {
		let factor:Float = encodedScore[0] as! Float
		let timeEncoded:Float = encodedScore[1] as! Float
		let thousandsEncoded:Float = encodedScore[2] as! Float
		let hundredsEncoded:Float = encodedScore[3] as! Float
		let tensEncoded:Float = encodedScore[4] as! Float
		let onesEncoded:Float = encodedScore[5] as! Float

		let thousands:Int = Int(round(10.0 * asin(thousandsEncoded)))
		let hundreds:Int = Int(round(10.0 * asin(hundredsEncoded)))
		let tens:Int = Int(round(10.0 * asin(tensEncoded)))
		let ones:Int = Int(round(10.0 * asin(onesEncoded)))

		let array = NSArray(array: [1000*thousands + 100*hundreds + 10*tens + ones, factor * asin(timeEncoded)])
		return array
	}
		
	func addScoreForPolyhedron(ofType type:Int, forMode newMode:UInt, forTime newTime:Float, withScore newScore:Int) {
		print("into  addScoreForPolyhedronType:\(type) forMode:\(newMode) forTime:\(newTime) withScore:\(newScore) of \(self.className)")
		let data = encodeDataForPolyhedron(ofType: type, forMode: newMode, forTime: newTime, withScore: newScore)
//		encodedScoreDataArray.append(data)
//		decodedScoreDataArray.append([newMode, type, newTime, newScore])
//		encodedScoreDataArray.write(toFile: filePath, atomically: true)
//		decodedScoreDataArray.write(toFile: filePath+"_decoded", atomically: true)
	}
	
	func encodeDataForPolyhedron(ofType type:Int, forMode newMode:UInt, forTime newTime:Float, withScore newScore:Int) -> NSArray {
		var score = newScore
		let thousands:Int = Int(score/1000)
		score -= 1000*thousands
		let hundreds:Int = Int(score/100)
		score -= 100*hundreds
		let tens:Int = Int(score/10)
		score -= 10*tens
		let ones:Int = Int(score)

		let thousands_encoded:Float = sin(Float(thousands)/10)
		let hundreds_encoded:Float = sin(Float(hundreds)/10)
		let tens_encoded:Float = sin(Float(tens)/10)
		let ones_encoded:Float = sin(Float(ones)/10)

		var factor:Float = 1.0
		while (newTime/factor > 1) {
			factor *= 10
		}
		let time_encoded = sin(newTime/factor)
		let array = NSArray(array:[newMode, type, factor, time_encoded, thousands_encoded, hundreds_encoded, tens_encoded, ones_encoded])
		return array
	}
	
	func getTopScores(forPolyhedronType type:Int) {
		print("int getTopScore for polyhedron type \(type) of \(self.className)")
		var tempArray:[[Any]] = [[]]
		
		for array in encodedScoreDataArray {
			if (array[0] as! Int) == type {
				tempArray.append(array)
			}
		}
//		let thousandsEncoded:Float = Float(tempArray[3])!
//		let hundredsEncoded:Float = Float(tempArray[4])!
//		let tensEncoded:Float = Float(tempArray[5])!
//		let onesEncoded:Float = Float(tempArray[6])!
//
//		let thousands:Int = Int(round(10.0 * asin(thousandsEncoded)))
//		let hundreds:Int = Int(round(10.0 * asin(hundredsEncoded)))
//		let tens:Int = Int(round(10.0 * asin(tensEncoded)))
//		let ones:Int = Int(round(10.0 * asin(onesEncoded)))
//
//		let factor:Float = Float(tempArray[1])!
//		let time_encoded = Float(tempArray[2])!
//
//		time = factor * asin(time_encoded)
//		score = 1000*thousands + 100*hundreds + 10*tens + ones

	}
	
}

/*
@property int high_score, score, longest_word, max_occurences, best_word;
@property float time;
@property uint mode;
@property (nonatomic, retain) NSMutableArray *decodedScoreDataArray, *wordArray;
@property (nonatomic, retain) NSString *filePath;

- (HighScores *) initializeWithFile:(NSString *)path appController:(AppController *)d;
- (void) addScoreForPolyhedronType:(int)polyhedron_type forMode:(int)newMode forTime:(float)newTime withScore:(int)newScore;
- (NSArray *) encodeDataForPolyhedronType:(int)polyhedron_type forMode:(int)newMode forTime:(float)newTime withScore:(int)newScore;
- (void) getTopScoresForPolyhedronType:(int)polyhedron_type;
- (BOOL) checkLevelCompleted:(NSNumber *)num;
- (NSNumber *) getFastestTimeForPolyhedron:(int) polyhedron_type;
- (NSArray *) getAverageTimeForPolyhedron:(int) polyhedron_type;
- (NSDictionary *) getInformationAboutPolyhedron:(int) polyhedron_type;
- (NSArray *) decodeScore:(NSArray *)encodedScore;
- (NSArray *) getFastestTimeForEachLevel;
- (NSDictionary *) getWordsForPolyhedron: (int) polyhedron_type ofLength: (int) length;
- (NSArray *) getCombinedWordLengths;
- (NSDictionary *) getWordsForPolyhedron: (int) polyhedron_type withScore: (int) word_score;
- (NSArray *) getCombinedWordScores;
- (NSArray *) getTimesForPolyhedron:(int) polyhedron_type;
- (NSArray *) getWordLengthsForPolyhedron: (int) polyhedron_type;
- (void) getWordsFoundArray;
- (NSArray *) getWordScoresForPolyhedron: (int) polyhedron_type;
- (NSArray *) getBestWordForPolyhedron:(int) polyhedron_type;
- (int) getBestWordFoundForPolyhedron:(int)polyhedron_type;
- (int) getLongestWordFoundForPolyhedron:(int)polyhedron_type;
- (NSArray *) getScoresForPolyhedron:(int) polyhedron_type;
- (NSArray *) getHighScoreForEachLevel;
- (NSNumber *) getHighScoreForPolyhedron:(int) polyhedron_type;
- (NSArray *) letterUse;
- (NSArray *) getAdventureHistoryArray;
- (NSArray *) getBestAdventureScores;
- (NSArray *) getAverageScoreForPolyhedron:(int) polyhedron_type;
@end
*/
