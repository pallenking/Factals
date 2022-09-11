//
//  FwSceneAsSwiftUIView.swift
//  FooDocTry3
//
//  Created by Allen King on 9/7/22.
//

import SceneKit
import SwiftUI

struct FwViewsArgs {
	let fwScene 				: FwScene
	let pointOfView 			: CameraNode? //SCNNode?		//
	let options 				: SceneView.Options			//= []					//.autoenablesDefaultLighting,//.allowsCameraControl,//.jitteringEnabled,//.rendersContinuously,//.temporalAntialiasingEnabled
	let preferredFramesPerSecond: Int						//= 30
	let antialiasingMode 		: SCNAntialiasingMode		//= .none				//SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
	let delegate 				: SCNSceneRendererDelegate?	// (An SCNView, could hardwire)
	let technique				: SCNTechnique?				= nil
}

		// Wrap a FwScene as a SwiftUI View

struct FwSceneAsSwiftUIView : NSViewRepresentable {		// was final class
	typealias NSViewType 		= FwView	// represent FwView's inside
	var args					: FwViewsArgs

	 // On creation, save the args for later
	init(args:FwViewsArgs)	{
		self.args				= args
	}
	 // Later, use args to make FwView
	func makeNSView(context: Context) -> FwView {
		let rv	:	FwView		= FwView(frame:CGRect(x:0, y:0, width:400, height:400))//, options:[:])
		rv.scene 				= args.fwScene as! SCNScene
		rv.pointOfView 			= args.pointOfView
		rv.backgroundColor		= NSColor("veryLightGray")!
		rv.preferredFramesPerSecond = args.preferredFramesPerSecond
		rv.antialiasingMode		= args.antialiasingMode
		rv.delegate				= args.delegate ?? rv	// nil --> rv's delegate is rv!
		 // Back link UGLY
		args.fwScene.fwView		= rv

		  // Configure Options of FwView
		 // There must be a better way to do this:
		if args.options.contains(.allowsCameraControl) {
			rv.allowsCameraControl = true
		}
		if args.options.contains(.autoenablesDefaultLighting) {
			rv.autoenablesDefaultLighting = true
		}
		if args.options.contains(.jitteringEnabled) {
			//view.jitteringEnabled = true
			print("****** view.jitteringEnabled not implemented ******")//warning
		}
		if args.options.contains(.rendersContinuously) {
			rv.rendersContinuously = true
		}
		if args.options.contains(.temporalAntialiasingEnabled) {
			//view.temporalAntialiasingEnabled = true
			print("****** view.temporalAntialiasingEnabled not implemented ******")
		}
		return rv
	}
	
	 // Unsupported
	func updateNSView(_ nsView: FwView, context: Context) {
	}
}
