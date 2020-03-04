import Foundation
import Cocoa

class PolyWordsView : NSView {
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
	var opponentWordsToDispay:NSMutableArray!
	var show_opponent_word = false
	var word_score:Int = 0
	var points_avail:Int = 0
	var points_avail_display:Int = 0
	var show_get_ready = false
	var opponent_ready = false
	var appController:AppController!
	var touchedLetterView:NSTextField!
	var match_red:Float = 1.0
	var match_green:Float = 1.0
	var match_blue:Float = 1.0
	let pullDataController = PullDataController()
	let pushDataController = PushDataController()
	var paused = true
	let clock = Timer()
	var score_animating = false
	var gameAnimationTimer:Timer!
	
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
	
	required init?(coder:NSCoder) {
		super.init(coder:coder)
	}
	
	convenience init?(withFrame frame:CGRect, withAppController d:AppController, aCoder:NSCoder) {
		self.init(coder: aCoder)
		appController = d
		//		self.initializeIvars(withFrame: frame)
		self.addSubview(touchedLetterView)
		var yPos:CGFloat
		if !appController.unlocked {
			yPos = -48.0
		} else {
			yPos = 0.0
		}
		var thickness:CGFloat = 95.0
		let polygonsCheckedView = NSTextField(string: "\nPolygons Checked")
		polygonsCheckedView.frame = CGRect(x: CGFloat(0.0), y: yPos, width: appController.screenRect.width, height: CGFloat(thickness))
		//		polygonsCheckedView.adjustsFontSizeToWidth = true
		polygonsCheckedView.backgroundColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
		polygonsCheckedView.font = NSFont(name: "Helvetica", size: 36)
		polygonsCheckedView.textColor = .white
		polygonsCheckedView.alignment = .center
		polygonsCheckedView.isHidden = (appController.checking != 2)
		//		polygonsCheckedView.numberOfLines = 2
		//		polygonsCheckedView.shadowColor = .black
		//		polygonsCheckedView.shadowOffset = CGSizeMake(2.0,2.0)
		polygonsCheckedView.tag = 100
		self.addSubview(polygonsCheckedView)
		
		yPos += thickness
		thickness = 65.0
		let indicatorView = NSTextField(frame: CGRect(x: 0.0, y: yPos, width: appController.screenRect.width, height: thickness))
		indicatorView.backgroundColor = NSColor(red:1.0, green: 0.0, blue: 0.0, alpha:0.1)
		
		indicatorView.isHidden = (appController.checking != 2)
		indicatorView.tag = 101
		self.addSubview(indicatorView)
		
		yPos += thickness
		thickness = 95.0
		let availableWordsView = NSTextField(string: "Words Found")
		availableWordsView.frame = CGRect(x: 0.0, y: yPos, width: appController.screenRect.width, height: thickness)
		//				availableWordsView.adjustsFontSizeToFitWidth = YES
		availableWordsView.backgroundColor = .red//[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
		availableWordsView.font = NSFont(name: "Helvetica", size: 36)
		availableWordsView.textColor = .white
		availableWordsView.alignment = .center
		availableWordsView.isHidden = (appController.checking != 2)
		//				availableWordsView.numberOfLines = 3
		//				availableWordsView.shadowColor = [UIColor blackColor]
		//				availableWordsView.shadowOffset = CGSizeMake(2.0,2.0)
		availableWordsView.tag = 102
		self.addSubview(availableWordsView)
		
		yPos += thickness
		thickness = 65.0
		let indicatorView2 = NSTextField.init(frame:CGRect(x: 0.0, y: yPos, width: appController.screenRect.size.width, height: thickness))
		indicatorView2.backgroundColor = NSColor(red:1.0, green:0.0, blue:0.0, alpha:0.1)
		indicatorView2.isHidden = (appController.checking != 2)
		indicatorView2.tag = 103
		self.addSubview(indicatorView2)
		
		yPos += thickness
		thickness = 95.0
		let availablePointsView = NSTextField(string: "nPoints Found")
		
		availablePointsView.frame = CGRect(x: 0.0, y: yPos, width: appController.screenRect.size.width, height: thickness)
		//				availablePointsView.adjustsFontSizeToFitWidth = YES
		availablePointsView.backgroundColor = .red
		availablePointsView.font = NSFont(name: "Helvetica", size: 36)
		availablePointsView.textColor = .white
		availablePointsView.alignment = .center
		availablePointsView.isHidden = (appController.checking != 2)
		//				availablePointsView.numberOfLines = 3
		//				availablePointsView.shadowColor = [UIColor blackColor]
		//				availablePointsView.shadowOffset = CGSizeMake(2.0,2.0)
		availablePointsView.tag = 104
		self.addSubview(availablePointsView)
		
		yPos += thickness
		thickness = 65.0
		let indicatorView3 = NSTextField.init(frame:CGRect(x: 0.0, y: yPos, width: appController.screenRect.size.width, height: thickness))
		indicatorView3.backgroundColor = NSColor(red:1.0, green:0.0, blue:0.0, alpha:0.1)
		indicatorView3.isHidden = (appController.checking != 2)
		indicatorView3.tag = 105
		self.addSubview(indicatorView3)
		
		timeHistory = NSMutableArray()
	}
	
	func resetMatchColor() {
		match_red = 1.0
		match_green = 1.0
		match_blue = 1.0
	}
	
	func updateOpponent(information:NSArray) {
		if (information.count == 2) {
			let newWords = information.object(at:0) as! NSArray
			let newScores = information.object(at:1) as! NSArray
			for word in newWords as! [String] {
				wordsFoundOpponent.add(word)
				opponentWordsToDispay.add(word)
				show_opponent_word = true
			}
			for scoreString in newScores as! [String] {
				opponent_score += Int(scoreString)!
				wordScoresOpponent.add(Int(scoreString) ?? 0)
			}
		}
		pullDataController.startSend(arrayWithObjects: NSArray(array: [UInt(appController.game_id), Int(appController.mode)]))
	}
	
	func pause() {
		//		// FIXME:  crashing on the following line after a few pauses
		let pauseAlert = PauseAlert.init(withView:self)
		self.addSubview(pauseAlert)// pauseAlert.superview(self) //showInView:self];
		self.stopClock()
		self.stopGameAnimation()
	}
	
	func stopClock() {
		self.paused = true
		clock.fireDate = .distantFuture//[NSDate distantFuture]];
	}
	
	@objc func stopGameAnimation() {
		if (score_animating && gameAnimationTimer != nil) {
			self.perform(#selector(stopGameAnimation), with: nil, afterDelay: 1.0)
			//		[self performSelector:@selector(stopGameAnimation) withObject:nil afterDelay:1.0];
		} else {
			gameAnimationTimer.invalidate()
			gameAnimationTimer = nil
		}
	}
	
	func pushData() {
		let newWordsFound = NSMutableArray()
		let newWordScores = NSMutableArray()
		let count_old_words_found = oldWordsFound.count
		let count_words_found = wordsFound.count
		for ii in count_old_words_found..<count_words_found {
			newWordsFound.add(wordsFound.object(at:ii))
			newWordScores.add(wordScores.object(at:ii))
		}

		oldWordsFound = NSMutableArray()
		oldWordsFound.addObjects(from:wordsFound as! [Any])
		let updatedData = NSArray(array: [newWordsFound, newWordScores, UInt(appController.game_id), Int(appController.mode)])
		pushDataController.startSend(with: updatedData)
	}

}
