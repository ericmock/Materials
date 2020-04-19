import Cocoa
import MetalKit

extension ViewController {
  func addGestureRecognizers(to view: NSView) {
//    let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
//    view.addGestureRecognizer(pan)
  }
  
	override func mouseDown(with event: NSEvent) {
		gameScene?.interactionsBegan(with: event)
		levelSelectionScene?.interactionsBegan(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		gameScene?.touchesMoved(with: event)
		levelSelectionScene?.touchesMoved(with: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		gameScene?.interactionsEnded(withEvent: event)
		levelSelectionScene?.interactionsEnded(withEvent: event)
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
				poly.polygon.selected = false
			}
			touchedPolygons.removeAll()
		}
		
		if (freeWheeling) {
			freeWheeling = false
			endSpin()
		}
		
		let touchPosition = event.locationInWindow
		initialTouchPosition = touchPosition
		initialAngleAxis = polyhedron.nodeAngleAxis
		
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
			gTrackballAngleAxis = AngleAxis(angle: 0, axis: float3(1,0,0))
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
			let previousTrackballAngleAxis = gTrackballAngleAxis
			gTrackballAngleAxis = trackball.rollToTrackballAngleAxis(withX: Float(position.x), withY: Float(position.y))
//			let newRotationAA = gTrackballAngleAxis * previousTrackballAngleAxis.inverse * polyhedron.nodeQuaternion
//			polyhedron.nodeAngleAxis = newRotationAA
			touchAngles.append(polyhedron.nodeAngleAxis.angle)
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
		}
		else if inputMode == .button {
			print("Button Mode")
			if touchPosition.x > 220.0 {
				for touchedPoly in touchedPolygons {
					touchedPoly.polygon.select_animation_start_time = get_time_of_day()
				}
				submitWord()
				submitting = true
			}
			else if (touchPosition.x < 90.0 && AppController.gameMode != AppConstants.kTwoPlayerClientMode && AppController.gameMode != AppConstants.kTwoPlayerServerMode) {
				pause()
			}
		}
		else if inputMode == .hint {
			print("Hint Mode")
		}
		else if (!dragging || inputMode == .select) {
			print("Select Mode")
			touchStartTime = get_time_of_day()
//			let polygons:[Apolygon] = Array(polyhedron.polygons.joined())
			touchPosition = event.locationInWindow//[t locationInView:t.view];
			
			if (previousTouchNumber >= 0 && previousTouchNumber < polygonModels.count) {
				polygonModels[previouslyTouchedNumber].polygon.touched = false
			}
			
			let touchedNumber = findTouchedPolygon(atPoint: touchPosition)
			let touchedPolygon = polygonModels[touchedNumber]
			print("Touched a \(touchedPolygon.polygon.type + 3)-sided polygon with letter \(touchedPolygon.polygon.letter)")
			
			if (touchedNumber >= 0) {
				let touchedPoly = polygonModels[touchedNumber]
				touchedPoly.polygon.select_animation_start_time = touchStartTime
				if !renderables.contains(touchedPoly) {
					renderables.append(touchedPoly)
//					print(poly.nodeQuaternion)
//					print(polyhedron.nodeQuaternion)
//					print("normal:  ",poly.polygon.normal_v)
//					print("tangent:  ",poly.polygon.tangent_v)
//					print("bitan:  ",poly.polygon.bitan_v)
//					let rot:float3x3 = float3x3(tensorProduct: poly.polygon.normal_v, float3(0,0,-1))
//					+ float3x3(tensorProduct: poly.polygon.tangent_v, float3(0,1,0))
//					+ float3x3(tensorProduct: poly.polygon.bitan_v, float3(1,0,0))
//					print("calculated rot:  ", rot)
//					poly.nodeQuaternion = simd_quatf(rot)//*polyhedron.nodeQuaternion.inverse
//					print(poly.nodeQuaternion)
//					print("translated rot:  ", float4x4(poly.nodeQuaternion))
//					poly.nodePosition = float3(0,2.5,0)
//					let vec = rot * poly.polygon.normal_v
//					print(vec)
//					_ = poly.modelMatrix
//					let init_quat = simd_quatf(from: float3(0,0,1), to: normalize(poly.polygon.centroid))
//					poly.nodeQuaternion = init_quat.inverse//quat * polyhedron.nodeQuaternion
//					poly.nodePosition = polyhedron.nodePosition
					polyhedron.polygonSelectedQ[touchedNumber] = true
					touchedPoly.initialTouchedAngleAxis = polyhedron.nodeAngleAxis
//								if (level == 0) {
//									touchedPoly.nodeQuaternion += simd_quatf(angle: 130.0 * .pi/180.0, axis:float3(0,0,1))
//								} else {
//									switch touchedPoly.polygon.type {
//									case 5:
//										touchedPoly.nodeQuaternion += simd_quatf(angle: -180.0 * .pi/180.0, axis:float3(0,0,1))
//										break
//									case 3:
//										touchedPoly.nodeQuaternion += simd_quatf(angle: -360.0 * .pi/180.0, axis:float3(0,0,1))
//										break
//									default:
//										touchedPoly.nodeQuaternion = touchedPoly.nodeQuaternion * simd_quatf(angle: -180.0 * .pi/180.0, axis:float3(0,1,0)) * simd_quatf(angle: -180.0 * .pi/180.0, axis:float3(0,0,1))
//										break
//									}
//								}

//					basePoly.nodePosition = (polyhedron.modelMatrix * float4(touchedPolygon.centroid,1)).xyz
//					poly.initialTouchedPosition = polyhedron.nodePosition
//					poly.initialTouchedQuaternion = polyhedron.nodeQuaternion
//					poly.initialTouchedScaleV = polyhedron.nodeScaleV
//					poly.initialTouchedCentroid = polyhedron.modelMatrix.upperLeft * poly.polygon.centroid
//					print("original centroid: \(poly.polygon.centroid)")
//					print("touched centroid: \(poly.initialTouchedCentroid)")
				}
				set(touchedPolygonModel: touchedPoly)
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

extension LevelSelectionScene {
	// TODO:  Rotate the polyhedron only when clicking in a circumscribing circle.
	func interactionsBegan(with event: NSEvent) {
		print("\n\n\n\n\n\nTouches Began")

		touchAngles.removeAll()
		touchTimes.removeAll()
//		touches.removeAll()
		
		if (freeWheeling) {
			freeWheeling = false
			endSpin()
		}
		
		let touchPosition = event.locationInWindow
		initialTouchPosition = touchPosition
		initialAngleAxis = models[0].nodeAngleAxis
				
		dragging = false
		checked = false

		var touchZone:Float = 405.0
		if AppController.unlocked {touchZone -= 45.0}
		if (Float(touchPosition.y) < touchZone && (touchPosition.x < 90.0 || touchPosition.x > 230.0)) {
			inputMode = .button
			touchTimes.append(get_time_of_day())
		} else if touchPosition.y < 50 {
			inputMode = .edit
		} else {
			dragTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkDrag), userInfo: nil, repeats: false)
			inputMode = .rotate
			trackball.startTrackball(withX: Float(screenSize.width/2), withY: Float(touchPosition.y), withOriginX: 0, withOriginY: 0, withWidth: Float(screenSize.width), withHeight: Float(screenSize.height));
			gTrackballAngleAxis = AngleAxis()
		}
	}
	
	private func printQuat(_ quat:simd_quatf) {
		print("angle:\(quat.angle), axis:\(quat.axis)\n")
	}

	@objc func touchesMoved(with event:NSEvent) {
		print("TM", terminator:"")

		dragging = true
		
		let position = event.locationInWindow
		if (inputMode == .rotate) {
//			print("Rotation Mode")
			touchTimes.append(get_time_of_day())
			let previousTrackballAngleAxis = gTrackballAngleAxis
			gTrackballAngleAxis = trackball.rollToTrackballAngleAxis(withX: Float(screenSize.width/2), withY: Float(position.y))
			let changeAngleAxis = AngleAxis(simd_quatf(gTrackballAngleAxis) * simd_quatf(previousTrackballAngleAxis).inverse)
			let newRotationAA = AngleAxis(simd_quatf(changeAngleAxis) * simd_quatf(models[0].nodeAngleAxis))
			print("rotations: \(180.0 / .pi * newRotationAA.angle) = \(-sign(changeAngleAxis.axis[0]))*\(180.0 / .pi * changeAngleAxis.angle) + \(180.0 / .pi * models[0].nodeAngleAxis.angle)")
			models[0].nodeAngleAxis = newRotationAA
			touchAngles.append(models[0].nodeAngleAxis.angle)
		} 
	}
	
	func interactionsEnded(withEvent event:NSEvent) {
		print("\n\n\n\n\n\nTouches Ended")

		NSObject.cancelPreviousPerformRequests(withTarget: self)
//		var touchPosition:CGPoint = CGPoint(x:0.0, y:0.0)
		dragTimer.invalidate()
		gTrackballAngleAxis = AngleAxis()
		integrator?.resetState()
		integrator?.state.theta[0] = models[0].nodeAngleAxis.angle
		print("viewController: ", 180.0 / .pi * integrator!.state.theta[0])
		if (dragging) {
			print("Rotation Mode")
			let count = min(touchTimes.count,touchAngles.count)
//			if count > 0 {
//				integrator?.initialState.theta[0] = touchAngles[count - 1]
//			}
//			else {
//			}
			if (count > 3) {
				let dt = touchTimes[count - 1] - touchTimes[0]
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
			integrator?.state.omega[0] = Float(omega)
		}
		else if inputMode == .button {
			print("Button Mode")
			let touchPosition = event.locationInWindow
			if touchPosition.x > 280.0 && ((stage < 7 && AppController.unlocked) || (stage < 2 && AppController.upgraded)) {
				goingToNextLevel = true
			}
			else if (touchPosition.x < 40.0 && stage > 1) {
				goingToPreviousLevel = true
			}
			else {
				var localAngle = models[0].nodeAngleAxis.angle
				
				if (localAngle < 0.0) {
					localAngle = 2.0 * .pi - localAngle
				}
				if (localAngle > 62.0 && localAngle < 82.0) {
					level = 1
				} else if (localAngle > 134.0 && localAngle < 154.0) {
					level = 2
				} else if (localAngle > 206.0 && localAngle < 226.0) {
					level = 3
				} else if (localAngle > 278.0 && localAngle < 298.0) {
					level = 4
				} else {
					level = 0
				}
				
				let baseLevel = (stage-1)*5
//				let mode = AppController.gameMode
				var index:Int
				var complete:Bool
				
//				if baseLevels + level - 1 < 0 {
				if true {
					complete = true
				}
				else {
					index = baseLevel + level - 1
					let polyDict = AppController.polyhedraInfo[index]
					complete = (Array(arrayLiteral: polyDict["complete"])[AppController.gameMode] != nil)
				}

				if complete {
					models.removeSubrange(1...)
//					[viewController.indicatorView startAnimating];
					AppController.polyhedronInfo = AppController.polyhedraInfo[baseLevel + level]
					if !AppController.gameViewInitialized {
						AppController.initializeGame()
					}
					AppController.resetGame()
					AppController.perform(#selector(AppController.startGame), with: nil, afterDelay: 0.5)

				}
			}
		}
		
		dragging = false
	}
}
