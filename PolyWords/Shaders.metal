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
};

struct NormalIn {
	float3 vector;
};

struct TangentIn {
	float3 vector;
};

struct BitanIn {
	float3 vector;
};

struct TextureCoordIn {
	float2 vector;
};

struct VertexOut {
  float4 position [[position]];
	float3 worldPosition;
	float3 meshNormal;
	float3 worldNormal;
//	float3 worldTangent;
//	float3 worldBitan;
//	float2 uv;
};

vertex VertexOut vertex_main(constant VertexIn *vertices [[buffer(verticesBufferIndex)]],
														 constant NormalIn *normals [[buffer(normalsBufferIndex)]],
                          constant float4x4 &matrix [[buffer(uniformsBufferIndex)]],
                          uint id [[vertex_id]]) {
  float4 position = matrix * float4(vertices[id].position, 1);
  VertexOut out;
	out.worldPosition = position.xyz;
	out.worldNormal = (matrix * float4(normals[id].vector,1)).xyz;
  out.position = position;
	out.meshNormal = normals[id].vector;
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant bool &isWireframe [[buffer(1)]],
                              constant float3 &color [[buffer(0)]]) {
	float3 normal = normalize(in.meshNormal);
	return float4(color, 1);
}
