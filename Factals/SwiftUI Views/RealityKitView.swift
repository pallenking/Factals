//
//  RealityKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import RealityKit
import SceneKit
import AppKit
import Combine

// MARK: SCNGeometry → RealityKit Extensions
extension SCNGeometry {
	func toMeshResource() -> MeshResource? {
		switch self {
		case let box as SCNBox:
			return .generateBox(width: Float(box.width), height: Float(box.height), depth: Float(box.length))
		case let sphere as SCNSphere:
			return .generateSphere(radius: Float(sphere.radius))
		case let cylinder as SCNCylinder:
			return .generateCylinder(height: Float(cylinder.height), radius: Float(cylinder.radius))
		case let cone as SCNCone:
			return .generateCone(height: Float(cone.height), radius: Float(cone.bottomRadius))
		case let plane as SCNPlane:
			return .generatePlane(width: Float(plane.width), depth: Float(plane.height))
		case let capsule as SCNCapsule:
			// RealityKit doesn't have generateCapsule, approximate with cylinder
			return .generateCylinder(height: Float(capsule.height), radius: Float(capsule.capRadius))
		default:
			// Custom geometries - would need vertex extraction (Phase 2 detail)
			print("⚠️ Geometry type \(type(of: self)) not yet supported, using placeholder")
			return .generateBox(size: 0.1) // Placeholder
		}
	}
}

extension SCNMaterial {
	func toSimpleMaterial() -> SimpleMaterial {
		var material = SimpleMaterial()
		if let color = diffuse.contents as? NSColor {
			material.color = .init(tint: color)
		}
		return material
	}
}

struct RealityKitContentView: View {
	@Bindable var vewBase: VewBase

	var body: some View {
		logApp(3, "NavigationStack:(tabViewSelect): Generating content for slot:\(vewBase.slot_)")
		return HStack (alignment:.top) {
			RealityKitView(vewBase: vewBase)
			 .frame(maxWidth: .infinity)
			 .border(.yellow, width:4)	//(.black, width:1)
			VStack {
				VStack {
					Text("Reality Kit:").font(Font.title)
					VewBaseBar(vewBase: Binding(
						get: { vewBase },
						set: { _ in }  // VewBase itself doesn't change, only its properties
					))
				}
				 .background(Color(red:1.0, green:1.0, blue:0.9))
				SelfiePoleBar(vewBase: vewBase)		// Pass parent to maintain observation chain
				Divider()
				InspectorsVew(vewBase:vewBase)
			}
		}
	}
}

func realityKitContentView(vewBase:Binding<VewBase>) -> some View {
	RealityKitContentView(vewBase: vewBase.wrappedValue)
}


class ArView : ARView {
	typealias Body = ARView
	var vewBase: VewBase? = nil
	var sceneAnchor: AnchorEntity?
	var cameraEntity: Entity?
	var shapeBaseWrapper: EntityWrapperNode?  // Bridge to SceneKit interface

	// Don't override myVewBase - use default from HeadsetView extension
	// which finds existing VewBase with loaded network

	func makeLights() {
		guard let anchor = sceneAnchor else { return }
		let light = DirectionalLight()
		light.light.intensity = 1000
		light.position = [0, 5, 5]
		light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
		light.name = "DirectionalLight"
		anchor.addChild(light)
	}

	func makeCamera() {
		// RealityKit camera is managed by ARView automatically
		// Create a reference entity for camera position if needed
		cameraEntity = Entity()
		cameraEntity?.name = "*-camera"
	}

	func makeAxis() {
		guard let anchor = sceneAnchor else { return }
		// Create axis markers (X=red, Y=green, Z=blue)
		let axisSize: Float = 0.5
		createAxisLine(anchor: anchor, color: .red, axis: SIMD3<Float>(1,0,0), length: axisSize, name: "AxisX")
		createAxisLine(anchor: anchor, color: .green, axis: SIMD3<Float>(0,1,0), length: axisSize, name: "AxisY")
		createAxisLine(anchor: anchor, color: .blue, axis: SIMD3<Float>(0,0,1), length: axisSize, name: "AxisZ")
	}

