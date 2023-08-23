//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.


///*
//Generate code exemplefying the following thoughts that I am told:
//sceneview takes in a publisher
//	swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
//	scenkit -> write models back to viewmodel. s
//	viewmodel single source of truth
//or ask me to clarify
// */
/*
SceneView
	that communicates with a ViewModel
		to render a SceneKit scene and
	the ViewModel updates
		with changes from SceneKit,
			acting as the single source of truth.

//sceneview takes in a publisher
//	swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
//	scenkit -> write models back to viewmodel. s
//	viewmodel single source of truth

 */

import SwiftUI
import SceneKit
//import Combine

////////////////////////////// Testing
//	$publisher
//	$view

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

struct ContentView: View {
	@Binding	var document	: FactalsDocument
	var body: some View {
		FwGutsView(fwGuts:$document.fwGuts)
	//	 .onAppear {
	//		guard let window = NSApplication.shared.windows.first else { return }
	//		let eventMonitor = EventMonitor(mask: [.keyDown, .leftMouseDown, .rightMouseDown]) { event in
	//			// Handle the event here
	//			print("Event: \(event)")
	//		}
	//		eventMonitor.startMonitoring(for: window)
	//	 }
	}
}
struct FwGutsView: View {
	@Binding	var fwGuts		: FwGuts
	@State		var isLoaded	= false
	@State		var mouseDown	= false

	var body: some View {
		VStack {
			HStack {
				if fwGuts.rootVews.count == 0 {
					Text("No Vews found")
				}
				// NOTE: To add more views, change variable "Vews":[] or "Vew1" in network
				ForEach($fwGuts.rootVews) {	rootVew in
					VStack {
						ZStack {
							let rootScene = rootVew.rootScene.wrappedValue
							EventReceiver { 	nsEvent in // Catch events (goes underneath)
								let _ = rootScene.processEvent(nsEvent:nsEvent, inVew:rootVew.wrappedValue)
							}
							/*
							sceneview takes in a publisher		// PW:
							swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
							scenkit -> write models back to viewmodel. s
							viewmodel single source of truth.
							 */
							// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
							// now: SceneView 	native SwiftUI
							SceneView(
								scene:rootScene,
								pointOfView:nil,	// SCNNode
								options:[.rendersContinuously],
								preferredFramesPerSecond:30,
								antialiasingMode:.none,
								delegate:rootScene,	//nil//SCNSceneRendererDelegate?
								technique: nil		//SCNTechnique?
							)
							 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
							 .border(.black, width:1)
							//.gesture(Gesture)// NSClickGestureRecognizer
							//.onChange(of: Equatable, perform: (Equatable) -> Void)
							//.onMouseDown(perform:handleMouseDown)
						//	 .onAppear(perform: setupHitTesting)
							 .onTapGesture(perform: handleTap)
						}
						VewBar(rootVew:rootVew)
					}
				}
			}
			FwGutsBar(fwGuts:$fwGuts).padding(.vertical, -10)
			 .padding(10)
			Spacer()
		}
	}
	private func handleTap() {
		guard let nsEvent 		= NSApp.currentEvent,
		 let sceneView 			= NSApp.keyWindow?.contentView as? SCNView else { return }
		let locationInView 		= sceneView.convert(nsEvent.locationInWindow, from:nil)
		
		let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: false]
		let hitTestResults = sceneView.hitTest(locationInView, options: hitTestOptions)

bug;	let v:Vew?				= nil
		let x:Vew? 				= DOCfwGuts.modelPic(with:nsEvent, inVew:v!)
		
		//selectedNode = hitTestResults.first?.node
	}
//	func tapGesture(value v:TapGesture.Value, count:Int) {
//		let fwGuts				= DOCfwGuts
//		print("tapGesture value:'\(v)' count:\(count)")
//
//		 // Make NSEvent for Double Click
//		let a					= fwGuts.fwScns[0].scnScene.cameraScn!.position
//		let location			= NSPoint(x: a.x, y: a.y)
//		let nsEvent:NSEvent	 	= NSEvent.mouseEvent(	with:.leftMouseDown,
//											location:location,
//											modifierFlags:.numericPad,//?? :NSEvent.ModifierFlags,
//			/* WTF: */			  timestamp:0,windowNumber:0,context:nil,eventNumber:0,
//											clickCount:count,
//											pressure:1.0)!
//		 // dispatch Pic event
//		let x:Vew? 				= DOCfwGuts.modelPic(with:nsEvent)
////		print(windowController0)
//		print(x ?? "<<nil>>")
//	}

//	private func handleTapXX() {
//		let nsEvent				= NSApp.currentEvent
//		let locationInWindow 	= nsEvent?.locationInWindow//(in: SCNNode())
//		// .map {	NSApp.keyWindow?.contentView?.convert($0, to: nil)	}
//		// .map { point in SceneView.pointOfView?.hitTest(rayFromScreen: point)?.node }
//		// ?? []
//		selectedNode = hitTestResults.first
//	}

