//
//  SceneKitHostingView.swift -- AppKit-based SceneKit functionality in a SwiftUI Environment
//  FooDocTry3
//
//  Created by Allen King on 9/7/22.
//
//

import SceneKit
import SwiftUI

		// Wrap a FwGuts as a SwiftUI View

struct SCNViewsArgs {
	var scenekitViewNumber		: Int						= 0
	let fwGuts					: FwGuts?					// owner

	let scnScene 				: SCNScene?
	let pointOfView 			: SCNNode?
	let options 				: SceneView.Options			//= []	.autoenablesDefaultLighting,//.allowsCameraControl,//.jitteringEnabled,//.rendersContinuously,//.temporalAntialiasingEnabled
	let preferredFramesPerSecond: Int						//= 30
	let antialiasingMode 		: SCNAntialiasingMode		//= .none				//SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
	let delegate 				: SCNSceneRendererDelegate?
	let technique				: SCNTechnique?				= nil
}
struct SceneKitHostingView : NSViewRepresentable {								// was final class
	typealias NSViewType 		= SCNView	// represent SCNView inside
	var scenekitViewNumber		: Int?	= nil

	 // 1. On creation, save the args for later
	init(_ args:SCNViewsArgs)	{
		self.args				= args
	}
	var args					: SCNViewsArgs

	 // 2. Later, use args to make SCNView
	func makeNSView(context: Context) -> SCNView {		// typedef Context = NSViewRepresentableContext<Self>
//		if trueF {
////wtf?	makeCoordinator()
//			let coordinator		= context.coordinator	// View.Coordinator
//			let transaction		= context.transaction
//		//	let transPlist		= transaction.plist		// 'plist' is inaccessible due to 'internal' protection level
//			let environment		= context.environment
//			//let preferenceBridge = context.preferenceBridge
//		}
		guard let fwGuts		= args.fwGuts else {	fatalError("args.fwGuts is nil") }
		 // Get new ViewIndex	//		++			++
		let sceneVewIndex		= fwGuts.newViewIndex()
		let scnView				= fwGuts.rootVews[sceneVewIndex].fwScn.scnView!
								//		++			++
//		printFwcState()
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
