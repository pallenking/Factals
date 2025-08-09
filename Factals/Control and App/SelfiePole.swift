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
struct SelfiePole: Equatable {		//Observable, 								//xyzzy15.3
	let nameTag				 	= getNametag()
	var position				= SCNVector3.origin	// world coordinates
	var spin  	: CGFloat 		= 0.0				// in degrees
	var gaze	: CGFloat 		= 0.0				// upward, in degrees
	var zoom	: CGFloat 		= 1.0
	var ortho	: CGFloat		= 0.0				// BROKEN 0->perspective, else ortho
								
	init(position:Vect3?=nil, spin:Float?=nil, gaze:Float?=nil, zoom:Float?=nil, ortho:Float?=nil) {
 //		self.position 			= position  ?? Vect3(0, 0, 0)
 //		self.spin 				= spin		?? 0.0
 //		self.gaze 				= gaze		?? 0.0
 //		self.zoom 				= zoom		?? 1.0
 //		self.ortho 				= ortho		?? 0.0
	}

	mutating func configure(from config:FwConfig) {								//xyzzy15.2
		 // Configure Camera from Source Code: ["camera":["p":[1,2,3], "u":3.4] ...]]
		if let c 				= config.fwConfig("selfiePole") {//camera") {
			if let n	 		= c.string("n") {
				debugger("NameTags are read only. '\(n)' ignored")
			}
			if let p 			= c.string("p") {			// 1, 1 2, 1 2 3, 1 2 3 4
				position		= SCNVector3(string:p)
			}
			if let s 			= c.float("s"), !s.isNan {	// Spin
				spin 			= CGFloat(s) 					// (in degrees)
			}
			if let g 			= c.float("g"), !g.isNan {	// Horizon look Up
				gaze 			= -CGFloat(g)					// (in degrees)
			}
			if let z 			= c.float("z"), !z.isNan {	// Zoom
				zoom 			= CGFloat(z)
			}
			ortho 				= c.cgFloat("o") ?? 0.0		// Ortho
			logRve(2, "=== Configure selfiePole(from:\(c.pp(.line)) -> \(pp(.line))")
		}
	}

	 // Computes the transform from a camera A on a selfie stick back to the origin
	func transform(lookAtVew:Vew) -> SCNMatrix4 {								//xyzzy15.4
		let posnBoxCtr			= lookAtVew.bBox.center
		let position			= lookAtVew.scn.convertPosition(posnBoxCtr, to:nil)
		return transform(lookAt: position)
	}
	func transform(lookAt posn:SCNVector3) -> SCNMatrix4 {								//xyzzy15.4
		assert(!posn.isNan, "About to use a NAN World Position")

		 // From the Origin to the Camera, in steps:
		let toFocusMatrix		= SCNMatrix4Translate(SCNMatrix4.identity, posn.x,posn.y,posn.z)
		var spinMatrix			= SCNMatrix4MakeRotation(spin * .pi/180.0, 0, 1, 0)
		let gazeMatrix			= SCNMatrix4MakeRotation(gaze * .pi/180.0, 1, 0, 0)
		let boomMatrix			= SCNMatrix4Translate(SCNMatrix4.identity, 0, 0, 50.0*zoom) //cameraZoom)//10 ad hoc .5
		let rv					= boomMatrix * gazeMatrix * spinMatrix * toFocusMatrix
		assert(!rv.isNan, "newCameraXform is Not a Number")
		assert(rv.at(3,3) == 1.0, "why?")	// Understand cameraXform.at(3,3). Is it 1.0? is it prudent to change it here

//		 //  ---- 1: translated above Point of Interest by cameraPoleHeight
//		var poleYSpin			= SCNMatrix4MakeRotation(spin * .pi/180.0, 0, 1, 0)
//		poleYSpin.position 		= posn + position	// ---- 2:
//		 //  ---- 3: With a boom (crane or derek) raised upward above the horizon:
//		let gazeUp				= SCNMatrix4MakeRotation(gaze * .pi / 180.0, 1, 0, 0)
//		 //  ---- 4: move out boom from pole, looking backward:
//		let toBoomEnd			= SCNMatrix4Translate(SCNMatrix4.identity, 0, 0, 50.0*zoom) //cameraZoom)//10 ad hoc .5
//
//		let rv					= toBoomEnd * gazeUp * poleYSpin

		return rv
	}
	
	// Update spin and gaze based on mouse delta
	mutating func updateFromMouseDelta(deltaX:Float, deltaY:Float, sensitivity:Float=0.005) {
					// Horizontal mouse movement --> spin = Y-axis rotation
		spin 					+= CGFloat(deltaX * sensitivity)
					// Vertical mouse movement 	 --> gaze = X-axis rotation
		gaze 					-= CGFloat(deltaY * sensitivity)  // Negative for natural mouse behavior
		let maxGaze: CGFloat 	= .pi * 0.4  // Clamp gaze to prevent camera from flipping over
		gaze 					=  max(-maxGaze, min(maxGaze, gaze))
	}
	
	// Get the camera's world position for the current configuration
	func getCameraPosition(focusPoint: Vect3) -> Vect3 {
bug;//	let transform = self.transform(lookingAt: focusPoint)
		return Vect3()//transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
	}
}
extension SelfiePole : Uid {

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		switch mode {
		case .line:
			return fmt("[at:%@, s:%.2f, u:%.2f, z:%.2f, o:%.2f]", position.pp(.line, aux), spin, gaze, zoom, ortho)
		default:
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
	}
}
