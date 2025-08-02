//
//  RealityKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import RealityKit
import AppKit

// ///////////////// Texting Scaffolding, after Josh and Peter help:///////////

 // Simple test of things like VIEWREPresentable
struct RealityTestView: View {
	@Bindable var factalsModel : FactalsModel

	var body: some View {
		RealityView { content in
			guard let scene = try? await Entity(named:"Scene"/*, in:pyroPandaBundle*/)
			 else {		return 													}
			content.add(scene)
		}
	}
//	.realityViewCameraControls(.orbit)
}

struct MyRealityView : View {
//	var realityBase : RealityBase?			// ARG1: exposes visual world

	var body : some View {
		RealityView(make: { content in 		// inout RealityViewCameraContent in
			fatalError(#function)
		}, update: 		  { content in		// inout RealityViewCameraContent in
			fatalError(#function)
		})					 // Old Way
//			scene:scnBase?.scnView!.scene,		//scnBase.
//			pointOfView:nil,	// SCNNode
//			options:[.rendersContinuously],
//			preferredFramesPerSecond:30,
//			antialiasingMode:.none,
//			delegate:scnBase,	//SCNSceneRendererDelegate?
//			technique: nil		//SCNTechnique?
//		)
	//	 .frame(maxWidth: .infinity)	// .frame(width:500, height:300)
	//	 .border(.black, width:1)
	}
}
