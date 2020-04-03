import Foundation

class Apolygon {
	var letter = ""
	var type:Int!
	var active = false
	var number = 0
	var texture = 0
	var selected = false
	var touched = false
	var tangent_v:float3 = [0,0,0]
	var bitan_v:float3 = [0,0,0]
	var normal_v:float3 = [0,0,0]
	var rot_angle:Float = 0
	var rot_v:float3 = [0,0,0]
	var position:float3 = [0,0,0]
	var select_animation_start_time = 0.0
	//	var indices:NSArray!
	var connections:[Apolygon] = []
	var centroid:float3 = [0,0,0]
	var indices:[UInt16] = []
	var vertices:[float3] = []
	var centroidIndices:[UInt16] = []
	var centroidVertices:[float3] = []
	var radius:Float = 0.0
	var animatingQ:Bool = false
	var dbID:Int = 0
	var name:String = ""
	let basePolygon:[BasePolygon] = []
	var baseTextureCoords:[SIMD2<Float>] = Array()
	var scaledBaseTextureCoords:[SIMD2<Float>] = Array()
	var textureCoords:[SIMD2<Float>] = Array()
	var numberOfSides:Int = 0
	var polyhedron:Polyhedron
	
	init(withType type:Int, withPolyhedron polyhedron:Polyhedron) {
		self.type = type
		self.polyhedron = polyhedron
		name = AppConstants.kPolygonTypeNames[type]
		select_animation_start_time = 0.0
		
		numberOfSides = AppConstants.kPolygonTypesVertexCount[type]
		let scale:Float = 1/1.0
		getTextureCoords(type, scale, numberOfSides)
	}
	
	fileprivate func getTextureCoords(_ polyhedronType: Int, _ scale: Float, _ numSides: Int) {
		// Deal with triangles
		var polygonIndex:Int
		if numSides == 3 {
			polygonIndex = 0
			if polyhedronType == 7 {
				let scale2:Float = 1.1
				let shift:Float = (scale2 - 1.0)/2.0
				let baseTextureCoords = [SIMD2<Float>(scale2*0.512355 - shift, scale2*0.766774 - shift - 0.04),
										SIMD2<Float>(scale2 * -0.0123553 - shift, scale2*0.366613 - shift - 0.04),
										SIMD2<Float>(scale2*1.0 - shift, scale2*0.366613 - shift - 0.04)]
				scaledBaseTextureCoords = Array()
				for coord in baseTextureCoords {
					scaledBaseTextureCoords.append(float2(scale,scale) * coord)
				}
			}
			else if polyhedronType == 31 {
				let scale2:Float = 1.0
				let shift:Float = (scale2 - 1.0)/2.0
				let baseTextureCoords = [SIMD2<Float>(scale2 * 0.337327 - shift, scale2*(1.0 + 0.05) - shift),
										SIMD2<Float>(scale2 * 0.300672 - shift, scale2*(0.25 + 0.05) - shift),
										SIMD2<Float>(scale2 * 0.862001 - shift, scale2*(0.25 + 0.05) - shift)]
				scaledBaseTextureCoords = Array()
				for coord in baseTextureCoords {
					scaledBaseTextureCoords.append(float2(scale,scale) * coord)
				}
				// Why did I have two different texture coords??
//				let temp2 = [
//					SIMD2<Float>(scale2 * (1.0 - 0.337327) - shift, scale2*(1.0 + 0.05) - shift),
//					SIMD2<Float>(scale2 * (1.0 - 0.300672) - shift, scale2*(0.25 + 0.05) - shift),
//					SIMD2<Float>(scale2 * (1.0 - 0.862001) - shift, scale2*(0.25 + 0.05) - shift)
//				]
//				for t in temp2 {
//					scaledBaseTextureCoords[polygonIndex][13] = scale * t
//					baseTextureCoords[polygonIndex][13] = t
//				}
			}
			else {
				baseTextureCoords = Array()
				scaledBaseTextureCoords = Array()
				for ii in 0..<3 {
					baseTextureCoords.append(float2(1.0/2.0 * (cos(Float(2*ii) * .pi/Float(numSides) + .pi/6.0) + 1), 1.0/2.0 * (sin(Float(2*ii) * .pi/Float(numSides) + .pi/6.0) + 1)))
					scaledBaseTextureCoords.append(float2(scale,scale) * baseTextureCoords.last!)
				}
			}
		}
		
		// Deal with squares
		if numSides == 4 {
			polygonIndex = 1
			if polyhedronType == 3 {
				let baseTextureCoords = [
					float2(0.5, 1.0),
					float2(0.105022, 0.412023),
					float2(0.5, 0.175955),
					float2(0.894978, 0.412023)
				]
				
				scaledBaseTextureCoords = Array()
				for coord in baseTextureCoords {
					scaledBaseTextureCoords.append(float2(scale,scale) * coord)
				}
			}
			else if polyhedronType == 23 {
				let scale2:Float = 1.1
				let shift:Float = (scale2 - 1.0)/2.0
				let baseTextureCoords = [
					float2(scale2*0.0 - shift, scale2*0.5 - shift),
					float2(scale2*0.5 - shift, scale2*0.190983 - shift),
					float2(scale2*1.0 - shift, scale2*0.5 - shift),
					float2(scale2*0.5 - shift, scale2*0.809017 - shift)
				]
				scaledBaseTextureCoords = Array()
				for coord in baseTextureCoords {
					scaledBaseTextureCoords.append(float2(scale,scale) * coord)
				}

			}
			else if polyhedronType == 25 {
				var temp2 = [
					float2(0.5, 0.0871677),
					float2(0.879126, 0.456416),
					float2(0.5, 1.0),
					float2(0.120874, 0.456416)]
				let scale2:Float = 1.1
				let shift:Float = (scale2 - 1.0)/2.0
				for ii in 0..<temp2.count {
					temp2[ii] *= scale2
					temp2[ii] -= shift
				}
				scaledBaseTextureCoords = Array()
				baseTextureCoords = Array()
				for t in temp2 {
					scaledBaseTextureCoords.append(scale * t)
					baseTextureCoords.append(t)
				}
				
			}
			else {
				baseTextureCoords = Array()
				scaledBaseTextureCoords = Array()
				for ii in 0..<4 {
					baseTextureCoords.append(float2(1.0/2.0 * (cos(Float(ii) * .pi/2.0 + .pi/4.0) + 1), 1.0/2.0 * (sin(Float(ii) * .pi/2.0 + .pi/4.0) + 1)))
					scaledBaseTextureCoords.append(float2(scale,scale) * baseTextureCoords.last!)
				}
			}
		}
		
		// Deal with remaining polygons
		if (numSides > 4) {
			polygonIndex = numSides - 3
			baseTextureCoords = Array()
			scaledBaseTextureCoords = Array()
			for ii in 0..<numSides {
				baseTextureCoords.append(float2(1.0/2.0 * (cos(2.0 * Float(ii) * .pi/Float(numSides) + .pi/2.0/Float(numSides)) + 1), 1.0/2.0 * (sin(2.0 * Float(ii) * .pi/Float(numSides) + .pi/2.0/Float(numSides)) + 1)))
				scaledBaseTextureCoords.append(float2(scale,scale) * baseTextureCoords.last!)
			}
		}
		
		var centroidTextureCoord = float2(0,0)
		for coord in baseTextureCoords {
			centroidTextureCoord += coord
		}
		centroidTextureCoord /= Float(numSides)
		
		baseTextureCoords.insert(centroidTextureCoord, at: 0)

		var scaledCentroidTextureCoord = float2(0,0)
		for coord in scaledBaseTextureCoords {
			scaledCentroidTextureCoord += coord
		}
		scaledCentroidTextureCoord /= Float(numSides)
		
		scaledBaseTextureCoords.insert(scaledCentroidTextureCoord, at: 0)
	}
	
