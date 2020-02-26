import MetalKit

class Submesh {
  var mtkSubmesh: MTKSubmesh
  
  struct Textures {
    let baseColor: MTLTexture?
    let normal: MTLTexture?
    let roughness: MTLTexture?
    let metallic: MTLTexture?
    let ao: MTLTexture?
  }
  
  let textures: Textures
  let material: Material
	let hasTangents: Bool
  let pipelineState: MTLRenderPipelineState
  
	init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh, findTangents:  Bool) {
		self.hasTangents = findTangents
    self.mtkSubmesh = mtkSubmesh
    textures = Textures(material: mdlSubmesh.material)
    material = Material(material: mdlSubmesh.material)
		pipelineState = Submesh.makePipelineState(textures: textures, hasTangents: hasTangents)
  }
}

// Pipeline state
private extension Submesh {
	static func makeFunctionConstants(textures: Textures)
    -> MTLFunctionConstantValues {
      let functionConstants = MTLFunctionConstantValues()
      var property = textures.baseColor != nil
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

	static func makePipelineState(textures: Textures, hasTangents: Bool) -> MTLRenderPipelineState {
    let functionConstants = makeFunctionConstants(textures: textures)
    
    let library = Renderer.library
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction: MTLFunction?
    do {
      fragmentFunction = try library?.makeFunction(name: "fragment_mainPBR",
                                                   constantValues: functionConstants)
    } catch {
      fatalError("No Metal function exists")
    }
    
    var pipelineState: MTLRenderPipelineState
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    
//    let vertexDescriptor = Model.vertexDescriptor
		pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor(hasTangents: hasTangents)
//    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
		pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    do {
      pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return pipelineState
  }
}


extension Submesh: Texturable {}

private extension Submesh.Textures {
  init(material: MDLMaterial?) {
    func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
      guard let property = material?.property(with: semantic),
        property.type == .string,
        let filename = property.stringValue,
        let texture = try? Submesh.loadTexture(imageName: filename)
        else {
          if let property = material?.property(with: semantic),
            property.type == .texture,
            let mdlTexture = property.textureSamplerValue?.texture {
            return try? Submesh.loadTexture(texture: mdlTexture)
          }
          return nil
      }
      return texture
    }
    baseColor = property(with: MDLMaterialSemantic.baseColor)
    normal = property(with: .tangentSpaceNormal)
    roughness = property(with: .roughness)
    metallic = property(with: .metallic)
    ao = property(with: .ambientOcclusion)
  }
}

private extension Material {
  init(material: MDLMaterial?) {
    self.init()
    if let baseColor = material?.property(with: .baseColor),
      baseColor.type == .float3 {
      self.baseColor = baseColor.float3Value
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

