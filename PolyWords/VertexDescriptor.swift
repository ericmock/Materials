import Foundation
import MetalKit

extension MTLVertexDescriptor {
	static func defaultVertexDescriptor() -> MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		var offset = 0
		var attributeCounter = 0
		let hasNormals = true
		let hasTangents = false
		let hasBitangents = false
		let hasTextureCoords = true
		let hasColorShift = true
		let hasFaceCounter = true
		let hasLetter = false
		
		vertexDescriptor.attributes[attributeCounter].format = .float3
		vertexDescriptor.attributes[attributeCounter].offset = 0
		vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
		offset += MemoryLayout<float3>.stride
//		print("offset: \(offset)")
		attributeCounter += 1
		
		if (hasNormals) {
			vertexDescriptor.attributes[attributeCounter].format = .float3
			vertexDescriptor.attributes[attributeCounter].offset = offset
			vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
			offset += MemoryLayout<float3>.stride
//			print("offset: \(offset)")
			attributeCounter += 1
		}
		if (hasTextureCoords) {
			vertexDescriptor.attributes[attributeCounter].format = .float2
			vertexDescriptor.attributes[attributeCounter].offset = offset
			vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
			offset += MemoryLayout<float2>.stride
//			print("offset: \(offset)")
			attributeCounter += 1
		}
		if (hasColorShift) {
			vertexDescriptor.attributes[attributeCounter].format = .float3
			vertexDescriptor.attributes[attributeCounter].offset = offset
			vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
			offset += MemoryLayout<float3>.stride
//			print("offset: \(offset)")
			attributeCounter += 1
		}
		if (hasFaceCounter) {
			vertexDescriptor.attributes[attributeCounter].format = .int
			vertexDescriptor.attributes[attributeCounter].offset = offset
			vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
			offset += MemoryLayout<Int>.stride
//			print("offset: \(offset)")
			attributeCounter += 1
		}
		if (hasLetter) {
			vertexDescriptor.attributes[attributeCounter].format = .int
			vertexDescriptor.attributes[attributeCounter].offset = offset
			vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
			offset += MemoryLayout<Int>.stride
//			print("offset: \(offset)")
			attributeCounter += 1
		}
		if (hasTangents) {
			vertexDescriptor.attributes[Int(Tangent.rawValue)].format = .float3
			vertexDescriptor.attributes[Int(Tangent.rawValue)].offset = offset
			vertexDescriptor.attributes[Int(Tangent.rawValue)].bufferIndex = 0
			offset += MemoryLayout<SIMD3<Float>>.stride
//			print("offset: \(offset)")
//			attributeCounter += 1
		}
		if (hasBitangents) {
			vertexDescriptor.attributes[Int(Bitangent.rawValue)].format = .float3
			vertexDescriptor.attributes[Int(Bitangent.rawValue)].offset = offset
			vertexDescriptor.attributes[Int(Bitangent.rawValue)].bufferIndex = 0
			offset += MemoryLayout<SIMD3<Float>>.stride
//			print("offset: \(offset)")
//			attributeCounter += 1
		}
//		print("offset: \(offset)")
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
//		vertexDescriptor.layouts[0].stride = offset
//    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)

		return vertexDescriptor
	}
}

//extension MDLVertexDescriptor {
//	static func defaultVertexDescriptor() -> MDLVertexDescriptor {
//		let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor())
//		var index = 0
//
//		let attributePosition = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//		attributePosition.name = MDLVertexAttributePosition
//		index += 1
//
//		let attributeNormal = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//		attributeNormal.name = MDLVertexAttributeNormal
//		index += 1
//
//		if (false) {
//			let attributeTangent = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//			attributeTangent.name = MDLVertexAttributeTangent
//			index += 1
//		}
//
//		let attributeUV = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//		attributeUV.name = MDLVertexAttributeTextureCoordinate
//
//
//		return vertexDescriptor
//	}
//}
