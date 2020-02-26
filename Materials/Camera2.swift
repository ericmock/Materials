//
//  Camera.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/11/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

class Camera2: Node2 {
    var fov = radians(fromDegrees: 60)
    var near: Float = 0.01
    var far: Float = 100
    var aspect: Float = 1
    
    private var startPoint: CGPoint = .zero
    private var lastPoint: CGPoint = .zero
    private var startTime: Float = 0
    private var checked = false
    private var dragging = false
    private var initialTouchPosition: CGPoint = .zero
    private var currentTouchPosition: CGPoint = .zero
    var dragTimer: Timer = Timer()
    var oldText: String = ""
    var polyhedron: Polyhedron!
    
    var previouslyTouchedNumber: Int = 0
    var touchedNumber: Int = 0
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translateBy: position)
        let rotateMatrix = float4x4(rotateAboutXYZBy: rotation)
        let scaleMatrix = float4x4(scaleBy: scaleV)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }
    
    func zoom(delta:Float) {}
    func rotate(delta: SIMD2<Float>) {}
    
}

class ArcballCamera2: Camera2 {
    
    var minDistance: Float = 0.5
    var maxDistance: Float = 10
    var velocity = CGPoint(x: 0.0,y: 0.0)
    var speed: CGFloat = 0.0
    private var _viewMatrix = float4x4.identity()

    var distance: Float = 0 {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    var target = SIMD3<Float>(repeating:0) {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    
    override func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        distance -= delta * sensitivity
        _viewMatrix = updateViewMatrix()
    }
    
    override var viewMatrix: float4x4 {
        return _viewMatrix
    }
    

    override init() {
        super.init()
        _viewMatrix = updateViewMatrix()
    }
    
    private func updateViewMatrix() -> float4x4 {
        let translateMatrix = float4x4(translateBy: [target.x, target.y, target.z - distance])
        let rotateMatrix = float4x4(rotateAboutYXZBy: [-rotation.x,rotation.y,0])
        let matrix = (rotateMatrix * translateMatrix).inverse
        position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
        return matrix
    }
    
    override func rotate(delta: SIMD2<Float>) {
        let sensitivity: Float = 0.005
        rotation.y += delta.x * sensitivity
        rotation.x += delta.y * sensitivity
        rotation.x = max(-Float.pi/2,
                         min(rotation.x,
                             Float.pi/2))
        _viewMatrix = updateViewMatrix()
    }
    
}

