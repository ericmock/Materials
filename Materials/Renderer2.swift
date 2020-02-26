//
//  Renderer.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/10/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

//struct Vertex {
//    let position: SIMD3<Float>
//    let color: SIMD3<Float>
//}

class Renderer2: NSObject {
    static var device:MTLDevice!
    let commandQueue:MTLCommandQueue

    //static var bufferProvider:BufferProvider!
    var samplerState:MTLSamplerState?

    static var library:MTLLibrary!

    let depthStencilState:MTLDepthStencilState
        
    weak var scene:Scene?
//    weak var titleScene: TitleScene?
//    let camera = ArcballCamera()
    
//    var uniforms = Uniforms()
//    var fragmentUniforms = FragmentUniforms()
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        
        view.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer2.createDepthState()

//        camera.target = [0, 0.8, 0]
//        camera.distance = 3
//        Renderer.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<float4x4>.size * 2)

        super.init()

        samplerState = defaultSampler(device: device)
    }
    
    func defaultSampler(device: MTLDevice) -> MTLSamplerState {
      let sampler = MTLSamplerDescriptor()
      sampler.minFilter             = MTLSamplerMinMagFilter.nearest
      sampler.magFilter             = MTLSamplerMinMagFilter.nearest
      sampler.mipFilter             = MTLSamplerMipFilter.nearest
      sampler.maxAnisotropy         = 1
      sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
      sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
      sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
      sampler.normalizedCoordinates = true
      sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = .greatestFiniteMagnitude
        return device.makeSamplerState(descriptor: sampler)!
    }

    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
    
}

extension Renderer2: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene?.sceneSizeWillChange(to: size)
//        titleScene?.sceneSizeWillChange(to: size)
    }
    
    func draw(in view: MTKView) {
//        _ = Renderer.bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)

        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let scene = scene else {
                return
        }
        
//        commandBuffer.addCompletedHandler { (_) in Renderer.self.bufferProvider.avaliableResourcesSemaphore.signal()}

        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setDepthStencilState(depthStencilState)
        
        let deltaTime = 1/Float(view.preferredFramesPerSecond)
        scene.update(deltaTime: deltaTime)

        for renderable in scene.renderables {
            commandEncoder.pushDebugGroup(renderable.name)
            renderable.render(commandEncoder: commandEncoder,
                              uniforms: scene.uniforms,
                              fragmentUniforms: scene.fragmentUniforms)
            commandEncoder.popDebugGroup()
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
