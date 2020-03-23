import MetalKit

class Renderer: NSObject {
	static var device: MTLDevice!
	var commandQueue: MTLCommandQueue!
	static var library: MTLLibrary!
	var samplerState:MTLSamplerState?
	weak var scene:Scene?
	let depthStencilState: MTLDepthStencilState
	
	
	/*  Move this to scene?
	static var colorPixelFormat: MTLPixelFormat!
	var uniforms = Uniforms()
	var fragmentUniforms = FragmentUniforms()
	let lighting = Lighting()
	
	lazy var camera: Camera = {
	let camera = ArcballCamera()
	camera.distance = 3
	camera.target = [0, 1, 0]
	camera.rotation.x = Float(-10).degreesToRadians
	return camera
	}()
	
	// Array of Models allows for rendering multiple models
	var models: [Model] = []
	*/
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
		
		/* Move to scene
		view.clearColor = MTLClearColor(red: 0.93, green: 0.97,
		blue: 1.0, alpha: 1)
		view.delegate = self
		mtkView(view, drawableSizeWillChange: view.bounds.size)
		
		// models
		let model = Model(name: "TestPolyhedron.obj")
		model.position = [0, 0, 0]
		models.append(model)
		
		fragmentUniforms.lightCount = lighting.count
		*/
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

		let deltaTime = 1/Float(view.preferredFramesPerSecond)
		scene.update(deltaTime: deltaTime)

/*  Everything here to Scene or Model
		uniforms.projectionMatrix = camera.projectionMatrix
		uniforms.viewMatrix = camera.viewMatrix
		fragmentUniforms.cameraPosition = camera.position
		
		var lights = lighting.lights
		renderEncoder.setFragmentBytes(&lights,
																	 length: MemoryLayout<Light>.stride * lights.count,
																	 index: Int(BufferIndexLights.rawValue))
		
		
		// render all the models in the array
		for model in models {
			
			// add tiling here
			fragmentUniforms.tiling = model.tiling
			renderEncoder.setFragmentBytes(&fragmentUniforms,
																		 length: MemoryLayout<FragmentUniforms>.stride,
																		 index: Int(BufferIndexFragmentUniforms.rawValue))
			
			renderEncoder.setFragmentSamplerState(model.samplerState, index: 0)
			
			uniforms.modelMatrix = model.modelMatrix
			uniforms.normalMatrix = uniforms.modelMatrix.upperLeft
			
			renderEncoder.setVertexBytes(&uniforms,
																	 length: MemoryLayout<Uniforms>.stride,
																	 index: Int(BufferIndexUniforms.rawValue))
			
			for mesh in model.meshes {
				
				// render multiple buffers
				// replace the following two lines
				// this only sends the MTLBuffer containing position, normal and UV
				for (index, vertexBuffer) in mesh.mtkMesh.vertexBuffers.enumerated() {
					renderEncoder.setVertexBuffer(vertexBuffer.buffer,
																				offset: 0, index: index)
				}
				
				for submesh in mesh.submeshes {
					renderEncoder.setRenderPipelineState(submesh.pipelineState)
					// textures
					renderEncoder.setFragmentTexture(submesh.textures.baseColor,
																					 index: Int(BaseColorTexture.rawValue))
					renderEncoder.setFragmentTexture(submesh.textures.normal,
																					 index: Int(NormalTexture.rawValue))
					renderEncoder.setFragmentTexture(submesh.textures.roughness,
																					 index: Int(RoughnessTexture.rawValue))
					renderEncoder.setFragmentTexture(submesh.textures.metallic,
																					 index: Int(MetallicTexture.rawValue))
					renderEncoder.setFragmentTexture(submesh.textures.ao,
																					 index: Int(AOTexture.rawValue))
					
					// set the materials here
					var material = submesh.material
					renderEncoder.setFragmentBytes(&material,
																				 length: MemoryLayout<Material>.stride,
																				 index: Int(BufferIndexMaterials.rawValue))
					
					let mtkSubmesh = submesh.mtkSubmesh
					renderEncoder.drawIndexedPrimitives(type: .triangle,
																							indexCount: mtkSubmesh.indexCount,
																							indexType: mtkSubmesh.indexType,
																							indexBuffer: mtkSubmesh.indexBuffer.buffer,
																							indexBufferOffset: mtkSubmesh.indexBuffer.offset)
				}
			}
		}
		
		renderEncoder.endEncoding()
		guard let drawable = view.currentDrawable else {
			return
		}
*/
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
