//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit
import AppKit

struct SceneKitContentView: View {
	@Bindable var vewBase: VewBase

	var body: some View {
		logApp(3, "*** Scene Kit Chosen, for slot \(vewBase.slot_) ***")
		return HStack (alignment:.top) {
			VStack { 		// H: Q=optional, Any/callable
				ZStack { 	//let _ = Self._printChanges()
			/**/	SceneKitView(prefFpsC:$vewBase.prefFps)
					 .frame(maxWidth: .infinity)
					 .border(.black, width:1)
					EventReceiver { nsEvent in // Catch events (goes underneath)
						guard let scnView = vewBase.headsetView as? ScnView
						 else { 	// ERROR:
							guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
							logApp(3, "RealityKitView Key '\(c)' not recognized and hence ignored...")
							return 											}
						let _ 		= scnView.processEvent(nsEvent:nsEvent, inVew:vewBase.tree)
					}
				}
			}
			VStack {
				VStack {
					Text("Scene Kit:").font(Font.title)
					VewBaseBar(vewBase: Binding(
						get: { vewBase },
						set: { _ in }  // VewBase itself doesn't change, only its properties
					))
				}
				 .background(Color(red:1.0, green:1.0, blue:0.9))
				SelfiePoleBar(vewBase: vewBase)		// Pass parent to maintain observation chain
				Divider()
				InspectorsVew(vewBase:vewBase)
			}
		}
	}
}

func sceneKitContentView(vewBase:Binding<VewBase>) -> some View {
	SceneKitContentView(vewBase: vewBase.wrappedValue)
}

struct SceneKitView : NSViewRepresentable {		// SceneKitView()
	@Binding var prefFpsC : CGFloat				// ARG2: (DEBUG)

	typealias Visible			= SCNNode
	typealias Vect3 			= SCNVector3
	typealias Vect4 			= SCNVector4
	typealias Matrix4x4 		= SCNMatrix4
	typealias NSViewType 		= ScnView		// Type represented

	// MARK: - Coordinator for Bidirectional Data Flow
	class Coordinator: NSObject {
		weak 	var scnView		: ScnView?
				var vewBase		: VewBase
		private var observations: [Any] 	= []
		private var isUpdatingFromScene 	= false
		private var isUpdatingFromUI 		= false

		init(vewBase: VewBase) {
			self.vewBase = vewBase
			super.init()
		}

		func setupObservations() {
			// UI → Scene: Observe SelfiePole changes and update camera
			observeSelfiePoleChanges()
		}

		private func observeSelfiePoleChanges() {
			let observation = withObservationTracking {
				// Register interest in all SelfiePole properties
				_ = vewBase.selfiePole.position
				_ = vewBase.selfiePole.spin
				_ = vewBase.selfiePole.gaze
				_ = vewBase.selfiePole.zoom
				_ = vewBase.selfiePole.ortho
			} onChange: { [weak self] in
				self?.selfiePoleDidChange()
				self?.observeSelfiePoleChanges()  // Re-register observation
			}
			observations.append(observation)
		}

		private func selfiePoleDidChange() {
			guard !isUpdatingFromScene else { return }  // Prevent feedback loop
			guard let scnView = scnView else { return }

			isUpdatingFromUI = true
			scnView.updateCamera(from: vewBase.selfiePole)
			isUpdatingFromUI = false
		}

		func sceneDidUpdateSelfiePole() {
			// Called when scene (mouse drag) updates selfiePole
			// This allows @Observable to propagate to UI without triggering camera update
			isUpdatingFromScene = true
			// SelfiePole change will trigger @Observable → UI updates automatically
			// But our guard in selfiePoleDidChange() prevents camera update loop
			DispatchQueue.main.async { [weak self] in
				self?.isUpdatingFromScene = false
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		// Get the vewBase that will be created in makeNSView
		// We'll link them together in makeNSView
		return Coordinator(vewBase: VewBase(vewConfig: .nothing, fwConfig: [:]))
	}

	 // NSViewRepresentable calls this, aka init
	func makeNSView(context:Context) -> ScnView {
		let scnView 			= ScnView()		//	var scnView : ScnView? = nil
		let vewBase 			= scnView.myVewBase(headsetView:scnView)
		vewBase.headsetView 	= scnView		// usage
		scnView.vewBase			= vewBase
		scnView.delegate		= scnView 		//  ? ?  ? ?  ? ?  STRANGE

		// Link Coordinator to actual VewBase and ScnView
		let coordinator 		= context.coordinator
		coordinator.vewBase 	= vewBase
		coordinator.scnView 	= scnView
		scnView.coordinator 	= coordinator

		scnView.makeLights()
		scnView.makeCamera()
		scnView.makeAxis()

		// Setup observations after everything is connected
		coordinator.setupObservations()

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

