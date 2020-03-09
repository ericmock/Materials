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
class SQLiteDatabase {
	private let dbPointer: OpaquePointer?
	let polygonTypesArray = ["triangle", "square", "pentagon", "hexagon", "heptagon", "octagon", "nonagon", "decagon", "elevengon", "twelvegon", "square_2", "square_3", "square_4", "triangle_2", "triangle_3", "triangle_4"]
	var numPolygonTypes = 0

	private init(dbPointer: OpaquePointer?) {
		self.dbPointer = dbPointer
	}
	deinit {
		sqlite3_close(dbPointer)
	}
	static func open(path: String) throws -> SQLiteDatabase {
		var db: OpaquePointer?
		if sqlite3_open(path, &db) == SQLITE_OK {
			return SQLiteDatabase(dbPointer: db)
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
extension SQLiteDatabase {
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
	let x: Double
	let y: Double
	let z: Double
}

protocol SQLTable {
	static var createStatement: String { get }
}
//: ## Read
extension SQLiteDatabase {
	func getVertices(forPolyhedronID polyhedron_id: Int32) throws -> [Vertex]? {
		let querySql = "SELECT x, y, z FROM vertices WHERE polyhedron_id = ?;"
		guard let queryStatement = try? prepareStatement(sql: querySql) else {
			throw SQLiteError.Step(message: "Error")
		}
		defer {
			sqlite3_finalize(queryStatement)
		}
		guard sqlite3_bind_int(queryStatement, 1, polyhedron_id) == SQLITE_OK else {
			return nil
		}
		print("Query Result:")
		var vertices:[Vertex] = []
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			
			let dataX = sqlite3_column_double(queryStatement, 0)
			let dataY = sqlite3_column_double(queryStatement, 1)
			let dataZ = sqlite3_column_double(queryStatement, 2)
			let vertex = Vertex(x: dataX, y: dataY, z:dataZ)
			vertices.append(vertex)
			print("\(dataX), \(dataY), \(dataZ)")
		}
		//		sqlite3_finalize(queryStatement)
		//    guard sqlite3_step(queryStatement) == SQLITE_ROW else {
		//      return nil
		//    }
		return vertices
	}
	
	func getNumberOfFaces(forPolyhedronID polyID: Int) throws {
		
		for ii in 0..<AppConstants.kNumPolygonTypes + 1 {
			let type = ii
			let querySql = "select count(polyhedron_id) from indices_? where polyhedron_id = '?' group by polyhedron_id"
			guard let queryStatement = try? prepareStatement(sql: querySql) else {
				throw SQLiteError.Step(message: "Error")
			}
			defer {
				sqlite3_finalize(queryStatement)
			}
			let typeName = polygonTypesArray[type] as NSString
			
			guard sqlite3_bind_text(queryStatement, 1, typeName.utf8String, -1, nil) == SQLITE_OK else {
				return
			}
			let id = Int32(polyID)
			guard sqlite3_bind_int(queryStatement, 2, id) == SQLITE_OK else {
				return
			}
			print("Query Result:")
			var faceNum:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
			while (sqlite3_step(queryStatement) == SQLITE_ROW) {
				faceNum[type] = Int(sqlite3_column_int(queryStatement, 0))
				numPolygonTypes += 1
				
			}
		}
		//		sqlite3_finalize(queryStatement)
		//    guard sqlite3_step(queryStatement) == SQLITE_ROW else {
		//      return nil
		//    }
	}
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

