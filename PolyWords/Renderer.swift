import MetalKit

class Renderer: NSObject {
	static var device: MTLDevice!
	var commandQueue: MTLCommandQueue!
	static var library: MTLLibrary!
	var samplerState:MTLSamplerState?
	weak var scene:Scene?
	let depthStencilState: MTLDepthStencilState
	
	init(view: MTKView) {
		guard
			let device = MTLCreateSystemDefaultDevice(),
			let commandQueue = device.makeCommandQueue() else {
				fatalError("GPU not available")
		}
		Renderer.device = device
		self.commandQueue = commandQueue
		Renderer.library = device.makeDefaultLibrary()  // Done in buildPipelineState() in MeshGeneration project
		// Move    Renderer.colorPixelFormat = metalView.colorPixelFormat
		view.device = device
		view.depthStencilPixelFormat = .depth32Float
		
		depthStencilState = Renderer.buildDepthStencilState()!
		super.init()
		samplerState = defaultSampler(device: device)
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
	
	static func buildDepthStencilState() -> MTLDepthStencilState? {
		let descriptor = MTLDepthStencilDescriptor()
		descriptor.depthCompareFunction = .less
		descriptor.isDepthWriteEnabled = true
		return
			Renderer.device.makeDepthStencilState(descriptor: descriptor)
	}
}

extension Renderer: MTKViewDelegate {
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		scene?.sceneSizeWillChange(to: size)
		//Move		camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
	}
	
	func flyingPolygon(touchedPolygons:[PolygonModel], time:Double, letterNumber:Int, letterCount:Int) {
		var letterNum = letterNumber
//		let gameScene = scene as! GameScene
		for poly in touchedPolygons {
			let dt:Float = Float(time - poly.polygon.select_animation_start_time)/4.0
			letterNum += 1
//			let polygonType = poly.polygon.type
			
			var trans:Float, trans2:Float, trans3:Float
			if (dt < 0.2) {
				trans = 0.5*(1.0 + atan(40.0*(dt - 0.1))/atan(40.0*(-0.1)))
				trans2 = 1.0 - exp(40.0*(dt-0.2))
				trans3 = 3.11775 * exp(-27.0 * dt) * sin(13.0767 * dt)
			}
			else {
				trans = 0.0
				trans2 = 0.0
				trans3 = 0.0
			}
			
//			poly.nodePosition += float3(dt,0,0)
//			let currentCentroid = (poly.initialTouchedModelMatrix * float4(poly.polygon.centroid,1)).xyz
//			poly.nodeQuaternion = simd_quatf(angle:1.0/100.0, axis: normalize(poly.initialTouchedCentroid)) * poly.nodeQuaternion
			let initialRotationMatrix = float3x3(poly.initialTouchedQuaternion)
//			let currentNormal = initialRotationMatrix *
			let rot = float3x3(rotateFromBases: [poly.polygon.basePolygon.normal, poly.polygon.basePolygon.tangent, poly.polygon.basePolygon.bitangent], toBases: [poly.polygon.normal_v, poly.polygon.tangent_v, poly.polygon.bitan_v])
//			let test1 = rot * poly.polygon.basePolygon.normal
//			print(poly.nodeQuaternion)
//			print(poly.polygon.normal_v)
//			print(test1)
//			let test2 = rot * rot.transpose
//			poly.nodeQuaternion = /*poly.initialTouchedQuaternion * */simd_quatf(rot)
			let startPosition =  initialRotationMatrix * poly.polygon.centroid
			let startQuaternion = poly.initialTouchedQuaternion * simd_quatf(rot)
			let startScale = float3(1,1,1)
			let endPosition = float3(0,2,-2)
			let endQuaternion = simd_quatf(angle: .pi, axis:float3(0,1,0)) * simd_quatf(angle: .pi, axis: float3(0,0,1))
			let endScale = float3(0.5,0.5,1)
			poly.nodePosition = (1.0 - trans) * endPosition + (trans + trans3) * startPosition
			poly.nodeQuaternion = simd_slerp(startQuaternion, endQuaternion, 1.0-trans)
			poly.nodeScaleV = (1.0 - trans) * endScale + trans * startScale
//			switch poly.polygon.type {
//			case 2:
//				poly.nodeQuaternion = simd_quatf(angle: -.pi/5.0, axis: float3(0,0,-1)) * simd_quatf(rot)
//				break
//			default:
//				poly.nodeQuaternion = simd_quatf(rot)//*polyhedron.nodeQuaternion.inverse
//			}
//			poly.nodePosition = (1.0 - trans)*float3(3*(Float(letterNum-1)*0.25 - Float(letterCount-1)*0.25/2.0),2.5,0)
//			poly.nodeQuaternion = simd_quatf(rot)*poly.initialTouchedQuaternion
//			poly.nodeQuaternion = simd_quatf(angle:0, axis: float3(0,0,0))
//			poly.nodePosition = float3(0.0,2.0,0.0)
//			poly. = float3(0, 0, 0)
//			poly.nodePosition += float3(
//				(Float(letterNum-1)*0.25 - Float(letterCount-1)*0.25/2.0)*trans,
//				0.0 + 1.38*trans,
//				-8.0 + 4.0*trans2 + 0.01*Float(letterNum))
			
//			if poly.nodeQuaternion.axis[0] != 0 {
//				poly.nodeQuaternion += simd_quatf(angle: rotationAngle*(1.0 - trans), axis: poly.nodeQuaternion.axis)
//			}
//			poly.nodeQuaternion += simd_quatf(angle: worldRotationAngle*(1.0 - trans), axis:poly.nodeQuaternion.axis)
//			poly.nodeScaleV = float3(
//				1.0 + trans*(0.2/poly.polygon.radius - 1.0),
//				1.0 + trans*(0.2/poly.polygon.radius - 1.0),
//				1.0)
			
//			if trans > 0.0 {
//				print("nodePosition: {\(poly.nodePosition.x), \(poly.nodePosition.y), \(poly.nodePosition.z)}")
//				print("nodeScale: {\(poly.nodeScaleV.x), \(poly.nodeScaleV.y), \(poly.nodeScaleV.z)}")
//				print("nodeRotationAxis: {\(poly.nodeQuaternion.axis.x), \(poly.nodeQuaternion.axis.y), \(poly.nodeQuaternion.axis.z)}")
//				print("nodeRotationAngle: \(poly.nodeQuaternion.angle)")
//			}
		}
	}
	
