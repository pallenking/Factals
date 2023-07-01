//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//
import SwiftUI
import SceneKit

extension SCNCameraController : ObservableObject {	}

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
							let rootScn		= rootVew.rootScn.wrappedValue
							EventReceiver { 	nsEvent in // Catch events (goes underneath)
								rootScn.processEvent(nsEvent:nsEvent, inVew:rootVew.wrappedValue)
							}
							// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
							// now: SceneView 	native SwiftUI

							/* A is

							sceneview takes in a publisher		// PW:
							swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
							scenkit -> write models back to viewmodel. s
							viewmodel single source of truth.
							 */

							SceneView(
								scene:rootScn.scnScene,
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
