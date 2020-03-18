//
//  Polyhedron.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/14/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import SQLite3
import simd

class Polyhedron: Model {
	var numberOfFaces:Int = 0
	var allActive:[Int] = []
	var db: PolyhedraDatabase!
	var numberOfDifferentPolygonTypes = 0
	//  allIndices[type][polygon][index]
	var allIndices:[[[UInt16]]] = Array(repeating: [[]], count: AppConstants.kPolygonTypeNames.count)
	//  allCentroidIndices[polygon][index]
	var allCentroidIndices:[[UInt16]] = Array()
	var activeArray:[Bool] = Array(repeating: false, count: AppConstants.kPolygonTypeNames.count)
	var idArray:[Int] = Array(repeating: 0, count: AppConstants.kPolygonTypeNames.count)
	var numberOfFacesOfPolygonType:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var numberOfFacesOfPolygonType2:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var allVertices:[Vertex] = Array()
	var allCentroidVertices:[Vertex] = Array()
	var polyInfo: NSDictionary!
	var polygonNumber = 0
	var numberOfPolygons = 0
	var animatingQ = false
	var animationType = 1
	var polygons:[[Apolygon]] = Array(repeating: [], count: AppConstants.kPolygonTypeNames.count)
	
	
	override init(name: String, findTangents: Bool) {
		super.init(name: name, findTangents: findTangents)

		openDatabase()
		polyInfo = ["polyID": 4]
		do {
			try getNumberOfFacesForAllPolygons()
		} catch {
			print("Error")
			return
		}
		initialize(withPolyhedronInfo: polyInfo)
	}
	
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
	
	func initialize(withPolyhedronInfo polyInfo:NSDictionary) {
		self.polyInfo = polyInfo
		let polyhedronType = polyInfo.object(forKey: "polyID") as! Int
		
		do {
			try getAllVertices()
		} catch {
			print("Error")
			return
		}
		
		for polygon_type in 0..<AppConstants.kPolygonTypeNames.count {
			do {
				try getAllIndices(forPolygonType: polygon_type)
			} catch {
				print("Error")
				return
			}
			
			allCentroidVertices = allVertices
			initializePolygons(ofType: polygon_type)
			numberOfPolygons += numberOfFacesOfPolygonType[polygon_type]
		}
		generateConnectivityForPolyhedron()
	}
	
	func generateConnectivityForPolyhedron() {
		var count = 0
		let polygonsFlat = Array(polygons.joined())
		for poly1 in polygonsFlat {
			for poly2 in polygonsFlat {
				if poly1 !== poly2 {
					for num in poly1.indices {
						if poly2.indices.contains(num) {
							count += 1
							if (count > 1) {
//								connections.append(poly2)
								poly1.connections.append(poly2)
							}
						}
					}
				}
				count = 0
			}
		}
	}
	

	func initializePolygons(ofType type:Int) {
		var counter = 0
		let numSides = AppConstants.kPolygonTypesVertexCount[type]
		for ii in 0..<numberOfFacesOfPolygonType[type] {
			let poly:Apolygon = Apolygon.init(withType: type, withPolyhedron: self)
			poly.number = polygonNumber
			poly.animatingQ = false
			polygonNumber += 1
			poly.texture = -1
			poly.active = activeArray[ii] // Needs to be activeArray[type][ii]
			poly.dbID = idArray[ii] // Needs to be idArray[type][ii]
			setPolygonIndices(forPolygon: poly, withIndices: allIndices[type][ii])
			setPolygonVertices(forPolygon: poly)
			poly.generateCentroids()
			poly.generateLocalPolygonBases()
			poly.getCentroidVertices()  //  Adds vertex to allCentroidVertices
			poly.getCentroidIndices(withVertexCount: allCentroidVertices.count)
			polygons[type].append(poly)
		}
	}
	
	func setPolygonIndices(forPolygon polygon:Apolygon, withIndices indices:[UInt16]) {
		polygon.indices = indices
		
	}
	
