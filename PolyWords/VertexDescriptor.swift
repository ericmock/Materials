import Foundation
import MetalKit

extension MTLVertexDescriptor {
	static func defaultVertexDescriptor() -> MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		var offset = 0
//		var attributeCounter = 0
		let hasNormals = true
		let hasTangents = false
		let hasBitangents = false
		let hasTextureCoords = true
		
		vertexDescriptor.attributes[Int(Position.rawValue)].format = .float3
		vertexDescriptor.attributes[Int(Position.rawValue)].offset = 0
		vertexDescriptor.attributes[Int(Position.rawValue)].bufferIndex = 0
		offset += MemoryLayout<float3>.stride
//		attributeCounter += 1
		
		if (hasNormals) {
			vertexDescriptor.attributes[Int(Normal.rawValue)].format = .float3
			vertexDescriptor.attributes[Int(Normal.rawValue)].offset = offset
			vertexDescriptor.attributes[Int(Normal.rawValue)].bufferIndex = 0
			offset += MemoryLayout<float3>.stride
//			attributeCounter += 1
		}
		if (hasTextureCoords) {
			vertexDescriptor.attributes[Int(UV.rawValue)].format = .float2
			vertexDescriptor.attributes[Int(UV.rawValue)].offset = offset
			vertexDescriptor.attributes[Int(UV.rawValue)].bufferIndex = 0
			offset += MemoryLayout<float2>.stride
		}
		if (hasTangents) {
			vertexDescriptor.attributes[Int(Tangent.rawValue)].format = .float3
			vertexDescriptor.attributes[Int(Tangent.rawValue)].offset = offset
			vertexDescriptor.attributes[Int(Tangent.rawValue)].bufferIndex = 0
			offset += MemoryLayout<SIMD3<Float>>.stride
//			attributeCounter += 1
		}
		if (hasBitangents) {
			vertexDescriptor.attributes[Int(Bitangent.rawValue)].format = .float3
			vertexDescriptor.attributes[Int(Bitangent.rawValue)].offset = offset
			vertexDescriptor.attributes[Int(Bitangent.rawValue)].bufferIndex = 0
			offset += MemoryLayout<SIMD3<Float>>.stride
//			attributeCounter += 1
		}
		print("offset: \(offset)")
		vertexDescriptor.layouts[0].stride = offset
//    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)

		return vertexDescriptor
	}
}

extension MDLVertexDescriptor {
	static func defaultVertexDescriptor() -> MDLVertexDescriptor {
		let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor())
		var index = 0
		
		let attributePosition = vertexDescriptor.attributes[index] as! MDLVertexAttribute
		attributePosition.name = MDLVertexAttributePosition
		index += 1
		
		let attributeNormal = vertexDescriptor.attributes[index] as! MDLVertexAttribute
		attributeNormal.name = MDLVertexAttributeNormal
		index += 1
		
		if (false) {
			let attributeTangent = vertexDescriptor.attributes[index] as! MDLVertexAttribute
			attributeTangent.name = MDLVertexAttributeTangent
			index += 1
		}
		
		let attributeUV = vertexDescriptor.attributes[index] as! MDLVertexAttribute
		attributeUV.name = MDLVertexAttributeTextureCoordinate
		
		
		return vertexDescriptor
	}
}
