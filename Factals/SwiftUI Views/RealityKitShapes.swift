//
//  RealityKitShapes.swift
//  FacReal
//
//  Created by Allen King on 7/24/25.
//  Shape creation functions for RealityKit primitives
//

import RealityKit
import simd
import AppKit

extension RealityKitView {
	// MARK: - Standard Primitives
	// Functions use NSColor directly since SimpleMaterial.Color is NSColor
	func RksBox(width:Float, height:Float, length:Float, chamferRadius:Float=0.0) -> ModelEntity {
		let boxMesh 			= MeshResource.generateBox(size:[width, height, length])
		let boxMaterial 		= SimpleMaterial(color:.gray, isMetallic:false)
		let boxEntity 			= ModelEntity(mesh:boxMesh, materials:[boxMaterial])
		return boxEntity
	}
	func RksSphere(radius:Float) -> ModelEntity {
		let sphereMesh 			= MeshResource.generateSphere(radius: radius)
		let sphereMaterial 		= SimpleMaterial(color:.gray, isMetallic:false)
		let sphereEntity 		= ModelEntity(mesh:sphereMesh, materials:[sphereMaterial])
		return sphereEntity
	}
	func RksCylinder(height:Float, radius:Float) -> ModelEntity {
		let cylinderMesh 		= MeshResource.generateCylinder(height: height, radius: radius)
		let cylinderMaterial 	= SimpleMaterial(color:.gray, isMetallic:false)
		let cylinderEntity 		= ModelEntity(mesh:cylinderMesh, materials:[cylinderMaterial])
		return cylinderEntity
	}
	func RksCone(height:Float, radius:Float) -> ModelEntity {
		let coneMesh 			= MeshResource.generateCone(height:height, radius:radius)
		let coneMaterial 		= SimpleMaterial(color:.gray, isMetallic:false)
		let coneEntity 			= ModelEntity(mesh: coneMesh, materials: [coneMaterial])
		return coneEntity
	}
	func RksPlane(width: Float, depth: Float) -> ModelEntity {
		let planeMesh 			= MeshResource.generatePlane(width: width, depth: depth)
		let planeMaterial 		= SimpleMaterial(color: .gray, isMetallic: false)
		let planeEntity 		= ModelEntity(mesh: planeMesh, materials: [planeMaterial])
		return planeEntity
	}
	func RksCapsule(height: Float, radius: Float) -> ModelEntity {
		// RealityKit doesn't have generateCapsule, use cylinder as approximation
		let capsuleMesh 		= MeshResource.generateCylinder(height: height, radius: radius)
		let capsuleMaterial 	= SimpleMaterial(color: .gray, isMetallic: false)
		let capsuleEntity 		= ModelEntity(mesh: capsuleMesh, materials: [capsuleMaterial])
		return capsuleEntity
	}
	func RksTorus(majorRadius: Float, minorRadius: Float) -> ModelEntity? {
		if let torusMesh 		= generateTorusMesh(majorRadius: majorRadius, minorRadius: minorRadius) {
			let torusMaterial 	= SimpleMaterial(color: .gray, isMetallic: false)
			let torusEntity 	= ModelEntity(mesh: torusMesh, materials: [torusMaterial])
			return torusEntity
		}
		return nil
	}
	func RksTube(height: Float, radius: Float) -> ModelEntity {
		let tubeMesh 			= MeshResource.generateCylinder(height: height, radius: radius)
		let tubeMaterial		= SimpleMaterial(color: .gray, isMetallic: false)
		let tubeEntity			= ModelEntity(mesh: tubeMesh, materials: [tubeMaterial])
		return tubeEntity
	}
	func RksPyramid(width: Float, height: Float, length: Float) -> ModelEntity? {
		if let pyramidMesh 		= generatePyramidMesh(width: width, height: height, length: length) {
			let pyramidMaterial = SimpleMaterial(color: .gray, isMetallic: false)
			let pyramidEntity 	= ModelEntity(mesh: pyramidMesh, materials: [pyramidMaterial])
			return pyramidEntity
		}
		return nil
	}
	func RksGroundPlane(width: Float, depth: Float) -> ModelEntity {
		let groundMesh 			= MeshResource.generatePlane(width: width, depth: depth)
		let groundMaterial 		= SimpleMaterial(color: .init(white: 0.9, alpha: 1), isMetallic: false)
		let groundEntity 		= ModelEntity(mesh: groundMesh, materials: [groundMaterial])
		return groundEntity
	}

