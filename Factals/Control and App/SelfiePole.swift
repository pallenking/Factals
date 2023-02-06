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
struct SelfiePole {
	var uid			: UInt16  		= randomUid()
	var at							= SCNVector3.origin	// world
	var spin  		: CGFloat 		= 0					// in degrees
	var horizonUp	: CGFloat 		= 0					// in degrees
	var zoom		: CGFloat 		= 1.0

	 // Computes the transform from a camera A on a selfie stick back to the origin
	var transform : SCNMatrix4 {

		  // From the Origin to the Camera, in steps:
		 //  ---- spin about Y axis
		let spinRadians			= spin * .pi / 180.0
		var poleSpinAboutY		= SCNMatrix4MakeRotation(spinRadians, 0, 1, 0)

		 //  ---- translated above Point of Interest by cameraPoleHeight
		let lookAtVew			= Vew.null
		let posn				= lookAtVew.bBox.center
		let lookAtWorldPosn		= lookAtVew.scn.convertPosition(posn, to:nil)
		assert(!lookAtWorldPosn.isNan, "About to use a NAN World Position")

		poleSpinAboutY.position	= lookAtWorldPosn + at

		 //  ---- With a boom (crane or derek) raised upward above the horizon:
		let upTilt				= horizonUp * .pi / 180.0
		let riseAboveHoriz		= SCNMatrix4MakeRotation(upTilt, 1, 0, 0)

		 //  ---- move out boom from pole, looking backward:
		let toEndOfBoom			= SCNMatrix4Translate(SCNMatrix4.identity, 0, 0, 50.0*zoom) //cameraZoom)//10 ad hoc .5

		let rv					= toEndOfBoom * riseAboveHoriz * poleSpinAboutY
		assert(!rv.isNan, "newCameraXform is Not a Number")
		assert(rv.at(3,3) == 1.0, "why?")	// Understand cameraXform.at(3,3). Is it 1.0? is it prudent to change it here

		return rv
	}

	func pp() -> String {
		return fmt("[at:%@, s:%.0f, u:%.0f, z:%.2f]", at.pp(.short), spin, horizonUp, zoom)
	}
}
