#include <metal_stdlib>
using namespace metal;
#import "Common.h"

//constant bool hasColorTexture [[function_constant(0)]];
//constant bool hasNormalTexture [[function_constant(1)]];


struct VertexIn {
  float4 position [[attribute(Position)]];
  float3 normal [[attribute(Normal)]];
  float2 uv [[attribute(UV)]];
//  float3 tangent [[attribute(Tangent)]];
//  float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 worldPosition;
	float3 worldNormal;
	float3 meshNormal;
//  float3 worldTangent;
//	float3 meshTangent;
//  float3 worldBitangent;
//	float3 meshBitangent;
//  float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(uniformsBufferIndex)]],
														 uint id [[vertex_id]])
{
  VertexOut out {
    .position = uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * vertexIn.position,
    .worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz,
    .worldNormal = (uniforms.viewMatrix * float4(vertexIn.normal,1)).xyz,
		.meshNormal = vertexIn.normal,
//    .worldTangent = uniforms.normalMatrix * vertexIn.tangent,
//		.meshTangent = vertexIn.tangent,
//    .worldBitangent = uniforms.normalMatrix * vertexIn.bitangent,
//		.meshBitangent = vertexIn.bitangent,
//    .uv = vertexIn.uv
  };
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Material &material [[buffer(materialsBufferIndex)]],
															constant float4 &color [[buffer(colorBufferIndex)]],
															constant bool &isWireframe [[buffer(wireframeQBufferIndex)]],
                              texture2d<float> baseColorTexture [[ texture(BaseColorTexture) ]],
//																																	function_constant(hasColorTexture) ]],
//                              texture2d<float> normalTexture [[ texture(NormalTexture),
//                                                               function_constant(hasNormalTexture) ]],
                              sampler textureSampler [[sampler(0)]],
//                              constant Light *lights [[buffer(lightsBufferIndex)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(fragmentUniformsBufferIndex)]]) {
//  float3 baseColor = baseColorTexture.sample(textureSampler,
//                                             in.uv * fragmentUniforms.tiling).rgb;
  
//  float4 baseColor;
//  if (hasColorTexture) {
//    baseColor = baseColorTexture.sample(textureSampler,
//                                        in.uv * fragmentUniforms.tiling).rgb;
//  } else {
//    baseColor = color;
//  }

//  float materialShininess = material.shininess;
//  float3 materialSpecularColor = material.specularColor;

//  float3 normalValue;
//  if (hasNormalTexture) {
//    normalValue = normalTexture.sample(textureSampler,
//                                       in.uv * fragmentUniforms.tiling).rgb;
//    normalValue = normalValue * 2 - 1;
//  } else {
//    normalValue = in.worldNormal;
//  }
//  normalValue = normalize(normalValue);
  
//  float3 diffuseColor = 0;
//  float3 ambientColor = 0;
//  float3 specularColor = 0;
  
//  float3 normalDirection = float3x3(in.worldTangent,
//                                    in.worldBitangent,
//                                    in.worldNormal) * normalValue;
//  normalDirection = normalize(normalDirection);
	
//	float3 normalDirection = normalValue;

//  for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
//    Light light = lights[i];
//    if (light.type == Sunlight) {
//      float3 lightDirection = normalize(-light.position);
//      float diffuseIntensity =
//      saturate(-dot(lightDirection, normalDirection));
//      diffuseColor += light.color * baseColor * diffuseIntensity;
//      if (diffuseIntensity > 0) {
//        float3 reflection =
//        reflect(lightDirection, normalDirection);
//        float3 cameraDirection =
//        normalize(in.worldPosition - fragmentUniforms.cameraPosition);
//        float specularIntensity =
//        pow(saturate(-dot(reflection, cameraDirection)),
//            materialShininess);
//        specularColor +=
//        light.specularColor * materialSpecularColor * specularIntensity;
//      }
//    } else if (light.type == Ambientlight) {
//      ambientColor += light.color * light.intensity;
//    } else if (light.type == Pointlight) {
//      float d = distance(light.position, in.worldPosition);
//      float3 lightDirection = normalize(in.worldPosition - light.position);
//      float attenuation = 1.0 / (light.attenuation.x +
//                                 light.attenuation.y * d + light.attenuation.z * d * d);
//      
//      float diffuseIntensity =
//      saturate(-dot(lightDirection, normalDirection));
//      float3 color = light.color * baseColor * diffuseIntensity;
//      color *= attenuation;
//      diffuseColor += color;
//    } else if (light.type == Spotlight) {
//      float d = distance(light.position, in.worldPosition);
//      float3 lightDirection = normalize(in.worldPosition - light.position);
//      float3 coneDirection = normalize(light.coneDirection);
//      float spotResult = dot(lightDirection, coneDirection);
//      if (spotResult > cos(light.coneAngle)) {
//        float attenuation = 1.0 / (light.attenuation.x +
//                                   light.attenuation.y * d + light.attenuation.z * d * d);
//        attenuation *= pow(spotResult, light.coneAttenuation);
//        float diffuseIntensity =
//        saturate(dot(-lightDirection, normalDirection));
//        float3 color = light.color * baseColor * diffuseIntensity;
//        color *= attenuation;
//        diffuseColor += color;
//      }
//    }
//  }
//  float3 color = saturate(diffuseColor + ambientColor + specularColor);
//  return baseColor;
	return abs(float4(in.worldNormal,1));
//	return abs(normalize(in.position));
}