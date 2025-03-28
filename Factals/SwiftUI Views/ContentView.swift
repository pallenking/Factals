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
/*
viewthatfits
anylayout

`fixedSize()` on text returns the ideal size and ignores the proposed size of the parent.
(Adding a note for the week note :)
 
Josh Homann to Everyone (Nov 16, 2024, 1:39 PM)
https://sarunw.com/posts/swiftui-anylayout/
 
John Brewer to Everyone (Nov 16, 2024, 1:43 PM)
Added Josh’s version to GitHub:
https://github.com/jeradesign/LongestPrefix/tree/josh
 
Bob DeLaurentis to Everyone (Nov 16, 2024, 1:44 PM)
For Allen: a ViewThatFits example
https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-an-adaptive-layout-with-viewthatfits
 */

/*
ScnView:
	SCNSceneRenderer(frame) --> ScnBase -> ...
					(key)   --> SYSTEMWIDE
					(key)	--> command
Scene
 */
/*
custom getter from UIFile

 */
import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding var document : FactalsDocument
	@State var prefFps = Float(0.5)
	var body: some View {
		FactalsModelView(factalsModel:document.factalsModel)		// Full App Views
												//	guard let fm = document.factalsModel else { return Text("No FactalsModel") }
												//	return FactalsModelView(factalsModel:fm)		// Full App Views
												//	FactalsModelView(factalsModel:document.factalsModel)		// Full App Views
		.onAppear {
			if let window = NSApplication.shared.windows.first {	//where: { $0.isMainWindow }
				window.title 	= document.factalsModel.partBase.hnwMachine.titlePlus()// + "   from ContentView"
//				window.title 	= document.factalsModel.partBase.title3 + "   from ContentView"
			}
		}
//	////////////////////// SCAFFOLDING /////////////////////////////////////////
	//	SimpleSceneKitView(vewBase:document.factalsModel.vewBases.first, prefFps:$prefFps)
	//	SimpleViewRepresentable(simpleObject:a)						// FAILS
	//	Text("ContentView")  										// Minimal View
	}
}

struct SimpleSceneKitView : View {
	let vewBase : VewBase?
	@Binding var prefFpsC : CGFloat
	var body: some View {
		ZStack {
			let scnBase = vewBase!.scnBase
			SceneKitView(scnBase:scnBase, prefFpsC:$prefFpsC)
				.frame(maxWidth: .infinity)
				.border(.black, width:1)
			EventReceiver { nsEvent in // Catch events (goes underneath)
				//print("Recieved NSEvent.locationInWindow\(nsEvent.locationInWindow)")
				let _ = scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase!.tree)
			}
		}
	}
}
// ////////////////////// END SCAFFOLDING //////////////////////////////////////
/*
all vewbases have
 */
struct Park: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    // Other properties...
}
var parks: [Park] = [
	Park(name: "Chicago"),	Park(name: "Los Angeles"),	Park(name: "San Francisco"),
]

struct FactalsModelView: View {
	@Bindable var factalsModel : FactalsModel
	@State private var tabViewSelect : Int	= 0