	private func createAxisLine(anchor: Entity, color: NSColor, axis: SIMD3<Float>, length: Float, name: String) {
		let mesh = MeshResource.generateCylinder(height: length * 2, radius: 0.005)
		let material = SimpleMaterial(color: color, isMetallic: false)
		let entity = ModelEntity(mesh: mesh, materials: [material])
		entity.name = name
		// Rotate to align with axis
		if axis.x != 0 {
			entity.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(0,0,1))
		} else if axis.z != 0 {
			entity.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(1,0,0))
		}
		anchor.addChild(entity)
	}

	func updateCamera(from selfiePole: SelfiePole) {
		guard let vewBase = vewBase else { return }
		// Transform camera using SelfiePole mathematics
		let self2focus = selfiePole.transform(lookAtVew: vewBase.lookAtVew)
		let focus2self = self2focus.inverse()
		// Update ARView camera (note: ARView camera is implicit, update scene anchor instead)
		sceneAnchor?.transform = Transform(matrix: simd_float4x4(focus2self))
	}

	/// Setup RealityKit update loop (equivalent to SceneKit's renderer delegate)
	func setupUpdateLoop() {
		var frameCount = 0

		// Subscribe to scene updates - called every frame
		scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
			guard let self = self, let vewBase = self.vewBase else { return }

			// Only update every 2nd frame to reduce load (30fps instead of 60fps)
			frameCount += 1
			guard frameCount % 2 == 0 else { return }

			// Call updateVSP on main thread (same as SceneKit does)
			DispatchQueue.main.async {
				vewBase.factalsModel?.doPartNViewsLocked(workNamed:"AR_updateVSP", logIf:false) {
					$0.updateVSP()
				}
			}
		}.store(in: &cancellables)
		print("🔄 ArView update loop started (30fps)")
	}

	private var cancellables: Set<AnyCancellable> = []
}
extension ArView : HeadsetView {
	var cameraXform: SCNMatrix4 {
		get {
			guard let transform = sceneAnchor?.transform else { return .identity }
			return SCNMatrix4(transform.matrix)
		}
		set(v) {
			sceneAnchor?.transform = Transform(matrix: simd_float4x4(v))
		}
	}
	var shapeBase: SCNNode {
		get {
			// Return wrapper node that bridges to RealityKit Entity hierarchy
			if let wrapper = shapeBaseWrapper {
				return wrapper
			}
			// Create wrapper if it doesn't exist yet
			if let anchor = sceneAnchor {
				let wrapper = EntityWrapperNode(wrapping: anchor)
				shapeBaseWrapper = wrapper
				return wrapper
			}
			// Fallback: return empty node if no anchor yet
			return SCNNode()
		}
		set { /* Ignored in RealityKit - entities are managed directly */ }
	}
	var isSceneKit: Bool { false }

	func configure(from: FwConfig) {
		// Configuration handled in makeNSView
	}

	/// RealityKit's HeadsetView
	var headsetView : HeadsetView? { self }//.delegate as? ScnBase)?.headsetView}
	var animatePhysics: Bool {
		get { bug; return false													}
		set { bug																}
	}
	func hitTest3D(_ point:NSPoint, options:[SCNHitTestOption:Any]?) -> [HitTestResult] {
		let cgPoint 			= CGPoint(x: point.x, y: point.y)

		// Use RealityKit's entity hit testing (not AR plane detection)
		let entities 			= self.entities(at: cgPoint)

		return entities.compactMap { entity in
			// Get world position from entity
			let worldPos 		= entity.position(relativeTo: nil)
			return HitTestResult(
				node: entity as Any,
				position: worldPos
			)
		}
	}
}

// MARK: - RealityKitView (NSViewRepresentable - parallel to SceneKitView)
struct RealityKitView: NSViewRepresentable {
	@Bindable var vewBase: VewBase

	typealias Visible = Entity
	typealias Vect3 = SIMD3<Float>
	typealias Vect4 = SIMD4<Float>
	typealias Matrix4x4 = simd_float4x4
	typealias NSViewType = ArView

