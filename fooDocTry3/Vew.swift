//
//  Vew.swift
//  fooDocTry3
//
//  Created by Allen King on 5/23/22.
//

import SceneKit
class Vew : Codable, ObservableObject {		//, NSObject, Equatable, PolyWrappable, NSCopying

}

func makePartz() -> SCNScene {
	let scene					= SCNScene()

/*
	for i in 0..<16 {
	
		// All scenens should have a  camera
		let square 					= SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1))
		square.name					= "square\(i)"
*/
		
	// All scenens should have a  camera
	let square 					= SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1))
	square.name					= "square"
//	square.camera 				= SCNCamera()
	scene.rootNode.addChildNode(square)
	
	// place the square
	square.position = SCNVector3(x: 0, y: 0, z: 0)
																			//		// create and add a light to the scene
																			//		let lightNode = SCNNode()
																			//		lightNode.light = SCNLight()
																			//		lightNode.light!.type = .omni
																			//		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
																			//		rootNode.addChildNode(lightNode)
																			//
																			//		// create and add an ambient light to the scene
																			//		let ambientLightNode = SCNNode()
																			//		ambientLightNode.light = SCNLight()
																			//		ambientLightNode.light!.type = .ambient
																			//		ambientLightNode.light!.color = NSColor.darkGray
																			//		rootNode.addChildNode(ambientLightNode)


	return scene
}
