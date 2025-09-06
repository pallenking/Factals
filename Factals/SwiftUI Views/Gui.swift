//
//  Gui.swift
//  Factals
//
//  Created by Allen King on 8/3/24.
//

import SceneKit
//	// // VIDEO: (OUTPUT)
//		 // make ScnBase()				// Make SCNView
//			// func SCNScene(for:SCNNode)		// skins for one Part. perhaps 3 .. 5 SCNNodes
//		// Skins for Parts
//			// func reSkin()
//	// // SOUND: (OUTPUT)
//		 // sound actions
//	// // STATE PERSISTENCE / MANAGEMENT
//	// // LOGGING:
//	// // (INPUT)
//		// keyboard
//		// mouse
//		// 		gestures, including fingera (pinching)
//	// // C. Simulation Environment
//		//	user defaults
//		//	experiment parameters
//		//	experiment state (load generate save)
//		//	time slider

// Generic		||	Scene Kit	|	Reality Kit
//--------------++--------------+-------------------
// Visible		||	SCNNode		|	AnchorEntity
// Vect3 		||	SCNVector3	|	SIMD3<Float>
// Vect4 		||	SCNVector4	|	SIMD4<Float>
// Matrix4x4 	||	SCNMatrix4	|	simd_float4x4

protocol Gui: NSView {			 /// Protypical Graphical User Interface
	var vewBase	: VewBase!		{	get set										}
	var isScnView : Bool 		{	get											}
//	var makeScenery:  Type 		{	get set										}
//	var OriginMark				{	get set										}
//	var cameraXform				{	get set										}
//	var Sounds					{	get set										}
//	var codable					{	get set										}
	var scene : SCNScene		{	get set										}
	var animatePhysics : Bool 	{	get set										}
	 // Abstract hitTest that works for both SceneKit and RealityKit
	func hitTest3D(_ point: NSPoint, options: [SCNHitTestOption:Any]?) -> [HitTestResult]
}


// Common result type for both renderers
struct HitTestResult {
	let node: Any      // SCNNode for SceneKit, Entity for RealityKit
	let position: SIMD3<Float>
//	let distance: Float
}