	func makeNSView(context: Context) -> ArView {
		let arView = ArView(frame: .zero)

		// Create and configure scene anchor
		let anchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
		anchor.name = "shapeBase"
		arView.sceneAnchor = anchor
		arView.scene.addAnchor(anchor)

		// Create wrapper node for SceneKit/RealityKit bridge
		arView.shapeBaseWrapper = EntityWrapperNode(wrapping: anchor)

		// Initialize VewBase with headsetView reference
		vewBase.headsetView = arView
		arView.vewBase = vewBase

		arView.makeLights()
		arView.makeCamera()
		arView.makeAxis()

		// Setup update loop to call updateVSP() every frame (like SceneKit's renderer delegate)
		arView.setupUpdateLoop()

		// NOTE: Don't build Entity tree here - VewBase.tree exists but SCNNodes don't have geometry yet
		// Entity tree will be built on first updateVSP() call when dirty:.vew is set
		print("✅ ArView initialized (Entity tree will build on first updateVSP)")

		return arView
	}

	func updateNSView(_ arView: ArView, context: Context) {
		// Update frame rate if needed
	}
}

// MARK: - Legacy RealityView-based implementation (for reference)
#if false  // Disabled - using NSViewRepresentable wrapper instead
struct RealityKitViewOLD: View {
	@Bindable      var vewBase: VewBase
	@State 		   var focusPosition:Vect3 			= Vect3(0, 0, 0)
	@State 		   var selectedPrimitiveName:String = ""
	@State private var lastDragLocation:CGPoint		= .zero
	@State private var isDragging	:Bool 			= false
	@State private var viewSize		:CGSize 		= .zero
	@State private var sceneBase	:AnchorEntity?	= nil
	@State private var isUpdatingFromUI:Bool		= false		// Prevent feedback loops

	typealias Visible			= Entity
	typealias Vect3 			= SIMD3<Float>
	typealias Vect4 			= SIMD4<Float>
	typealias Matrix4x4 		= simd_float4x4

