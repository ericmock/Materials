import Foundation
import Cocoa
import simd

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
	var clock = Timer()
	var score_animating = false
	var gameAnimationTimer:Timer!
	var prev_time = Date()
	var match:Bool = false
	var wordArray:NSMutableArray!
	var submittingPolygonsValuesArray:NSMutableArray!
	var touchedPolygonsArray:NSMutableArray!
	let valueArray:[Int] = [1, 3, 2, 2, 1, 2, 2, 1, 1, 4, 3, 2, 2, 1, 1, 3, 4, 1, 1, 1, 2, 3, 2, 4, 3, 4]
	var last_submit_time:Float = 0.0
	var num_words_found:Int = 0
	var polyhedron:Polyhedron!
	var dynamicWordsFoundFileHandle:FileHandle!
	var staticWordsFoundFileHandle:FileHandle!
	let commonLettersArray = NSArray(array:["A", "E", "I", "O", "T", "N"])
	let uncommonLettersArray = NSArray(array:["J", "Q", "X", "Z"])
	var lookingUpWordsQ = false
	var availableWords:NSMutableArray!
	var wordsDB:WordsDB!
	var previousTouchedPoly:Polygons!
	var recordScore = false
	var highScore = 0


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
	
	func startClock() {
		if (clock.isValid) {
			clock.invalidate()
//			clock = nil;
		}
		prev_time = Date();
		clock = Timer.init(fireAt:Date(), interval:1, target:self, selector:#selector(oneSecondPulse), userInfo:nil, repeats:true)
		self.paused = false
		appController.polyWordsViewController.game_state = AppConstants.kGameContinue

//		[[NSRunLoop currentRunLoop] addTimer:clock forMode:NSDefaultRunLoopMode];

		if (appController?.mode == AppConstants.kTwoPlayerClientMode) || (appController?.mode == AppConstants.kTwoPlayerServerMode) {
			pullDataController.startSend(arrayWithObjects:[appController.game_id, Int(appController.mode)]);
		}
	}

	func checkMatch() {
		if (appController.mode == AppConstants.kStaticTimedMode || appController.mode == AppConstants.kStaticScoredMode || appController.mode == AppConstants.kTwoPlayerClientMode || appController.mode == AppConstants.kTwoPlayerServerMode) {
			if (wordString.count > 2 && wordArray.contains(wordString) && !wordsFound.contains(wordString) && !wordsFoundOpponent.contains(wordString)) {
				match = true
				self.getWordScore()
			}
		} else {
			if (wordString.count > 2 && wordArray.contains(wordString)) {
				match = true
				self.getWordScore()
			} else {
				match = false
			}
		}
	}
	
	func getWordScore() {
//		var letter_score:Float = 0.0
		var base_word_score:Float = 0.0
		submittingPolygonsValuesArray.removeAllObjects()
			for poly in touchedPolygonsArray as! [Polygons] {
				let letter_num = appController.alphabetArray.firstIndex(of: poly.letter)!
				let polygon_type = poly.type
				var num_sides = polygon_type! + 3;
				if (polygon_type == 10 || polygon_type == 11 || polygon_type == 12) {
					num_sides = 4
				} else if (polygon_type == 13 || polygon_type == 14 || polygon_type == 15) {
					num_sides = 3
				}
				let factor1:Float = -1.0*pow(-1,match ? 1.0 : 0.0)
				let factor2:Float = (12.0 - Float(num_sides))
				let factor3:Float = Float(valueArray[letter_num]) * (match ? Float(wordString.count) : 1.0)
				let letter_score = factor1 * factor2 * factor3
				base_word_score += letter_score
				submittingPolygonsValuesArray.add(Int(letter_score))
			}

//		let word_length = wordString.count
			var word_score = base_word_score;//-1.0*pow(-1,(float)match)*letter_score * (match?[wordString length]:1.0);

		if ((appController.mode != AppConstants.kDynamicTimedMode && appController.mode != AppConstants.kDynamicScoredMode) && word_score < 0) {
				word_score = 0
		}

	}
	
	func submitWord() {
		last_submit_time = playTime

		self.getWordScore()
		// if we in dynamic letter mode, replace the submitted letters
		if (appController.mode == AppConstants.kDynamicTimedMode || appController.mode == AppConstants.kDynamicScoredMode) {
			let polygonsToReplace = NSArray(array: touchedPolygonsArray)
			submittingPolygonsValuesArray.removeAllObjects()
			for poly in touchedPolygonsArray as! [Polygons] {
				submittingPolygonsValuesArray.add(poly)
			}
			
			self.getNewLetters(forPolygons:polygonsToReplace)
			self.setAnimation()
		}
		// if not just deselect them
		else {
			submittingPolygonsValuesArray.removeAllObjects()
			for poly in touchedPolygonsArray as! [Polygons] {
				submittingPolygonsValuesArray.add(poly)
			}
		}

		score += word_score;
	//	score_display = (score < 0)?0:score;

		if (match) {
			appController.swipeSound.play()
			let wordStringCopy = wordString.copy()
			wordsFound.add(wordStringCopy)
			wordScores.add(Int(word_score))
			if appController.mode == AppConstants.kTwoPlayerClientMode || appController.mode == AppConstants.kTwoPlayerServerMode {
				self.pushData()
				num_words_found = wordsFound.count
				match = false
				score_animating = true
				if appController.mode == AppConstants.kDynamicTimedMode || appController.mode == AppConstants.kDynamicScoredMode {
					let polyInfoString = polyhedron.polyInfo.object(forKey:"polyID") as! String
					let wordScoreString = String(word_score)
					let wordsFoundString = wordString + "," + wordScoreString + "," + polyInfoString
					dynamicWordsFoundFileHandle.write(wordsFoundString.data(using:.utf8)!)
				}
			} else if appController.mode == AppConstants.kStaticTimedMode || appController.mode == AppConstants.kStaticScoredMode {
				let polyInfoString = polyhedron.polyInfo.object(forKey:"polyID") as! String
				let wordScoreString = String(word_score)
				let wordsFoundString = wordString + "," + wordScoreString + "," + polyInfoString
				staticWordsFoundFileHandle.write(wordsFoundString.data(using:.utf8)!)
			}
		}
		
		self.resetMatchColor()
		wordString = ""
		word_score = 0
	}

	func getNewLetters(forPolygons polygons:NSArray) {
		for poly in polygons as! [Polygons] {
			self.assignRandomLetterToPoly(number:poly.number)
		}
	}
	
	func assignRandomLetterToPoly(number ii:Int) {
		var rd:Int
//		srandomdev();
		let poly = polyhedron.polygons.object(at:ii) as! Polygons
		var g = SystemRandomNumberGenerator()
		if (poly.active) {
			rd = Int.random(in: 0...(appController.alphabetArray.count - 1), using: &g);
			if uncommonLettersArray.contains(appController.alphabetArray[rd]) {
				rd = Int.random(in: 0...(appController.alphabetArray.count - 1), using: &g);
			} else if !uncommonLettersArray.contains(appController.alphabetArray[rd]) {
				rd = Int.random(in: 0...(appController.alphabetArray.count - 1), using: &g);
			}
			//	rd=ii+1;// for numbers
			poly.texture = rd % 180
			poly.letter = appController.alphabetArray[rd % appController.alphabetArray.count]
		} else {
			poly.texture = 26
			poly.letter = "-";
		}
	}
	
	func setMatchColor() {
		if (match) {
			match_red = 0.0
			match_green = 1.0
			match_blue = 0.0
		} else if (wordsFound.contains(wordString)) {
			match_red = 1.0
			match_green = 1.0
			match_blue = 0.0
		} else if (wordsFoundOpponent.contains(wordString)) {
			match_red = 1.0
			match_green = 0.5
			match_blue = 0.0
		} else if (!lookingUpWordsQ && wordString.count > 2) {
			match_red = 1.0
			match_green = 0.0
			match_blue = 0.0
		} else {
			match_red = 1.0
			match_green = 1.0
			match_blue = 1.0
		}
	}
	
	func set(touchedPolygon touchedPoly:Polygons = Polygons()) {

		// reset the match identifier
		match = false

		if !(touchedPoly.active) {
			for poly in touchedPolygonsArray as! [Polygons] {
				poly.selected = false
			}
			touchedPolygonsArray.removeAllObjects()

			wordString = ""
			self.getWordScore()
			return
		}

		touchedPoly.selected = true

		// check to see if it is already selected
		if (touchedPolygonsArray.contains(touchedPoly)) {
			// if it's already selected grab the index number and length of the range to remove from the selected array
			let index = touchedPolygonsArray.index(of: touchedPoly)
			let length = touchedPolygonsArray.count - index
			// reset the touched flag of all the previously touched polygons
			for poly in touchedPolygonsArray as! [Polygons] {
				poly.selected = false
			}
			let range = NSMakeRange(index, length)
			// remove the touched polygon and all those higher on the stack
			touchedPolygonsArray.removeObjects(in: range)// removeObjectsInRange:range];
			// reset the word string to contain only selected letters
			wordString = ""
			for poly in touchedPolygonsArray as! [Polygons] {
				poly.selected = true
				wordString.append(contentsOf: poly.letter.lowercased())
			}

		} else {
//			 if the polygon wasn't already selected, add it to the array of selected polygons
//			 determine how many vertices the touched polygon has in common with the previously touched polygon
//
//						00  04  08  12
//						01  05  09  13
//						02  06  10  14
//						03  07  11  15
//
//			 generate a rotation matrix that takes the polygon basis to the global basis
			var rot_m:float3x3 = matrix_identity_float3x3
			rot_m[0][0] = touchedPoly.tangent_v[0]
			rot_m[0][1] = touchedPoly.tangent_v[1]
			rot_m[0][2] = touchedPoly.tangent_v[2]
			rot_m[1][0] = touchedPoly.bitan_v[0]
			rot_m[1][1] = touchedPoly.bitan_v[1]
			rot_m[1][2] = touchedPoly.bitan_v[2]
			rot_m[2][0] = touchedPoly.normal_v[0]
			rot_m[2][1] = touchedPoly.normal_v[1]
			rot_m[2][2] = touchedPoly.normal_v[2]

			// calculate the rotation angle per http://en.wikipedia.org/wiki/Rotation_representation
			touchedPoly.rot_angle = acos( (rot_m[0][0] + rot_m[1][1] + rot_m[2][2] - 1.0)/2.0 )

			// calculate the rotation vector per http://en.wikipedia.org/wiki/Rotation_representation
			let denom = 2.0*sin(touchedPoly.rot_angle)
			touchedPoly.rot_v[0] = (rot_m[2][1] - rot_m[1][2])/denom
			touchedPoly.rot_v[1] = (rot_m[0][2] - rot_m[2][0])/denom
			touchedPoly.rot_v[2] = (rot_m[1][0] - rot_m[0][1])/denom

			touchedPoly.select_animation_start_time = Date()

			var count:UInt = 0
			for num in touchedPoly.indices as! [Int] {
				if (touchedPolygonsArray.lastObject as! Polygons).indices.contains(num) {
					count += 1
				}
			}
			// if the polygon doesn't share at least two vertices with the previously touched polygon...
			if (count < 2 && touchedPolygonsArray.count > 0) {
				// ...reset touched flag for all previously touched polygons...
				for poly in touchedPolygonsArray as! [Polygons] {
					poly.selected = false
				}
				// ...clear the array of selected polygons...
				touchedPolygonsArray.removeAllObjects()
				// ...and set the touched flag and add the touched polygon to the array.
				touchedPoly.selected = true
				touchedPolygonsArray.add(touchedPoly)
			} else {
				touchedPolygonsArray.add(touchedPoly)
			}
			// update the word string
			wordString = ""
			for poly in touchedPolygonsArray as! [Polygons] {
				wordString.append(contentsOf: poly.letter.lowercased())
			}
		}

		// if there are three letters selected, use the other thread to grab all the words that start with those three letters
		if wordString.count >= 3 {
			self.lookingUpWordsQ = true
			var foundWord = ""
			wordArray.removeAllObjects()
			if (availableWords.count == 0) {
				if (availableWords.contains(wordString)) {
					foundWord = wordString
				}
				lookingUpWordsQ = false
			} else {
				foundWord = wordsDB.selectWords(forString:wordString)
			}
			if (foundWord != "") {
				wordArray.add(foundWord)
			}
			self.checkMatch()
		} else {
			word_score = 0
		}

		previousTouchedPoly = touchedPoly

		self.setMatchColor()
	}
	
	func showDynamicTimedModeEndAlert() {
		var message:String = ""
		var next_level_unlocked = false
		let this_level_completed = ((appController.polyhedronInfoArray?.object(at: Int(appController.level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
		if (score >= AppConstants.kScoreToObtainDynamic && !this_level_completed &&
			((appController.unlocked && appController.level < 35) ||
			(appController.upgraded && appController.level < 10) ||
				(appController.level < 5))) {
				next_level_unlocked = true
		}

		let buttons = NSArray(array:["Play Again", "Play Another Level", "Main Menu"])
			let type:Int = 6
		if (recordScore && !appController.level_aborted) {
			if (highScore == 0) {
				highScore = score
				message.append(contentsOf: "You established your high score for this level")
				if (next_level_unlocked) {
					message.append(contentsOf: " and unlocked the next level.\n\n\n\n\n")
				} else {
					message.append(contentsOf:".\n\n\n\n\n")
				}
			} else if (score > highScore) {
				highScore = score
				message.append(contentsOf: "Congratulations.  You beat your high score")
				if (next_level_unlocked) {
					message.append(contentsOf: " and unlocked the next level.\n\n\n\n\n")
				} else {
					message.append(contentsOf:".\n\n\n\n\n")
				}
			} else {
				message.append(contentsOf: "You failed to beat your high score.\n\n\n\n\n")
			}
		} else {
			message.append(contentsOf:"\n\n\n\n\n")
		}
		self.showPolyWordsViewAlertWithInfo(alertInfo: NSArray(array:[type, message, buttons]))
//		[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];

		self.stopClock()
		self.stopGameAnimation()
	}

	func showPolyWordsViewAlertWithInfo(alertInfo:NSArray = NSArray()) {
//		if (alertInfo != nil) {
//			let myActionSheet:MyActionSheet = MyActionSheet.initialize(withController:appController, withInformation:alertInfo, withCallingObject:self)
//			myActionSheet.showInView(self)
//			[myActionSheet release];
//		}
	}

	func setAnimation() {
		
	}

	@objc func oneSecondPulse() {
		
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
