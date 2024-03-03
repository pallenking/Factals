//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit

struct SceneKitView: NSViewRepresentable {
	typealias NSViewType 		= FwView//:SCNView:NSView	// Type represented

	func makeNSView(context: Context) -> FwView {
		 // simple content for testing:
		guard let scnScene		= SCNScene(named: "art.scnassets/ship.scn") else {	fatalError()	}
		let rvFwView			= FwView()
		rvFwView.scene			= scnScene
		return rvFwView
	}
	func updateNSView(_ fwView:FwView, context:Context) {						}

//	func makeCoordinator() -> Coordinator {				return Coordinator()	}
//	class Coordinator {
//		var fwView: FwView?
//		func onAppear(_ fwView: FwView) {
//			self.fwView 		= fwView				// NEVER GETS CALLED (bug should)
//			//self.fwView?.delegate = scnBase
//			// Now you have access to the FwView instance, Do whatever you want with it
//		}
//	}
}
