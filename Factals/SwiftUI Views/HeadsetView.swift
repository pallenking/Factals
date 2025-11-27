//
//  HeadsetView.swift
//  Factals
//
//  Created by Allen King on 8/3/24.

import SceneKit
import RealityKit

//					SYSTEM FUNCTIONALITY
//	VIDEO: (OUTPUT)
//		make ScnBase()				// Make SCNView
//		Skins for Parts
//		func reSkin()
//	SOUND: (OUTPUT)
//		sound actions
//	STATE PERSISTENCE / MANAGEMENT
//	LOGGING
//	INPUT
//		keyboard
//		mouse
//		gestures, including fingera (pinching)
//	Simulation Environment
//		user defaults
//		experiment parameters
//		experiment state (load generate save)
//		time slider

//					COMPONENTS
//		AR is the concept,
//		ARKit does the tracking,
//		RealityKitView.swift - Uses RealityKit renderer (the newer ArView class)
//		ScnView.swift		 - Uses SceneKit renderer

// Generic		||	Scene Kit	|	Reality Kit
//--------------++--------------+-------------------
// Visible		||	SCNNode		|	AnchorEntity
// Vect3 		||	SCNVector3	|	SIMD3<Float>
// Vect4 		||	SCNVector4	|	SIMD4<Float>
// Matrix4x4 	||	SCNMatrix4	|	simd_float4x4

//					TO DO:
//		that communicates with a ViewModel
//			to render a SceneKit scene and
//		the ViewModel updates
//			with changes from SceneKit,
//				acting as the single source of truth.
//		 //////////////////////////// Testing	$publisher/	$view
//		 Generate code exemplefying the following thoughts that I am told:
/*
		Propose changes so changes in SceneKit or RealityKit get reflected in the app's SwiftUI, and vice versa
		Here are some scattered notes
			sceneview takes in a publisher		// PW essential/big
			swift publishes deltas - $viewmodel.property -> sceneview .sink -> camera of view scenekit
			scenkit -> write models back to viewmodel. s
			viewmodel single source of truth.
			was, back2: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
			now       : SceneView 	native SwiftUI (not full-featured)


 */
//		 sceneview takes in a publisher		// PW essential/big
//		 swift publishes deltas - $viewmodel.property -> sceneview .sink -> camera of view scenekit
//		 scenkit -> write models back to viewmodel. s
//		 viewmodel single source of truth.
//		 was, back2: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
//		 now       : SceneView 	native SwiftUI (not full-featured)

protocol HeadsetView : NSView {		 /// Protypical Graphical User Interface			*/AnyObject/*
	func makeAxis()
	func makeCamera()
	func makeLights()
	var cameraXform :SCNMatrix4	{	get set										}
	func configure(from:FwConfig) 
	var shapeBase	: SCNNode	{	get set										}
	var isSceneKit 	: Bool 		{	get											}
//	var vewBase     : VewBase!	{	get set										}
//	var Sounds					{	get set										}
//	var codable					{	get set										}
	var animatePhysics : Bool 	{	get set										}
	 // Abstract hitTest that works for both SceneKit and RealityKit
	func hitTest3D(_ point: NSPoint, options: [SCNHitTestOption:Any]?) -> [HitTestResult]
}
extension HeadsetView {
	func myVewBase(headsetView:HeadsetView) -> VewBase {
		guard let fm			= FactalsModel.shared else { fatalError("FactalsModel.shared is nil!!") }
		let vewBase				= fm.vewBases.last {	//** USE EXISTING (as a HACK, use it)
				$0.headsetView		== nil
		} ?? {											//** None, MAKE NEW
			let vewBase			= VewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
			vewBase.factalsModel = fm
			vewBase.partBase	= fm.partBase
			if false == fm.vewBases.contains(where: { $0 === vewBase }) 	// $0.id == vewBase.id
			 {	fm.vewBases.append(vewBase)				/* ** Install ** */		}
			return vewBase
		} ()
		vewBase.headsetView		= headsetView				// Always set, whether existing or new
		assert(vewBase === fm.vewBases.last, "paranoia")
		return vewBase
	}
}

// Common result type for both renderers
struct HitTestResult {
	let node: Any      // SCNNode for SceneKit, Entity for RealityKit
	let position: SIMD3<Float>
//	let distance: Float
}
