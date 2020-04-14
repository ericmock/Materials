//
//  Polygon.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/14/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation

struct BasePolygon {
    let vertices: [SIMD3<Float>]
    let indices: [UInt16]
    var touched: Bool = false
    var textureNumber: Int
    var polyType: Int = 0
    var active: Bool = false
    var centroid: SIMD3<Float> = [0, 0, 0]
	var normal = zAxis
	var tangent = xAxis
	var bitangent = yAxis

    init(vertices: [SIMD3<Float>], indices: [UInt16], textureNumber: Int) {
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
