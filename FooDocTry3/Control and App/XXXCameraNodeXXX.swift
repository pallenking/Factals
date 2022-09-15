////
////  cameraScn.swift
////  FooDocTry3
////
////  Created by Allen King on 8/21/22.
////
//
////			ELIMINATE THIS FILE
//
//import SceneKit
//
//class cameraScn : SCNNode {
//
//	init(_ config:FwConfig) {										super.init()
//		camera					= SCNCamera()
//		camera!.name			= "SCNCamera"
//		camera!.wantsExposureAdaptation = false				// determines whether SceneKit automatically adjusts the exposure level.
//		camera!.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
//		camera!.exposureAdaptationDarkeningSpeedFactor = 1
//		camera!.automaticallyAdjustsZRange = true			//cam.zNear				= 1
//		//camera!.zNear			= 1
//		//camera!.zFar			= 100
//														// NOOO	addChildNode(camera!)
//		 // Configure Camera from Source Code:
//		if let c 				= config.fwConfig("camera") {
//			var f				= DOCfwGuts
//			if let h 			= c.float("h"), !h.isNan {	// Pole Height
//				f.lastSelfiePole.height	= CGFloat(h)
//			}
//			if let u 			= c.float("u"), !u.isNan {	// Horizon look Up
//				f.lastSelfiePole.horizonUp = -CGFloat(u)		/* in degrees */
//			}
//			if let s 			= c.float("s"), !s.isNan {	// Spin
//				f.lastSelfiePole.spin = CGFloat(s) 		/* in degrees */
//			}
//			if let z 			= c.float("z"), !z.isNan {	// Zoom
//				f.lastSelfiePole.zoom = CGFloat(z)
//			}
//			atRve(2, logd("=== Set camera=\(c.pp(.line))"))		// add printout of lastSelfiePole
//		}
//	}
//
//	required init?(coder: NSCoder)	{	fatalError("init(coder:) has not been implemented")	}
//}
