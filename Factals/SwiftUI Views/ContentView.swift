//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
/*
IMPORT OSLog
navigationsplitview


UserDefaults
AppStorage

*/
import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding var document : FactalsDocument
	var body: some View {
		//Text("ContentView")
		FactalsModelView(factalsModel: document.factalsModel)
	}
}

struct FactalsModelView: View {
	@Bindable var factalsModel : FactalsModel

	@State private	var tabViewSelect : Int = 0
	var body: some View {
		VStack {
			//Text("FactalsModelView(factalsModel")
			TabView(selection: $tabViewSelect)  {
				  // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				 //  NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					VStack {									//Binding<VewBase>
						//Text("ForEach($factalsModel.vewBases)")
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
//						ForEach(0..<vewBase.inspectors.count, id: \.self) { index in
//							Group {
//								HStack(alignment: .top) {
//									vewBase.inspectors.wrappedValue[index]
//									Spacer() // Ensures the content stays left-aligned
//								}
//							}
//						}
						SelfiePoleBar(selfiePole: vewBase.selfiePole)
						VewBaseBar(vewBase:vewBase)
					}
					.tabItem { Label("L-\(33)", systemImage: "") 				}
				}
	//			ViewRepTest(factalsModel:factalsModel)
	//				.tabItem { Label("ViewRepTest() test", systemImage: "")		}
				 /// WRONG, but slightly  fnctional
				Button("<+>") {}
					.tabItem { Label("+", systemImage: "")						}
					.onAppear {			 addNewTab()							}
				Text("<++>")
					.tabItem { Label("++", systemImage:"") 						}
					.onTapGesture {		 	print("never executed")				}
			}
			.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
				updateTitle()
			}
			.accentColor(.green) // Change the color of the selected tab
	
			FactalsModelBar(factalsModel: factalsModel)
			Spacer()
		}
	}
	private func updateTitle() {
		NSApplication.shared.windows.first?.title = "code updateTitle()!!"
		//if let url 		= documentURL {
		//	try? url.setResourceValues(URLResourceValues(name: document.text))
		//}
	}
	private func addNewTab() {
		factalsModel.anotherVewBase(vewConfig:.atom, fwConfig:[:])
		tabViewSelect 			= factalsModel.vewBases.count - 1
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
