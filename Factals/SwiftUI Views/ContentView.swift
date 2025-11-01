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

import SwiftUI
import SceneKit
import Combine

struct LazyView<Content: View>: View {
	let build: () -> Content
	init(_ build: @escaping () -> Content) {
		self.build = build
	}
	var body: Content {
		build()
	}
}

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
//			let scnView 		= vewBase!.scnView
//			let scnBase 		= scnView!.scnBase
//			SceneKitView(scnView:scnView, prefFpsC:$prefFpsC)
//				.frame(maxWidth: .infinity)
//				.border(.black, width:1)
//			EventReceiver { nsEvent in // Catch events (goes underneath)
//				//logApp(3, "Recieved NSEvent.locationInWindow\(nsEvent.locationInWindow)")
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
	@State private var tabViewAddCt  : Int	= 0
	@State private var evaluationTrigger = PassthroughSubject<Int, Never>()

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
			Button(label:{ Text("SCN++") })
			{	addNewTabPre()													}
			Button(label:{ Text("AR++") })
			{	addNewTabPre()													}
			Button(label:{ Text("Test Sound") })
			{	guard let rootScn = (FACTALSMODEL?.vewBases.first?.gui as? SCNView)?.scene?.rootNode
				 else { print("no rootScn found to play sound"); return}
				rootScn.play(sound:"da")  										} //"forward"//"tick"// playSimple(rootScn:rootScn)
		}
	}
	private var navigationView: some View {
		let _ 					= Self._printChanges()
		return NavigationStack {
			TabView(selection:$tabViewSelect) {
				ForEach($factalsModel.vewBases) {	vewBase in
					if let gui	= vewBase.wrappedValue.gui {
						if gui.isScnView {				// Scene Kit
							sceneKitContentView(vewBase:vewBase)
							 .tabItem
							 {	Label(vewBase.wrappedValue.title, systemImage: "") }
							 .tag(vewBase.wrappedValue.slot_)
						} else {						// Reality Kit
							realityKitContentView(vewBase:vewBase)
							 .tabItem
							 {	Label("RealityView()", systemImage: "")			}
							 .tag(vewBase.wrappedValue.slot_)
						}
					}
				}
			}
												//	 .task(id:tabViewSelect) {
												//		 // This triggers BEFORE the new content view is generated
												//		logApp(3, "NavigationStack[\(tabViewSelect)].task(id): Pre-evaluating")
												//		 // Your pre-evaluation logic here
												//	 }
												//	 .task(id:tabViewAddCt) {			// on change of tabViewAddCt
												//		 // This triggers BEFORE the new content view is generated
												//		logApp(3, "NavigationStack[\(tabViewSelect)].task(    tabViewAddCt):\(tabViewAddCt)=>\(tabViewAddCt+1)")
												//	//	tabViewAddCt		+= 1
												//		 // Your pre-evaluation logic here
												//	 }
			 .onChange(  of:factalsModel.vewBases, initial:true) { oldValue, newValue  in
				logApp(3, "NavigationStack[\(tabViewSelect)].onChange(of:vewBases): vewBases:\(oldValue)->\(newValue)")

				updateTabTitle()												}
			 .onChange(  of:tabViewSelect  ) { oldValue, newValue in
				logApp(3, "NavigationStack[\(tabViewSelect)].onChange(of:tabViewSelect(\(oldValue)->\(newValue))): evaluationTrigger.send(\(newValue))")
				evaluationTrigger.send(newValue)								}
			 .onChange(  of:tabViewAddCt  ) { oldValue, newValue in
				logApp(3, "NavigationStack[\(tabViewSelect)] onChange tabViewAddCt:\(oldValue)=>\(newValue)")
				evaluationTrigger.send(newValue)								}
			 .onReceive(evaluationTrigger) { newSelection in	 // Invalidate View on evaluationTrigger.
				logApp(3, "NavigationStack[\(tabViewSelect)].onReceive(evaluationTrigger \(newSelection): causes redraw of \($factalsModel.vewBases.count) vewBases")
			 }
			 .accentColor(.green) // Change the color of the selected tab
 		}
	}
//	private func sceneKitContentView(vewBase:Binding<VewBase>) -> some View {
//		logApp(3, "NavigationStack:\(tabViewSelect): Generating content for slot:\(vewBase.wrappedValue.slot_)")
//		return HStack (alignment:.top) {
//			VStack { // H: Q=optional, Any/callable		//Binding<VewBase>
//				//let seeView 	= vewBase.wrappedValue.seeView as? SCNView
//				ZStack {
//					//let _ 	= Self._printChanges()
//			/**/	SceneKitView(prefFpsC:vewBase.prefFps)
//					 .frame(maxWidth: .infinity)
//					 .border(.black, width:1)
//					EventReceiver { nsEvent in // Catch events (goes underneath)
//						guard let scnView = vewBase.wrappedValue.gui as? ScnView
//						 else { 	// ERROR:
//							guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
//							logApp(3, "Key '\(c)' not recognized and hence ignored...")
//							return 											}
//						let _ 	= scnView.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
//								
//					}
//				}
//			}//.frame(width: 555)
//			VStack {
//				VewBaseBar(vewBase:vewBase)
//				InspectorsVew(vewBase:vewBase.wrappedValue)
//			}//.frame(width:500)
//		}
//	}
//
	private func updateTabTitle() { }	// NO:factalsModel.partBase.title: XXXX
	private func addNewTabPre()	  {		// was factalsModel.NewVewBase(..)
	 // OLD WAY:
		let vewBase 			= VewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
		vewBase.factalsModel	= factalsModel
		factalsModel.vewBases.append(vewBase)
		tabViewSelect 			= factalsModel.vewBases.count - 1	// newly added is at end

		logApp(3, "Modify tabViewAddCt (\(tabViewAddCt)->\(tabViewAddCt+1)) to cause redraw of VewBases.")
		tabViewAddCt			+= 1
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
	//		.onChange(of: selfiePole.zoom) { logApp(3, .onChange(of:selfiePole.zoom:",$0, $1) }
	//		.background(Color(red:1.0, green:0.9, blue:0.9))	// pink
		}
		// .padding(6)
	}
}

