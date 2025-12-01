//  SCNGeometry+RealityKit.swift
//  Factals
//
//  Converter to translate SCNGeometry to RealityKit MeshResource

import SceneKit
import RealityKit

extension SCNGeometry {
	/// Convert SCNGeometry to RealityKit MeshResource
	/// Returns nil if conversion not supported for this geometry type
	func toMeshResource() -> MeshResource? {
		// Handle standard SceneKit primitives
		switch self {
		case let box as SCNBox:
			return .generateBox(
				width: Float(box.width),
				height: Float(box.height),
				depth: Float(box.length)
			)

		case let sphere as SCNSphere:
			return .generateSphere(radius: Float(sphere.radius))

		case let cylinder as SCNCylinder:
			return .generateCylinder(
				height: Float(cylinder.height),
				radius: Float(cylinder.radius)
			)

		case let cone as SCNCone:
			return .generateCone(
				height: Float(cone.height),
				radius: Float(cone.bottomRadius)
			)

		case let plane as SCNPlane:
			return .generatePlane(
				width: Float(plane.width),
				depth: Float(plane.height)
			)

		case let capsule as SCNCapsule:
			return .generateCapsule(
				height: Float(capsule.height),
				radius: Float(capsule.radius)
			)

		case let torus as SCNTorus:
			// RealityKit doesn't have built-in torus, convert via mesh
			return convertCustomGeometry()

		// Custom geometries (SCNHemisphere, SCNTunnelHood, etc.)
		default:
			return convertCustomGeometry()
		}
	}

	/// Convert custom or complex SCNGeometry by extracting vertex data
	private func convertCustomGeometry() -> MeshResource? {
		// Extract geometry sources
		guard let vertexSource = sources(for: .vertex).first,
			  let elements = self.elements.first else {
			print("⚠️ Cannot convert geometry: missing vertex source or elements")
			return nil
		}

		// Get vertex data
		let vertexCount = vertexSource.vectorCount
		let vertexStride = vertexSource.dataStride
		let vertexData = vertexSource.data

		var positions: [SIMD3<Float>] = []
		positions.reserveCapacity(vertexCount)

		// Extract vertex positions
		for i in 0..<vertexCount {
			let offset = i * vertexStride
			vertexData.withUnsafeBytes { bytes in
				let pointer = bytes.baseAddress!.advanced(by: offset)
				let vector = pointer.assumingMemoryBound(to: SCNVector3.self).pointee
				positions.append(SIMD3<Float>(
					Float(vector.x),
					Float(vector.y),
					Float(vector.z)
				))
			}
		}

		// Extract indices
		var indices: [UInt32] = []
		let indexData = elements.data
		let indexCount = indexData.count / MemoryLayout<UInt16>.size

		indexData.withUnsafeBytes { bytes in
			let uint16Ptr = bytes.baseAddress!.assumingMemoryBound(to: UInt16.self)
			for i in 0..<indexCount {
				indices.append(UInt32(uint16Ptr[i]))
			}
		}

		// Create MeshDescriptor
		var descriptor = MeshDescriptor()
		descriptor.positions = .init(positions)
		descriptor.primitives = .triangles(indices)

		// Extract normals if available
		if let normalSource = sources(for: .normal).first {
			var normals: [SIMD3<Float>] = []
			normals.reserveCapacity(normalSource.vectorCount)

			for i in 0..<normalSource.vectorCount {
				let offset = i * normalSource.dataStride
				normalSource.data.withUnsafeBytes { bytes in
					let pointer = bytes.baseAddress!.advanced(by: offset)
					let vector = pointer.assumingMemoryBound(to: SCNVector3.self).pointee
					normals.append(SIMD3<Float>(
						Float(vector.x),
						Float(vector.y),
						Float(vector.z)
					))
				}
			}
			descriptor.normals = .init(normals)
		}

		// Generate mesh
		do {
			return try MeshResource.generate(from: [descriptor])
		} catch {
			print("⚠️ Failed to generate MeshResource: \(error)")
			return nil
		}
	}
}

// MARK: - Material Conversion
extension SCNMaterial {
	/// Convert SCNMaterial to RealityKit SimpleMaterial
	func toSimpleMaterial() -> SimpleMaterial {
		var material = SimpleMaterial()

		// Convert diffuse color
		if let color = diffuse.contents as? NSColor {
			material.color = .init(tint: color)
		}

		// Metallic and roughness
		if let metalness = metalness.contents as? NSNumber {
			material.metallic = metalness.floatValue
		}
		if let roughness = roughness.contents as? NSNumber {
			material.roughness = roughness.floatValue
		}

		return material
	}
}
