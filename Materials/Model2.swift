//
//  Model.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/11/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

class Model2: Node2 {
    
 //   var bufferProvider:BufferProvider

    let meshes: [Mesh2]
    var hasTangents: Bool = false
    var texture:MTLTexture?
    
    init(name: String, findTangents: Bool = false) {
//        self.texture = texture
        let assetURL = Bundle.main.url(forResource: name, withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor(hasTangent: findTangents)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
        
        asset.loadTextures()
        
        if findTangents {
            for sourceMesh in asset.childObjects(of: MDLMesh.self) as! [MDLMesh] {
                sourceMesh.addOrthTanBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                           normalAttributeNamed: MDLVertexAttributeNormal,
                                           tangentAttributeNamed: MDLVertexAttributeTangent)
                sourceMesh.vertexDescriptor = vertexDescriptor
            }
            self.hasTangents = true
        }
        
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh2(mdlMesh: $0.0, mtkMesh: $0.1, findTangents: findTangents)
        }
        
//        self.bufferProvider = BufferProvider(device: Renderer.device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<float4x4>.size * 2)
        let texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
//        texture.loadTexture(device: Renderer.device, commandQ: commandQ, flip: true)
        

        super.init()

        self.name = name
        
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh2) {
        let mtkSubmesh = submesh.mtkSubmesh
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: mtkSubmesh.indexCount,
                                             indexType: mtkSubmesh.indexType,
                                             indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                             indexBufferOffset: mtkSubmesh.indexBuffer.offset)
    }
    
}

extension Model2: Renderable {
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