	var body: some View {
		VStack {
			GeometryReader { geometry in
				RealityView { content in
					sceneBase		= AnchorEntity(.world(transform:matrix_identity_float4x4))
					sceneBase!.name = "shapeBase"			// Create anchor for the scene

					// Load from VewBase.tree (NEW: Phase 4)
					rebuildEntityTree(vewBase: vewBase, rootAnchor: sceneBase!)

					// Keep test scenery for now (comment out later when tree loading works)
		/**/		RkMakeScenery(anchor:sceneBase!)
//		/**/		XxMakeScenery(anchor:sceneBase!)

					content.add(sceneBase!)
					logApp(3, "RealityView loaded with \(sceneBase!.children.count) children, " +
							  "\n\t rotation: \(   		 sceneBase!.transform.rotation) " 		+
							  "\n\t translation: \(		 sceneBase!.transform.translation)"			)
			//		let scnBase 	= ScnBase(headsetView:rv)		// scnBase.headsetView = rv // important BACKPOINTER
			//		rv.delegate		= scnBase 						// (the SCNSceneRendererDelegate)
			//		rv.scene		= scnBase.headsetView!.scene	// wrapped.scnScene //headsetView.scene //.scene
			//		let vewBase		= fm.NewVewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
			//		vewBase.headsetView = rv
				} update: { content in
				  // Update camera transform using SelfiePole mathematics
					guard let anchor = content.entities.first(where: { $0.name == "shapeBase" })
					 else { return 												}
					let self2focus	= vewBase.selfiePole.transform(lookAt:SCNVector3(focusPosition))// SCNMatrix4
					let focus2self	= self2focus.inverse()									// SCNMatrix4
	/**/			anchor.transform = Transform(matrix:Matrix4x4(focus2self))
					updateHighlighting(from:self, anchor: anchor as! AnchorEntity)
					logApp(3, "RealityView update with \(anchor.children.count) children,\n\t rotation:\(anchor.transform.rotation)\n\t translation: \(anchor.transform.translation)")
				//	printTreeBase(entity:sceneBase)													// ENTITY
//				  // Update camera transform using SelfiePole mathematics
//					if let sceneBase 	  = content.entities.first(where: { $0.name == "shapeBase" }) {
//						let self2focus = selfiePole.transform(lookAt:SCNVector3(focusPosition))// SCNMatrix4
//						let focus2self	= self2focus.inverse()									// SCNMatrix4
//		/**/			sceneBase.transform = Transform(matrix:Matrix4x4(focus2self))
//						updateHighlighting(from:self, sceneBase: sceneBase as! AnchorEntity)
//						logApp(3, "RealityView update with \(sceneBase.children.count) children,\n\t rotation:\(sceneBase.transform.rotation)\n\t translation: \(anchor.transform.translation)")
//					//	printTreeBase(entity:sceneBase)													// ENTITY
//					}
				}
				.background(Color.gray.opacity(0.1))	//yellow)//
				.gesture(
					DragGesture(minimumDistance: 0)
					 .onChanged { value in
					 	if !isDragging {
					 		lastDragLocation = value.location
					 		isDragging = true
					 		return  // Skip first update to establish baseline
					 	}
					 	// Use incremental delta from last position (not from start)
						let dx = Float(value.location.x - lastDragLocation.x) / 3.0  // Left/right: 1/3 strength
						let dy = Float(value.location.y - lastDragLocation.y) * 5.0  // Up/down: 5x strength
					 	vewBase.selfiePole.updateFromMouseDelta(deltaX:dx, deltaY:dy, sensitivity:0.5)

					 	lastDragLocation = value.location
					 }
					 .onEnded { _ in
					 	isDragging	= false
					 }
				)
				.onTapGesture { location in
					performHitTest(from:self, at:location, viewSize: geometry.size)
				}
				.background(ScrollWheelCaptureView(selfiePole:$vewBase.selfiePole))
				.onAppear {
					setupScrollWheelMonitor(realityKitView:self)
				}
				.onChange(of: geometry.size) { _, newSize in
					viewSize = newSize
				}
			}
			//Text("TEST POINT: \(sceneBase?.children.count ?? -1)")
		}
	}
	func XxMakeScenery(anchor:AnchorEntity) {
		// ??? Add lighting so we can see the materials
		let light = DirectionalLight()
		light.light.intensity = 1000
		light.position = [0, 5, 5]
		light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
		anchor.addChild(light)

		// Standard SceneKit primitives 	- Row 1
		var position = Vect3(-4, 0, -2)	// Moved back from origin so camera can see
		let spacing: Float 			= 0.8

		let boxEnt1 				= RksBox(width:0.3, height:0.3, length:0.3)
		boxEnt1.position 			= position;		position.x += spacing
		boxEnt1.name 				= "RksBox1"
		boxEnt1.model?.materials 	= [SimpleMaterial(color:.blue, isMetallic:false)]
		anchor.addChild(boxEnt1)
	}
	func RkMakeScenery(anchor:AnchorEntity) {
		// Add lighting so we can see the materials
		let light = DirectionalLight()
		light.light.intensity = 1000
		light.position = [0, 5, 5]
		light.look(at: [0, 0, 0], from: light.position, relativeTo: nil)
		anchor.addChild(light)

		ArkOriginMark(size: 0.5, position:Vect3(0, 0, 0), anchor:anchor, name:"OriginMark")

		// Standard SceneKit primitives 	- Row 1
		var position = Vect3(-4, 0, -2)	// Moved back from origin so camera can see
		let spacing: Float 			= 0.8

		let boxEnt1 				= RksBox(width:0.3, height:0.3, length:0.3)
		boxEnt1.position 			= position;		position.x += spacing
		boxEnt1.name 				= "RksBox1"
		boxEnt1.model?.materials 	= [SimpleMaterial(color:.blue, isMetallic:false)]
		anchor.addChild(boxEnt1)
		
		let boxEnt2 				= RksBox(width:0.4, height:0.2, length:0.3)
		boxEnt2.position 			= position;		position.x += spacing
		boxEnt2.name 				= "RksBox2"
		boxEnt2.model?.materials 	= [SimpleMaterial(color: .cyan, isMetallic: false)]
		anchor.addChild(boxEnt2)
//	return ; nop
		let sphere 					= RksSphere(radius: 0.15)
		sphere.position 			= position
		sphere.name 				= "RksSphere"
		sphere.model?.materials 	= [SimpleMaterial(color: .red, isMetallic: false)]
		anchor.addChild(sphere)
		position.x 					+= spacing

		let cylinder 				= RksCylinder(height: 0.4, radius: 0.1)
		cylinder.position 			= position;		position.x += spacing
		cylinder.name 				= "Cylinder"
		cylinder.model?.materials 	= [SimpleMaterial(color: .green, isMetallic: false)]
		anchor.addChild(cylinder)
		
		let cone 					= RksCone(height: 0.4, radius: 0.15)
		cone.position 				= position;		position.x += spacing
		cone.name 					= "Cone"
		cone.model?.materials 		= [SimpleMaterial(color: .yellow, isMetallic: false)]
		anchor.addChild(cone)
		
		let plane 					= RksPlane(width: 0.4, depth: 0.3)
		plane.position 				= position;		position.x += spacing
		plane.name 					= "Plane"
		plane.model?.materials 		= [SimpleMaterial(color: .lightGray, isMetallic: false)]
		anchor.addChild(plane)

		// Standard SceneKit primitives 	- Row 2
		position 					= [-4, 0, -1]
		let capsule 				= RksCapsule(height: 0.4, radius: 0.1)
		capsule.position 			= position;		position.x += spacing
		capsule.name 				= "Capsule"
		capsule.model?.materials = [SimpleMaterial(color: .purple, isMetallic: false)]
		anchor.addChild(capsule)

		// Custom geometries 				- Row 3
		position 					= [-4, 0, 0]
		if let hemisphere 			= RksHemisphere(radius: 0.15, slice: 0.0, stepsAround: 16, stepsBetweenPoles: 8, cap: true) {
			hemisphere.position 	= position;		position.x += spacing
			hemisphere.name 		= "Hemisphere"
			hemisphere.model?.materials = [SimpleMaterial(color: .orange, isMetallic: false)]
			anchor.addChild(hemisphere)
		}
		
		let point 					= RksPoint(radius: 0.02)
		point.position 				= position;		position.x += spacing
		point.name 					= "Point"
		point.model?.materials 		= [SimpleMaterial(color: .black, isMetallic: false)]
		anchor.addChild(point)
		
		if let torus 				= RksTorus(majorRadius: 0.15, minorRadius: 0.05) {
			torus.position 			= position;		position.x += spacing
			torus.name 				= "Torus"
			torus.model?.materials 	= [SimpleMaterial(color: .magenta, isMetallic: false)]
			anchor.addChild(torus)
		}
		
		let tube 					= RksTube(height: 0.4, radius: 0.15)
		tube.position 				= position;		position.x += spacing
		tube.name 					= "Tube"
		tube.model?.materials 		= [SimpleMaterial(color: .brown, isMetallic: false)]
		anchor.addChild(tube)
		
		if let pyramid 				= RksPyramid(width: 0.3, height: 0.4, length: 0.3) {
			pyramid.position 		= position;		position.x += spacing
			pyramid.name 			= "Pyramid"
			pyramid.model?.materials = [SimpleMaterial(color: .systemTeal, isMetallic: false)]
			anchor.addChild(pyramid)
		}

		// Custom geometries - Row 4
		position					= [-4, 0, 1]

		if let tunnelHood 			= RksTunnelHood(width: 0.4, height: 0.3, depth: 0.2) {
			tunnelHood.position 	= position;		position.x += spacing
			tunnelHood.name 		= "TunnelHood"
			tunnelHood.model?.materials = [SimpleMaterial(color: .systemGray, isMetallic: false)]
			anchor.addChild(tunnelHood)
		}

		if let pictureframe 		= RksPictureframe(width: 0.4, height: 0.3, thickness: 0.02) {
			pictureframe.position 	= position;	position.x += spacing
			pictureframe.name 		= "Pictureframe"
			pictureframe.model?.materials = [SimpleMaterial(color: .systemBrown, isMetallic: false)]
			anchor.addChild(pictureframe)
		}

		if let pictureframe3D 		= Rks3DPictureframe(width: 0.4, height: 0.3, depth: 0.1, frameWidth: 0.05) {
			pictureframe3D.position = position;	position.x += spacing
			pictureframe3D.name 	= "3DPictureframe"
			pictureframe3D.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
			anchor.addChild(pictureframe3D)
		}
									
		if let cornerTriangle 		= RksCornerTriangle(size: 0.3) {
			cornerTriangle.position = position;	position.x += spacing
			cornerTriangle.name 	= "CornerTriangle"
			cornerTriangle.model?.materials = [SimpleMaterial(color: .systemIndigo, isMetallic: false)]
			anchor.addChild(cornerTriangle)
		}

		if let openBox 				= RksOpenBox(width: 0.3, height: 0.3, depth: 0.3, thickness: 0.02) {
			openBox.position 		= position;		position.x += spacing
			openBox.name 			= "OpenBox"
			openBox.model?.materials = [SimpleMaterial(color: .systemPink, isMetallic: false)]
			anchor.addChild(openBox)
		}

		// Ground plane for reference
		let groundPlane 			= RksGroundPlane(width: 8, depth: 4)
		groundPlane.position 		= [0, -0.2, 0]
		groundPlane.name 			= "GroundPlane"
		anchor.addChild(groundPlane)
	}

