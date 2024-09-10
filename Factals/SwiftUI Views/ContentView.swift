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
	@StateObject var fooFactalsModel = FooFactalsModel()
	@Binding var document : FactalsDocument
	var body: some View {
		//FactalsModelView(factalsModel: document.factalsModel)		// Full App Views
//		SimpleTestView(factalsModel:document.factalsModel)  		// Test NSViewRepresentable
//		SimpleViewRepresentable(fooFactalsModel:nil)				// WORKS
		SimpleViewRepresentable(fooFactalsModel:fooFactalsModel)	// FAILS
		//Text("ContentView")  										// Minimal View
	}
}
// struct ContentView2: View {
// 	@State var factalsModel = FactalsModel()
// 	@Binding var document : FactalsDocument
//
// 	var body: some View {
// 		//FactalsModelView(factalsModel: document.factalsModel)		// Full App Views
// //		SimpleTestView(factalsModel:document.factalsModel)  		// Test NSViewRepresentable
// //		SimpleViewRepresentable(factalsModel:nil)				// WORKS
// 		SimpleViewRepresentable(factalsModel:factalsModel)	// FAILS
// 		Text("ContentView")  										// Minimal View
// 	}
// }
//
// @Observable class SimpleClass {	}
//
// struct ContentView: View {
// 	@State var myObject = SimpleClass()//FooFactalsModel()
// 	@State var factalsModel = FactalsModel()
// 	@Binding var document : FactalsDocument
// 	var body: some View {
// 		//FactalsModelView(factalsModel: document.factalsModel)		// Full App Views
// //		SimpleTestView(factalsModel:document.factalsModel)  		// Test NSViewRepresentable
// //		SimpleViewRepresentable(fooFactalsModel:nil)				// WORKS
// 		SimpleViewRepresentable(factalsModel:myObject)				// FAILS
// 		Text("ContentView")  										// Minimal View
// 	}
// }

struct FactalsModelView: View {
	@Bindable var factalsModel : FactalsModel
	@State private	var tabViewSelect : Int = 0

	var body: some View {
		VStack {
			FactalsModelBar(factalsModel:factalsModel)
			HStack {
				Text("")
				Spacer()
				Button("<+>") {}
					.tabItem { Label("+", systemImage: "")						}
					.onAppear {			 addNewTab()							}
				Text("<++>")
					.tabItem { Label("++", systemImage:"") 						}
					.onTapGesture {		 	print("never executed")				}

			}
			TabView(selection: $tabViewSelect)  {

				  // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				 //  NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					VStack {									//Binding<VewBase>
						VewBaseBar(vewBase:vewBase)
						let scnSceneBase = vewBase.scnSceneBase.wrappedValue
						ZStack {
							SceneKitView(scnSceneBase:scnSceneBase, prefFps:vewBase.prefFps)
								.frame(maxWidth: .infinity)
								.border(.black, width:1)
							EventReceiver { nsEvent in // Catch events (goes underneath)
 								print("Recieved NSEvent.locationInWindow\(nsEvent.locationInWindow)")
								let _ = scnSceneBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
							}
						}
//						ForEach(0..<vewBase.inspectors.count, id: \.self) { index in
//							Group {
//								HStack(alignment: .top) {
//									vewBase.inspectors.wrappedValue[index]
//									Spacer() // Ensures the content stays left-aligned
//								}
//							}
//						}
					}
					 // Flock: want to access
					.tabItem { Label("L-\(33)", systemImage: "") 				}
				}
				SimpleTestView(factalsModel:factalsModel)
					.tabItem { Label("SimpleTestView()", systemImage: "")		}
			}
			.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
				updateTitle()
			}
			.accentColor(.green) // Change the color of the selected tab
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
