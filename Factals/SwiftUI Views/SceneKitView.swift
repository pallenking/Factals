//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit
import AppKit

// ///////////////// Texting Scaffolding, after Josh and Peter help:///////////

 // Simple test of things like VIEWREPresentable
struct SimpleTestView: View {
	@Bindable var factalsModel : FactalsModel

	@State var prefFpsC : CGFloat	= 30.0

	var body: some View {
//		let x = factalsModel.simulator.timeNow
		VStack (alignment:.leading) {
			let size = CGFloat(12)		// of Text
			Text("TextField:NSViewRepresentable / TextField:View ").font(.system(size:size))
			HStack {
				//Text("ViewRepTest:").foregroundStyle(.red).font(.system(size:18))	/// A: SwiftUI Text
				Text("timeNow=(factalsModel.simulator.timeNow)")
				TextField("timeNow=", value:$factalsModel.simulator.timeNow,
						  format:.number.precision(.significantDigits(5)))
					.frame(width:100)
				Button("+=1") {
					factalsModel.simulator.timeNow += 1.0						}
			}
			 .font(.system(size:12))
			Text("SelfiePoleBar(selfiePole):View").font(.system(size:size))
			VStack {									//Binding<VewBase>
				let vewBase0		= $factalsModel.vewBases[0]
				SelfiePoleBar(selfiePole:vewBase0.selfiePole)
					.font(.system(size:12))
			}
			Text("SceneKitView:NSViewRepresentable").font(.system(size:size))
			VStack {									//Binding<VewBase>
				let vewBase0		= factalsModel.vewBases[0]
				let scnSceneBase	= vewBase0.scnSceneBase
				ZStack {
					SceneKitView(scnSceneBase:scnSceneBase, prefFpsC:$prefFpsC)		 // New Way (uses old NSViewRepresentable)
					 .frame(maxWidth: .infinity)
					 .border(.black, width:1)
					Text("Overlayed Text")
					EventReceiver {	nsEvent in // Catch events (goes underneath)
 						print("EventReceiver:point = \(nsEvent.locationInWindow)")
						let _ = scnSceneBase.processEvent(nsEvent:nsEvent, inVew:vewBase0.tree)
					}
					MySceneView(scnSceneBase:scnSceneBase)
				}
			//	VewBaseBar(vewBase:$vewBase0)
			}
		}
		.font(.largeTitle)
	}}

// Flock: nscontrol delegate controltextdideneediting nstextfield delegate nscontrol method
// MARK: END OF SCAFFOLDING //////////////////////////////////////////////////


	//		that communicates with a ViewModel
	//			to render a SceneKit scene and
	//		the ViewModel updates
	//			with changes from SceneKit,
	//				acting as the single source of truth.
	////////////////////////////// Testing	$publisher/	$view
	// Generate code exemplefying the following thoughts that I am told:
	// sceneview takes in a publisher		// PW essential/big
	// swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
	// scenkit -> write models back to viewmodel. s
	// viewmodel single source of truth.
	// was, back2: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
	// now       : SceneView 	native SwiftUI (not full-featured)



 /// SwiftUI Wrapper of SCNView
struct SceneKitView: NSViewRepresentable {
	var scnSceneBase : ScnSceneBase?			// ARG1: exposes visual world
	@Binding var prefFpsC : CGFloat				// ARG2: (DEBUG)
	typealias NSViewType 		= SCNView		// Type represented

	func makeNSView(context: Context) -> SCNView {
		guard let scnSceneBase	else {	fatal("scnSceneBase is nil")			}
		let scnView				= SCNView(frame: NSRect.zero, options: [String : Any]())
		scnSceneBase.scnView	= scnView		// for pic

		scnView.isPlaying		= true			// animations, does nothing
		scnView.showsStatistics	= true			// controls extra bar
	//	scnView.debugOptions	= [				// enable display of:
	//		SCNDebugOptions.showPhysicsFields,]	//  regions affected by each SCNPhysicsField object
		scnView.allowsCameraControl	= true//false// // user may control camera	//args.options.contains(.allowsCameraControl)
		scnView.autoenablesDefaultLighting = false	// we contol lighting	    //args.options.contains(.autoenablesDefaultLighting)
		scnView.rendersContinuously	= true			//args.options.contains(.rendersContinuously)
		scnView.preferredFramesPerSecond = Int(prefFpsC)
		scnView.delegate		= scnSceneBase 	//scnSceneBase is SCNSceneRendererDelegate
		scnView.scene			= scnSceneBase.tree
		return scnView
	}

	func updateNSView(_ nsView: SCNView, context:Context) {
		let scnView				= nsView as SCNView			//	scnSceneBase.scnView
		scnView.preferredFramesPerSecond = Int(prefFpsC)		//args.preferredFramesPerSecond
	}
}