	// MARK: - Custom Geometries
	func RksHemisphere(radius: Float, slice: Float = 0.0, stepsAround: Int = 16, stepsBetweenPoles: Int = 8, cap: Bool = true) -> ModelEntity? {
		if let hemisphereMesh 	= generateHemisphereMesh(radius: radius, slice: slice, stepsAround: stepsAround, stepsBetweenPoles: stepsBetweenPoles, cap: cap) {
			let hemisphereMaterial = SimpleMaterial(color: .gray, isMetallic: false)
			let hemisphereEntity = ModelEntity(mesh: hemisphereMesh, materials: [hemisphereMaterial])
			return hemisphereEntity
		}
		return nil
	}
	func RksPoint(radius: Float) -> ModelEntity {
		let pointMesh 			= MeshResource.generateSphere(radius: radius)
		let pointMaterial 		= SimpleMaterial(color: .gray, isMetallic: false)
		let pointEntity 		= ModelEntity(mesh: pointMesh, materials: [pointMaterial])
		return pointEntity
	}

	func RksTunnelHood(width: Float, height: Float, depth: Float) -> ModelEntity? {
		if let tunnelHoodMesh 	= generateTunnelHoodMesh(width: width, height: height, depth: depth) {
			let tunnelHoodMaterial = SimpleMaterial(color: .gray, isMetallic: false)
			let tunnelHoodEntity = ModelEntity(mesh: tunnelHoodMesh, materials: [tunnelHoodMaterial])
			return tunnelHoodEntity
		}
		return nil
	}

	func RksPictureframe(width: Float, height: Float, thickness: Float) -> ModelEntity? {
		if let pictureframeMesh	= generatePictureframeMesh(width: width, height: height, thickness: thickness) {
			let pictureframeMaterial = SimpleMaterial(color: .gray, isMetallic: false)
			let pictureframeEntity = ModelEntity(mesh: pictureframeMesh, materials: [pictureframeMaterial])
			return pictureframeEntity
		}
		return nil
	}

	func Rks3DPictureframe(width: Float, height: Float, depth: Float, frameWidth: Float) -> ModelEntity? {
		if let pictureframe3DMesh = generate3DPictureframeMesh(width: width, height: height, depth: depth, frameWidth: frameWidth) {
			let pictureframe3DMaterial = SimpleMaterial(color: .gray, isMetallic: true)
			let pictureframe3DEntity = ModelEntity(mesh: pictureframe3DMesh, materials: [pictureframe3DMaterial])
			return pictureframe3DEntity
		}
		return nil
	}

	func RksCornerTriangle(size: Float) -> ModelEntity? {
		if let cornerTriangleMesh = generateCornerTriangleMesh(size: size) {
			let cornerTriangleMaterial = SimpleMaterial(color: .gray, isMetallic: false)
			let cornerTriangleEntity = ModelEntity(mesh: cornerTriangleMesh, materials: [cornerTriangleMaterial])
			return cornerTriangleEntity
		}
		return nil
	}

	func RksOpenBox(width: Float, height: Float, depth: Float, thickness: Float) -> ModelEntity? {
		if let openBoxMesh 		= generateOpenBoxMesh(width: width, height: height, depth: depth, thickness: thickness) {
			let openBoxMaterial = SimpleMaterial(color: .gray, isMetallic: false)
			let openBoxEntity 	= ModelEntity(mesh: openBoxMesh, materials: [openBoxMaterial])
			return openBoxEntity
		}
		return nil
	}

