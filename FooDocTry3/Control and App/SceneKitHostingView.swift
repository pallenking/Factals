//
//  SceneKitHostingView.swift
//  FooDocTry3
//
//  Created by Allen King on 9/7/22.
//
//	Allows SceneKit functionality in a SwiftUI View

import SceneKit
import SwiftUI

struct SCNViewsArgs {
	let fwGuts					: FwGuts?
	let scnScene 				: SCNScene?
	let pointOfView 			: SCNNode?
	let options 				: SceneView.Options			//= []	.autoenablesDefaultLighting,//.allowsCameraControl,//.jitteringEnabled,//.rendersContinuously,//.temporalAntialiasingEnabled
	let preferredFramesPerSecond: Int						//= 30
	let antialiasingMode 		: SCNAntialiasingMode		//= .none				//SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
	let delegate 				: SCNSceneRendererDelegate?
	let technique				: SCNTechnique?				= nil
}

		// Wrap a FwGuts as a SwiftUI View

struct SceneKitHostingView : NSViewRepresentable {								// was final class
	typealias NSViewType 		= SCNView	// represent SCNView inside

	 // On creation, save the args for later
	init(_ args:SCNViewsArgs)	{
		self.args				= args
	}
	var args					: SCNViewsArgs

	 // Later, use args to make SCNView
	func makeNSView(context: Context) -> SCNView {
		let scnView	: SCNView	= SCNView(frame:CGRect(x:0, y:0, width:400, height:400))//, options:[:])
		let scnScene			= args.scnScene ?? SCNScene() 					// ?? SCNScene(named:"art.scnassets/ship.scn")
		scnScene.isPaused		= false					// perhaps enabled later
		scnView.scene			= scnScene
		scnView.pointOfView 	= args.pointOfView
		scnView.backgroundColor	= NSColor("veryLightGray")!
		scnView.preferredFramesPerSecond = args.preferredFramesPerSecond
		scnView.antialiasingMode = args.antialiasingMode
		scnView.delegate		= args.delegate	// nil --> rv's delegate is rv!


ppFwcState()

		 // Connect FwGuts
		if let fwGuts			= args.fwGuts {
			guard let scnScene	= scnView.scene else {	fatalError("makeNSView cannot get SCNScene from SCNView") }
			fwGuts.fwScn.scnScene = scnScene
			fwGuts.fwScn.scnView = scnView			// Link things SceneKitHostingView generated
//??			fwGuts.rootVew.scn	= rootScn			// set Vew with new scn root
			let rootScn			= scnScene.rootNode
			rootScn.name		= "*-ROOT"
		}
		  // Configure Options of FwView
		 // There must be a better way to do this:
		if args.options.contains(.allowsCameraControl) {
			scnView.allowsCameraControl = true
		}
		if args.options.contains(.autoenablesDefaultLighting) {
			scnView.autoenablesDefaultLighting = true
		}
		if args.options.contains(.jitteringEnabled) {
			//view.jitteringEnabled = true
			print("****** view.jitteringEnabled not implemented ******")//warning
		}
		if args.options.contains(.rendersContinuously) {
			scnView.rendersContinuously = true
		}
		if args.options.contains(.temporalAntialiasingEnabled) {
			//view.temporalAntialiasingEnabled = true
			print("****** view.temporalAntialiasingEnabled not implemented ******")
		}
		return scnView
	}
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		atRnd(4, print("----------- SceneKitHostingView.updateNSView called"))
	}
}
