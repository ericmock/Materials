//
//  GameScene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import Cocoa

class GameScene: Scene {
    //let trains = Instance(name: "train", instanceCount: 3)
    //let trees = Instance(name: "treefir", instanceCount: 2)
    
    let polyhedron = Polyhedron(name: "TestPolyhedron", findTangents: false)
    //let polyhedra = Instance(name: "TestPolyhedron", instanceCount: 1, findTangents: false)
    
    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 4
        camera.rotation = [-0.4,-0.4,0]
        
        add(node: polyhedron)
        
        polyhedron.rotation.y = radians(fromDegrees: Float.random(in: -180..<180))
    }
    
    @objc override func checkDrag(timer: Timer) {
        checked = true;
        if (!dragging || (hypot(currentTouchPosition.x - initialTouchPosition.x,currentTouchPosition.y - initialTouchPosition.y) < 5)) {
            mode = .select; // if dragging hasn't started yet, we're selecting
        } else {
            mode = .rotate
        }
        
        if (mode == .select) {
            oldText = touchedLetters;
            touchedNumber = findTouchedPolygon(atPoint: initialTouchPosition);
            let polyCount: Int = thePolyhedron.polygons.count;
            if (previouslyTouchedNumber >= 0 && previouslyTouchedNumber < polyCount) {
                let poly:MyPolygon = thePolyhedron.polygons[previouslyTouchedNumber]
                //                Polygons *poly = [polyhedron.polygons objectAtIndex:prev_touched_num];
                poly.touched = false;
            }
            if (touchedNumber >= 0 && previouslyTouchedNumber < polyCount) {
                let poly:MyPolygon = thePolyhedron.polygons[previouslyTouchedNumber]
                //                Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
                poly.touched = true;
                touchedLetters = oldText + alphabetArray[(poly.textureNumber)%26].lowercased()
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
        
        var closePolygons:[MyPolygon] = []
        var centroidZs:[Float] = [0]
        var faceNumbers:[Int] = [0]
        
        vec[3] = 1.0
        
        // TODO
        //        glGetIntegerv(GL_VIEWPORT, vp);
        //        matrixMatrixMultiply(delegate.projectionMatrix, modelViewMatrix, transform_matrix);
        
        var counter = 0
        for ll in 0..<10 {
            for ii in 0..<thePolyhedron.numberOfFacesOfType[ll] {
                var minX: Float = Float(MAXFLOAT)
                var maxX: Float = -Float(MAXFLOAT)
                var minY: Float = Float(MAXFLOAT)
                var maxY: Float = -Float(MAXFLOAT)
                for kk in 0..<(3+ll) {
                    for jj in 0..<3 {
                        vec[jj] = thePolyhedron.polyVertices[ll][(3 + ll) * 3 * ii + 3 * kk + jj];
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
                    closePolygons.append(thePolyhedron.polygons[counter])
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
            let polyType: Int = poly.polyType
            var deformedVertexX = [Float](repeating: 0, count: polyType + 3)
            var deformedVertexY = [Float](repeating: 0, count: polyType + 3)
            for nn in 0..<(polyType + 3) {
                let tmp: Int = 3 * (3 + polyType)
                let faceNumber: Int = Int(faceNumbers[counter])
                let base_vertex_index: Int = tmp * faceNumber + 3 * Int(nn)
                for kk in 0..<3 {
                    
                    vec[kk] = thePolyhedron.polyVertices[polyType][base_vertex_index + kk]
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
    
    override func touchesMoved(with event: NSEvent, inView view: NSViewController) {
        
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
    override func interactionsEnded(withEvent event:NSEvent) {
        
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
