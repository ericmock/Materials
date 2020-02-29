//
//  Polygon.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/17/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
 
class MyPolygon {
    let vertices: [SIMD3<Float>]
    let indices: [SIMD3<Int>]
    var touched: Bool = false
    var textureNumber: Int
    var polyType: Int = 0
    var active: Bool = false
    var centroid: SIMD3<Float> = [0, 0, 0]
    var number: Int = 0
   
    init(vertices: [SIMD3<Float>], indices: [SIMD3<Int>], textureNumber: Int) {
        self.vertices = vertices;
        self.indices = indices;
        self.textureNumber = textureNumber
        
        self.polyType = indices.count
        
        for vertex in vertices {
            centroid += vertex
        }
        centroid = centroid/Float(polyType)
    }

}