	func ArkOriginMark(size:Float, position:Vect3, anchor:AnchorEntity, name: String = "OriginMark") {
		// Create 3 thin cylinders showing X, Y, Z axes
		// X-axis: Red   cylinder along X direction
		// Y-axis: Green cylinder along Y direction
		// Z-axis: Blue  cylinder along Z direction
		
		let lineRadius: Float 		= 0.005  	// Very thin cylinders to simulate lines
		let lineLength 				= size * 2	// Full length from -size to +size
									
		// X-axis (Red)
		let xAxisMesh 				= MeshResource.generateCylinder(height: lineLength, radius: lineRadius)
		let xAxisMaterial 			= SimpleMaterial(color: .red, isMetallic: false)
		let xAxisEntity 			= ModelEntity(mesh: xAxisMesh, materials: [xAxisMaterial])
		// Rotate 90 degrees around Z-axis to align with X-axis
		xAxisEntity.transform.rotation = simd_quatf(angle: Float.pi/2, axis: Vect3(0, 0, 1))
		xAxisEntity.position 		= position
		xAxisEntity.name 			= "\(name)_X"
		anchor.addChild(xAxisEntity)
		
		// Y-axis (Green) - default cylinder orientation is already Y-axis
		let yAxisMesh 				= MeshResource.generateCylinder(height: lineLength, radius: lineRadius)
		let yAxisMaterial 			= SimpleMaterial(color: .green, isMetallic: false)
		let yAxisEntity 			= ModelEntity(mesh: yAxisMesh, materials: [yAxisMaterial])
		yAxisEntity.position 		= position
		yAxisEntity.name 			= "\(name)_Y"
		anchor.addChild(yAxisEntity)
		
		// Z-axis (Blue)
		let zAxisMesh = MeshResource.generateCylinder(height: lineLength, radius: lineRadius)
		let zAxisMaterial = SimpleMaterial(color: .blue, isMetallic: false)
		let zAxisEntity = ModelEntity(mesh: zAxisMesh, materials: [zAxisMaterial])
		// Rotate 90 degrees around X-axis to align with Z-axis
		zAxisEntity.transform.rotation = simd_quatf(angle: Float.pi/2, axis: Vect3(1, 0, 0))
		zAxisEntity.position = position
		zAxisEntity.name = "\(name)_Z"
		anchor.addChild(zAxisEntity)
	}

