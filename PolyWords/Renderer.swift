import MetalKit

class Renderer: NSObject {
	static var device: MTLDevice!
	var commandQueue: MTLCommandQueue!
	static var library: MTLLibrary!
	var samplerState:MTLSamplerState?
	weak var scene:Scene?
	let depthStencilState: MTLDepthStencilState
		
	init(view: MTKView) {
		guard
			let device = MTLCreateSystemDefaultDevice(),
			let commandQueue = device.makeCommandQueue() else {
				fatalError("GPU not available")
		}
		Renderer.device = device
		self.commandQueue = commandQueue
		Renderer.library = device.makeDefaultLibrary()  // Done in buildPipelineState() in MeshGeneration project
		// Move    Renderer.colorPixelFormat = metalView.colorPixelFormat
		view.device = device
		view.depthStencilPixelFormat = .depth32Float
		
		depthStencilState = Renderer.buildDepthStencilState()!
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
	
	static func buildDepthStencilState() -> MTLDepthStencilState? {
		let descriptor = MTLDepthStencilDescriptor()
		descriptor.depthCompareFunction = .less
		descriptor.isDepthWriteEnabled = true
		return
			Renderer.device.makeDepthStencilState(descriptor: descriptor)
	}
}

extension Renderer: MTKViewDelegate {
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		scene?.sceneSizeWillChange(to: size)
//Move		camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
	}
	
	func draw(in view: MTKView) {
		guard
			let drawable = view.currentDrawable,
			let descriptor = view.currentRenderPassDescriptor,
			let commandBuffer = commandQueue.makeCommandBuffer(),
			let scene = scene,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
			else {
				return
		}
		
		renderEncoder.setDepthStencilState(depthStencilState)

		var lights = scene.lighting.lights
    renderEncoder.setFragmentBytes(&lights,
                                   length: MemoryLayout<Light>.stride * lights.count,
                                   index: Int(lightsBufferIndex.rawValue))

		let deltaTime = 1/Float(view.preferredFramesPerSecond)
		scene.update(deltaTime: deltaTime)

		for renderable in scene.renderables {
			renderEncoder.pushDebugGroup(renderable.name)
			renderable.render(commandEncoder: renderEncoder,
												uniforms: scene.uniforms,
												fragmentUniforms: scene.fragmentUniforms)
			renderEncoder.popDebugGroup()
		}
		
		renderEncoder.endEncoding()
		
		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
}
