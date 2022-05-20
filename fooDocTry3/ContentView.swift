//
//  ContentView.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

class ViewModel: ObservableObject {
	@Published var scene 		= SCNScene(named:  "art.scnassets/ship.scn")!	//"ship"
	@Published var camera 		= SCNCamera()
	let i = 33
//	scene.rootNode				= SCNNode()
//	var camera : SCNCamera		= SCNCamera()
//	cameraNode.camera 			= camera
//	camera.usesOrthographicProjection = true
//	camera.orthographicScale 	= 9
//	camera.zNear 				= 0
//	camera.zFar 				= 100
//	scene.rootNode.camera 		= camera

//	scene.camera				= SCNCamera()
//	sceneView.scene.rootNode.addChildNode(cameraNode)

}

struct ContentView: View {
	@Binding var document: fooDocTry3Document
	@StateObject var viewModel 	= ViewModel()
	let scene = SCNScene(named: "art.scnassets/ship.scn")
	var cameraNode: SCNNode? {
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
		return cameraNode
	}
	var body: some View {
		VStack {
			SceneView(
				scene: scene,
				pointOfView: cameraNode,
				options: [
					.allowsCameraControl,
					.autoenablesDefaultLighting
				]
			)
//			.frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height/2)
		}
	}
}

//struct ContentView_Previews: PreviewProvider {
//	static var previews: some View {
//		ContentView()
//	}
//}
//struct ContentView: View {
//	@Binding var document: fooDocTry3Document
//	@StateObject var viewModel 	= ViewModel()
//
//	var body: some View {
////		//if $document.text != nil {
////		TextEditor(text: $document.text)
////		//}
//		ZStack {
//	//		ship()
////			SceneView(
////				scene: viewModel.scene,
////				pointOfView: viewModel.camera,
////				options: [ .autoenablesDefaultLighting, .temporalAntialiasingEnabled ]
////			)
////			.border(Color.black, width: 3)
//
//			VStack {
//				HStack(alignment: .top, spacing: 0, content: {
//					Button("Boop") {
//						print("Boop!")
//					}
//					.padding()
//					Spacer()
//				})
//				Spacer()
//			}
//
//		}
//	}
///*
// */
//}

//struct ContentView_Previews: PreviewProvider {
//	static var previews: some View {
//		ContentView(document: .constant(fooDocTry3Document()))
//	}
//}
