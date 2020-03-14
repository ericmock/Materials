//  This is simply the Polyhedron Statistics view but for one polyhedron.

import Cocoa
import SceneKit

public enum ShapeType:Int {
	
	case Box = 0
	case Sphere
	case Pyramid
	case Torus
	case Capsule
	case Cylinder
	case Cone
	case Tube
	
	// 2
	static func random() -> ShapeType {
		let maxValue = Tube.rawValue
		let rand = arc4random_uniform(UInt32(maxValue+1))
		return ShapeType(rawValue: Int(rand))!
	}
}

public struct Metadata: CustomDebugStringConvertible, Equatable {
	
	let statType: String
	let statValue: String
	
	init(statType: String, score: String) {
		self.statType = statType
		self.statValue = score
	}
	
	public var debugDescription: String {
		return "Word: \(statType), Score: \(statValue)"
	}
	
}
class ViewController: NSViewController {
	let kPolyhedronPerStage:Int = 5
	var stage:Int = 1
	var level:Int = 1

	@IBOutlet weak var polyhedronName: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let stageLevel:Int = kPolyhedronPerStage * stage + level
		let polyCount:Int = 10//appController.polyhedronInfoArray.count
		let num = stageLevel%polyCount
		let polyInfo = ["PolyID": 20, "Name": "Polyhedron"] as [String : Any] // appController.polyhedronInfoArray.object(at: num)
		var prevNum:Int
		if num > 0 {
			prevNum = num - 1
		} else {
			prevNum = 0
		}
		
		let visible:Bool = (num<=0 /*|| [[[[appController.polyhedronInfoArray objectAtIndex:prev_num] objectForKey:@"completed"] objectAtIndex:appController.mode] boolValue] || [[[polyInfo objectForKey:@"completed"] objectAtIndex:appController.mode] boolValue] */) ? true : false
		
		let polyhedronType = polyInfo["PolyID"]
		
		if visible {
			polyhedronName.stringValue = polyInfo["Name"] as! String
			/*
			((HighScores *)appController.highScores).mode = appController.mode;
			NSDictionary *dict = [((HighScores *)appController.highScores) getInformationAboutPolyhedron:polyhedron_type];
			
			if ([[dict objectForKey:@"fastestTime"] floatValue] < MAXFLOAT)
				highScoresView.fastestTime = [dict objectForKey:@"fastestTime"];
			else
				highScoresView.fastestTime = nil;
			
			if ([[dict objectForKey:@"highScore"] intValue] > 0)
				highScoresView.highScore = [dict objectForKey:@"highScore"];
			else
				highScoresView.highScore = nil;
			
			float totalTime = [[dict objectForKey:@"totalTime"] floatValue];
			float scoreTime = [[dict objectForKey:@"totalScore"] floatValue];
			float plays_scored = [[dict objectForKey:@"playsScored"] floatValue];
			float plays_timed = [[dict objectForKey:@"playsTimed"] floatValue];
			if (appController.mode == kStaticTimedMode || appController.mode == kDynamicTimedMode) {
				highScoresView.plays = [dict objectForKey:@"playsTimed"];
			} else {
				highScoresView.plays = [dict objectForKey:@"playsScored"];
			}
			if (plays_timed) {
				highScoresView.averageTime = [NSNumber numberWithFloat:totalTime/plays_timed];
			} else {
				highScoresView.averageTime = nil;
			}
			if (plays_scored) {
				highScoresView.averageScore = [NSNumber numberWithFloat:scoreTime/plays_scored];
			} else {
				highScoresView.averageScore = nil;
			}
			

			*/
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