	func RksBox(width:Float, height:Float, length:Float, chamferRadius:Float=0.0) -> ModelEntity {
		let boxMesh 				= MeshResource.generateBox(size:[width, height, length])
		let boxMaterial 			= SimpleMaterial(color:.gray, isMetallic:false)
		let boxEntity 				= ModelEntity(mesh:boxMesh, materials:[boxMaterial])
		return boxEntity
	}

	func performHitTest(from rkView:RealityKitView, at location: CGPoint, viewSize: CGSize) {
		// NOTE: Full 3D raycasting hit testing would require direct ARView access.
		// SwiftUI's RealityView doesn't expose the underlying ARView for hit testing in gesture handlers.
		// For now, using entity position-based approximation suitable for this grid demo.
		//
		// TODO: Refactor to use UIViewRepresentable wrapper to get direct ARView access for proper hitTest3D()

		guard viewSize.width > 0 && viewSize.height > 0 else { return }

		// Normalize coordinates to view bounds (using actual view size, not hardcoded)
		let normalizedX 			= Float(location.x / viewSize.width)
		let normalizedY 			= Float(location.y / viewSize.height)

		// Map to our grid layout (5 columns, 4 rows) /// Modifying state during view update, this will cause undefined behavior.
		let gridX 					= min(Int(normalizedX * 5), 4)  // Clamp to 0-4
		let gridY 					= min(Int(normalizedY * 4), 3)  // Clamp to 0-3

		// Map to actual positions used in makeScenery
		let spacing: Float 			= 0.8
		let startX: Float 			= -4
		let startZ: Float 			= -2

		// Calculate the focus position based on grid coordinates
		let focusX 					= startX + Float(gridX) * spacing
		let focusZ 					= startZ + Float(gridY)

		rkView.focusPosition 		= Vect3(focusX, 0, focusZ)

		// Determine which primitive was selected for display purposes
		let primitiveNames 			= [
			"RksBox1", 	  "RksBox2", 	  "RksSphere", 		"Cylinder", 	  "Cone",		// Row 0
			"Plane", 	  "Capsule", 	  "", 				"", 			  "",			// Row 1
			"Hemisphere", "Point", 		  "Torus", 			"Tube", 		  "Pyramid",	// Row 2
			"TunnelHood", "Pictureframe", "3DPictureframe", "CornerTriangle", "OpenBox"	// Row 3
		]

		let primitiveIndex 			= gridY * 5 + gridX
		let primitiveName 			= primitiveIndex < primitiveNames.count ? primitiveNames[primitiveIndex] : "Unknown"

		rkView.selectedPrimitiveName = primitiveName

		// Reset SelfiePole to a good viewing angle for the new focus point (FIX #4: Update state properly)
		rkView.vewBase.selfiePole.spin 		=  0.0
		rkView.vewBase.selfiePole.gaze 		= -0.3  // Slight downward angle
		rkView.vewBase.selfiePole.zoom 		=  1.0
		rkView.vewBase.selfiePole.ortho 	=  0.0  // Default to perspective

		logApp(3, "Selected: \(primitiveName) at grid(\(gridX),\(gridY)) focus: \(rkView.focusPosition)")
		logApp(3, "SelfiePole reset - spin: \(rkView.vewBase.selfiePole.spin), gaze: \(rkView.vewBase.selfiePole.gaze), " +
					"zoom: \(rkView.vewBase.selfiePole.zoom), ortho: \(rkView.vewBase.selfiePole.ortho)")
	}
									
