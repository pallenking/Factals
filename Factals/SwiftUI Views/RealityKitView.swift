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

class ArView : ARView {
	typealias Body = ARView
	weak var delegate: SCNSceneRendererDelegate?
}

/*
weak var delegate: (any SCNSceneRendererDelegate)? { get set }
 */
extension ArView : Gui {
	func configure(from: FwConfig) 				{	bug 						}
	func makeScenery(anchorEntity:AnchorEntity) {	bug 						}
//		gui!.makeScenery (anchorEntity:anchorEntity)
//	}
	func makeAxis()   {	}
	func makeCamera() {	}
	func makeLights() {	}
	var cameraXform: SCNMatrix4 {
		get {	.identity														}
		set {																	}
	}
	var anchor: SCNNode {
		get {	bug; return SCNNode()											}
		set {		}
	}
	/// RealityKit's Gui
	var gui : Gui? { self														}
//	var gui : Gui? { (self.delegate as? ScnBase)?.gui							}
	var isScnView: Bool { false 												}
	var vewBase: VewBase! {
		get {			bug; return self.vewBase								}
		set {			bug; return self.vewBase = newValue 								}
	}
//	var getScene : SCNScene? {
//		get { bug; return self.scene as? SCNScene								}
//		set { fatalError("RealityKit doesn't use SCNScene") 					}
//	}
//	var animatePhysics: Bool {
//		get { return true 														}
//		set { bug 																}
//	}
	func hitTest3D(_ point:NSPoint, options:[SCNHitTestOption:Any]?) -> [HitTestResult] {
		bug
		return []
		//		let raycast = self.raycast(from: point, allowing:.estimatedPlane, alignment:.any)
//	//	let cgPoint 			= CGPoint(x: point.x, y: point.y)
//	//	let xxx:ARView 			= self as! ARView
//	//	let ray 				= xxx.raycast(from:cgPoint, allowing:.estimatedPlane, alignment:.any)
//		let ray					= self.raycast(from: point, allowing: .estimatedPlane, alignment: .any)
//		return ray.map { result in
//			HitTestResult(
//				node: result.anchor,
//				//position: SCNVector3(result.worldTransform.columns.3.x,
//				//					 result.worldTransform.columns.3.y,
//				//					 result.worldTransform.columns.3.z),
//				position: result.worldTransform.columns.3.xyz,
//	//			distance: simd_length(result.worldTransform.columns.3.xyz)
//			)
//		}
	}
}
//struct RealityKitContentView {
func realityKitContentView(vewBase:Binding<VewBase>) -> some View {
	//logApp(3, "NavigationStack:(tabViewSelect): Generating content for slot:\(vewBase.wrappedValue.slot_)")
	return HStack (alignment:.top) {
		VStack { 		// H: Q=optional, Any/callable		//Binding<VewBase>
			ZStack {
		/**/	RealityKitView()
				 .frame(maxWidth: .infinity)
				 .border(.black, width:1)
				EventReceiver { nsEvent in // Catch events (goes underneath)
					guard let scnView = vewBase.wrappedValue.gui as? ScnView
					 else { 	// ERROR:
						guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
						logApp(3, "Key '\(c)' not recognized and hence ignored...")
						return 											}
					let _ 	= scnView.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
				}
			}
		}//.frame(width: 555)
		VStack {
			VewBaseBar(vewBase:vewBase)
			InspectorsVew(vewBase:vewBase.wrappedValue)
		}//.frame(width:500)
	}
}

struct RealityKitView: View {
	@State		   var selfiePole 				 = SelfiePole()
	@State 		   var focusPosition:Vect3 		 = Vect3(0, 0, 0)
	@State 		   var selectedPrimitiveName:String = ""
	@State private var lastDragLocation:CGPoint	 = .zero
	@State private var isDragging:Bool 			 = false

	typealias Visible			= Entity
	typealias Vect3 			= SIMD3<Float>
	typealias Vect4 			= SIMD4<Float>
	typealias Matrix4x4 		= simd_float4x4
								
