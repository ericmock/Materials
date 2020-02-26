import MetalKit

class Model: Node {
	
	let meshes: [Mesh]
	var tiling: UInt32 = 1
	var hasTangents: Bool = false
	
	//  let samplerState: MTLSamplerState?
	var vertexDescriptor: MDLVertexDescriptor
	
	init(name: String, findTangents: Bool = false) {
		guard
			let assetUrl = Bundle.main.url(forResource: name, withExtension: "obj") else {
				fatalError("Model: \(name) not found")
		}
		let allocator = MTKMeshBufferAllocator(device: Renderer.device)
		
		vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor(hasTangents: findTangents)
		
		let asset = MDLAsset(url: assetUrl,
												 vertexDescriptor: vertexDescriptor,
												 bufferAllocator: allocator)
		
		if findTangents {
			for sourceMesh in asset.childObjects(of: MDLMesh.self) as! [MDLMesh] {
				sourceMesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
																	 normalAttributeNamed: MDLVertexAttributeNormal,
																	 tangentAttributeNamed: MDLVertexAttributeTangent)
				sourceMesh.vertexDescriptor = vertexDescriptor
			}
			self.hasTangents = true
		}
		
		// load Model I/O textures
		asset.loadTextures()
		
		var mtkMeshes: [MTKMesh] = []
		let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
		_ = mdlMeshes.map { mdlMesh in
			mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
				MDLVertexAttributeTextureCoordinate,
															tangentAttributeNamed: MDLVertexAttributeTangent,
															bitangentAttributeNamed: MDLVertexAttributeBitangent)
			//      Model.vertexDescriptor = mdlMesh.vertexDescriptor
			mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: Renderer.device))
		}
		
		meshes = zip(mdlMeshes, mtkMeshes).map {
			Mesh(mdlMesh: $0.0, mtkMesh: $0.1, findTangents: findTangents)
		}
		super.init()
		self.samplerState = Model.buildSamplerState()
		self.name = name
	}
	
	
	// the normal vectors should be in the first buffer
	func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
		let mtkSubmesh = submesh.mtkSubmesh
		commandEncoder.drawIndexedPrimitives(type: .triangle,
																				 indexCount: mtkSubmesh.indexCount,
																				 indexType: mtkSubmesh.indexType,
																				 indexBuffer: mtkSubmesh.indexBuffer.buffer,
																				 indexBufferOffset: mtkSubmesh.indexBuffer.offset)
	}
	
	private static func buildSamplerState() -> MTLSamplerState? {
		let descriptor = MTLSamplerDescriptor()
		descriptor.sAddressMode = .repeat
		descriptor.tAddressMode = .repeat
		descriptor.mipFilter = .linear
		descriptor.maxAnisotropy = 8
		let samplerState =
			Renderer.device.makeSamplerState(descriptor: descriptor)
		return samplerState
	}
}



extension Model: Renderable {
	func render(commandEncoder: MTLRenderCommandEncoder,
							uniforms vertex: Uniforms,
							fragmentUniforms fragment: FragmentUniforms) {
		
		
		var uniforms = vertex
		var fragmentUniforms = fragment
		
		uniforms.modelMatrix = worldMatrix
		commandEncoder.setVertexBytes(&uniforms,
																	length: MemoryLayout<Uniforms>.stride,
																	index: 21)
		commandEncoder.setFragmentBytes(&fragmentUniforms,
																		length: MemoryLayout<FragmentUniforms>.stride,
																		index: 22)
		
		for mesh in meshes {
			for vertexBuffer in mesh.mtkMesh.vertexBuffers {
				
				//                let uniformBuffer = Renderer.bufferProvider.nextUniformsBuffer(projectionMatrix: uniforms.projectionMatrix, modelViewMatrix: uniforms.modelMatrix)
				// 5
				//commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
				
				
				commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
				
				for submesh in mesh.submeshes {
					commandEncoder.setRenderPipelineState(submesh.pipelineState)
					var material = submesh.material
					//                    commandEncoder.setFragmentBytes(&material,
					//                                                    length: MemoryLayout<Material>.stride,
					//                                                    index: 11)
					commandEncoder.setFragmentTexture(submesh.textures.baseColor, index: 0)
					
					if let samplerState = samplerState {
						commandEncoder.setFragmentSamplerState(samplerState, index: 0)
					}
					
					//          let mtkSubmesh = submesh.mtkSubmesh
					
					commandEncoder.setRenderPipelineState(submesh.pipelineState)
					
					render(commandEncoder: commandEncoder, submesh: submesh)
				}
			}
		}
		
	}
}
