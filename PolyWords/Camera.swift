import Foundation
import CoreGraphics

class Camera: Node {
  
  var fovDegrees: Float = 70
  var fovRadians: Float {
    return fovDegrees.degreesToRadians
  }
  var aspect: Float = 1
  var near: Float = 0.001
  var far: Float = 100
  
	private var startPoint: CGPoint = .zero
	private var lastPoint: CGPoint = .zero
	private var startTime: Float = 0
	private var checked = false
	private var dragging = false
	private var initialTouchPosition: CGPoint = .zero
	private var currentTouchPosition: CGPoint = .zero
	var dragTimer: Timer = Timer()
	var oldText: String = ""
	var polyhedron: Polyhedron!
	
	var previouslyTouchedNumber: Int = 0
	var touchedNumber: Int = 0
	

  var projectionMatrix: float4x4 {
    return float4x4(projectionFov: fovRadians,
                    near: near,
                    far: far,
                    aspect: aspect)
  }
  
  var viewMatrix: float4x4 {
    let translateMatrix = float4x4(translation: nodePosition)
    let rotateMatrix = float4x4(simd_quatf(angle: nodeAngleAxis.angle, axis: nodeAngleAxis.axis))
    let scaleMatrix = float4x4(scaling: nodeScaleV)
    return (translateMatrix * scaleMatrix * rotateMatrix).inverse
  }
  
  func zoom(delta: Float) {}
  func rotate(delta: float3) {}
}


class ArcballCamera: Camera {
  
  var minDistance: Float = 0.5
  var maxDistance: Float = 10
	var velocity = CGPoint(x: 0.0, y: 0.0)
	var speed: CGFloat = 0.0
	private var _viewMatrix = float4x4.identity()
	
  var distance: Float = 0 {
    didSet {
      _viewMatrix = updateViewMatrix()
    }
  }
  
  var target: float3 = [0, 0, 0] {
    didSet {
      _viewMatrix = updateViewMatrix()
    }
  }
  
	override func zoom(delta: Float) {
			let sensitivity: Float = 0.05
			distance -= delta * sensitivity
			_viewMatrix = updateViewMatrix()
	}
	
  override var nodeAngleAxis: AngleAxis {
    didSet {
      _viewMatrix = updateViewMatrix()
    }
  }
  
  override var viewMatrix: float4x4 {
    return _viewMatrix
  }
  
  override init() {
    super.init()
    _viewMatrix = updateViewMatrix()
  }
  
  private func updateViewMatrix() -> float4x4 {
    let translateMatrix = float4x4(translation: [target.x, target.y, target.z - distance])
    let rotateMatrix = float4x4(simd_quatf(angle: nodeAngleAxis.angle, axis: nodeAngleAxis.axis))
    let matrix = (rotateMatrix * translateMatrix).inverse
    nodePosition = rotateMatrix.upperLeft * -matrix.columns.3.xyz
    return matrix
  }
  
	override func rotate(delta: float3) {
//    let sensitivity: Float = 0.005
//    var x = nodeRotation.x + delta.y * sensitivity
//    x = max(-Float.pi/2, min(x, Float.pi/2))
//    nodeRotation = [
//        x,
//        nodeRotation.y + delta.x * sensitivity,
//        nodeRotation.z
//    ]
    _viewMatrix = updateViewMatrix()
  }
	
//  override func rotate(delta: float3) {
//    let sensitivity: Float = 0.005
//		print(rotation)  // does not cause crash
//		print(delta)  // does not cause crash
//		print(rotation.x)  // does not cause crash
//		print(delta.x)  // does not cause crash
////		rotation.y += sensitivity  // does not cause crash
//		print(rotation.y)  // does not cause crash
//		print(10.0 * sensitivity)  // does not cause crash
//		let temp = 10.0 * sensitivity; print(temp)  // does not cause crash
////		var temp2 = 10.0 * sensitivity  // causes crash at rotation.x += delta.y * sensitivity
////		rotation.y = temp  // causes crash
////		rotation.y += 10.0 * sensitivity  // causes crash
////    rotation.y += delta.x * sensitivity  // causes crash
////    rotation += delta * sensitivity  // causes crash
//		print(rotation)  // does not cause crash
//		print(rotation.x)  // does not cause crash
//		rotation.x += delta.y * sensitivity  // does not cause crash
////		rotation.y += delta.x * sensitivity
////		temp = rotation.x; print(temp)
////    rotation.x = max(-Float.pi/2, min(rotation.x, Float.pi/2))  // causes crash
//    _viewMatrix = updateViewMatrix()
//  }
}
