//
//  Extensions.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/11/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

//extension MTLVertexDescriptor {
//    static func defaultVertexDescriptor(hasTangent: Bool = false) -> MTLVertexDescriptor {
//        let vertexDescriptor = MTLVertexDescriptor()
//        var stride = 0
//        var attributeCounter = 0
//
//        vertexDescriptor.attributes[attributeCounter].format = .float3
//        vertexDescriptor.attributes[attributeCounter].offset = 0
//        vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
//        stride += MemoryLayout<SIMD3<Float>>.stride
//        attributeCounter += 1
//
//        vertexDescriptor.attributes[attributeCounter].format = .float3
//        vertexDescriptor.attributes[attributeCounter].offset = stride
//        vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
//        stride += MemoryLayout<SIMD3<Float>>.stride
//        attributeCounter += 1
//
//        if (hasTangent) {
//            vertexDescriptor.attributes[attributeCounter].format = .float3
//            vertexDescriptor.attributes[attributeCounter].offset = stride
//            vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
//            stride += MemoryLayout<SIMD3<Float>>.stride
//            attributeCounter += 1
//        }
//
//        vertexDescriptor.attributes[attributeCounter].format = .float2
//        vertexDescriptor.attributes[attributeCounter].offset = stride
//        vertexDescriptor.attributes[attributeCounter].bufferIndex = 0
//        stride += MemoryLayout<SIMD2<Float>>.stride
//
//
//        vertexDescriptor.layouts[0].stride = stride
//
//        return vertexDescriptor
//    }
//}
//
//extension MDLVertexDescriptor {
//  static var defaultVertexDescriptor: MDLVertexDescriptor = {
//    let vertexDescriptor = MDLVertexDescriptor()
//    var offset  = 0
//    
//    // position attribute
//    vertexDescriptor.attributes[Int(Position.rawValue)]
//      = MDLVertexAttribute(name: MDLVertexAttributePosition,
//                           format: .float3,
//                           offset: 0,
//                           bufferIndex: Int(BufferIndexVertices.rawValue))
//    offset += MemoryLayout<float3>.stride
//    
//    // normal attribute
//    vertexDescriptor.attributes[Int(Normal.rawValue)] =
//      MDLVertexAttribute(name: MDLVertexAttributeNormal,
//                         format: .float3,
//                         offset: offset,
//                         bufferIndex: Int(BufferIndexVertices.rawValue))
//    offset += MemoryLayout<float3>.stride
//    
//    // uv attribute
//    vertexDescriptor.attributes[Int(UV.rawValue)] =
//      MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
//                         format: .float2,
//                         offset: offset,
//                         bufferIndex: Int(BufferIndexVertices.rawValue))
//    offset += MemoryLayout<float2>.stride
//    
//    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
//    return vertexDescriptor
//  }()
//}
//
//extension MDLVertexDescriptor {
//    static func defaultVertexDescriptor(hasTangent: Bool = false) -> MDLVertexDescriptor {
//        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor(hasTangent: hasTangent))
//        var index = 0
//
//        let attributePosition = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//        attributePosition.name = MDLVertexAttributePosition
//        index += 1
//
//        let attributeNormal = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//        attributeNormal.name = MDLVertexAttributeNormal
//        index += 1
//
//        if (hasTangent) {
//            let attributeTangent = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//            attributeTangent.name = MDLVertexAttributeTangent
//            index += 1
//        }
//
//        let attributeUV = vertexDescriptor.attributes[index] as! MDLVertexAttribute
//        attributeUV.name = MDLVertexAttributeTextureCoordinate
//	}
//}

