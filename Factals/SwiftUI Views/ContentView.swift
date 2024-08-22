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
	@ObservedObject var factalsModel : FactalsModel
	@State private	var selectedFileIndex : Int = 0
	
	var body: some View {
		VStack {
			TabView(selection: $selectedFileIndex)  {
				// NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				// NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					VStack {									//Binding<VewBase>
						let scnSceneBase = vewBase.scnSceneBase.wrappedValue
						ZStack {
							EventReceiver { nsEvent in // Catch events (goes underneath)
								print("EventReceiver:point = \(nsEvent.locationInWindow)")
								let _ = scnSceneBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
							}
							SceneKitView(scnSceneBase:scnSceneBase, prefFps:vewBase.prefFps)
							 .frame(maxWidth: .infinity)
							 .border(.black, width:1)
						}
 						ForEach(0..<vewBase.inspectors.count, id: \.self) { index in
							Group {
	                			vewBase.inspectors.wrappedValue[index]
							}
						}
						VewBaseBar(vewBase:vewBase)
					}
					 .tabItem { Label("L-\(33)", systemImage: "xmark.circle") }//vewBase.title
//					 .tabItem { Label(factalsModel.partBase.title, systemImage: "xmark.circle") }
				}
				W(factalsModel:factalsModel)
				 .tabItem { Label("W()", systemImage: "1.circle").labelStyle(DefaultLabelStyle())}
				Button("+") {}	/// WRONG, but slightly  fnctional ///
				 .tabItem { Label("+",   systemImage: "plus").padding()			}
				 .onAppear() {			 addNewTab()							}
			}
			.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
				updateTitle()
			}
	        .accentColor(.green) // Change the color of the selected tab

			FactalsModelBar(factalsModel: factalsModel).padding(.vertical, -10)
			 .padding(10)
			Spacer()
		}
	}
	private func updateTitle() {
		//bug//	if let url = documentURL {
		//			try? url.setResourceValues(URLResourceValues(name: document.text))
		//		}
	}
	private func addNewTab() {
		factalsModel.anotherVewBase(vewConfig:.atom, fwConfig:[:])
		selectedFileIndex = factalsModel.vewBases.count - 1
	}
}
/*
window group
 */
//SceneView(					 // Old Way
//	scene:scnSceneBase.scnScene,
//	pointOfView:nil,	// SCNNode
//	options:[.rendersContinuously],
//	preferredFramesPerSecond:30,
//	antialiasingMode:.none,
//	delegate:scnSceneBase,	//SCNSceneRendererDelegate?
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
