//
//  ContentView.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

class JetModel: ObservableObject {
	@Published var scene : SCNScene = SCNScene(named:"art.scnassets/ship.scn")!
}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 	= JetModel()
	var body: some View {
		VStack {
			Text("Dragon Jet")
				.bold()
				.padding()
			HStack {
				SceneView(
					scene: 		 document.scene,
					pointOfView: document.scene.cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
					.frame(width:400, height:400)
				SceneView(
					scene: 		 jetModel.scene,
					pointOfView: jetModel.scene.cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
					.frame(width:400, height:400)
			}
		}
	}
}
