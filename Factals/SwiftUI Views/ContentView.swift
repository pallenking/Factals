//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.

import SwiftUI
import SceneKit

struct ContentView: View {
	@Binding	var document	: FactalsDocument
	var body: some View {
		FactalsModelView(factalsModel:$document.factalsModel)
//		.onAppear {
//			let windows 	= NSApplication.shared.windows
//			assert(windows.count == 1, "Cannot find widow unless exactly 1")			//NSApp.keyWindow
//			let rp			= document.factalsModel.partBase
//			windows.first!.title = rp.title
//
//			EventMonitor(mask: [.keyDown, .leftMouseDown, .rightMouseDown]) { event in
//	bug;		print("Event: \(event)")			// Handle the event here
//			}.startMonitoring(for: windows.first!)
//		}
	}
}

//class EventMonitor {
//	private var monitor: Any?
//	private let mask: NSEvent.EventTypeMask
//	private let handler: (NSEvent) -> Void
//
//	init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void) {
//		self.mask = mask
//		self.handler = handler
//	}
//
//	deinit {
//		stopMonitoring()
//	}
//
//	func startMonitoring(for window: NSWindow) {
//		monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
//			self?.handleEvent(event)
//			return event
//		}
//		window.makeFirstResponder(window.contentView)
//	}
//
//	func stopMonitoring() {
//		if let monitor = monitor {
//			NSEvent.removeMonitor(monitor)
//			self.monitor = nil
//		}
//	}
//
//	private func handleEvent(_ event: NSEvent) {
//		handler(event)
//	}
//}

struct FactalsModelView: View {
	@Binding	var factalsModel : FactalsModel		// not OK here
	@State		var isLoaded	= false
	@State		var mouseDown	= false

	var body: some View {

		VStack {
			HStack {
				if factalsModel.vewBases.count == 0 {
					Text("No VewBases found")
				}
				 // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				 // NOTE: 20231016PAK: ForEach{} messes up 'Debug View Hierarchy'
				ForEach($factalsModel.vewBases) {	vewBase in	//Binding<[VewBase]>.Element
					VStack {									//Binding<VewBase>

						SceneKitView()
						 .frame(width:400, height:100)
						 .onAppear { 			//setupHitTesting
							let x				= vewBase.scnBase.wrappedValue.fwView
							vewBase.scnBase.wrappedValue.fwView = nil // NEED fwView here
							//$factalsModel.coordinator.onAppear {				}
							//guard let nsWindow	= NSApplication.shared.windows.first, //?.rootViewController
							//	  let nsView	= nsWindow.contentView else {
							//	fatalError("couldn't find fwView")}
							//scnBase.fwView	= (nsView as! FwView)
						 }

//						ZStack {
//							let scnBase			= vewBase.scnBase.wrappedValue
//							EventReceiver { 	nsEvent in // Catch events (goes underneath)
//								//print("EventReceiver:point = \(nsEvent.locationInWindow)")
//								let _ = scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase.tree.wrappedValue)
//							}
//							// Generate code exemplefying the following thoughts that I am told:
//							// sceneview takes in a publisher		// PW essential/big
//							// swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
//							// scenkit -> write models back to viewmodel. s
//							// viewmodel single source of truth.
//
//							// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
//							// now: SceneView 	native SwiftUI
//
//							//	SceneView
//							//		that communicates with a ViewModel
//							//			to render a SceneKit scene and
//							//		the ViewModel updates
//							//			with changes from SceneKit,
//							//				acting as the single source of truth.
//
//							////////////////////////////// Testing	$publisher/	$view
//
//							SceneView(
//								scene:scnBase.scnScene,		//15a4./_null:SCNNode
//								pointOfView:nil,	// SCNNode
//								options:[.rendersContinuously],
//								preferredFramesPerSecond:30,
//								antialiasingMode:.none,
//								delegate:scnBase,	//SCNSceneRendererDelegate?
//								technique: nil		//SCNTechnique?
//							)
//							 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
//							 .border(.black, width:1)
//							 .onChange(of:isLoaded) { oldVal, newVal in				// compiles, seems OK
//								print(".onChange(of:isLoaded) { \(oldVal), \(newVal)")
//							 }
////							 .onAppear {			//setupHitTesting
////								guard let nsWindow	= NSApplication.shared.windows.first, //?.rootViewController
////									  let nsView	= nsWindow.contentView else {
////									fatalError("couldn't find fwView")
////								}
////								scnBase.fwView		= (nsView as! FwView)
////							 }
//						//	.onAppear(perform: {
//						//		NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
//						//			print("\(isOverContentView ? "Mouse inside ContentView" : "Not inside Content View") x: \(self.mouseLocation.x) y: \(self.mouseLocation.y)")
//						//			return $0
//						//		}
//						//	})
//				//			 .onMouseDown(perform:handleMouseDown)				/// no member 'onMouseDown'
//					//		 .onKeyPress(phases: .up)  { press in
//					//			 print(press.characters)
//					//			 return .handled
//					//		 }
//			//				 .gesture(tapGesture)// NSClickGestureRecognizer
//			//				 .onTapGesture {
//			//				 	let vew:Vew? 		= DOCfactalsModel.modelPic()							//with:nsEvent, inVew:v!
//			//					print("tapGesture -> \(vew?.pp(.classUid) ?? "nil")")
//			//				 }
//						}
						VewBar(vewBase:vewBase)
					}
				}
			}
			FactalsModelBar(factalsModel:$factalsModel).padding(.vertical, -10)
			 .padding(10)
			Spacer()
		}
//			.onAppear() {
//				let windows 	= NSApplication.shared.windows
//				assert(windows.count == 1, "Cannot find widow unless exactly 1")			//NSApp.keyWindow
//				windows.first!.title = factalsModel.partBase?.title ?? "<UNTITLED>"
//			}
	}
//	 .map {	NSApp.keyWindow?.contentView?.convert($0, to: nil)	}
//	 .map { point in SceneView.pointOfView?.hitTest(rayFromScreen: point)?.node }
//	 ?? []
	func handleMouseDown(event: NSEvent) {
		mouseDown = true
		handleMouseEvent(event)
	}
	func handleMouseEvent(_ event: NSEvent) {
		if let view = NSApplication.shared.keyWindow?.contentView {
			let location = view.convert(event.locationInWindow, from: nil)
bug;		if let hitNsView = view.hitTest(location) {//,
				bug
			//let sceneView = hitNsView.node.scene?.view {//as? SCNView {
			//	sceneView.mouseDown(with: event)
			}
		}
	}
}


/*	Scraps:
//		animatePhysics 			= c.bool("animatePhysics") ?? false
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
//		fwView!.backgroundColor	= NSColor("veryLightGray")!
//		fwView!.antialiasingMode = .multisampling16X
//		fwView!.delegate		= self as any SCNSceneRendererDelegate
//	 /// animatePhysics is a posative quantity (isPaused is a negative)
//	var animatePhysics : Bool {
//		get {			return !scnScene.isPaused										}
//		set(v) {		scnScene.isPaused = !v											}
//	}
 */
