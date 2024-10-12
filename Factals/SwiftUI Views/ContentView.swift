//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
/* TO DO:
NavigationSplitView -- A view that presents views in two or three columns, where selections in leading columns control presentations in subsequent columns
UserDefaults == An interface to the user’s defaults database, where you store key-value pairs persistently across launches of your app.
AppStorage -- A property wrapper type that reflects a value from UserDefaults and invalidates a view on a change in value in that user default
*/
import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding var document : FactalsDocument
	@State var prefFps = Float(0.5)
	var body: some View {
		FactalsModelView(factalsModel:document.factalsModel)		// Full App Views
//	////////////////////// SCAFFOLDING /////////////////////////////////////////
	//	SimpleSceneKitView(vewBase:document.factalsModel.vewBases.first, prefFps:$prefFps)
	//	SimpleViewRepresentable(simpleObject:a)						// FAILS
	//	Text("ContentView")  										// Minimal View
	}
}
struct SimpleSceneKitView : View {
	let vewBase : VewBase?
	@Binding var prefFps : Float
	var body: some View {
		ZStack {
			let scnSceneBase = vewBase!.scnSceneBase
			SceneKitView(scnSceneBase:scnSceneBase, prefFps:$prefFps)
				.frame(maxWidth: .infinity)
				.border(.black, width:1)
			EventReceiver { nsEvent in // Catch events (goes underneath)
				print("Recieved NSEvent.locationInWindow\(nsEvent.locationInWindow)")
				let _ = scnSceneBase.processEvent(nsEvent:nsEvent, inVew:vewBase!.tree)
			}
		}
	}
}
// ////////////////////// END SCAFFOLDING //////////////////////////////////////
/*
all vewbases have
 */

struct FactalsModelView: View {
	@Bindable var factalsModel : FactalsModel
	@State private var tabViewSelect : Int	= 0

	var body: some View {
		let _ = Self._printChanges()

		VStack {
			FactalsModelBar(factalsModel:factalsModel)
			HStack {
				Text("")
				Spacer()
//				Button("<+>") {}
//					.tabItem { Label("+", systemImage: "")						}
// //				.onAppear {			print("dubiousValue")					}
//					.onTapGesture {		addNewTab()								}
				Text("<++>")
					.tabItem { Label("++", systemImage:"") 						}
					.onTapGesture {		addNewTab()								}
			}
			HStack {
				TabView(selection:$tabViewSelect)  {
					  // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
					 //  NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
					ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
						VStack {									//Binding<VewBase>
							VewBaseBar(vewBase:vewBase)
							let scnSceneBase = vewBase.scnSceneBase.wrappedValue
							ZStack {
								 // NSViewRepresentable of a SCNView : UIView
								SceneKitView(scnSceneBase:scnSceneBase, prefFps:vewBase.prefFps)
									.frame(maxWidth: .infinity)
									.border(.black, width:1)
								EventReceiver { nsEvent in // Catch events (goes underneath)
									print("...\n...Recieved NSEvent.locationInWindow\(nsEvent.locationInWindow)")
									let _ = scnSceneBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
								}
							}
						//	let xxx = vewBase.wrappedValue.slot_
							ForEach(0..<vewBase.inspectors.count, id: \.self) { index in
								Group {
									HStack(alignment: .top) {
										vewBase.inspectors.wrappedValue[index]
										Spacer() // Ensures the content stays left-aligned
									}
								}
							}
						}
						// Flock: want to access
						.tabItem { Label("L:\(vewBase.wrappedValue.slot_)", systemImage: "") 			}
						.tag(vewBase.wrappedValue.slot_)
					}

					 // A View selectable in TabView
					SimpleTestView(factalsModel:factalsModel)
					 .tabItem { Label("SimpleTestView()", systemImage: "")		}
					 .tag(-2)

					 // force redraw
					Text("Clear")
					 .tabItem { Label("Clear", systemImage: "")		}
					 .tag(-3)
				}
				.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
					updateTitle()												}
				.accentColor(.green) // Change the color of the selected tab

				// UGLY first attempt at displaying inspectors in a third column
//				VStack {
//					ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
//						ForEach(0..<vewBase.inspectors.count, id: \.self) { index in
//							Group {
//								HStack(alignment: .top) {
//									vewBase.inspectors.wrappedValue[index]
//									Spacer() // Ensures the content stays left-aligned
//								}
//							}
//						}
//					}
//				}
			}
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
		tabViewSelect 			= factalsModel.vewBases.count - 1	// set to newly added
	}
}
/*
window group
 */



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
