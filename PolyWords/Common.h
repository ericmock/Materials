#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
  matrix_float3x3 normalMatrix;
} Uniforms;

typedef enum {
  unused = 0,
  Sunlight = 1,
  Spotlight = 2,
  Pointlight = 3,
  Ambientlight = 4
} LightType;

typedef struct {
  vector_float3 position;
  vector_float3 color;
  vector_float3 specularColor;
  float intensity;
  vector_float3 attenuation;
  LightType type;
  float coneAngle;
  vector_float3 coneDirection;
  float coneAttenuation;
} Light;

typedef struct {
  uint lightCount;
  vector_float3 cameraPosition;
  uint tiling;
} FragmentUniforms;

typedef enum {
  Position = 0,
  Normal = 1,
  UV = 2,
  Tangent = 3,
  Bitangent = 4
} Attributes;

typedef enum {
  BaseColorTexture = 0,
  NormalTexture = 1,
  RoughnessTexture = 2,
  MetallicTexture = 3,
  AOTexture = 4,
	LettersTexture = 5
} Textures;

typedef enum {
  verticesBufferIndex = 0,
	normalsBufferIndex = 1,
	tangentsBufferIndex = 2,
	bitanBufferIndex = 3,
	textureCoordbufferIndex = 4,
  uniformsBufferIndex = 11,
  lightsBufferIndex = 12,
  fragmentUniformsBufferIndex = 13,
  materialsBufferIndex = 14,
	letterBufferIndex = 15,
	wireframeQBufferIndex = 16,
	polygonColorBufferIndex = 17,
	polygonSelectedIndex = 18
} BufferIndices;

typedef struct {
  vector_float4 baseColor;
  vector_float3 specularColor;
  float roughness;
  float metallic;
  vector_float3 ambientOcclusion;
  float shininess;
} Material;

#endif /* Common_h */
