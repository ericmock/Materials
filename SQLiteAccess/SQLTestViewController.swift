import Cocoa
import SQLite3


class SQLTestViewController: NSViewController {
	
	var db: PolyhedraDatabase!
	let polygonTypesArray = ["triangle", "square", "pentagon", "hexagon", "heptagon", "octagon", "nonagon", "decagon", "elevengon", "twelvegon", "square_2", "square_3", "square_4", "triangle_2", "triangle_3", "triangle_4"]
	var numPolygonTypes = 0
	var indices:[Double]!
	var activeArray:[Bool]!
	var idArray:[Int]!
	var faceNum:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var faceNum2:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var polyVertices:[[Float]] = Array()
	var baseTextureCoords:[[Float]] = Array()
	var textureCoords:[[Float]] = Array()
	var vertices:[Vertex] = Array()
	var centroids:[Vertex] = Array()

	func openDatabase() {
		let dbPath = Bundle.main.resourceURL?.appendingPathComponent("data.sqlite").absoluteString//directoryUrl?.appendingPathComponent("data.sqlite").relativePath
		
		do {
			db = try PolyhedraDatabase.open(path: dbPath!)
			print("Successfully opened connection to database.")
		} catch SQLiteError.OpenDatabase(_) {
			print("Unable to open database.")
			return
		} catch {
			return
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		openDatabase()
		
		var vertices:[Vertex]?
		do {
			vertices = try getVertices(forPolyhedronID: 20)
		} catch {
			print("Error")
			return
		}
		
	}
	
	func getVertices(forPolyhedronID polyhedron_id: Int32) throws -> [Vertex]? {
		let querySql = "SELECT x, y, z FROM vertices WHERE polyhedron_id = ?;"
		guard let queryStatement = try? db.prepareStatement(sql: querySql) else {
			throw SQLiteError.Step(message: "Error")
		}
		defer {
			sqlite3_finalize(queryStatement)
		}
		guard sqlite3_bind_int(queryStatement, 1, polyhedron_id) == SQLITE_OK else {
			return nil
		}
		print("Query Result:")
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
			guard let queryStatement = try? db.prepareStatement(sql: querySql) else {
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
			while (sqlite3_step(queryStatement) == SQLITE_ROW) {
				faceNum[type] = Int(sqlite3_column_int(queryStatement, 0))
				numPolygonTypes += 1
				
			}
		}
	}

	fileprivate func getNumberOfSides(_ type: Int) -> Int {
		var numSides = type + 3
		if (type == 10 || type == 11 || type == 12) {
			numSides = 4
		}	else if (type == 13 || type == 14 || type == 15) {
			numSides = 3
		}
		return numSides
	}
	
	func generateCentroids(forPolygonType type: Int) {
		let count = indices.count
		let numSides = getNumberOfSides(type)
		let num = Int(count/numSides)
		centroids.removeAll()
		
		for ii in 0..<num {
			var centroid_x = 0.0
			var centroid_y = 0.0
			var centroid_z = 0.0
			for jj in (numSides * ii)..<(ii+1)*numSides {
				let num2 = Int(indices[jj])
				centroid_x += vertices[3*num2].x
				centroid_y += vertices[3*num2].y
				centroid_z += vertices[3*num2].z
			}
			centroid_x /= Double(numSides)
			centroid_y /= Double(numSides)
			centroid_z /= Double(numSides)
			centroids.append(Vertex(x: centroid_x, y: centroid_y, z: centroid_z))
		}
	}
	
	func getIndices(forPolygonType type: Int, withPolyhedronInfo polyInfo:NSDictionary) throws {
		var querySql: String
		indices.removeAll()
		activeArray.removeAll()
		idArray.removeAll()
		
		querySql = "select *, rowid from indices_? where polyhedron_id = '?'"
		let numSides = getNumberOfSides(type)

		guard let queryStatement = try? db.prepareStatement(sql: querySql) else {
			throw SQLiteError.Step(message: "Error")
		}
		defer {
			sqlite3_finalize(queryStatement)
		}
		
		let typeName = polygonTypesArray[type] as NSString
		
		guard sqlite3_bind_text(queryStatement, 1, typeName.utf8String, -1, nil) == SQLITE_OK else {
			return
		}
		
		let id = Int32(polyInfo.object(forKey: "polyEd") as! Int)
		guard sqlite3_bind_int(queryStatement, 2, id) == SQLITE_OK else {
			return
		}
		
		print("Query Result:")
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			for jj in 1..<numSides + 1 {
				indices.append(sqlite3_column_double(queryStatement, Int32(jj)))
			}
			let result = sqlite3_column_int(queryStatement, Int32(numSides + 1))
			if result == 0 {
				activeArray.append(false)
			} else {
				activeArray.append(true)
			}
			idArray.append(Int(sqlite3_column_int(queryStatement, Int32(numSides + 1))))
		}
	}
	
	func generatePolygonVertices(forType polygonType:Int) {
		let count = indices.count
		let numSides = getNumberOfSides(polygonType)

		faceNum2[polygonType] = Int(count/numSides)

		polyVertices = Array(repeating: Array(repeating: 0.0, count:polygonType), count: 3*count)
		
		for ii in 0..<count {
			let num = Int(indices[ii])
			polyVertices[polygonType][3*ii + 0] = Float(vertices[3*num].x)//[[vertices objectAtIndex:(3*num + 0)] floatValue];
			polyVertices[polygonType][3*ii + 1] = Float(vertices[3*num + 1].y)//[[vertices objectAtIndex:(3*num + 1)] floatValue];
			polyVertices[polygonType][3*ii + 2] = Float(vertices[3*num + 2].z)//[[vertices objectAtIndex:(3*num + 2)] floatValue];
		}
	}

	func setTextureCoords(forType type:Int) {
		let numSides = getNumberOfSides(type)
		polyVertices = Array(repeating: Array(repeating: 0.0, count:type), count: 2*numSides)

		for ii in stride(from: 0, to: faceNum[type]*numSides*2, by: numSides*2) {
			for jj in 0..<2*numSides {
				textureCoords[type][ii+jj] = baseTextureCoords[type][jj]
			}
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}