	func setPolygonVertices(forPolygon polygon:Apolygon) {
		//		let count = indices.count
		//		let numSides = AppConstants.kPolygonTypesVertexCount[polygonType]
		
		//		numberOfFacesOfPolygonType2[polygonType] = Int(count/numSides)
		
		polygon.vertices = []
		for ii in 0..<polygon.numberOfSides {
			polygon.vertices.append(allVertices[Int(polygon.indices[ii])])
		}
		//		for ii in 0..<count {
		//			let num = Int(indices[ii])
		//			ertices.append(polyhedronVertices[num])
		//			polyVertices[polygonType][3*ii + 0] = Float(polyhedronVertices[3*num].x)//[[polyhedronVertices objectAtIndex:(3*num + 0)] floatValue];
		//			polyVertices[polygonType][3*ii + 1] = Float(polyhedronVertices[3*num + 1].y)//[[polyhedronVertices objectAtIndex:(3*num + 1)] floatValue];
		//			polyVertices[polygonType][3*ii + 2] = Float(polyhedronVertices[3*num + 2].z)//[[polyhedronVertices objectAtIndex:(3*num + 2)] floatValue];
		//		}
	}

	
	func getAllVertices() throws {
		let querySql = "SELECT x, y, z FROM vertices WHERE polyhedron_id = ?;"
		let polyhedron_id = polyInfo.object(forKey: "polyID") as! Int32
		guard let queryStatement = try? db.prepareStatement(sql: querySql)
			else {
			throw SQLiteError.Step(message: "Error")
		}
		defer {
			sqlite3_finalize(queryStatement)
		}
		guard sqlite3_bind_int(queryStatement, 1, polyhedron_id) == SQLITE_OK
			else {
			return
		}
		print("Vertices:")
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			
			let dataX = Float(sqlite3_column_double(queryStatement, 0))
			let dataY = Float(sqlite3_column_double(queryStatement, 1))
			let dataZ = Float(sqlite3_column_double(queryStatement, 2))
			let vertex = Vertex(x: dataX, y: dataY, z:dataZ)
			allVertices.append(vertex)
			print("[\(dataX), \(dataY), \(dataZ)]")
		}
		//		sqlite3_finalize(queryStatement)
		//    guard sqlite3_step(queryStatement) == SQLITE_ROW else {
		//      return nil
		//    }
//		return polyhedronVertices
	}
	
	func getNumberOfFacesForAllPolygons() throws {
		
		for ii in 0..<AppConstants.kPolygonTypeNames.count {
			let type = ii
			let typeName = ("indices_" + AppConstants.kPolygonTypeNames[type])
			
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
				numberOfDifferentPolygonTypes += 1
				
			}
		}
	}
	
	
	func getAllIndices(forPolygonType type: Int) throws {
		var querySql: String
//		allIndices =
//		allActive.removeAll()
//		idArray.removeAll()
		
		querySql = "select *, rowid from indices_" + AppConstants.kPolygonTypeNames[type] + " where polyhedron_id = ?;"
		let numSides = AppConstants.kPolygonTypesVertexCount[type]
		
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
		
		print("\(AppConstants.kPolygonTypeNames[type]) indices:")
		allIndices[type].removeAll()
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			var polyIndices:[UInt16] = Array()
			for jj in 1..<numSides + 1 {
				let index = UInt16(sqlite3_column_double(queryStatement, Int32(jj)))
				polyIndices.append(index)
				print("\(index)", terminator: ",")
			}
			allIndices[type].append(polyIndices)
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
	
	

	func convert(indices: [[UInt16]]) -> [[UInt16]] {
		var indicesNew:[[UInt16]] = Array()
		var value2:UInt16
		for index in indices {
			var groupNew:[UInt16] = Array()
			let firstIndex = index[0]
			for (num, value) in index.enumerated() {
				if num > 0 && num < index.count - 1 {
					value2 = index[num+1]
					groupNew.append(contentsOf: [firstIndex, value, value2])
				}
			}
			indicesNew.append(groupNew)
		}
		return indicesNew
	}

}

