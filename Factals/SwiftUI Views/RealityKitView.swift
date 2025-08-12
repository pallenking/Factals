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

typealias Vect3 = SIMD3<Float>
typealias Vect4 = SIMD4<Float>
typealias Matrix4x4 = simd_float4x4


func createGeometries(anchor:AnchorEntity) {
							//		let boxEnt 					= RksBox(width:0.3, height:0.3, length:0.3)
							//		boxEnt.position 			= position;		position.x += spacing
							//		boxEnt.name 				= "Box1"	//"RksBox"
							//		boxEnt.model?.materials 	= [SimpleMaterial(color:.blue, isMetallic:false)]
							//		anchor.addChild(boxEnt)
							//
							//		let boxEnt2 				= RksBox(width:0.3, height:0.3, length:0.3)
							//		boxEnt2.position 			= position;		position.x += spacing
							//		boxEnt2.name 				= "Box2"	//"RksBox"
							//		boxEnt2.model?.materials 	= [SimpleMaterial(color:.blue, isMetallic:false)]
							//		anchor.addChild(boxEnt2)
							//	}
							//	private func createGeometries(anchor:AnchorEntity) {
							//		let spacing: Float 		= 0.8
							//		let scn					= /*vew.scn.findScn(named:"s-Prev") ??*/ {
							//			let rv				= Entity()
							//	//		//vew.scn.addChild(node:rv, atIndex:0)
							//			rv.name				= "s-Prev"
							//	//	//	rv.geometry			= SCNBox(width:0.2, height:0.2, length:0.2, chamferRadius:0.01)	//191113
							//				// RksBox(size:Vect3, position:Vect3, color:NSColor, anchor:AnchorEntity, name:String="Box") {
							//
							//	//		let geomet			= RksBox(width:width, height:height, length:3, chamferRadius:0.4)
							//	//		rv.position			= SCNVector3(1.5, height/2, 0)
							//	//		let color			= vew.scn.color0
							//	//	//	let color			= NSColor.blue//.gray//.white//NSColor("lightpink")!//NSColor("lightslategray")!
							//	//		rv.color0			= color.change(saturationBy:0.3, fadeTo:0.5)
							//	//		return rv
							//		} ()
							//
							//	//		// Add origin marker at center
bug
	ArkOriginMark(size: 0.5, position:Vect3(0, 0, 0), anchor: anchor, name: "OriginMark")
	
	// Standard SceneKit primitives 	- Row 1
	var position: Vect3 		= [-4, 0, -2]	//[0,0,0]	// IN USE
	let spacing: Float 			= 0.8

	let boxEnt 				= RksBox(width:0.3, height:0.3, length:0.3)
	boxEnt.position 		= position;		position.x += spacing
	boxEnt.name 			= "RksBox"
	boxEnt.model?.materials = [SimpleMaterial(color:.blue, isMetallic:false)]
	anchor.addChild(boxEnt)
	
	let box2 				= RksBox(width:0.4, height:0.2, length:0.3)
	box2.position 			= position;		position.x += spacing
	box2.name 				= "RksBox2"
	box2.model?.materials 	= [SimpleMaterial(color: .cyan, isMetallic: false)]
	anchor.addChild(box2)
	
	let sphere 				= RksSphere(radius: 0.15)
	sphere.position 		= position
	sphere.name 			= "RksSphere"
	sphere.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
	anchor.addChild(sphere)
	position.x 				+= spacing

	let cylinder 			= RksCylinder(height: 0.4, radius: 0.1)
	cylinder.position 		= position;		position.x += spacing
	cylinder.name 			= "Cylinder"
	cylinder.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
	anchor.addChild(cylinder)
	
	let cone 				= RksCone(height: 0.4, radius: 0.15)
	cone.position 			= position;		position.x += spacing
	cone.name 				= "Cone"
	cone.model?.materials 	= [SimpleMaterial(color: .yellow, isMetallic: false)]
	anchor.addChild(cone)
	
	let plane 				= RksPlane(width: 0.4, depth: 0.3)
	plane.position 			= position;		position.x += spacing
	plane.name 				= "Plane"
	plane.model?.materials 	= [SimpleMaterial(color: .lightGray, isMetallic: false)]
	anchor.addChild(plane)

	// Standard SceneKit primitives 	- Row 2
	position 				= [-4, 0, -1]
	let capsule 			= RksCapsule(height: 0.4, radius: 0.1)
	capsule.position 		= position;		position.x += spacing
	capsule.name 			= "Capsule"
	capsule.model?.materials = [SimpleMaterial(color: .purple, isMetallic: false)]
	anchor.addChild(capsule)

	// Custom geometries 				- Row 3
	position 				= [-4, 0, 0]
	if let hemisphere 		= RksHemisphere(radius: 0.15, slice: 0.0, stepsAround: 16, stepsBetweenPoles: 8, cap: true) {
		hemisphere.position = position;		position.x += spacing
		hemisphere.name 	= "Hemisphere"
		hemisphere.model?.materials = [SimpleMaterial(color: .orange, isMetallic: false)]
		anchor.addChild(hemisphere)
	}
	
	let point 				= RksPoint(radius: 0.02)
	point.position 			= position;		position.x += spacing
	point.name 				= "Point"
	point.model?.materials 	= [SimpleMaterial(color: .black, isMetallic: false)]
	anchor.addChild(point)
	
	if let torus 			= RksTorus(majorRadius: 0.15, minorRadius: 0.05) {
		torus.position 		= position;		position.x += spacing
		torus.name 			= "Torus"
		torus.model?.materials = [SimpleMaterial(color: .magenta, isMetallic: false)]
		anchor.addChild(torus)
	}
	
	let tube 				= RksTube(height: 0.4, radius: 0.15)
	tube.position 			= position;		position.x += spacing
	tube.name 				= "Tube"
	tube.model?.materials 	= [SimpleMaterial(color: .brown, isMetallic: false)]
	anchor.addChild(tube)
	
	if let pyramid 			= RksPyramid(width: 0.3, height: 0.4, length: 0.3) {
		pyramid.position 	= position;		position.x += spacing
		pyramid.name 		= "Pyramid"
		pyramid.model?.materials = [SimpleMaterial(color: .systemTeal, isMetallic: false)]
		anchor.addChild(pyramid)
	}

	// Custom geometries - Row 4
	position = [-4, 0, 1]

	if let tunnelHood 		= RksTunnelHood(width: 0.4, height: 0.3, depth: 0.2) {
		tunnelHood.position = position;		position.x += spacing
		tunnelHood.name 	= "TunnelHood"
		tunnelHood.model?.materials = [SimpleMaterial(color: .systemGray, isMetallic: false)]
		anchor.addChild(tunnelHood)
	}

	if let pictureframe 	= RksPictureframe(width: 0.4, height: 0.3, thickness: 0.02) {
		pictureframe.position = position;	position.x += spacing
		pictureframe.name 	= "Pictureframe"
		pictureframe.model?.materials = [SimpleMaterial(color: .systemBrown, isMetallic: false)]
		anchor.addChild(pictureframe)
	}

	if let pictureframe3D 	= Rks3DPictureframe(width: 0.4, height: 0.3, depth: 0.1, frameWidth: 0.05) {
		pictureframe3D.position = position;	position.x += spacing
		pictureframe3D.name = "3DPictureframe"
		pictureframe3D.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
		anchor.addChild(pictureframe3D)
	}

	if let cornerTriangle 	= RksCornerTriangle(size: 0.3) {
		cornerTriangle.position = position;	position.x += spacing
		cornerTriangle.name = "CornerTriangle"
		cornerTriangle.model?.materials = [SimpleMaterial(color: .systemIndigo, isMetallic: false)]
		anchor.addChild(cornerTriangle)
	}

	if let openBox 			= RksOpenBox(width: 0.3, height: 0.3, depth: 0.3, thickness: 0.02) {
		openBox.position 	= position;		position.x += spacing
		openBox.name 		= "OpenBox"
		openBox.model?.materials = [SimpleMaterial(color: .systemPink, isMetallic: false)]
		anchor.addChild(openBox)
	}

	// Ground plane for reference
	let groundPlane 		= RksGroundPlane(width: 8, depth: 4)
	groundPlane.position 	= [0, -0.2, 0]
	groundPlane.name 		= "GroundPlane"
	anchor.addChild(groundPlane)
}

