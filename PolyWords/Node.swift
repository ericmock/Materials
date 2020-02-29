import MetalKit

class Node {
	
	var children: [Node] = []
	var parent: Node? = nil
	
	var name: String = "untitled"
	var position: float3 = [0, 0, 0]
	var rotation: float3 = [0, 0, 0]
	var scaleV: float3 = [1, 1, 1]
	
	var initialPosition = SIMD3<Float>(repeating: 0)
	var initialRotation = SIMD3<Float>(repeating: 0)
	var initialScaleV = SIMD3<Float>(repeating: 1)
	
	var modelMatrix: float4x4 {
		let translateMatrix = float4x4(translation: position)
		let rotateMatrix = float4x4(rotation: rotation)
		let scaleMatrix = float4x4(scaling: scaleV)
		return translateMatrix * rotateMatrix * scaleMatrix
	}
	
	var worldMatrix: float4x4 {
		if let parent = parent {
			return parent.worldMatrix * modelMatrix
		} else {
			parent = nil
		}
		return modelMatrix
	}
	
	var boundingBox = MDLAxisAlignedBoundingBox()
	var samplerState:MTLSamplerState? = nil
	
	init() {
		samplerState = defaultSampler(device: Renderer.device)
		
	}
	
	final func add(childNode: Node) {
		children.append(childNode)
		childNode.parent = self
	}
	
	final func remove(childNode: Node) {
		for child in childNode.children {
			child.parent = self
			children.append(child)
		}
		childNode.children = []
		guard let index = (children.firstIndex {
			$0 === childNode
		}) else { return }
		children.remove(at: index)
	}
	
	func worldBoundingBox(matrix: float4x4? = nil ) -> Rect {
		var worldMatrix = self.worldMatrix
		if let matrix = matrix {
			worldMatrix = worldMatrix * matrix
		}
		var lowerLeft = SIMD4<Float>(boundingBox.minBounds.x, 0, boundingBox.minBounds.z, 1)
		lowerLeft = worldMatrix * lowerLeft
		
		var upperRight = SIMD4<Float>(boundingBox.maxBounds.x, 0, boundingBox.maxBounds.z, 1)
		upperRight = worldMatrix * upperRight
		
		return Rect(x: lowerLeft.x,
								z: lowerLeft.z,
								width: upperRight.x - lowerLeft.x,
								height: upperRight.z - lowerLeft.z)
	}
	
	func defaultSampler(device: MTLDevice) -> MTLSamplerState {
		let sampler = MTLSamplerDescriptor()
		sampler.minFilter             = MTLSamplerMinMagFilter.nearest
		sampler.magFilter             = MTLSamplerMinMagFilter.nearest
		sampler.mipFilter             = MTLSamplerMipFilter.nearest
		sampler.maxAnisotropy         = 1
		sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
		sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
		sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
		sampler.normalizedCoordinates = true
		sampler.lodMinClamp           = 0
		sampler.lodMaxClamp           = .greatestFiniteMagnitude
		return device.makeSamplerState(descriptor: sampler)!
	}
	
	
}