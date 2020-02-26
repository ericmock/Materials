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
    let kRad2Deg:Float//static const float kRad2Deg = 180. / 3.1415927;
    let kDeg2Rad:Float//static const float kDeg2Rad = 3.1415927 / 180.;
    
    var gRadiusTrackball:Float = 0
    var gStartPtTrackball:SIMD3<Float> = [0, 0, 0]
    var gEndPtTrackball:SIMD3<Float> = [0, 0 ,0]
    var gXCenterTrackball:Float = 0.0
    var gYCenterTrackball:Float = 0.0
    
    init() {
        kRad2Deg = 180.0/pi
        kDeg2Rad = pi/180.0
    }
    
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
        xxyy = gStartPtTrackball[0] * gStartPtTrackball[0] + gStartPtTrackball[1] * gStartPtTrackball[1]
        if (xxyy > gRadiusTrackball * gRadiusTrackball) {
            // Outside the sphere.
            gStartPtTrackball[2] = 0.0
        } else {
            gStartPtTrackball[2] = sqrt(gRadiusTrackball * gRadiusTrackball - xxyy)
        }
        
    }
    
    // update to new mouse position, output rotation angle, rot is output rotation angle
    func rollToTrackball(withX x:Float, withY y:Float) -> SIMD4<Float> {
        var xxyy:Float = 0
        var cosAng:Float = 0
        var sinAng:Float = 0
        var ls:Float = 0
        var le:Float = 0
        var lr:Float = 0
        var rot:SIMD4<Float> = [0]
        
        gEndPtTrackball[0] = x - gXCenterTrackball
        gEndPtTrackball[1] = y - gYCenterTrackball
        if (abs(gEndPtTrackball[0] - gStartPtTrackball[0]) < kTol && abs(gEndPtTrackball[1] - gStartPtTrackball[1]) < kTol) {
            return rot// Not enough change in the vectors to have an action.
        }
        
        // Compute the ending vector from the surface of the ball to its center.
        xxyy = gEndPtTrackball[0] * gEndPtTrackball[0] + gEndPtTrackball[1] * gEndPtTrackball[1]
        if (xxyy > gRadiusTrackball * gRadiusTrackball) {
            // Outside the sphere.
            gEndPtTrackball [2] = 0.0
        } else {
            gEndPtTrackball[2] = sqrt(gRadiusTrackball * gRadiusTrackball - xxyy)
        }
        
        // Take the cross product of the two vectors. r = s X e
        //rot = cross(gStartPtTrackball, gEndPtTrackball)
            rot[1] =  gStartPtTrackball[1] * gEndPtTrackball[2] - gStartPtTrackball[2] * gEndPtTrackball[1]
            rot[2] = -gStartPtTrackball[0] * gEndPtTrackball[2] + gStartPtTrackball[2] * gEndPtTrackball[0]
            rot[3] =  gStartPtTrackball[0] * gEndPtTrackball[1] - gStartPtTrackball[1] * gEndPtTrackball[0]
        
        // Use atan for a better angle.  If you use only cos or sin, you only get
        // half the possible angles, and you can end up with rotations that flip around near
        // the poles.
        
        // cos(a) = (s . e) / (||s|| ||e||)
        //cosAng = dot(normalize(gStartPtTrackball),normalize(gEndPtTrackball))
            cosAng = gStartPtTrackball[0] * gEndPtTrackball[0] + gStartPtTrackball[1] * gEndPtTrackball[1] + gStartPtTrackball[2] * gEndPtTrackball[2] // (s . e)
            ls = sqrt(gStartPtTrackball[0] * gStartPtTrackball[0] + gStartPtTrackball[1] * gStartPtTrackball[1] + gStartPtTrackball[2] * gStartPtTrackball[2])
            ls = 1.0 / ls; // 1 / ||s||
            le = sqrt(gEndPtTrackball[0] * gEndPtTrackball[0] + gEndPtTrackball[1] * gEndPtTrackball[1] + gEndPtTrackball[2] * gEndPtTrackball[2])
            le = 1.0 / le; // 1 / ||e||
            cosAng = cosAng * ls * le
        
        // sin(a) = ||(s X e)|| / (||s|| ||e||)
//        let crossSE = cross(normalize(gStartPtTrackball),normalize(gEndPtTrackball))
        //sinAng = sqrt(dot(crossSE,crossSE))
        //lr = sinAng
            sinAng = sqrt(rot[1] * rot[1] + rot[2] * rot[2] + rot[3] * rot[3]) // ||(s X e)||;
                                        // keep this length in lr for normalizing the rotation vector later.
            sinAng = sinAng * ls * le
        lr = sinAng
        rot[0] = atan2(sinAng, cosAng) * kRad2Deg // GL rotations are in degrees.
        
        // Normalize the rotation axis.
        lr = 1.0 / lr
        rot[1] *= lr
        rot[2] *= lr
        rot[3] *= lr
        
        // returns rotate
        return rot
    }
    
    func rotation2Quat(withA A:SIMD4<Float>) -> SIMD4<Float> {
        var ang2:Float = 0
        var sinAng2:Float = 0
        var q:SIMD4<Float> = [0]
        
        // Convert a GL-style rotation to a quaternion.  The GL rotation looks like this:
        // {angle, x, y, z}, the corresponding quaternion looks like this:
        // {{v}, cos(angle/2)}, where {v} is {x, y, z} / sin(angle/2).
        
        ang2 = A[0] * kDeg2Rad * 0.5  // Convert from degrees ot radians, get the half-angle.
        sinAng2 = sin(ang2)
        q[0] = A[1] * sinAng2
        q[1] = A[2] * sinAng2
        q[2] = A[3] * sinAng2
        q[3] = cos(ang2)
        
        return q
    }
    
    func addToRotationTrackball(withDA dA:SIMD4<Float>, withA A:SIMD4<Float>) -> SIMD4<Float> {
        var q0:SIMD4<Float> = [0]
        var q1:SIMD4<Float> = [0]
        var q2:SIMD4<Float> = [0]
        var out:SIMD4<Float> = [0]
        var theta2:Float = 0
        var sinTheta2:Float = 0
        
        // Figure out A' = A . dA
        // In quaternions: let q0 <- A, and q1 <- dA.
        // Figure out q2 = q1 . q0 (note the order reversal!).
        // A' <- q2.
        // last element of q is the component on the 1 basis
        
        q0 = rotation2Quat(withA: A)
        q1 = rotation2Quat(withA: dA);
        
        // q2 = q1 + q0;
        q2[0] = q1[1]*q0[2] - q1[2]*q0[1] + q1[3]*q0[0] + q1[0]*q0[3]
        q2[1] = q1[2]*q0[0] - q1[0]*q0[2] + q1[3]*q0[1] + q1[1]*q0[3]
        q2[2] = q1[0]*q0[1] - q1[1]*q0[0] + q1[3]*q0[2] + q1[2]*q0[3]
        q2[3] = q1[3]*q0[3] - q1[0]*q0[0] - q1[1]*q0[1] - q1[2]*q0[2]
        // Here's an excersize for the reader: it's a good idea to re-normalize your quaternions
        // every so often.  Experiment with different frequencies.
        
        // An identity rotation is expressed as rotation by 0 about any axis.
        // The "angle" term in a quaternion is really the cosine of the half-angle.
        // So, if the cosine of the half-angle is one (or, 1.0 within our tolerance),
        // then you have an identity rotation.
        if (abs(abs(q2[3] - 1.0)) < 1.0e-7) {
            // Identity rotation.
            out[0] = 0.0
            out[1] = 1.0
            out[2] = 0.0
            out[3] = 0.0
            return out
        }
        
        // If you get here, then you have a non-identity rotation.  In non-identity rotations,
        // the cosine of the half-angle is non-0, which means the sine of the angle is also
        // non-0.  So we can safely divide by sin(theta2).
        
        // Turn the quaternion back into an {angle, {axis}} rotation.
        theta2 = acos(q2[3])
        sinTheta2 = 1.0/sin(theta2)
        out[0] = theta2 * 2.0 * kRad2Deg
        out[1] = q2[0] * sinTheta2
        out[2] = q2[1] * sinTheta2
        out[3] = q2[2] * sinTheta2
        
        return out
    }
    
    //void matrixMultiply (float * a, float * b, float * c) {
    //    c[0] = a[0]*b[0] + a[4]*b[1] + a[8]*b[2] + a[12]*b[3];
    //    c[1] = a[1]*b[0] + a[5]*b[1] + a[9]*b[2] + a[13]*b[3];
    //    c[2] = a[2]*b[0] + a[6]*b[1] + a[10]*b[2] + a[14]*b[3];
    //    c[3] = a[3]*b[0] + a[7]*b[1] + a[11]*b[2] + a[15]*b[3];
    //}
    
    //void matrixMatrixMultiply (float * a, float * b, float * c) {
    //    c[0] = a[0]*b[0] + a[4]*b[1] + a[8]*b[2] + a[12]*b[3];
    //    c[1] = a[1]*b[0] + a[5]*b[1] + a[9]*b[2] + a[13]*b[3];
    //    c[2] = a[2]*b[0] + a[6]*b[1] + a[10]*b[2] + a[14]*b[3];
    //    c[3] = a[3]*b[0] + a[7]*b[1] + a[11]*b[2] + a[15]*b[3];
    //    c[4] = a[0]*b[4] + a[4]*b[5] + a[8]*b[6] + a[12]*b[7];
    //    c[5] = a[1]*b[4] + a[5]*b[5] + a[9]*b[6] + a[13]*b[7];
    //    c[6] = a[2]*b[4] + a[6]*b[5] + a[10]*b[6] + a[14]*b[7];
    //    c[7] = a[3]*b[4] + a[7]*b[5] + a[11]*b[6] + a[15]*b[7];
    //    c[8] = a[0]*b[8] + a[4]*b[9] + a[8]*b[10] + a[12]*b[11];
    //    c[9] = a[1]*b[8] + a[5]*b[9] + a[9]*b[10] + a[13]*b[11];
    //    c[10] = a[2]*b[8] + a[6]*b[9] + a[10]*b[10] + a[14]*b[11];
    //    c[11] = a[3]*b[8] + a[7]*b[9] + a[11]*b[10] + a[15]*b[11];
    //    c[12] = a[0]*b[12] + a[4]*b[13] + a[8]*b[14] + a[12]*b[15];
    //    c[13] = a[1]*b[12] + a[5]*b[13] + a[9]*b[14] + a[13]*b[15];
    //    c[14] = a[2]*b[12] + a[6]*b[13] + a[10]*b[14] + a[14]*b[15];
    //    c[15] = a[3]*b[12] + a[7]*b[13] + a[11]*b[14] + a[15]*b[15];
    //}
    
    func length3D(withA a:SIMD4<Float>, withB b:SIMD4<Float>) -> Float {
        return sqrt((a[0] - b[0])*(a[0] - b[0]) + (a[1] - b[1])*(a[1] - b[1]) + (a[2] - b[2])*(a[2] - b[2]))
    }
    
    func crossProduct2D(withA a:SIMD4<Float>, withB b:SIMD4<Float>) -> Float {
        return a[0] * b[1] - a[1] * b[0]
    }
    
    //int pnpoly(int npol, float *xp, float *yp, float x, float y) {
    //    int i, j, c = 0;
    //    for (i = 0, j = npol-1; i < npol; j = i++) {
    //        if ((((yp[i] <= y) && (y < yp[j])) ||
    //             ((yp[j] <= y) && (y < yp[i]))) &&
    //            (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i]))
    //            c = !c;
    //    }
    //    return c;
    //}
}
