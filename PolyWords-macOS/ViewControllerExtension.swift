import Cocoa
import MetalKit

extension ViewController {
  func addGestureRecognizers(to view: NSView) {
    let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
    view.addGestureRecognizer(pan)
  }
  
  @objc func handlePan(gesture: NSPanGestureRecognizer) {
    let translation = gesture.translation(in: gesture.view)
    let delta = float2(Float(translation.x),
                       Float(translation.y))
    
    titleScene?.camera.rotate(delta: delta)
    gesture.setTranslation(.zero, in: gesture.view)
  }
  
  override func scrollWheel(with event: NSEvent) {
    titleScene?.camera.zoom(delta: Float(event.deltaY))
  }
}

extension Scene {
	
	func interactionsBegan(with event: NSEvent, inView view: LocalViewController) {//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
		
		//NSArray *touchArray = [touches allObjects];
		//UITouch *t = [touchArray objectAtIndex:0];
		var touchPosition = event.locationInWindow//CGPoint touchPos = [t locationInView:t.view];
		initialTouchPosition = touchPosition
		
		dragging = false
		
		checked = false
		dragTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkDrag), userInfo: nil, repeats: false) //dragTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkDrag:) userInfo:nil repeats:NO] retain];
		
		mode = .rotate
		// Do we need this still?
		touchPosition.y = screenSize.height - touchPosition.y
		self.trackball.startTrackball(withX: Float(touchPosition.x), withY: Float(touchPosition.y), withOriginX: 0, withOriginY: 0, withWidth: Float(screenSize.width), withHeight: Float(screenSize.height));
	}
	
	func touchesMoved(with event: NSEvent, inView view: NSViewController) {
		
		dragging = true
		
		//NSArray *touchArray = [touches allObjects];
		var touchPosition: CGPoint = CGPoint(x:0.0, y:0.0)
		
		//UITouch *t = [touchArray objectAtIndex:0];
		touchPosition = event.locationInWindow//[t locationInView:t.view];
		currentTouchPosition = touchPosition
		
		if (mode == .rotate) {
			touchPosition.y = self.screenSize.height - touchPosition.y
			gTrackBallRotation = self.trackball.rollToTrackball(withX: Float(touchPosition.x), withY: Float(touchPosition.y));
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
//				thePolyhedron.polygons[previousTouchNumber].touched = false
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
