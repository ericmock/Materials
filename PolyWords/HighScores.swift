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
	var decodedScoreDataArray: NSMutableArray!
	var encodedScoreDataArray: NSMutableArray!
	var wordArray: [String]!
	
	init(withFile path:String, delegate d:AppController) {
		super.init()
		mode = 0
		score = 0
		time = 0
		appController = d
		self.filePath = path
		let rawData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
//		encodedScoreDataArray = try! PropertyListSerialization.propertyList(from: rawData, format: nil) as? [String]

//		for (key, value:Array) in encodedScoreDataArray {
//			if (key.count > 7) {
//				let decodedScores = decodeScore(arrayWithObjects: [value[2], value[3], value[4], value[5], value[6], value[7]])
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

let kScoreToObtainStatic = 0
let kStaticTimedMode = 0
let kStaticScoredMode = 1
let kDynamicTimedMode = 2
let kDynamicScoredMode = 3
let kTimeToCompleteStatic = 0
let kTimeToCompleteDynamic = 0
let kScoreToObtainDynamic = 0
	
	func checkLevelCompleted(num:NSNumber) -> Bool {
		print("into checkLevelCompleted:  \(num) of \(self.className)")
		var complete = false
		if (mode == kStaticTimedMode) {
			for array in (decodedScoreDataArray as! [NSArray]) {
				if num.isEqual(to: array.object(at: 1)),
					array.object(at: 1) as! Int >= kScoreToObtainStatic,
					array.object(at: 0) as! Int == mode {
						complete = true
					break
				}
			}
		} else if mode == kStaticScoredMode {
			for array in (decodedScoreDataArray as! [NSArray]) {
				if num.isEqual(to: array.object(at: 1)),
					(array.object(at: 1) as! Int) <= kTimeToCompleteStatic,
					array.object(at: 0) as! Int == mode {
						complete = true
					break
				}
			}
		} else if mode == kDynamicScoredMode {
			for array in (decodedScoreDataArray as! [NSArray]) {
				if num.isEqual(to: array.object(at: 1)),
					(array.object(at: 1) as! Int) <= kTimeToCompleteDynamic,
					array.object(at: 0) as! Int == mode {
						complete = true
					break
				}
			}
		} else if mode == kDynamicTimedMode {
			for array in (decodedScoreDataArray as! [NSArray]) {
				if num.isEqual(to: array.object(at: 1)),
					(array.object(at: 1) as! Int) >= kScoreToObtainDynamic,
					array.object(at: 0) as! Int == mode {
						complete = true
					break
				}
			}
		}
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
		
	func addScoreForPolyhedron(ofType type:Int, forMode newMode:Int, forTime newTime:Float, withScore newScore:Int) {
		print("into  addScoreForPolyhedronType:\(type) forMode:\(newMode) forTime:\(newTime) withScore:\(newScore) of \(self.className)")
		let data = encodeDataForPolyhedron(ofType: type, forMode: newMode, forTime: newTime, withScore: newScore)
		encodedScoreDataArray.add(data)
		decodedScoreDataArray.add([newMode, type, newTime, newScore])
		encodedScoreDataArray.write(toFile: filePath, atomically: true)
		decodedScoreDataArray.write(toFile: filePath+"_decoded", atomically: true)
	}
	
	func encodeDataForPolyhedron(ofType type:Int, forMode newMode:Int, forTime newTime:Float, withScore newScore:Int) -> NSArray {
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
		let tempArray = NSMutableArray()
		for array in (encodedScoreDataArray as! [NSArray]) {
			if (array.object(at: 0) as! Int) == type {
				tempArray.add(array)
			}
		}
		let thousandsEncoded:Float = tempArray[3] as! Float
		let hundredsEncoded:Float = tempArray[4] as! Float
		let tensEncoded:Float = tempArray[5] as! Float
		let onesEncoded:Float = tempArray[6] as! Float

		let thousands:Int = Int(round(10.0 * asin(thousandsEncoded)))
		let hundreds:Int = Int(round(10.0 * asin(hundredsEncoded)))
		let tens:Int = Int(round(10.0 * asin(tensEncoded)))
		let ones:Int = Int(round(10.0 * asin(onesEncoded)))
		
		let factor:Float = tempArray[1] as! Float
		let time_encoded = tempArray[2] as! Float
		
		time = factor * asin(time_encoded)
		score = 1000*thousands + 100*hundreds + 10*tens + ones

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
