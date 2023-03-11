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
	@Binding	 var document	: FactalsDocument
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
			GutsBar(fwGuts:$fwGuts).padding(.vertical, -10)
 
			HStack {
				if fwGuts.rootVews.count == 0 {
					Text("No Vews found")
				}
				ForEach($fwGuts.rootVews) {	rootVew in
					VStack {	 //  --- H a v e N W a n t  <i>  ---
						VewBar(rootVew:rootVew)
						let rootScn			= rootVew.rootScn.wrappedValue

						ZStack {
							 // This View goes underneath:
							EventReceiver { 	nsEvent in
								rootScn.processEvent(nsEvent:nsEvent, inVew:rootVew.wrappedValue)
							}
							// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
							// now: SceneView 	native SwiftUI
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
							 .border(.black, width:2)

	//						 .gesture(Gesture)
	// NSClickGestureRecognizer
	
							//.onChange(of: Equatable, perform: (Equatable) -> Void)
							//.onMouseDown(perform:handleMouseDown)
						}
					}
				}
			}
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
