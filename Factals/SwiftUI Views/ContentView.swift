//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
/*
IMPORT OSLog
navigationsplitview
*/
import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding	var document	: FactalsDocument
	var body: some View {
		FactalsModelView(factalsModel: document.factalsModel)
	}
}

struct FactalsModelView: View {
	@ObservedObject var factalsModel : FactalsModel		// not OK here
	@State		var prefFps : String = " Set by FactalsModelView"

	var body: some View {
		VStack {
			HStack {
				 // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				 // NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					VStack {									//Binding<VewBase>
						let scnBase			= vewBase.scnBase.wrappedValue
						ZStack {
							EventReceiver { 	nsEvent in // Catch events (goes underneath)
								print("EventReceiver:point = \(nsEvent.locationInWindow)")
								let _ = scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
							}
							SceneKitView(scnBase:scnBase, prefFps:$prefFps /*Binding<String>*/)		 // New Way (uses old NSViewRepresentable)
							 .frame(maxWidth: .infinity)
							 .border(.black, width:1)
						}
						VewBar(vewBase:vewBase)
					}
				}
				Button("+") {
					factalsModel.anotherVewBase(vewConfig:.atom, fwConfig:[:])
				}
				W(factalsModel:factalsModel)
			}
			FactalsModelBar(factalsModel: factalsModel).padding(.vertical, -10)
			 .padding(10)
/**/		Spacer()
		}
	}
}
/*
window group
 */
//SceneView(					 // Old Way
//	scene:scnBase.scnScene,
//	pointOfView:nil,	// SCNNode
//	options:[.rendersContinuously],
//	preferredFramesPerSecond:30,
//	antialiasingMode:.none,
//	delegate:scnBase,	//SCNSceneRendererDelegate?
//	technique: nil		//SCNTechnique?
//)
// .frame(maxWidth: .infinity)// .frame(width:500, height:300)
// .border(.black, width:1)
//
////		that communicates with a ViewModel
////			to render a SceneKit scene and
////		the ViewModel updates
////			with changes from SceneKit,
////				acting as the single source of truth.
//////////////////////////////// Testing	$publisher/	$view
//// Generate code exemplefying the following thoughts that I am told:
//// sceneview takes in a publisher		// PW essential/big
//// swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
//// scenkit -> write models back to viewmodel. s
//// viewmodel single source of truth.
//// was, back2: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
//// now       : SceneView 	native SwiftUI (not full-featured)
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
