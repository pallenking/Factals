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

let layout = falseF ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
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
	}
}

struct FactalsModelView: View {
	@Bindable var factalsModel : FactalsModel
	@State private var tabViewSelect:Int = 0
	@State private var tabViewAddCt :Int = 0
	@State private var evaluationTrigger = PassthroughSubject<Int, Never>()

	var body: some View {
		//let _ = Self._printChanges()
		VStack() {	//spacing:-10) {// does nothing
			FactalsModelBar(factalsModel:factalsModel)
			HStack {			// Body Header 0 Buttons
				Text("")
				Spacer()
				Button(label:{ Text("SCN++") }) {
					addNewTab(subTitled:"SCN")									}
				Button(label:{ Text("AR++") })
				{	addNewTab(subTitled:"AR")									}
				Button(label:{ Text("delete") })
				{ 	deleteCurrentTab()											}
				Button(label:{ Text("Test Sound") })
				{	guard let rootScn = (FactalsModel.shared?.vewBases.first?.guiView as? SCNView)?.scene?.rootNode
					 else { print("no rootScn found to play sound"); return}
					rootScn.play(sound:"da")  									}
			}
			NavigationStack {
				TabView(selection:$tabViewSelect) {
					ForEach($factalsModel.vewBases) {	vewBase in
						kitContentView(vewBase:vewBase)
						 .tag(vewBase.wrappedValue.slot_)
						 .tabItem
						 {	Label(vewBase.wrappedValue.title, systemImage: "") 	}
					}
				}
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
			//	 .task(id:tabViewSelect) 	// This triggers BEFORE the new content view is generated
			//	 {	logApp(3, "NavigationStack[\(tabViewSelect)].task(id): pre-evaluation logic here")	 }
			//	 .task(id:tabViewAddCt) 	// on change of tabViewAddCt (This triggers BEFORE, as above)
			//	 {	logApp(3, "NavigationStack[\(tabViewSelect)].task(    tabViewAddCt):\(tabViewAddCt)=>\(tabViewAddCt+1)")
			//		tabViewAddCt		+= 1															 }
				 .accentColor(.green) // Change the color of the selected tab
			}
		}
	}
	@ViewBuilder
	func kitContentView(vewBase:Binding<VewBase>) -> some View {
		let useSceneKit				= true
		if useSceneKit {
			sceneKitContentView(vewBase:vewBase)
		} else {
			realityKitContentView(vewBase:vewBase)
		}
//		if let guiView				= vewBase.wrappedValue.guiView {
//			if guiView.isSceneKit {
//				sceneKitContentView(vewBase:vewBase)
//			} else {
//				realityKitContentView(vewBase:vewBase)
//			}
//		} else {
//			Text("No GUI available")
// 		}
	}
 	private func updateTabTitle() { }	// NO:factalsModel.partBase.title: XXXX
	private func addNewTab(subTitled:String)	  {
		let vewBase 			= VewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
		vewBase.title			= "\(subTitled) \(vewBase.title)"		//assert(vewBase.title == "\(VewBase.nVewBases)", "vewBase.title != nVewBases: \(vewBase.title) != \(VewBase.nVewBases)")
		vewBase.factalsModel	= factalsModel

		factalsModel.vewBases.append(vewBase)
		tabViewSelect 			= factalsModel.vewBases.count - 1	// newly added is at end

		logApp(3, "Modify tabViewAddCt (\(tabViewAddCt)->\(tabViewAddCt+1)) to cause redraw of VewBases.")
		tabViewAddCt			+= 1
	}
	private func deleteCurrentTab() {
		factalsModel.vewBases.remove(at:tabViewSelect)
		tabViewSelect			-= 1
	}
}
