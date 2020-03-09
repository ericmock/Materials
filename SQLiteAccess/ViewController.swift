//
/**
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import Cocoa
import SQLite3


class ViewController: NSViewController {

//	enum Database: String {
//		case Part1
//		case Part2
//
//		var path: String? {
//			return
//		}
//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let directoryUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

		let dbPath = Bundle.main.resourceURL?.appendingPathComponent("data.sqlite").absoluteString//directoryUrl?.appendingPathComponent("data.sqlite").relativePath
		
//		func destroyDatabase(db: Database) {
//			guard let path = db.path else { return }
//			do {
//				if FileManager.default.fileExists(atPath: path) {
//					try FileManager.default.removeItem(atPath: path)
//				}
//			} catch {
//				print("Could not destroy \(db) Database file.")
//			}
//		}
//
//		func destroyPart1Database() {
//			destroyDatabase(db: .Part1)
//		}
//
//		func destroyPart2Database() {
//			destroyDatabase(db: .Part2)
//		}

//		destroyPart2Database()

		let db: SQLiteDatabase

		do {
				db = try SQLiteDatabase.open(path: dbPath!)
				print("Successfully opened connection to database.")
		} catch SQLiteError.OpenDatabase(_) {
				print("Unable to open database.")
			return
		} catch {
			return
		}
		
//		do {
//			try db.createTable(table: Contact.self)
//		} catch {
//			print("Error")
//		}
//
//		do {
//			try db.insertContact(contact: Contact(id: 1, name: "Ray"))
//		} catch {
//			print("Error")
//		}

		var first:Contact?
		do {
			first = try db.getVertices(polyhedron_id: 20)
		} catch {
			print("Error")
			return
		}

		print("\(first!.id) \(first!.name)")
//		func openDatabase() -> OpaquePointer? {
//			var db: OpaquePointer?
//			if sqlite3_open(part1DbPath, &db) == SQLITE_OK {
//				//print("Successfully opened connection to database at \(part1DbPath)")
//				return db
//			} else {
//				print("Unable to open database.")
//				return nil
//			}
//		}
//
////		let db = openDatabase()
//
//		let createTableString = """
//		CREATE TABLE Contact(
//		Id INT PRIMARY KEY NOT NULL,
//		FirstName CHAR(255),
//		LastName CHAR(255));
//		"""
//
//		func createTable() {
//			var createTableStatement: OpaquePointer?
//			if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
//				if sqlite3_step(createTableStatement) == SQLITE_DONE {
//					print("\nContact table created.")
//				} else {
//					print("\nContact table could not be created.")
//				}
//			} else {
//				print("\nCREATE TABLE statement could not be prepared.")
//			}
//			sqlite3_finalize(createTableStatement)
//		}
//		createTable()
//
//		let insertStatementString = "INSERT INTO Contact (Id, FirstName, LastName) VALUES (?, ?, ?);"
//
//		func insert() {
//			var insertStatement: OpaquePointer?
//			// 1
//			let names: [NSString] = ["Ray", "Chris", "Martha", "Danielle", "Adam"]
//			if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
//				// 2
//				print("\n")
//				for (index, name) in names.enumerated() {
//					// 3
//					let id = Int32(index + 1)
//					sqlite3_bind_int(insertStatement, 1, id)
//					sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
//					if sqlite3_step(insertStatement) == SQLITE_DONE {
//						print("Successfully inserted row.")
//					} else {
//						print("Could not insert row.")
//					}
//					// 4
//					sqlite3_reset(insertStatement)
//				}
//				sqlite3_finalize(insertStatement)
//			} else {
//				print("\nINSERT statement could not be prepared.")
//			}
//		}
//
//		insert()
//
//		let queryStatementString = "SELECT * FROM Contact;"
//
//		func query() {
//			var queryStatement: OpaquePointer?
//			if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
//				print("\n")
//				while (sqlite3_step(queryStatement) == SQLITE_ROW) {
//					let id = sqlite3_column_int(queryStatement, 0)
//					let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
//					let name = String(cString: queryResultCol1!)
//					print("Query Result:")
//					print("\(id) | \(name)")
//				}
//			} else {
//					let errorMessage = String(cString: sqlite3_errmsg(db))
//					print("\nQuery could not be prepared! \(errorMessage)")
//			}
//			sqlite3_finalize(queryStatement)
//		}
//
//		query()
//
//		let updateStatementString = "UPDATE Contact SET Name = 'Adam' WHERE Id = 1;"
//		func update() {
//			var updateStatement: OpaquePointer?
//			if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
//				if sqlite3_step(updateStatement) == SQLITE_DONE {
//					print("\nSuccessfully updated row.")
//				} else {
//					print("\nCould not update row.")
//				}
//			} else {
//				print("\nUPDATE statement could not be prepared")
//			}
//			sqlite3_finalize(updateStatement)
//		}
//		update()
//		query()
//
//		let deleteStatementString = "DELETE FROM Contact WHERE Id = 1;"
//		func delete() {
//		  var deleteStatement: OpaquePointer?
//		  if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
//		    if sqlite3_step(deleteStatement) == SQLITE_DONE {
//		      print("\nSuccessfully deleted row.")
//		    } else {
//		      print("\nCould not delete row.")
//		    }
//		  } else {
//		    print("\nDELETE statement could not be prepared")
//		  }
//		  sqlite3_finalize(deleteStatement)
//		}
//		delete()
//		query()
//
//		sqlite3_close(db)
		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

