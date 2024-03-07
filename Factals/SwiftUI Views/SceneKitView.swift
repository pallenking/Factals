//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit

struct SceneKitView: NSViewRepresentable {
	var scnBase : ScnBase		// ARG1
	typealias NSViewType 		= FwView//:SCNView:NSView	// Type represented

	func makeNSView(context: Context) -> FwView {
		let rvFwView			= FwView()//frame:CGRect()
		rvFwView.delegate		= scnBase 		//SCNSceneRendererDelegate?
		rvFwView.scnBase		= scnBase
		rvFwView.scene			= scnBase.scnScene
		scnBase.fwView			= rvFwView
		return rvFwView
//		let sceneView = SCNView()
//		sceneView.scene = SCNScene(named: "yourScene.scn") // Replace "yourScene.scn" with your 3D scene file name
//		sceneView.autoenablesDefaultLighting = true
//		sceneView.allowsCameraControl = true
//		return sceneView
	}

	func updateNSView(_ nsView: FwView, context:Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject {
		var sceneKitView:SceneKitView

		init(_ sceneKitView: SceneKitView) {
			self.sceneKitView = sceneKitView
		}

		func mouseDownX(with event: NSEvent) {
			//let c				= Context()
			let fwView 			= sceneKitView.scnBase.fwView //fwView
			let point			= fwView!.convert(event.locationInWindow, from: nil)
			let hitResults 		= fwView!.hitTest(point, options: [:])
			if let hitResult 	= hitResults.first {
				// This is the first object hit by the click
				let node 		= hitResult.node
				print("Clicked on node: \(node.name ?? "Unnamed")")
				// Perform any actions you want on the node here
			}
		}
	}
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


// // FwView:
//struct SceneKitView: NSViewRepresentable {
//	var scnBase : ScnBase		// ARG1
//	typealias NSViewType 		= FwView//:SCNView:NSView	// Type represented
//
//	func makeNSView(context: Context) -> FwView {
//		let rvFwView			= FwView()//frame:CGRect()
//		rvFwView.delegate		= scnBase 		//SCNSceneRendererDelegate?
//		rvFwView.scnBase		= scnBase
//		rvFwView.scene			= scnBase.scnScene
//		return rvFwView
//	}
//	func updateNSView(_ fwView:FwView, context:Context) {						}
//
//	func makeCoordinator() -> Coordinator {				return Coordinator()	}
//	class Coordinator {
//		var fwView: FwView?
//		func onAppear(_ fwView: FwView) {
//			self.fwView 		= fwView				// NEVER GETS CALLED (bug should)
//			// Now you have access to the FwView instance, Do whatever you want with it
//		}
//	}
//}
