//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.

import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding	var document	: FactalsDocument
	var body: some View {
		FactalsModelView(factalsModel:$document.factalsModel)
	}
}

struct FactalsModelView: View {
	@Binding	var factalsModel : FactalsModel		// not OK here
	@State		var mouseDown	= false

	var body: some View {
		//NewDocumentFromSelection
		VStack {
			HStack {
				if factalsModel.vewBases.count == 0 {
					Text("No VewBases found")
				}
				 // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				 // NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					VStack {									//Binding<VewBase>
						let scnBase			= vewBase.scnBase.wrappedValue
						ZStack {
							EventReceiver { 	nsEvent in // Catch events (goes underneath)
								//print("EventReceiver:point = \(nsEvent.locationInWindow)")
								let _ = scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
							}
								
								// Generate code exemplefying the following thoughts that I am told:
								// sceneview takes in a publisher		// PW essential/big
								// swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
								// scenkit -> write models back to viewmodel. s
								// viewmodel single source of truth.
								
								// was, back2: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
								// now       : SceneView 	native SwiftUI (not full-featured)
								
								//	SceneView
								//		that communicates with a ViewModel
								//			to render a SceneKit scene and
								//		the ViewModel updates
								//			with changes from SceneKit,
								//				acting as the single source of truth.
								
								////////////////////////////// Testing	$publisher/	$view
							if trueF {//falseF {//trueF {//
								SceneKitView(scnBase:scnBase)		 // New Way
								 .frame(maxWidth: .infinity)
								 .border(.black, width:1)
							} else {
								SceneView(							 // Old Way
									scene:scnBase.scnScene,
									pointOfView:nil,	// SCNNode
									options:[.rendersContinuously],
									preferredFramesPerSecond:30,
									antialiasingMode:.none,
									delegate:scnBase,	//SCNSceneRendererDelegate?
									technique: nil		//SCNTechnique?
								)
								 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
								 .border(.black, width:1)
							}
						}
						VewBar(vewBase:vewBase)
					}
				}
			}
			FactalsModelBar(factalsModel:$factalsModel).padding(.vertical, -10)
			 .padding(10)
			Spacer()
		}
	}
}
/*
struct SizeEnvironmentKey: EnvironmentKey {
    static var defaultValue: CGSize = .zero
}
extension EnvironmentValues {
    var windowSize: CGSize {
        get { self[SizeEnvironmentKey.self] }
        set { self[SizeEnvironmentKey.self] = newValue }
    }
}
extension View {
    func insertSizeIntoEnvironment(_ size: CGSize) -> some View {
        environment(\.windowSize, size)
    }
}

@Environment(\.windowSize) private var size
 */