	// MARK: - Mesh Generation Functions
	private func generateHemisphereMesh(radius: Float, slice: Float = 0.0, stepsAround: Int = 16, stepsBetweenPoles: Int = 8, cap: Bool = true) -> MeshResource? {
		var vertices: [Vect3] = []
		var normals: [Vect3] = []
		var indices: [UInt32] = []
		
		// Calculate actual hemisphere steps based on slice parameter
		let actualSteps = Int(Float(stepsBetweenPoles) * (1.0 - slice))
		
		// Generate vertices starting from north pole
		for i in 0...actualSteps {
			let lat = Float(i) / Float(stepsBetweenPoles) * Float.pi / 2.0 // 0 to π/2 for hemisphere
			let cosLat = cos(lat)
			let sinLat = sin(lat)
			
			for j in 0...stepsAround {
				let lon = Float(j) / Float(stepsAround) * 2.0 * Float.pi
				let cosLon = cos(lon)
				let sinLon = sin(lon)
				
				let x = radius * cosLat * cosLon
				let y = radius * sinLat
				let z = radius * cosLat * sinLon
				
				vertices.append(Vect3(x, y, z))
				normals.append(normalize(Vect3(x, y, z)))
			}
		}
		
		// Add cap vertices if needed
		if cap && actualSteps < stepsBetweenPoles {
			let capY = radius * sin(Float(actualSteps) / Float(stepsBetweenPoles) * Float.pi / 2.0)
			let capRadius = radius * cos(Float(actualSteps) / Float(stepsBetweenPoles) * Float.pi / 2.0)
			
			// Center of cap
			vertices.append(Vect3(0, capY, 0))
			normals.append(Vect3(0, -1, 0))
			
			// Cap rim vertices
			for j in 0...stepsAround {
				let lon = Float(j) / Float(stepsAround) * 2.0 * Float.pi
				let x = capRadius * cos(lon)
				let z = capRadius * sin(lon)
				
				vertices.append(Vect3(x, capY, z))
				normals.append(Vect3(0, -1, 0))
			}
		}
		
		// Generate indices for hemisphere surface
		for i in 0..<actualSteps {
			for j in 0..<stepsAround {
				let curr = UInt32(i * (stepsAround + 1) + j)
				let next = UInt32(i * (stepsAround + 1) + (j + 1))
				let currNext = UInt32((i + 1) * (stepsAround + 1) + j)
				let nextNext = UInt32((i + 1) * (stepsAround + 1) + (j + 1))
				
				indices.append(contentsOf: [curr, currNext, next])
				indices.append(contentsOf: [next, currNext, nextNext])
			}
		}
		
		// Generate indices for cap if needed
		if cap && actualSteps < stepsBetweenPoles {
			let centerIndex = UInt32(vertices.count - (stepsAround + 2))
			let startCapIndex = centerIndex + 1
			
			for j in 0..<stepsAround {
				let curr = startCapIndex + UInt32(j)
				let next = startCapIndex + UInt32((j + 1) % (stepsAround + 1))
				indices.append(contentsOf: [centerIndex, curr, next])
			}
		}
		
		var meshDescriptor = MeshDescriptor()
		meshDescriptor.positions = MeshBuffer(vertices)
		meshDescriptor.normals = MeshBuffer(normals)
		meshDescriptor.primitives = .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}
									
	private func generateTorusMesh(majorRadius: Float, minorRadius: Float) -> MeshResource? {
		let radialSegments 			= 24
		let tubularSegments 		= 16
		
		var vertices:[Vect3] = []
		var normals: [Vect3] = []
		var indices: [UInt32] 		= []
		
		for i in 0...radialSegments {
			let u = Float(i) / Float(radialSegments) * 2 * Float.pi
			
			for j in 0...tubularSegments {
				let v 				= Float(j) / Float(tubularSegments) * 2 * Float.pi
				
				let x 				= (majorRadius + minorRadius * cos(v)) * cos(u)
				let y 				= minorRadius * sin(v)
				let z 				= (majorRadius + minorRadius * cos(v)) * sin(u)
				
				vertices.append(Vect3(x, y, z))
				
				let nx 				= cos(v) * cos(u)
				let ny 				= sin(v)
				let nz 				= cos(v) * sin(u)
				normals.append(Vect3(nx, ny, nz))
			}
		}
		
		for i in 0..<radialSegments {
			for j in 0..<tubularSegments {
				let a 				= UInt32(i * (tubularSegments + 1) + j)
				let b 				= UInt32((i + 1) * (tubularSegments + 1) + j)
				let c 				= UInt32((i + 1) * (tubularSegments + 1) + (j + 1))
				let d 				= UInt32(i * (tubularSegments + 1) + (j + 1))
				
				indices.append(contentsOf: [a, b, c, a, c, d])
			}
		}
		
		var meshDescriptor 			= MeshDescriptor()
		meshDescriptor.positions 	= MeshBuffer(vertices)
		meshDescriptor.normals 		= MeshBuffer(normals)
		meshDescriptor.primitives	= .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}

