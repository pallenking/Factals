//
//  Workstation.swift
//  Factals
//
//  Created by Allen King on 8/3/24.
//

import SceneKit

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
