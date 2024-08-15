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
//import Cocoa
//class TUINSRemoteViewController: NSViewController {
//	func viewServiceDidTerminateWithError(_ error: Error) {
//		// Handle the error
//		print("View service terminated with error: \(error)")
//		// Optionally, you can attempt to restart the service or inform the user
//	}
//}
//extension TUINSRemoteViewController {
//
//    override func viewServiceDidTerminateWithError(_ error: Error) {
//        // Handle the error appropriately
//        print("View service did terminate with error: \(error)")
//
//        // Custom error handling code
//        // For example, you could show an alert to the user or perform cleanup operations
//        let alert = NSAlert()
//        alert.messageText = "Error"
//        alert.informativeText = error.localizedDescription
//        alert.alertStyle = .warning
//        alert.addButton(withTitle: "OK")
//        
//        alert.runModal()
//
//        // Additional custom handling as needed
//    }
//}
struct W: View {
	@ObservedObject var factalsModel : FactalsModel
	@State var prefFps : Float  = 30.0	// BETTER

	var body: some View {
		VStack (alignment:.leading) {
			HStack {
				Text("W:").foregroundStyle(.blue)	/// A: SwiftUI Text
				Text("timeNow=")
				FwTextField(float:$factalsModel.simulator.timeNow).frame(width: 160)
				Button("Reset") {	factalsModel.simulator.timeNow = 0				}
			}
			VStack {									//Binding<VewBase>
				let vewBase0		= $factalsModel.vewBases[0]					//.scnBase.wrappedValue
				SelfiePoleBar(selfiePole:vewBase0.selfiePole)
			}

			VStack {									//Binding<VewBase>
				let vewBase0		= factalsModel.vewBases[0]					//.scnBase.wrappedValue
				let scnBase			= vewBase0.scnBase							//.scnBase.wrappedValue
				ZStack {
					EventReceiver { 	nsEvent in // Catch events (goes underneath)
						print("EventReceiver:point = \(nsEvent.locationInWindow)")
						let _ = scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase0.tree)
					}
					SceneKitView(scnBase:scnBase, prefFps:$prefFps)		 // New Way (uses old NSViewRepresentable)
					 .frame(maxWidth: .infinity)
					 .border(.black, width:1)
				}
				//VewBaseBar(vewBase:vewBase)
			}

	//		SceneKitView(scnBase:nil, prefFpsF:$text)		/// B: The target UItext)
//			FwTextField(text:$text)							/// B: The target UI
		
		}
		.font(.largeTitle)
	}
}
final class Delegate: NSObject, NSTextFieldDelegate {
	@Binding var float: Float
	init(_ binding: Binding<Float>) {
		_float = binding
	}
	func textFieldDidEndEditing(_ textField: NSTextField) {
		float = textField.floatValue
	}
}
struct FwTextField: NSViewRepresentable {
	typealias NSViewType 		= NSTextField
	@Binding var float: Float

				/// Modifying state during view update, this will cause undefined behavior.
	func makeNSView(context: Context) -> NSTextField {
		let nsView 				= NSTextField()
		//add target action						//	view.addAction(UIAction { [weak view] action in }, for: .editingChanged)
		nsView.floatValue		= float
		nsView.delegate 		= context.coordinator	/// changes to coordinator

		nsView.textColor 		= NSColor.red
		nsView.backgroundColor 	= NSColor(red:1.0, green:0.9, blue:0.9, alpha:1.0)
		return nsView
	}

	func updateNSView(_ nsView: NSTextField, context: Context) {
		nsView.floatValue = float
	}
	func makeCoordinator() -> Delegate {
		.init($float)
	}
}
// MARK: END OF SCAFFOLDING //////////////////////////////////////////////////

 /// SwiftUI Wrapper of SCNView
struct SceneKitView: NSViewRepresentable {
	typealias NSViewType 		= SCNView		// Type represented
	var scnBase : ScnBase?						// ARG1: exposes visual world
	@Binding var prefFps : Float				// ARG2:	// BETTER

	func makeNSView(context: Context) -> SCNView {		// PW: some View?

		let sv					= SCNView(frame: NSRect.zero, options: [String : Any]())
		sv.isPlaying			= true			// animations, does nothing
		sv.showsStatistics		= true			// controls extra bar
		sv.debugOptions	= [						// enable display of:
			SCNDebugOptions.showPhysicsFields,	//  regions affected by each SCNPhysicsField object
		]
		sv.allowsCameraControl	= true//false// // user may control camera	//args.options.contains(.allowsCameraControl)
		sv.autoenablesDefaultLighting = false	// we contol lighting	    //args.options.contains(.autoenablesDefaultLighting)
		sv.rendersContinuously	= true			//args.options.contains(.rendersContinuously)
		sv.preferredFramesPerSecond = Int(prefFps)
 
		if let scnBase	{
			sv.delegate			= scnBase 		//scnBase is SCNSceneRendererDelegate
			sv.scene			= scnBase.scnScene

			scnBase.scnView		= sv		// for pic
		}
		else {	fatalError("scnBase is nil")													}
		return sv
	}

	func updateNSView(_ nsView: SCNView, context:Context) {
		let sv					= nsView as SCNView			//	scnBase.scnView
		sv.preferredFramesPerSecond = Int(prefFps)		//args.preferredFramesPerSecond
	}
}

/////////////////////////  SCRAPS   //////////////////////////////////

//	@State		var isLoaded	= false
//								 .onChange(of:isLoaded) { oldVal, newVal in				// compiles, seems OK
//								 	print(".onChange(of:isLoaded) { \(oldVal), \(newVal)")
//								 }
		//						 .onAppear { 			//setupHitTesting
		//						 	let scnBase			= vewBase.scnBase
		//						 	let bind_fwView		= scnBase.scnView		//Binding<FwView?>
		//						 	var y				= "nil"
		//						 	if let scnView		= bind_fwView.wrappedValue,
		//						 	   let s			= scnView.scnBase {
		//						 		y				= s.pp()
		//						 	}
		//						 	print("\(scnBase).scnView.scnBase = \(y)")
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
		//						 	let bind_scnView	= scnBase.scnView		//Binding<FwView?>
		//							let y				= bind_scnView.wrappedValue?.scnBase?.pp() ?? "nil"
		//						 	print("\(scnBase).scnView.scnBase = \(y)")
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

