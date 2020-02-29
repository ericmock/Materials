//
//  Renderable.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//

import Foundation
import MetalKit

protocol Renderable {
    var name: String { get }
    
    func render(commandEncoder: MTLRenderCommandEncoder,
                uniforms: Uniforms,
                fragmentUniforms: FragmentUniforms)
}
