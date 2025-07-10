//
//  Untitled.swift
//  Factals
//
//  Created by Allen King on 7/8/25.
//

import AppKit
import SceneKit
import RealityKit

// MARK: - 1. Factals Renderer -- Protocol Definition

// Updated RendererProtocol.swift

protocol FactalsRenderer {
	associatedtype NodeType
	associatedtype SceneType
	associatedtype ViewType
	
	func createScene() -> SceneType
	func createNode() -> NodeType
	func addChild(_ child: NodeType, to parent: NodeType)
	func setPosition(_ position: SIMD3<Float>, for node: NodeType)
	func setColor(_ color: NSColor, for node: NodeType)
	
	// CHANGE: Return Result instead of throwing
	func createGeometry(from mesh: FactalsMesh) -> Result<Any, Error>
	
	// NEW: Add method for creating renderable entities
	func createRenderableNode(from mesh: FactalsMesh) -> Result<Any, Error>
//	func createRenderableNode(from mesh: FactalsMesh) -> Result<NodeType, Error>
}
struct FactalsMesh {				// Geometry abstraction
	let vertices: [SIMD3<Float>]
	let indices: [Int32]
	let normals: [SIMD3<Float>]?
	let materials: [FactalsMaterial]
}
struct FactalsMaterial {
	let diffuse: NSColor
	let specular: NSColor
	let metallic: Float
	let roughness: Float
}

// MARK: - 2. SceneKit Renderer

// Updated SceneKitRenderer.swift
class SceneKitRenderer: FactalsRenderer {

	typealias NodeType 			= SCNNode
	typealias SceneType 		= SCNScene
	typealias ViewType 			= SCNView
	
	func createScene() -> SCNScene {
		return SCNScene()
	}
	
	func createNode() -> SCNNode {
		return SCNNode()
	}
	func createRenderableNode(from mesh: FactalsMesh) -> Result<Any, any Error> {
		fatalError(" ** createRenderableNode(from:) not yet implemented **")
	}
	
	func addChild(_ child: SCNNode, to parent: SCNNode) {
		parent.addChildNode(child)
	}
	
	func setPosition(_ position: SIMD3<Float>, for node: SCNNode) {
		node.position = SCNVector3(position.x, position.y, position.z)
	}
	
	func setColor(_ color: NSColor, for node: SCNNode) {
		node.color0 = color
	}
	
	// CHANGE: Return Result instead of direct SCNGeometry
	func createGeometry(from mesh: FactalsMesh) -> Result<Any, Error> {
		return createSCNGeometry(from: mesh).map { $0 as Any }
	}
	
	// NEW: Implement protocol requirement
	func createRenderableNode(from mesh: FactalsMesh) -> Result<SCNNode, Error> {
		switch createSCNGeometry(from: mesh) {
			case .success(let geometry):
				let node = SCNNode()
				node.geometry = geometry
				return .success(node)
			case .failure(let error):
				return .failure(error)
		}
	}
	
	// CHANGE: Return Result for consistency
	private func createSCNGeometry(from mesh: FactalsMesh)
							-> Result<SCNGeometry, Error> {
		do {
			let vertices = mesh.vertices.map {
				SCNVector3($0.x, $0.y, $0.z)
			}
			
			let source = SCNGeometrySource(vertices: vertices)
			let element = SCNGeometryElement(
				indices: mesh.indices,
				primitiveType: .triangles
			)
			 
			var sources = [source]
			if let normals = mesh.normals {
				let normalVectors = normals.map {
					SCNVector3($0.x, $0.y, $0.z)
				}
				let normalSource = SCNGeometrySource(normals: normalVectors)
				sources.append(normalSource)
			}
			 
			let geometry = SCNGeometry(sources: sources, elements: [element])
			 
			 // Apply materials
			geometry.materials = mesh.materials.map { factMaterial in
				let material = SCNMaterial()
				material.diffuse.contents = factMaterial.diffuse
				material.specular.contents = factMaterial.specular
				material.metalness.contents = factMaterial.metallic
				material.roughness.contents = factMaterial.roughness
				material.lightingModel = .physicallyBased
				return material
			}
			 
			return .success(geometry)
			 
		} catch {
			return .failure(error)
		}
	}
}
// MARK: - 3. RealityKit Renderer

