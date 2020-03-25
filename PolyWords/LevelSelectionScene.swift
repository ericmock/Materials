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
	let appController:AppController
	let touchAngles:[Float] = []
	let touchTimes:[Float] = []
	var lockedPolyhedronInfo:Dictionary<String,Any>
	
	init(screenSize: CGSize, sceneName: String, appController: AppController) {
		self.appController = appController
		lockedPolyhedronInfo = ["name": "Locked",
														"polyID": 0,
														"completed": [1, 1, 1, 1],
														"level": 0
		]
		super.init(screenSize: screenSize, sceneName: sceneName)
		gTrackBallRotation[1] = 1.0
		worldRotation[1] = 1.0
	}

//	MARK:  Methods
	override func setupScene() {
	}
	
	override func updateScene(deltaTime: Float) {
	}
		
	override func update(deltaTime: Float) {
	}
	
}
