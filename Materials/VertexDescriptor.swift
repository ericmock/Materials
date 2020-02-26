import Foundation
import MetalKit

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor(hasTangents: Bool = false) -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        var stride = 0
        var attributeCounter = 0
        
        vertexDescriptor.attributes[attributeCounter].format = .float3
        vertexDescriptor.attributes[attributeCounter].offset = 0
        vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
        stride += MemoryLayout<SIMD3<Float>>.stride
        attributeCounter += 1

        vertexDescriptor.attributes[attributeCounter].format = .float3
        vertexDescriptor.attributes[attributeCounter].offset = stride
        vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
        stride += MemoryLayout<SIMD3<Float>>.stride
        attributeCounter += 1

        if (hasTangents) {
            vertexDescriptor.attributes[attributeCounter].format = .float3
            vertexDescriptor.attributes[attributeCounter].offset = stride
            vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
            stride += MemoryLayout<SIMD3<Float>>.stride
            attributeCounter += 1
        }
        
        vertexDescriptor.attributes[attributeCounter].format = .float2
        vertexDescriptor.attributes[attributeCounter].offset = stride
        vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
        stride += MemoryLayout<SIMD2<Float>>.stride


        vertexDescriptor.layouts[0].stride = stride

        return vertexDescriptor
    }
}

extension MDLVertexDescriptor {
	static func defaultVertexDescriptor(hasTangents: Bool) -> MDLVertexDescriptor {
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor(hasTangents: hasTangents))
        var index = 0
        
        let attributePosition = vertexDescriptor.attributes[index] as! MDLVertexAttribute
        attributePosition.name = MDLVertexAttributePosition
        index += 1
        
        let attributeNormal = vertexDescriptor.attributes[index] as! MDLVertexAttribute
        attributeNormal.name = MDLVertexAttributeNormal
        index += 1
        
        if (hasTangents) {
            let attributeTangent = vertexDescriptor.attributes[index] as! MDLVertexAttribute
            attributeTangent.name = MDLVertexAttributeTangent
            index += 1
        }
        
        let attributeUV = vertexDescriptor.attributes[index] as! MDLVertexAttribute
        attributeUV.name = MDLVertexAttributeTextureCoordinate
        
        
        return vertexDescriptor
    }
}