// RealityKitRenderer.swift
import RealityKit
import RealityFoundation
								//
class RealityKitRenderer: FactalsRenderer {
	typealias  NodeType			= Entity
	typealias SceneType 		= Scene
	typealias  ViewType 		= ARView
	
	func createScene() -> Scene {
		bug;return createScene()
	}
	func createNode() -> Entity {
		return Entity()
	}
	func createRenderableNode(from mesh: FactalsMesh) -> Result<Any, any Error> {
		fatalError("*** NOT IMPLEMENTED")
	}
	func addChild(_ child:Entity, to parent:Entity) {
		parent.addChild(child)
	}
	func setPosition(_ position:SIMD3<Float>, for node:Entity) {
		node.transform.translation = position
	}
	
	func setColor(_ color:NSColor, for node:Entity) {
		// CHANGE: Better type checking and material handling
		if let modelEntity = node as? ModelEntity {
			let c = NSColor.init(
						red:   CGFloat(color.redComponent),
						green: CGFloat(color.greenComponent),
						blue:  CGFloat(color.blueComponent),
						alpha: CGFloat(color.alphaComponent)
					)
			let material = SimpleMaterial(color:c, roughness:0.5, isMetallic:false)
			modelEntity.model?.materials = [material]
		} else {
			// For non-ModelEntity nodes, store color for when geometry is added
			node.components.set(ColorComponent(color: color))
		}
	}
	// CHANGE: Return Result<MeshResource, Error> instead of throwing
	func createGeometry(from mesh: FactalsMesh) -> Result<Any,      any Error> {
//	func createGeometry(from mesh: FactalsMesh) -> Result<MeshResource, Error> {
		do {
			var descriptor = MeshDescriptor(name: "FactalsMesh")
			
			// Convert vertices to RealityKit format
			descriptor.positions = MeshBuffer(mesh.vertices)
			
			let triangleIndices:[UInt32] = mesh.indices.map { UInt32($0) }
			descriptor.primitives = .triangles(triangleIndices)
						//	// CHANGE: Proper triangle index conversion
						//	let triangleIndices = stride(from:0, to:mesh.indices.count, by:3)
						//					.compactMap { i -> (UInt32, UInt32, UInt32)? in
						//		guard i + 2 < mesh.indices.count else { return nil }
						//		return (
						//			UInt32(mesh.indices[i]),
						//			UInt32(mesh.indices[i + 1]),
						//			UInt32(mesh.indices[i + 2])
						//		)
						//	}
					//!!//	descriptor.primitives = .triangles(triangleIndices)
			
			// Add normals if available
			if let normals = mesh.normals {
				descriptor.normals = MeshBuffer(normals)
			}
			return .failure(RealityKitError.geometryCreationFailed("error" as! Error))
bug	//		return .success(try MeshResource.generate(from:triangleIndices) as Any)
//    @MainActor @preconcurrency public static func
//											 generate(from descriptors: [MeshDescriptor]) throws -> MeshResource

//			return .success(try MeshResource.generate(from:triangleIndices, vertexDescriptor:descriptor) as Any)
//			return .success(try MeshResource.generate(from: descriptor) as Any)
		} catch {
			return .failure(RealityKitError.geometryCreationFailed(error))
		}
	}
	
	// NEW: Implement protocol requirement
	func createRenderableNode(from mesh: FactalsMesh) -> Result<Entity, Error> {
		return createModelEntity(from: mesh).map { $0 as Entity }
	}
	
