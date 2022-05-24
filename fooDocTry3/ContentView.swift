//
//  ContentView.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding var document: fooDocTry3Document
	var body: some View {
		HStack {
//			TextField("Enter", text: $document.text)
//				.frame(width:200, height:400)
//				.padding()
			SceneView(
				scene: 		 document.scene,
				pointOfView: document.scene.cameraNode,
				options: [
					.allowsCameraControl,
					.autoenablesDefaultLighting
				]
			)
				.frame(width:400, height:400)
			SceneView(
				scene: 		 document.partz,
				pointOfView: document.partz.cameraNode,
				options: [
					.allowsCameraControl,
					.autoenablesDefaultLighting
				]
			)
				.frame(width:400, height:400)
		}
	}
}