	private func setupScrollWheelMonitor(realityKitView rkView:RealityKitView) {
		NSEvent.addLocalMonitorForEvents(matching:.scrollWheel) { event in
			print("NSEvent scroll wheel detected: deltaY=\(event.scrollingDeltaY)")
			let scrollDelta 		= event.scrollingDeltaY
			if abs(scrollDelta) < 0.0001 { }// Ignore very small deltas
			else if scrollDelta > 0 		// Scroll up - zoom in (closer)
			{	rkView.vewBase.selfiePole.zoom = max(0.00010, rkView.vewBase.selfiePole.zoom / 1.05) }
			else 						// Scroll down - zoom out (farther)
			{	rkView.vewBase.selfiePole.zoom = min(10000.0, rkView.vewBase.selfiePole.zoom * 1.05) }
			print("SelfiePole zoom updated: \(rkView.vewBase.selfiePole.zoom)")
			return nil						// Return nil to prevent the event from being handled by other views
		}
	}
		
	private func updateHighlighting(from rkView:RealityKitView,  anchor: AnchorEntity) {
		// Reset all materials to original and highlight selected
		for child in anchor.children {
			if let modelEntity = child as? ModelEntity {
				if child.name == rkView.selectedPrimitiveName {
					// Highlight selected entity
					var highlightMaterial = SimpleMaterial(color: .yellow, isMetallic: true)
					highlightMaterial.roughness = 0.1
					modelEntity.model?.materials = [highlightMaterial]
				} else {
					// Keep original material (simplified - in practice you'd store originals)
					// This is a simplified approach for the demo
				}
			}
		}
	}
}
 // Scroll wheel capture using NSViewRepresentable
struct ScrollWheelCaptureView: NSViewRepresentable {
	@Binding var selfiePole: SelfiePole
	
	func makeNSView(context: Context) -> ScrollWheelNSView {
		let view = ScrollWheelNSView()
		view.selfiePoleBinding = $selfiePole
		return view
	}
	func updateNSView(_ nsView: ScrollWheelNSView, context: Context) {
		nsView.selfiePoleBinding = $selfiePole
	}
}

