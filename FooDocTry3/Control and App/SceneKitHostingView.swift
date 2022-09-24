//
//  SceneKitHostingView.swift
//  FooDocTry3
//
//  Created by Allen King on 9/7/22.
//
//	Allows SceneKit functionality in a SwiftUI View

import SceneKit
import SwiftUI

		// Wrap a FwGuts as a SwiftUI View

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
//class Coordinator: NSObject {
//	var iii					= 0
////	@Binding var rating: Int
//
//	init(iii:Int) {//*rating: Binding<Int>*/) {
//		self.iii				= iii
//		super.init()
//bug		//$rating = rating
////		rating					= 0
//	}
//}
struct SceneKitHostingView : NSViewRepresentable {								// was final class
	typealias NSViewType 		= SCNView	// represent SCNView inside

	 // On creation, save the args for later
	init(_ args:SCNViewsArgs)	{
		self.args				= args
	}
	var args					: SCNViewsArgs

//	var coord : Coordinator		= Coordinator(iii:-1)

//	func makeCoordinator() {
//		coord.iii				+= 1
//	}
	 // Later, use args to make SCNView
	func makeNSView(context: Context) -> SCNView {		// typedef Context = NSViewRepresentableContext<Self>

//		makeCoordinator()
		let coordinator			= context.coordinator	// View.Coordinator
		let transaction			= context.transaction
		//let transPlist		= transaction.plist
		let environment			= context.environment
		//let preferenceBridge	= context.preferenceBridge

		 // Make new scnScene and scnView:
		let scnScene			= args.scnScene ?? SCNScene() 					// ?? SCNScene(named:"art.scnassets/ship.scn")
		scnScene.isPaused		= false					// perhaps enabled later
		let scnView	: SCNView	= SCNView(frame:CGRect(x:0, y:0, width:400, height:400))//, options:[:])
		scnView.scene			= scnScene
		scnView.pointOfView 	= args.pointOfView
		scnView.backgroundColor	= NSColor("veryLightGray")!
		scnView.preferredFramesPerSecond = args.preferredFramesPerSecond
		scnView.antialiasingMode = args.antialiasingMode
		scnView.delegate		= args.delegate	// nil --> rv's delegate is rv!

		 // Configure SCNScene
		let rootScn				= scnScene.rootNode
		rootScn.name			= "*-ROOT"
		if let fwGuts			= args.fwGuts {
			let i				= fwGuts.fwScn.count - 1
			let fwScn			= fwGuts.fwScn
			fwScn[i]!.scnScene	= scnScene
			fwScn[i]!.scnView	= scnView			// Link things SceneKitHostingView generated
			fwGuts.rootVew[i]!.scn = rootScn 		// set Vew with new scn root

			let pw				= scnScene.physicsWorld
			if pw.contactDelegate != nil {
				assert(pw.contactDelegate !== fwGuts.eventCentral, "")
			}
			pw.contactDelegate = fwGuts.eventCentral
			print(" ........... FwGuts:\(fmt("%04x", fwGuts.uid)) Vew:\(i)........." +
				  "\(String(describing: scnScene.physicsWorld.contactDelegate)) <-2 \(fwGuts.eventCentral)")
	//		assert(scnScene.physicsWorld.contactDelegate === fwGuts.eventCentral, "")
	//		scnScene.physicsWorld.contactDelegate = fwGuts.eventCentral
//	//		assert(fwGuts.fwScn[i]!.scnScene.physicsWorld.contactDelegate === fwGuts.eventCentral, "")
//	//		fwGuts.fwScn[i]!.scnScene.physicsWorld.contactDelegate = fwGuts.eventCentral

		} else {
			warning("makeNSView: args.fwGuts is nil")
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