	func setTextureCoords(forType type:Int) {
	}
	
	func generateLocalPolygonBases() {
		var ave = SIMD3<Float>(0,0,0)
		var index:UInt16
		for vertex in vertices {
			ave += vertex
		}
		
		ave = ave/Float(vertices.count)
		
		radius = simd_distance(vertices[0], ave)
		
		let v1 = vertices[0] - vertices[1]
		let v2 = vertices[0] - vertices[2]
		normal_v = normalize(cross(v1, v2))
		polyhedron.allCentroidNormals.append(normal_v)
		if let last = polyhedron.allCentroidNormalIndices.last {
			index = last + 1
		} else {
			index = 0
		}
		polyhedron.allCentroidNormalIndices.append(index)
		tangent_v = normalize(v1)
		bitan_v = cross(normal_v, tangent_v)
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
	
	func generateCentroids() {
		centroid = [0.0, 0.0, 0.0]
		for jj in 0..<vertices.count {
			centroid += vertices[jj]
		}
		centroid /= Float(vertices.count)
	}
	
	func generateCentroidVertices() {
		centroidVertices = vertices
		centroidVertices.insert(centroid, at: 0)
	}

	func getCentroidIndices(withVertexCount vertexCount:Int) {
		var value2:UInt16
		centroidIndices = Array()
		for (num, value) in indices.enumerated() {
			let centroidIndex = UInt16(vertexCount - 1)
			value2 = indices[(num+1)%indices.count]
			centroidIndices.append(contentsOf: [centroidIndex, value, value2])
			polyhedron.allCentroidIndices.append(contentsOf: [centroidIndex, value, value2])
		}
	}
}
