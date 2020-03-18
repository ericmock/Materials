import Foundation
import SQLite3

//: # Making it Swift
enum SQLiteError: Error {
	case OpenDatabase(message: String)
	case Prepare(message: String)
	case Step(message: String)
	case Bind(message: String)
}

//: ## The Database Connection
class PolyhedraDatabase {
	private let dbPointer: OpaquePointer?

	private init(dbPointer: OpaquePointer?) {
		self.dbPointer = dbPointer
	}
	deinit {
		sqlite3_close(dbPointer)
	}
	static func open(path: String) throws -> PolyhedraDatabase {
		var db: OpaquePointer?
		if sqlite3_open(path, &db) == SQLITE_OK {
			return PolyhedraDatabase(dbPointer: db)
		} else {
			defer {
				if db != nil {
					sqlite3_close(db)
				}
			}
			if let errorPointer = sqlite3_errmsg(db) {
				let message = String(cString: errorPointer)
				throw SQLiteError.OpenDatabase(message: message)
			} else {
				throw SQLiteError
					.OpenDatabase(message: "No error message provided from sqlite.")
			}
		}
	}
	
	fileprivate var errorMessage: String {
		if let errorPointer = sqlite3_errmsg(dbPointer) {
			let errorMessage = String(cString: errorPointer)
			return errorMessage
		} else {
			return "No error message provided from sqlite."
		}
	}
}

//: ## Preparing Statements
extension PolyhedraDatabase {
	func prepareStatement(sql: String) throws -> OpaquePointer? {
		var statement: OpaquePointer?
		guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil)
			== SQLITE_OK else {
				print(SQLiteError.Prepare(message: errorMessage))
				throw SQLiteError.Prepare(message: errorMessage)
		}
		return statement
	}
}
//: ## Create Table
struct Vertex {
	var x: Float
	var y: Float
	var z: Float
  var position: float3 {
    get {
      float3(x, y, z)
    }
    set {
      x = newValue.x
      y = newValue.y
      z = newValue.z
    }
  }
//
//	var position: float3
}

protocol SQLTable {
	static var createStatement: String { get }
}


//extension Contact: SQLTable {
//  static var createStatement: String {
//    return """
//    CREATE TABLE Contact(
//      Id INT PRIMARY KEY NOT NULL,
//      Name CHAR(255)
//    );
//    """
//  }
//}

//extension SQLiteDatabase {
//  func createTable(table: SQLTable.Type) throws {
//    let createTableStatement = try prepareStatement(sql: table.createStatement)
//    defer {
//      sqlite3_finalize(createTableStatement)
//    }
//    guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
//      throw SQLiteError.Step(message: "Error")
//    }
//    print("\(table) table created.")
//  }
//}

//: ## Insert
//extension SQLiteDatabase {
//  func insertContact(contact: Contact) throws {
//    let insertSql = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"
//    let insertStatement = try prepareStatement(sql: insertSql)
//    defer {
//      sqlite3_finalize(insertStatement)
//    }
//    let name: NSString = contact.name
//    guard
//      sqlite3_bind_int(insertStatement, 1, contact.id) == SQLITE_OK  &&
//      sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil) == SQLITE_OK
//      else {
//        throw SQLiteError.Bind(message: "Error")
//    }
//    guard sqlite3_step(insertStatement) == SQLITE_DONE else {
//        throw SQLiteError.Step(message: "Error")
//    }
//    let insertStatement2 = try prepareStatement(sql: insertSql)
//
//    guard
//      sqlite3_bind_int(insertStatement2, 1, contact.id + 1) == SQLITE_OK  &&
//      sqlite3_bind_text(insertStatement2, 2, name.utf8String, -1, nil) == SQLITE_OK
//      else {
//        throw SQLiteError.Bind(message: "Error")
//    }
//    guard sqlite3_step(insertStatement2) == SQLITE_DONE else {
//        throw SQLiteError.Step(message: "Error")
//    }
//    print("Successfully inserted row.")
//  }
//}

