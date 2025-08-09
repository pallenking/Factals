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

struct RealityKitView: View {
	@State private var selfiePole = SelfiePole()
	@State private var lastDragLocation: CGPoint = .zero
	@State private var isDragging: Bool = false
	@State private var focusPosition: Vect3 = Vect3(0, 0, 0)
	@State private var selectedPrimitiveName: String = ""
	
	var body: some View {
		RealityView { content in
			// 1. Create anchor for the scene
			let anchor 			= AnchorEntity(.world(transform:matrix_identity_float4x4))
			anchor.name 		= "mainAnchor"
			// 2. Add anchor to content
			createGeometries(anchor: anchor)
			content.add(anchor)			// Add anchor to scene
			
			print("RealityView loaded with \(anchor.children.count) children, transform:\(anchor.transform)")
		} update: { content in
			// Update view transformation using SelfiePole mathematics
			if let anchor 		= content.entities.first(where: { $0.name == "mainAnchor" }) {
				let self2focus	= selfiePole.transform(lookAt:SCNVector3(focusPosition))
				let focus2self	= self2focus.inverse()				// SCNMatrix4
				anchor.transform = Transform(matrix:Matrix4x4(focus2self))
				print("RealityView update with \(anchor.children.count) children, transform:\(anchor.transform)")
				updateHighlighting(anchor: anchor as! AnchorEntity)
			}
		}
		.background(Color.gray.opacity(0.1))
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					if !isDragging {	// Perform hit testing on drag start
						performHitTest(at: value.startLocation)
						lastDragLocation = value.startLocation
						isDragging = true
					}
					let d		= value.location - lastDragLocation
					selfiePole.updateFromMouseDelta(deltaX:Float(d.x), deltaY:Float(d.y), sensitivity:0.005)
					lastDragLocation = value.location
				}
				.onEnded
				{ _ in	isDragging = false										}
		)
		.onTapGesture
		{	location in performHitTest(at: location)							}
		.background(ScrollWheelCaptureView(selfiePole: $selfiePole))
		.onAppear
		{	setupScrollWheelMonitor()											}
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
	
	private func originMark(size:Float, position:Vect3, anchor:AnchorEntity, name: String = "OriginMark") {
		// Create 3 thin cylinders showing X, Y, Z axes
		// X-axis: Red cylinder along X direction
		// Y-axis: Green cylinder along Y direction  
		// Z-axis: Blue cylinder along Z direction
		
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

	func createGeometries(anchor:AnchorEntity) {
		originMark(size:0.5, position:Vect3(0,0,0), anchor:anchor, name:"OriginMark")
		
		// Standard SceneKit primitives 	- Row 1
		var position: Vect3 	= [0,0,0]//[-4, 0, -2]	//
		let spacing: Float 		= 0.8

		let boxEnt 				= RksBox(width:0.3, height:0.3, length:0.3)
		boxEnt.position 		= position;		position.x += spacing
		boxEnt.name 			= "Box"	//"RksBox"
		boxEnt.model?.materials = [SimpleMaterial(color:.blue, isMetallic:false)]
		anchor.addChild(boxEnt)
	}
	func createGeometries2(anchor:AnchorEntity) {
		originMark(size:0.5, position:Vect3(0,0,0), anchor:anchor, name:"OriginMark")
		
		// Standard SceneKit primitives 	- Row 1
		var position: Vect3 	= [-4, 0, -2]	//[0,0,0]//
		let spacing: Float 		= 0.8

		let boxEnt 				= RksBox(width:0.3, height:0.3, length:0.3)
		boxEnt.position 		= position;		position.x += spacing
		boxEnt.name 			= "Box"	//"RksBox"
		boxEnt.model?.materials = [SimpleMaterial(color:.blue, isMetallic:false)]
		anchor.addChild(boxEnt)
		
		let box2 				= RksBox2(width:0.4, height:0.2, length:0.3)
		box2.position 			= position;		position.x += spacing
		box2.name 				= "RksBox2"
		box2.model?.materials 	= [SimpleMaterial(color: .cyan, isMetallic: false)]
		anchor.addChild(box2)
		
//		let sphere 				= RksSphere(radius: 0.15)
//		sphere.position 		= position
//		sphere.name 			= "RksSphere"
//		sphere.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
//		anchor.addChild(sphere)
//		position.x 				+= spacing
//
//		let cylinder 			= RksCylinder(height: 0.4, radius: 0.1)
//		cylinder.position 		= position;		position.x += spacing
//		cylinder.name 			= "Cylinder"
//		cylinder.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
//		anchor.addChild(cylinder)
//
//		let cone 				= RksCone(height: 0.4, radius: 0.15)
//		cone.position 			= position;		position.x += spacing
//		cone.name 				= "Cone"
//		cone.model?.materials 	= [SimpleMaterial(color: .yellow, isMetallic: false)]
//		anchor.addChild(cone)
//
//		let plane 				= RksPlane(width: 0.4, depth: 0.3)
//		plane.position 			= position;		position.x += spacing
//		plane.name 				= "Plane"
//		plane.model?.materials 	= [SimpleMaterial(color: .lightGray, isMetallic: false)]
//		anchor.addChild(plane)
//
//		// Standard SceneKit primitives 	- Row 2
//		position 				= [-4, 0, -1]
//		let capsule 			= RksCapsule(height: 0.4, radius: 0.1)
//		capsule.position 		= position;		position.x += spacing
//		capsule.name 			= "Capsule"
//		capsule.model?.materials = [SimpleMaterial(color: .purple, isMetallic: false)]
//		anchor.addChild(capsule)
//
//		// Custom geometries 				- Row 3
//		position 				= [-4, 0, 0]
//		if let hemisphere 		= RksHemisphere(radius: 0.15, slice: 0.0, stepsAround: 16, stepsBetweenPoles: 8, cap: true) {
//			hemisphere.position = position;		position.x += spacing
//			hemisphere.name 	= "Hemisphere"
//			hemisphere.model?.materials = [SimpleMaterial(color: .orange, isMetallic: false)]
//			anchor.addChild(hemisphere)
//		}
//
//		let point 				= RksPoint(radius: 0.02)
//		point.position 			= position;		position.x += spacing
//		point.name 				= "Point"
//		point.model?.materials 	= [SimpleMaterial(color: .black, isMetallic: false)]
//		anchor.addChild(point)
//
//		if let torus 			= RksTorus(majorRadius: 0.15, minorRadius: 0.05) {
//			torus.position 		= position;		position.x += spacing
//			torus.name 			= "Torus"
//			torus.model?.materials = [SimpleMaterial(color: .magenta, isMetallic: false)]
//			anchor.addChild(torus)
//		}
//
//		let tube 				= RksTube(height: 0.4, radius: 0.15)
//		tube.position 			= position;		position.x += spacing
//		tube.name 				= "Tube"
//		tube.model?.materials 	= [SimpleMaterial(color: .brown, isMetallic: false)]
//		anchor.addChild(tube)
//
//		if let pyramid 			= RksPyramid(width: 0.3, height: 0.4, length: 0.3) {
//			pyramid.position 	= position;		position.x += spacing
//			pyramid.name 		= "Pyramid"
//			pyramid.model?.materials = [SimpleMaterial(color: .systemTeal, isMetallic: false)]
//			anchor.addChild(pyramid)
//		}
//
//		// Custom geometries - Row 4
//		position = [-4, 0, 1]
//
//		if let tunnelHood 		= RksTunnelHood(width: 0.4, height: 0.3, depth: 0.2) {
//			tunnelHood.position = position;		position.x += spacing
//			tunnelHood.name 	= "TunnelHood"
//			tunnelHood.model?.materials = [SimpleMaterial(color: .systemGray, isMetallic: false)]
//			anchor.addChild(tunnelHood)
//		}
//
//		if let pictureframe 	= RksPictureframe(width: 0.4, height: 0.3, thickness: 0.02) {
//			pictureframe.position = position;	position.x += spacing
//			pictureframe.name 	= "Pictureframe"
//			pictureframe.model?.materials = [SimpleMaterial(color: .systemBrown, isMetallic: false)]
//			anchor.addChild(pictureframe)
//		}
//
//		if let pictureframe3D 	= Rks3DPictureframe(width: 0.4, height: 0.3, depth: 0.1, frameWidth: 0.05) {
//			pictureframe3D.position = position;	position.x += spacing
//			pictureframe3D.name = "3DPictureframe"
//			pictureframe3D.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
//			anchor.addChild(pictureframe3D)
//		}
//
//		if let cornerTriangle 	= RksCornerTriangle(size: 0.3) {
//			cornerTriangle.position = position;	position.x += spacing
//			cornerTriangle.name = "CornerTriangle"
//			cornerTriangle.model?.materials = [SimpleMaterial(color: .systemIndigo, isMetallic: false)]
//			anchor.addChild(cornerTriangle)
//		}
//
//		if let openBox 			= RksOpenBox(width: 0.3, height: 0.3, depth: 0.3, thickness: 0.02) {
//			openBox.position 	= position;		position.x += spacing
//			openBox.name 		= "OpenBox"
//			openBox.model?.materials = [SimpleMaterial(color: .systemPink, isMetallic: false)]
//			anchor.addChild(openBox)
//		}
//
//		// Ground plane for reference
//		let groundPlane 		= RksGroundPlane(width: 8, depth: 4)
//		groundPlane.position 	= [0, -0.2, 0]
//		groundPlane.name 		= "GroundPlane"
//		anchor.addChild(groundPlane)
	}

	// MARK: - Standard Primitives
	//width:0.2, height:0.2, length:0.2, chamferRadius:0.01
	func RksBox(width:Float, height:Float, length:Float, chamferRadius:Float=0.0) -> ModelEntity {
		let boxMesh 				= MeshResource.generateBox(size:[width, height, length])
		let boxMaterial 			= SimpleMaterial(color:.gray, isMetallic:false)
		let boxEntity 				= ModelEntity(mesh:boxMesh, materials:[boxMaterial])
		return boxEntity
	}
//	func RksSphere(radius:Float) -> ModelEntity {
//		let sphereMesh 				= MeshResource.generateSphere(radius: radius)
//		let sphereMaterial 			= SimpleMaterial(color:.gray, isMetallic:false)
//		let sphereEntity 			= ModelEntity(mesh:sphereMesh, materials:[sphereMaterial])
//		return sphereEntity
//	}
//	func RksCylinder(height:Float, radius:Float) -> ModelEntity {
//		let cylinderMesh 			= MeshResource.generateCylinder(height: height, radius: radius)
//		let cylinderMaterial 		= SimpleMaterial(color:.gray, isMetallic:false)
//		let cylinderEntity 			= ModelEntity(mesh:cylinderMesh, materials:[cylinderMaterial])
//		return cylinderEntity
//	}
//	func RksCone(height:Float, radius:Float) -> ModelEntity {
//		let coneMesh 				= MeshResource.generateCone(height:height, radius:radius)
//		let coneMaterial 			= SimpleMaterial(color:.gray, isMetallic:false)
//		let coneEntity 				= ModelEntity(mesh: coneMesh, materials: [coneMaterial])
//		return coneEntity
//	}
//
//	func RksPlane(width: Float, depth: Float) -> ModelEntity {
//		let planeMesh 				= MeshResource.generatePlane(width: width, depth: depth)
//		let planeMaterial 			= SimpleMaterial(color: .gray, isMetallic: false)
//		let planeEntity 			= ModelEntity(mesh: planeMesh, materials: [planeMaterial])
//		return planeEntity
//	}
//
//	func RksCapsule(height: Float, radius: Float) -> ModelEntity {
//		// RealityKit doesn't have generateCapsule, use cylinder as approximation
//		let capsuleMesh 			= MeshResource.generateCylinder(height: height, radius: radius)
//		let capsuleMaterial 		= SimpleMaterial(color: .gray, isMetallic: false)
//		let capsuleEntity 			= ModelEntity(mesh: capsuleMesh, materials: [capsuleMaterial])
//		return capsuleEntity
//	}
//	func RksTorus(majorRadius: Float, minorRadius: Float) -> ModelEntity? {
//		if let torusMesh 			= generateTorusMesh(majorRadius: majorRadius, minorRadius: minorRadius) {
//			let torusMaterial 		= SimpleMaterial(color: .gray, isMetallic: false)
//			let torusEntity 		= ModelEntity(mesh: torusMesh, materials: [torusMaterial])
//			return torusEntity
//		}
//		return nil
//	}
//	func RksTube(height: Float, radius: Float) -> ModelEntity {
//		let tubeMesh 				= MeshResource.generateCylinder(height: height, radius: radius)
//		let tubeMaterial			= SimpleMaterial(color: .gray, isMetallic: false)
//		let tubeEntity				= ModelEntity(mesh: tubeMesh, materials: [tubeMaterial])
//		return tubeEntity
//	}
//	func RksPyramid(width: Float, height: Float, length: Float) -> ModelEntity? {
//		if let pyramidMesh 			= generatePyramidMesh(width: width, height: height, length: length) {
//			let pyramidMaterial 	= SimpleMaterial(color: .gray, isMetallic: false)
//			let pyramidEntity 		= ModelEntity(mesh: pyramidMesh, materials: [pyramidMaterial])
//			return pyramidEntity
//		}
//		return nil
//	}
//	func RksGroundPlane(width: Float, depth: Float) -> ModelEntity {
//		let groundMesh 				= MeshResource.generatePlane(width: width, depth: depth)
//		let groundMaterial 			= SimpleMaterial(color: .init(white: 0.9, alpha: 1), isMetallic: false)
//		let groundEntity 			= ModelEntity(mesh: groundMesh, materials: [groundMaterial])
//		return groundEntity
//	}
//
//	// MARK: - Custom Geometries
//	func RksHemisphere(radius: Float, slice: Float = 0.0, stepsAround: Int = 16, stepsBetweenPoles: Int = 8, cap: Bool = true) -> ModelEntity? {
//		if let hemisphereMesh 		= generateHemisphereMesh(radius: radius, slice: slice, stepsAround: stepsAround, stepsBetweenPoles: stepsBetweenPoles, cap: cap) {
//			let hemisphereMaterial	= SimpleMaterial(color: .gray, isMetallic: false)
//			let hemisphereEntity	= ModelEntity(mesh: hemisphereMesh, materials: [hemisphereMaterial])
//			return hemisphereEntity
//		}
//		return nil
//	}
//	func RksPoint(radius: Float) -> ModelEntity {
//		let pointMesh 				= MeshResource.generateSphere(radius: radius)
//		let pointMaterial 			= SimpleMaterial(color: .gray, isMetallic: false)
//		let pointEntity 			= ModelEntity(mesh: pointMesh, materials: [pointMaterial])
//		return pointEntity
//	}
//
//	func RksTunnelHood(width: Float, height: Float, depth: Float) -> ModelEntity? {
//		if let tunnelHoodMesh 		= generateTunnelHoodMesh(width: width, height: height, depth: depth) {
//			let tunnelHoodMaterial 	= SimpleMaterial(color: .gray, isMetallic: false)
//			let tunnelHoodEntity 	= ModelEntity(mesh: tunnelHoodMesh, materials: [tunnelHoodMaterial])
//			return tunnelHoodEntity
//		}
//		return nil
//	}
//
//	func RksPictureframe(width: Float, height: Float, thickness: Float) -> ModelEntity? {
//		if let pictureframeMesh 	= generatePictureframeMesh(width: width, height: height, thickness: thickness) {
//			let pictureframeMaterial = SimpleMaterial(color: .gray, isMetallic: false)
//			let pictureframeEntity	= ModelEntity(mesh: pictureframeMesh, materials: [pictureframeMaterial])
//			return pictureframeEntity
//		}
//		return nil
//	}
//
//	func Rks3DPictureframe(width: Float, height: Float, depth: Float, frameWidth: Float) -> ModelEntity? {
//		if let pictureframe3DMesh 	= generate3DPictureframeMesh(width: width, height: height, depth: depth, frameWidth: frameWidth) {
//			let pictureframe3DMaterial = SimpleMaterial(color: .gray, isMetallic: true)
//			let pictureframe3DEntity = ModelEntity(mesh: pictureframe3DMesh, materials: [pictureframe3DMaterial])
//			return pictureframe3DEntity
//		}
//		return nil
//	}
//
//	func RksCornerTriangle(size: Float) -> ModelEntity? {
//		if let cornerTriangleMesh 	= generateCornerTriangleMesh(size: size) {
//			let cornerTriangleMaterial = SimpleMaterial(color: .gray, isMetallic: false)
//			let cornerTriangleEntity = ModelEntity(mesh: cornerTriangleMesh, materials: [cornerTriangleMaterial])
//			return cornerTriangleEntity
//		}
//		return nil
//	}
//
//	func RksOpenBox(width: Float, height: Float, depth: Float, thickness: Float) -> ModelEntity? {
//		if let openBoxMesh 			= generateOpenBoxMesh(width: width, height: height, depth: depth, thickness: thickness) {
//			let openBoxMaterial 	= SimpleMaterial(color: .gray, isMetallic: false)
//			let openBoxEntity 		= ModelEntity(mesh: openBoxMesh, materials: [openBoxMaterial])
//			return openBoxEntity
//		}
//		return nil
//	}
//
//	// MARK: - Mesh Generation Functions
//	private func generateHemisphereMesh(radius: Float, slice: Float = 0.0, stepsAround: Int = 16, stepsBetweenPoles: Int = 8, cap: Bool = true) -> MeshResource? {
//		var vertices: [Vect3] = []
//		var normals: [Vect3] = []
//		var indices: [UInt32] = []
//		
//		// Calculate actual hemisphere steps based on slice parameter
//		let actualSteps = Int(Float(stepsBetweenPoles) * (1.0 - slice))
//		
//		// Generate vertices starting from north pole
//		for i in 0...actualSteps {
//			let lat = Float(i) / Float(stepsBetweenPoles) * Float.pi / 2.0 // 0 to π/2 for hemisphere
//			let cosLat = cos(lat)
//			let sinLat = sin(lat)
//			
//			for j in 0...stepsAround {
//				let lon = Float(j) / Float(stepsAround) * 2.0 * Float.pi
//				let cosLon = cos(lon)
//				let sinLon = sin(lon)
//				
//				let x = radius * cosLat * cosLon
//				let y = radius * sinLat
//				let z = radius * cosLat * sinLon
//				
//				vertices.append(Vect3(x, y, z))
//				normals.append(normalize(Vect3(x, y, z)))
//			}
//		}
//		
//		// Add cap vertices if needed
//		if cap && actualSteps < stepsBetweenPoles {
//			let capY = radius * sin(Float(actualSteps) / Float(stepsBetweenPoles) * Float.pi / 2.0)
//			let capRadius = radius * cos(Float(actualSteps) / Float(stepsBetweenPoles) * Float.pi / 2.0)
//			
//			// Center of cap
//			vertices.append(Vect3(0, capY, 0))
//			normals.append(Vect3(0, -1, 0))
//			
//			// Cap rim vertices
//			for j in 0...stepsAround {
//				let lon = Float(j) / Float(stepsAround) * 2.0 * Float.pi
//				let x = capRadius * cos(lon)
//				let z = capRadius * sin(lon)
//				
//				vertices.append(Vect3(x, capY, z))
//				normals.append(Vect3(0, -1, 0))
//			}
//		}
//		
//		// Generate indices for hemisphere surface
//		for i in 0..<actualSteps {
//			for j in 0..<stepsAround {
//				let curr = UInt32(i * (stepsAround + 1) + j)
//				let next = UInt32(i * (stepsAround + 1) + (j + 1))
//				let currNext = UInt32((i + 1) * (stepsAround + 1) + j)
//				let nextNext = UInt32((i + 1) * (stepsAround + 1) + (j + 1))
//				
//				indices.append(contentsOf: [curr, currNext, next])
//				indices.append(contentsOf: [next, currNext, nextNext])
//			}
//		}
//		
//		// Generate indices for cap if needed
//		if cap && actualSteps < stepsBetweenPoles {
//			let centerIndex = UInt32(vertices.count - (stepsAround + 2))
//			let startCapIndex = centerIndex + 1
//			
//			for j in 0..<stepsAround {
//				let curr = startCapIndex + UInt32(j)
//				let next = startCapIndex + UInt32((j + 1) % (stepsAround + 1))
//				indices.append(contentsOf: [centerIndex, curr, next])
//			}
//		}
//		
//		var meshDescriptor = MeshDescriptor()
//		meshDescriptor.positions = MeshBuffer(vertices)
//		meshDescriptor.normals = MeshBuffer(normals)
//		meshDescriptor.primitives = .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//									
//	private func generateTorusMesh(majorRadius: Float, minorRadius: Float) -> MeshResource? {
//		let radialSegments 			= 24
//		let tubularSegments 		= 16
//		
//		var vertices:[Vect3] = []
//		var normals: [Vect3] = []
//		var indices: [UInt32] 		= []
//		
//		for i in 0...radialSegments {
//			let u = Float(i) / Float(radialSegments) * 2 * Float.pi
//			
//			for j in 0...tubularSegments {
//				let v 				= Float(j) / Float(tubularSegments) * 2 * Float.pi
//				
//				let x 				= (majorRadius + minorRadius * cos(v)) * cos(u)
//				let y 				= minorRadius * sin(v)
//				let z 				= (majorRadius + minorRadius * cos(v)) * sin(u)
//				
//				vertices.append(Vect3(x, y, z))
//				
//				let nx 				= cos(v) * cos(u)
//				let ny 				= sin(v)
//				let nz 				= cos(v) * sin(u)
//				normals.append(Vect3(nx, ny, nz))
//			}
//		}
//		
//		for i in 0..<radialSegments {
//			for j in 0..<tubularSegments {
//				let a 				= UInt32(i * (tubularSegments + 1) + j)
//				let b 				= UInt32((i + 1) * (tubularSegments + 1) + j)
//				let c 				= UInt32((i + 1) * (tubularSegments + 1) + (j + 1))
//				let d 				= UInt32(i * (tubularSegments + 1) + (j + 1))
//				
//				indices.append(contentsOf: [a, b, c, a, c, d])
//			}
//		}
//		
//		var meshDescriptor 			= MeshDescriptor()
//		meshDescriptor.positions 	= MeshBuffer(vertices)
//		meshDescriptor.normals 		= MeshBuffer(normals)
//		meshDescriptor.primitives	= .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//
//	private func generatePyramidMesh(width: Float, height: Float, length: Float) -> MeshResource? {
//		let halfWidth 				= width / 2
//		let halfLength 				= length / 2
//		
//		let vertices: [Vect3] = [
//			Vect3(-halfWidth, 0, -halfLength),	// 0	// Base vertices
//			Vect3( halfWidth, 0, -halfLength),	// 1
//			Vect3( halfWidth, 0,  halfLength),	// 2
//			Vect3(-halfWidth, 0,  halfLength),	// 3
//			Vect3( 0, 		 height, 0)			// 4	// Apex
//		]
//		
//		let indices: [UInt32] 		= [
//			// Base (bottom face)
//			0, 2, 1,
//			0, 3, 2,
//			// Side faces
//			0, 1, 4,  // Front
//			1, 2, 4,  // Right
//			2, 3, 4,  // Back
//			3, 0, 4   // Left
//		]
//		
//		// Calculate normals
//		var normals: [Vect3] = []
//		for vertex in vertices {
//			if vertex.y == 0 {
//				normals.append(Vect3(0, -1, 0))  // Base normal
//			} else {
//				normals.append(normalize(vertex))  // Approximate apex normal
//			}
//		}
//		
//		var meshDescriptor 			= MeshDescriptor()
//		meshDescriptor.positions 	= MeshBuffer(vertices)
//		meshDescriptor.normals 		= MeshBuffer(normals)
//		meshDescriptor.primitives 	= .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//
//	private func generateTunnelHoodMesh(width: Float, height: Float, depth: Float) -> MeshResource? {
//		let segments 				= 16
//		var vertices: [Vect3] = []
//		var normals: [Vect3] = []
//		var indices: [UInt32] 		= []
//		
//		let halfWidth 				= width / 2
//		let halfDepth 				= depth / 2
//		
//		// Generate arch vertices
//		for i in 0...segments {
//			let angle 				= Float(i) / Float(segments) * Float.pi
//			let x 					= cos(angle) * halfWidth
//			let y 					= sin(angle) * height
//			
//			// Front face
//			vertices.append(Vect3(x, y, halfDepth))
//			normals.append(Vect3(0, 0, 1))
//			
//			// Back face
//			vertices.append(Vect3(x, y, -halfDepth))
//			normals.append(Vect3(0, 0, -1))
//		}
//		
//		// Generate side faces
//		for i in 0..<segments {
//			let base = UInt32(i * 2)
//			
//			// Connect front and back
//			indices.append(contentsOf: [base + 0, base + 2, base + 1])
//			indices.append(contentsOf: [base + 1, base + 2, base + 3])
//		}
//									
//		var meshDescriptor 			= MeshDescriptor()
//		meshDescriptor.positions 	= MeshBuffer(vertices)
//		meshDescriptor.normals 		= MeshBuffer(normals)
//		meshDescriptor.primitives 	= .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//
//	private func generatePictureframeMesh(width: Float, height: Float, thickness: Float) -> MeshResource? {
//		let frameWidth: Float 		= 0.05
//		let halfWidth 				= width / 2
//		let halfHeight 				= height / 2
//		let halfThickness 			= thickness / 2
//		
//		let vertices: [Vect3] = [
//			// Outer frame vertices (front)
//			Vect3(-halfWidth, -halfHeight, halfThickness),
//			Vect3(halfWidth, -halfHeight, halfThickness),
//			Vect3(halfWidth, halfHeight, halfThickness),
//			Vect3(-halfWidth, halfHeight, halfThickness),
//			
//			// Inner frame vertices (front)
//			Vect3(-halfWidth + frameWidth, -halfHeight + frameWidth, halfThickness),
//			Vect3( halfWidth - frameWidth, -halfHeight + frameWidth, halfThickness),
//			Vect3( halfWidth - frameWidth,  halfHeight - frameWidth, halfThickness),
//			Vect3(-halfWidth + frameWidth,  halfHeight - frameWidth, halfThickness),
//			
//			// Outer frame vertices (back)
//			Vect3(-halfWidth, -halfHeight, -halfThickness),
//			Vect3( halfWidth, -halfHeight, -halfThickness),
//			Vect3( halfWidth,  halfHeight, -halfThickness),
//			Vect3(-halfWidth,  halfHeight, -halfThickness),
//			
//			// Inner frame vertices (back)
//			Vect3(-halfWidth + frameWidth, -halfHeight + frameWidth, -halfThickness),
//			Vect3( halfWidth - frameWidth, -halfHeight + frameWidth, -halfThickness),
//			Vect3( halfWidth - frameWidth,  halfHeight - frameWidth, -halfThickness),
//			Vect3(-halfWidth + frameWidth,  halfHeight - frameWidth, -halfThickness)
//		]
//		
//		let indices: [UInt32] = [
//			// Front face frame
//			0, 1, 4, 1, 5, 4,
//			1, 2, 5, 2, 6, 5,
//			2, 3, 6, 3, 7, 6,
//			3, 0, 7, 0, 4, 7,
//			
//			// Back face frame
//			8, 12, 9, 9, 12, 13,
//			9, 13, 10, 10, 13, 14,
//			10, 14, 11, 11, 14, 15,
//			11, 15, 8, 8, 15, 12
//		]
//		
//		let normals = vertices.map { _ in Vect3(0, 0, 1) }
//									
//		var meshDescriptor 			= MeshDescriptor()
//		meshDescriptor.positions 	= MeshBuffer(vertices)
//		meshDescriptor.normals 		= MeshBuffer(normals)
//		meshDescriptor.primitives 	= .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//
//	private func generate3DPictureframeMesh(width: Float, height: Float, depth: Float, frameWidth: Float) -> MeshResource? {
//		let halfWidth 				= width / 2
//		let halfHeight 				= height / 2
//		let halfDepth 				= depth / 2
//		
//		var vertices: [Vect3] = []
//		var indices: [UInt32] 		= []
//		
//		// Generate outer box vertices
//		let outerVertices: [Vect3] = [
//			Vect3(-halfWidth, -halfHeight, -halfDepth),
//			Vect3( halfWidth, -halfHeight, -halfDepth),
//			Vect3( halfWidth,  halfHeight, -halfDepth),
//			Vect3(-halfWidth,  halfHeight, -halfDepth),
//			Vect3(-halfWidth, -halfHeight,  halfDepth),
//			Vect3( halfWidth, -halfHeight,  halfDepth),
//			Vect3( halfWidth,  halfHeight,  halfDepth),
//			Vect3(-halfWidth,  halfHeight,  halfDepth)
//		]
//									
//		// Generate inner box vertices (hollow center)
//		let innerHalfWidth 			= halfWidth - frameWidth
//		let innerHalfHeight 		= halfHeight - frameWidth
//		let innerVertices: [Vect3] = [
//			Vect3(-innerHalfWidth, -innerHalfHeight, -halfDepth),
//			Vect3( innerHalfWidth, -innerHalfHeight, -halfDepth),
//			Vect3( innerHalfWidth,  innerHalfHeight, -halfDepth),
//			Vect3(-innerHalfWidth,  innerHalfHeight, -halfDepth),
//			Vect3(-innerHalfWidth, -innerHalfHeight,  halfDepth),
//			Vect3( innerHalfWidth, -innerHalfHeight,  halfDepth),
//			Vect3( innerHalfWidth,  innerHalfHeight,  halfDepth),
//			Vect3(-innerHalfWidth,  innerHalfHeight,  halfDepth)
//		]
//		
//		vertices.append(contentsOf: outerVertices)
//		vertices.append(contentsOf: innerVertices)
//		
//		// Frame faces indices
//		let frameIndices: [UInt32] = [
//			// Bottom frame
//			0, 1, 8, 1, 9, 8,
//			// Right frame
//			1, 2, 9, 2, 10, 9,
//			// Top frame
//			2, 3, 10, 3, 11, 10,
//			// Left frame
//			3, 0, 11, 0, 8, 11,
//			// Front face
//			4, 12, 5, 5, 12, 13,
//			5, 13, 6, 6, 13, 14,
//			6, 14, 7, 7, 14, 15,
//			7, 15, 4, 4, 15, 12
//		]
//		
//		indices.append(contentsOf: frameIndices)
//									
//		let normals 				= vertices.map { normalize($0) }
//		
//		var meshDescriptor 			= MeshDescriptor()
//		meshDescriptor.positions 	= MeshBuffer(vertices)
//		meshDescriptor.normals 		= MeshBuffer(normals)
//		meshDescriptor.primitives 	= .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//
//	private func generateCornerTriangleMesh(size: Float) -> MeshResource? {
//		let vertices: [Vect3] = [
//			// Base triangle
//			Vect3(0, 0, 0),
//			Vect3(size, 0, 0),
//			Vect3(0, 0, size),
//			// Top vertex
//			Vect3(0, size, 0)
//		]
//		
//		let indices: [UInt32] = [
//			// Base triangle
//			0, 2, 1,
//			// Side faces
//			0, 1, 3,
//			1, 2, 3,
//			2, 0, 3
//		]
//		
//		var normals: [Vect3] = []
//		for vertex in vertices {
//			normals.append(normalize(vertex))
//		}
//		
//		var meshDescriptor = MeshDescriptor()
//		meshDescriptor.positions = MeshBuffer(vertices)
//		meshDescriptor.normals = MeshBuffer(normals)
//		meshDescriptor.primitives = .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
//
//	private func generateOpenBoxMesh(width: Float, height: Float, depth: Float, thickness: Float) -> MeshResource? {
//		let halfWidth = width / 2
//		let halfDepth = depth / 2
//		
//		var vertices: [Vect3] = []
//		var indices: [UInt32] = []
//		
//		// Bottom face (outer)
//		vertices.append(contentsOf: [
//			Vect3(-halfWidth, 0, -halfDepth),
//			Vect3(halfWidth, 0, -halfDepth),
//			Vect3(halfWidth, 0, halfDepth),
//			Vect3(-halfWidth, 0, halfDepth)
//		])
//		
//		// Bottom face (inner)
//		let innerHalfWidth = halfWidth - thickness
//		let innerHalfDepth = halfDepth - thickness
//		vertices.append(contentsOf: [
//			Vect3(-innerHalfWidth, thickness, -innerHalfDepth),
//			Vect3(innerHalfWidth, thickness, -innerHalfDepth),
//			Vect3(innerHalfWidth, thickness, innerHalfDepth),
//			Vect3(-innerHalfWidth, thickness, innerHalfDepth)
//		])
//		
//		// Side walls
//		let wallHeight = height - thickness
//		
//		// Front wall
//		vertices.append(contentsOf: [
//			Vect3(-halfWidth, 0, halfDepth),
//			Vect3(halfWidth, 0, halfDepth),
//			Vect3(halfWidth, wallHeight, halfDepth),
//			Vect3(-halfWidth, wallHeight, halfDepth),
//			Vect3(-innerHalfWidth, thickness, innerHalfDepth),
//			Vect3(innerHalfWidth, thickness, innerHalfDepth),
//			Vect3(innerHalfWidth, wallHeight, innerHalfDepth),
//			Vect3(-innerHalfWidth, wallHeight, innerHalfDepth)
//		])
//		
//		// Generate indices for box faces (excluding top)
//		let bottomIndices: [UInt32] = [0, 1, 4, 1, 5, 4, 1, 2, 5, 2, 6, 5, 2, 3, 6, 3, 7, 6, 3, 0, 7, 0, 4, 7]
//		let frontWallIndices: [UInt32] = [8, 9, 10, 8, 10, 11, 12, 14, 13, 12, 15, 14]
//		
//		indices.append(contentsOf: bottomIndices)
//		indices.append(contentsOf: frontWallIndices)
//		
//		let normals = vertices.map { _ in Vect3(0, 1, 0) }
//		
//		var meshDescriptor = MeshDescriptor()
//		meshDescriptor.positions = MeshBuffer(vertices)
//		meshDescriptor.normals = MeshBuffer(normals)
//		meshDescriptor.primitives = .triangles(indices)
//		
//		return try? MeshResource.generate(from: [meshDescriptor])
//	}
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
