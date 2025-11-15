//
//  GuiView.swift
//  Factals
//
//  Created by Allen King on 8/3/24.
//

import SceneKit
import RealityKit
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

protocol GuiView : AnyObject {		 /// Protypical Graphical User Interface			*/NSView/*
	func makeScenery(anchorEntity:AnchorEntity)->()//	var OriginMark				{	get set										}
	func makeAxis()
	func makeCamera()
	func makeLights()
	var cameraXform :SCNMatrix4	{	get set										}
	func configure(from:FwConfig) 
	var anchor      : SCNNode	{	get set										}
	var isSceneKit 	: Bool 		{	get											}
  //var getScene 	: SCNScene?	{	get set										}
  //var delegate    : SCNSceneRendererDelegate?	{	get set						}
//	var vewBase     : VewBase!	{	get set										}
//	var Sounds					{	get set										}
//	var codable					{	get set										}
//	var animatePhysics : Bool 	{	get set										}
	 // Abstract hitTest that works for both SceneKit and RealityKit
	func hitTest3D(_ point: NSPoint, options: [SCNHitTestOption:Any]?) -> [HitTestResult]
}
extension GuiView {
	func myVewBase(guiView:GuiView) -> VewBase {
		guard let fm			= FactalsModel.shared else { fatalError("FactalsModel.shared is nil!!") }
		let vewBase				= fm.vewBases.last {	//** USE EXISTING (as a HACK, use it)
				$0.guiView		== nil
		} ?? {											//** None, MAKE NEW
			let vewBase			= VewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
			vewBase.factalsModel = fm
			vewBase.partBase	= fm.partBase
			vewBase.guiView		= guiView
			if false == fm.vewBases.contains(where: { $0 === vewBase }) 	// $0.id == vewBase.id
			 {	fm.vewBases.append(vewBase)				/* ** Install ** */		}
			return vewBase
		} ()
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