	// CHANGE: Return Result instead of throwing
	func createModelEntity(from mesh: FactalsMesh) -> Result<ModelEntity, Error> {
		switch createGeometry(from: mesh) {
			case .success(let meshResource):
				// CHANGE: Better material conversion
				let materials: [Material] = mesh.materials.isEmpty ? [SimpleMaterial()]
				: mesh.materials.map { factMaterial in
					SimpleMaterial(
						color: NSColor(
							red:   CGFloat(factMaterial.diffuse.redComponent),
							green: CGFloat(factMaterial.diffuse.greenComponent),
							blue:  CGFloat(factMaterial.diffuse.blueComponent),
							alpha: CGFloat(factMaterial.diffuse.alphaComponent)
						),
						roughness: MaterialScalarParameter(floatLiteral: factMaterial.roughness),
						isMetallic: factMaterial.metallic > 0.5
					)
				}
				let modelEntity = ModelEntity(
					mesh: meshResource as! MeshResource,
					materials: materials
				)
				return .success(modelEntity)
				
			case .failure(let error):
				return .failure(error)
		}
	}
}

// NEW: Custom error types for better error handling
enum RealityKitError: Error {
	case geometryCreationFailed(Error)
	case materialConversionFailed(String)
	case entityCreationFailed(String)
	
	var localizedDescription: String {
		switch self {
			case .geometryCreationFailed(let error):
				return "Failed to create RealityKit geometry:\(error.localizedDescription)"
			case .materialConversionFailed(let message):
				return "Failed to convert material: \(message)"
			case .entityCreationFailed(let message):
				return "Failed to create entity: \(message)"
		}
	}
}

// NEW: Component for storing color on non-ModelEntity nodes
struct ColorComponent: Component {
	let color: NSColor
}


// MARK: - 4. Update Usage in VewBase
// MARK: - 5. RendererManager
class RendererManager: ObservableObject {
	@Published var currentRenderer: RendererType = .sceneKit

	enum RendererType {
		case sceneKit
		case realityKit
	}

	func createRenderer() -> any FactalsRenderer {
		switch currentRenderer {
		case .sceneKit:
			return SceneKitRenderer()
		case .realityKit:
			return RealityKitRenderer()
		}
	}
}

// Create global instance
let rendererManager = RendererManager()

// Updated VewBase.swift usage
extension VewBase {
	
	func createNode(from mesh: FactalsMesh) -> Result<Any, Error> {
fatalError()//	return renderer.createRenderableNode(from: mesh)
	}
	
	// CHANGE: Handle Result types properly
	func addMeshToScene(_ mesh: FactalsMesh, at position: SIMD3<Float>) {
//		switch renderer.createRenderableNode(from: mesh) {
//			case .success(let node):
//				renderer.setPosition(position, for:node)
		switch renderer.createRenderableNode(from: mesh) {
			case .success(let node):
				if let scnRenderer = renderer as? SceneKitRenderer,
				   let scnNode = node as? SCNNode {
					scnRenderer.setPosition(position, for: scnNode)
				} else if let rkRenderer = renderer as? RealityKitRenderer,
						  let entity = node as? Entity {
					rkRenderer.setPosition(position, for: entity)
				}
				// Add to scene...
			case .failure(let error):
				print("Failed to create node: \(error)")
		}
	}
}

//	The main changes to RealityKitRenderer reflect:
//
//	1. Error Handling: All geometry creation now returns Result<T, Error> instead of
//	throwing
//	2. Proper API Usage: MeshDescriptor with correct buffer types and triangle indices
//	3. Material System: Better conversion between NSColor and RealityKit materials
//	4. Type Safety: Custom error types and component system for non-ModelEntity nodes
//	5. Protocol Consistency: Both renderers now follow the same error handling pattern
																
//	These changes make the RealityKitRenderer more robust and align it with
//	RealityKit's best practices while maintaining compatibility with your existing
//	SceneKit codebase.
																
