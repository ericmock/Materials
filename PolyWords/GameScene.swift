//
//  GameScene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import CoreGraphics
#if !os(iOS)
import Cocoa
#endif

class GameScene: Scene {
	var wordsDB:Words!
	var previousTouchedPoly:Apolygon!
	var last_submit_time:Float = 0.0
	var playTime:Float = 0.0
	var submittingPolygonsValues:[Any] = []
	var touchedPolygons:[Apolygon] = []
	var score:Int = 0
	var word_score:Int = 0
	var match:Bool = false
	var wordString = ""
	var wordsFound:[String] = []
	var wordsFoundOpponent:[String] = []
	var wordScores:[Int] = []
	var num_words_found:Int = 0
	var score_animating = false
	var dynamicWordsFoundFileHandle:FileHandle!
	var staticWordsFoundFileHandle:FileHandle!
	var match_red:Float = 1.0
	var match_green:Float = 1.0
	var match_blue:Float = 1.0
	var highScore = 0
	var recordScore = false
	var availableWords:[String] = []
	var availableWordScores:[Int] = []
	var gameAnimationTimer:Timer!
	var oldWordsFound:[String] = []
	var pullDataController:PullDataController!
	var pushDataController:PushDataController!
	var fastest_time = Float.infinity
	var opponent_score:Int = 0
	var timeHistory:[Any] = []
	var points_avail:Int = 0
	var points_avail_display:Int = 0
	var words:[String] = []
	var opponent_ready = false
	var clock = Timer()
	var paused = true
	var prev_time = Date()
	var show_opponent_word = false
	var opponentWordsToDisplay:[String] = []
	var wordScoresOpponent:[Int] = []
	var finding_words = false
	var reset_counters = true
	var poly_counter = 0
	var num_words_avail = 0
	var timeLeft:Float = 0
	var touchAngles:[Float] = []
	var touchTimes:[Float] = []
	var freeWheeling = false
	var recordTimeQ = false
	var zoomFactor = 1
	var touchedLetterView:NSTextField!
	var reds = Array(repeating: CGFloat(), count: 4)
	var greens = Array(repeating: CGFloat(), count: 4)
	var blues = Array(repeating: CGFloat(), count: 4)
	var select_red = 0.0
	var select_green = 0.0
	var select_blue = 0.0
	var num_colors = 1
	var differentPolygonTypes = 0
	var show_get_ready = false
	var lastSubmitTime:Float = 0.0
	var mode = 0
	var unlocked = false
	var upgraded = false
	var level = 1
	var level_aborted = false
	var game_id = 0
	var level_completed = false
	var letterString = ""

	var polyhedron = Polyhedron(name: "TestPolyhedron", withPolyID: 12)
	
	override init(screenSize: CGSize, sceneName: String) {
		super.init(screenSize: screenSize, sceneName: sceneName)
		gTrackBallRotation[1] = 1.0
		worldRotation[1] = 1.0
	}
	
	func endSpin() {
		
	}

	func setWorldRotation(angle:Float, X:Float, Y:Float, Z:Float) {
		
	}
	
	func setRotation(angle:Float, X:Float, Y:Float, Z:Float) {
		
	}
	
	override func setupScene() {
		camera.target = [0, 0.8, 0]
		camera.distance = 3
		camera.rotation = [-0.4,-0.4,0]
		
		add(node: polyhedron)
		
		polyhedron.rotation.y = radians(fromDegrees: Float.random(in: -180..<180))
	}
	
	@objc override func checkDrag(timer: Timer) {
		checked = true;
		if (!dragging || (hypot(currentTouchPosition.x - initialTouchPosition.x,currentTouchPosition.y - initialTouchPosition.y) < 5)) {
			inputMode = .select; // if dragging hasn't started yet, we're selecting
		} else {
			inputMode = .rotate
		}
		
		if (inputMode == .select) {
			oldText = touchedLetters;
			touchedNumber = findTouchedPolygon(atPoint: initialTouchPosition);
			let polyCount: Int = thePolyhedron.polygons.count;
			if (previouslyTouchedNumber >= 0 && previouslyTouchedNumber < polyCount) {
				//				let poly:Polygons = thePolyhedron.polygons[previouslyTouchedNumber]
				//                Polygons *poly = [polyhedron.polygons objectAtIndex:prev_touched_num];
				//				poly.touched = false;
			}
			if (touchedNumber >= 0 && previouslyTouchedNumber < polyCount) {
				//				let poly:Polygons = thePolyhedron.polygons[previouslyTouchedNumber]
				//                Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
				//				poly.touched = true;
				//				touchedLetters = oldText + alphabetArray[(poly.textureNumber)%26].lowercased()
				previouslyTouchedNumber = touchedNumber
			}
		}
	}
	
