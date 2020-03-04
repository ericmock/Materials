import Foundation

class PolyWordsView {
	var timeHistory:NSMutableArray!
	var wordsFound:NSMutableArray!
	var wordScores:NSMutableArray!
	var wordsFoundOpponent:NSMutableArray!
	var wordScoresOpponent:NSMutableArray!
	var oldWordsFound:NSMutableArray!
	var score:Int = 0
	var playTime:Float = 0.0
	var lastSubmitTime:Float = 0.0
	var gameState:Int = 0
	var wordString = ""
	var opponent_score:Int = 0
	var word_score:Int = 0
	var points_avail:Int = 0
	var points_avail_display:Int = 0
	var show_get_ready = false
	var opponent_ready = false
	
	func setWorldRotation(angle:Float, X:Float, Y:Float, Z:Float) {
		
	}
	
	func setRotation(angle:Float, X:Float, Y:Float, Z:Float) {
		
	}
	
	func endSpin() {
		
	}
	
	func selectPolyhedron(withInfo polyInfo:NSDictionary) {
		
	}
	
	func assignLetter(with num:Int, toPolyNumber polyNumber:Int) {
		
	}
}
