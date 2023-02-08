//
//  SceneKitHostingView.swift -- AppKit-based SceneKit functionality in a SwiftUI Environment
//  Factals
//
//  Created by Allen King on 9/7/22.
//
//
// from https://stackoverflow.com/questions/56743724/swiftui-how-to-add-a-scenekit-scene

import SceneKit
import SwiftUI

struct SceneKitArgs {
	var sceneIndex		: Int				// N.B var: Unique and Ascending
	let title			: String
	let rootPart		: RootPart?			// Model
	let vewConfig		: VewConfig?
	let scnScene 		: SCNScene?			// Legacy, low level access
	let pointOfView 	: SCNNode?
	let options 		: SceneView.Options
		//.autoenablesDefaultLighting,
		//.allowsCameraControl,
		//.jitteringEnabled,
		//.rendersContinuously,
		//.temporalAntialiasingEnabled
	let preferredFramesPerSecond: Int		//= 30
}

struct SceneKitView: View {
	let sceneKitArgs : SceneKitArgs

    var body: some View {
		ZStack {
			 // /////////
			EventReceiver(handler: { nsEvent in
				if let fwGuts	= sceneKitArgs.rootPart?.fwGuts,
				  let rootVew	= fwGuts.rootVews[sceneKitArgs.sceneIndex] {
					rootVew.rootScn.processEvent(nsEvent:nsEvent, inVew:nil)
				}
			})
			 // ////////////////
			SceneKitHostingView(sceneKitArgs)
			 .allowsHitTesting(true)
		}
    }
}

// Zev comment:
//      Current: SCNScene passed to SCNView   (the AppKit way of doing it) wrapped in an NSViewRepresentable called SceneKitHostingView
// Zev proposal: SCNScene passed to SceneView (the native SwiftUI way of doing it)
struct SceneKitHostingView : NSViewRepresentable {								// was final class
	typealias NSViewType 		= SCNView	// represent SCNView inside


	 // 1. On creation, save the args for later
	init(_ args:SceneKitArgs)	{
		self.args				= args
		atRnd(4, DOClog.log("=== Slot \(args.sceneIndex): ========= SceneKitHostingView title:'\(args.title)'"))
	}
	var args					: SceneKitArgs

	   // 2. It's later! Use args to make SCNView
	  //  This may be called many times for the same View
	func makeNSView(context: Context) -> SCNView {		// typedef Context = NSViewRepresentableContext<Self>
											//	makeCoordinator()	//wtf?
												let coord : Void		= context.coordinator		// View.Coordinator
												let transaction			= context.transaction		// a 'plist'
												let environment			= context.environment		// Empty
												//let prefBridge 		= context.preferenceBridge	// no member 'preferenceBridge'
		guard let fwGuts		= args.rootPart?.fwGuts else { fatalError("got no fwGuts!")}
		atRnd(4, DOClog.log("=== Slot \(args.sceneIndex): ========== makeNSView         title:'\(args.title)'"))

		let scnScene 			= args.scnScene ?? SCNScene()
		let rootScn	: RootScn	= RootScn(scnScene:scnScene, args:args)

		 // Make a new RootVew:
		let rootVew				= RootVew(forPart:fwGuts.rootPart, rootScn:rootScn)
		rootVew.fwGuts			= fwGuts

		 // Get index :
		let i					= args.sceneIndex
		assert(i >= 0 && i < 4, "Illegal args.sceneIndex:\(i)")

		 // SAVE in array:					// print(fwGuts.rootVews[0].debugDescriaption)
		fwGuts.rootVews[i]		= rootVew

		 // Get an ScnView from rootScn
		let fwView				= rootVew.rootScn.fwView!
		 // Configure from args.options:
		fwView.allowsCameraControl			= args.options.contains(.allowsCameraControl)
		fwView.autoenablesDefaultLighting	= args.options.contains(.autoenablesDefaultLighting)
		//fwView.jitteringEnabled			= args.options.contains(.jitteringEnabled)
		fwView.rendersContinuously			= args.options.contains(.rendersContinuously)
		//returnedScnView.temporalAntialiasingEnabled = args.options.contains(.temporalAntialiasingEnabled)
		fwView.preferredFramesPerSecond		= args.preferredFramesPerSecond
		//atRnd(4, DOClog.log("\t\t\t   ==>>  Made \(fwView.pp(.line)) vewConfig:" +
		//	"'\(args.vewConfig?.pp() ?? "nil")' POV:'\(args.pointOfView?.pp(.classUid) ?? "nil")'"))
		return fwView
	}
	func updateNSView(_ nsView: SCNView, context: Context) {
		atRnd(4, DOClog.log("=== Slot \(args.sceneIndex): =========== updateNSView      title:'\(args.title)' (Does nothing)"))
	}
}
