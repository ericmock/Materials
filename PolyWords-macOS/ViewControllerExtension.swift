import Cocoa
import MetalKit

extension ViewController {
  func addGestureRecognizers(to view: NSView) {
//    let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
//    view.addGestureRecognizer(pan)
  }
  
	override func mouseDown(with event: NSEvent) {
		gameScene?.interactionsBegan(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		gameScene?.touchesMoved(with: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		gameScene?.interactionsEnded(withEvent: event)
	}
	
//  @objc func handlePan(gesture: NSPanGestureRecognizer) {
		// Need to update model/worldMatrix, not viewMatrix
//    let translation = gesture.translation(in: gesture.view)
//    let delta = float3(Float(translation.x),
//                       Float(translation.y),0)
//
//    gameScene?.camera.rotate(delta: delta)
//		gameScene?.touchesMoved(gesture: gesture)
//    gesture.setTranslation(.zero, in: gesture.view)
//  }
  
  override func scrollWheel(with event: NSEvent) {
    gameScene?.camera.zoom(delta: Float(event.deltaY))
  }
}

extension GameScene {
	// TODO:  Rotate the polyhedron only when clicking in a circumscribing circle.
	func interactionsBegan(with event: NSEvent) {
		print("Touches Began")

		touchAngles.removeAll()
		touchTimes.removeAll()
		touches.removeAll()
		
		if submitting {
			submitting = false
			for poly in touchedPolygons {
				poly.selected = false
			}
			touchedPolygons.removeAll()
		}
		
		if (freeWheeling) {
			freeWheeling = false
			endSpin()
		}
		
		let touchPosition = event.locationInWindow
		initialTouchPosition = touchPosition
		initialQuaternion = polyhedron.nodeQuaternion
		
		if touches.count > 1 {
			let t2 = touches[1]
			let touchPos2 = t2.locationInWindow
			initialDistance = hypot(Float(touchPos2.x-touchPosition.x), Float(touchPos2.y-touchPosition.y))
		}
		
		dragging = false
		checked = false

		var touchZone:Float = 405.0
		if AppController.unlocked {touchZone -= 45.0}
		if (Float(touchPosition.y) < touchZone && (touchPosition.x < 90.0 || touchPosition.x > 230.0)) {
			inputMode = .button
			if submitting {
				submitting = false
				wordDisplay = 0.0
			}
			touchTimes.append(get_time_of_day())
			touches.append(event)
		} else if touchPosition.y < 50 {
			inputMode = .edit
		} else {
			dragTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkDrag), userInfo: nil, repeats: false)
			inputMode = .rotate
			trackball.startTrackball(withX: Float(touchPosition.x), withY: Float(touchPosition.y), withOriginX: 0, withOriginY: 0, withWidth: Float(screenSize.width), withHeight: Float(screenSize.height));
			gTrackballQuaternion = simd_quatf(angle: 0, axis: float3(1,0,0))
		}
		
	}
	
	private func printQuat(_ quat:simd_quatf) {
		print("angle:\(quat.angle), axis:\(quat.axis)\n")
	}

	@objc func touchesMoved(with event:NSEvent) {
//		print("Touches Moved")

		dragging = true
		
		let position = event.locationInWindow
		if (inputMode == .rotate) {
//			print("Rotation Mode")
			touchTimes.append(get_time_of_day())
			let previousTrackballQuaternion = gTrackballQuaternion
			gTrackballQuaternion = trackball.rollToTrackball(withX: Float(position.x), withY: Float(position.y))
			let newRotationQuat = gTrackballQuaternion * previousTrackballQuaternion.inverse * polyhedron.nodeQuaternion
			polyhedron.nodeQuaternion = newRotationQuat
			touchAngles.append(polyhedron.nodeQuaternion.angle)
		} else if (inputMode == .select) {
//			print("Select Mode")
			let polygons:[Apolygon] = Array(polyhedron.polygons.joined())
			let touchedNum = findTouchedPolygon(atPoint: position)
			if (previouslyTouchedNumber >= 0 && previouslyTouchedNumber < polygons.count) {
				let poly = polygons[previouslyTouchedNumber]
				poly.touched = false
			}
			if touchedNum >= 0 {
				let poly = polygons[previouslyTouchedNumber]
				poly.touched = true
				viewController.touchedLetterView.placeholderString = AppConstants.kAlphabet[poly.texture % AppConstants.kAlphabet.count].lowercased()
				viewController.touchedLetterView.isHidden = false
				previouslyTouchedNumber = touchedNum
			}
		}
	}
	
