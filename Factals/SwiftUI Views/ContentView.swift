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
				window.title 	= "HnwM: " + document.factalsModel.partBase.hnwMachine.titlePlus()// + "   from ContentView"
			}
		}
	// //////////////////// SCAFFOLDING /////////////////////////////////////////
	//	SimpleSceneKitView(vewBase:document.factalsModel.vewBases.first, prefFps:$prefFps)
	//	SimpleViewRepresentable(simpleObject:a)						// FAILS
	//	Text("ContentView")  										// Minimal View
	}
}

//struct SimpleSceneKitView : View {
//	let vewBase : VewBase?
//	@Binding var prefFpsC : CGFloat
//	var body: some View {
//		ZStack {
//								//
//			let scnView 		= vewBase!.scnView
//			let scnBase 		= scnView!.scnBase
//			SceneKitView(scnView:scnView, prefFpsC:$prefFpsC)
//				.frame(maxWidth: .infinity)
//				.border(.black, width:1)
//			EventReceiver { nsEvent in // Catch events (goes underneath)
//				//print("Recieved NSEvent.locationInWindow\(nsEvent.locationInWindow)")
//				let _ 			= scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase!.tree)
//			}
//		}
//	}
//}
//struct ContentViewRKV : View {
//	@Binding var document: FactalsDocument		// unused®
//
//	var body: some View {
//		VStack {
//			Text("RealityKitView")
//			 .font(.title)
//
//			RealityKitView()
////			 .frame(minWidth: 200, minHeight: 150)
//			 .border(Color.gray, width: 1)
//		}
//		//.padding()
//	}
//
//}
// ////////////////////// END SCAFFOLDING //////////////////////////////////////
///*
//all vewbases have
// */
//struct Park: Identifiable, Hashable {
//    var id: UUID = UUID()
//    var name: String
//    // Other properties...
//}
//var parks: [Park] = [
//	Park(name: "Chicago"),	Park(name: "Los Angeles"),	Park(name: "San Francisco"),
//]

struct FactalsModelView: View {
	@Bindable var factalsModel : FactalsModel
	@State private var tabViewSelect : Int	= 0

	var body: some View {
		//let _ = Self._printChanges()
		VStack() {	//spacing:-10) {// does nothing
			FactalsModelBar(factalsModel:factalsModel)
			headerButtonsView
			navigationView
		}
	}
	
	private var headerButtonsView: some View {
		HStack {			// Body Header 0 Buttons
			Text("")
			Spacer()

			Button(label:{ Text("--") })
			{ 	deleteCurrentTab()												}
			Button(label:{ Text("++") })
			{	addNewTab()														}
			Button(label:{ Text("Test Sound") })
			{	let rootScn = FACTALSMODEL!.vewBases.first!.SeeView?.scene.rootNode
				rootScn?.play(sound:"da")  										} //"forward"//"tick"// playSimple(rootScn:rootScn)
		}
	}
	
	private var navigationView: some View {
		NavigationStack {
			TabView(selection:$tabViewSelect)  {
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					tabContentView(vewBase: vewBase)
						.tabItem {
							Label(vewBase.wrappedValue.title, systemImage: "")	//vewBase.wrapppedValue.slot_//"abcde"//"\(vewBase.vewBase.slot_)"//
						}
						.tag(vewBase.wrappedValue.slot_)
				}
				// -3: Reality Kit
				RealityKitView(/*factalsModel:factalsModel*/)
					.tabItem { Label("RealityView()", systemImage: "")			}
					.tag(-3)
			}
			.onChange(of: factalsModel.vewBases, initial:true) { _,_  in
				updateTabTitle()											}
			.accentColor(.green) // Change the color of the selected tab
		}
	}
	
	private func tabContentView(vewBase: Binding<VewBase>) -> some View {
		HStack (alignment:.top) {
			VStack {									//Binding<VewBase>
				let SeeView = vewBase.wrappedValue.SeeView
				ZStack {
					//let _ = Self._printChanges()
					SceneKitView(scnView:SeeView as? SCNView, prefFpsC:vewBase.prefFpsC)
						.frame(maxWidth: .infinity)
						.border(.black, width:1)
					EventReceiver { nsEvent in // Catch events (goes underneath)
						if let scnView = SeeView as? SCNView {
							if !scnView.scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue) {
								guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
								print("Key '\(c)' not recognized and hence ignored...")
							}
						}
					}
				}
			}//.frame(width: 555)
			VStack {
				VewBaseBar(vewBase:vewBase)
				InspectorsVew(vewBase:vewBase.wrappedValue)
			}.frame(width:400)
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