	func draw(in view: MTKView) {
		guard
			let drawable = view.currentDrawable,
			let descriptor = view.currentRenderPassDescriptor,
			let commandBuffer = commandQueue.makeCommandBuffer(),
			let scene = scene,
			let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
			else {
				return
		}
		
		renderEncoder.setDepthStencilState(depthStencilState)
		
		var lights = scene.lighting.lights
		renderEncoder.setFragmentBytes(&lights,
																	 length: MemoryLayout<Light>.stride * lights.count,
																	 index: Int(lightsBufferIndex.rawValue))
		
		let deltaTime = 1/Float(view.preferredFramesPerSecond)
		scene.update(deltaTime: deltaTime)
		
		for (num,renderable) in scene.renderables.enumerated() {
			if num > 0 && scene is GameScene {
				let polygonModel = renderable as! PolygonModel
//				let poly = polygonModel.polygon
//				print("modelMatrix: \(polygonModel.modelMatrix)")
//				print("scene Uniforms: \(scene.uniforms)")
//				print("nodePosition: {\(polygonModel.nodePosition.x), \(polygonModel.nodePosition.y), \(polygonModel.nodePosition.z)}")
//				print("nodeScale: {\(polygonModel.nodeScaleV.x), \(polygonModel.nodeScaleV.y), \(polygonModel.nodeScaleV.z)}")
//				print("nodeRotationAxis: {\(polygonModel.nodeQuaternion.axis.x), \(polygonModel.nodeQuaternion.axis.y), \(polygonModel.nodeQuaternion.axis.z)}")
//				print("nodeRotationAngle: \(polygonModel.nodeQuaternion.angle)")
//				let quat = scene.renderables[0].nodeQuaternion;
//				let quat2 = simd_quatf(angle: quat.angle, axis:quat.axis)
				flyingPolygon(touchedPolygons: [polygonModel], time: get_time_of_day(), letterNumber: num, letterCount: (scene.renderables.count - 1))
			}
			renderEncoder.pushDebugGroup(renderable.name)
			renderable.render(commandEncoder: renderEncoder,
												uniforms: scene.uniforms,
												fragmentUniforms: scene.fragmentUniforms)
			renderEncoder.popDebugGroup()
		}
		
		renderEncoder.endEncoding()
		
		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
}
