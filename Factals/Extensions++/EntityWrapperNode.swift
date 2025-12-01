//
//  EntityWrapperNode.swift
//  Factals
//
//  Bridge between SceneKit (SCNNode) and RealityKit (Entity) hierarchies
//

import SceneKit
import RealityKit

/// SCNNode subclass that wraps a RealityKit Entity hierarchy
/// Allows RealityKit content to be accessed through SceneKit-like interface
class EntityWrapperNode: SCNNode {

	/// The wrapped RealityKit entity (typically an AnchorEntity)
	var wrappedEntity: Entity?

	/// Create wrapper for a RealityKit entity
	init(wrapping entity: Entity) {
		self.wrappedEntity = entity
		super.init()
		self.name = "EntityWrapper[\(entity.name)]"
	}

	/// Standard SCNNode init
	override init() {
		self.wrappedEntity = nil
		super.init()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Bridge Methods

	/// Get the underlying AnchorEntity if this wraps one
	var anchorEntity: AnchorEntity? {
		return wrappedEntity as? AnchorEntity
	}

	/// Access Entity transform through SCNNode interface
	override var transform: SCNMatrix4 {
		get {
			guard let entity = wrappedEntity else { return super.transform }
			return SCNMatrix4(entity.transform.matrix)
		}
		set {
			guard let entity = wrappedEntity else { return }
			entity.transform = Transform(matrix: simd_float4x4(newValue))
		}
	}

	/// Access Entity position through SCNNode interface
	override var position: SCNVector3 {
		get {
			guard let entity = wrappedEntity else { return super.position }
			let pos = entity.position(relativeTo: nil)
			return SCNVector3(pos.x, pos.y, pos.z)
		}
		set {
			guard let entity = wrappedEntity else { return }
			entity.position = SIMD3<Float>(newValue.x, newValue.y, newValue.z)
		}
	}

	/// Find child entity by name
	func findEntity(named name: String) -> Entity? {
		return wrappedEntity?.findEntity(named: name)
	}

	/// Get all child entities
	var childEntities: [Entity] {
		return wrappedEntity?.children ?? []
	}

	/// Debug description
	override var description: String {
		if let entity = wrappedEntity {
			return "EntityWrapperNode('\(entity.name)' with \(entity.children.count) children)"
		}
		return "EntityWrapperNode(empty)"
	}
}