	override func findTouchedPolygon(atPoint touchPos: CGPoint) -> Int {
		var touchPosition:SIMD2<Float> = [0]
		touchPosition.x = Float(touchPos.x)
		touchPosition.y = Float(touchPos.y)
		var vec:SIMD4<Float> = [0]
		var vec1:SIMD4<Float> = [0]
		var vec3:SIMD4<Float> = [0]
		let transform_matrix:float4x4 = float4x4(0)//, touch[3] = {0.0, 0.0, -6.0};
		let vp:SIMD4<Int32> = [0]
		var winX:Float = 0
		var winY:Float = 0
		//         var winZ: Float
		//        var ii: Int = 0
		//        var jj: Int = 0
		var touchedNumber:Int = 0
		
		touchPosition.y = 480.0 - touchPosition.y
		
		var closePolygons:[Apolygon] = []
		var centroidZs:[Float] = [0]
		var faceNumbers:[Int] = [0]
		
		vec[3] = 1.0
		
		// TODO
		//        glGetIntegerv(GL_VIEWPORT, vp);
		//        matrixMatrixMultiply(delegate.projectionMatrix, modelViewMatrix, transform_matrix);
		
		var counter = 0
		for ll in 0..<10 {
			for ii in 0..<thePolyhedron.numberOfFacesOfPolygonType[ll] {
				var minX: Float = Float(MAXFLOAT)
				var maxX: Float = -Float(MAXFLOAT)
				var minY: Float = Float(MAXFLOAT)
				var maxY: Float = -Float(MAXFLOAT)
				for kk in 0..<(3+ll) {
					for jj in 0..<3 {
						//						vec[jj] = thePolyhedron.polyVertices[ll][(3 + ll) * 3 * ii + 3 * kk + jj];
					}
					
					vec3 = transform_matrix * SIMD4<Float>(vec)
					
					vec3[0]/=vec3[3];
					vec3[1]/=vec3[3];
					vec3[2]/=vec3[3];
					
					winX = Float(vp[0]) + Float(vp[2]) * (vec3[0] + 1.0) / 2.0
					winY = Float(vp[1]) + Float(vp[3]) * (vec3[1] + 1.0) / 2.0
					//                     winZ = (vec3[2] + 1.0) / 2.0
					
					if (winX > maxX) {maxX = Float(winX)}
					if (winX < minX) {minX = Float(winX)}
					if (winY > maxY) {maxY = Float(winY)}
					if (winY < minY) {minY = Float(winY)}
				}
				
				if (touchPosition.x < maxX && touchPosition.x > minX && touchPosition.y < maxY && touchPosition.y > minY) {
					//					closePolygons.append(thePolyhedron.polygons[counter])
					faceNumbers.append(ii)
				}
				counter += 1
			}
		}
		
		var centroidZmax:Float = -100;//, temp[4] = {0.0, 0.0, 0.0, 1.0}, vec2[4] = {0.0, 0.0, 0.0, 1.0};
		//         var touched_num = -1
		//         var base_vertex_index = 0;
		counter = 0;
		let copyOfClosePolygons = closePolygons;
		for poly in copyOfClosePolygons {
			let polyType: Int = poly.type
			var deformedVertexX = [Float](repeating: 0, count: polyType + 3)
			var deformedVertexY = [Float](repeating: 0, count: polyType + 3)
			for nn in 0..<(polyType + 3) {
				let tmp: Int = 3 * (3 + polyType)
				let faceNumber: Int = Int(faceNumbers[counter])
				let base_vertex_index: Int = tmp * faceNumber + 3 * Int(nn)
				for kk in 0..<3 {
					
					//					vec[kk] = thePolyhedron.polyVertices[polyType][base_vertex_index + kk]
					//                    poly_vertices_ptr[polyType!][base_vertex_index + kk];
					//            float temp2[4];
					//            matrixMultiply(modelViewMatrix, vec, vec1);
					//            matrixMultiply(delegate.projectionMatrix, vec1, vec3);
					vec3 = transform_matrix * vec
					vec3[0]/=vec3[3]
					vec3[1]/=vec3[3]
					vec3[2]/=vec3[3]
					winX = Float(vp[0]) + Float(vp[2]) * (vec3[0] + 1.0) / 2.0
					winY = Float(vp[1]) + Float(vp[3]) * (vec3[1] + 1.0) / 2.0
					//                     winZ = (vec3[2] + 1.0) / 2.0;
					deformedVertexX[nn] = winX;
					deformedVertexY[nn] = winY;
					//            NSLog(@"deformed_vertex_coords[%i] = (%2.3f, %2.3f)", nn, deformed_vertex_coords_x[nn], deformed_vertex_coords_y[nn]);
					
					let inside: Bool = pointInPolygon(withNumberOfPoints: polyType + 3, withXPoints: deformedVertexX, withYPoints: deformedVertexY, withX: touchPosition.x, withY: touchPosition.y);
					
					//            NSLog(@"letter = %@, inside = %i",[delegate.alphabetArray objectAtIndex:poly.texture], inside);
					if (!inside || !poly.active) {
						if let idx = closePolygons.firstIndex(where: { $0 === poly }) {
							closePolygons.remove(at: idx)
						}
					} else {
						let centroid: SIMD3<Float> = poly.centroid
						//                        vec[0] = [[centroid objectAtIndex:0] floatValue];
						vec[0] = centroid.x
						vec[1] = centroid.y
						vec[2] = centroid.z
						vec[3] = 1.0
						vec1 = uniforms.modelMatrix * vec
						//                        vec[1] = [[centroid objectAtIndex:1] floatValue];
						//                        vec[2] = [[centroid objectAtIndex:2] floatValue];
						//                        vec[3] = 1.0;
						//                        matrixMultiply(modelViewMatrix, vec, vec1);
						//            NSLog(@"centroid.z = %2.3f", vec1[2]);
						centroidZs.append(vec1[2])//[centroidsArray addObject:[NSNumber numberWithFloat:vec1[2]]];
					}
					counter += 1
				}
				counter = 0;
				for poly in closePolygons {
					let centroidZ = centroidZs[counter]//[[centroidsArray objectAtIndex:counter] floatValue];
					if (centroidZ > centroidZmax) {
						centroidZmax = centroidZ;
						touchedNumber = poly.number;
					}
					counter += 1;
				}
				
			}
		}
		return touchedNumber
	}
	
