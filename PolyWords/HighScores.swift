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
	var high_score: Int!
	var score: Int!
	var longest_word: Int!
	var max_occurences: Int!
	var best_word: Int!
	var mode: UInt!
	var time: Float!
	var filePath: String!
	var appController: AppController!
	var decodedScoreDataArray:[[String]]!
	var encodedScoreDataArray:[[String]]!
	var wordArray: [String]!
	
	
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
	
	func getHighScoreForEachLevel() -> NSArray {
		let array = NSMutableArray()
		var counter = 1
		for tempDict in (appController.polyhedronInfoArray as! [NSDictionary]) {
			let num = getHighScore(forPolyhedron: tempDict.object(forKey: "polyID") as! Int)
			array.add(Float(counter))
			if num < Float.greatestFiniteMagnitude {
				array.add(num)
			} else {
				array.add(0)
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
			if Int(array[1]) == type,
			array[3] as! Float > highScore,
				abs(array[2] as! Float - Float(AppConstants.kTimeToCompleteDynamic)) < 1.1,
				UInt(array[0]) == mode {
				highScore = array[3] as! Float
				count += 1
			}
		}
		return highScore
	}

	func getTimes(forPolyhedron type:Int) -> NSArray {
		let timeArray = NSMutableArray()
		for array in decodedScoreDataArray {
			if Int(array[1]) == type,
				UInt(array[0]) == AppConstants.kScoreToObtainDynamic {
				timeArray.add(array[2])
			}
		}
		return NSArray(array: timeArray)
	}

	func getScores(forPolyhedron type:Int) -> NSArray {
		let timeArray = NSMutableArray()
		for array in decodedScoreDataArray {
			if Int(array[1]) == type,
				UInt(array[0]) == mode {
				timeArray.add(array[3])
			}
		}
		return NSArray(array: timeArray)
	}
	
	func getAverageScore(forPolyhedron type:Int) -> NSArray {
		var totalScore:Int = 0
		var plays:Int = 0
		for array in decodedScoreDataArray {
			if Int(array[1]) == type,
				UInt(array[0]) == mode {
				totalScore += Int(array[3])!
				plays += 1
			}
		}
		return NSArray(array: [totalScore, plays])
	}
	
	func getAverageTime(forPolyhedron type:Int) -> NSArray {
		var totalTime:Float = 0
		var plays:Int = 0
		for array in decodedScoreDataArray {
			if Int(array[1]) == type,
				UInt(array[0]) == mode {
				totalTime += Float(array[2])!
				plays += 1
			}
		}
		return NSArray(array: [totalTime, plays])
	}
	
	func checkLevelCompleted(num:NSNumber) -> Bool {
		print("into checkLevelCompleted:  \(num) of \(self.className)")
		var complete = false
/*		if (mode == AppConstants.kStaticTimedMode) {
			for array in decodedScoreDataArray {
				if num.isEqual(to: array[1]),
					UInt(array[1])! >= AppConstants.kScoreToObtainStatic,
					UInt(array[0]) == mode {
						complete = true
					break
				}
			}
		}
		else if mode == AppConstants.kStaticScoredMode {
			for array in decodedScoreDataArray {
				let test = Float("3.14")
				if num.isEqual(to: array[1]),
					Float(array[1])! <= AppConstants.kTimeToCompleteStatic,
					UInt(array[0]) == mode {
						complete = true
					break
				}
			}
		}
		else if mode == AppConstants.kDynamicScoredMode {
			for array in decodedScoreDataArray {
				if num.isEqual(to: array[1]),
					(Float(array[1]))! <= AppConstants.kTimeToCompleteDynamic,
					UInt(array[0]) == mode {
						complete = true
					break
				}
			}
		}
		else if mode == AppConstants.kDynamicTimedMode {
			for array in decodedScoreDataArray {
				if num.isEqual(to: array[1]),
					(UInt(array[1]))! >= AppConstants.kScoreToObtainDynamic,
					UInt(array[0]) == mode {
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
		var tempArray:[[String]] = [[]]
		
		for array in encodedScoreDataArray {
			if (Int(array[0])) == type {
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
