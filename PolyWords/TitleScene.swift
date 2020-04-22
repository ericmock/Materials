//
//  TitleScene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import CoreGraphics


class TitleScene: Scene {
//	MARK:  Instance variables
	let quadVertices:[SIMD4<Float>] = [
		SIMD4<Float>(1.0, 1.0, 0, 1),
		SIMD4<Float>(1.0, -1.0, 0, 1),
		SIMD4<Float>(-1.0, -1.0, 0, 1),
		SIMD4<Float>(1.0, 1.0, 0, 1),
		SIMD4<Float>(-1.0, -1.0, 0, 1),
		SIMD4<Float>(-1.0, 1.0, 0, 1)
	]
	
	let quadUV:[SIMD2<Float>] = [
		SIMD2<Float>(1.0,1.0),
		SIMD2<Float>(1.0,0.0),
		SIMD2<Float>(0.0,0.0),
		SIMD2<Float>(1.0,1.0),
		SIMD2<Float>(0.0,0.0),
		SIMD2<Float>(0.0,1.0)
	]
	
	var creationTime = Date()
	var timeAtStart = Date()
	var timeSinceStart: TimeInterval = 0.0
	var previousTime = Date()
	var dT:TimeInterval = 0.0
	var integrator:Integrator?
	var initialState:stateStructure?
	var presentState:stateStructure?
	//    let title1 = Model(name: "Title1")
	
	override init(screenSize: CGSize, sceneName: String) {
		super.init(screenSize: screenSize, sceneName: sceneName)
		models = [PolygonModel(withPolygon: Apolygon(withType: 1), inScene: self),
							PolygonModel(withPolygon: Apolygon(withType: 1), inScene: self),
							PolygonModel(withPolygon: Apolygon(withType: 1), inScene: self),
							PolygonModel(withPolygon: Apolygon(withType: 1), inScene: self),
							PolygonModel(withPolygon: Apolygon(withType: 1), inScene: self),
							PolygonModel(withPolygon: Apolygon(withType: 1), inScene: self)]
		integrator = Integrator(withScene: self, withDOFs: models.count, withInitialState: stateStructure(withDOFs: models.count), withForceFunction: {(coords, vels, time) in print(time)})
		setupScene()

	}

//	MARK:  Methods
	override func setupScene() {
		camera.target = [0, 0.8, 0]
		camera.distance = 4
//		camera.nodeRotation = [-0.4, -0.4, 0]
		//        add(node: title1)
		//        title1.scaleV.y = 1.0/5.0
		//        title1.position.x = 0.0
		//        title1.position.y = 2.0
		//        title1.position.z = 1.0
		
		dT = 0.0
		timeSinceStart = 0.0
		timeAtStart = Date()
		previousTime = Date()
		
		for ii in 0..<models.count {
			add(node: models[ii])
			models[ii].nodeScaleV.y = 0.2
			models[ii].nodePosition.x = 0.0
			models[ii].nodePosition.y =  2.0 - Float(ii)/5.0
			models[ii].nodeInitialScaleV.y = 1.0
			models[ii].nodeInitialPosition.x = 0.0
			models[ii].nodeInitialPosition.y = 2.0 - Float(ii)/2.0
		}
		
		//        titles[0].scaleV = [1.0, 0.2, 1.0]
		//        titles[0].position = [0.0, 0.8, 0.0]
		//        titles[0].initialPosition = titles[0].position
		
		creationTime = Date()
		
		integrator?.resetState()
	}
	
	func updateTime() {
		dT = Date().timeIntervalSince(previousTime)
		if dT > 1.0/5.0 {
			dT = 0.0
		}
		//print("dT = ",dT)
		timeSinceStart = Date().timeIntervalSince(creationTime)
		previousTime = Date()
	}
	
//	override func updateScene(deltaTime: Float) {
//		//        time += deltaTime
//		if camera.speed != 0.0 {
//			camera.rotate(delta: float3(Float(camera.velocity.x) * deltaTime, Float(camera.velocity.y) * deltaTime, 0))
//			camera.velocity = CGPoint(x:0.99 * camera.velocity.x, y:0.99 * camera.velocity.y)
//		}
//	}
	
	func updateNodePositions(deltaTime: Double) {
		//        print("initialState= ",initialState)
		integrator?.integrate(with: deltaTime)
		presentState = integrator!.state
		initialState = presentState
		//        print("presentState = ",presentState)
		for (ii, title) in models.enumerated() {
			let rotation = SIMD3<Float>(-presentState!.theta[ii], 0.0, 0.0)
			let transformMatrix = float4x4(rotateAboutXYZBy: rotation, aboutPoint: [0, -title.nodeInitialPosition.y - title.nodeScaleV.y, 0])
			let initialPosition = SIMD4<Float>(title.nodeInitialPosition.x, title.nodeInitialPosition.y, title.nodeInitialPosition.z, 1.0)
//			title.nodeRotation.x = 3.14 - presentState.theta[ii]
			title.nodePosition = (transformMatrix * initialPosition).xyz
			//            tit4ule.position.y += title.initialPosition.y
		}
	}
	
	override func update(deltaTime: Double) {
		updateTime()
		updateNodePositions(deltaTime: deltaTime)
		updateScene(deltaTime: deltaTime)
		uniforms.viewMatrix = camera.viewMatrix
		uniforms.projectionMatrix = camera.projectionMatrix
		uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
		fragmentUniforms.cameraPosition = camera.nodePosition
	}
	
}
