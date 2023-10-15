//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.

import SwiftUI
import SceneKit
//import Combine

/* Generate code exemplefying the following thoughts that I am told:
*	sceneview takes in a publisher
		swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
		scenkit -> write models back to viewmodel. s
		viewmodel single source of truth
	or ask me to clarify
*	SceneView
		that communicates with a ViewModel
			to render a SceneKit scene and
		the ViewModel updates
			with changes from SceneKit,
				acting as the single source of truth.
 */

////////////////////////////// Testing
//	$publisher
//	$view

class EventMonitor {
	private var monitor: Any?
	private let mask: NSEvent.EventTypeMask
	private let handler: (NSEvent) -> Void

	init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void) {
		self.mask = mask
		self.handler = handler
	}

	deinit {
		stopMonitoring()
	}

	func startMonitoring(for window: NSWindow) {
		monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
			self?.handleEvent(event)
			return event
		}
		window.makeFirstResponder(window.contentView)
	}

	func stopMonitoring() {
		if let monitor = monitor {
			NSEvent.removeMonitor(monitor)
			self.monitor = nil
		}
	}

	private func handleEvent(_ event: NSEvent) {
		handler(event)
	}
}

struct ContentView: View {
	@Binding	var document	: FactalsDocument
	var body: some View {
		FwGutsView(fwGuts:$document.fwGuts)
		 .onAppear {
			guard let window = NSApplication.shared.windows.first else { return }
			let eventMonitor = EventMonitor(mask: [.keyDown, .leftMouseDown, .rightMouseDown]) { event in
	bug			// Handle the event here
				print("Event: \(event)")
			}
			eventMonitor.startMonitoring(for: window)
		 }
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
				 // NOTE: To add more views, change variable "Vews":[] or "Vew1" in Library
				ForEach($fwGuts.rootVews) {	rootVew in
					VStack {
						ZStack {
							let rootScene = rootVew.rootScene.wrappedValue
							EventReceiver { 	nsEvent in // Catch events (goes underneath)
								let _ = rootScene.processEvent(nsEvent:nsEvent, inVew:rootVew.wrappedValue)
							}
							// sceneview takes in a publisher		// PW:
							// swift publishes deltas - $viewmodel.property -> sceneview .sync -> camera of view scenekit
							// scenkit -> write models back to viewmodel. s
							// viewmodel single source of truth.
							// was: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
							// now: SceneView 	native SwiftUI
							SceneView(
								scene:rootScene, 	//rootScn.scnScene,
								pointOfView: nil,	// SCNNode
								options: [.rendersContinuously],
								preferredFramesPerSecond: 30,
								antialiasingMode: .none,
								delegate: nil//rootScn	//SCNSceneRendererDelegate?
							//	technique: nil		//SCNTechnique?
							)

//							SceneView(
//								scene:rootScene,
//								pointOfView:nil,	// SCNNode
//								options:[.rendersContinuously],
//								preferredFramesPerSecond:30,
//								antialiasingMode:.none,
//								delegate:rootScene,	//nil//SCNSceneRendererDelegate?
//								technique: nil		//SCNTechnique?
//							)
							 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
							 .border(.black, width:1)
							 .onChange(of:isLoaded) { x in				// compiles, seems OK
								print("isLoaded = ", x)
							 }
					//		 .onKeyPress(phases: .up)  { press in
					//			 print(press.characters)
					//			 return .handled
					//		 }
				//			 .onMouseDown(perform:handleMouseDown)				/// no member 'onMouseDown'
							 .onAppear {			//setupHitTesting
			//					guard let nsWindow	= NSApplication.shared.windows.first, //?.rootViewController
			//						  let nsView	= nsWindow.contentView,
			//						  let fwView	= nsView as? SCNView else { fatalError("couldn't find fwView")	}
			//					 // Perform hit testing on tap gesture
			//		bug			//let tapGestur		= UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
			//					//sceneView.addGestureRecognizer(tapGestur)
							 }
						//	.onAppear(perform: {
						//		NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
						//			print("\(isOverContentView ? "Mouse inside ContentView" : "Not inside Content View") x: \(self.mouseLocation.x) y: \(self.mouseLocation.y)")
						//			return $0
						//		}
						//	})
			//			//	 .gesture(tapGesture)// NSClickGestureRecognizer
			//				 .onTapGesture {
			//				 	let vew:Vew? 		= DOCfwGuts.modelPic()							//with:nsEvent, inVew:v!
			//					print("tapGesture -> \(vew?.pp(.classUid) ?? "nil")")
			//				 }
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
