//
//  TitleScene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import CoreGraphics


class LevelSelectionScene: Scene {
	//	MARK:  Instance variables
	var touchAngles:[Float] = []
	var touchTimes:[Double] = []
	var lockedPolyhedronInfo:Dictionary<String,Any>
	var freeWheeling = false
	var dragging = false
	var omega = 0.0
	var touchStartTime = 0.0
	var stage:Int = 1
	var goingToNextLevel = false
	var goingToPreviousLevel = false
	var level = 0
	var integrator:Integrator?
	var initialState:stateStructure?
	var presentState:stateStructure?
	var polyhedraRotationAxes:[float3] = Array()
	var polyhedraRotationAngles:[Float] = Array()
	
	
	override init(screenSize: CGSize, sceneName: String) {
		lockedPolyhedronInfo = ["name": "Locked",
														"polyID": 0,
														"completed": [1, 1, 1, 1],
														"level": 0
		]
		super.init(screenSize: screenSize, sceneName: sceneName)
		integrator = Integrator(withScene: self, withDOFs: 1, withInitialState: stateStructure(withDOFs: 1), withForceFunction: {(coords, vels, time) in print(time)})
		
		for _ in 0..<6 {
			let x = Float.random(in: -1...1)
			let y = Float.random(in: -1...1)
			let z = Float.random(in: -1...1)
			polyhedraRotationAxes.append(normalize(float3(x, y, z)))
			polyhedraRotationAngles.append(0.0)
		}
		
		worldRotation_toLevelSelectionScene[1] = 1.0
		setupScene()
		
	}
	
	//	MARK:  Methods
	override func setupScene() {
		camera.target = [0, 0, 0]
		camera.distance = 3
		camera.nodeAngleAxis = AngleAxis()
		
		let worldModel = Model(forScene: self)
		worldModel.name = "World"
		worldModel.nodeAngleAxis = AngleAxis(angle: 2 * .pi / 12, axis: float3(1,0,0))

		add(node: worldModel, renderQ: false)
		models.append(worldModel)
		
		//		let polyhedraInfo = AppController.initializePolyhedronInfo()
		for (num,polyhedronInfo) in AppController.polyhedraInfo.enumerated() {
			if (polyhedronInfo["level"] as! Int) < 6 {
				let polyhedron = Polyhedron(name: polyhedronInfo["name"] as! String, withPolyID: polyhedronInfo["polyID"] as! Int, scene: self)
				polyhedron.nodeAngleAxis = AngleAxis(angle: radians(fromDegrees: Float.random(in: -180..<180)), axis: float3(0,1,0))
				polyhedron.nodePosition.x = 0
				polyhedron.nodePosition.y = 1.25 * cos(2.0 * Float(num)/6.0 * .pi)
				polyhedron.nodePosition.z = 1.25 * sin(2.0 * Float(num)/6.0 * .pi)
				polyhedron.nodeScaleV = float3(1.0/5.0, 1.0/5.0, 1.0/5.0)
				polyhedron.name = polyhedronInfo["name"] as! String
				add(node: polyhedron, parent: worldModel)
				models.append(polyhedron)
			}
		}
	}
	
//	override func updateScene(deltaTime: Float) {
//
//	}
	
	func updateNodePositions(deltaTime: Double) {
		for (num, polyhedron) in models[0].children.enumerated() {
			polyhedron.nodeAngleAxis = AngleAxis(angle: polyhedraRotationAngles[num], axis: polyhedraRotationAxes[num])
			polyhedraRotationAngles[num] += 0.01
		}
		if freeWheeling {
			integrator?.integrate(with: deltaTime)
			presentState = integrator!.state
//		print("updateNodePosition:", presentState!.theta[0])
			initialState = presentState
//			let previousTrackballQuaternion = gTrackballQuaternion
//			gTrackballQuaternion = simd_quatf(angle: presentState!.theta[0], axis: gTrackballQuaternion.axis)
			let newRotationQuat = AngleAxis(angle: presentState!.theta[0], axis: xAxis)
			models[0].nodeAngleAxis = newRotationQuat
//			print("updateNodePosition: \(models[0].nodeAngleAxis.angle), \(presentState!.theta[0]), \(gTrackballAngleAxis.axis)")
//			if omega > 0.001 {
//				let previousTrackballQuaternion = gTrackballQuaternion
//				gTrackballQuaternion = simd_quatf(angle: gTrackballQuaternion.angle + Float(omega) * 0.02, axis: gTrackballQuaternion.axis)
//				let newRotationQuat = gTrackballQuaternion * previousTrackballQuaternion.inverse * models[0].nodeQuaternion
//				models[0].nodeQuaternion = newRotationQuat
//
//				omega /= 1.05;
				
//				omega /= 1.05;
//			}
//			else {
//				freeWheeling = false
//				//						[self endSpin];
//			}
		}
		//			for (ii, title) in titles.enumerated() {
		//				let rotation = SIMD3<Float>(-presentState!.theta[ii], 0.0, 0.0)
		//				let transformMatrix = float4x4(rotateAboutXYZBy: rotation, aboutPoint: [0, -title.nodeInitialPosition.y - title.nodeScaleV.y, 0])
		//				let initialPosition = SIMD4<Float>(title.nodeInitialPosition.x, title.nodeInitialPosition.y, title.nodeInitialPosition.z, 1.0)
		//				title.nodePosition = (transformMatrix * initialPosition).xyz
		//			}
	}
	
	override func update(deltaTime: Double) {
		updateNodePositions(deltaTime: deltaTime)
		updateScene(deltaTime: deltaTime)
		uniforms.viewMatrix = camera.viewMatrix
		uniforms.projectionMatrix = camera.projectionMatrix
		uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
		fragmentUniforms.cameraPosition = camera.nodePosition
	}
	
	func getLevel() -> UInt {
		var level:UInt
		let levelRotation = worldRotation_toLevelSelectionScene
		//		levelRotation = trackball.addToRotationTrackball(withDA: gTrackBallRotation, withA: levelRotation)
		
		if (levelRotation[1] > 0.0) {
			if (levelRotation[0] > 62.0 && levelRotation[0] < 82.0) {
				level = 1
			} else if (levelRotation[0] > 134.0 && levelRotation[0] < 154.0) {
				level = 2
			} else if (levelRotation[0] > 206.0 && levelRotation[0] < 226.0) {
				level = 3
			} else if (levelRotation[0] > 278.0 && levelRotation[0] < 298.0) {
				level = 4
			} else {
				level = 0
			}
		} else {
			if (levelRotation[0] > 62.0 && levelRotation[0] < 82.0) {
				level = 4
			} else if (levelRotation[0] > 134.0 && levelRotation[0] < 154.0) {
				level = 3
			} else if (levelRotation[0] > 206.0 && levelRotation[0] < 226.0) {
				level = 2
			} else if (levelRotation[0] > 278.0 && levelRotation[0] < 298.0) {
				level = 1
			} else {
				level = 0
			}
		}
		return level;
		
	}
	
	func endSpin() {
//		print("start endSpin: ", 180.0 / .pi * gTrackballAngleAxis.angle)
//		gTrackballQuaternion = trackball.addToRotationTrackball(withDA: gTrackballQuaternion, withA: models[0].nodeQuaternion)
		gTrackballAngleAxis = AngleAxis(angle: 0, axis: xAxis)
//		print("end endSpin: ", 180.0 / .pi * gTrackballAngleAxis.angle)
	}
}

