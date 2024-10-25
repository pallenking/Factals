//
//  SelfiePole.swift
//  Factals
//
//  Created by Allen King on 9/8/22.
//

import SceneKit

	// Imagine a camera A on a selfie pole, pointing back to the holder B
   //
  // From Origin to Camera, in steps: Pole about Origin
 //  ---- spun about Y axis

 // Uses Cylindrical Coordinates
struct SelfiePole: Equatable {		//Observable, 
	var nameTag				 	= getNametag()
	var position				= SCNVector3.origin	// world coordinates
	var spin  	: CGFloat 		= 0.0				// in degrees
	var gaze	: CGFloat 		= 0.0				// upward, in degrees
	var zoom	: CGFloat 		= 1.0
	var ortho	: CGFloat		= 0.0				// BROKEN 0->perspective, else ortho

	mutating func configure(from config:FwConfig) {
		 // Configure Camera from Source Code: ["camera":["p":[1,2,3], "u":3.4] ...]]
		if let c 				= config.fwConfig("selfiePole") {//camera") {
			if let pStr 		= c.string("p") {			// 1, 1 2, 1 2 3, 1 2 3 4
				position		= SCNVector3(string:pStr)
			}
			if let s 			= c.float("s"), !s.isNan {	// Spin
				spin 			= CGFloat(s) 					// (in degrees)
			}
			if let u 			= c.float("u"), !u.isNan {	// Horizon look Up
				gaze 			= -CGFloat(u)					// (in degrees)
			}
			if let z 			= c.float("z"), !z.isNan {	// Zoom
				zoom 			= CGFloat(z)
			}
			ortho 				= c.cgFloat("o") ?? 0.0		// Ortho
			atRve(2, print("=== Configure selfiePole(from:\(c.pp(.line)) -> \(pp(.line))"))
		}
	}

	 // Computes the transform from a camera A on a selfie stick back to the origin
	func transform(lookAtVew:Vew) -> SCNMatrix4 {

		  // From the Origin to the Camera, in steps:
		 //  ---- 1: Spin about Y axis
		let spinRadians			= spin * .pi / 180.0
		var poleSpinAboutY1		= SCNMatrix4MakeRotation(spinRadians, 0, 1, 0)
		 //  ---- translated above Point of Interest by cameraPoleHeight
		//let lookAtVew : Vew?	= nil//		= Vew.null
		let posn				= lookAtVew.bBox.center
		let lookAtWorldPosn		= lookAtVew.scnRoot.convertPosition(posn, to:nil)
		assert(!lookAtWorldPosn.isNan, "About to use a NAN World Position")
		poleSpinAboutY1.position = lookAtWorldPosn + position

		 //  ---- 2: With a boom (crane or derek) raised upward above the horizon:
		let riseAboveHoriz2		= SCNMatrix4MakeRotation(gaze * .pi / 180.0, 1, 0, 0)

		 //  ---- move out boom from pole, looking backward:
		let toEndOfBoom3		= SCNMatrix4Translate(SCNMatrix4.identity, 0, 0, 50.0*zoom) //cameraZoom)//10 ad hoc .5

		let rv					= toEndOfBoom3 * riseAboveHoriz2 * poleSpinAboutY1
		assert(!rv.isNan, "newCameraXform is Not a Number")
		assert(rv.at(3,3) == 1.0, "why?")	// Understand cameraXform.at(3,3). Is it 1.0? is it prudent to change it here

		return rv
	}
}
extension SelfiePole : Uid {

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .line:
			return fmt("[at:%@, s:%.2f, u:%.2f, z:%.2f, o:%.2f]", position.pp(.line, aux), spin, gaze, zoom, ortho)
		default:
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
	}
}
