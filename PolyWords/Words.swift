//
//  Words.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import SQLite3

class Words : NSObject {
	let db:SQLiteDatabase_old!
	let delegate:GameScene!
	var gameScene:GameScene
	let deleteStatement = ""
	let insertStatament = ""
	let wordID = 0
	let word = ""
	//    let words:[NSString] = []
	
	init(withDB dbPath:String, withScene scene:GameScene, withDelegate delegate:GameScene) {
		self.gameScene = scene
		self.delegate = delegate
		do {
			db = try SQLiteDatabase_old.open(path: dbPath)
		} catch SQLiteError.OpenDatabase(_) {
			print("Unable to open database.")
			db = nil
		} catch {
			db = nil
		}
	}
	
	func finalizeStatements() {
		// TODO:  Add database interface code
		//+ (void) finalizeStatements {
		//    if(database) sqlite3_close(database);
		//    if(deleteStmt) sqlite3_finalize(deleteStmt);
		//    if(insertStmt) sqlite3_finalize(insertStmt);
		//}
		//
		//- (void) testMethod: (NSString *)string {
		////    NSLog(@"wordString = %@",string);
		//}
		//
		
	}
	
	func getValidChains(startingWithPolygon poly:Apolygon) -> NSArray {
		return NSArray()
	}
	
	func findWordsStarting(withPolygon poly:Apolygon) -> NSArray {
		let foundWords = NSMutableArray(capacity: 5)
		let foundWordChains = NSMutableArray(capacity: 5)
		let validStuff = self.getValidChains(startingWithPolygon: poly)
		
		let validChains:NSMutableArray = (validStuff.object(at: 0) as! NSArray).mutableCopy() as! NSMutableArray
		let validWords:NSMutableArray = (validStuff.object(at: 1) as! NSArray).mutableCopy() as! NSMutableArray
		
//		var s = ""
//		var newString = ""
		
		while (validChains.count > 0) {
			let chain = validChains.lastObject as! NSArray
			let words = validWords.lastObject as! NSArray
			var string = ""
			for poly in chain as! [Apolygon] {
				string.append(poly.letter.lowercased())
			}
			if words.contains(string) {
				if !foundWords.contains(string) {
					foundWords.add(string)
					foundWordChains.add(chain)
				}
			}
			
			let chain_size = chain.count
			let substrings = NSMutableArray(capacity: words.count)
			for s in words as! [String] {
				if s.count > chain_size {
					let index = s.index(s.startIndex, offsetBy: chain_size + 1)
					substrings.add(s[..<index])
				}
			}
			let lastPoly = chain.lastObject as! Apolygon
			for nextPoly in lastPoly.connections {
				if !chain.contains(nextPoly) {
					var tempString = String(string)
					tempString.append(nextPoly.letter.lowercased())
					let newString = String(tempString)
					if words.contains(newString) {
						if !foundWords.contains(newString) {
							foundWords.add(newString)
							let chainMutable = chain.mutableCopy() as! NSMutableArray
							chainMutable.add(nextPoly)
							foundWordChains.add(chainMutable)
						}
					}
					if substrings.contains(newString) {
						validChains.insert((chain.mutableCopy() as! NSMutableArray).add(nextPoly), at: 0)
						validWords.insert(words, at: 0)
					}
				}
			}
			
			validChains.removeLastObject()
			validWords.removeLastObject()
		}
		
		return NSArray(array: [foundWords, foundWordChains])
	}
	
	func selectWords(forString string:String) -> String {
		let len = string.count
		var sqlString = ""
		if (len <= 6) {
			sqlString = "select rowid, word from words\(len) where word = \(string)"
		} else {
			sqlString = "select id, word from words where word = \(string)"
		}
		
		// TODO:  Add database query code
		gameScene.words = db.select(withStatement: sqlString) ?? [""]
		
		self.performSelector(onMainThread: #selector(setter: gameScene.lookingUpWordsQ), with: false, waitUntilDone: Bool(false), modes: nil)
		//    const char *sql = [sqlString cStringUsingEncoding: NSASCIIStringEncoding];
		//    sqlite3_stmt *selectstmt;
		//    if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
		//        while(sqlite3_step(selectstmt) == SQLITE_ROW) {
		//            word = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
		//            [delegate addWord:word];
		////            counter++;
		//        }
		////        gettimeofday(&tv2, &tz);
		////        NSLog(@"build array time,%5.6f",(double)(tv2.tv_sec - tv1.tv_sec) + (double)(tv2.tv_usec - tv1.tv_usec) * 0.000001l);
		////        NSLog(@"words found,%d",counter);
		//    }

		return ""
	}
	
	func deleteWord() {
		//Do we need/use this??
		//- (void) deleteWord {
		//    if(deleteStmt == nil) {
		//        const char *sql = "delete from words where wordID = ?";
		//        if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
		//            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
		//    }
		//    sqlite3_bind_int(deleteStmt, 1, wordID);
		//    if (SQLITE_DONE != sqlite3_step(deleteStmt))
		//        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
		//    sqlite3_reset(deleteStmt);
		//}
		//
	}
	
	func insertWord() {
		//Do we need/use this?
		//- (void) insertWord {
		//    if(insertStmt == nil) {
		//        const char *sql = "insert into words (word) Values (?)";
		//        if(sqlite3_prepare_v2(database, sql, -1, &insertStmt, NULL) != SQLITE_OK)
		//            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
		//    }
		//    sqlite3_bind_text(insertStmt, 1, [word UTF8String], -1, SQLITE_TRANSIENT);
		//    if(SQLITE_DONE != sqlite3_step(insertStmt))
		//        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		//    else
		//        wordID = sqlite3_last_insert_rowid(database);
		//    sqlite3_reset(insertStmt);
		//}
	}
	
	func lookingUpWordwQ(_ q:Bool) {
		delegate.lookingUpWordsQ = q
		if !q {
			delegate.checkMatch()
		}
	}
	
	func words(startingWithString string:String) -> NSArray {
		let len = string.count
		var sqlString = String()
		let wordsFound = NSMutableArray()
		
//		static sqlite3_stmt *selectstmt = nil;
		sqlString = "select word from words_all where idx\(len) = '\(string.lowercased())'"
//		const char *sql = [sqlString cStringUsingEncoding: NSUTF8StringEncoding];
//		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
//			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
//				[wordsFound addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)]];
//			}
//		}
//		if (selectstmt) sqlite3_finalize(selectstmt);
		return NSArray(array: [wordsFound])

	}
}
