import Cocoa
import SQLite3
import simd


class SQLTestViewController: NSViewController {
	
	var db: PolyhedraDatabase!
	let polygonTypesArray = ["triangle", "square", "pentagon", "hexagon", "heptagon", "octagon", "nonagon", "decagon", "elevengon", "twelvegon", "square_2", "square_3", "square_4", "triangle_2", "triangle_3", "triangle_4"]
	var numPolygonTypes = 0
	var indices:[Float] = Array()
	var activeArray:[Bool] = Array()
	var idArray:[Int] = Array()
	var faceNum:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var faceNum2:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var polyVertices:[SIMD3<Float>] = Array()
	var baseTextureCoords:[SIMD2<Float>] = Array()
	var scaledBaseTextureCoords:[SIMD2<Float>] = Array()
	var textureCoords:[[SIMD2<Float>]] = Array()
	var vertices:[SIMD3<Float>] = Array()
	var centroids:[SIMD3<Float>] = Array()
	var polyInfo: NSDictionary!
	var polygonNumber = 0
	var numPolygons = 0
	var animatingQ = false
	var animationType = 1
	var polygons:[Apolygon] = []

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
		
		polyInfo = ["polyID": 20]
		
		var vertices:[SIMD3<Float>]?
		do {
			vertices = try getVertices()
		} catch {
			print("Error")
			return
		}
		
	}
	
	func initialize(withPolyhedronInfo polyInfo:NSDictionary) {
		self.polyInfo = polyInfo
		let polyhedronType = polyInfo.object(forKey: "polyID") as! Int
		let dbPath = Bundle.main.resourceURL?.appendingPathComponent("data.sqlite").absoluteString//directoryUrl?.appendingPathComponent("data.sqlite").relativePath
		openDatabase()
		
		let numSides = getNumberOfSides(polyhedronType)
		textureCoords = Array(repeating: Array(repeating: SIMD2<Float>(0,0), count:numSides), count: faceNum[polyhedronType])
		polyVertices = Array(repeating: SIMD3<Float>(repeating: 0), count:polyhedronType)
		
		let scale:Float = 1/6.0
		
		// Deal with triangles
		if polyhedronType == 7 {
			let scale2:Float = 1.1
			let shift:Float = (scale2 - 1.0)/2.0
			let temp = [SIMD2<Float>(scale2*0.512355 - shift, scale2*0.766774 - shift - 0.04),
									SIMD2<Float>(scale2 * -0.0123553 - shift, scale2*0.366613 - shift - 0.04),
									SIMD2<Float>(scale2*1.0 - shift, scale2*0.366613 - shift - 0.04)]
			for t in temp {
				scaledBaseTextureCoords[15] = scale * t
				baseTextureCoords[15] = t
			}
		}
		else if polyhedronType == 31 {
			let scale2:Float = 1.0
			let shift:Float = (scale2 - 1.0)/2.0
			let temp = [SIMD2<Float>(scale2 * 0.337327 - shift, scale2*(1.0 + 0.05) - shift),
									SIMD2<Float>(scale2 * 0.300672 - shift, scale2*(0.25 + 0.05) - shift),
									SIMD2<Float>(scale2 * 0.862001 - shift, scale2*(0.25 + 0.05) - shift)]
			for t in temp {
				scaledBaseTextureCoords[13] = scale * t
				baseTextureCoords[13] = t
			}
			let temp2 = [
				SIMD2<Float>(scale2 * (1.0 - 0.337327) - shift, scale2*(1.0 + 0.05) - shift),
				SIMD2<Float>(scale2 * (1.0 - 0.300672) - shift, scale2*(0.25 + 0.05) - shift),
				SIMD2<Float>(scale2 * (1.0 - 0.862001) - shift, scale2*(0.25 + 0.05) - shift)
			]
			for t in temp2 {
				scaledBaseTextureCoords[13] = scale * t
				baseTextureCoords[13] = t
			}
		}
		else {
			for ii in stride(from: 0, through: 3*2, by: 2) {
				baseTextureCoords[0] = SIMD2<Float>(1.0/2.0 * (cos(.pi + .pi/6.0 + Float(ii) * .pi/Float(numSides)) + 1), 1.0/2.0 * (sin(.pi + .pi/6.0 + Float(ii) * .pi/Float(numSides)) + 1))
				scaledBaseTextureCoords[0] = scale * baseTextureCoords[0]
			}
		}
		
		// Deal with squares
		if polyhedronType == 3 {
			let temp2 = [
				float2(0.5, 1.0),
				float2(0.105022, 0.412023),
				float2(0.5, 0.175955),
				float2(0.894978, 0.412023)
			]
			for t in temp2 {
				scaledBaseTextureCoords[12] = scale * t
				baseTextureCoords[12] = t
			}
		}
		else if polyhedronType == 23 {
			let scale2:Float = 1.1
			let shift:Float = (scale2 - 1.0)/2.0
			let temp2 = [
				SIMD2<Float>(scale2*0.0 - shift, scale2*0.5 - shift),
				SIMD2<Float>(scale2*0.5 - shift, scale2*0.190983 - shift),
				SIMD2<Float>(scale2*1.0 - shift, scale2*0.5 - shift),
				SIMD2<Float>(scale2*0.5 - shift, scale2*0.809017 - shift)
			]
			for t in temp2 {
				scaledBaseTextureCoords[10] = scale * t
				baseTextureCoords[10] = t
			}

		}
		else if polyhedronType == 25 {
			var temp2 = [
				SIMD2<Float>(0.5, 0.0871677),
				SIMD2<Float>(0.879126, 0.456416),
				SIMD2<Float>(0.5, 1.0),
				SIMD2<Float>(0.120874, 0.456416)]
			let scale2:Float = 1.1
			let shift:Float = (scale2 - 1.0)/2.0
			for ii in 0..<temp2.count {
				temp2[ii] *= scale2
				temp2[ii] -= shift
			}
			for t in temp2 {
				scaledBaseTextureCoords[11] = scale * t
				baseTextureCoords[11] = t
			}

		}
		else {
			for ii in stride(from: 0, through: 4*2, by: 2) {
				baseTextureCoords[1] = float2(1.0/2.0 * (cos((Float(ii) + 1.0) * .pi/4.0) + 1), 1.0/2.0 * (sin((Float(ii) + 1.0) * .pi/4.0) + 1))
				scaledBaseTextureCoords[1] = scale * baseTextureCoords[0]
			}
		}
		
		// Deal with remaining polygons
		var counter = 2
		for num_sides in 5..<12 {
			for ii in stride(from: 0, through: num_sides*2, by: 2) {
				baseTextureCoords[counter] = float2(1.0/2.0 * (cos((Float(ii) + 1.0) * .pi/Float(num_sides)) + 1), 1.0/2.0 * (sin((Float(ii) + 1.0) * .pi/Float(num_sides)) + 1))
				scaledBaseTextureCoords[counter] = scale * baseTextureCoords[0]
			}
			counter += 1
		}
		
		getNumberOfFacesForAllPolygon()
		do {
			vertices = try getVertices()!
		} catch {
			print("Error")
			return
		}

		for polygon_type in 0..<AppConstants.kNumPolygonTypes + 1 {
			if faceNum[polygon_type] > 0 {
				getPolygons(ofType: polygon_type)
				setTextureCoords(forType: polygon_type)
			}
		}
		
		generateConnectivityForPolyhedron()
		generateLocalPolygonBases()
		
		vertices.removeAll()
	}
	
	func generateConnectivityForPolyhedron() {
		var connections:[Apolygon] = []
		var count = 0
		for poly1 in polygons {
			for poly2 in polygons {
				if poly1 !== poly2 {
					for num in poly1.indices {
						if poly2.indices.contains(num) {
							count += 1
							if (count > 1) {
								connections.append(poly2)
							}
						}
					}
				}
				count = 0
			}
			poly1.connections = connections
			connections.removeAll()
		}
	}
	
	func generateLocalPolygonBases() {
		for poly in polygons {
			var ave = SIMD3<Float>(0,0,0)
			
			// get the vertex coordinates
			for index in poly.indices {
				poly.vertices[index] = vertices[index]
				ave += vertices[index]
			}
			
			ave = ave/Float(poly.indices.count)
			
			poly.radius = simd_distance(poly.vertices[0], ave)
			
			let v1 = poly.vertices[0] - poly.vertices[1]
			let v2 = poly.vertices[0] - poly.vertices[2]
			poly.normal_v = normalize(cross(v1, v2))
			poly.tangent_v = normalize(v1)
			poly.bitan_v = cross(poly.normal_v, poly.tangent_v)
		}
	}
	
	func getNumberOfFacesForAllPolygon() {
	}

	func getPolygons(ofType type:Int) {
		do {
			try getIndices(forPolygonType: type)
		} catch {
			print("Error")
			return
		}
		generatePolygonVertices(forType: type)
		generateCentroids(forPolygonType: type)
		
		initializePolygons(ofType: type)
		numPolygons += faceNum[type]
	}
	
	func initializePolygons(ofType type:Int) {
		var counter = 0
		let num = faceNum[type]
		let numSides = getNumberOfSides(type)
		for ii in 0..<num {
			let poly:Apolygon = Apolygon.init(withType: type)
			if indices.count > 0 {
				for jj in 0..<numSides {
					poly.indices.append(counter)
					counter += 1
				}
			}
			if centroids.count > 0 {
				poly.centroids[ii] = centroids[ii]
				poly.centroid = centroids[ii]
			}
		}
	}
	
	func getVertices() throws -> [SIMD3<Float>]? {
		let querySql = "SELECT x, y, z FROM vertices WHERE polyhedron_id = ?;"
		let polyhedron_id = polyInfo.object(forKey: "polyID") as! Int32
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
			
			let dataX = Float(sqlite3_column_double(queryStatement, 0))
			let dataY = Float(sqlite3_column_double(queryStatement, 1))
			let dataZ = Float(sqlite3_column_double(queryStatement, 2))
			let vertex = SIMD3<Float>(x: dataX, y: dataY, z:dataZ)
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
			var centroid = SIMD3<Float>(repeating: 0)
//			var centroid_x:Float = 0.0
//			var centroid_y:Float = 0.0
//			var centroid_z:Float = 0.0
			for jj in (numSides * ii)..<(ii+1)*numSides {
				let num2 = Int(indices[jj])
				centroid = vertices[3*num2]
//				centroid_x += vertices[3*num2].x
//				centroid_y += vertices[3*num2].y
//				centroid_z += vertices[3*num2].z
			}
			centroid /= Float(numSides)
//			centroid_x /= Float(numSides)
//			centroid_y /= Float(numSides)
//			centroid_z /= Float(numSides)
			centroids.append(centroid)
		}
	}
	
	func getIndices(forPolygonType type: Int) throws {
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
				indices.append(Float(sqlite3_column_double(queryStatement, Int32(jj))))
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

		polyVertices = Array(repeating: SIMD3<Float>(repeating: 0), count:polygonType)//Array(repeating: Array(repeating: 0.0, count:polygonType), count: 3*count)
		
		for ii in 0..<count {
			let num = Int(indices[ii])
			polyVertices[polygonType][3*ii + 0] = Float(vertices[3*num].x)//[[vertices objectAtIndex:(3*num + 0)] floatValue];
			polyVertices[polygonType][3*ii + 1] = Float(vertices[3*num + 1].y)//[[vertices objectAtIndex:(3*num + 1)] floatValue];
			polyVertices[polygonType][3*ii + 2] = Float(vertices[3*num + 2].z)//[[vertices objectAtIndex:(3*num + 2)] floatValue];
		}
	}

	func setTextureCoords(forType type:Int) {
		let numSides = getNumberOfSides(type)
		textureCoords = Array(repeating: Array(repeating: SIMD2<Float>(0,0), count:numSides), count: faceNum[type])//Array(repeating: Array(repeating: 0.0, count:type), count: 2*numSides)

		for ii in 0..<faceNum[type] {
//			for jj in 0..<2*numSides {
				textureCoords[type][ii] = baseTextureCoords[type]
//			}
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}

