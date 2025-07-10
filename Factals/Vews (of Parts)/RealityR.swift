//
//  RealityR.swift
//  Factals
//
//  Created by Allen King on 7/8/25.
//
//  Migration notes and documentation for RealityKit integration
//
//  Current SceneKit Architecture Analysis
//
//  Your app extensively uses SceneKit with:
////  - SceneKitView.swift: NSViewRepresentable wrapper for SCNView
////  - ScnBase.swift: Core SceneKit management (738 lines)
////  - Custom SCNGeometry classes: SCNHemisphere, SCNTunnelHood, SCN3DPictureframe
////  - SCNNode extensions: Extensive customization (440+ lines)
////  - Complex 3D visualization: Network parts, links, and interactive elements
////
//		// MARK: - Phase 1: Renderer Abstraction Layer
//		
//protocol FactalsRenderer {			/// RendererProtocol.swift
//	associatedtype  NodeType
//	associatedtype SceneType
//	associatedtype  ViewType
//
//	func createScene() -> SceneType
//	func createNode() -> NodeType
//	func addChild(node:SCNNode, to parent:NodeType, atIndex index:Int?)
//
//	func setPosition(_ position: SIMD3<Float>, for node: NodeType)
//	func setColor(_ color: NSColor, for node: NodeType)
//	func createGeometry(from mesh: FactalsMesh) -> Any
//}
//struct FactalsMesh {				// Geometry abstraction
//	let vertices: [SIMD3<Float>]
//	let indices: [Int32]
//	let normals: [SIMD3<Float>]?
//	let materials: [FactalsMaterial]
//}
//struct FactalsMaterial {
//	let diffuse: NSColor
//	let specular: NSColor
//	let metallic: Float
//	let roughness: Float
//}
//
//	// MARK: - Phase 2A: SceneKit Renderers
//class SceneKitRenderer: FactalsRenderer {
//	typealias NodeType 			= SCNNode
//	typealias SceneType 		= SCNScene
//	typealias ViewType 			= SCNView
//
//	func createScene() -> SCNScene {
//		return SCNScene()
//	}
//
//	func createNode() -> SCNNode {
//		return SCNNode()
//	}
//	func addChild(node:SCNNode, to parent: SCNNode, atIndex index:Int?=nil) {
//		guard !parent.childNodes.contains(node) else { fatalError("no duplicates allowed")}
//		if let index {
//			parent.insertChildNode(node, at:index)
//		} else {
//			parent.addChildNode(node)
//		}
//	}
//	func setPosition(_ position: SIMD3<Float>, for node: SCNNode) {
//		node.position			= SCNVector3(position.x, position.y, position.z)
//	}
//	func setColor(_ color: NSColor, for node: SCNNode) {
//		node.geometry?.firstMaterial?.diffuse.contents = color
//	}
//	func createGeometry(from mesh: FactalsMesh) -> Any {
//		return createGeometry(from: mesh)
//	}
//
//	func createGeometry(from mesh: FactalsMesh) -> SCNGeometry {
//	  let source = SCNGeometrySource(vertices: mesh.vertices.map {
//		  SCNVector3($0.x, $0.y, $0.z)
//	  })
//	  let element = SCNGeometryElement(
//		  indices: mesh.indices,
//		  primitiveType: .triangles
//	  )
//	  return SCNGeometry(sources: [source], elements: [element])
//	}
//}
//								//
//	// MARK: - Phase 2B: RealityKit Renderers
//class RealityKitRenderer: FactalsRenderer {  // RealityKitRenderer.swift
//	typealias NodeType 			= Entity
//	typealias SceneType 		= Scene
//	typealias ViewType 			= ARView
//
//	func addChild(node:SCNNode, to parent:Entity, atIndex index:Int?) {
//		bug
//	}
//
//	func createScene() -> Scene {
//		bug;return createScene()
//	}
//	
//	func createNode() -> Entity {
//		return Entity()
//	}
//	
//	func setPosition(_ position:SIMD3<Float>, for node:Entity) {
//	
//	}
//	func setColor(_ color:NSColor, for node:Entity) {
//	
//	}
//								//
//	func createGeometry(from mesh: FactalsMesh) -> MeshResource {
//		var descriptor 			= MeshDescriptor()
//		descriptor.positions 	= .init(mesh.vertices)
//		descriptor.triangleIndices = .init(mesh.indices.map { UInt32($0) })
//		if let normals 			= mesh.normals {
//			descriptor.normals 	= .init(normals)
//		}
//		return try! MeshResource.generate(from: descriptor)
//	}
//}
//
//// MARK: - Phase 3: Update Core Classes
//// RendererManager.swift
//class RendererManager: ObservableObject {
//	@Published var currentRenderer: RendererType = .sceneKit
//
//	enum RendererType {
//		case sceneKit
//		case realityKit
//	}
//
//	func createRenderer() -> any FactalsRenderer {
//		switch currentRenderer {
//		case .sceneKit:
//			return SceneKitRenderer()
//		case .realityKit:
//				return RealityKitRenderer()
//		}
//	}
//}
//
//// Updated VewBase.swift
//class VewBase {
//	let rendererManager = RendererManager()
//	private var renderer: any FactalsRenderer
//
//	init() {
//		self.renderer = rendererManager.createRenderer()
//	}
//
//	func switchRenderer(to type: RendererManager.RendererType) {
//		rendererManager.currentRenderer = type
//		self.renderer = rendererManager.createRenderer()
//		rebuildScene()
//	}
//}
//
//	// MARK: - Phase 4: Create Unified View
//struct UnifiedSceneView: View {  	// UnifiedSceneView.swift
//	@StateObject private var rendererManager = RendererManager()
//	let scnBase: ScnBase?
//
//	var body: some View {
//	  Group {
//		  switch rendererManager.currentRenderer {
//		  case .sceneKit:
//			  SceneKitView(scnBase: scnBase, prefFpsC: .constant(30))
//		  case .realityKit:
//			  RealityKitView(scnBase: scnBase)
//		  }
//	  }
//	  .toolbar {
//		  ToolbarItem {
//			  Picker("Renderer", selection: $rendererManager.currentRenderer) {
//				  Text("SceneKit").tag(RendererManager.RendererType.sceneKit)
//				  Text("RealityKit").tag(RendererManager.RendererType.realityKit)
//			  }
//			  .pickerStyle(SegmentedPickerStyle())
//		  }
//	  }
//	  }
//  }
//
////	// MARK: - Phase 5: Migration Steps
////  1. Custom Geometry Migration:
////	- Convert SCNHemisphere → RealityKit MeshResource
////	- Convert SCN3DPictureframe → RealityKit equivalent
////	- Create geometry factory pattern
////  2. Event Handling Migration:
////	- SceneKit: processEvent(nsEvent:inVew:) → RealityKit: Gesture recognizers
////	- Mouse interaction: hitTest → RealityKit collision detection
////  3. Camera System Migration:
////	- SceneKit: SCNCamera + selfiePole → RealityKit: PerspectiveCamera
////	- Maintain same camera controls and animations
////  4. Physics Migration:
////	- SceneKit: SCNPhysicsBody → RealityKit: PhysicsBodyComponent
////	- Collision detection system updates
//
//	// MARK: - Phase 6: Backwards Compatibility
//  // LegacySupport.swift
//extension SCNNode {
//	func toRealityKitEntity() -> Entity {
//		let entity = Entity()
//		
//		// Convert transform
//		entity.transform = Transform(
//			scale: SIMD3<Float>(scale.x, scale.y, scale.z),
//			rotation: simd_quatf(transform),
//			translation: SIMD3<Float>(position.x, position.y, position.z)
//		)
//		
//		// Convert geometry
//		if let geometry = self.geometry {
//			let mesh = geometry.toFactalsMesh()
//			// Apply to entity...
//		}
//		
//		return entity
//}
//  }
//
//  Implementation Timeline
//
//  Week 1-2: Create abstraction layer and basic renderer interfaces
//  Week 3-4: Implement SceneKit renderer (refactor existing code)
//  Week 5-6: Implement RealityKit rendererWeek 7-8: Create unified view and switching
//  mechanism
//  Week 9-10: Migrate custom geometries and event handling
//  Week 11-12: Testing, performance optimization, and polish
//
//  Benefits of This Approach
//
//  1. Gradual Migration: Keep existing functionality while building new
//  2. Easy Switching: Runtime renderer selection for testing
//  3. Maintainable: Clean separation of concerns
//  4. Future-Proof: Easy to add new rendering backends
//  5. Backwards Compatible: Existing SceneKit code continues working
//
//  This strategy allows you to maintain your complex 3D visualization while gradually
//  migrating to RealityKit, with the flexibility to switch between renderers as
//  needed.
//
//⏺ Update Todos
//  ⎿  ☒ Analyze current SceneKit implementation in the codebase
//	 ☒ Identify key SceneKit components that need migration
//	 ☒ Design abstraction layer for renderer switching
//	 ☒ Create migration strategy document
