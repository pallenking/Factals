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
struct SelfiePole: Equatable {  			//Observable, 						//xyzzy15.3
	var nameTag   : NameTag
	var position  : SCNVector3				// world coordinates
	var spin	  : CGFloat					// in degrees
	var gaze	  : CGFloat					// upward, in degrees
	var zoom	  : CGFloat
	var ortho	  : CGFloat  				// BROKEN 0->perspective, else ortho
  
	init(
		nameTag n : NameTag 	= getNametag(),
		position  : SCNVector3 	= .origin,//.zero,
		spin	  : Float 		= 0.0,
		gaze	  : Float 		= 0.0,
		zoom	  : Float 		= 1.0,
		ortho	  : Float 		= 0.0
	) {
		self.nameTag			= n
		self.position 			= SCNVector3(position)
		self.spin 				= CGFloat(spin)
		self.gaze 				= CGFloat(gaze)
		self.zoom 				= CGFloat(zoom)
		self.ortho 				= CGFloat(ortho)
	}

	mutating func configure(from config: FwConfig) {  //xyzzy15.2
		// Configure Camera from Source Code: ["selfiePole":["p":[1,2,3], "u":3.4] ...]]
		if let c = config.fwConfig("selfiePole") {
			if let n = c.string("n") {
				debugger("NameTags are read only. '\(n)' ignored")
			}
			if let p = c.string("p")  // 1, 1 2, 1 2 3, 1 2 3 4
			{
				position = SCNVector3(string: p)
			}
			if let s = c.float("s"), !s.isNan  // Spin
			{
				spin = CGFloat(s) /* (in degrees) */
			}
			if let g = c.float("g"), !g.isNan  // Horizon look Up
			{
				gaze = -CGFloat(g) /* (in degrees) */
			}
			if let z = c.float("z"), !z.isNan  // Zoom
			{
				zoom = CGFloat(z)
			}
			ortho = c.cgFloat("o") ?? 0.0  // Ortho
			logRve(2, "=== Configure selfiePole(from:\(c.pp(.line)) -> \(pp(.line))"
			)
		}
	}

	// Computes the transform from a camera A on a selfie stick back to the origin
	var transform: SCNMatrix4 { transform(lookAt: .zero) }
	func transform(lookAtVew: Vew) -> SCNMatrix4 {  //xyzzy15.4
		let posnBoxCtr = lookAtVew.bBox.center
		let position = lookAtVew.scn.convertPosition(posnBoxCtr, to: nil)
		return transform(lookAt: position)
	}
	func transform(lookAt posn: SCNVector3) -> SCNMatrix4 {  //xyzzy15.4
		assert(!posn.isNan, "About to use a NAN World Position")

		// From the Origin to the Camera, in steps:
		let toFocusMatrix = SCNMatrix4Translate(
			SCNMatrix4.identity,
			posn.x,
			posn.y,
			posn.z
		)
		let spinMatrix = SCNMatrix4MakeRotation(spin * .pi / 180.0, 0, 1, 0)
		let gazeMatrix = SCNMatrix4MakeRotation(gaze * .pi / 180.0, 1, 0, 0)
		let boomMatrix = SCNMatrix4Translate(
			SCNMatrix4.identity,
			0,
			0,
			50.0 * zoom
		)  //cameraZoom)//10 ad hoc .5
		let rv = boomMatrix * gazeMatrix * spinMatrix * toFocusMatrix
		assert(!rv.isNan, "newCameraXform is Not a Number")
		assert(rv.at(3, 3) == 1.0, "why?")  // Understand transform.at(3,3). Is it 1.0? is it prudent to change it here
		return rv
	}

	// Update spin and gaze based on mouse delta
	mutating func updateFromMouseDelta(
		deltaX: Float,
		deltaY: Float,
		sensitivity: Float = 0.005
	) {
		// Horizontal mouse movement --> spin = Y-axis rotation
		spin += CGFloat(deltaX * sensitivity)
		// Vertical mouse movement 	 --> gaze = X-axis rotation
		gaze -= CGFloat(deltaY * sensitivity)  // Negative for natural mouse behavior
		let maxGaze: CGFloat = .pi * 0.4  // Clamp gaze to prevent camera from flipping over
		gaze = max(-maxGaze, min(maxGaze, gaze))
	}

	// Get the camera's world position for the current configuration
	func getCameraPosition(focusPoint: SCNVector3) -> SCNVector3 {
		bug  //	let transform = self.transform(lookingAt: focusPoint)
		return SCNVector3()  //transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
	}
}
extension SelfiePole: Uid {

	// MARK: - 15. PrettyPrint
	func pp(_ mode: PpMode = .tree, _ aux: FwConfig = params4defaultPp) -> String
	{
		switch mode {
		case .line:
			let x						= getNametag()
			return String(nameTag) + fmt("[at:%@, s:%.2f, u:%.2f, z:%.2f, o:%.2f]",
				   position.pp(.line, aux), spin, gaze, zoom, ortho)
		default:
			return ppFixedDefault(mode, aux)  // NO, try default method
		}
	}
}
