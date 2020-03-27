#include <metal_stdlib>
using namespace metal;
#import "Common.h"

//constant bool hasColorTexture [[function_constant(0)]];
//constant bool hasNormalTexture [[function_constant(1)]];


struct VertexIn {
  float3 position;
  float3 normal;
  float2 uv;
	float3 colorShift;
	int polygonNumber;
	int letter;
//  float3 tangent [[attribute(Tangent)]];
//  float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 worldPosition;
	float3 worldNormal;
	float3 meshNormal;
	float3 colorShift;
	int polygonNumber;
	int letter;
//  float3 worldTangent;
//	float3 meshTangent;
//  float3 worldBitangent;
//	float3 meshBitangent;
  float2 uv;
};

vertex VertexOut vertex_main(constant VertexIn *vertexIn [[buffer(0)]],
                             constant Uniforms &uniforms [[buffer(uniformsBufferIndex)]],
														 uint id [[vertex_id]])
{
  VertexOut out {
    .position = uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * float4(vertexIn[id].position, 1),
    .worldPosition = (uniforms.modelMatrix * float4(vertexIn[id].position, 1)).xyz,
    .worldNormal = (uniforms.viewMatrix * float4(vertexIn[id].normal,1)).xyz,
		.meshNormal = vertexIn[id].normal,
//    .worldTangent = uniforms.normalMatrix * vertexIn.tangent,
//		.meshTangent = vertexIn.tangent,
//    .worldBitangent = uniforms.normalMatrix * vertexIn.bitangent,
//		.meshBitangent = vertexIn.bitangent,
    .uv = vertexIn[id].uv,
		.colorShift = vertexIn[id].colorShift,
		.polygonNumber = vertexIn[id].polygonNumber,
		.letter = vertexIn[id].letter
  };
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
//                              constant Material &material [[buffer(materialsBufferIndex)]],
//															constant float4 &color [[buffer(colorBufferIndex)]],
															constant bool &isWireframe [[buffer(wireframeQBufferIndex)]],
                              texture2d<float> baseColorTexture [[ texture(BaseColorTexture) ]],
//																																	function_constant(hasColorTexture) ]],
                              texture2d<float> normalTexture [[ texture(NormalTexture) ]],
//                                                               function_constant(hasNormalTexture) ]],
															texture2d<float> lettersTexture [[ texture(LettersTexture) ]],
															//                                                               function_constant(hasNormalTexture) ]],
                              sampler textureSampler [[sampler(0)]],
                              constant Light *lights [[buffer(lightsBufferIndex)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(fragmentUniformsBufferIndex)]]) {
  
	float3 baseColor = in.colorShift * baseColorTexture.sample(textureSampler,
                                             in.uv * fragmentUniforms.tiling).rgb;
	float2 letterPosition = in.uv/6.0 + float2(float(in.polygonNumber%6)/6.0,floor(float(in.polygonNumber)/6.0)/6.0) + float2(0.0,0.0);
	
	float3 lettersColor = in.colorShift * lettersTexture.sample(textureSampler,
                                             letterPosition * fragmentUniforms.tiling).rgb;
	baseColor = baseColor * lettersColor;
	float materialShininess = 1;//material.shininess;
	float3 materialSpecularColor = float3(1,1,1);//material.specularColor;

  float3 normalValue = normalTexture.sample(textureSampler,
                                       in.uv * fragmentUniforms.tiling).rgb;
  normalValue = normalValue * 2 - 1;
	normalValue = normalize(normalValue);
  
  float3 diffuseColor = 0;
  float3 ambientColor = 0;
  float3 specularColor = 0;
  
//  float3 normalDirection = float3x3(in.worldTangent,
//                                    in.worldBitangent,
//                                    in.worldNormal) * normalValue;
//  normalDirection = normalize(normalDirection);
	
	float3 normalDirection = normalValue;

  for (uint i = 0; i < fragmentUniforms.lightCount; i++) {
    Light light = lights[i];
    if (light.type == Sunlight) {
      float3 lightDirection = normalize(-light.position);
      float diffuseIntensity =
      saturate(-dot(lightDirection, normalDirection));
      diffuseColor += light.color * baseColor * diffuseIntensity;
      if (diffuseIntensity > 0) {
        float3 reflection =
        reflect(lightDirection, normalDirection);
        float3 cameraDirection =
        normalize(in.worldPosition - fragmentUniforms.cameraPosition);
        float specularIntensity =
        pow(saturate(-dot(reflection, cameraDirection)),
            materialShininess);
        specularColor +=
        light.specularColor * materialSpecularColor * specularIntensity;
      }
    } else if (light.type == Ambientlight) {
      ambientColor += light.color * light.intensity;
    } else if (light.type == Pointlight) {
      float d = distance(light.position, in.worldPosition);
      float3 lightDirection = normalize(in.worldPosition - light.position);
      float attenuation = 1.0 / (light.attenuation.x +
                                 light.attenuation.y * d + light.attenuation.z * d * d);
      
      float diffuseIntensity =
      saturate(-dot(lightDirection, normalDirection));
      float3 color = light.color * baseColor * diffuseIntensity;
      color *= attenuation;
      diffuseColor += color;
    } else if (light.type == Spotlight) {
      float d = distance(light.position, in.worldPosition);
      float3 lightDirection = normalize(in.worldPosition - light.position);
      float3 coneDirection = normalize(light.coneDirection);
      float spotResult = dot(lightDirection, coneDirection);
      if (spotResult > cos(light.coneAngle)) {
        float attenuation = 1.0 / (light.attenuation.x +
                                   light.attenuation.y * d + light.attenuation.z * d * d);
        attenuation *= pow(spotResult, light.coneAttenuation);
        float diffuseIntensity =
        saturate(dot(-lightDirection, normalDirection));
        float3 color = light.color * baseColor * diffuseIntensity;
        color *= attenuation;
        diffuseColor += color;
      }
    }
  }
  float3 fragColor = saturate(diffuseColor + ambientColor + specularColor);
	float denom = 26.0;
//  return float4(in.polygonNumber/denom,in.polygonNumber/denom,in.polygonNumber/denom,1);
//	return float4(fragmentUniforms.tiling, 0, 0, 1);
	return float4(fragColor,1);
//	return float4(float2(int(in.polygonNumber/6),in.polygonNumber%6),0,1);
//	return abs(normalize(in.position));
//	return float4(1,0,0,1);
}
