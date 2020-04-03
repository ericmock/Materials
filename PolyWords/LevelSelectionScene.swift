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
	let touchAngles:[Float] = []
	let touchTimes:[Float] = []
	var lockedPolyhedronInfo:Dictionary<String,Any>
	
	override init(screenSize: CGSize, sceneName: String) {
		lockedPolyhedronInfo = ["name": "Locked",
														"polyID": 0,
														"completed": [1, 1, 1, 1],
														"level": 0
		]
		super.init(screenSize: screenSize, sceneName: sceneName)
//		gTrackBallRotation[1] = 1.0
		worldRotation_toLevelSelectionScene[1] = 1.0
	}

//	MARK:  Methods
	override func setupScene() {
		camera.target = [0, 0.8, 0]
		camera.distance = 3
		camera.nodeQuaternion = simd_quatf()
		
		let polyhedraInfo = AppController.initializePolyhedronInfo()
		for (num,polyhedronInfo) in polyhedraInfo.enumerated() {
			if (polyhedronInfo["level"] as! Int) < 6 {
				let polyhedron = Polyhedron(name: polyhedronInfo["name"] as! String, withPolyID: polyhedronInfo["polyID"] as! Int, scene: self)
				polyhedron.nodeQuaternion = simd_quatf(angle: radians(fromDegrees: Float.random(in: -180..<180)), axis: float3(0,1,0))
				polyhedron.nodePosition.x = 0
				polyhedron.nodePosition.y = 1.5 * cos(2.0 * Float(num)/6.0 * .pi)
				polyhedron.nodePosition.z = 1.5 * sin(2.0 * Float(num)/6.0 * .pi)
				polyhedron.nodeScaleV = float3(1.0/5.0, 1.0/5.0, 1.0/5.0)
				add(node: polyhedron)
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
		var levelRotation = worldRotation_toLevelSelectionScene
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

}