// /////////////////////////////// SceneView ////////////////////////////

struct MySceneView : View {
	var scnSceneBase : ScnSceneBase?			// ARG1: exposes visual world

	var body : some View {
		SceneView(					 // Old Way
			scene:scnSceneBase?.scnView!.scene,		//scnSceneBase.
			pointOfView:nil,	// SCNNode
			options:[.rendersContinuously],
			preferredFramesPerSecond:30,
			antialiasingMode:.none,
			delegate:scnSceneBase,	//SCNSceneRendererDelegate?
			technique: nil		//SCNTechnique?
		)
		 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
		 .border(.black, width:1)
	}
}

// ///////////////////////  SCRAPS   //////////////////////////////////

//	@State		var isLoaded	= false
//								 .onChange(of:isLoaded) { oldVal, newVal in				// compiles, seems OK
//								 	print(".onChange(of:isLoaded) { \(oldVal), \(newVal)")
//								 }
		//						 .onAppear { 			//setupHitTesting
		//						 	let scnSceneBase			= vewBase.scnSceneBase
		//						 	let bind_fwView		= scnSceneBase.scnView		//Binding<FwView?>
		//						 	var y				= "nil"
		//						 	if let scnView		= bind_fwView.wrappedValue,
		//						 	   let s			= scnView.scnSceneBase {
		//						 		y				= s.pp()
		//						 	}
		//						 	print("\(scnSceneBase).scnView.scnSceneBase = \(y)")
		//						 .onAppear { 			//setupHitTesting
		//							//coordinator.onAppear()
		//						 	//$factalsModel.coordinator.onAppear {				}
//		.onAppear {
//			let windows 	= NSApplication.shared.windows
//			assert(windows.count == 1, "Cannot find widow unless exactly 1")			//NSApp.keyWindow
//			let rp			= document.factalsModel.partBase
//			windows.first!.title = rp.title
//			EventMonitor(mask: [.keyDown, .leftMouseDown, .rightMouseDown]) { event in
//	bug;		print("Event: \(event)")			// Handle the event here
//			}.startMonitoring(for: windows.first!)
//		}
			//class EventMonitor {
			//	private var monitor: Any?
			//	private let mask: NSEvent.EventTypeMask
			//	private let handler: EventHandler
			//	init(mask: NSEvent.EventTypeMask, handler: @escaping EventHandler {
			//		self.mask = mask
			//		self.handler = handler
			//	}
			//	deinit {		stopMonitoring()	}
			//	func startMonitoring(for window: NSWindow) {
			//		monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
			//			self?.handleEvent(event)
			//			return event
			//		}
			//		window.makeFirstResponder(window.contentView)
			//	}
			//	func stopMonitoring() {
			//		if let monitor = monitor {
			//			NSEvent.removeMonitor(monitor)
			//			self.monitor = nil
			//		}
			//	}
			//	private func handleEvent(_ event: NSEvent) {
			//		handler(event)
			//	}
			//}


									//NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
									//	print("\(isOverContentView ? "Mouse inside ContentView" : "Not inside Content View") x: \(self.mouseLocation.x) y: \(self.mouseLocation.y)")
									//	return $0
									//}
								//.onMouseDown(perform:handleMouseDown)				/// no member 'onMouseDown'
								//.onKeyPress(phases: .up)  { press in
								//	print(press.characters)
								//	return .handled
								//}
								//.gesture(tapGesture)// NSClickGestureRecognizer
								//.onTapGesture {
								//	let vew:Vew? 		= DOCfactalsModel.modelPic()							//with:nsEvent, inVew:v!
								//  print("tapGesture -> \(vew?.pp(.classUid) ?? "nil")")
								//}
		//animatePhysics 			= c.bool("animatePhysics") ?? false
		//if let gravityAny		= c["gravity"] {
		//	if let gravityVect : SCNVector3 = SCNVector3(from:gravityAny) {
		//		scnScene.physicsWorld.gravity = gravityVect
		//	}
		//	else if let gravityY: Double = gravityAny.asDouble {
		//		scnScene.physicsWorld.gravity.y = gravityY
		//	}
		//}
		//if let speed			= c.cgFloat("speed") {
		//	scnScene.physicsWorld.speed	= speed
		//}
//		scnView!.backgroundColor = NSColor("veryLightGray")!
//		scnView!.antialiasingMode = .multisampling16X
//		scnView!.delegate		= self as any SCNSceneRendererDelegate
//	 /// animatePhysics is a posative quantity (isPaused is a negative)
//	var animatePhysics : Bool {
//		get {			return !scnScene.isPaused										}
//		set(v) {		scnScene.isPaused = !v											}
//	}

