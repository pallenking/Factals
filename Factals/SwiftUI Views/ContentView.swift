//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
///*
//Generate code exemplefying the following thoughts that I am told:
//sceneview takes in a publisher
//	swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
//	scenkit -> write models back to viewmodel. s
//	viewmodel single source of truth
//or ask me to clarify
// */
////
//import SwiftUI
//import Combine
//import SceneKit
//
// // Define a ViewModel for the SceneView
//class SceneViewModelGPT: ObservableObject {
//	@Published var scene: SCNScene			// Publisher for the scene
//	// ...
//	init(scene: SCNScene) {
//		self.scene = scene
//	}
//	// Function to write models back to the ViewModel
//	func updateModels() {
//		// update the scene or other properties ...
//	}
//}
//
//struct SceneViewGPT: View {				// Using SceneKit View in SwiftUI
//	@ObservedObject var viewModelGPT: SceneViewModelGPT	// SceneViewModelGPT is the single source of truth
//	var body: some View {
//		Text("hello")
//		SceneKitViewGPT(scene: $viewModelGPT.scene)
//			.onReceive(viewModelGPT.$scene) { newScene in
//				// You can manipulate Camera here if needed
//				// let camera = newScene.rootNode.childNode(withName: "camera", recursively: true)
//				// ...
//
//				// update models from SceneKit to ViewModel
//				viewModelGPT.updateModels()
//			}
//	}
//}
//struct SceneKitViewGPT: UIViewRepresentable {
//	@Binding var scene: SCNScene
//	func makeUIView(context: Context) -> SCNView {
//		let scnView = SCNView()
//		scnView.scene = scene
//		return scnView
//	}
//	func updateUIView(_ uiView: SCNView, context: Context) {
//		uiView.scene = scene
//	}
//}
//
//
/*
SceneView
	that communicates with a ViewModel
		to render a SceneKit scene and
	the ViewModel updates
		with changes from SceneKit,
			acting as the single source of truth.

//sceneview takes in a publisher
//	swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
//	scenkit -> write models back to viewmodel. s
//	viewmodel single source of truth

 */

import SwiftUI
import SceneKit

//extension SCNCameraController : ObservableObject {	} //20230701PAK removed

////////////////////////////// Testing
//	$publisher
//	$view

struct ContentView: View {
	@Binding	var document	: FactalsDocument
	var body: some View {
		FwGutsView(fwGuts:$document.fwGuts)
	}
}
struct FwGutsView: View {
	@Binding	var fwGuts		: FwGuts
	@State		var isLoaded	= false
	@State		var mouseDown	= false

	var body: some View {
		VStack {
			HStack {
				if fwGuts.rootVews.count == 0 {
					Text("No Vews found")
				}
				// NOTE: To add more views, change variable "Vews":[] or "Vew1" in network
				ForEach($fwGuts.rootVews) {	rootVew in
					VStack {
						ZStack {
							let rootScn		= RootScn(scn:rootVew.scn.wrappedValue)
							EventReceiver { 	nsEvent in // Catch events (goes underneath)
								rootScn.processEvent(nsEvent:nsEvent, inVew:rootVew.wrappedValue)
							}
							/*
							sceneview takes in a publisher		// PW:
							swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
							scenkit -> write models back to viewmodel. s
							viewmodel single source of truth.
							 */
							// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
							// now: SceneView 	native SwiftUI
							SceneView(
								scene:nil,//rootScn.scnScene,
								pointOfView: nil,	// SCNNode
								options: [.rendersContinuously],
								preferredFramesPerSecond: 30,
								antialiasingMode: .none,
								delegate: nil//rootScn	//SCNSceneRendererDelegate?
							//	technique: nil		//SCNTechnique?
							)
							 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
							 .border(.black, width:1)
							//.gesture(Gesture)// NSClickGestureRecognizer
							//.onChange(of: Equatable, perform: (Equatable) -> Void)
							//.onMouseDown(perform:handleMouseDown)

							//SceneKitHostingView(SceneKitArgs(
							//	slot: Int,
							//	title: String,
							//	fwGuts: fwGuts,
							//	vewConfig: VewConfig?,
							//	pointOfView: SCNNode?,
							//	options: SceneView.Options,
							//	preferredFramesPerSecond: Int
							//SceneKitHostingView(SceneKitArgs(
							//	slot: Int,
							//	title: String,
							//	fwGuts: fwGuts,
							//	vewConfig: VewConfig?,
							//	pointOfView: SCNNode?,
							//	options: SceneView.Options,
							//	preferredFramesPerSecond: Int
							//))
						}
						VewBar(rootVew:rootVew)
					}
				}
			}
			FwGutsBar(fwGuts:$fwGuts).padding(.vertical, -10)
			 .padding(10)
			Spacer()
		}
	}
	func handleMouseDown(event: NSEvent) {
		mouseDown = true
		handleMouseEvent(event)
	}
	func handleMouseEvent(_ event: NSEvent) {
		if let view = NSApplication.shared.keyWindow?.contentView {
			let location = view.convert(event.locationInWindow, from: nil)
bug	//		if let hitResult = view.hitTest(location),
	//		  let sceneView = hitResult.node.scene?.view as? SCNView {
	//			sceneView.mouseDown(with: event)
	//		}
		}
	}
}