	private func generatePyramidMesh(width: Float, height: Float, length: Float) -> MeshResource? {
		let halfWidth 				= width / 2
		let halfLength 				= length / 2
		
		let vertices: [Vect3] = [
			Vect3(-halfWidth, 0, -halfLength),	// 0	// Base vertices
			Vect3( halfWidth, 0, -halfLength),	// 1
			Vect3( halfWidth, 0,  halfLength),	// 2
			Vect3(-halfWidth, 0,  halfLength),	// 3
			Vect3( 0, 		 height, 0)			// 4	// Apex
		]
		
		let indices: [UInt32] 		= [
			// Base (bottom face)
			0, 2, 1,
			0, 3, 2,
			// Side faces
			0, 1, 4,  // Front
			1, 2, 4,  // Right
			2, 3, 4,  // Back
			3, 0, 4   // Left
		]
		
		// Calculate normals
		var normals: [Vect3] = []
		for vertex in vertices {
			if vertex.y == 0 {
				normals.append(Vect3(0, -1, 0))  // Base normal
			} else {
				normals.append(normalize(vertex))  // Approximate apex normal
			}
		}
		
		var meshDescriptor 			= MeshDescriptor()
		meshDescriptor.positions 	= MeshBuffer(vertices)
		meshDescriptor.normals 		= MeshBuffer(normals)
		meshDescriptor.primitives 	= .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}

	private func generateTunnelHoodMesh(width: Float, height: Float, depth: Float) -> MeshResource? {
		let segments 				= 16
		var vertices: [Vect3] = []
		var normals: [Vect3] = []
		var indices: [UInt32] 		= []
		
		let halfWidth 				= width / 2
		let halfDepth 				= depth / 2
		
		// Generate arch vertices
		for i in 0...segments {
			let angle 				= Float(i) / Float(segments) * Float.pi
			let x 					= cos(angle) * halfWidth
			let y 					= sin(angle) * height
			
			// Front face
			vertices.append(Vect3(x, y, halfDepth))
			normals.append(Vect3(0, 0, 1))
			
			// Back face
			vertices.append(Vect3(x, y, -halfDepth))
			normals.append(Vect3(0, 0, -1))
		}
		
		// Generate side faces
		for i in 0..<segments {
			let base = UInt32(i * 2)
			
			// Connect front and back
			indices.append(contentsOf: [base + 0, base + 2, base + 1])
			indices.append(contentsOf: [base + 1, base + 2, base + 3])
		}
									
		var meshDescriptor 			= MeshDescriptor()
		meshDescriptor.positions 	= MeshBuffer(vertices)
		meshDescriptor.normals 		= MeshBuffer(normals)
		meshDescriptor.primitives 	= .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}

