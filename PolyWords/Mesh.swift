import MetalKit

struct Mesh {
  let mtkMesh: MTKMesh
  let submeshes: [Submesh]
//	let findTangents: Bool
  
	init(mdlMesh: MDLMesh, mtkMesh: MTKMesh, findTangents: Bool) {
//		self.findTangents = findTangents
    self.mtkMesh = mtkMesh
    submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
			Submesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1, findTangents: findTangents)
    }
  }
}
