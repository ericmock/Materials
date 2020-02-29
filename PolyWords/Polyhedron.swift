//
//  Polyhedron.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/14/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation

// {{0.5, -0.688191, 0}, {-0.5, -0.688191, 0}, {-0.809017, 0.262866,0}, {0, 0.850651, 0}, {0.809017, 0.262866, 0}}
class Polyhedron: Model {
    let polygons:[MyPolygon]
    let basePolygons:[BasePolygon]
    let numberTriangles:Int
    let numberSquares:Int
    let numberPentagons:Int
    //let numberFacesOfTypes:Int
    let numberOfFacesOfType:[Int] = [0]
    var numberOfFaces: Int
    var polyVertices:  [SIMD4<Float>]!
    //    var transform: Transform
    
    
    override init(name: String, findTangents: Bool) {
        polygons = [MyPolygon(vertices: [[0.57735, 0, 0], [-0.288675, -0.5, 0],[-0.288675, 0.5, 0]],
                              indices: [[1,2,3]], textureNumber: 0),
                    MyPolygon(vertices: [[0.5, -0.5, 0],[-0.5, -0.5, 0],[-0.5, 0.5, 0],[0.5, 0.5, 0]],
                              indices: [[1,2,3],[1,3,4]], textureNumber: 0),
                    MyPolygon(vertices: [[0.5, -0.688191, 0], [-0.5, -0.688191, 0], [-0.809017, 0.262866,0], [0, 0.850651, 0], [0.809017, 0.262866, 0]],
                              indices: [[1,2,3],[1,3,5],[5,3,4]], textureNumber: 0)]
        basePolygons = [BasePolygon(vertices: [[0.57735, 0, 0], [-0.288675, -0.5, 0],[-0.288675, 0.5, 0]],
                                    indices: [[1,2,3]], textureNumber: 0),
                        BasePolygon(vertices: [[0.5, -0.5, 0],[-0.5, -0.5, 0],[-0.5, 0.5, 0],[0.5, 0.5, 0]],
                                    indices: [[1,2,3],[1,3,4]], textureNumber: 0),
                        BasePolygon(vertices: [[0.5, -0.688191, 0], [-0.5, -0.688191, 0], [-0.809017, 0.262866,0], [0, 0.850651, 0], [0.809017, 0.262866, 0]],
                                    indices: [[1,2,3],[1,3,5],[5,3,4]], textureNumber: 0)]
        numberTriangles = 20
        numberSquares = 30
        numberPentagons = 12
        
        numberOfFaces = numberTriangles + numberSquares + numberPentagons
        
        
        super.init(name: name, findTangents: findTangents)
        
        
    }
    
}
