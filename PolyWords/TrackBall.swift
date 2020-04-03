//
//  TrackBall.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/18/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation

//
// File:        trackball.c
//
// Abstract:    Implements a trackball like camera system
//
// Version:        1.1 - minor fixes.
//                1.0 - Original release.
//
//
// Disclaimer:    IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
//                in consideration of your agreement to the following terms, and your use,
//                installation, modification or redistribution of this Apple software
//                constitutes acceptance of these terms.  If you do not agree with these
//                terms, please do not use, install, modify or redistribute this Apple
//                software.
//
//                In consideration of your agreement to abide by the following terms, and
//                subject to these terms, Apple grants you a personal, non - exclusive
//                license, under Apple's copyrights in this original Apple software ( the
//                "Apple Software" ), to use, reproduce, modify and redistribute the Apple
//                Software, with or without modifications, in source and / or binary forms;
//                provided that if you redistribute the Apple Software in its entirety and
//                without modifications, you must retain this notice and the following text
//                and disclaimers in all such redistributions of the Apple Software. Neither
//                the name, trademarks, service marks or logos of Apple Inc. may be used to
//                endorse or promote products derived from the Apple Software without specific
//                prior written permission from Apple.  Except as expressly stated in this
//                notice, no other rights or licenses, express or implied, are granted by
//                Apple herein, including but not limited to any patent rights that may be
//                infringed by your derivative works or by other works in which the Apple
//                Software may be incorporated.
//
//                The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
//                WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
//                WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
//                PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
//                ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//                IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
//                CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//                SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//                INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
//                AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
//                UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
//                OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Copyright ( C ) 2000-2007 Apple Inc. All Rights Reserved.
//

import simd
import Foundation

class Trackball {
	let kTol:Float = 0.01//static const float kTol = 0.001;
	let pi = Float.pi
//	let kRad2Deg:Float//static const float kRad2Deg = 180. / 3.1415927;
//	let kDeg2Rad:Float//static const float kDeg2Rad = 3.1415927 / 180.;
	
	var gRadiusTrackball:Float = 0
	var gStartPtTrackball:SIMD3<Float> = [0, 0, 0]
	var gEndPtTrackball:SIMD3<Float> = [0, 0 ,0]
	var gXCenterTrackball:Float = 0.0
	var gYCenterTrackball:Float = 0.0
	
//	init() {
//		kRad2Deg = 180.0/pi
//		kDeg2Rad = pi/180.0
//	}
	
	// mouse positon and view size as inputs
	func startTrackball(withX x:Float, withY y:Float, withOriginX originX:Float, withOriginY originY:Float, withWidth width:Float, withHeight height:Float) {
		var xxyy:Float
		var nx:Float
		var ny:Float
		
		/* Start up the trackball.  The trackball works by pretending that a ball
		encloses the 3D view.  You roll this pretend ball with the mouse.  For
		example, if you click on the center of the ball and move the mouse straight
		to the right, you roll the ball around its Y-axis.  This produces a Y-axis
		rotation.  You can click on the "edge" of the ball and roll it around
		in a circle to get a Z-axis rotation.
		
		The math behind the trackball is simple: start with a vector from the first
		mouse-click on the ball to the center of the 3D view.  At the same time, set the radius
		of the ball to be the smaller dimension of the 3D view.  As you drag the mouse
		around in the 3D view, a second vector is computed from the surface of the ball
		to the center.  The axis of rotation is the cross product of these two vectors,
		and the angle of rotation is the angle between the two vectors.
		*/
		nx = width
		ny = height
		if (nx < ny) {
			gRadiusTrackball = ny * 0.5;
		} else {
			gRadiusTrackball = nx * 0.5;
		}
		// Figure the center of the view.
		gXCenterTrackball = originX + width * 0.5
		gYCenterTrackball = originY + height * 0.5

		// Compute the starting vector from the surface of the ball to its center.
		gStartPtTrackball[0] = x - gXCenterTrackball
		gStartPtTrackball[1] = y - gYCenterTrackball
//		print("gStartPtTrackball: (\(gStartPtTrackball[0]), \(gStartPtTrackball[1]))")
		xxyy = gStartPtTrackball[0] * gStartPtTrackball[0] + gStartPtTrackball[1] * gStartPtTrackball[1]
		if (xxyy > gRadiusTrackball * gRadiusTrackball) {
			// Outside the sphere.
			gStartPtTrackball[2] = 0.0
		} else {
			gStartPtTrackball[2] = sqrt(gRadiusTrackball * gRadiusTrackball - xxyy)
		}
	}
	
