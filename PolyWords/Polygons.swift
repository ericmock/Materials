import Foundation

class Polygons {
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
	
	init() {
		type = 0
		tangent_v = [0,0,0]
		bitan_v = [0,0,0]
		normal_v = [0,0,0]
		rot_angle = 0
		rot_v = [0,0,0]
		select_animation_start_time = Date()
		indices = NSArray()
	}
}
