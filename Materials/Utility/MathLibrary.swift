import simd

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>

let π = Float.pi

extension Float {
  var radiansToDegrees: Float {
    (self / π) * 180
  }
  var degreesToRadians: Float {
    (self / 180) * π
  }
}

func radians(fromDegrees degrees: Float) -> Float {
    return (degrees / 180) * π
}

func degrees(fromRadians radians: Float) -> Float {
    return (radians / π) * 180
}

func pointInPolygon(withNumberOfPoints npol: Int, withXPoints xp: [Float], withYPoints yp: [Float], withX x: Float, withY y: Float) -> Bool {
    //int i, j, c = 0
    var j: Int = npol - 1
    var c: Bool = false
    for i in 0..<npol {
        //    for (i = 0, j = npol-1; i < npol; j = i++) {
        j = i
        if ((((yp[i] <= y) && (y < yp[j])) ||
            ((yp[j] <= y) && (y < yp[i]))) &&
            (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i])) {
            c = !c
        }
    }
    return c
}


// MARK:- float4
extension float4x4 {
  // MARK:- Translate
  init(translation: float3) {
    let matrix = float4x4(
      [            1,             0,             0, 0],
      [            0,             1,             0, 0],
      [            0,             0,             1, 0],
      [translation.x, translation.y, translation.z, 1]
    )
    self = matrix
  }
  
  // MARK:- Scale
  init(scaling: float3) {
    let matrix = float4x4(
      [scaling.x,         0,         0, 0],
      [        0, scaling.y,         0, 0],
      [        0,         0, scaling.z, 0],
      [        0,         0,         0, 1]
    )
    self = matrix
  }

  init(scaling: Float) {
    self = matrix_identity_float4x4
    columns.3.w = 1 / scaling
  }
  
  // MARK:- Rotate
  init(rotationX angle: Float) {
    let matrix = float4x4(
      [1,           0,          0, 0],
      [0,  cos(angle), sin(angle), 0],
      [0, -sin(angle), cos(angle), 0],
      [0,           0,          0, 1]
    )
    self = matrix
  }
  
  init(rotationY angle: Float) {
    let matrix = float4x4(
      [cos(angle), 0, -sin(angle), 0],
      [         0, 1,           0, 0],
      [sin(angle), 0,  cos(angle), 0],
      [         0, 0,           0, 1]
    )
    self = matrix
  }
  
  init(rotationZ angle: Float) {
    let matrix = float4x4(
      [ cos(angle), sin(angle), 0, 0],
      [-sin(angle), cos(angle), 0, 0],
      [          0,          0, 1, 0],
      [          0,          0, 0, 1]
    )
    self = matrix
  }
  
  init(rotation angle: float3) {
    let rotationX = float4x4(rotationX: angle.x)
    let rotationY = float4x4(rotationY: angle.y)
    let rotationZ = float4x4(rotationZ: angle.z)
    self = rotationX * rotationY * rotationZ
  }
  
  init(rotationYXZ angle: float3) {
    let rotationX = float4x4(rotationX: angle.x)
    let rotationY = float4x4(rotationY: angle.y)
    let rotationZ = float4x4(rotationZ: angle.z)
    self = rotationY * rotationX * rotationZ
  }
  
  // MARK:- Identity
  static func identity() -> float4x4 {
    matrix_identity_float4x4
  }
  
  // MARK:- Upper left 3x3
  var upperLeft: float3x3 {
    let x = columns.0.xyz
    let y = columns.1.xyz
    let z = columns.2.xyz
    return float3x3(columns: (x, y, z))
  }
  
