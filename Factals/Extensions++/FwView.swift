//  FwView.swift -- A 2D NSView which displays a 3D FwGuts
/// Key, Mouse, and Touch Events; mouse rotator, mouse pic, ...

import SceneKit
import SwiftUI

			//\\\///\\\///\\\  SCNView, our superclass, conforms to SCNSceneRenderer:
			//\\\				Therefore we have
			//\\\ 	  .sceneTime					-
			//\\\ 	  .autoenablesDefaultLighting	-
			//\\\ 	  .hitTest:options:				***
			//\\\ 	  .audioListener				***
			//\\\ 	  .pointOfView					?
			//\\\ 	  .projectPoint:unprojectPoint: ?
			//\\\ 	  .delegate						***
			//\\\ SCNView.scene		same as fwGuts:

		 //	SCNDebugOptions.showBoundingBoxes,	// bounding boxes for nodes with content.
		//	SCNDebugOptions.showWireframe,		// geometries as wireframe.
		//	SCNDebugOptions.renderAsWireframe,	// only wireframe of geometry
		 //	SCNDebugOptions.showSkeletons,		//?EH? skeletal animation parameters
		 //	SCNDebugOptions.showCreases,		//?EH? nonsmoothed crease regions affected by subdivisions.
		 //	SCNDebugOptions.showConstraints,	//?EH? constraint objects acting on nodes.
				// Cameras and Lighting
		 //	SCNDebugOptions.showCameras,		//?EH? Display visualizations for nodes in the scene with attached cameras and their fields of view.
		 //	SCNDebugOptions.showLightInfluences,//?EH? locations of each SCNLight object
		 //	SCNDebugOptions.showLightExtents,	//?EH? regions affected by each SCNLight
				// Debugging Physics
		//	SCNDebugOptions.showPhysicsShapes,	// physics shapes for nodes with SCNPhysicsBody.
	//	jitteringEnabled		= false		//args.options.contains(.jitteringEnabled)
	//	temporalAntialiasingEnabled	= false	//args.options.contains(.temporalAntialiasingEnabled)

class FwView : SCNView {

	 // MARK: - 2. Object Variables:
	weak							// backpointer?
	 var scnBase : ScnBase?		= nil

	init(frame:CGRect=CGRect(), options:[String:Any]=[:]) {
		super.init(frame:CGRect(), options: [String : Any]())
		isPlaying/*animations*/ = true	// does nothing showsStatistics 		= true			// works fine
		debugOptions			= [			// enable display of:
			SCNDebugOptions.showPhysicsFields,	//?EH?  regions affected by each SCNPhysicsField object
		]
		allowsCameraControl 	= false		// we control camera	//true//args.options.contains(.allowsCameraControl)
		autoenablesDefaultLighting = false	// we contol lighting	//true//args.options.contains(.autoenablesDefaultLighting)
		rendersContinuously		= true		//args.options.contains(.rendersContinuously)
		preferredFramesPerSecond = 30		//args.preferredFramesPerSecond
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
}






