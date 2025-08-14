//
//  Workstation.swift
//  Factals
//
//  Created by Allen King on 8/3/24.
//

import SceneKit
// // /////////////// Scene Kit
//typealias Viz					= AnchorEntity
//typealias Vect3 				= SCNVector3
//typealias Vect4 				= SCNVector4
//typealias Matrix4x4 			= SCNMatrix4

 // /////////////// Reality Kit
typealias Viz					= SCNNode
typealias Vect3 				= SIMD3<Float>
typealias Vect4 				= SIMD4<Float>
typealias Matrix4x4 			= simd_float4x4

protocol Workstation {
	// // VIDEO: (OUTPUT)
		// make ScnBase()				// Make SCNView
			func SCNScene(for:SCNNode)		// skins for one Part. perhaps 3 .. 5 SCNNodes
		// Skins for Parts
			func reSkin()

	// // SOUND: (OUTPUT)
		// sound actions

	// // STATE PERSISTENCE / MANAGEMENT

	// // LOGGING:

	// // (INPUT)
		// keyboard
		// mouse
		// 		gestures, including fingera (pinching)



	// // C. Simulation Environment
		//	user defaults
		//	experiment parameters
		//	experiment state (load generate save)
		//	time slider

}
