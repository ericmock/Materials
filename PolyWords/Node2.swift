//
//  Node.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import ModelIO
import MetalKit


class Node2 {
    var name = "Untitled"
    
    var children: [Node2] = []
    var parent: Node2? = nil
    
    var position = SIMD3<Float>(repeating: 0)
    var rotation = SIMD3<Float>(repeating: 0)
    var scaleV = SIMD3<Float>(repeating: 1)
    
    var initialPosition = SIMD3<Float>(repeating: 0)
    var initialRotation = SIMD3<Float>(repeating: 0)
    var initialScaleV = SIMD3<Float>(repeating: 1)
    
    var matrix: float4x4  {
        let translateMatrix = float4x4(translateBy: position)
        let rotationMatrix = float4x4(rotateAboutXYZBy: rotation)
        let scaleMatrix = float4x4(scaleBy: scaleV)
        return translateMatrix * rotationMatrix * scaleMatrix
    }
    
    var worldMatrix: float4x4 {
        if let parent = parent {
            return parent.worldMatrix * matrix
        } else {
            parent = nil
        }
        return matrix
    }
    
    var boundingBox = MDLAxisAlignedBoundingBox()
    var samplerState:MTLSamplerState? = nil

    init() {
        samplerState = defaultSampler(device: Renderer.device)

    }
    
    final func add(childNode: Node2) {
        children.append(childNode)
        childNode.parent = self
    }
    
    final func remove(childNode: Node2) {
        for child in childNode.children {
            child.parent = self
            children.append(child)
        }
        childNode.children = []
        guard let index = (children.firstIndex {
            $0 === childNode
        }) else { return }
        children.remove(at: index)
    }
    
    func worldBoundingBox(matrix: float4x4? = nil ) -> Rect {
        var worldMatrix = self.worldMatrix
        if let matrix = matrix {
            worldMatrix = worldMatrix * matrix
        }
        var lowerLeft = SIMD4<Float>(boundingBox.minBounds.x, 0, boundingBox.minBounds.z, 1)
        lowerLeft = worldMatrix * lowerLeft
        
        var upperRight = SIMD4<Float>(boundingBox.maxBounds.x, 0, boundingBox.maxBounds.z, 1)
        upperRight = worldMatrix * upperRight
        
        return Rect(x: lowerLeft.x,
                    z: lowerLeft.z,
                    width: upperRight.x - lowerLeft.x,
                    height: upperRight.z - lowerLeft.z)
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
    

}
