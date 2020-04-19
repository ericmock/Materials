//
//  TitleIntegrator.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import simd

struct stateStructure {
	var theta:[Float] = Array()//[Float](repeating:1.0, count: kNumParticles)
	var omega:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	var alpha:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	var cos_theta:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	var sin_theta:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	
	init(withDOFs dofs:Int) {
		for _ in 0..<dofs {
			theta.append(0.0)
			omega.append(0.0)
			alpha.append(0.0)
			cos_theta.append(0.0)
			sin_theta.append(0.0)
		}
	}
}

struct derivative {
	var dtheta:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	var domega:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	init(withDOFs dofs:Int) {
		for _ in 0..<dofs {
			dtheta.append(0.0)
			domega.append(0.0)
		}
	}
}

struct acceleration {
	var alpha:[Float] = Array()//[Float](repeating:0.0, count: kNumParticles)
	init(withDOFs dofs:Int) {
		for _ in 0..<dofs {
			alpha.append(0.0)
		}
	}

}

class Integrator {
	
	var scene:Scene
	var state:stateStructure
	var F:[Float] = []
	var dofs:Int
//	var setF: ([Double],[Double],Double) -> Void
	
	init(withScene scene:Scene, withDOFs dofs:Int, withInitialState initial:stateStructure, withForceFunction setF:@escaping (_ coords:[Double], _ vels:[Double], _ time:Any) -> Void) {
		self.scene = scene
		self.dofs = dofs
//		self.setF = setF
//		state = stateStructure(withDOFs: dofs)
		F = Array(repeating: 0.0, count: dofs)
		state = initial
		resetState()
	}
	
	func integrate(with dt:TimeInterval) {
		print("integrate start:  ", 180.0 / .pi * state.theta[0])
		var a = derivative(withDOFs: dofs)
		var b = derivative(withDOFs: dofs)
		var c = derivative(withDOFs: dofs)
		var d = derivative(withDOFs: dofs)
		var dthetadt:Float = 0.0
		var domegadt:Float = 0.0
		
		a = evaluate(with: state)
		b = evaluate(with: state, deltaT:dt*0.5, d:a)
		c = evaluate(with: state, deltaT:dt*0.5, d:b)
		d = evaluate(with: state, deltaT:dt, d:c)
		
		for ll in 0..<dofs {
			dthetadt = 1.0/6.0 * (a.dtheta[ll] + 2.0 * (b.dtheta[ll] + c.dtheta[ll]) + d.dtheta[ll])
			domegadt = 1.0/6.0 * (a.domega[ll] + 2.0 * (b.domega[ll] + c.domega[ll]) + d.domega[ll])
			state.theta[ll] = state.theta[ll] + dthetadt*Float(dt)
			state.omega[ll] = state.omega[ll] + domegadt*Float(dt)
			while state.omega[ll] > 2.0 * .pi {
				state.omega[ll] -= 2.0 * .pi
			}
		}
		print("integrate end:  ", 180.0 / .pi * state.theta[0])
	}
	
	func evaluate(with initial:stateStructure) -> derivative {
		var output:derivative = derivative(withDOFs: dofs)
		var accelXY:acceleration = acceleration(withDOFs: dofs)
		
		for ll in 0..<dofs {
			output.dtheta[ll] = initial.omega[ll]
			accelXY = accel(with: initial)
			output.domega[ll] = accelXY.alpha[ll]
		}
		return output
	}
	
	func evaluate(with initial:stateStructure, deltaT dt:TimeInterval, d:derivative) -> derivative {
		var output:derivative = derivative(withDOFs: dofs)
		var accelXY:acceleration = acceleration(withDOFs: dofs)
		
		for ll in 0..<dofs {
			state.theta[ll] = initial.theta[ll] + d.dtheta[ll]*Float(dt)
			state.omega[ll] = initial.omega[ll] + d.domega[ll]*Float(dt)
			output.dtheta[ll] = state.omega[ll]
			
			accelXY = accel(with: initial)
			output.domega[ll] = accelXY.alpha[ll]
		}
		return output
	}
	
	func accel(with initial:stateStructure) -> acceleration {
		var accelXY = acceleration(withDOFs: dofs)
		setF(withCoords: initial.theta, vels: initial.omega, time: 0.0)
		for ii in 0..<dofs {
			accelXY.alpha[ii] = F[ii]
		}
		return accelXY
	}
	
//	func setF(withCoords coords:[Float], vels:[Float], time:Double) {
//		let g:Float = 10.0
//		let gangle:Float = atan2(-scene.accelz, -scene.accely)
//		for ii in 0..<dofs {
//			if state.omega[ii] < 0.2 {
//				F[ii] = -g/2*sin(coords[ii] - gangle) - 0.25*vels[ii]
//			}
//		}
//	}
	
	func setF(withCoords coords:[Float], vels:[Float], time:Double) {
		for ii in 0..<dofs {
			F[ii] = 0.2 * sin(6.0 * coords[ii]) - 0.3 * vels[ii]
		}
	}

	func resetState() {
		state = stateStructure(withDOFs: dofs)
	}
}
