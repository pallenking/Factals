//
//  ContentView.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

class ViewModel: ObservableObject {
	@Published var scene : SCNScene
	@Published var cameraNode : SCNNode? = nil

	func printModel() {
		print("rootNode.name = '\(scene.rootNode.name ?? "<nil>")'")
		print("rootNode.children = '\(scene.rootNode.childNodes.count)'")
		for scn in scene.rootNode.childNodes {
			print("name:'\(scn.name ?? "<nil>")'")
		}
	}

	init() {
		scene 					= SCNScene(named:"art.scnassets/ship.scn")!
		cameraNode 				= SCNNode()
		cameraNode!.name		= "Camera0.1"
		cameraNode!.camera 		= SCNCamera()
		cameraNode!.position 	= SCNVector3(x: 2, y: 0, z: 10)
		scene.rootNode.addChildNode(cameraNode!)
		
		printModel()
	}
}

struct ContentView: View {
	@Binding var document: fooDocTry3Document
	@StateObject var viewModel 	= ViewModel()
	var body: some View {
		VStack {
			SceneView(
				scene: 		 viewModel.scene,
				pointOfView: viewModel.cameraNode,
				options: [
					.allowsCameraControl,
					.autoenablesDefaultLighting
				]
			)
			.frame(width:400, height:400)
		}
	}
}
