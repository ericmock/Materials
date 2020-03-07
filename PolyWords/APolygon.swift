import Foundation

class Apolygon {
	var letter = ""
	var type:Int!
	var active = false
	var number = 0
	var texture = 0
	var selected = false
	var tangent_v:float3
	var bitan_v:float3
	var normal_v:float3
	var rot_angle:Float
	var rot_v:float3
	var select_animation_start_time:Date!
	var indices:NSArray!
	var connections:NSMutableArray!
	var centroid:float3
	
	init() {
		type = 0
		tangent_v = [0,0,0]
		bitan_v = [0,0,0]
		normal_v = [0,0,0]
		rot_angle = 0
		rot_v = [0,0,0]
		centroid = [0,0,0]
		select_animation_start_time = Date()
		indices = NSArray()
	}
	
//	init(vertices: [SIMD3<Float>], indices: [SIMD3<Int>], textureNumber: Int) {
//			self.vertices = vertices;
//			self.indices = indices;
//			self.textureNumber = textureNumber
//
//			self.polyType = indices.count
//
//			for vertex in vertices {
//					centroid += vertex
//			}
//			centroid = centroid/Float(polyType)
//	}

}