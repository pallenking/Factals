//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit
import AppKit

func sceneKitContentView(vewBase:Binding<VewBase>) -> some View {
	logApp(3, "*** Scene Kit Chosen, for slot \(vewBase.wrappedValue.slot_) ***")
	return HStack (alignment:.top) {
		VStack { 		// H: Q=optional, Any/callable		//Binding<VewBase>
			ZStack { 	//let _ = Self._printChanges()
		/**/	SceneKitView(prefFpsC:vewBase.prefFps)
				 .frame(maxWidth: .infinity)
				 .border(.black, width:1)
				EventReceiver { nsEvent in // Catch events (goes underneath)
					guard let scnView = vewBase.wrappedValue.headsetView as? ScnView
					 else { 	// ERROR:
						guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
						logApp(3, "RealityKitView Key '\(c)' not recognized and hence ignored...")
						return 											}
					let _ 		= scnView.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
				}
			}
		}
		VStack {
			VStack {
				Text("Scene Kit:").font(Font.title)
				VewBaseBar(vewBase:vewBase)
			}
			 .background(Color(red:1.0, green:1.0, blue:0.9))
			SelfiePoleBar(selfiePole:vewBase.selfiePole)					// .border(Color.gray, width: 3)
			Divider()
			InspectorsVew(vewBase:vewBase.wrappedValue)
		}
	}
}

struct SceneKitView : NSViewRepresentable {		// SceneKitView()
	@Binding var prefFpsC : CGFloat				// ARG2: (DEBUG)

	typealias Visible			= SCNNode
	typealias Vect3 			= SCNVector3
	typealias Vect4 			= SCNVector4
	typealias Matrix4x4 		= SCNMatrix4
	typealias NSViewType 		= ScnView		// Type represented

	 // NSViewRepresentable calls this, aka init
	func makeNSView(context:Context) -> ScnView {
		let scnView 			= ScnView()		//	var scnView : ScnView? = nil
		let vewBase 			= scnView.myVewBase(headsetView:scnView)
		vewBase.headsetView 	= scnView		// usage
		scnView.vewBase			= vewBase
		scnView.delegate		= scnView 		//  ? ?  ? ?  ? ?  STRANGE

		scnView.makeLights()
		scnView.makeCamera()
		scnView.makeAxis()

		return scnView
	}
	func updateNSView(_ scnView: ScnView, context:Context) {
		scnView.preferredFramesPerSecond = Int(prefFpsC)		//args.preferredFramesPerSecond
	}
}

//------------------------------ Scraps to end -------------------------
						//		@State		var isLoaded	= false
						//		 .onChange(of:isLoaded) { oldVal, newVal in				// compiles, seems OK
						//		 	print(".onChange(of:isLoaded) { \(oldVal), \(newVal)")
						//		 .onAppear {
						//			//coordinator.onAppear()
						//			//$factalsModel.coordinator.onAppear {				}
						//			NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
						//		.onMouseDown(perform:handleMouseDown)				/// no member 'onMouseDown'
						//		.onKeyPress(phases: .up)  { press in
						//		.gesture(tapGesture)				/ NSClickGestureRecognizer
						//		.onTapGesture {

