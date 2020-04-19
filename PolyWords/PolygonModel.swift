import Foundation
import MetalKit

class PolygonModel : Model {
	let polygon:Apolygon
	var initialTouchedCentroid = float3(0,0,0)
	var initialTouchedPosition = float3(0,0,0)
	var initialTouchedAngleAxis = AngleAxis()
	var initialTouchedScaleV = float3(1,1,1)
	var initialTouchedModelMatrix: float4x4 {
		let translateMatrix = float4x4(translation: initialTouchedPosition)
		let rotateMatrix = float4x4(simd_quatf(initialTouchedAngleAxis))//;print("rotation: \(rotation)")
		let scaleMatrix = float4x4(scaling: initialTouchedScaleV)
		return translateMatrix * rotateMatrix * scaleMatrix
	}
	
	override var nodeAngleAxis:AngleAxis {
		didSet {
//			let rotationMatrix = float4x4(nodeQuaternion).upperLeft
//			print("didSet rot:  ",rotationMatrix)
//			print("new normal:  ",rotationMatrix * self.polygon.normal_v)
		}
	}


	init(withPolygon polygon:Apolygon, inScene scene:Scene) {
		self.polygon = polygon
		super.init(forScene: scene)
		let colorMultiplier = [float3(1.5,1.0,1.0),float3(1.0,1.5,1.0),float3(1.0,1.0,1.5),float3(1.5,1.5,1)]
		for (num, vertex) in polygon.basePolygon.vertices.enumerated() {
			let newVertex = Vertex(position: vertex,
														 normal: polygon.normal_v,
														 uv: polygon.scaledBaseTextureCoords[num],
														 colorShift: colorMultiplier[(polygon.numberOfSides-3)%4],
														 faceNumber: 0
			)
			faceVertices.append(newVertex)
		}
		let letterNum = Int16(AppConstants.kAlphabet.firstIndex(of: polygon.letter)!)
		polygonColors.append(colorMultiplier[polygon.type])
		polygonLetters.append(letterNum)

		var localIndices:[UInt16] = Array(repeating: 0, count: 3*polygon.numberOfSides)
		var localIndexCounter:UInt16 = 1
		for num in 0..<polygon.numberOfSides {
			localIndices[3*num] = 0
			localIndices[3*num + 1] = localIndexCounter
			localIndices[3*num + 2] = (localIndexCounter)%UInt16(polygon.numberOfSides) + 1
			localIndexCounter += 1
		}
		faceIndices.append(contentsOf: localIndices)
		
		super.initialize(name: "Polygon \(polygon.number)", scene: scene)

	}
	
	override func render(commandEncoder: MTLRenderCommandEncoder,
							uniforms vertex: Uniforms,
							fragmentUniforms fragment: FragmentUniforms) {
		var uniforms = vertex
				var fragmentUniforms = fragment
				
				uniforms.modelMatrix = worldMatrix
//				print("modelMatrix: \(modelMatrix)")
//				print("scene Uniforms: \(uniforms)")
				fragmentUniforms.tiling = tiling
		//		fragmentUniforms.lightCount = 2
				commandEncoder.setVertexBytes(&uniforms,
																			length: MemoryLayout<Uniforms>.stride,
																			index: Int(uniformsBufferIndex.rawValue))
				commandEncoder.setFragmentBytes(&fragmentUniforms,
																				length: MemoryLayout<FragmentUniforms>.stride,
																				index: Int(fragmentUniformsBufferIndex.rawValue))
				
				for vertexBuffer in mesh.vertexBuffers {
					
					commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(verticesBufferIndex.rawValue))
					
					for submesh in mesh.submeshes {
						commandEncoder.setRenderPipelineState(submesh.polygonPipelineState)
		//				var color = submesh.color
		//				commandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: Int(colorBufferIndex.rawValue))
						// This is a very ugly hack to share textures across Level Selection Scene models
						let baseColorTexture = scene.models[scene.polyhedronModelNumber].mesh.submeshes[0].textures.baseColor
						let normalTexture = scene.models[scene.polyhedronModelNumber].mesh.submeshes[0].textures.normal
						let lettersTexture = scene.models[scene.polyhedronModelNumber].mesh.submeshes[0].textures.letters
						commandEncoder.setFragmentTexture(baseColorTexture,
																						 index: Int(BaseColorTexture.rawValue))
						commandEncoder.setFragmentTexture(normalTexture,
																						 index: Int(NormalTexture.rawValue))
						commandEncoder.setFragmentTexture(lettersTexture,
																						 index: Int(LettersTexture.rawValue))
		//				commandEncoder.setFragmentTexture(submesh.textures.metallic,
		//																				 index: Int(MetallicTexture.rawValue))
		//				commandEncoder.setFragmentTexture(submesh.textures.ao,
		//																				 index: Int(AOTexture.rawValue))

						//					var material = submesh.material
						//					commandEncoder.setFragmentBytes(&material,
						//																					length: MemoryLayout<Material>.stride,
						//																					index: Int(materialsBufferIndex.rawValue))
						//					commandEncoder.setFragmentTexture(submesh.baseColor, index: 0)
						
						if let samplerState = samplerState {
							commandEncoder.setFragmentSamplerState(samplerState, index: 0)
						}
						
						commandEncoder.setRenderPipelineState(submesh.polygonPipelineState)
						
						render(commandEncoder: commandEncoder, submesh: submesh)
					}
				}
	}

}
