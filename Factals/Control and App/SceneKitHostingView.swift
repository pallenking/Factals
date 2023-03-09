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

//struct SceneKitArgs {
//	var slot			: Int				// N.B var: Unique and Ascending
//	let title			: String
//	let fwGuts			: FwGuts?			// Model
//	let vewConfig		: VewConfig?
////	let scnScene 		: SCNScene?			// Legacy, low level access
//	let pointOfView 	: SCNNode?
//	let options 		: SceneView.Options
//		//.autoenablesDefaultLighting,
//		//.allowsCameraControl,
//		//.jitteringEnabled,
//		//.rendersContinuously,
//		//.temporalAntialiasingEnabled
//	let preferredFramesPerSecond: Int		//= 30
////	let handler			: (NSEvent) -> Void	// = { nsEvent in fatalError("SceneKitArgs default handler is illegal")}	// EXPERIMENTAL
//}

//	struct SceneKitView: View {
//		@Binding var fwGuts : FwGuts
//
//		var body: some View {
//			SceneView(
//				scene: nil,
//				pointOfView: nil,
//				options: [.rendersContinuously],
//				preferredFramesPerSecond: 30,
//				antialiasingMode: .none,
//				delegate: nil, 		//SCNSceneRendererDelegate?
//				technique: nil)		//SCNTechnique?
//	//		ZStack {
//	//			 // /////////
//	//			 let sceneKitArgs = SceneKitArgs(
//	//						slot		: 0,
//	//						title		: "\(0): Big main view",
//	//						fwGuts		: fwGuts,
//	//						vewConfig	: vewConfigAllToDeapth4, 				//vewConfig1,//.null,
//	////						scnScene	: nil,	 // no specific background scene
//	//						pointOfView	: nil,
//	//						options		: [.rendersContinuously],	//.allowsCameraControl,
//	//						preferredFramesPerSecond:30
//	//					//	handler		: { nsEvent in print("0: Big main view's handler") }
//	//						)
//	//			EventReceiver(handler: { nsEvent in
//	//				if let fwGuts = sceneKitArgs.fwGuts,
//	//				  sceneKitArgs.slot >= 0 && sceneKitArgs.slot < fwGuts.rootVews.count {
//	//					let rootVew	= fwGuts.rootVews[sceneKitArgs.slot]
//	//					let _ 	= rootVew.rootScn.processEvent(nsEvent:nsEvent, inVew:rootVew)
//	//				}
//	//			})
//	//			 // ////////////////
//	//			SceneKitHostingView(sceneKitArgs)
//	//			 .allowsHitTesting(true)
//	//		}
//	//		.onChange(of: fwGuts.rootVews) { rootVews in
//	//			rootVews.forEach { rootVew in
//	//				let selfiePole = rootVew.selfiePole
//	//				print("New Zoom: ", selfiePole.zoom)
//	//			}
//	//		}
//	////		.onChange(of: fwGuts.rootVews) { rootViews in
//	////			guard !rootViews.isEmpty else {		return		}
//	////			let selfiePole = rootViews[0].selfiePole
//	////			print("New Zoom: ", selfiePole.zoom)
//	////		}
//	//		}
//		}
//	}

// Zev comment:
//      Current: SCNScene passed to SCNView   (the AppKit way of doing it) wrapped in an NSViewRepresentable called SceneKitHostingView
// Zev proposal: SCNScene passed to SceneView (the native SwiftUI way of doing it)
//class SceneCoordinator {
//	let parent: SceneKitHostingView
//	let foo 					= SCNScene()
//	let fooBar 					= SCNNode()
//
//	init(_ parent: SceneKitHostingView) {
//		self.parent 			= parent
//	}
//}
//
//struct SceneKitHostingView : NSViewRepresentable {								// was final class
//	typealias NSViewType 		= SCNView	// representing a SCNView inside NSViewRepresentable
////	let sceneCoordinator 		= SceneCoordinator()
//
//	 // 1. On creation, save the args for later
//	init(_ args:SceneKitArgs)	{
//		self.args				= args
//		atRnd(4, DOClog.log("=== Slot\(args.slot): ========= SceneKitHostingView title:'\(args.title)'"))
//	}
//	var args					: SceneKitArgs
//
//	func makeCoordinator() -> SceneCoordinator {
//        SceneCoordinator(self)
//    }
//
//	   // 2. It's later! Use args to make SCNView
//	  //  This may be called many times for the same View
//	func makeNSView(context: Context) -> SCNView {		// typedef Context = NSViewRepresentableContext<Self>
//											//	makeCoordinator()	//wtf?
//												let coord				= context.coordinator		// View.Coordinator
//												let x = coord.foo;
//												let transaction			= context.transaction		// a 'plist'
//												let environment			= context.environment		// Empty
//												//let prefBridge 		= context.preferenceBridge	// no member 'preferenceBridge'
//
//		guard let fwGuts		= args.fwGuts else { fatalError("got nil fwGuts!")}
//		atRnd(4, DOClog.log("=== Slot\(args.slot): ========== makeNSView         title:'\(args.title)'"))
//
//		let rootScn	: RootScn	= RootScn(args:args)
//
//		 // Make a new RootVew:
//		let rootVew				= RootVew(forPart:fwGuts.rootPart!, rootScn:rootScn)
//		rootVew.fwGuts			= fwGuts	// owner link
//
//		 // Register with FwGuts
//		rootVew.slot			= fwGuts.rootVews.count		// [0...]
//		fwGuts.rootVews.append(rootVew)
//
//		 // Configure it from document
//		rootVew.configureDocument(from:fwGuts.document.config)
//
//		 // Get an ScnView from rootScn
//		guard let fwView		= rootVew.rootScn.fwView else { fatalError("rootVew.rootScn.fwView is nil")}
//
//		//fwView.scene 			= sceneCoordinator.scene
//		//sceneCoordinator.scene.rootNode.addChildNode(sceneCoordinator.rootNode)
//
//		 // Configure from args.options:
//		fwView.allowsCameraControl			= args.options.contains(.allowsCameraControl)
//		fwView.autoenablesDefaultLighting	= args.options.contains(.autoenablesDefaultLighting)
//		//fwView.jitteringEnabled			= args.options.contains(.jitteringEnabled)
//		fwView.rendersContinuously			= args.options.contains(.rendersContinuously)
//		//fwView.temporalAntialiasingEnabled = args.options.contains(.temporalAntialiasingEnabled)
//		fwView.preferredFramesPerSecond		= args.preferredFramesPerSecond
//		//atRnd(4, DOClog.log("\t\t\t   ==>>  Made \(fwView.pp(.line)) vewConfig:" +
//		//	"'\(args.vewConfig?.pp() ?? "nil")' POV:'\(args.pointOfView?.pp(.classUid) ?? "nil")'"))
//		return fwView
//	}
//	func updateNSView(_ nsView: SCNView, context: Context) {
//		atRnd(4, DOClog.log("=== Slot\(args.slot): =========== updateNSView      title:'\(args.title)' (Does nothing)"))
//	}
//}