	private func generatePictureframeMesh(width: Float, height: Float, thickness: Float) -> MeshResource? {
		let frameWidth: Float 		= 0.05
		let halfWidth 				= width / 2
		let halfHeight 				= height / 2
		let halfThickness 			= thickness / 2
		
		let vertices: [Vect3] = [
			// Outer frame vertices (front)
			Vect3(-halfWidth, -halfHeight, halfThickness),
			Vect3(halfWidth, -halfHeight, halfThickness),
			Vect3(halfWidth, halfHeight, halfThickness),
			Vect3(-halfWidth, halfHeight, halfThickness),
			
			// Inner frame vertices (front)
			Vect3(-halfWidth + frameWidth, -halfHeight + frameWidth, halfThickness),
			Vect3( halfWidth - frameWidth, -halfHeight + frameWidth, halfThickness),
			Vect3( halfWidth - frameWidth,  halfHeight - frameWidth, halfThickness),
			Vect3(-halfWidth + frameWidth,  halfHeight - frameWidth, halfThickness),
			
			// Outer frame vertices (back)
			Vect3(-halfWidth, -halfHeight, -halfThickness),
			Vect3( halfWidth, -halfHeight, -halfThickness),
			Vect3( halfWidth,  halfHeight, -halfThickness),
			Vect3(-halfWidth,  halfHeight, -halfThickness),
			
			// Inner frame vertices (back)
			Vect3(-halfWidth + frameWidth, -halfHeight + frameWidth, -halfThickness),
			Vect3( halfWidth - frameWidth, -halfHeight + frameWidth, -halfThickness),
			Vect3( halfWidth - frameWidth,  halfHeight - frameWidth, -halfThickness),
			Vect3(-halfWidth + frameWidth,  halfHeight - frameWidth, -halfThickness)
		]
		
		let indices: [UInt32] = [
			// Front face frame
			0, 1, 4, 1, 5, 4,
			1, 2, 5, 2, 6, 5,
			2, 3, 6, 3, 7, 6,
			3, 0, 7, 0, 4, 7,
			
			// Back face frame
			8, 12, 9, 9, 12, 13,
			9, 13, 10, 10, 13, 14,
			10, 14, 11, 11, 14, 15,
			11, 15, 8, 8, 15, 12
		]
		
		let normals = vertices.map { _ in Vect3(0, 0, 1) }
									
		var meshDescriptor 			= MeshDescriptor()
		meshDescriptor.positions 	= MeshBuffer(vertices)
		meshDescriptor.normals 		= MeshBuffer(normals)
		meshDescriptor.primitives 	= .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}

	private func generate3DPictureframeMesh(width: Float, height: Float, depth: Float, frameWidth: Float) -> MeshResource? {
		let halfWidth 				= width / 2
		let halfHeight 				= height / 2
		let halfDepth 				= depth / 2
		
		var vertices: [Vect3] = []
		var indices: [UInt32] 		= []
		
		// Generate outer box vertices
		let outerVertices: [Vect3] = [
			Vect3(-halfWidth, -halfHeight, -halfDepth),
			Vect3( halfWidth, -halfHeight, -halfDepth),
			Vect3( halfWidth,  halfHeight, -halfDepth),
			Vect3(-halfWidth,  halfHeight, -halfDepth),
			Vect3(-halfWidth, -halfHeight,  halfDepth),
			Vect3( halfWidth, -halfHeight,  halfDepth),
			Vect3( halfWidth,  halfHeight,  halfDepth),
			Vect3(-halfWidth,  halfHeight,  halfDepth)
		]
									
		// Generate inner box vertices (hollow center)
		let innerHalfWidth 			= halfWidth - frameWidth
		let innerHalfHeight 		= halfHeight - frameWidth
		let innerVertices: [Vect3] = [
			Vect3(-innerHalfWidth, -innerHalfHeight, -halfDepth),
			Vect3( innerHalfWidth, -innerHalfHeight, -halfDepth),
			Vect3( innerHalfWidth,  innerHalfHeight, -halfDepth),
			Vect3(-innerHalfWidth,  innerHalfHeight, -halfDepth),
			Vect3(-innerHalfWidth, -innerHalfHeight,  halfDepth),
			Vect3( innerHalfWidth, -innerHalfHeight,  halfDepth),
			Vect3( innerHalfWidth,  innerHalfHeight,  halfDepth),
			Vect3(-innerHalfWidth,  innerHalfHeight,  halfDepth)
		]
		
		vertices.append(contentsOf: outerVertices)
		vertices.append(contentsOf: innerVertices)
		
		// Frame faces indices
		let frameIndices: [UInt32] = [
			// Bottom frame
			0, 1, 8, 1, 9, 8,
			// Right frame
			1, 2, 9, 2, 10, 9,
			// Top frame
			2, 3, 10, 3, 11, 10,
			// Left frame
			3, 0, 11, 0, 8, 11,
			// Front face
			4, 12, 5, 5, 12, 13,
			5, 13, 6, 6, 13, 14,
			6, 14, 7, 7, 14, 15,
			7, 15, 4, 4, 15, 12
		]
		
		indices.append(contentsOf: frameIndices)
									
		let normals 				= vertices.map { normalize($0) }
		
		var meshDescriptor 			= MeshDescriptor()
		meshDescriptor.positions 	= MeshBuffer(vertices)
		meshDescriptor.normals 		= MeshBuffer(normals)
		meshDescriptor.primitives 	= .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}