func ArkOriginMark(size:Float, position:Vect3, anchor:AnchorEntity, name: String = "OriginMark") {
	// Create 3 thin cylinders showing X, Y, Z axes
	// X-axis: Red   cylinder along X direction
	// Y-axis: Green cylinder along Y direction
	// Z-axis: Blue  cylinder along Z direction
	
	let lineRadius: Float = 0.005  // Very thin cylinders to simulate lines
	let lineLength = size * 2      // Full length from -size to +size
								
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

struct RealityKitView: View {
	@State private var selfiePole 				 = SelfiePole()
	@State private var lastDragLocation: CGPoint = .zero
	@State private var isDragging: Bool 		 = false
	@State private var focusPosition: Vect3 	 = Vect3(0, 0, 0)
	@State private var selectedPrimitiveName: String = ""
	
	var body: some View {
		RealityView { content in
			let anchor 			= AnchorEntity(.world(transform: matrix_identity_float4x4))
			anchor.name 		= "mainAnchor"		// Create anchor for the scene
/**/		createGeometries(anchor:anchor)
			content.add(anchor)
			print("RealityView loaded with \(anchor.children.count) children,\n\t rotation:\(anchor.transform.rotation) \n\t translation: \(anchor.transform.translation)")
		} update: { content in
		  // Update camera transform using SelfiePole mathematics
			if let anchor 		= content.entities.first(where: { $0.name == "mainAnchor" }) {
				let self2focus	= selfiePole.transform(lookAt:SCNVector3(focusPosition))// SCNMatrix4
				let focus2self	= self2focus.inverse()									// SCNMatrix4
				anchor.transform = Transform(matrix:Matrix4x4(focus2self))
				updateHighlighting(anchor: anchor as! AnchorEntity)
				print("RealityView update with \(anchor.children.count) children,\n\t rotation:\(anchor.transform.rotation)\n\t translation: \(anchor.transform.translation)")
				print(entityTree:anchor)													// ENTITY
			}
		}
		.background(Color.gray.opacity(0.1))
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					if !isDragging {
						// Perform hit testing on drag start
						performHitTest(at: value.startLocation)
						lastDragLocation = value.startLocation
						isDragging = true
					}
					
					let deltaX = Float(value.location.x - lastDragLocation.x)
					let deltaY = Float(value.location.y - lastDragLocation.y)
					
					// Use SelfiePole's mouse delta handling
					selfiePole.updateFromMouseDelta(deltaX: deltaX, deltaY: deltaY, sensitivity: 0.005)
					
					lastDragLocation = value.location
				}
				.onEnded { _ in
					isDragging = false
				}
		)
		.onTapGesture { location in
			performHitTest(at: location)
		}
		.background(ScrollWheelCaptureView(selfiePole: $selfiePole))
		.onAppear {
			setupScrollWheelMonitor()
		}
	}
	
	private func performHitTest(at location: CGPoint) {
		// Map screen coordinates to 3D space based on our grid layout
		// This is a simplified approach that works with our known grid arrangement
		
		// Normalize coordinates to view bounds
		let normalizedX = Float(location.x) / 800.0  // View width
		let normalizedY = Float(location.y) / 600.0  // View height
		
		// Map to our grid layout (5 columns, 4 rows)
		let gridX = min(Int(normalizedX * 5), 4)  // Clamp to 0-4
		let gridY = min(Int(normalizedY * 4), 3)  // Clamp to 0-3
		
		// Map to actual positions used in createGeometries
		let spacing: Float = 0.8
		let startX: Float = -4
		let startZ: Float = -2
		
		// Calculate the focus position based on grid coordinates
		let focusX = startX + Float(gridX) * spacing
		let focusZ = startZ + Float(gridY)
		
		focusPosition = Vect3(focusX, 0, focusZ)
		
		// Determine which primitive was selected for display purposes
		let primitiveNames = [
			// Row 0
			"Box", "Box2", "Sphere", "Cylinder", "Cone",
			// Row 1  
			"Plane", "Capsule", "", "", "",
			// Row 2
			"Hemisphere", "Point", "Torus", "Tube", "Pyramid", 
			// Row 3
			"TunnelHood", "Pictureframe", "3DPictureframe", "CornerTriangle", "OpenBox"
		]
		
		let primitiveIndex = gridY * 5 + gridX
		let primitiveName = primitiveIndex < primitiveNames.count ? primitiveNames[primitiveIndex] : "Unknown"
		
		selectedPrimitiveName = primitiveName
		
		// Reset SelfiePole to a good viewing angle for the new focus point
		selfiePole.spin = 0.0
		selfiePole.gaze = -0.3  // Slight downward angle
		selfiePole.zoom = 1.0
		selfiePole.ortho = 0.0  // Default to perspective
		
		print("Selected: \(primitiveName) at grid(\(gridX),\(gridY)) focus: \(focusPosition)")
		print("SelfiePole reset - spin: \(selfiePole.spin), gaze: \(selfiePole.gaze), zoom: \(selfiePole.zoom), ortho: \(selfiePole.ortho)")
	}
	
	private func setupScrollWheelMonitor() {
		NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
			print("NSEvent scroll wheel detected: deltaY=\(event.scrollingDeltaY)")
			
			let scrollDelta = event.scrollingDeltaY
			if abs(scrollDelta) > 0.1 { // Ignore very small deltas
				if scrollDelta > 0 {
					// Scroll up - zoom in (closer)
					selfiePole.zoom = max(0.1, selfiePole.zoom / 1.05)
				} else {
					// Scroll down - zoom out (farther)
					selfiePole.zoom = min(10.0, selfiePole.zoom * 1.05)
				}
				print("SelfiePole zoom updated: \(selfiePole.zoom)")
			}
			
			// Return nil to prevent the event from being handled by other views
			return nil
		}
	}
	
	private func updateHighlighting(anchor: AnchorEntity) {
		// Reset all materials to original and highlight selected
		for child in anchor.children {
			if let modelEntity = child as? ModelEntity {
				if child.name == selectedPrimitiveName {
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
//struct RealityKitView: View {
//	@State private var selfiePole = SelfiePole()
//	@State private var lastDragLocation: CGPoint = .zero
//	@State private var isDragging: Bool = false
//	@State private var focusPosition: Vect3 = Vect3(0, 0, 0)
//	@State private var selectedPrimitiveName: String = ""
//	
//	var body: some View {
//		RealityView { content in
//			// 1. Create anchor for the scene
//			let anchor 			= AnchorEntity(.world(transform:matrix_identity_float4x4))
//			anchor.name 		= "mainAnchor"
//			// 2. Add anchor to content
//			createGeometries(anchor: anchor)
//			content.add(anchor)			// Add anchor to scene
//			
//			print("RealityView loaded with \(anchor.children.count) children, transform:\(anchor.transform)")
//		} update: { content in
//			// Update view transformation using SelfiePole mathematics
//			if let anchor 		= content.entities.first(where: { $0.name == "mainAnchor" }) {
//				let self2focus	= selfiePole.transform(lookAt:SCNVector3(focusPosition))
//				let focus2self	= self2focus.inverse()				// SCNMatrix4
//				anchor.transform = Transform(matrix:Matrix4x4(focus2self))
//				print("RealityView update with \(anchor.children.count) children, transform:\(anchor.transform)")
//				updateHighlighting(anchor: anchor as! AnchorEntity)
//			}
//		}
//		.background(Color.gray.opacity(0.1))
//		.gesture(
//			DragGesture(minimumDistance: 0)
//				.onChanged { value in
//					if !isDragging {	// Perform hit testing on drag start
//						performHitTest(at: value.startLocation)
//						lastDragLocation = value.startLocation
//						isDragging = true
//					}
//					let d		= value.location - lastDragLocation
//					selfiePole.updateFromMouseDelta(deltaX:Float(d.x), deltaY:Float(d.y), sensitivity:0.005)
//					lastDragLocation = value.location
//				}
//				.onEnded
//				{ _ in	isDragging = false										}
//		)
//		.onTapGesture
//		{	location in performHitTest(at: location)							}
//		.background(ScrollWheelCaptureView(selfiePole: $selfiePole))
//		.onAppear
//		{	setupScrollWheelMonitor()											}
//	}
//	
//	private func performHitTest(at location: CGPoint) {
//bug
//		// Map screen coordinates to 3D space based on our grid layout
//		// This is a simplified approach that works with our known grid arrangement
//		
//		// Normalize coordinates to view bounds
//		let normalizedX = Float(location.x) / 800.0  // View width
//		let normalizedY = Float(location.y) / 600.0  // View height
//		
//		// Map to our grid layout (5 columns, 4 rows)
//		let gridX = min(Int(normalizedX * 5), 4)  // Clamp to 0-4
//		let gridY = min(Int(normalizedY * 4), 3)  // Clamp to 0-3
//		
//		// Map to actual positions used in createGeometries
//		let spacing: Float = 0.8
//		let startX: Float = -4
//		let startZ: Float = -2
//		
//		// Calculate the focus position based on grid coordinates
//		let focusX = startX + Float(gridX) * spacing
//		let focusZ = startZ + Float(gridY)
//		
//		focusPosition = Vect3(focusX, 0, focusZ)
//		
//		// Determine which primitive was selected for display purposes
//		let primitiveNames = [
//			// Row 0
//			"Box", "Box2", "Sphere", "Cylinder", "Cone",
//			// Row 1  
//			"Plane", "Capsule", "", "", "",
//			// Row 2
//			"Hemisphere", "Point", "Torus", "Tube", "Pyramid", 
//			// Row 3
//			"TunnelHood", "Pictureframe", "3DPictureframe", "CornerTriangle", "OpenBox"
//		]
//		
//		let primitiveIndex = gridY * 5 + gridX
//		let primitiveName = primitiveIndex < primitiveNames.count ? primitiveNames[primitiveIndex] : "Unknown"
//		
//		selectedPrimitiveName = primitiveName
//		
//		// Reset SelfiePole to a good viewing angle for the new focus point
//		selfiePole.spin = 0.0
//		selfiePole.gaze = -0.3  // Slight downward angle
//		selfiePole.zoom = 1.0
//		selfiePole.ortho = 0.0  // Default to perspective
//		
//		print("Selected: \(primitiveName) at grid(\(gridX),\(gridY)) focus: \(focusPosition)")
//		print("SelfiePole reset - spin: \(selfiePole.spin), gaze: \(selfiePole.gaze), zoom: \(selfiePole.zoom), ortho: \(selfiePole.ortho)")
//	}
//	
//	private func setupScrollWheelMonitor() {
//		NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
//			print("NSEvent scroll wheel detected: deltaY=\(event.scrollingDeltaY)")
//			
//			let scrollDelta = event.scrollingDeltaY
//			if abs(scrollDelta) > 0.1 { // Ignore very small deltas
//				if scrollDelta > 0 {
//					// Scroll up - zoom in (closer)
//					selfiePole.zoom = max(0.1, selfiePole.zoom / 1.05)
//				} else {
//					// Scroll down - zoom out (farther)
//					selfiePole.zoom = min(10.0, selfiePole.zoom * 1.05)
//				}
//				print("SelfiePole zoom updated: \(selfiePole.zoom)")
//			}
//			
//			// Return nil to prevent the event from being handled by other views
//			return nil
//		}
//	}
//	
//	private func updateHighlighting(anchor: AnchorEntity) {
//		// Reset all materials to original and highlight selected
//		for child in anchor.children {
//			if let modelEntity = child as? ModelEntity {
//				if child.name == selectedPrimitiveName {
//					// Highlight selected entity
//					var highlightMaterial = SimpleMaterial(color: .yellow, isMetallic: true)
//					highlightMaterial.roughness = 0.1
//					modelEntity.model?.materials = [highlightMaterial]
//				} else {
//					// Keep original material (simplified - in practice you'd store originals)
//					// This is a simplified approach for the demo
//				}
//			}
//		}
//	}
//	
//	private func originMark(size:Float, position:Vect3, anchor:AnchorEntity, name: String = "OriginMark") {
//		// Create 3 thin cylinders showing X, Y, Z axes
//		// X-axis: Red cylinder along X direction
//		// Y-axis: Green cylinder along Y direction  
//		// Z-axis: Blue cylinder along Z direction
//		
//		let lineRadius: Float = 0.005  // Very thin cylinders to simulate lines
//		let lineLength = size * 2      // Full length from -size to +size
//								
//		// X-axis (Red)
//		let xAxisMesh 				= MeshResource.generateCylinder(height: lineLength, radius: lineRadius)
//		let xAxisMaterial 			= SimpleMaterial(color: .red, isMetallic: false)
//		let xAxisEntity 			= ModelEntity(mesh: xAxisMesh, materials: [xAxisMaterial])
//		// Rotate 90 degrees around Z-axis to align with X-axis
//		xAxisEntity.transform.rotation = simd_quatf(angle: Float.pi/2, axis: Vect3(0, 0, 1))
//		xAxisEntity.position 		= position
//		xAxisEntity.name 			= "\(name)_X"
//		anchor.addChild(xAxisEntity)
//		
//		// Y-axis (Green) - default cylinder orientation is already Y-axis
//		let yAxisMesh 				= MeshResource.generateCylinder(height: lineLength, radius: lineRadius)
//		let yAxisMaterial 			= SimpleMaterial(color: .green, isMetallic: false)
//		let yAxisEntity 			= ModelEntity(mesh: yAxisMesh, materials: [yAxisMaterial])
//		yAxisEntity.position 		= position
//		yAxisEntity.name 			= "\(name)_Y"
//		anchor.addChild(yAxisEntity)
//		
//		// Z-axis (Blue)
//		let zAxisMesh = MeshResource.generateCylinder(height: lineLength, radius: lineRadius)
//		let zAxisMaterial = SimpleMaterial(color: .blue, isMetallic: false)
//		let zAxisEntity = ModelEntity(mesh: zAxisMesh, materials: [zAxisMaterial])
//		// Rotate 90 degrees around X-axis to align with Z-axis
//		zAxisEntity.transform.rotation = simd_quatf(angle: Float.pi/2, axis: Vect3(1, 0, 0))
//		zAxisEntity.position = position
//		zAxisEntity.name = "\(name)_Z"
//		anchor.addChild(zAxisEntity)
//	}
//
//	func createGeometries0(anchor:AnchorEntity) {
//		ArkOriginMark(size:0.5, position:Vect3(0,0,0), anchor:anchor, name:"OriginMark")
//		
//		// Standard SceneKit primitives 	- Row 1
//		var position: Vect3 	= [-4, 0, -2]	//[0,0,0]	//
//		let spacing: Float 		= 0.8
//
//		let boxEnt 				= RksBox(width:0.3, height:0.3, length:0.3)
//		boxEnt.position 		= position;		position.x += spacing
//		boxEnt.name 			= "Box"	//"RksBox"
//		boxEnt.model?.materials = [SimpleMaterial(color:.blue, isMetallic:false)]
//		anchor.addChild(boxEnt)
//	}
//	func createGeometries2(anchor:AnchorEntity) {
//		ArkOriginMark(size:0.5, position:Vect3(0,0,0), anchor:anchor, name:"OriginMark")
//		
//		// Standard SceneKit primitives 	- Row 1
//		var position: Vect3 	= [-4, 0, -2]	//[0,0,0]//
//		let spacing: Float 		= 0.8
//
//		let boxEnt 				= RksBox(width:0.3, height:0.3, length:0.3)
//		boxEnt.position 		= position;		position.x += spacing
//		boxEnt.name 			= "Box"	//"RksBox"
//		boxEnt.model?.materials = [SimpleMaterial(color:.blue, isMetallic:false)]
//		anchor.addChild(boxEnt)
//		
//		let box2 				= RksBox2(width:0.4, height:0.2, length:0.3)
//		box2.position 			= position;		position.x += spacing
//		box2.name 				= "RksBox2"
//		box2.model?.materials 	= [SimpleMaterial(color: .cyan, isMetallic: false)]
//		anchor.addChild(box2)
//	}
//
//	// MARK: - Standard Primitives
//	//width:0.2, height:0.2, length:0.2, chamferRadius:0.01
//	func RksBox3(width:Float, height:Float, length:Float, chamferRadius:Float=0.0) -> ModelEntity {
//		let boxMesh 				= MeshResource.generateBox(size:[width, height, length])
//		let boxMaterial 			= SimpleMaterial(color:.gray, isMetallic:false)
//		let boxEntity 				= ModelEntity(mesh:boxMesh, materials:[boxMaterial])
//		return boxEntity
//	}
//}


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
func print(entityTree entity: Entity, indent: String = "") {
	print("\(indent)\(type(of:entity)):\(entity.name)' - children:\(entity.children.count)")
	for child in entity.children {
		print(entityTree:child, indent: indent + "  ")
	}
}
