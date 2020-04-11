import MetalKit

class Model: Node, Renderable {
	
	var mesh:Mesh!
	var tiling:UInt32 = 1
	var hasTangents:Bool = false
	var allVertices:[float3] = Array()
	var allCentroidVertices:[float3] = Array()
	var faceVertices:[Vertex] = Array()
	var allCentroidNormals:[float3] = Array()
	var allIndices:[[[UInt16]]] = Array(repeating: [[]], count: AppConstants.kPolygonTypeNames.count)
	var allCentroidIndices:[UInt16] = Array()
	var faceIndices:[UInt16] = Array()
	var allCentroidNormalIndices:[UInt16] = Array()
	var polygonLetters:[Int16] = Array()
	var polygonColors:[float3] = Array()
	var polygonSelectedQ:[Bool] = Array()
	let scene:Scene

	
	//  let samplerState: MTLSamplerState?
	var vertexDescriptor:MDLVertexDescriptor!
	
//	init(withVertices vertices:[SIMD3<Float>], indices:[Int], normals:[SIMD3<Float>], tangents:[SIMD3<Float>], bitangents:[SIMD3<Float>], textureVertices:[SIMD2<Float>]) {
//		// need to bundle this all up in a single buffer and then tell GPU the layout
//		let numVertices = vertices.count
//		var bufferSize = 0
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex positions
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex normals
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex tangents
//		bufferSize += MemoryLayout<Vertex>.stride * numVertices // vertex bitangents
//		bufferSize += MemoryLayout<SIMD2<Float>>.stride * numVertices // texture coordinates
//
//		vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor(hasTangents: true)
//
//		
//	}
	init(forScene scene:Scene) {
		self.scene = scene
		super.init()
	}
	
	func loadMyTextures() {
		var bytes:[UInt8] = [1, 2, 3, 4, 5, 6, 7, 8]
		let srcImageData = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
		srcImageData.initialize(from: &bytes, count: 8)
	}
	
	func initialize(name: String, scene:Scene) {
    var submeshes: [Submesh] = []
		
		let indexBuffer = Renderer.device.makeBuffer(bytes: faceIndices, length: MemoryLayout<UInt16>.stride * faceIndices.count, options: [])!
		let submesh = Submesh(indexBuffer: indexBuffer,
													indexCount: faceIndices.count,
													indexType: .uint16,
													baseColor: [0.0, 1.0, 0.0, 1.0],
													scene: scene)
		submeshes.append(submesh)

		let stride = MemoryLayout<Vertex>.stride
		let length = stride * faceVertices.count
//		print(faceVertices[0])
		let vertexBuffer = Renderer.device.makeBuffer(bytes: faceVertices,
																									length: length,
																									options: [])!
		
		mesh = Mesh(vertexBuffer: vertexBuffer, submeshes: submeshes)
		
		self.samplerState = Model.buildSamplerState()
		self.name = name
	}
	
	func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
		commandEncoder.setTriangleFillMode(.fill)
		var isWireframe:Bool = false
		commandEncoder.setFragmentBytes(&isWireframe, length: MemoryLayout<Bool>.stride, index: Int(wireframeQBufferIndex.rawValue))
		commandEncoder.setFragmentBytes(&polygonLetters, length: MemoryLayout<Int16>.stride * polygonLetters.count, index: Int(letterBufferIndex.rawValue))
		commandEncoder.setFragmentBytes(&polygonColors, length: MemoryLayout<float3>.stride * polygonColors.count, index: Int(polygonColorBufferIndex.rawValue))
		commandEncoder.setFragmentBytes(&polygonSelectedQ, length: MemoryLayout<Bool>.stride * polygonSelectedQ.count, index: Int(polygonSelectedIndex.rawValue))

		commandEncoder.drawIndexedPrimitives(type: .triangle,
																				indexCount: submesh.indexCount,
																				indexType: submesh.indexType,
																				indexBuffer: submesh.indexBuffer,
																				indexBufferOffset: 0)
		commandEncoder.setTriangleFillMode(.lines)
//		var color:float4 = [0,0,0,0]
//		commandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: Int(colorBufferIndex.rawValue))
		isWireframe = true
		commandEncoder.setFragmentBytes(&isWireframe, length: MemoryLayout<Bool>.stride, index: Int(wireframeQBufferIndex.rawValue))
		commandEncoder.drawIndexedPrimitives(type: .triangle,
																				indexCount: submesh.indexCount,
																				indexType: submesh.indexType,
																				indexBuffer: submesh.indexBuffer,
																				indexBufferOffset: 0)

	}
	
	private static func buildSamplerState() -> MTLSamplerState? {
		let descriptor = MTLSamplerDescriptor()
		descriptor.sAddressMode = .repeat
		descriptor.tAddressMode = .repeat
		descriptor.mipFilter = .linear
		descriptor.maxAnisotropy = 8
		let samplerState =
			Renderer.device.makeSamplerState(descriptor: descriptor)
		return samplerState
	}
	
	// override this for each model type.
	func render(commandEncoder: MTLRenderCommandEncoder,
							uniforms vertex: Uniforms,
							fragmentUniforms fragment: FragmentUniforms) {
	}
}

extension Model: Equatable {
	static func == (lhs: Model, rhs: Model) -> Bool {
		return lhs === rhs
	}
}
