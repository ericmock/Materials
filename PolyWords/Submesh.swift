import MetalKit

class Submesh {
	//	var color:float4 = [1,0,0,1]
	let indexBuffer: MTLBuffer
	//	let letterBuffer: MTLBuffer
	let indexCount: Int
	//	let letterCount: Int
	let indexType: MTLIndexType
	
	struct Textures {
		var baseColor: MTLTexture?
		var normal: MTLTexture?
		var roughness: MTLTexture?
		var metallic: MTLTexture?
		var ao: MTLTexture?
		var letters: MTLTexture?
	}
	
	let textures: Textures
	//  let material: Material
	let pipelineState: MTLRenderPipelineState
	let polygonPipelineState: MTLRenderPipelineState!
	
	init(indexBuffer buffer:MTLBuffer,
			 indexCount count:Int,
			 indexType type:MTLIndexType,
			 baseColor:float4,
			 scene:Scene) {
		indexBuffer = buffer
		indexCount = count
		indexType = type
		//		color = baseColor
		let textureDict:Dictionary<TextureSemantics,String> = [.baseColor:"TestPolyhedron-color", .tangentSpaceNormal:"TestPolyhedron-normal", .roughness: "TestPolyhedron-roughness", .letters: "Alphabet"]
		var texturesToLoad:Dictionary<TextureSemantics,String> = Dictionary()//= [.baseColor:"", .tangentSpaceNormal:"", .roughness:"", .letters:""]
		for (textureSemantic,name) in textureDict {
			if !scene.sceneTextures.contains(name) {
				scene.sceneTextures.append(name)
				texturesToLoad.merge([textureSemantic:name]) { (_, new) in new }
//				texturesToLoad.updateValue(name, forKey: textureSemantic)
			}
		}
		textures = Textures(textures: texturesToLoad)
		pipelineState = Submesh.makePipelineState(textures: textures, forModelType: 0)
		polygonPipelineState = Submesh.makePipelineState(textures: textures, forModelType: 1)
	}
}

// Pipeline state
private extension Submesh {
	static func makeFunctionConstants(textures: Textures)
		-> MTLFunctionConstantValues {
			let functionConstants = MTLFunctionConstantValues()
			var property = (textures.baseColor != nil)
			functionConstants.setConstantValue(&property, type: .bool, index: 0)
			property = textures.normal != nil
			functionConstants.setConstantValue(&property, type: .bool, index: 1)
			property = textures.roughness != nil
			functionConstants.setConstantValue(&property, type: .bool, index: 2)
			property = textures.metallic != nil
			functionConstants.setConstantValue(&property, type: .bool, index: 3)
			property = textures.ao != nil
			functionConstants.setConstantValue(&property, type: .bool, index: 4)
			return functionConstants
	}
	
	static func makePipelineState(textures: Textures, forModelType modelType: Int) -> MTLRenderPipelineState {
		let functionConstants = makeFunctionConstants(textures: textures)
		
		let library = Renderer.library
		let vertexFunction = library?.makeFunction(name: "vertex_main")
		
		var pipelineState: MTLRenderPipelineState
		let pipelineDescriptor = MTLRenderPipelineDescriptor()

		if modelType == 0 {
			let fragmentFunction: MTLFunction?
			do {
				fragmentFunction = try library?.makeFunction(name: "fragment_main",
																										 constantValues: functionConstants)
			} catch {
				fatalError("No Metal function exists")
			}
			pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
			pipelineDescriptor.vertexFunction = vertexFunction
			pipelineDescriptor.fragmentFunction = fragmentFunction
			
			pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
			do {
				pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
			} catch let error {
				fatalError(error.localizedDescription)
			}
			
		}
		else {
			let polygonFragmentFunction: MTLFunction?
			do {
				polygonFragmentFunction = try library?.makeFunction(name: "polygon_fragment_main",
																														constantValues: functionConstants)
			} catch {
				fatalError("No Metal function exists")
			}
			pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
			pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
			pipelineDescriptor.vertexFunction = vertexFunction
			pipelineDescriptor.fragmentFunction = polygonFragmentFunction
			
			pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
			do {
				pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
			} catch let error {
				fatalError(error.localizedDescription)
			}
			
		}
		
		
		return pipelineState
	}
}


extension Submesh: Texturable {}

private extension Submesh.Textures {
	init(textures:Dictionary<TextureSemantics,String>) {
		for (semantic, filename) in textures {
			switch semantic {
			case .baseColor:
				guard let texture = try? Submesh.loadTexture(imageName: filename)
					else {
						break
				}
				baseColor = texture
				break
			case .tangentSpaceNormal:
				guard let texture = try? Submesh.loadTexture(imageName: filename)
					else {
						break
				}
				normal = texture
				break
			case .roughness:
				guard let texture = try? Submesh.loadTexture(imageName: filename)
					else {
						break
				}
				roughness = texture
				break
			case .metallic:
				guard let texture = try? Submesh.loadTexture(imageName: filename)
					else {
						break
				}
				metallic = texture
				break
			case .ao:
				guard let texture = try? Submesh.loadTexture(imageName: filename)
					else {
						break
				}
				ao = texture
				break
			case .letters:
				guard let texture = try? Submesh.loadTexture(imageName: filename)
					else {
						break
				}
				letters = texture
				break
			}
		}
	}
}

private extension Material {
	init(material: MDLMaterial?) {
		self.init()
		if let baseColor = material?.property(with: .baseColor),
			baseColor.type == .float4 {
			self.baseColor = baseColor.float4Value
		}
		if let specular = material?.property(with: .specular),
			specular.type == .float3 {
			self.specularColor = specular.float3Value
		}
		if let shininess = material?.property(with: .specularExponent),
			shininess.type == .float {
			self.shininess = shininess.floatValue
		}
		if let roughness = material?.property(with: .roughness),
			roughness.type == .float3 {
			self.roughness = roughness.floatValue
		}
	}
}

