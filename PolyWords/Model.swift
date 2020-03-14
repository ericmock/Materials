import MetalKit

class Model: Node {
	
	let meshes:[Mesh]
	var tiling:UInt32 = 1
	var hasTangents:Bool = false
	
	//  let samplerState: MTLSamplerState?
	var vertexDescriptor:MDLVertexDescriptor
	
//	init(withVertices vertices:[SIMD3<Float>], indices:[Int], normals:[SIMD3<Float>], tangents:[SIMD3<Float>], bitangents:[SIMD3<Float>], textureVertices:[SIMD2<Float>]) {
//		// need to bundle this all up in a single buffer and then tell GPU the layout
//		let numVertices = vertices.count
//		var bufferSize = 0
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex positions
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex normals
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex tangents
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex bitangents
//		bufferSize += MemoryLayout<SIMD2<Float>>.stride * numVertices // texture coordinates
//
//		vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor(hasTangents: true)
//
//		
//	}
	
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
		
//		if findTangents {
//			for sourceMesh in asset.childObjects(of: MDLMesh.self) as! [MDLMesh] {
//				sourceMesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
//																	 normalAttributeNamed: MDLVertexAttributeNormal,
//																	 tangentAttributeNamed: MDLVertexAttributeTangent)
//				sourceMesh.vertexDescriptor = vertexDescriptor
//			}
//			self.hasTangents = true
//		}
		
		// load Model I/O textures
		asset.loadTextures()
		
//		var mtkMeshes: [MTKMesh] = []
//		let mdlMeshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
//		if findTangents {
//			_ = mdlMeshes.map { mdlMesh in
//				mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
//					MDLVertexAttributeTextureCoordinate,
//																tangentAttributeNamed: MDLVertexAttributeTangent,
//																bitangentAttributeNamed: MDLVertexAttributeBitangent)
//				//      Model.vertexDescriptor = mdlMesh.vertexDescriptor
//				mtkMeshes.append(try! MTKMesh(mesh: mdlMesh, device: Renderer.device))
//			}
//			self.hasTangents = true
//		}
		
		let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)

		_ = mdlMeshes.map { mdlMesh in
			mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed:
				MDLVertexAttributeTextureCoordinate,
															tangentAttributeNamed: MDLVertexAttributeTangent,
															bitangentAttributeNamed: MDLVertexAttributeBitangent)
		}
		
		let zippedMeshes = zip(mdlMeshes, mtkMeshes)
		
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
																	index: Int(uniformsBufferIndex.rawValue))
		commandEncoder.setFragmentBytes(&fragmentUniforms,
																		length: MemoryLayout<FragmentUniforms>.stride,
																		index: Int(fragmentUniformsBufferIndex.rawValue))
		
		for mesh in meshes {
			for vertexBuffer in mesh.mtkMesh.vertexBuffers {
				
//				let uniformBuffer = Renderer.bufferProvider.nextUniformsBuffer(projectionMatrix: uniforms.projectionMatrix, modelViewMatrix: uniforms.modelMatrix)
				// 5
//				commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
				
				
				commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
				
				for submesh in mesh.submeshes {
					commandEncoder.setRenderPipelineState(submesh.pipelineState)
					var material = submesh.material
					commandEncoder.setFragmentBytes(&material,
																					length: MemoryLayout<Material>.stride,
																					index: Int(materialsBufferIndex.rawValue))
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