	func interactionsEnded(withEvent event:NSEvent) {
		print("Touches Ended")

		NSObject.cancelPreviousPerformRequests(withTarget: self)
		var touchPosition: CGPoint = CGPoint(x:0.0, y:0.0)
		dragTimer.invalidate()
		
		if (dragging && inputMode == .rotate) {
			print("Rotation Mode")
			let count = touchTimes.count
			if (count > 3) {
				let dt = touchTimes[count - 1] - touchTimes[count - 3]
				omega = Double(touchAngles[count - 1] - touchAngles[count - 3])/dt
			}
			else if (count > 2) {
				let dt = touchTimes[count - 1] - touchTimes[count - 2]
				omega = Double(touchAngles[count - 1] - touchAngles[count - 2])/dt
			}
			else {
				omega = 0.0
			}
			
			freeWheeling = true
//			gTrackballQuaternion = simd_quatf(angle: 0, axis: float3(1,0,0))
			
//			polyhedron.nodeRotation = float4(0,1,0,0)
//			;print("model rotation reset:");printQuat(polyhedron.nodeQuaternion)
//			polyhedron.parent?.nodeRotation = rotation
//			;print("world rotation final:");printQuat(polyhedron.parent!.nodeQuaternion)
		}
		else if inputMode == .button {
			print("Button Mode")
			if touchPosition.x > 220.0 {
				for touchedPoly in touchedPolygons {
					touchedPoly.select_animation_start_time = get_time_of_day()
				}
				submitWord()
				submitting = true
			}
			else if (touchPosition.x < 90.0 && mode != AppConstants.kTwoPlayerClientMode && mode != AppConstants.kTwoPlayerServerMode) {
				pause()
			}
		}
		else if inputMode == .hint {
			print("Hint Mode")
		}
		else if (!dragging || inputMode == .select) {
			print("Select Mode")
			touchStartTime = get_time_of_day()
			let polygons:[Apolygon] = Array(polyhedron.polygons.joined())
			touchPosition = event.locationInWindow//[t locationInView:t.view];
			
			if (previousTouchNumber >= 0 && previousTouchNumber < polygons.count) {
				polygons[previouslyTouchedNumber].touched = false
			}
			
			let touchedNumber = findTouchedPolygon(atPoint: touchPosition)
			let touchedPolygon = Array(polyhedron.polygons.joined())[touchedNumber] as Apolygon
			print("Touched a \(touchedPolygon.type + 3)-sided polygon with letter \(touchedPolygon.letter)")
			
			if (touchedNumber >= 0) {
				let poly = polygons[touchedNumber]
				set(touchedPolygon: poly)
			} else {
//				set(touchedPolygon: )
			}
			
			if match {
				AppController.wordSound.play()
			}
			else {
				AppController.touchSound.play()
			}
			
			viewController.touchedLetterView.placeholderString = ""
			viewController.touchedLetterView.isHidden = true
		}
		dragging = false
	}
}

/*
extension GameScene {
	func touchesMoved(with event: NSEvent, inView view: NSViewController) {
		
		dragging = true
		
		//NSArray *touchArray = [touches allObjects];
		var touchPosition: CGPoint = CGPoint(x:0.0, y:0.0)
		
		//UITouch *t = [touchArray objectAtIndex:0];
		touchPosition = event.locationInWindow//[t locationInView:t.view];
		currentTouchPosition = touchPosition
		
		if (mode == .rotate) {
			touchPosition.y = screenSize.height - touchPosition.y
			gTrackBallRotation = trackball.rollToTrackball(withX: Float(touchPosition.x), withY: Float(touchPosition.y));
			//[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
		} else if (mode == .select) {
			//            int touched_num = [self findTouchedPolygonAtPoint:touchPos];
			//            if (prev_touched_num >= 0 && prev_touched_num < [polyhedron.polygons count]) {
			//                Polygons *poly = [polyhedron.polygons objectAtIndex:prev_touched_num];
			//                poly.touched = FALSE;
			//            }
			//            if (touched_num >= 0) {
			//                Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
			//                poly.touched = TRUE;
			//                delegate.touchedLetterView.text = [oldText stringByAppendingString:[[alphabetArray objectAtIndex:(poly.texture)%26] lowercaseString]];
			//                prev_touched_num = touched_num;
			//            }
		}
	}
	
	func interactionsEnded(withEvent event:NSEvent) {
		
		var touchPosition: CGPoint = CGPoint(x:0.0, y:0.0)
		dragTimer.invalidate()
		
		if (dragging && mode == .rotate) {
			//addToRotationTrackball (gTrackBallRotation, worldRotation);
			gTrackBallRotation[0] = 0.0
			gTrackBallRotation[1] = 0.0
			gTrackBallRotation[2] = 0.0
			gTrackBallRotation[3] = 0.0
			
			rotationAngles = gTrackBallRotation
			worldRotationAngles = worldRotation
		} else if (!dragging || mode == .select) {
			touchPosition = event.locationInWindow//[t locationInView:t.view];
			
			if (previousTouchNumber >= 0 && previousTouchNumber < thePolyhedron.polygons.count) {
				// need to make sure from level to level that index is within bounds
				//((Polygons *)[polyhedron.polygons objectAtIndex:prev_touched_num]).touched = FALSE;
				thePolyhedron.polygons[previousTouchNumber].touched = false
			}
			
			let touchedNumber = findTouchedPolygon(atPoint: touchPosition)//[self findTouchedPolygonAtPoint:touchPos];
			
			if (touchedNumber >= 0) {
				touchedPolygon = touchedNumber//][delegate setTouchedPolygon:[polyhedron.polygons objectAtIndex:touched_num]];
			} else {
				touchedPolygon = 0//[delegate setTouchedPolygon:nil]
			}
			
		}
		dragging = false
	}

}
*/
