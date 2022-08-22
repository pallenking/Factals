//
//  CameraNode.swift
//  FooDocTry3
//
//  Created by Allen King on 8/21/22.
//

import SceneKit

class CameraNode : SCNNode {

	init(_ config:FwConfig) {															//	func addCameraNode(config:FwConfig) -> SCNNode {
		super.init()																	 // ///// Camera:
		name					= "camera"
		position 				= SCNVector3(0, 0, 100)	// HACK: must agree with updateCameraRotator
		
		// THESE DANGLE:
		// DOC?.fwView?.pointOfView = camNode
		// DOC?.fwView?.audioListener = camNode
		
		self.camera				= SCNCamera()
		camera!.name			= "SCNCamera"
		camera!.wantsExposureAdaptation = false				//A Boolean value that determines whether SceneKit automatically adjusts the exposure level.
		camera!.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
		camera!.exposureAdaptationDarkeningSpeedFactor = 1
		camera!.automaticallyAdjustsZRange = true			//cam.zNear				= 1

		 // Configure Camera from Source Code:
		if let c 				= config.fwConfig("camera") {
			var lastSelfiePole	= FwScene.SelfiePole()
			if let h 			= c.float("h"), !h.isNan {	// Pole Height
				lastSelfiePole.height = CGFloat(h)
			}
			if let u 			= c.float("u"), !u.isNan {	// Horizon look Up
				lastSelfiePole.horizonUp = -CGFloat(u)		/* in degrees */
			}
			if let s 			= c.float("s"), !s.isNan {	// Spin
				lastSelfiePole.spin 	= CGFloat(s) 		/* in degrees */
			}
			if let z 			= c.float("z"), !z.isNan {	// Zoom
				lastSelfiePole.zoom 		= CGFloat(z)
			}
			atRve(2, logd("=== Set camera=\(c.pp(.line))"))		// add printout of lastSelfiePole
		}
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
}