	// update to new mouse position, output rotation angle, rot is output rotation angle
	func rollToTrackball(withX x:Float, withY y:Float) -> simd_quatf {
		var xxyy:Float = 0
		var cosAng:Float = 0
		var sinAng:Float = 0
		var ls:Float = 0
		var le:Float = 0
		var lr:Float = 0
		var rot:SIMD4<Float> = [0, 0, 0, 0]
		
		gEndPtTrackball[0] = x - gXCenterTrackball
		gEndPtTrackball[1] = y - gYCenterTrackball
//		print("gStartPtTrackball: (\(gStartPtTrackball[0]), \(gStartPtTrackball[1]))")
//		print("gEndPtTrackball: (\(gEndPtTrackball[0]), \(gEndPtTrackball[1]))")

		if (abs(gEndPtTrackball[0] - gStartPtTrackball[0]) < kTol && abs(gEndPtTrackball[1] - gStartPtTrackball[1]) < kTol) {
			return rotation2Quat(withA: rot)// Not enough change in the vectors to have an action.
		}
		
		// Compute the ending vector from the surface of the ball to its center.
		xxyy = gEndPtTrackball[0] * gEndPtTrackball[0] + gEndPtTrackball[1] * gEndPtTrackball[1]
		if (xxyy > gRadiusTrackball * gRadiusTrackball) {
			// Outside the sphere.
//			print("Outside the sphere.")
			gEndPtTrackball [2] = 0.0
		} else {
			gEndPtTrackball[2] = sqrt(gRadiusTrackball * gRadiusTrackball - xxyy)
		}
		
		// Take the cross product of the two vectors. r = s X e
		let cross = normalize(simd_cross(gStartPtTrackball,gEndPtTrackball))
//		print("trackball radius: \(gRadiusTrackball)")
//		print("cross product: \(cross)")
		rot[1] =  gStartPtTrackball[1] * gEndPtTrackball[2] - gStartPtTrackball[2] * gEndPtTrackball[1]
		rot[2] = -gStartPtTrackball[0] * gEndPtTrackball[2] + gStartPtTrackball[2] * gEndPtTrackball[0]
		rot[3] =  gStartPtTrackball[0] * gEndPtTrackball[1] - gStartPtTrackball[1] * gEndPtTrackball[0]
		
		// Use atan for a better angle.  If you use only cos or sin, you only get
		// half the possible angles, and you can end up with rotations that flip around near
		// the poles.
		
		// cos(a) = (s . e) / (||s|| ||e||)
		cosAng = gStartPtTrackball[0] * gEndPtTrackball[0] + gStartPtTrackball[1] * gEndPtTrackball[1] + gStartPtTrackball[2] * gEndPtTrackball[2] // (s . e)
		ls = sqrt(gStartPtTrackball[0] * gStartPtTrackball[0] + gStartPtTrackball[1] * gStartPtTrackball[1] + gStartPtTrackball[2] * gStartPtTrackball[2])
		ls = 1.0 / ls; // 1 / ||s||
		le = sqrt(gEndPtTrackball[0] * gEndPtTrackball[0] + gEndPtTrackball[1] * gEndPtTrackball[1] + gEndPtTrackball[2] * gEndPtTrackball[2])
		le = 1.0 / le; // 1 / ||e||
		cosAng = cosAng * ls * le
		
		// sin(a) = ||(s X e)|| / (||s|| ||e||)
		//        let crossSE = cross(normalize(gStartPtTrackball),normalize(gEndPtTrackball))
		sinAng = sqrt(rot[1] * rot[1] + rot[2] * rot[2] + rot[3] * rot[3]) // ||(s X e)||;
		// keep this length in lr for normalizing the rotation vector later.
		lr = sinAng
		sinAng = sinAng * ls * le
		rot[0] = -atan2(sinAng, cosAng) // GL rotations are in degrees.
		
		// Normalize the rotation axis.
		lr = 1.0 / lr
		rot[1] *= lr
		rot[2] *= lr
		rot[3] *= lr
		
//		;print("trackball angle: \(rot[0]), axis: {\(rot[1]), \(rot[2]), \(rot[3])}")
		
		return rotation2Quat(withA: rot)
	}
	
	func rotation2Quat(withA A:SIMD4<Float>) -> simd_quatf {
		var ang2:Float = 0
		var sinAng2:Float = 0
		var q:simd_quatf
		
		// Convert a GL-style rotation to a quaternion.  The GL rotation looks like this:
		// {angle, x, y, z}, the corresponding quaternion looks like this:
		// {{v}, cos(angle/2)}, where {v} is {x, y, z} / sin(angle/2).
		
		ang2 = A[0] * 0.5  // Convert from degrees ot radians, get the half-angle.
		sinAng2 = sin(ang2)
		q = simd_quatf(ix: A[1] * sinAng2, iy: A[2] * sinAng2, iz: A[3] * sinAng2, r: cos(ang2))
		return q
	}
	
	func addToRotationTrackball(withDA dA:float4, withA A:float4) -> float4 {
//		var theta2:Float = 0
		
		// Figure out A' = A . dA
		// In quaternions: let q0 <- A, and q1 <- dA.
		// Figure out q2 = q1 . q0 (note the order reversal!).
		// A' <- q2.
		// last element of q is the component on the 1 basis
		
		let q0 = rotation2Quat(withA: A)
		let q1 = rotation2Quat(withA: dA);
		
		// q2 = q1 + q0;
		let q2 = q0 * q1
		// Here's an excersize for the reader: it's a good idea to re-normalize your quaternions
		// every so often.  Experiment with different frequencies.
		
		// An identity rotation is expressed as rotation by 0 about any axis.
		// The "angle" term in a quaternion is really the cosine of the half-angle.
		// So, if the cosine of the half-angle is one (or, 1.0 within our tolerance),
		// then you have an identity rotation.
		if (abs(abs(q2.real - 1.0)) < 1.0e-7) {
			// Identity rotation.
			return float4(0,1,0,0)
		}
		
		// If you get here, then you have a non-identity rotation.  In non-identity rotations,
		// the cosine of the half-angle is non-0, which means the sine of the angle is also
		// non-0.  So we can safely divide by sin(theta2).
		
		// Turn the quaternion back into an {angle, {axis}} rotation.
		let angle = q2.angle
		let axis = q2.axis
		
		return float4(angle,axis[0],axis[1],axis[2])
	}
		
	func length3D(withA a:SIMD4<Float>, withB b:SIMD4<Float>) -> Float {
		return sqrt((a[0] - b[0])*(a[0] - b[0]) + (a[1] - b[1])*(a[1] - b[1]) + (a[2] - b[2])*(a[2] - b[2]))
	}
	
	func crossProduct2D(withA a:SIMD4<Float>, withB b:SIMD4<Float>) -> Float {
		return a[0] * b[1] - a[1] * b[0]
	}
}
