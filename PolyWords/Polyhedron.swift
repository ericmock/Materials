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
	var activeArray:[Bool] = Array(repeating: false, count: AppConstants.kPolygonTypeNames.count)
	var idArray:[Int] = Array(repeating: 0, count: AppConstants.kPolygonTypeNames.count)
	var numberOfFacesOfPolygonType:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var numberOfFacesOfPolygonType2:[Int] = Array(repeating: 0, count: AppConstants.kNumPolygonTypes + 1)
	var polyInfo: NSDictionary!
	var polygonNumber = 0
	var numberOfPolygons = 0
	var animatingQ = false
	var animationType = 1
	var polygons:[[Apolygon]] = Array(repeating: [], count: AppConstants.kPolygonTypeNames.count)
	
	
	init(name: String, withPolyID polyID:Int, scene:Scene) {
		super.init(forScene: scene)

		openDatabase()
		polyInfo = ["polyID": polyID]
		do {
			try getNumberOfFacesForAllPolygons()
		} catch {
			print("Error")
			return
		}
		initialize(withPolyhedronInfo: polyInfo, scene: scene)
		
		super.initialize(name: "Polyhedron", scene: scene)
	}
	
	func openDatabase() {
		let dbPath = Bundle.main.resourceURL?.appendingPathComponent("data.sqlite").absoluteString//directoryUrl?.appendingPathComponent("data.sqlite").relativePath
		
		do {
			db = try PolyhedraDatabase.open(path: dbPath!)
		} catch SQLiteError.OpenDatabase(_) {
			print("Unable to open database.")
			return
		} catch {
			return
		}
	}
	
	func initialize(withPolyhedronInfo polyInfo:NSDictionary, scene:Scene) {
		self.polyInfo = polyInfo
		let polyhedronType = polyInfo.object(forKey: "polyID") as! Int
		
		do {
			try getAllVertices()
		} catch {
			print("Error")
			return
		}
		
		allCentroidVertices = allVertices
		for polygon_type in 0..<AppConstants.kPolygonTypeNames.count {
			do {
				try getAllIndices(forPolygonType: polygon_type)
			} catch {
				print("Error")
				return
			}
			
			initializePolygons(ofType: polygon_type)
			numberOfPolygons += numberOfFacesOfPolygonType[polygon_type]
		}
		generateFaceVerticesAndIndices()
		generateConnectivityForPolyhedron()
	}
	
	func generateFaceVerticesAndIndices() {
		let colorMultiplier = [float3(1.5,1.0,1.0),float3(1.0,1.5,1.0),float3(1.0,1.0,1.5),float3(1.5,1.5,1)]
		var indexCounter:UInt16 = 0
		var polygonCounter:Int = 0
		for polygonsOfType in polygons {
			for poly in polygonsOfType {
				let letter = Int.random(in: 0...25)
				poly.letter = AppConstants.kAlphabet[letter%25]
				polygonLetters.append(Int16(letter))
				for (num, vertex) in poly.centroidVertices.enumerated() {
//					print(poly.scaledBaseTextureCoords[num])
					let newVertex = Vertex(position: vertex,
																 normal: poly.normal_v,
																 uv: poly.scaledBaseTextureCoords[num],
																 colorShift: colorMultiplier[(poly.numberOfSides-3)%4],
																 faceNumber: poly.number
//																 letterNumber: polygonCounter%25
//																 tangent: poly.tangent_v,
//																 bitangent: poly.bitan_v
					)
					faceVertices.append(newVertex)
				}
				polygonCounter += 1
				var localIndices:[UInt16] = Array(repeating: 0, count: 3*poly.numberOfSides)
				var localIndexCounter:UInt16 = 1
				for num in 0..<poly.numberOfSides {
					localIndices[3*num] = 0 + indexCounter
					localIndices[3*num + 1] = localIndexCounter + indexCounter
					localIndices[3*num + 2] = (localIndexCounter)%UInt16(poly.numberOfSides) + indexCounter + 1
					localIndexCounter += 1
				}
				faceIndices.append(contentsOf: localIndices)
				indexCounter += localIndexCounter
			}
		}
//		for vertex in faceVertices {
//				print("Sides: \(vertex.uv), Letter: \(vertex.letterNumber)")
//		}
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
//		var counter = 0
//		let numSides = AppConstants.kPolygonTypesVertexCount[type]
		for ii in 0..<numberOfFacesOfPolygonType[type] {
			let poly:Apolygon = Apolygon.init(withType: type, withPolyhedron: self)
			poly.number = polygonNumber
			poly.animatingQ = false
			polygonNumber += 1
			poly.texture = -1
			poly.active = true//activeArray[type][ii] // Needs to be activeArray[type][ii]
			poly.dbID = 0//idArray[type][ii] // Needs to be idArray[type][ii]
			setPolygonIndices(forPolygon: poly, withIndices: allIndices[type][ii])
			setPolygonVertices(forPolygon: poly)
			poly.generateCentroids()
			poly.generateLocalPolygonBases()
			poly.generateCentroidVertices()  //  Adds vertex to allCentroidVertices
			poly.getCentroidIndices(withVertexCount: allCentroidVertices.count)
			polygons[type].append(poly)
		}
	}
	
	func setPolygonIndices(forPolygon polygon:Apolygon, withIndices indices:[UInt16]) {
		polygon.indices = indices
		
	}
	
	func setPolygonVertices(forPolygon polygon:Apolygon) {
		polygon.vertices = []
		for ii in 0..<polygon.numberOfSides {
			polygon.vertices.append(allVertices[Int(polygon.indices[ii])])
		}
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
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			
			let dataX = Float(sqlite3_column_double(queryStatement, 0))
			let dataY = Float(sqlite3_column_double(queryStatement, 1))
			let dataZ = Float(sqlite3_column_double(queryStatement, 2))
			let vertex = float3(dataX, dataY, dataZ)
			allVertices.append(vertex)
		}
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
			
			let id = polyInfo.object(forKey: "polyID") as! Int32
			guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
				return
			}
//			print("Query Result:")
			while (sqlite3_step(queryStatement) == SQLITE_ROW) {
				numberOfFacesOfPolygonType[type] = Int(sqlite3_column_int(queryStatement, 0))
				numberOfDifferentPolygonTypes += 1
				
			}
		}
	}
	
	
	func getAllIndices(forPolygonType type: Int) throws {
		var querySql: String
		
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
		
		super.allIndices[type].removeAll()
		while (sqlite3_step(queryStatement) == SQLITE_ROW) {
			var polyIndices:[UInt16] = Array()
			for jj in 1..<numSides + 1 {
				let index = UInt16(sqlite3_column_double(queryStatement, Int32(jj)))
				polyIndices.append(index)
			}
			super.allIndices[type].append(polyIndices)
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