	var body: some View {
		//let _ = Self._printChanges()
		VStack() {	//spacing:-10) {// does nothing

			FactalsModelBar(factalsModel:factalsModel)

			HStack {			// Body Header 0 Buttons
				Text("")
				Spacer()

				Button(label:{ Text("--") })
					{ 	deleteCurrentTab()										}
				Button(label:{ Text("++") }) {
					addNewTab()													}
				Button(label:{ Text("Test Sound") }) {
					let rootScn = FACTALSMODEL!.vewBases.first!.scnBase.roots!.rootNode
					rootScn.play(sound:"da")  									//"forward"//"tick"// playSimple(rootScn:rootScn)
				}
			}
			NavigationStack {
				TabView(selection:$tabViewSelect)  {

					 // Create, with tag = slot_
					ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
						HStack (alignment:.top) {
							VStack {									//Binding<VewBase>
								let scnBase = vewBase.scnBase.wrappedValue
								ZStack {
									//let _ = Self._printChanges()

									SceneKitView(scnBase:scnBase, prefFpsC:vewBase.prefFpsC)
										.frame(maxWidth: .infinity)
										.border(.black, width:1)

									EventReceiver { nsEvent in // Catch events (goes underneath)
										if !scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue) {
											guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
											//print("Key '\(c)' not recognized and hence ignored...")
										}
									}
								}
							}//.frame(width: 555)
							VStack {
								VewBaseBar(vewBase:vewBase)
								InspectorsVew(vewBase:vewBase.wrappedValue)
							}.frame(width:400)
						}
						 .tabItem {
						 	Label(vewBase.wrappedValue.title, systemImage: "")	//vewBase.wrapppedValue.slot_//"abcde"//"\(vewBase.vewBase.slot_)"//
						 }
						 .tag(vewBase.wrappedValue.slot_)
					}

				//	 // -2: A View selectable in TabView
				//	SimpleTestView(factalsModel:factalsModel)
				//	 .tabItem { Label("SimpleBase0()", systemImage: "")			}
				//	 .tag(-2)
				//
				//	 // -3: clear screan force redraw
				//	Text("")
				//	 .tabItem { Label("Clear", systemImage: "")					}
				//	 .tag(-3)
    				}
				.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
					updateTabTitle()												}
				.accentColor(.green) // Change the color of the selected tab
		//		List($factalsModel.vewBases) { vewBase in
		//			HStack (alignment:.top) {
		//				VStack {									//Binding<VewBase>
		//					let scnBase = vewBase.scnBase.wrappedValue
		//					ZStack { SceneKitView(scnBase:scnBase, prefFpsC:vewBase.prefFpsC) }
		//				}.frame(width:555, height:355)
		//				VStack {
		//					VewBaseBar(vewBase:vewBase)
		//					InspectorsVew(vewBase:vewBase.wrappedValue)
		//				}.frame(width:400)
		//			}
		//			.tabItem {
		//				Label("Slot_\(vewBase.wrappedValue.slot_)", systemImage: "") 				}	// PW broken
		//			.tag(vewBase.wrappedValue.slot_)
		//		}
		//		.navigationDestination(for:Park.self) { park in
		//			Text("ParkDetails(\(park))")
		//		}
		//		.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
		//			updateTabTitle()												}
		//		.accentColor(.green) // Change the color of the selected tab
			}
		}
	}

	private func updateTabTitle() {		// NO:factalsModel.partBase.title: XXXX
	}
	private func addNewTab() {
		factalsModel.anotherVewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
		tabViewSelect 			= factalsModel.vewBases.count - 1	// set to newly added
	}
	private func deleteCurrentTab() {
		factalsModel.vewBases.removeFirst(tabViewSelect)
	}
}

// ///////////////////////////// Trial Code: ///////////////////////////////////
// ///////////////////////////// Trial Code: ///////////////////////////////////
// ///////////////////////////// Trial Code: ///////////////////////////////////
let layout = falseF ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())

struct ContentView2: View {
	@Binding var document : FactalsDocument
	@State var selfiePole = SelfiePole()
	var body: some View {
//		InspecSCNVector3(label:"position", vect3:$selfiePole.position, oneLine:false)
//			.frame(maxWidth: 100)
		SelfiePoleBar(selfiePole: Binding(
			get: { selfiePole },
			set: { selfiePole = $0 }
		))
		.minimumScaleFactor(0.5)
			.frame(width:700)				// 400+, 300?
//			.frame(maxWidth:300)				// 400+, 300?
			.font(.system(size:12))
	}
}
struct SelfiePoleBar2: View   {													//xyzzy15.5
	@Binding var selfiePole	: SelfiePole

	var body: some View {
		HStack {
			VStack {
				Text("  " + "SelfiePole").bold()	//.foregroundColor(.red)
				Text("id:\(selfiePole.pp(.nameTag))")
			}
	//		HStack {
				InspecSCNVector3(label:"position", vect3:$selfiePole.position, oneLine:false)
				LabeledCGFloat(label:"spin", val:$selfiePole.spin, oneLine:false)
				LabeledCGFloat(label:"gaze", val:$selfiePole.gaze, oneLine:false)
				LabeledCGFloat(label:"zoom", val:$selfiePole.zoom, oneLine:false)
	//		}
	//		.onChange(of: selfiePole.zoom) { print(".onChange(of:selfiePole.zoom:",$0, $1) }
	//		.background(Color(red:1.0, green:0.9, blue:0.9))	// pink
		}
		// .padding(6)
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
