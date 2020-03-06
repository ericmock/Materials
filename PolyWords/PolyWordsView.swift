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
	var pullDataController:PullDataController!
	var pushDataController:PushDataController!
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
	var availableWordScores:NSMutableArray!
	var wordsDB:Words!
	var previousTouchedPoly:Apolygon!
	var recordScore = false
	var highScore = 0
	var fastest_time = Float.infinity
	var animationInterval:TimeInterval = 0
	var finding_words = false
	var reset_counters = true
	var poly_counter = 0
	var num_words_avail = 0
	
	
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
		for poly in touchedPolygonsArray as! [Apolygon] {
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
			for poly in touchedPolygonsArray as! [Apolygon] {
				submittingPolygonsValuesArray.add(poly)
			}
			
			self.getNewLetters(forPolygons:polygonsToReplace)
			self.setAnimation()
		}
			// if not just deselect them
		else {
			submittingPolygonsValuesArray.removeAllObjects()
			for poly in touchedPolygonsArray as! [Apolygon] {
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
		for poly in polygons as! [Apolygon] {
			self.assignRandomLetterToPoly(number:poly.number)
		}
	}
	
	func assignRandomLetterToPoly(number ii:Int) {
		var rd:Int
		//		srandomdev();
		let poly = polyhedron.polygons.object(at:ii) as! Apolygon
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
	
	func set(touchedPolygon touchedPoly:Apolygon = Apolygon()) {
		
		// reset the match identifier
		match = false
		
		if !(touchedPoly.active) {
			for poly in touchedPolygonsArray as! [Apolygon] {
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
			for poly in touchedPolygonsArray as! [Apolygon] {
				poly.selected = false
			}
			let range = NSMakeRange(index, length)
			// remove the touched polygon and all those higher on the stack
			touchedPolygonsArray.removeObjects(in: range)// removeObjectsInRange:range];
			// reset the word string to contain only selected letters
			wordString = ""
			for poly in touchedPolygonsArray as! [Apolygon] {
				poly.selected = true
				wordString.append(poly.letter.lowercased())
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
				if (touchedPolygonsArray.lastObject as! Apolygon).indices.contains(num) {
					count += 1
				}
			}
			// if the polygon doesn't share at least two vertices with the previously touched polygon...
			if (count < 2 && touchedPolygonsArray.count > 0) {
				// ...reset touched flag for all previously touched polygons...
				for poly in touchedPolygonsArray as! [Apolygon] {
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
			for poly in touchedPolygonsArray as! [Apolygon] {
				wordString.append(poly.letter.lowercased())
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
				message.append("You established your high score for this level")
				if (next_level_unlocked) {
					message.append(" and unlocked the next level.\n\n\n\n\n")
				} else {
					message.append(".\n\n\n\n\n")
				}
			} else if (score > highScore) {
				highScore = score
				message.append("Congratulations.  You beat your high score")
				if (next_level_unlocked) {
					message.append(" and unlocked the next level.\n\n\n\n\n")
				} else {
					message.append(".\n\n\n\n\n")
				}
			} else {
				message.append("You failed to beat your high score.\n\n\n\n\n")
			}
		} else {
			message.append("\n\n\n\n\n")
		}
		self.showPolyWordsViewAlertWithInfo(alertInfo: NSArray(array:[type, message, buttons]))
		//		[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];
		
		self.stopClock()
		self.stopGameAnimation()
	}
	
	func showDynamicScoredModeEndAlert() {
		var message:String = ""
		let buttons = NSArray(array:["Play Again", "Play Another Level", "Main Menu"])
		let type:Int = 6
		var next_level_unlocked = false
		let this_level_completed = ((appController.polyhedronInfoArray?.object(at: Int(appController.level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
		if (playTime <= AppConstants.kTimeToCompleteDynamic && !this_level_completed &&
			((appController.unlocked && appController.level < 35) ||
				(appController.upgraded && appController.level < 10) ||
				(appController.level < 5))) {
			next_level_unlocked = true
		}
		
		if (recordScore && !appController.level_aborted) {
			if (fastest_time == Float.infinity) {
				fastest_time = playTime
				message.append("You established your fastest time for this level")
				if (next_level_unlocked) {
					message.append(" and unlocked the next level.\n\n\n\n\n")
				} else {
					message.append(".\n\n\n\n\n")
				}
			} else if (playTime < fastest_time) {
				fastest_time = playTime
				message.append("Congratulations.  You beat your fastest time")
				if (next_level_unlocked) {
					message.append(" and unlocked the next level.\n\n\n\n\n")
				} else {
					message.append(".\n\n\n\n\n")
				}
			} else {
				message.append("You failed to beat your fastest time.\n\n\n\n\n")
			}
		} else {
			message.append("\n\n\n\n\n")
		}
		self.showPolyWordsViewAlertWithInfo(alertInfo: NSArray(array:[type, message, buttons]))
		
		self.stopClock()
		self.stopGameAnimation()
	}
	
	func showStaticTimedModeEndAlert() {
		var message = ""
		let buttons = NSMutableArray(array:["View Word List", "Play Again", "Play Another Level", "Main Menu"])
		var type:Int
		var next_level_unlocked = false
		let this_level_completed = ((appController.polyhedronInfoArray?.object(at: Int(appController.level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
		if (score >= AppConstants.kScoreToObtainStatic && !this_level_completed &&
			((appController.unlocked && appController.level < 35) ||
				(appController.upgraded && appController.level < 10) ||
				(appController.level < 5))) {
			next_level_unlocked = true
		}
		if (recordScore && !appController.level_aborted) {
			if (highScore == 0) {
				highScore = score
				message.append("You established your high score for this level")
				if availableWords.count > 0 {
					type = 8
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
					} else {
						message.append(".\n\n\n\n\n")
					}
				} else {
					type = 3
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					} else {
						message.append(".\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					}
				}
			} else if (score > highScore) {
				highScore = score
				message.append("Congratulations.  You beat your high score")
				if availableWords.count > 0 {
					type = 8
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
					} else {
						message.append(".\n\n\n\n\n")
					}
				} else {
					type = 3
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					} else {
						message.append(".\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					}
				}
			} else {
				message.append("You failed to beat your high score.\n\n\n\n\n")
				if availableWords.count > 0 {
					type = 8
				} else {
					type = 3
					buttons.replaceObject(at: 0, with:"Find Missed Words")
				}
			}
		} else {
			message.append("\n\n\n\n\n")
			if availableWords.count > 0 {
				type = 8
			} else {
				type = 3
				buttons.replaceObject(at: 0, with:"Find Missed Words")
			}
		}
		self.showPolyWordsViewAlertWithInfo(alertInfo: NSArray(array:[type, message, buttons]))
		self.stopClock()
		self.stopGameAnimation()
	}
	
	func showStaticScoredModeEndAlert() {
		var message = ""
		let buttons = NSMutableArray(array:["View Word List", "Play Again", "Play Another Level", "Main Menu"])
		var type:Int
		var next_level_unlocked = false
		let this_level_completed = ((appController.polyhedronInfoArray?.object(at: Int(appController.level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
		if (playTime <= AppConstants.kTimeToCompleteStatic && !this_level_completed &&
			((appController.unlocked && appController.level < 35) ||
				(appController.upgraded && appController.level < 10) ||
				(appController.level < 5))) {
			next_level_unlocked = true
		}
		if (recordScore && !appController.level_aborted) {
			if (fastest_time == Float.infinity) {
				fastest_time = playTime
				message.append("You established your fastest time for this level")
				if availableWords.count > 0 {
					type = 8
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
					} else {
						message.append(".\n\n\n\n\n")
					}
				} else {
					type = 3
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					} else {
						message.append(".\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					}
				}
			} else if (fastest_time > playTime) {
				fastest_time = playTime
				message.append("Congratulations.  You beat your fastest time")
				if availableWords.count > 0 {
					type = 8
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
					} else {
						message.append(".\n\n\n\n\n")
					}
				} else {
					type = 3
					if (next_level_unlocked) {
						message.append(" and unlocked the next level.\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					} else {
						message.append(".\n\n\n\n\n")
						buttons.replaceObject(at: 0, with:"Find Missed Words")
					}
				}
			} else {
				message.append("You failed to beat your fastest time.\n\n\n\n\n")
				if availableWords.count > 0 {
					type = 8
				} else {
					type = 3
					buttons.replaceObject(at: 0, with:"Find Missed Words")
				}
			}
		} else {
			message.append("\n\n\n\n\n")
			if availableWords.count > 0 {
				type = 8
			} else {
				type = 3
				buttons.replaceObject(at: 0, with:"Find Missed Words")
			}
		}
		self.showPolyWordsViewAlertWithInfo(alertInfo: NSArray(array:[type, message, buttons]))
		self.stopClock()
		self.stopGameAnimation()
	}

	func showTwoPlayerModeEndAlert() {
		var message = ""
		let buttons = NSMutableArray(array:["View Word List", "Play Again", "Play Another Level", "Main Menu"])
		var type:Int
		if (recordScore) {
			if (score > opponent_score) {
				message.append("Congratulations.  You beat your opponent.\n\n\n\n\n")
				if availableWords.count > 0 {
					type = 10
				} else {
					type = 11
					buttons.replaceObject(at: 0, with:"Find Missed Words")
				}
			} else if (score < opponent_score) {
				message.append("Your opponent won that game.\n\n\n\n\n")
				if availableWords.count > 0 {
					type = 10
				} else {
					type = 11
				}
			} else {
				message.append("You tied!\n\n\n\n\n")
				if availableWords.count > 0 {
					type = 10
				} else {
					type = 11
					buttons.replaceObject(at: 0, with:"Find Missed Words")
				}
			}
		} else {
			message.append("\n\n\n\n\n")
			if availableWords.count > 0 {
				type = 10
			} else {
				type = 11
				buttons.replaceObject(at: 0, with:"Find Missed Words")
			}
		}
		self.showPolyWordsViewAlertWithInfo(alertInfo: NSArray(array:[type, message, buttons]))
		self.stopClock()
		self.stopGameAnimation()
	}
	
	func abortLevel() {
		score = 0
		timeHistory.removeAllObjects()
		word_score = 0
		points_avail = 0
		points_avail_display = 0
		NSArray(array:[]).write(toFile: appController.getDynamicScoredSavePath(), atomically:true)
		appController.level_aborted = true
		self.startGameAnimation()
	}
	
	func checkLevelCompleted() {
		appController.level_completed = false
		var level_unlock = false
		var recorded_score = AppConstants.kScoreToObtainDynamic
		var recorded_time = AppConstants.kTimeToCompleteDynamic
		if appController.mode == AppConstants.kDynamicTimedMode {
			if (playTime.rounded(.towardZero) >= AppConstants.kTimeToCompleteDynamic || appController.level_aborted) {
				if (score >= AppConstants.kScoreToObtainDynamic) {
					level_unlock = true
				}
				if (!appController.level_aborted) {
					appController.level_completed = true
				}
				appController.removeAllStoredData()
				self.showDynamicTimedModeEndAlert()
				recorded_time = AppConstants.kTimeToCompleteDynamic
				recorded_score = UInt(score)
			}
		}	else if (appController.mode == AppConstants.kStaticTimedMode) {
			if (playTime.rounded(.towardZero) >= AppConstants.kTimeToCompleteStatic || appController.level_aborted) {
				if (score >= AppConstants.kScoreToObtainStatic) {
					level_unlock = true
				}
				if (!appController.level_aborted) {
					appController.level_completed = true
				}
				appController.removeAllStoredData()
				self.showStaticTimedModeEndAlert()
				recorded_time = AppConstants.kTimeToCompleteStatic
				recorded_score = UInt(score)
			}
		}	else if (appController.mode == AppConstants.kDynamicScoredMode) {
			if (playTime >= AppConstants.kTimeToCompleteStatic || appController.level_aborted) {
				if (score >= AppConstants.kScoreToObtainStatic) {
					level_unlock = true
				}
				if (!appController.level_aborted) {
					appController.level_completed = true
				}
				appController.removeAllStoredData()
				self.showDynamicScoredModeEndAlert()
				recorded_time = playTime
				recorded_score = AppConstants.kScoreToObtainDynamic
			}
		} else if (appController.mode == AppConstants.kStaticScoredMode) {
			if (score >= AppConstants.kScoreToObtainStatic || appController.level_aborted) {
				if (playTime <= AppConstants.kTimeToCompleteStatic) {
					level_unlock = true
				}
				if (!appController.level_aborted) {
					appController.level_completed = true
				}
				appController.removeAllStoredData()
				self.showStaticScoredModeEndAlert()
				recorded_time = playTime
				recorded_score = AppConstants.kScoreToObtainStatic
			}
		}
		else if (appController.mode == AppConstants.kTwoPlayerClientMode || appController.mode == AppConstants.kTwoPlayerServerMode) {
			if (playTime.rounded(.towardZero) >= AppConstants.kTimeToCompleteStatic || appController.level_aborted) {
				appController.removeAllStoredData()
				pullDataController.session.finishTasksAndInvalidate()
				pushDataController.connection.finishTasksAndInvalidate()
				self.showTwoPlayerModeEndAlert()
				opponent_ready = false
			}
		}

		if (recordScore && appController.level_completed) {
			appController.highScores.addScoreForPolyhedron(ofType: polyhedron.polyInfo.object(forKey: "polyID") as! Int, forMode: appController!.mode, forTime: recorded_time, withScore: Int(recorded_score))
			recordScore = false
			opponent_ready = false
			if (appController.send_data_q) {
				let postController = PostScoreController()
				postController.startSend(NSArray(array: [score, playTime, appController.level, UInt(appController.mode), wordsFound as NSArray, wordScores as NSArray, wordScores as NSArray]))
			}
		}

		if (appController.level_completed) {
			self.stopClock()
			if (level_unlock) {
				let dict:NSMutableDictionary = (appController.polyhedronInfoArray!.object(at:(Int(appController.level - 1))) as! NSDictionary).mutableCopy() as! NSMutableDictionary
				let array2:NSMutableArray = (dict.object(forKey:"completed") as! NSArray).mutableCopy() as! NSMutableArray
				array2.replaceObject(at: Int(appController!.mode), with: Bool(true))
				dict.setValue(array2, forKey: "completed")
				appController.polyhedronInfoArray?.replaceObject(at: Int(appController.level - 1), with: dict)
			}
		}
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
	
	@objc func drawView() {
		
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
	
	@objc func startGameAnimation() {
		var message = ""
		if (gameAnimationTimer.isValid) {
			gameAnimationTimer.invalidate()
			gameAnimationTimer = Timer()
		}

		let game_state = appController.polyWordsViewController.game_state
		if (points_avail < 3000 && appController.mode == AppConstants.kStaticScoredMode && !appController.level_aborted && game_state != AppConstants.kGameContinue) {
			let alert = NSPanel.init()
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reshuffle Letters" message:[NSString stringWithFormat:@"Only %i points are available with these letters.",points_avail]
//															 delegate:self cancelButtonTitle:@"Shuffle" otherButtonTitles:nil];
//			alert.tag = 1
			alert.makeKeyAndOrderFront(nil)
		} else if ((game_state == AppConstants.kGameStart || game_state == AppConstants.kGameRestart) && show_get_ready && appController.mode != AppConstants.kTwoPlayerClientMode && appController.mode != AppConstants.kTwoPlayerServerMode) {
			gameAnimationTimer = Timer(timeInterval:animationInterval, target: self, selector: #selector(drawView), userInfo: nil, repeats: true)
			if appController.mode == AppConstants.kDynamicTimedMode {
				message = "Score as many points as you can in \(AppConstants.kTimeToCompleteDynamic) seconds.  Don't forget you can throw back letters.\n\n\n\n\n\n"
			} else if (appController.mode == AppConstants.kStaticTimedMode) {
				message = "Score as many points as you can in \(AppConstants.kTimeToCompleteStatic) seconds.  Don't forget you can throw back letters.\n\n\n\n\n\n"
			} else if (appController.mode == AppConstants.kDynamicScoredMode) {
				message = "Score \(AppConstants.kScoreToObtainDynamic) points as fast as you can.  Don't forget you can throw back letters.\n\n\n\n\n\n"
			} else if (appController.mode == AppConstants.kStaticScoredMode) {
				message = "Score \(AppConstants.kScoreToObtainStatic) points as fast as you can.\n\n\n\n\n\n"
			}
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Ready" message:message
//															 delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//			alert.tag = 3;
			var rect:CGRect
			if (appController.mode == AppConstants.kDynamicTimedMode || appController.mode == AppConstants.kDynamicScoredMode) {
				rect = CGRect(x: 16,y: 100,width: 252,height: 115);
			} else {
				rect = CGRect(x: 16,y: 80,width: 252,height: 115);
			}
//			UILabel *label1 = [[UILabel alloc] initWithFrame:rect];
//			label1.text = @"Remember letters must share an edge to form words.";
//			label1.numberOfLines = 3;
//			label1.adjustsFontSizeToFitWidth = YES;
//			label1.backgroundColor = [UIColor clearColor];
//			label1.font = [UIFont boldSystemFontOfSize:20.0];
//			label1.textColor = [UIColor whiteColor];
//			label1.textAlignment = UITextAlignmentCenter;
//			label1.shadowColor = [UIColor blackColor];
//			label1.shadowOffset = CGSizeMake(2.0,2.0);
//			[alert addSubview:label1];
//
//			[alert show];
			show_get_ready = true
		} else if (show_get_ready && opponent_ready) {
			gameAnimationTimer = Timer(timeInterval:animationInterval, target: self, selector: #selector(drawView), userInfo: nil, repeats: true)
//			[waitingAlert dismissWithClickedButtonIndex:2 animated:NO];
			message = ""
//
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Ready\n\n\n\n\n\n" message:message
//															 delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
//			UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16,50,252,25)];
//			label1.text = @"Game will start in";
//			label1.adjustsFontSizeToFitWidth = YES;
//			label1.backgroundColor = [UIColor clearColor];
//			label1.font = [UIFont systemFontOfSize:18.0];
//			label1.textColor = [UIColor whiteColor];
//			label1.textAlignment = UITextAlignmentCenter;
//			label1.shadowColor = [UIColor blackColor];
//			label1.shadowOffset = CGSizeMake(2.0,2.0);
//			[alert addSubview:label1];
//			UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(16,175,252,25)];
//			label2.text = @"seconds.";
//			label2.adjustsFontSizeToFitWidth = YES;
//			label2.backgroundColor = [UIColor clearColor];
//			label2.font = [UIFont systemFontOfSize:18.0];
//			label2.textColor = [UIColor whiteColor];
//			label2.textAlignment = UITextAlignmentCenter;
//			label2.shadowColor = [UIColor blackColor];
//			label2.shadowOffset = CGSizeMake(2.0,2.0);
//			[alert addSubview:label2];
//			UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(16,90,252,75)];
//			label3.text = @"3";
//			label3.adjustsFontSizeToFitWidth = YES;
//			label3.backgroundColor = [UIColor clearColor];
//			label3.font = [UIFont systemFontOfSize:72.0];
//			label3.textColor = [UIColor whiteColor];
//			label3.textAlignment = UITextAlignmentCenter;
//			label3.shadowColor = [UIColor blackColor];
//			label3.shadowOffset = CGSizeMake(2.0,2.0);
//			label3.tag = 101;
//			[alert addSubview:label3];
//			[alert show];
			show_get_ready = true
//			[self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];
//			alert.tag = 6;
		}
		else {
			gameAnimationTimer = Timer(timeInterval:animationInterval, target: self, selector: #selector(drawView), userInfo: nil, repeats: true)
			if (!appController.level_completed) {
				self.startClock()
			}
		}
	//	[self checkLevelCompleted];
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
	
	func wordsFound(withLength length:Int) -> NSArray {
		let words = NSMutableArray()
		for word in wordsFound as! [String] {
			if word.count == length {
				words.add(word)
			}
		}
		return words as NSArray
	}
	
	func findAllWords() {
		self.findWords(toPoints:Int.max)
	}
	
	func findWords(toPoints points:Int) {
		finding_words = true
		reset_counters = true
		poly_counter = 0
		points_avail = 0
		num_words_avail = 0
		let to_points = points
		
		for poly in polyhedron.polygons as! [Apolygon] {
			if poly.active && points_avail < to_points {
				self.findWordsStarting(withPolygon: poly)
				poly_counter += 1
			}
		}
		
		if points == Int.max {
			for poly in polyhedron.polygons as! [Apolygon] {
				poly.connections = nil
			}
		}
		
		if points == Int.max {
			wordsDB.finalizeStatements()
			self.sortAvailableWords()
		} else {
			availableWords.removeAllObjects()
			availableWordScores.removeAllObjects()
		}
		
		finding_words = false
		self.performSelector(onMainThread: #selector(stopTransitionAnimation), with: nil, waitUntilDone: false)
		if !appController.level_completed && !appController.level_aborted {
			self.performSelector(onMainThread: #selector(startGameAnimation), with: nil, waitUntilDone: false)
		} else {
			self.performSelector(onMainThread: #selector(checkLevelComplete), with: nil, waitUntilDone: false)
		}
	}
	
	
	
	func findWordsStarting(withPolygon poly:Apolygon) {
		//TODO:  don't need to return an array with the actual words
		let localWordsArray = wordsDB.findWordsStarting(withPolygon: poly)
		let chainsFoundArray = localWordsArray.object(at:1)
		for chain in chainsFoundArray as! [[Apolygon]] {
			var word = ""
			for poly in chain {
				word.append(poly.letter.lowercased())
			}
			if !availableWords.contains(word) {
				availableWords.add(word)
				num_words_avail = availableWords.count
				let num = self.getScore(forChain: chain)
				points_avail += Int(num)
				points_avail_display = (points_avail < 100000) ? points_avail : 1000
				availableWordScores.add(self.getScore(forChain: chain))
			}
		}
	}
	
	func getScore(forChain chain:[Apolygon]) -> Int {
		return 0
	}
	
	func sortAvailableWords() {
		var cont = true
		var tempString:String
		var tempNum:Int
		
		while cont {
			cont = false
			if availableWords.count > 0 {
				for ii in 0..<(availableWords.count - 1) {
					let length1 = (availableWords.object(at: ii) as! String).count
					let length2 = (availableWords.object(at: ii+1) as! String).count
					if length1 < length2 {
						tempString = availableWords.object(at:ii) as! String
						tempNum = availableWordScores.object(at:ii) as! Int
						availableWords.replaceObject(at: ii, with: availableWords.object(at: ii+1))
						availableWords.replaceObject(at: ii+1, with: tempString)
						availableWordScores.replaceObject(at: ii, with: availableWordScores.object(at: ii+1))
						availableWordScores.replaceObject(at: ii+1, with: tempNum)
						cont = true
					}
				}
			}
		}
		num_words_avail = availableWords.count
	}
	
	@objc func stopTransitionAnimation() {
		
	}
	
	@objc func checkLevelComplete() {
		
	}
}
