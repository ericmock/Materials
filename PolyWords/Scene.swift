//
//  Scene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//
#if !os(iOS)
import Cocoa
#endif
import Foundation
import CoreGraphics
import MetalKit

enum InputMode {
	case rotate
	case select
}


class Scene {
	var rootNode = Node()
	var renderables: [Renderable] = []
	
	var screenSize: CGSize
	
	static var colorPixelFormat: MTLPixelFormat!
	var uniforms = Uniforms()
	var fragmentUniforms = FragmentUniforms()
	let lighting = Lighting()
	
	lazy var camera: ArcballCamera = {
		let camera = ArcballCamera()
		camera.distance = 3
		camera.target = [0, 1, 0]
		camera.rotation.x = Float(-10).degreesToRadians
		return camera
	}()
	
	var models: [Model] = []
	
	let trackball = Trackball()
	var gTrackBallRotation:SIMD4<Float> = [0, 0, 0, 0]
	var rotationAngles:SIMD4<Float> = [0, 0, 0, 0]
	var worldRotationAngles:SIMD4<Float> = [0, 0, 0, 0]
	var worldRotation:SIMD4<Float> = [0, 0, 0, 0]
	
	private var startPoint:CGPoint = .zero
	private var lastPoint:CGPoint = .zero
	private var startTime:Float = 0
	var checked = false
	var inputMode = InputMode.select
	var initialTouchPosition:CGPoint = .zero
	var currentTouchPosition:CGPoint = .zero
	var previousTouchPosition:CGPoint = .zero
	var previousTouchNumber:Int = 0
	var touchedPolygon:Int = 0
	
	var dragTimer:Timer = Timer()
	var previouslyTouchedNumber: Int = 0
	var touchedNumber: Int = 0
	
	var accelz:Float = 0.0
	var accely:Float = 0.0
	
	var sceneTextures:[String] = []
	
	init(screenSize: CGSize, sceneName: String) {
		self.screenSize = screenSize
		fragmentUniforms.lightCount = lighting.count
		print("number of lights: \(lighting.count)")
		setupScene()
	}
	
	func updateScene(deltaTime: Float) {
		if camera.speed != 0.0 {
			camera.rotate(delta: float3(Float(camera.velocity.x) * deltaTime, Float(camera.velocity.y) * deltaTime, 0))
			camera.velocity = CGPoint(x:0.99 * camera.velocity.x, y:0.99 * camera.velocity.y)
		}
	}
	
	func update(deltaTime: Float) {
		updateScene(deltaTime: deltaTime)
		uniforms.viewMatrix = camera.viewMatrix
		uniforms.projectionMatrix = camera.projectionMatrix
		uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
		fragmentUniforms.cameraPosition = camera.position
	}
	
	final func add(node: Node, parent: Node? = nil, renderQ: Bool = true) {
		if let parent = parent {
			parent.add(childNode: node)
		} else {
			rootNode.add(childNode: node)
		}
		
		guard let renderable = node as? Renderable else { return }
		if renderQ {
			renderables.append(renderable)
		}
	}
	
	final func remove(node: Node) {
		if let parent = node.parent {
			parent.remove(childNode: node)
		} else {
			for child in node.children {
				child.parent = nil
			}
			node.children = []
		}
		
		if node is Renderable,
			let index = renderables.firstIndex(where: { $0 as? Node === node }) {
			renderables.remove(at: index)
		}
	}
	
	func setupScene() {
		//override
	}
	
	func sceneSizeWillChange(to size: CGSize) {
		camera.aspect = Float(size.width / size.height)
		screenSize = size
	}
	
	@objc func checkDrag(timer: Timer) {
		//Override if needed
	}
	
	func findTouchedPolygon(atPoint touchPos: CGPoint) -> Int {
		//Override if needed
		return 0
	}
	
	
}
