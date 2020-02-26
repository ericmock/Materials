//
//  TitleIntegrator.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import simd

let kNumParticles = 10

struct stateStructure {
    var theta:[Float] = [Float](repeating:1.0, count: kNumParticles)
    var omega:[Float] = [Float](repeating:0.0, count: kNumParticles)
    var alpha:[Float] = [Float](repeating:0.0, count: kNumParticles)
    var cos_theta:[Float] = [Float](repeating:0.0, count: kNumParticles)
    var sin_theta:[Float] = [Float](repeating:0.0, count: kNumParticles)
    
    init() {
        for ii in 0..<kNumParticles {
            theta[ii] = Float(Int.random(in: -100...100))/100.0
        }
    }
}

struct derivative {
    var dtheta:[Float] = [Float](repeating:0.0, count: kNumParticles)
    var domega:[Float] = [Float](repeating:0.0, count: kNumParticles)
};

struct acceleration {
    var alpha:[Float] = [Float](repeating:0.0, count: kNumParticles)
};

//
//  IntegratorMain.m
//  SlingShot
//
//  Created by Eric Mockensturm on 4/17/09.
//  Copyright 2009 Penn State University. All rights reserved.
//
//
//#import "IntegratorTitle.h"
//#import "AppController.h"
//#import "random.h"
//


class TitleIntegrator {
    
    var scene:Scene
    var state:stateStructure = stateStructure()
    
    init(scene:Scene) {
        self.scene = scene
        resetState()
    }
    //@implementation IntegratorTitle
    //
    //@synthesize endState;
    //
    //- (id) initWithDelegate: (AppController *)d {
    //    if ((self = [super init])) {
    //        delegate = d;
    //        [self resetState];
    //    }
    //    return self;
    //}
    //
    func integrate(with dt:TimeInterval) {
        var a = derivative()
        var b = derivative()
        var c = derivative()
        var d = derivative()
        var dthetadt:Float = 0.0
        var domegadt:Float = 0.0
        
        a = evaluate(with: state)
        b = evaluate(with: state, deltaT:dt*0.5, d:a)
        c = evaluate(with: state, deltaT:dt*0.5, d:b)
        d = evaluate(with: state, deltaT:dt, d:c)
        
        for ll in 0..<kNumParticles {
            dthetadt = 1.0/6.0 * (a.dtheta[ll] + 2.0 * (b.dtheta[ll] + c.dtheta[ll]) + d.dtheta[ll])
            domegadt = 1.0/6.0 * (a.domega[ll] + 2.0 * (b.domega[ll] + c.domega[ll]) + d.domega[ll])
            state.theta[ll] = state.theta[ll] + dthetadt*Float(dt)
            state.omega[ll] = state.omega[ll] + domegadt*Float(dt)
        }
    }
    
    //- (void) integrate:(double) dt {
    //    struct derivative a;
    //    struct derivative b;
    //    struct derivative c;
    //    struct derivative d;
    //    double dthetadt;//, drdt;
    //    double domegadt;//, dvdt;
    //
    //    a = [self evaluate:state];
    //    b = [self evaluate:state deltat:dt*0.5 deriv:a];
    //    c = [self evaluate:state deltat:dt*0.5 deriv:b];
    //    d = [self evaluate:state deltat:dt deriv:c];
    //
    //    uint ll;
    //    for (ll=0;ll<kNumParticles;ll++) {
    //        dthetadt = 1.0/6.0 * (a.dtheta[ll] + 2.0*(b.dtheta[ll] + c.dtheta[ll]) + d.dtheta[ll]);
    //        domegadt = 1.0/6.0 * (a.domega[ll] + 2.0*(b.domega[ll] + c.domega[ll]) + d.domega[ll]);
    //        state.theta[ll] = state.theta[ll] + dthetadt*dt;
    //        state.omega[ll] = state.omega[ll] + domegadt*dt;
    ////        state.sin_theta[ll] = sin(state.theta[ll]);
    ////        state.cos_theta[ll] = cos(state.theta[ll]);
    //    }
    //    endState = state;
    //
    //    return;
    //}
    //
    
    func evaluate(with initial:stateStructure) -> derivative {
        var output:derivative = derivative()
        var accelXY:acceleration = acceleration()
        
        for ll in 0..<kNumParticles {
            output.dtheta[ll] = initial.omega[ll]
            accelXY = accel(with: initial)
            output.domega[ll] = accelXY.alpha[ll]
        }
        return output
    }
    //- (struct derivative) evaluate:(struct statestruc) initial {
    //    struct derivative output;
    //    struct acceleration accelXY;
    //
    //    uint ll;
    //    for (ll=0;ll<kNumParticles;ll++) {
    //        output.dtheta[ll] = initial.omega[ll];
    //        accelXY = [self accelerationAtInitialState:initial];
    //        output.domega[ll] = accelXY.alpha[ll];
    //    }
    //
    //    return output;
    //}
    //
    
    func evaluate(with initial:stateStructure, deltaT dt:TimeInterval, d:derivative) -> derivative {
        var output:derivative = derivative()
        var accelXY:acceleration = acceleration()
        
        for ll in 0..<kNumParticles {
            state.theta[ll] = initial.theta[ll] + d.dtheta[ll]*Float(dt)
            state.omega[ll] = initial.omega[ll] + d.domega[ll]*Float(dt)
            output.dtheta[ll] = state.omega[ll]
            
            accelXY = accel(with: initial)
            output.domega[ll] = accelXY.alpha[ll]
        }
        return output
    }
    //- (struct derivative) evaluate:(struct statestruc) initial deltat:(double)dt deriv:(struct derivative) d {
    //    struct acceleration accelXY;
    //    struct derivative output;
    //
    //    uint ll;
    //    for (ll=0;ll<kNumParticles;ll++) {
    //        state.theta[ll] = initial.theta[ll] + d.dtheta[ll]*dt;
    //        state.omega[ll] = initial.omega[ll] + d.domega[ll]*dt;
    //        output.dtheta[ll] = state.omega[ll];
    //
    //        accelXY = [self accelerationAtInitialState:initial];
    //
    //        output.domega[ll] = accelXY.alpha[ll];
    //    }
    //
    //    return output;
    //}
    //
    func accel(with initial:stateStructure) -> acceleration {
        var accelXY = acceleration()
        let g:Float = 10.0
        let gangle:Float = atan2(-scene.accelz, -scene.accely)
        for ii in 0..<kNumParticles {
            accelXY.alpha[ii] = -g/2*sin(initial.theta[ii] - gangle) - 0.25*initial.omega[ii]
        }
        return accelXY
    }
    //- (struct acceleration) accelerationAtInitialState:(struct statestruc) initial {
    //
    //    struct acceleration accelXY;
    //
    //    double g = 10.0;
    //    float gangle = atan2(-delegate.accelz,-delegate.accely);
    //    for (int ii = 0; ii < kNumParticles; ii++) {
    //        accelXY.alpha[ii] = -g/2*sin(initial.theta[ii] - gangle) - 0.25*initial.omega[ii];
    //    }
    //
    //    return accelXY;
    //}
    //
    
    func resetState() {
        state = stateStructure()
    }
    
    //- (void) resetState {
    //    int ii;
    //    for (ii=0;ii<kNumParticles;ii++) {
    //        state.theta[ii] = 0.0;//frandom(-M_PI, M_PI);
    ////        state.sin_theta[ii] = sin(state.theta[ii]);
    ////        state.cos_theta[ii] = cos(state.theta[ii]);
    //        state.omega[ii] = frandom(-0.08, 0.08);
    //    }
    //}
    //
    //@end
}
