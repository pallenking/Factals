//  FwView.swift -- A 2D NSView which displays a 3D FwGuts
/// Key, Mouse, and Touch Events; mouse rotator, mouse pic, ...

import SceneKit
import SwiftUI

class FwView : SCNView {
	 // MARK: - 2. Object Variables:
//	var rootScn : RootScn? { bug; return nil }		// NEEDS MORE WORK

//	 //\\\///\\\///\\\  Our super, SCNView, conforms to SCNSceneRenderer:
//	 //\\\				Therefore we have
//	 //\\\ 	  .sceneTime					-
//	 //\\\ 	  .autoenablesDefaultLighting	-
//	 //\\\ 	  .hitTest:options:				***
//	 //\\\ 	  .audioListener				***
//	 //\\\ 	  .pointOfView					?
//	 //\\\ 	  .projectPoint:unprojectPoint: ?
//	 //\\\ 	  .delegate						***
//	 //\\\ SCNView.scene		same as fwGuts:
//	 // MARK: - 3. Factory
//	override init(frame:CGRect, options:[String : Any]? = nil) {
//
//		super.init(frame:frame, options:options) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		atCon(6, logd("initXXX:        FwView/\(ppUid(self)):()"))		// <\(pp(.uidClass))>
//
////		showsStatistics 		= true			// doesn't work here
////		isPlaying/*animations*/	= true			// works here?
////		debugOptions = [
////			SCNDebugOptions.showBoundingBoxes,	//Display the bounding boxes for any nodes with content.
////			SCNDebugOptions.showWireframe,		//Display geometries in the scene with wireframe rendering.
////			SCNDebugOptions.renderAsWireframe,	//Display only wireframe placeholders for geometries in the scene.
////			SCNDebugOptions.showSkeletons,		//Display visualizations of the skeletal animation parameters for relevant geometries.
////			SCNDebugOptions.showCreases,		//Display nonsmoothed crease regions for geometries affected by surface subdivision.
////			SCNDebugOptions.showConstraints,	//Display visualizations of the constraint objects acting on nodes in the scene.
////				// Cameras and Lighting
////			SCNDebugOptions.showCameras,		//Display visualizations for nodes in the scene with attached cameras and their fields of view.
////			SCNDebugOptions.showLightInfluences,//Display the locations of each SCNLight object in the scene.
////			SCNDebugOptions.showLightExtents,	//Display the regions affected by each SCNLight object in the scene.
////				// Debugging Physicsfa
////			SCNDebugOptions.showPhysicsShapes,	//Display the physics shapes for any nodes with attached SCNPhysicsBody objects.
////			SCNDebugOptions.showPhysicsFields,	//Display the regions affected by each SCNPhysicsField object in the scene.
////		]
////		allowsCameraControl 	= false			// dare to turn it on?
////		autoenablesDefaultLighting = false		// dare to turn it on?
//	}
//	 // MARK: - 3.5 Codable
//	required init?(coder decoder: NSCoder) {
//		super.init(coder:decoder) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//	}
//	 // MARK: - 13.4 First Responder
//			 func acceptsFirstResponder()	-> Bool	{	return true				}
//	 // MARK: - 15. PrettyPrint
////	 // MARK: - 17. Debugging Aids
////	override func  becomeFirstResponder()	-> Bool	{	return true				}
////	override func validateProposedFirstResponder(_ responder: NSResponder,
////					   for event: NSEvent?) -> Bool {	return true				}
////	override func resignFirstResponder()	-> Bool	{	return true				}
}
