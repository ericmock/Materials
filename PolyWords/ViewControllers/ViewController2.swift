//
//  ViewController.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/10/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

#if !os(iOS)
import Cocoa
#endif
import MetalKit

class ViewController2: NSViewController {
    
    @IBOutlet var metalView: MTKView!
    var renderer:Renderer?
    var gameScene:GameScene?
    var titleScene:TitleScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = Renderer(view: metalView)
        metalView.device = Renderer.device
        metalView.delegate = renderer
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        titleScene = TitleScene(screenSize: metalView.bounds.size, sceneName:"Title")
        gameScene = GameScene(screenSize: metalView.bounds.size, sceneName:"Title")
        renderer?.scene = gameScene
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delaysPrimaryMouseButtonEvents = false
        view.addGestureRecognizer(pan)
    }
    
    override func mouseDown(with event: NSEvent) {
        titleScene?.camera.speed = 0.0
        titleScene?.interactionsBegan(with: event, inView: self)
    }
    
    override func scrollWheel(with event: NSEvent) {
        titleScene?.camera.zoom(delta: Float(event.deltaY))
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        let delta = SIMD2<Float>(Float(translation.x),
                                 Float(translation.y))
        titleScene?.camera.speed = 0.0
        titleScene?.camera.rotate(delta: delta)
        titleScene?.camera.velocity = velocity
        titleScene?.camera.speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.x)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
}

