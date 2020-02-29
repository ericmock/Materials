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
    let translateMatrix = float4x4(translation: position)
    let rotateMatrix = float4x4(rotation: rotation)
    let scaleMatrix = float4x4(scaling: scaleV)
    return (translateMatrix * scaleMatrix * rotateMatrix).inverse
  }
  
  func zoom(delta: Float) {}
  func rotate(delta: float2) {}
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
	
  override var rotation: float3 {
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
    let rotateMatrix = float4x4(rotationYXZ: [-rotation.x,
                                              rotation.y,
                                              0])
    let matrix = (rotateMatrix * translateMatrix).inverse
    position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
    return matrix
  }
  
  override func rotate(delta: float2) {
    let sensitivity: Float = 0.005
    rotation.y += delta.x * sensitivity
    rotation.x += delta.y * sensitivity
    rotation.x = max(-Float.pi/2,
                     min(rotation.x,
                         Float.pi/2))
    _viewMatrix = updateViewMatrix()
  }
}
