//
//  EntityWrapperNode.swift
//  Factals
//
//  Created by Allen King on 11/29/25.
//

// MARK: - EntityWrapperNode (Bridge between SceneKit and RealityKit)

import SwiftUI
import RealityKit
import SceneKit
import AppKit

/// SCNNode subclass that wraps a RealityKit Entity hierarchy
/// Allows RealityKit content to be accessed through SceneKit-like interface
class EntityWrapperNode: SCNNode {
	var wrappedEntity: Entity?				/// The wrapped RealityKit entity (typically an AnchorEntity)
	init(wrapping entity: Entity) {			/// Create wrapper for a RealityKit entity
		self.wrappedEntity 		= entity
		super.init()
		self.name 				= "EntityWrapper[\(entity.name)]"
	}
	override init() {						/// Standard SCNNode init
		self.wrappedEntity 		= nil
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
			guard let entity 	= wrappedEntity else { return super.transform 	}
			return SCNMatrix4(entity.transform.matrix)
		}
		set {
			guard let entity 	= wrappedEntity else { return 					}
			entity.transform 	= Transform(matrix: simd_float4x4(newValue))
		}
	}
	/// Access Entity position through SCNNode interface
	override var position: SCNVector3 {
		get {
			guard let entity 	= wrappedEntity else { return super.position 	}
			let pos 			= entity.position(relativeTo: nil)
			return SCNVector3(pos.x, pos.y, pos.z)
		}
		set {
			guard let entity 	= wrappedEntity else { return }
			entity.position 	= SIMD3<Float>(Float(newValue.x), Float(newValue.y), Float(newValue.z))
		}
	}
	/// Find child entity by name
	func findEntity(named name: String) -> Entity? {
		return wrappedEntity?.findEntity(named: name)
	}
	/// Get all child entities
	var childEntities: [Entity] {
		guard let entity = wrappedEntity else { return [] }
		return Array(entity.children)
	}
	/// Debug description
	override var description: String {
		if let entity = wrappedEntity {
			return "EntityWrapperNode('\(entity.name)' with \(entity.children.count) children)"
		}
		return "EntityWrapperNode(empty)"
	}
}
