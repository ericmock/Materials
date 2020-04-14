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

	
	override init(screenSize: CGSize, sceneName: String) {
		lockedPolyhedronInfo = ["name": "Locked",
														"polyID": 0,
														"completed": [1, 1, 1, 1],
														"level": 0
		]
		super.init(screenSize: screenSize, sceneName: sceneName)
//		gTrackBallRotation[1] = 1.0
		worldRotation_toLevelSelectionScene[1] = 1.0
		setupScene()

	}

//	MARK:  Methods
	override func setupScene() {
		camera.target = [0, 0, 0]
		camera.distance = 3
		camera.nodeQuaternion = simd_quatf()
		
		let worldModel = Model(forScene: self)
		worldModel.name = "World"
		add(node: worldModel, renderQ: false)
		models.append(worldModel)

		let polyhedraInfo = AppController.initializePolyhedronInfo()
		for (num,polyhedronInfo) in polyhedraInfo.enumerated() {
			if (polyhedronInfo["level"] as! Int) < 6 {
				let polyhedron = Polyhedron(name: polyhedronInfo["name"] as! String, withPolyID: polyhedronInfo["polyID"] as! Int, scene: self)
				polyhedron.nodeQuaternion = simd_quatf(angle: radians(fromDegrees: Float.random(in: -180..<180)), axis: float3(0,1,0))
				polyhedron.nodePosition.x = 0
				polyhedron.nodePosition.y = 1.25 * cos(2.0 * Float(num)/6.0 * .pi)
				polyhedron.nodePosition.z = 1.25 * sin(2.0 * Float(num)/6.0 * .pi)
				polyhedron.nodeScaleV = float3(1.0/5.0, 1.0/5.0, 1.0/5.0)
				add(node: polyhedron, parent: worldModel)
				models.append(polyhedron)
			}
		}
	}

//	override func updateScene(deltaTime: Float) {
//	}
//		
//	override func update(deltaTime: Float) {
//	}
	
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
		gTrackballQuaternion = trackball.addToRotationTrackball(withDA: gTrackballQuaternion, withA: models[0].nodeQuaternion)
	}
}

