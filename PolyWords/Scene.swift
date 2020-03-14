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

enum inputMode {
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
	
	// Array of Models allows for rendering multiple models
	var models: [Model] = []
	
//	let camera = ArcballCamera2()
	let trackball = Trackball()
	var gTrackBallRotation:SIMD4<Float> = [0, 0, 0, 0]
	var rotationAngles:SIMD4<Float> = [0, 0, 0, 0]
	var worldRotationAngles:SIMD4<Float> = [0, 0, 0, 0]
	var worldRotation:SIMD4<Float> = [0, 0, 0, 0]
//	var uniforms = Uniforms()
//	var fragmentUniforms = FragmentUniforms()
	
	private var startPoint:CGPoint = .zero
	private var lastPoint:CGPoint = .zero
	private var startTime:Float = 0
	var checked = false
	var dragging = false
	var mode = inputMode.select
	var initialTouchPosition:CGPoint = .zero
	var currentTouchPosition:CGPoint = .zero
	var previousTouchPosition:CGPoint = .zero
	var previousTouchNumber:Int = 0
	var touchedPolygon:Int = 0
	
	var dragTimer:Timer = Timer()
	var touchedLetters:String = ""
	var oldText:String = ""
	//    var viewController: ViewController!
	var thePolyhedron:Polyhedron!
	
	//    var renderer: Renderer!
	var alphabetArray:[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	var commonLettersArray:[String] = ["A", "E", "I", "O", "T", "N"]
	var uncommonLettersArray:[String] = ["J", "Q", "X", "Z"];
	
	var previouslyTouchedNumber: Int = 0
	var touchedNumber: Int = 0
	
	var words:[NSString] = [""]
	@objc var lookingUpWordsQ:Bool = false
	
	var accelz:Float = 0.0
	var accely:Float = 0.0
	
	
	init(screenSize: CGSize, sceneName: String) {
		self.screenSize = screenSize
		setupScene()
	}
	
	func updateScene(deltaTime: Float) {
		if camera.speed != 0.0 {
			camera.rotate(delta: SIMD2<Float>(Float(camera.velocity.x) * deltaTime, Float(camera.velocity.y) * deltaTime))
			camera.velocity = CGPoint(x:0.99 * camera.velocity.x, y:0.99 * camera.velocity.y)
		}
	}
	
	func update(deltaTime: Float) {
		updateScene(deltaTime: deltaTime)
		uniforms.viewMatrix = camera.viewMatrix
		uniforms.projectionMatrix = camera.projectionMatrix
		
		fragmentUniforms.cameraPosition = camera.position
	}
	
	final func add(node: Node, parent: Node? = nil, renderQ: Bool = true) {
//		if node.name == "TestPolyhedron" {
//			thePolyhedron = (node as! Polyhedron);
//		} else if node.name == "TitleQuad" {
//			
//		}
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
