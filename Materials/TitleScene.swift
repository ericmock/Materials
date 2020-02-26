//
//  TitleScene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/19/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation


class TitleScene: Scene {
    
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
    var integrator:TitleIntegrator?
    var initialState = stateStructure()
    var presentState = stateStructure()
    
    //    let title1 = Model(name: "Title1")
    let titles:[Model] = [Model(name: "Title1"),
                          Model(name: "Title2"),
                          Model(name: "Title3"),
                          Model(name: "Title4"),
                          Model(name: "Title5"),
                          Model(name: "Title1")]
    
    override init(screenSize: CGSize, sceneName: String) {
        super.init(screenSize: screenSize, sceneName: sceneName)
        integrator = TitleIntegrator(scene: self)
        //       super.init(screenSize: s, sceneName: <#T##String#>)
    }
    
    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 4
        camera.rotation = [-0.4, -0.4, 0]
        //        add(node: title1)
        //        title1.scaleV.y = 1.0/5.0
        //        title1.position.x = 0.0
        //        title1.position.y = 2.0
        //        title1.position.z = 1.0
        
        dT = 0.0
        timeSinceStart = 0.0
        timeAtStart = Date()
        previousTime = Date()
        
        for ii in 0..<titles.count {
            add(node: titles[ii])
            titles[ii].scaleV.y = 0.2
            titles[ii].position.x = 0.0
            titles[ii].position.y =  2.0 - Float(ii)/5.0
            titles[ii].initialScaleV.y = 1.0
            titles[ii].initialPosition.x = 0.0
            titles[ii].initialPosition.y = 2.0 - Float(ii)/2.0
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
    
    override func updateScene(deltaTime: Float) {
        //        time += deltaTime
        if camera.speed != 0.0 {
            camera.rotate(delta: SIMD2<Float>(Float(camera.velocity.x) * deltaTime, Float(camera.velocity.y) * deltaTime))
            camera.velocity = CGPoint(x:0.99 * camera.velocity.x, y:0.99 * camera.velocity.y)
        }
    }
    
    func updateNodePositions(deltaTime: Float) {
        //        print("initialState= ",initialState)
        integrator?.integrate(with: TimeInterval(deltaTime))
        presentState = integrator!.state
        initialState = presentState
        //        print("presentState = ",presentState)
        for (ii, title) in titles.enumerated() {
            let rotation = SIMD3<Float>(-presentState.theta[ii], 0.0, 0.0)
            let transformMatrix = float4x4(rotateAboutXYZBy: rotation, aboutPoint: [0, -title.initialPosition.y - title.scaleV.y, 0])
            let initialPosition = SIMD4<Float>(title.initialPosition.x, title.initialPosition.y, title.initialPosition.z, 1.0)
            title.rotation.x = 3.14 - presentState.theta[ii]
            title.position = (transformMatrix * initialPosition).xyz
            //            tit4ule.position.y += title.initialPosition.y
        }
    }
    
    override func update(deltaTime: Float) {
        updateTime()
        updateNodePositions(deltaTime: deltaTime)
        updateScene(deltaTime: deltaTime)
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        
        fragmentUniforms.cameraPosition = camera.position
    }
    
}