	func setAnimation() {
		
	}
	
	func submitWord() {
		last_submit_time = playTime
		
		self.getWordScore()
		// if we in dynamic letter mode, replace the submitted letters
		if (mode == AppConstants.kDynamicTimedMode || mode == AppConstants.kDynamicScoredMode) {
			let polygonsToReplace = NSArray(array: touchedPolygons)
			submittingPolygonsValues.removeAll()
			for poly in touchedPolygons {
				submittingPolygonsValues.append(poly)
			}
			
			self.getNewLetters(forPolygons:polygonsToReplace)
			self.setAnimation()
		}
			// if not just deselect them
		else {
			submittingPolygonsValues.removeAll()
			for poly in touchedPolygons {
				submittingPolygonsValues.append(poly)
			}
		}
		
		score += word_score;
		//	score_display = (score < 0)?0:score;
		
		if (match) {
			//			swipeSound.play()
			let wordStringCopy = wordString.copy()
			wordsFound.append(wordStringCopy as! String)
			wordScores.append(Int(word_score))
			if mode == AppConstants.kTwoPlayerClientMode || mode == AppConstants.kTwoPlayerServerMode {
				self.pushData()
				num_words_found = wordsFound.count
				match = false
				score_animating = true
				if mode == AppConstants.kDynamicTimedMode || mode == AppConstants.kDynamicScoredMode {
					let polyInfoString = polyhedron.polyInfo.object(forKey:"polyID") as! String
					let wordScoreString = String(word_score)
					let wordsFoundString = wordString + "," + wordScoreString + "," + polyInfoString
					dynamicWordsFoundFileHandle.write(wordsFoundString.data(using:.utf8)!)
				}
			} else if mode == AppConstants.kStaticTimedMode || mode == AppConstants.kStaticScoredMode {
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
	
	func resetMatchColor() {
		match_red = 1.0
		match_green = 1.0
		match_blue = 1.0
	}
	
	func getNewLetters(forPolygons polygons:NSArray) {
		for poly in polygons as! [Apolygon] {
			self.assignRandomLetterToPoly(number:poly.number)
		}
	}
	
	func assignLetterToAllPolygons(withString string:String) {
		var counter = 0
		for polygonType in polyhedron.polygons {
			for polygon in polygonType {
				let index = string.index(string.startIndex, offsetBy: counter)
				polygon.letter = String(string[index])
				counter = counter + 1
			}
		}
	}
	
	func assignLetterToAllPolygons() {
		if mode != AppConstants.kTwoPlayerClientMode {
			var counter = 0
			for polygonType in polyhedron.polygons {
				for _ in polygonType {
					assignRandomLetterToPoly(number: counter)
					counter += 1
				}
			}
		}
		else {
			assignLetterToAllPolygons(withString: letterString)
		}
	}
	
	func assignLetter(toPolygon polyNumber:Int, ofType type:Int, withNumber num:Int) {
		polyhedron.polygons[type][polyNumber].texture = num
		polyhedron.polygons[type][polyNumber].letter = AppConstants.kAlphabet[num]
	}
	
	func assignRandomLetterToPoly(number ii:Int) {
		var rd:Int
		//		srandomdev();
		let poly = Array(polyhedron.polygons.joined())[ii]
		var g = SystemRandomNumberGenerator()
		if (poly.active) {
			rd = Int.random(in: 0...(AppConstants.kAlphabet.count - 1), using: &g);
			if uncommonLettersArray.contains(AppConstants.kAlphabet[rd]) {
				rd = Int.random(in: 0...(AppConstants.kAlphabet.count - 1), using: &g);
			} else if !uncommonLettersArray.contains(AppConstants.kAlphabet[rd]) {
				rd = Int.random(in: 0...(AppConstants.kAlphabet.count - 1), using: &g);
			}
			//	rd=ii+1;// for numbers
			poly.texture = rd % 180
			poly.letter = AppConstants.kAlphabet[rd % AppConstants.kAlphabet.count]
		} else {
			poly.texture = 26
			poly.letter = "-";
		}
	}
	
	func getWordScore() {
		//		var letter_score:Float = 0.0
		var base_word_score:Float = 0.0
		submittingPolygonsValues.removeAll()
		for poly in touchedPolygons {
			let letter_num = AppConstants.kAlphabet.firstIndex(of: poly.letter)!
			let polygon_type = poly.type
			var num_sides = polygon_type! + 3;
			if (polygon_type == 10 || polygon_type == 11 || polygon_type == 12) {
				num_sides = 4
			} else if (polygon_type == 13 || polygon_type == 14 || polygon_type == 15) {
				num_sides = 3
			}
			let factor1:Float = -1.0*pow(-1,match ? 1.0 : 0.0)
			let factor2:Float = (12.0 - Float(num_sides))
			let factor3:Float = Float(AppConstants.kLetterValues[letter_num]) * (match ? Float(wordString.count) : 1.0)
			let letter_score = factor1 * factor2 * factor3
			base_word_score += letter_score
			submittingPolygonsValues.append(Int(letter_score))
		}
		
		//		let word_length = wordString.count
		var word_score = base_word_score;//-1.0*pow(-1,(float)match)*letter_score * (match?[wordString length]:1.0);
		
		if ((mode != AppConstants.kDynamicTimedMode && mode != AppConstants.kDynamicScoredMode) && word_score < 0) {
			word_score = 0
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
	
	// TODO: Make Apolygon conform to equatable
	func set(touchedPolygon touchedPoly:Apolygon) {
		
		// reset the match identifier
		match = false
		
		if !(touchedPoly.active) {
			for poly in touchedPolygons {
				poly.selected = false
			}
			touchedPolygons.removeAll()
			
			wordString = ""
			self.getWordScore()
			return
		}
		
		touchedPoly.selected = true
		
		// check to see if it is already selected
		//		if (touchedPolygons.contains(touchedPoly)) {
		if (true) {
			// if it's already selected grab the index number and length of the range to remove from the selected array
			//			let index = touchedPolygons.index(of: touchedPoly)
			let index = 0
			let length = touchedPolygons.count - index
			// reset the touched flag of all the previously touched polygons
			for poly in touchedPolygons {
				poly.selected = false
			}
			//			let range = NSMakeRange(index, length)
			// remove the touched polygon and all those higher on the stack
			touchedPolygons.removeSubrange(index..<index+length)// removeObjectsInRange:range];
			// reset the word string to contain only selected letters
			wordString = ""
			for poly in touchedPolygons {
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
			for num in touchedPoly.indices {
				if (touchedPolygons.last?.indices.contains(num))! {
					count += 1
				}
			}
			// if the polygon doesn't share at least two vertices with the previously touched polygon...
			if (count < 2 && touchedPolygons.count > 0) {
				// ...reset touched flag for all previously touched polygons...
				for poly in touchedPolygons {
					poly.selected = false
				}
				// ...clear the array of selected polygons...
				touchedPolygons.removeAll()
				// ...and set the touched flag and add the touched polygon to the array.
				touchedPoly.selected = true
				touchedPolygons.append(touchedPoly)
			} else {
				touchedPolygons.append(touchedPoly)
			}
			// update the word string
			wordString = ""
			for poly in touchedPolygons {
				wordString.append(poly.letter.lowercased())
			}
		}
		
		// if there are three letters selected, use the other thread to grab all the words that start with those three letters
		if wordString.count >= 3 {
			self.lookingUpWordsQ = true
			var foundWord = ""
			words.removeAll()
			if (availableWords.count == 0) {
				if (availableWords.contains(wordString)) {
					foundWord = wordString
				}
				lookingUpWordsQ = false
			} else {
				foundWord = wordsDB.selectWords(forString:wordString)
			}
			if (foundWord != "") {
				words.append(foundWord)
			}
			self.checkMatch()
		} else {
			word_score = 0
		}
		
		previousTouchedPoly = touchedPoly
		
		self.setMatchColor()
	}
	
	func pause() {
		//		// FIXME:  crashing on the following line after a few pauses
		//Move to new NSView class		let pauseAlert = PauseAlert.init(withView:self)
		//Move to new NSView class		self.addSubview(pauseAlert)// pauseAlert.superview(self) //showInView:self];
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
		//		polyWordsViewController.game_state = AppConstants.kGameContinue
		
		//		[[NSRunLoop currentRunLoop] addTimer:clock forMode:NSDefaultRunLoopMode];
		
		if (mode == AppConstants.kTwoPlayerClientMode) || (mode == AppConstants.kTwoPlayerServerMode) {
			pullDataController.startSend(arrayWithObjects:[game_id, Int(mode)]);
		}
	}
	
	@objc func oneSecondPulse() {
		
	}
	
	func showDynamicTimedModeEndAlert() {
		var message:String = ""
		var next_level_unlocked = false
//		let this_level_completed = ((polyhedronInfoArray?.object(at: Int(level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
//		if (score >= AppConstants.kScoreToObtainDynamic && !this_level_completed &&
//			((unlocked && level < 35) ||
//				(upgraded && level < 10) ||
//				(level < 5))) {
//			next_level_unlocked = true
//		}
		
		let buttons = NSArray(array:["Play Again", "Play Another Level", "Main Menu"])
		let type:Int = 6
		if (recordScore && !level_aborted) {
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
//		let this_level_completed = ((polyhedronInfoArray?.object(at: Int(level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
//		if (playTime <= AppConstants.kTimeToCompleteDynamic && !this_level_completed &&
//			((unlocked && level < 35) ||
//				(upgraded && level < 10) ||
//				(level < 5))) {
//			next_level_unlocked = true
//		}
		
		if (recordScore && !level_aborted) {
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
//		let this_level_completed = ((polyhedronInfoArray?.object(at: Int(level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(mode)) as! Bool
//		if (score >= AppConstants.kScoreToObtainStatic && !this_level_completed &&
//			((unlocked && level < 35) ||
//				(upgraded && level < 10) ||
//				(level < 5))) {
//			next_level_unlocked = true
//		}
		if (recordScore && !level_aborted) {
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
	
	func showPolyWordsViewAlertWithInfo(alertInfo:NSArray = NSArray()) {
		//		if (alertInfo != nil) {
		//			let myActionSheet:MyActionSheet = MyActionSheet.initialize(withController:appController, withInformation:alertInfo, withCallingObject:self)
		//			myActionSheet.showInView(self)
		//			[myActionSheet release];
		//		}
	}
	
	@objc func stopGameAnimation() {
		if (score_animating && gameAnimationTimer != nil) {
			//Move to new NSView class			self.perform(#selector(stopGameAnimation), with: nil, afterDelay: 1.0)
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
		
		/*		let game_state = polyWordsViewController.game_state
		if (points_avail < 3000 && mode == AppConstants.kStaticScoredMode && !level_aborted && game_state != AppConstants.kGameContinue) {
		let alert = NSPanel.init()
		//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reshuffle Letters" message:[NSString stringWithFormat:@"Only %i points are available with these letters.",points_avail]
		//															 delegate:self cancelButtonTitle:@"Shuffle" otherButtonTitles:nil];
		//			alert.tag = 1
		//			alert.makeKeyAndOrderFront(nil)
		}
		else if ((game_state == AppConstants.kGameStart || game_state == AppConstants.kGameRestart) && show_get_ready && mode != AppConstants.kTwoPlayerClientMode && mode != AppConstants.kTwoPlayerServerMode) {
		//			gameAnimationTimer = Timer(timeInterval:animationInterval, target: self, selector: #selector(drawView), userInfo: nil, repeats: true)
		//			if mode == AppConstants.kDynamicTimedMode {
		//				message = "Score as many points as you can in \(AppConstants.kTimeToCompleteDynamic) seconds.  Don't forget you can throw back letters.\n\n\n\n\n\n"
		//			} else if (mode == AppConstants.kStaticTimedMode) {
		//				message = "Score as many points as you can in \(AppConstants.kTimeToCompleteStatic) seconds.  Don't forget you can throw back letters.\n\n\n\n\n\n"
		//			} else if (mode == AppConstants.kDynamicScoredMode) {
		//				message = "Score \(AppConstants.kScoreToObtainDynamic) points as fast as you can.  Don't forget you can throw back letters.\n\n\n\n\n\n"
		//			} else if (mode == AppConstants.kStaticScoredMode) {
		//				message = "Score \(AppConstants.kScoreToObtainStatic) points as fast as you can.\n\n\n\n\n\n"
		//			}
		//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Ready" message:message
		//															 delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
		//			alert.tag = 3;
		var rect:CGRect
		if (mode == AppConstants.kDynamicTimedMode || mode == AppConstants.kDynamicScoredMode) {
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
		}
		else if (show_get_ready && opponent_ready) {
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
		if (!level_completed) {
		self.startClock()
		}
		}
		*/
		//	[self checkLevelCompleted];
	}
	
	func pushData() {
		let newWordsFound = NSMutableArray()
		let newWordScores = NSMutableArray()
		let count_old_words_found = oldWordsFound.count
		let count_words_found = wordsFound.count
		for ii in count_old_words_found..<count_words_found {
			newWordsFound.add(wordsFound[ii])
			newWordScores.add(wordScores[ii])
		}
		
		oldWordsFound = []
		oldWordsFound.append(contentsOf: wordsFound)
		let updatedData = NSArray(array: [newWordsFound, newWordScores, UInt(game_id), Int(mode)])
		pushDataController.startSend(with: updatedData)
	}
	
	func updateOpponent(information:NSArray) {
		if (information.count == 2) {
			let newWords = information.object(at:0) as! NSArray
			let newScores = information.object(at:1) as! NSArray
			for word in newWords as! [String] {
				wordsFoundOpponent.append(word)
				opponentWordsToDisplay.append(word)
				show_opponent_word = true
			}
			for scoreString in newScores as! [String] {
				opponent_score += Int(scoreString)!
				wordScoresOpponent.append(Int(scoreString) ?? 0)
			}
		}
		pullDataController.startSend(arrayWithObjects: NSArray(array: [UInt(game_id), Int(mode)]))
	}


	
	func showStaticScoredModeEndAlert() {
		var message = ""
		let buttons = NSMutableArray(array:["View Word List", "Play Again", "Play Another Level", "Main Menu"])
		var type:Int
		var next_level_unlocked = false
//		let this_level_completed = ((polyhedronInfoArray?.object(at: Int(level - 1) ) as! NSDictionary).object(forKey: "completed") as! NSArray).object(at: Int(appController!.mode)) as! Bool
//		if (playTime <= AppConstants.kTimeToCompleteStatic && !this_level_completed &&
//			((unlocked && level < 35) ||
//				(upgraded && level < 10) ||
//				(level < 5))) {
//			next_level_unlocked = true
//		}
		if (recordScore && !level_aborted) {
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
	
		func resetGame() {
			wordString = ""
			score = 0
			opponent_score = 0
			word_score = 0
			points_avail = 0
			points_avail_display = 0
			show_get_ready = true
			opponent_ready = false
			self.level_aborted = false
			self.level_completed = false
			wordsFound = []
			wordScores = []
			wordsFoundOpponent = []
			wordScoresOpponent = []
			timeHistory = []
			oldWordsFound = []
			playTime = 0.0
			lastSubmitTime = 0.0
			setWorldRotation(angle:0.0, X:0.0, Y:0.0, Z:1.0)
			setRotation(angle:0.0, X:0.0, Y:0.0, Z:1.0)
			endSpin()
	//TODO		polyWordsViewController.gameState = kGameStart
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
		timeHistory.removeAll()
		word_score = 0
		points_avail = 0
		points_avail_display = 0
		NSArray(array:[]).write(toFile: AppController.getDynamicScoredSavePath(), atomically:true)
		level_aborted = true
		self.startGameAnimation()
	}
	
	func checkLevelCompleted() {
		level_completed = false
		var level_unlock = false
		var recorded_score = AppConstants.kScoreToObtainDynamic
		var recorded_time = AppConstants.kTimeToCompleteDynamic
		if mode == AppConstants.kDynamicTimedMode {
			if (playTime.rounded(.towardZero) >= AppConstants.kTimeToCompleteDynamic || level_aborted) {
				if (score >= AppConstants.kScoreToObtainDynamic) {
					level_unlock = true
				}
				if (!level_aborted) {
					level_completed = true
				}
				AppController.removeAllStoredData()
				self.showDynamicTimedModeEndAlert()
				recorded_time = AppConstants.kTimeToCompleteDynamic
				recorded_score = UInt(score)
			}
		}	else if (mode == AppConstants.kStaticTimedMode) {
			if (playTime.rounded(.towardZero) >= AppConstants.kTimeToCompleteStatic || level_aborted) {
				if (score >= AppConstants.kScoreToObtainStatic) {
					level_unlock = true
				}
				if (!level_aborted) {
					level_completed = true
				}
				AppController.removeAllStoredData()
				self.showStaticTimedModeEndAlert()
				recorded_time = AppConstants.kTimeToCompleteStatic
				recorded_score = UInt(score)
			}
		}	else if (mode == AppConstants.kDynamicScoredMode) {
			if (playTime >= AppConstants.kTimeToCompleteStatic || level_aborted) {
				if (score >= AppConstants.kScoreToObtainStatic) {
					level_unlock = true
				}
				if (!level_aborted) {
					level_completed = true
				}
				AppController.removeAllStoredData()
				self.showDynamicScoredModeEndAlert()
				recorded_time = playTime
				recorded_score = AppConstants.kScoreToObtainDynamic
			}
		} else if (mode == AppConstants.kStaticScoredMode) {
			if (score >= AppConstants.kScoreToObtainStatic || level_aborted) {
				if (playTime <= AppConstants.kTimeToCompleteStatic) {
					level_unlock = true
				}
				if (!level_aborted) {
					level_completed = true
				}
				AppController.removeAllStoredData()
				self.showStaticScoredModeEndAlert()
				recorded_time = playTime
				recorded_score = AppConstants.kScoreToObtainStatic
			}
		}
		else if (mode == AppConstants.kTwoPlayerClientMode || mode == AppConstants.kTwoPlayerServerMode) {
			if (playTime.rounded(.towardZero) >= AppConstants.kTimeToCompleteStatic || level_aborted) {
				AppController.removeAllStoredData()
				pullDataController.session.finishTasksAndInvalidate()
				pushDataController.connection.finishTasksAndInvalidate()
				self.showTwoPlayerModeEndAlert()
				opponent_ready = false
			}
		}
		
//		if (recordScore && level_completed) {
//			highScores.addScoreForPolyhedron(ofType: polyhedron.polyInfo.object(forKey: "polyID") as! Int, forMode: appController!.mode, forTime: recorded_time, withScore: Int(recorded_score))
//			recordScore = false
//			opponent_ready = false
//			if (send_data_q) {
//				let postController = PostScoreController()
//				//				postController.startSend(NSArray(array: [score, playTime, level, UInt(mode), wordsFound as NSArray, wordScores as NSArray, wordScores as NSArray]))
//			}
//		}
		
//		if (level_completed) {
//			self.stopClock()
//			if (level_unlock) {
//				let dict:NSMutableDictionary = (polyhedronInfoArray!.object(at:(Int(level - 1))) as! NSDictionary).mutableCopy() as! NSMutableDictionary
//				let array2:NSMutableArray = (dict.object(forKey:"completed") as! NSArray).mutableCopy() as! NSMutableArray
//				array2.replaceObject(at: Int(appController!.mode), with: Bool(true))
//				dict.setValue(array2, forKey: "completed")
//				polyhedronInfoArray?.replaceObject(at: Int(level - 1), with: dict)
//			}
//		}
	}
//		func resetGame() {
//			wordString = ""
//			score = 0
//			opponent_score = 0
//			word_score = 0
//			points_avail = 0
//			points_avail_display = 0
//			show_get_ready = true
//			opponent_ready = false
//			self.level_aborted = false
//			self.level_completed = false
//			wordsFound = []
//			wordScores = []
//			wordsFoundOpponent = []
//			wordScoresOpponent = []
//			timeHistory = []
//			oldWordsFound = []
//			playTime = 0.0
//			lastSubmitTime = 0.0
//			setWorldRotation(angle:0.0, X:0.0, Y:0.0, Z:1.0)
//			setRotation(angle:0.0, X:0.0, Y:0.0, Z:1.0)
//			endSpin()
//	//TODO		polyWordsViewController.gameState = kGameStart
//		}

	func checkMatch() {
		if (mode == AppConstants.kStaticTimedMode || mode == AppConstants.kStaticScoredMode || mode == AppConstants.kTwoPlayerClientMode || mode == AppConstants.kTwoPlayerServerMode) {
			if (wordString.count > 2 && words.contains(wordString) && !wordsFound.contains(wordString) && !wordsFoundOpponent.contains(wordString)) {
				match = true
				self.getWordScore()
			}
		} else {
			if (wordString.count > 2 && words.contains(wordString)) {
				match = true
				self.getWordScore()
			} else {
				match = false
			}
		}
	}
	
		func wordsFound(withLength length:Int) -> NSArray {
			words = []
			for word in wordsFound {
				if word.count == length {
					words.append(word)
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
			
			for poly in polyhedron.polygons.joined() {
				if poly.active && points_avail < to_points {
					self.findWordsStarting(withPolygon: poly)
					poly_counter += 1
				}
			}
			
			if points == Int.max {
				for poly in polyhedron.polygons.joined() {
					poly.connections = []
				}
			}
			
			if points == Int.max {
				wordsDB.finalizeStatements()
				self.sortAvailableWords()
			} else {
				availableWords.removeAll()
				availableWordScores.removeAll()
			}
			
			finding_words = false
	//Move to new NSView class		self.performSelector(onMainThread: #selector(stopTransitionAnimation), with: nil, waitUntilDone: false)
			if !level_completed && !level_aborted {
	//Move to new NSView class			self.performSelector(onMainThread: #selector(startGameAnimation), with: nil, waitUntilDone: false)
			} else {
	//Move to new NSView class			self.performSelector(onMainThread: #selector(checkLevelComplete), with: nil, waitUntilDone: false)
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
					availableWords.append(word)
					num_words_avail = availableWords.count
					let num = self.getScore(forChain: chain)
					points_avail += Int(num)
					points_avail_display = (points_avail < 100000) ? points_avail : 1000
					availableWordScores.append(self.getScore(forChain: chain))
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
						let length1 = (availableWords[ii]).count
						let length2 = (availableWords[ii+1]).count
						if length1 < length2 {
							tempString = availableWords[ii]
							tempNum = availableWordScores[ii]
//							availableWords.replaceObject(at: ii, with: availableWords.object(at: ii+1))
//							availableWords.replaceObject(at: ii+1, with: tempString)
//							availableWordScores.replaceObject(at: ii, with: availableWordScores.object(at: ii+1))
//							availableWordScores.replaceObject(at: ii+1, with: tempNum)
							cont = true
						}
					}
				}
			}
			num_words_avail = availableWords.count
		}
		
		func selectPolyhedron(polyhedraInfo:Dictionary<String,Any>) {
			let alphabet = AppConstants.kAlphabet
			let commonLetters = AppConstants.kCommonLetters
			let uncommonLetters = AppConstants.kUncommonLetters
			let letterValues = AppConstants.kLetterValues
			let alphabetCount = alphabet.count
			touchedPolygons.removeAll()
			dragging = false
			score_animating = false
			recordTimeQ = true
			recordScore = true
			zoomFactor = 1
			timeLeft = AppConstants.kTimeToCompleteStatic
			touchAngles.removeAll()
			touchTimes.removeAll()
			freeWheeling = false
			touchedLetterView.placeholderString = ""
			wordString = ""
			match = false
			lookingUpWordsQ = false
			availableWords.removeAll()
			availableWordScores.removeAll()
			
			polyhedron = Polyhedron(name:"", withPolyID: polyhedraInfo["PolyID"] as! Int)
			
			let numSides = 6
			var axes_vertex_coord = Array(repeating: Float(), count: 3*4*numSides)
			var axes_cap_vertex_coord = Array(repeating: Float(), count: 3*numSides)
			var cosii:Float, sinii:Float, cosiiplusone:Float, siniiplusone:Float
			for ii in 0..<numSides {
				cosii = cos(Float(ii) * 2 * .pi / Float(numSides))
				sinii = sin(Float(ii) * 2 * .pi / Float(numSides))
				cosiiplusone = cos(Float((ii) + 1) * 2 * .pi / Float(numSides))
				siniiplusone = sin(Float((ii) + 1) * 2 * .pi / Float(numSides))
				axes_vertex_coord[12*ii + 0] = -1.0;
				axes_vertex_coord[12*ii + 1] = cosii;
				axes_vertex_coord[12*ii + 2] = sinii;
				axes_vertex_coord[12*ii + 3] = 1.0;
				axes_vertex_coord[12*ii + 4] = cosii;
				axes_vertex_coord[12*ii + 5] = sinii;
				axes_vertex_coord[12*ii + 6] = -1.0;
				axes_vertex_coord[12*ii + 7] = cosiiplusone;
				axes_vertex_coord[12*ii + 8] = siniiplusone;
				axes_vertex_coord[12*ii + 9] = 1.0;
				axes_vertex_coord[12*ii + 10] = cosiiplusone;
				axes_vertex_coord[12*ii + 11] = siniiplusone;
				
				axes_cap_vertex_coord[3*ii + 0] = cosii;
				axes_cap_vertex_coord[3*ii + 1] = sinii;
				axes_cap_vertex_coord[3*ii + 2] = 0.0;
			}
			
			for ii in 0..<4 {
				reds[ii] = 1.0
				greens[ii] = 1.0
				blues[ii] = 1.0
			}
			
			select_red = 0.7
			select_green = 0.7
			select_blue = 1.0
			
			num_colors = 1
			
			var colors = Array(repeating: NSColor(), count: 10)
			colors[0] = NSColor(red:0.752, green:0.730, blue:0.210, alpha:1.000)
			colors[1] = NSColor(red:0.777, green:0.685, blue:0.572, alpha:1.000)
			colors[2] = NSColor(red:0.905, green:0.835, blue:0.690, alpha:1.000)
			colors[3] = NSColor(red:0.825, green:0.703, blue:0.456, alpha:1.000)
			colors[4] = NSColor(red:0.637, green:0.075, blue:0.163, alpha:1.000)
			colors[5] = NSColor(red:0.541, green:0.654, blue:0.406, alpha:1.000)
			colors[6] = NSColor(red:0.679, green:0.548, blue:0.112, alpha:1.000)
			colors[7] = NSColor(red:0.592, green:0.512, blue:0.382, alpha:1.000)
			colors[8] = NSColor(red:0.530, green:0.604, blue:0.214, alpha:1.000)
			colors[9] = NSColor(red:0.305, green:0.505, blue:0.476, alpha:1.000)
			
			for kk in 0..<20 {
				let rgb:UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
				colors[kk%10].getComponents(rgb)
				reds[kk] = rgb[0]
				greens[kk] = rgb[1]
				blues[kk] = rgb[2]
			}
			
			differentPolygonTypes = 0
			polyhedron.animatingQ = false
			
			let polyInfo = polyhedraInfo

	//		self.staticWordsFoundFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[[appController getStaticWordsFoundPath] stringByAppendingFormat:@"_string"]];
	//		[staticWordsFoundFileHandle seekToEndOfFile];
	//		self.dynamicWordsFoundFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[[appController getDynamicWordsFoundPath] stringByAppendingFormat:@"_string"]];
	//		[dynamicWordsFoundFileHandle seekToEndOfFile];

		}
		
		@objc func stopTransitionAnimation() {
			
		}
		
		@objc func checkLevelComplete() {
			
		}
}