	private func generateCornerTriangleMesh(size: Float) -> MeshResource? {
		let vertices: [Vect3] = [
			// Base triangle
			Vect3(0, 0, 0),
			Vect3(size, 0, 0),
			Vect3(0, 0, size),
			// Top vertex
			Vect3(0, size, 0)
		]
		
		let indices: [UInt32] = [
			// Base triangle
			0, 2, 1,
			// Side faces
			0, 1, 3,
			1, 2, 3,
			2, 0, 3
		]
		
		var normals: [Vect3] = []
		for vertex in vertices {
			normals.append(normalize(vertex))
		}
		
		var meshDescriptor = MeshDescriptor()
		meshDescriptor.positions = MeshBuffer(vertices)
		meshDescriptor.normals = MeshBuffer(normals)
		meshDescriptor.primitives = .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}

	private func generateOpenBoxMesh(width: Float, height: Float, depth: Float, thickness: Float) -> MeshResource? {
		let halfWidth = width / 2
		let halfDepth = depth / 2
		
		var vertices: [Vect3] = []
		var indices: [UInt32] = []
		
		// Bottom face (outer)
		vertices.append(contentsOf: [
			Vect3(-halfWidth, 0, -halfDepth),
			Vect3(halfWidth, 0, -halfDepth),
			Vect3(halfWidth, 0, halfDepth),
			Vect3(-halfWidth, 0, halfDepth)
		])
		
		// Bottom face (inner)
		let innerHalfWidth = halfWidth - thickness
		let innerHalfDepth = halfDepth - thickness
		vertices.append(contentsOf: [
			Vect3(-innerHalfWidth, thickness, -innerHalfDepth),
			Vect3(innerHalfWidth, thickness, -innerHalfDepth),
			Vect3(innerHalfWidth, thickness, innerHalfDepth),
			Vect3(-innerHalfWidth, thickness, innerHalfDepth)
		])
		
		// Side walls
		let wallHeight = height - thickness
		
		// Front wall
		vertices.append(contentsOf: [
			Vect3(-halfWidth, 0, halfDepth),
			Vect3(halfWidth, 0, halfDepth),
			Vect3(halfWidth, wallHeight, halfDepth),
			Vect3(-halfWidth, wallHeight, halfDepth),
			Vect3(-innerHalfWidth, thickness, innerHalfDepth),
			Vect3(innerHalfWidth, thickness, innerHalfDepth),
			Vect3(innerHalfWidth, wallHeight, innerHalfDepth),
			Vect3(-innerHalfWidth, wallHeight, innerHalfDepth)
		])
		
		// Generate indices for box faces (excluding top)
		let bottomIndices: [UInt32] = [0, 1, 4, 1, 5, 4, 1, 2, 5, 2, 6, 5, 2, 3, 6, 3, 7, 6, 3, 0, 7, 0, 4, 7]
		let frontWallIndices: [UInt32] = [8, 9, 10, 8, 10, 11, 12, 14, 13, 12, 15, 14]
		
		indices.append(contentsOf: bottomIndices)
		indices.append(contentsOf: frontWallIndices)
		
		let normals = vertices.map { _ in Vect3(0, 1, 0) }
		
		var meshDescriptor = MeshDescriptor()
		meshDescriptor.positions = MeshBuffer(vertices)
		meshDescriptor.normals = MeshBuffer(normals)
		meshDescriptor.primitives = .triangles(indices)
		
		return try? MeshResource.generate(from: [meshDescriptor])
	}
}
///}
