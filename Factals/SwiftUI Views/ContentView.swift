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
//
//	Publisher $zoommodel.zoom
//	viewmodel.$zoom
//				}
//				HStack {  	 //  --- H a v e N W a n t  0  ---
//					ForEach(fwGuts.rootVews) {	rootVew in
//						VStack {	 //  --- H a v e N W a n t  0  ---
//							let slot		= 0
//							VewBar(rootVews:$fwGuts.rootVews,  slot:slot)	// PW1: I don't understand the correct thing to pass in
//							//
//							let sceneKitArgs = SceneKitArgs(
//								slot		: slot,
//								title		: "\(slot): Big main view",
//								rootPart	: fwGuts.rootPart,
//								vewConfig	: vewConfigAllToDeapth4, 				//vewConfig1,//.null,
//								scnScene	: nil,	 // no specific background scene
//								pointOfView	: nil,
//								options		: [.rendersContinuously],	//.allowsCameraControl,
//								preferredFramesPerSecond:30
//							//	handler		: { nsEvent in print("0: Big main view's handler") }
//							)
//							SceneKitView(sceneKitArgs:sceneKitArgs)
//							 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
//							 .border(.black, width:2)
//							 .onAppear() {
//								fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
//								isLoaded = true
//							 }
//						}
//
//					}
//				}

struct ContentView: View {
	@Binding	 var document	: FactalsDocument	// the Document
	var body: some View {
		FwGutsView(fwGuts:$document.fwGuts)	// document:$document,        r
	}
}
struct FwGutsView: View {
	@Binding	var fwGuts		: FwGuts
	@State		var isLoaded	= false

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
						// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
						// now: SceneView 	native SwiftUI
						SceneView(
							scene: nil,
							pointOfView: nil,
							options: [.rendersContinuously],
							preferredFramesPerSecond: 30,
							antialiasingMode: .none,
							delegate: nil, 		//SCNSceneRendererDelegate?
							technique: nil		//SCNTechnique?
						)
						 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
						 .border(.black, width:2)
					}
				}
			}
			Spacer()
		}
	}
}
