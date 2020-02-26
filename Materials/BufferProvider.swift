//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by Eric Mockensturm on 2/22/20.
//  Copyright © 2020 razeware. All rights reserved.
//

import Foundation
import Metal

class BufferProvider {
    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var avaliableBufferIndex: Int = 0
    
    var avaliableResourcesSemaphore: DispatchSemaphore
    
    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {

        avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)

        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        for _ in 0...inflightBuffersCount-1 {
            let uniformsBuffer:MTLBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])!
            uniformsBuffers.append(uniformsBuffer)
        }
        
    }
    
    deinit {
        for _ in 0...self.inflightBuffersCount {
            self.avaliableResourcesSemaphore.signal()
        }
    }
    
    func nextUniformsBuffer(projectionMatrix: float4x4, modelViewMatrix: float4x4) -> MTLBuffer {
        
      // 1
      let buffer = uniformsBuffers[avaliableBufferIndex]
        
      // 2
      let bufferPointer = buffer.contents()
        
      // 3
      memcpy(bufferPointer, modelViewMatrix.raw, MemoryLayout<float4x4>.size)
      memcpy(bufferPointer + MemoryLayout<float4x4>.size, projectionMatrix.raw, MemoryLayout<float4x4>.size)
        
      // 4
      avaliableBufferIndex += 1
      if avaliableBufferIndex == inflightBuffersCount{
        avaliableBufferIndex = 0
      }
        
      return buffer
    }
}