	var body: some View {
		VStack {
			HStack {
				Spacer()
				SelfiePoleBar(selfiePole:$selfiePole)
			//	 .border(Color.gray, width: 3)
			//	 .frame(width:800, height:20)
			}
			RealityView { content in
				let anchor 		= AnchorEntity(.world(transform: matrix_identity_float4x4))
				anchor.name 	= "mainAnchor"			// Create anchor for the scene
	/**/		makeScenery(anchor:anchor)
				content.add(anchor)
				print("RealityView loaded with \(anchor.children.count) children,\n\t rotation:\(anchor.transform.rotation) \n\t translation: \(anchor.transform.translation)")
		//		let scnBase 	= ScnBase(gui:rv)		// scnBase.gui = rv // important BACKPOINTER
		//		rv.delegate		= scnBase 				// (the SCNSceneRendererDelegate)
		//		rv.scene		= scnBase.gui!.scene	// wrapped.scnScene //gui.scene //.scene
		//		let vewBase		= fm.NewVewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
		//		vewBase.gui 	= rv
			} update: { content in
			  // Update camera transform using SelfiePole mathematics
				if let anchor 	  = content.entities.first(where: { $0.name == "mainAnchor" }) {
					let self2focus = selfiePole.transform(lookAt:SCNVector3(focusPosition))// SCNMatrix4
					let focus2self	= self2focus.inverse()									// SCNMatrix4
	/**/			anchor.transform = Transform(matrix:Matrix4x4(focus2self))
					updateHighlighting(from:self, anchor: anchor as! AnchorEntity)
					Swift.print("RealityView update with \(anchor.children.count) children,\n\t rotation:\(anchor.transform.rotation)\n\t translation: \(anchor.transform.translation)")
				//	printTreeBase(entity:anchor)													// ENTITY
				}
			}
			.background(Color.gray.opacity(0.1))
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { value in
						if !isDragging {
							// Perform hit testing on drag start
							performHitTest(from:self, at: value.startLocation)
							lastDragLocation = value.startLocation
							isDragging = true
						}

						let deltaX	= Float(value.location.x - lastDragLocation.x)
						let deltaY	= Float(value.location.y - lastDragLocation.y)
						
						// Use SelfiePole's mouse delta handling
						selfiePole.updateFromMouseDelta(deltaX:deltaX, deltaY:deltaY, sensitivity:0.005)
						
						lastDragLocation = value.location
					}
					.onEnded { _ in
						isDragging	= false
					}
			)
			.onTapGesture { location in
				performHitTest(from:self, at:location)
			}
			.background(ScrollWheelCaptureView(selfiePole:$selfiePole))
			.onAppear {
				setupScrollWheelMonitor(realityKitView:self)
			}
		}
	}
	func makeScenery(anchor:AnchorEntity) {
		ArkOriginMark(size: 0.5, position:Vect3(0, 0, 0), anchor:anchor, name:"OriginMark")
									
		// Standard SceneKit primitives 	- Row 1
		var position = Vect3(0,0,0)	//[-4, 0, -2]	// IN USE
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
	return
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
									
	func performHitTest(from rkView:RealityKitView, at location: CGPoint) {
		// Map screen coordinates to 3D space based on our grid layout
		// This is a simplified approach that works with our known grid arrangement
								
		// Normalize coordinates to view bounds
		let normalizedX 			= Float(location.x) / 800.0  // View width
		let normalizedY 			= Float(location.y) / 600.0  // View height
		
		// Map to our grid layout (5 columns, 4 rows)
		let gridX 					= min(Int(normalizedX * 5), 4)  // Clamp to 0-4
		let gridY 					= min(Int(normalizedY * 4), 3)  // Clamp to 0-3
									
		// Map to actual positions used in createGeometries
		let spacing: Float 			= 0.8
		let startX: Float 			= -4
		let startZ: Float 			= -2
		
		// Calculate the focus position based on grid coordinates
		let focusX 					= startX + Float(gridX) * spacing
		let focusZ 					= startZ + Float(gridY)
		
		rkView.focusPosition 		= Vect3(focusX, 0, focusZ)
		
		// Determine which primitive was selected for display purposes
		let primitiveNames 			= [
			"Box", 		  "Box2", 		  "Sphere", 		"Cylinder", 	 "Cone",	// Row 0
			"Plane", 	  "Capsule", 	  "", 				"", 			 "",		// Row 1
			"Hemisphere", "Point", 		  "Torus", 			"Tube", 		 "Pyramid",	// Row 2
			"TunnelHood", "Pictureframe", "3DPictureframe", "CornerTriangle", "OpenBox"	// Row 3
		]
									
		let primitiveIndex 			= gridY * 5 + gridX
		let primitiveName 			= primitiveIndex < primitiveNames.count ? primitiveNames[primitiveIndex] : "Unknown"
		
		rkView.selectedPrimitiveName = primitiveName
									
		// Reset SelfiePole to a good viewing angle for the new focus point
		var selfiePole				= rkView.selfiePole
		selfiePole.spin 			=  0.0
		selfiePole.gaze 			= -0.3  // Slight downward angle
		selfiePole.zoom 			=  1.0
		selfiePole.ortho 			=  0.0  // Default to perspective
		
		print("Selected: \(primitiveName) at grid(\(gridX),\(gridY)) focus: \(rkView.focusPosition)")
		print("SelfiePole reset - spin: \(rkView.selfiePole.spin), gaze: \(rkView.selfiePole.gaze), zoom: \(rkView.selfiePole.zoom), ortho: \(rkView.selfiePole.ortho)")
	}
									
	private func setupScrollWheelMonitor(realityKitView rkView:RealityKitView) {
		NSEvent.addLocalMonitorForEvents(matching:.scrollWheel) { event in
			print("NSEvent scroll wheel detected: deltaY=\(event.scrollingDeltaY)")
			let scrollDelta 		= event.scrollingDeltaY
			if abs(scrollDelta) < 0.0001 { }// Ignore very small deltas
			else if scrollDelta > 0 		// Scroll up - zoom in (closer)
			{	rkView.selfiePole.zoom = max(0.00010, rkView.selfiePole.zoom / 1.05) }
			else 						// Scroll down - zoom out (farther)
			{	rkView.selfiePole.zoom = min(10000.0, rkView.selfiePole.zoom * 1.05) }
			print("SelfiePole zoom updated: \(rkView.selfiePole.zoom)")
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
				let someArView = ARView()
				if let someArViewSubclass = someArView as? ArView {
					someArViewSubclass.delegate
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
 /// Debugging
func printTreeBase(entity: Entity, indent: String = "") {
	print("\(indent)\(type(of:entity)):\(entity.name)' - children:\(entity.children.count)")
	for child in entity.children {
		printTreeBase(entity:child, indent: indent + "  ")
	}
}
