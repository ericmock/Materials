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
    let db:SQLiteDatabase!
    var gameScene:Scene
    let deleteStatement = ""
    let insertStatament = ""
    let wordID = 0
    let word = ""
//    let words:[NSString] = []
    
    init(withDB dbPath:String, scene:Scene) {
        self.gameScene = scene
        do {
            db = try SQLiteDatabase.open(path: dbPath)
        } catch SQLiteError.OpenDatabase(_) {
            print("Unable to open database.")
            db = nil
        } catch {
            db = nil
        }
    }

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
    
    func selectWords(forString string:NSString) {
        let len = string.length
        var sqlString = ""
        if (len <= 6) {
            sqlString = "select rowid, word from words\(len) where word = \(string)"
        } else {
            sqlString = "select id, word from words where word = \(string)"
        }

        gameScene.words = db.select(withStatement: sqlString) ?? [""]
        
        self.performSelector(onMainThread: #selector(setter: gameScene.lookingUpWordsQ), with: false, waitUntilDone: Bool(false), modes: nil)
    }
    
//- (void) selectWordsForString: (NSString *)string {
//    NSUInteger len = [string length];
//    NSString *sqlString;
//    if (len <= 6) sqlString = [NSString stringWithFormat:@"select rowid, word from words%i where word = '%@'", len, string];
//    else sqlString = [NSString stringWithFormat:@"select id, word from words where word = '%@'", string];
//
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
//    [self performSelectorOnMainThread:@selector(lookingUpWordsQ:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
//}
//
    
    func deleteWord() {
        //Do we need/use this??
    }
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
    
    func insertWord() {
        //Do we need/use this?
    }
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
//
//- (void) dealloc {
//    [word release];
//    [super dealloc];
//}
//
//-(void)lookingUpWordsQ:(NSNumber *)yesno {
//    delegate.lookingUpWordsQ = [yesno boolValue];
//    if (![yesno boolValue])
//        [delegate checkMatch];
//}
//
//@end
    
}