  // MARK: - Left handed projection matrix
  init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
    let y = 1 / tan(fov * 0.5)
    let x = y / aspect
    let z = lhs ? far / (far - near) : far / (near - far)
    let X = float4( x,  0,  0,  0)
    let Y = float4( 0,  y,  0,  0)
    let Z = lhs ? float4( 0,  0,  z, 1) : float4( 0,  0,  z, -1)
    let W = lhs ? float4( 0,  0,  z * -near,  0) : float4( 0,  0,  z * near,  0)
    self.init()
    columns = (X, Y, Z, W)
  }
  
  // left-handed LookAt
  init(eye: float3, center: float3, up: float3) {
    let z = normalize(center-eye)
    let x = normalize(cross(up, z))
    let y = cross(z, x)
    
    let X = float4(x.x, y.x, z.x, 0)
    let Y = float4(x.y, y.y, z.y, 0)
    let Z = float4(x.z, y.z, z.z, 0)
    let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)
    
    self.init()
    columns = (X, Y, Z, W)
  }
  
  // MARK:- Orthographic matrix
  init(orthoLeft left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
    let X = float4(2 / (right - left), 0, 0, 0)
    let Y = float4(0, 2 / (top - bottom), 0, 0)
    let Z = float4(0, 0, 1 / (far - near), 0)
    let W = float4((left + right) / (left - right),
                   (top + bottom) / (bottom - top),
                   near / (near - far),
                   1)
    self.init()
    columns = (X, Y, Z, W)
  }
  
  // convert double4x4 to float4x4
  init(_ m: matrix_double4x4) {
    self.init()
    let matrix: float4x4 = float4x4(float4(m.columns.0),
                                    float4(m.columns.1),
                                    float4(m.columns.2),
                                    float4(m.columns.3))
    self = matrix
  }
	
	init(translateBy: SIMD3<Float>) {
			self = matrix_identity_float4x4
			columns.3.x = translateBy.x
			columns.3.y = translateBy.y
			columns.3.z = translateBy.z
	}

	init(scaleBy: SIMD3<Float>) {
			self = matrix_identity_float4x4
			columns.0.x = scaleBy.x
			columns.1.y = scaleBy.y
			columns.2.z = scaleBy.z
	}
	
	init(scaleBy: Float) {
			self = float4x4(scaleBy: SIMD3<Float>(scaleBy, scaleBy, scaleBy))
	}
	
	init(scaleByX: Float, scaleByY: Float, scaleByZ: Float) {
			self = float4x4(scaleBy: SIMD3<Float>(scaleByX, scaleByY, scaleByZ))
	}

	init(rotateAboutXBy angle: Float) {
			self = matrix_identity_float4x4
			columns.1.y = cos(angle)
			columns.1.z = sin(angle)
			columns.2.y = -sin(angle)
			columns.2.z = cos(angle)
	}
	
	init(rotateAboutYBy angle: Float) {
			self = matrix_identity_float4x4
			columns.0.x = cos(angle)
			columns.0.z = -sin(angle)
			columns.2.x = sin(angle)
			columns.2.z = cos(angle)
	}

	init(rotateAboutZBy angle: Float) {
			self = matrix_identity_float4x4
			columns.0.x = cos(angle)
			columns.0.y = sin(angle)
			columns.1.x = -sin(angle)
			columns.1.y = cos(angle)
	}
	
	init(rotateAboutXYZBy angle: SIMD3<Float>) {
			let rotationX = float4x4(rotateAboutXBy: angle.x)
			let rotationY = float4x4(rotateAboutYBy: angle.y)
			let rotationZ = float4x4(rotateAboutZBy: angle.z)
			self = rotationX * rotationY * rotationZ
	}
	
	init(rotateAboutXYZBy angle: SIMD3<Float>, aboutPoint: SIMD3<Float>) {
			let translate1 = float4x4(translateBy: aboutPoint)
			let translate2 = -translate1

			let rotationX = float4x4(rotateAboutXBy: angle.x)
			let rotationY = float4x4(rotateAboutYBy: angle.y)
			let rotationZ = float4x4(rotateAboutZBy: angle.z)
			self = translate2 * rotationX * rotationY * rotationZ * translate1
	}
	
	init(rotateAboutYXZBy angle: SIMD3<Float>) {
			let rotationX = float4x4(rotateAboutXBy: angle.x)
			let rotationY = float4x4(rotateAboutYBy: angle.y)
			let rotationZ = float4x4(rotateAboutZBy: angle.z)
			self = rotationY * rotationX * rotationZ
	}
	
	var raw: [Float] {
			return [columns.0.x, columns.0.y, columns.0.z, columns.0.w, columns.1.x, columns.1.y, columns.1.z, columns.1.w, columns.2.x, columns.2.y, columns.2.z, columns.2.w, columns.3.x, columns.3.y, columns.3.z, columns.3.w]
	}

}

// MARK:- float3x3
extension float3x3 {
  init(normalFrom4x4 matrix: float4x4) {
    self.init()
    columns = matrix.upperLeft.inverse.transpose.columns
  }
}

// MARK:- float4
extension float4 {
  var xyz: float3 {
    get {
      float3(x, y, z)
    }
    set {
      x = newValue.x
      y = newValue.y
      z = newValue.z
    }
  }
  
  // convert from double4
  init(_ d: SIMD4<Double>) {
    self.init()
    self = [Float(d.x), Float(d.y), Float(d.z), Float(d.w)]
  }
}