//	func setupHitTesting() {
//		guard let nsWindow		= NSApplication.shared.windows.first, //?.rootViewController
//		  let nsView			= nsWindow.contentView,
//		  let fwView			= nsView as? SCNView else { fatalError("couldn't find fwView")	}
//		// Perform hit testing on tap gesture
//		let tapGestur			= UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//		sceneView.addGestureRecognizer(tapGestur)
//	}

	func handleMouseDown(event: NSEvent) {
		mouseDown = true
		handleMouseEvent(event)
	}
	func handleMouseEvent(_ event: NSEvent) {
		if let view = NSApplication.shared.keyWindow?.contentView {
			let location = view.convert(event.locationInWindow, from: nil)
bug	//		if let hitResult = view.hitTest(location),
	//		  let sceneView = hitResult.node.scene?.view as? SCNView {
	//			sceneView.mouseDown(with: event)
	//		}
		}
	}
}
/*
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

// FwView scraps: ===================
//class FwView : SCNView {
//			//\\\///\\\///\\\  Our super, SCNView, conforms to SCNSceneRenderer:
//			//\\\				Therefore we have
//			//\\\ 	  .sceneTime					-
//			//\\\ 	  .autoenablesDefaultLighting	-
//			//\\\ 	  .hitTest:options:				***
//			//\\\ 	  .audioListener				***
//			//\\\ 	  .pointOfView					?
//			//\\\ 	  .projectPoint:unprojectPoint: ?
//			//\\\ 	  .delegate						***
//			//\\\ SCNView.scene		same as fwGuts:
//
//	 // MARK: - 2. Object Variables:
//	 //	In assumed reality, an FwView _owns_ the RootScene
//	var rootScn : RootScn?		= nil
//
////	var handler : (NSEvent)->Void = { nsEvent in fatalError("FwView's default handler is null")}
//
//	init(frame:CGRect, options:[String:Any]=[:]) {
//		super.init(frame:CGRect(), options: [String : Any]())
//
//		isPlaying/*animations*/ = true	// does nothing showsStatistics 		= true			// works fine
//		debugOptions	= [						// enable display of:
//		 //	SCNDebugOptions.showBoundingBoxes,	// bounding boxes for nodes with content.
//		//	SCNDebugOptions.showWireframe,		// geometries as wireframe.
//		//	SCNDebugOptions.renderAsWireframe,	// only wireframe of geometry
//		 //	SCNDebugOptions.showSkeletons,		//?EH? skeletal animation parameters
//		 //	SCNDebugOptions.showCreases,		//?EH? nonsmoothed crease regions affected by subdivisions.
//		 //	SCNDebugOptions.showConstraints,	//?EH? constraint objects acting on nodes.
//				// Cameras and Lighting
//		 //	SCNDebugOptions.showCameras,		//?EH? Display visualizations for nodes in the scene with attached cameras and their fields of view.
//		 //	SCNDebugOptions.showLightInfluences,//?EH? locations of each SCNLight object
//		 //	SCNDebugOptions.showLightExtents,	//?EH? regions affected by each SCNLight
//				// Debugging Physics
//		//	SCNDebugOptions.showPhysicsShapes,	// physics shapes for nodes with SCNPhysicsBody.
//		 //	SCNDebugOptions.showPhysicsFields,	//?EH?  regions affected by each SCNPhysicsField object
//		]
//
//		allowsCameraControl 	= false		// we control camera	//true//args.options.contains(.allowsCameraControl)
//		autoenablesDefaultLighting = false	// we contol lighting	//true//args.options.contains(.autoenablesDefaultLighting)
//		rendersContinuously		= true		//args.options.contains(.rendersContinuously)
//		preferredFramesPerSecond = 30		//args.preferredFramesPerSecond
//	//	jitteringEnabled		= false		//args.options.contains(.jitteringEnabled)
//	//	temporalAntialiasingEnabled	= false	//args.options.contains(.temporalAntialiasingEnabled)
//	}


//import SwiftUI
//import Combine
//import SceneKit
//
// SCNScene ChatGPT ================
// // Define a ViewModel for the SceneView
//class SceneViewModelGPT: ObservableObject {
//	@Published var scene: SCNScene			// Publisher for the scene
//	// ...
//	init(scene: SCNScene) {
//		self.scene = scene
//	}
//	// Function to write models back to the ViewModel
//	func updateModels() {
//		// update the scene or other properties ...
//	}
//}
//
//struct SceneViewGPT: View {				// Using SceneKit View in SwiftUI
//	@ObservedObject var viewModelGPT: SceneViewModelGPT	// SceneViewModelGPT is the single source of truth
//	var body: some View {
//		Text("hello")
//		SceneKitViewGPT(scene: $viewModelGPT.scene)
//			.onReceive(viewModelGPT.$scene) { newScene in
//				// You can manipulate Camera here if needed
//				// let camera = newScene.rootNode.childNode(withName: "camera", recursively: true)
//				// ...
//
//				// update models from SceneKit to ViewModel
//				viewModelGPT.updateModels()
//			}
//	}
//}
//struct SceneKitViewGPT: UIViewRepresentable {
//	@Binding var scene: SCNScene
//	func makeUIView(context: Context) -> SCNView {
//		let scnView = SCNView()
//		scnView.scene = scene
//		return scnView
//	}
//	func updateUIView(_ uiView: SCNView, context: Context) {
//		uiView.scene = scene
//	}
//}


 */
