//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit

struct SceneKitView: NSViewRepresentable {
	var scnBase : ScnBase		// ARG1: exposes visual world
	typealias NSViewType 		= FwView	//:SCNView:NSView	// Type represented

	func makeNSView(context: Context) -> FwView {
		let fwView				= FwView()//frame:CGRect()
		fwView.delegate			= scnBase 		//scnBase is SCNSceneRendererDelegate
		fwView.scnBase			= scnBase
		fwView.scene			= scnBase.scnScene
//		fwView.autoenablesDefaultLighting = true
//		fwView.allowsCameraControl = true

		scnBase.fwView			= fwView		// for pic
		return fwView
	}

	func updateNSView(_ nsView: FwView, context:Context) {}
}

/////////////////////////  SCRAPS   //////////////////////////////////

//	func makeCoordinator() -> Coordinator {
//		Coordinator(self)
//	}
//	class Coordinator: NSObject {
//		var sceneKitView:SceneKitView
//		init(_ sceneKitView: SceneKitView) {
//			self.sceneKitView = sceneKitView
//		}
//		func mouseDownX(with event: NSEvent) {
//bug			 //let c			= Context()
//			let fwView 			= sceneKitView.scnBase.fwView //fwView
//			let point			= fwView!.convert(event.locationInWindow, from: nil)
//			let hitResults 		= fwView!.hitTest(point, options: [:])
//			if let hitResult 	= hitResults.first {
//				// This is the first object hit by the click
//				let node 		= hitResult.node
//				print("Clicked on node: \(node.name ?? "Unnamed")")
//				// Perform any actions you want on the node here
//			}
//		}
//	}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

//		.onAppear {
//			let windows 	= NSApplication.shared.windows
//			assert(windows.count == 1, "Cannot find widow unless exactly 1")			//NSApp.keyWindow
//			let rp			= document.factalsModel.partBase
//			windows.first!.title = rp.title
//			EventMonitor(mask: [.keyDown, .leftMouseDown, .rightMouseDown]) { event in
//	bug;		print("Event: \(event)")			// Handle the event here
//			}.startMonitoring(for: windows.first!)
//		}
		//						 .onAppear { 			//setupHitTesting
		//							//coordinator.onAppear()
		//						 	//$factalsModel.coordinator.onAppear {				}
		//						 	let scnBase			= vewBase.scnBase
		//						 	let bind_fwView		= scnBase.fwView		//Binding<FwView?>
		//							let y				= bind_fwView.wrappedValue?.scnBase?.pp() ?? "nil"
		//						 	print("\(scnBase).fwView.scnBase = \(y)")
		//						 }
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
//			.onAppear() {
//				let windows 	= NSApplication.shared.windows
//				assert(windows.count == 1, "Cannot find widow unless exactly 1")			//NSApp.keyWindow
//				windows.first!.title = factalsModel.partBase?.title ?? "<UNTITLED>"
//			}
//	 .map {	NSApp.keyWindow?.contentView?.convert($0, to: nil)	}
//	 .map { point in SceneView.pointOfView?.hitTest(rayFromScreen: point)?.node }
//	 ?? []
//	func handleMouseDown(event: NSEvent) {
//		mouseDown = true
//		handleMouseEvent(event)
//	}
//	func handleMouseEvent(_ event: NSEvent) {
//		if let view = NSApplication.shared.keyWindow?.contentView {
//			let location = view.convert(event.locationInWindow, from: nil)
//bug;		if let hitNsView = view.hitTest(location) {//,
//				bug
//			//let sceneView = hitNsView.node.scene?.view {//as? SCNView {
//			//	sceneView.mouseDown(with: event)
//			}
//		}
//	}

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

//class EventMonitor {
//	private var monitor: Any?
//	private let mask: NSEvent.EventTypeMask
//	private let handler: (NSEvent) -> Void
//	init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent) -> Void) {
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

