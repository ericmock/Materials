//
//  Shaders.metal
//  MeshGeneration
//
//  Created by Caroline on 11/3/20.
//  Copyright © 2020 Caroline. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import <simd/simd.h>
#import "Common.h"

struct VertexIn {
  float3 position;
	float3 normal;
	float2 uv;
};

struct VertexOut {
  float4 position [[position]];
	float3 normal;
	float2 uv;
};

vertex VertexOut vertex_main(constant VertexIn *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(uniformsBufferIndex)]],
                          uint id [[vertex_id]]) {
  float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * float4(vertices[id].position, 1);
  VertexOut out;
  out.position = position;
	out.normal = vertices[id].normal;
	out.uv = vertices[id].uv;
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant bool &isWireframe [[buffer(1)]]
//                              constant float3 &color [[buffer(0)]]
															) {
  return float4(abs(in.normal), 1);
}