class ScrollWheelNSView: NSView {
	var selfiePoleBinding: Binding<SelfiePole>?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	private func setupView() {
		wantsLayer = true
		layer?.backgroundColor = NSColor.clear.cgColor
	}
	
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		// Ensure we can receive scroll events when added to window
		window?.makeFirstResponder(self)
	}
								
	override func scrollWheel(with event:NSEvent) {
		print("ScrollWheel captured: deltaY=\(event.scrollingDeltaY)")
		guard let binding 		= selfiePoleBinding
		 else {	return super.scrollWheel(with:event)							}
		let scrollDelta 		= event.scrollingDeltaY
		if 		 scrollDelta >  0.1 		// Scroll up 	- zoom in (closer)
		{	binding.wrappedValue.zoom = max(0.1,  binding.wrappedValue.zoom / 1.05) }
		 else if scrollDelta < -0.1 				// Scroll down 	- zoom out (farther)
		{	binding.wrappedValue.zoom = min(10.0, binding.wrappedValue.zoom * 1.05) }
	}
	override var acceptsFirstResponder: Bool { return true }
}
#endif  // End legacy RealityKitViewOLD code

// MARK: - Vew → Entity Tree Builder (Standalone Functions)
/// Build RealityKit Entity tree from Vew tree (manual update approach)
/// Call this to populate RealityKit scene from VewBase.tree
func buildEntityTree(from vew: Vew, parent: Entity) -> Entity? {
	// Create Entity for this Vew
	let entity = Entity()
	entity.name = vew.name

	// Store reference in Vew for future updates
	vew.entity = entity

	// Convert SCNNode geometry to RealityKit MeshResource
	if let geometry = vew.scn.geometry,
	   let meshResource = geometry.toMeshResource() {

		// Convert materials
		var materials: [SimpleMaterial] = []
		let scnMaterials = geometry.materials
		if !scnMaterials.isEmpty {
			materials = scnMaterials.map { $0.toSimpleMaterial() }
		} else {
			// Default material if none specified
			materials = [SimpleMaterial(color: .gray, isMetallic: false)]
		}

		// Create ModelEntity with geometry and materials
		let modelEntity = ModelEntity(mesh: meshResource, materials: materials)
		modelEntity.name = vew.name + "_model"
		entity.addChild(modelEntity)
		print("   ✓ Created ModelEntity for '\(vew.name)' - geometry: \(type(of: geometry))")
	} else {
		print("   ⊘ No geometry for '\(vew.name)' - just container entity")
	}

	// Copy transform from SCNNode to Entity
	let scnTransform = vew.scn.transform
	entity.transform = Transform(matrix: simd_float4x4(scnTransform))

	// Add to parent
	parent.addChild(entity)

	// Recursively build children
	for childVew in vew.children {
		_ = buildEntityTree(from: childVew, parent: entity)
	}

	return entity
}

/// Rebuild entire Entity tree from VewBase.tree
/// Call this after loading a new network or when tree structure changes
func rebuildEntityTree(vewBase: VewBase, rootAnchor: Entity) {
	// Debug: Show what we're building from
	print("🔍 rebuildEntityTree called:")
	print("   VewBase.tree name: '\(vewBase.tree.name)'")
	print("   VewBase.tree children: \(vewBase.tree.children.count)")
	print("   VewBase.tree has geometry: \(vewBase.tree.scn.geometry != nil)")

	// Remove all existing children (except lights, camera markers, etc.)
	for child in rootAnchor.children {
		if !child.name.contains("Light") &&
		   !child.name.contains("OriginMark") &&
		   !child.name.contains("GroundPlane") {
			child.removeFromParent()
		}
	}

	// Build new tree from VewBase.tree
	let builtEntity = buildEntityTree(from: vewBase.tree, parent: rootAnchor)

	print("🌳 RealityKit Entity tree rebuilt from VewBase.tree")
	print("   Built entity name: '\(builtEntity?.name ?? "nil")'")
	print("   Root anchor children count: \(rootAnchor.children.count)")
}

 /// Debugging
func printTreeBase(entity: Entity, indent: String = "") {
	print("\(indent)\(type(of:entity)):\(entity.name)' - children:\(entity.children.count)")
	for child in entity.children {
		printTreeBase(entity:child, indent: indent + "  ")
	}
}
