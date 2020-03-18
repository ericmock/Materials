import Cocoa
import SQLite3
import simd

class PolyhedronViewController: NSViewController {
	
	var db: PolyhedraDatabase!
	let polygonTypes = ["triangle", "square", "pentagon", "hexagon", "heptagon", "octagon", "decagon", "twelvegon", "square_2", "square_3", "square_4", "triangle_2", "triangle_3", "triangle_4"]
	let polygonTypesVertexCount = [3, 4, 5, 6, 7, 8, 10, 12, 4, 4, 4, 3, 3, 3]
	var numPolygonTypes = 0
	var indices:[Int] = Array()
	var activeArray:[Bool] = Array()
	var idArray:[Int] = Array()
	var numberOfFacesOfPolygonType:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var numberOfFacesOfPolygonType2:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var polyVertices:[SIMD3<Float>] = Array()
	var baseTextureCoords:[[SIMD2<Float>]] = Array()
	var scaledBaseTextureCoords:[[SIMD2<Float>]] = Array()
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
		
		polyInfo = ["polyID": 4]
		
		do {
			try getNumberOfFacesForAllPolygons()
		} catch {
			print("Error")
			return
		}
		
		initialize(withPolyhedronInfo: polyInfo)
//		var vertices:[SIMD3<Float>]?
//		do {
//			vertices = try getVertices()
//		} catch {
//			print("Error")
//			return
//		}
		
	}
	
	func initialize(withPolyhedronInfo polyInfo:NSDictionary) {
		self.polyInfo = polyInfo
		let polyhedronType = polyInfo.object(forKey: "polyID") as! Int

		openDatabase()
		
		let numSides = getNumberOfSides(polyhedronType)
		polyVertices = Array(repeating: SIMD3<Float>(repeating: 0), count:polyhedronType)
		
		centroids = Array(repeating: SIMD3<Float>(repeating: 0), count:polygonTypes.count)

		let scale:Float = 1/6.0
		
		// Deal with triangles
		var polygonIndex = 0
		baseTextureCoords.append(Array(repeating: SIMD2<Float>(0,0), count: 3))
		scaledBaseTextureCoords.append(Array(repeating: SIMD2<Float>(0,0), count: 3))
		if polyhedronType == 7 {
			let scale2:Float = 1.1
			let shift:Float = (scale2 - 1.0)/2.0
			let temp = [SIMD2<Float>(scale2*0.512355 - shift, scale2*0.766774 - shift - 0.04),
									SIMD2<Float>(scale2 * -0.0123553 - shift, scale2*0.366613 - shift - 0.04),
									SIMD2<Float>(scale2*1.0 - shift, scale2*0.366613 - shift - 0.04)]
			for t in temp {
				scaledBaseTextureCoords[polygonIndex][15] = scale * t
				baseTextureCoords[polygonIndex][15] = t
			}
		}
		else if polyhedronType == 31 {
			let scale2:Float = 1.0
			let shift:Float = (scale2 - 1.0)/2.0
			let temp = [SIMD2<Float>(scale2 * 0.337327 - shift, scale2*(1.0 + 0.05) - shift),
									SIMD2<Float>(scale2 * 0.300672 - shift, scale2*(0.25 + 0.05) - shift),
									SIMD2<Float>(scale2 * 0.862001 - shift, scale2*(0.25 + 0.05) - shift)]
			for t in temp {
				scaledBaseTextureCoords[polygonIndex][13] = scale * t
				baseTextureCoords[polygonIndex][13] = t
			}
			let temp2 = [
				SIMD2<Float>(scale2 * (1.0 - 0.337327) - shift, scale2*(1.0 + 0.05) - shift),
				SIMD2<Float>(scale2 * (1.0 - 0.300672) - shift, scale2*(0.25 + 0.05) - shift),
				SIMD2<Float>(scale2 * (1.0 - 0.862001) - shift, scale2*(0.25 + 0.05) - shift)
			]
			for t in temp2 {
				scaledBaseTextureCoords[polygonIndex][13] = scale * t
				baseTextureCoords[polygonIndex][13] = t
			}
		}
		else {
			for ii in 0..<3 {
				baseTextureCoords[polygonIndex][ii] = SIMD2<Float>(1.0/2.0 * (cos(.pi + .pi/6.0 + Float(ii) * .pi/Float(numSides)) + 1), 1.0/2.0 * (sin(.pi + .pi/6.0 + Float(ii) * .pi/Float(numSides)) + 1))
				scaledBaseTextureCoords[polygonIndex][ii] = scale * baseTextureCoords[polygonIndex][ii]
			}
		}

		// Deal with squares
		polygonIndex += 1
		baseTextureCoords.append(Array(repeating: SIMD2<Float>(0,0), count: 4))
		scaledBaseTextureCoords.append(Array(repeating: SIMD2<Float>(0,0), count: 4))

		if polyhedronType == 3 {
			let temp2 = [
				float2(0.5, 1.0),
				float2(0.105022, 0.412023),
				float2(0.5, 0.175955),
				float2(0.894978, 0.412023)
			]
			for t in temp2 {
				scaledBaseTextureCoords[polygonIndex][12] = scale * t
				baseTextureCoords[polygonIndex][12] = t
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
				scaledBaseTextureCoords[polygonIndex][10] = scale * t
				baseTextureCoords[polygonIndex][10] = t
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
				scaledBaseTextureCoords[polygonIndex][11] = scale * t
				baseTextureCoords[polygonIndex][11] = t
			}

		}
		else {
			for ii in 0..<4 {
				baseTextureCoords[polygonIndex][ii] = float2(1.0/2.0 * (cos((Float(ii) + 1.0) * .pi/4.0) + 1), 1.0/2.0 * (sin((Float(ii) + 1.0) * .pi/4.0) + 1))
				scaledBaseTextureCoords[polygonIndex][ii] = scale * baseTextureCoords[polygonIndex][ii]
			}
		}
		
		// Deal with remaining polygons
		for num_sides in polygonTypesVertexCount[2...7] {
			polygonIndex += 1
			baseTextureCoords.append(Array(repeating: SIMD2<Float>(0,0), count: num_sides))
			scaledBaseTextureCoords.append(Array(repeating: SIMD2<Float>(0,0), count: num_sides))
			for ii in 0..<num_sides {
				baseTextureCoords[polygonIndex][ii] = float2(1.0/2.0 * (cos((Float(ii) + 1.0) * .pi/Float(num_sides)) + 1), 1.0/2.0 * (sin((Float(ii) + 1.0) * .pi/Float(num_sides)) + 1))
				scaledBaseTextureCoords[polygonIndex][ii] = scale * baseTextureCoords[polygonIndex][ii]
			}
		}
		do {
			vertices = try getVertices()!
		} catch {
			print("Error")
			return
		}

		for polygon_type in 0..<polygonTypesVertexCount.count {
			getPolygons(ofType: polygon_type)
			setTextureCoords(forType: polygon_type)
		}
		
		generateConnectivityForPolyhedron()
		generateLocalPolygonBases()
		
		// Need to pack vertex, normal, tangent, bitan, and texture coords together.
		// Need to calculate normal, tangent, and bitan for each vertex.
		
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
//			print("Basis for \(poly.name)")
			var ave = SIMD3<Float>(0,0,0)
			
			// get the vertex coordinates
			for index in poly.indices {
				poly.vertices.append(vertices[index])
				ave += vertices[index]
			}
			
			ave = ave/Float(poly.indices.count)
			
			poly.radius = simd_distance(poly.vertices[0], ave)
			
			let v1 = poly.vertices[0] - poly.vertices[1]
			let v2 = poly.vertices[0] - poly.vertices[2]
//			print("\(v1), \(v2)")
			poly.normal_v = normalize(cross(v1, v2))
			poly.tangent_v = normalize(v1)
			poly.bitan_v = cross(poly.normal_v, poly.tangent_v)
			print("{\(String(describing: poly.normal_v))}, {\(String(describing: poly.tangent_v))}, {\(String(describing: poly.bitan_v))}")
		}
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
		numPolygons += numberOfFacesOfPolygonType[type]
	}
	
	func initializePolygons(ofType type:Int) {
		var counter = 0
		let numSides = getNumberOfSides(type)
		for ii in 0..<numberOfFacesOfPolygonType[type] {
			let poly:Apolygon = Apolygon.init(withType: type)
			if indices.count > 0 {
				for _ in 0..<numSides {
					poly.indices.append(indices[counter])
					counter += 1
				}
			}
			if centroids.count > 0 {
				poly.centroid = centroids[type]
			}
			poly.number = polygonNumber
			poly.animatingQ = false
			polygonNumber += 1
			poly.texture = -1
			poly.active = activeArray[ii]
			poly.dbID = idArray[ii]
			polygons.append(poly)
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
		print("Vertices:")
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			
			let dataX = Float(sqlite3_column_double(queryStatement, 0))
			let dataY = Float(sqlite3_column_double(queryStatement, 1))
			let dataZ = Float(sqlite3_column_double(queryStatement, 2))
			let vertex = SIMD3<Float>(x: dataX, y: dataY, z:dataZ)
			vertices.append(vertex)
			print("{\(dataX), \(dataY), \(dataZ)}")
		}
		//		sqlite3_finalize(queryStatement)
		//    guard sqlite3_step(queryStatement) == SQLITE_ROW else {
		//      return nil
		//    }
		return vertices
	}

	func getNumberOfFacesForAllPolygons() throws {
		
		for ii in 0..<polygonTypes.count {
			let type = ii
			let typeName = ("indices_" + polygonTypes[type])

			let querySql = "SELECT COUNT(polyhedron_id) FROM " + typeName + " where polyhedron_id = ? group by polyhedron_id;"
			guard let queryStatement = try? db.prepareStatement(sql: querySql) else {
				throw SQLiteError.Step(message: "Error")
			}
			defer {
				sqlite3_finalize(queryStatement)
			}
			
//			guard sqlite3_bind_text(queryStatement, 1, typeName.utf8String, -1, nil) == SQLITE_OK else {
//				return
//			}
			let id = polyInfo.object(forKey: "polyID") as! Int32
			guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
				return
			}
			print("Query Result:")
			while (sqlite3_step(queryStatement) == SQLITE_ROW) {
				numberOfFacesOfPolygonType[type] = Int(sqlite3_column_int(queryStatement, 0))
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
		let numSides = polygonTypesVertexCount[type]
		let numberVertices = Int(count/numSides)
//		centroids.removeAll()
		
		for ii in 0..<numberVertices {
			var centroid = SIMD3<Float>(repeating: 0)
//			var centroid_x:Float = 0.0
//			var centroid_y:Float = 0.0
//			var centroid_z:Float = 0.0
			for jj in (numSides * ii)..<(ii+1)*numSides {
				let num2 = Int(indices[jj])
				centroid += vertices[num2]
//				centroid_x += vertices[3*num2].x
//				centroid_y += vertices[3*num2].y
//				centroid_z += vertices[3*num2].z
			}
			centroid /= Float(numSides)
//			centroid_x /= Float(numSides)
//			centroid_y /= Float(numSides)
//			centroid_z /= Float(numSides)
			centroids[type] = centroid
		}
	}
	
	func getIndices(forPolygonType type: Int) throws {
		var querySql: String
		indices.removeAll()
		activeArray.removeAll()
		idArray.removeAll()
		
		querySql = "select *, rowid from indices_" + polygonTypes[type] + " where polyhedron_id = ?;"
		let numSides = getNumberOfSides(type)

		guard let queryStatement = try? db.prepareStatement(sql: querySql) else {
			throw SQLiteError.Step(message: "Error")
		}
		defer {
			sqlite3_finalize(queryStatement)
		}
				
		let id = Int32(polyInfo.object(forKey: "polyID") as! Int)
		guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
			return
		}
		
		print("\(polygonTypes[type]) indices:")
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			for jj in 1..<numSides + 1 {
				let index = Int(sqlite3_column_double(queryStatement, Int32(jj)))
				indices.append(index)
				print("\(index)", terminator: ",")
			}
			print("")
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

		numberOfFacesOfPolygonType2[polygonType] = Int(count/numSides)

//		polyVertices = Array(repeating: SIMD3<Float>(repeating: 0), count:count)
		
		for ii in 0..<count {
			let num = Int(indices[ii])
			polyVertices.append(vertices[num])
//			polyVertices[polygonType][3*ii + 0] = Float(vertices[3*num].x)//[[vertices objectAtIndex:(3*num + 0)] floatValue];
//			polyVertices[polygonType][3*ii + 1] = Float(vertices[3*num + 1].y)//[[vertices objectAtIndex:(3*num + 1)] floatValue];
//			polyVertices[polygonType][3*ii + 2] = Float(vertices[3*num + 2].z)//[[vertices objectAtIndex:(3*num + 2)] floatValue];
		}
	}

	func setTextureCoords(forType type:Int) {
		let numSides = getNumberOfSides(type)
		textureCoords.append(Array())

		for _ in 0..<numberOfFacesOfPolygonType[type] {
			for jj in 0..<numSides {
				textureCoords[type].append(baseTextureCoords[type][jj])
			}
//			}
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}

