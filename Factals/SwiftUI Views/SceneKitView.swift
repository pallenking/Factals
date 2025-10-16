//
//  SceneKitView.swift
//  Factals
//
//  Created by Allen King on 2/24/24.
//

import SwiftUI
import SceneKit
import AppKit


	//		that communicates with a ViewModel
	//			to render a SceneKit scene and
	//		the ViewModel updates
	//			with changes from SceneKit,
	//				acting as the single source of truth.
	////////////////////////////// Testing	$publisher/	$view
	// Generate code exemplefying the following thoughts that I am told:
	// sceneview takes in a publisher		// PW essential/big
	// swift publishes deltas - $viewmodel.property -> sceneview .sink -> camera of view scenekit
	// scenkit -> write models back to viewmodel. s
	// viewmodel single source of truth.
	// was, back2: SCNView		AppKit wrapped in an NSViewRepresentable (subclass SceneKitHostingView)
	// now       : SceneView 	native SwiftUI (not full-featured)

struct SceneKitView : NSViewRepresentable {
	var scnView 		 		= ScnView()		// ARG1: exposes visual world
//	var scnView 		 		= SCNView()		// ARG1: exposes visual world
	@Binding var prefFpsC : CGFloat				// ARG2: (DEBUG)

	typealias Visible			= SCNNode
	typealias Vect3 			= SCNVector3
	typealias Vect4 			= SCNVector4
	typealias Matrix4x4 		= SCNMatrix4
	typealias NSViewType 		= SCNView		// Type represented

	func makeNSView(context:Context) -> SCNView {
		guard let fm			= FACTALSMODEL 		else { fatalError("FACTALSMODEL is nil!!") }

		 // BUG AVOIDANCE HACK: find existing one:
		guard let vewBase		= fm.vewBases.first(where: {
				$0.gui == nil 					// not used yet
			&&	$0.factalsModel === fm 			// matches my
			&&	$0.partBase === fm.partBase		//  factory and part
		})
		 else { fatalError("no preMade VewBase matches")						}
		assert(vewBase === fm.vewBases.last,	 "paranoia")
	//	assert(vewBase.factalsModel === fm,		 "paranoia")
	//	assert(vewBase.partBase === fm.partBase, "paranoia")
												 // ELSE NORMAL:
										//		let vewBase				= VewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
										//		vewBase.factalsModel	= fm
										//		vewBase.partBase		= fm.partBase
										 //		if false == fm.vewBases.contains(where: { $0 === vewBase }) {	// $0.id == vewBase.id
										 //			fm.vewBases.append(vewBase)
										 //		}
		 // Make delegate ScnBase
		let scnBase 			= ScnBase(gui:scnView)							// scnBase.gui = rv // important BACKPOINTER
		scnView.delegate		= scnBase 		// (the SCNSceneRendererDelegate)
		scnView.getScene		= scnBase.gui!.getScene							// wrapped.scnScene //gui.scene //.scene
		vewBase.gui 			= scnView		// needed

		logApp(5, "Check 1: scnView=\( 		 scnView.pp(.nameTag)), "
				+ "scnView.scnBase=\(scnView.scnBase?.pp(.nameTag) ?? "<nil>")")
		scnView.getScene?.rootNode.addChildNode(vewBase.tree.scn)
		scnView.makeLights()
		scnView.makeCamera()
		scnView.makeAxis()

		scnView.isPlaying		= false			// book keepscnViewing
		scnView.showsStatistics	= true			// controls extra bar
		scnView.debugOptions	= 				// enable display of:
		  [	SCNDebugOptions.showPhysicsFields ]	//  regions affected by each SCNPhysicsField object
		scnView.allowsCameraControl	= true		// user may control camera	//args.options.contains(.allowsCameraControl)
		scnView.autoenablesDefaultLighting = false // we contol lighting	    //args.options.contains(.autoenablesDefaultLighting)
		scnView.rendersContinuously	= true		//args.options.contains(.rendersContinuously)
		scnView.preferredFramesPerSecond = Int(prefFpsC)
		return scnView
	}
	func updateNSView(_ scnView:SCNView, context:Context) {
	//	let scnView				= scnView as SCNView			//	scnBase.scnView
		scnView.preferredFramesPerSecond = Int(prefFpsC)		//args.preferredFramesPerSecond
	}
}

//------------------------------ Scraps to end -------------------------
// ///////////////// Texting Scaffolding, after Josh and Peter help:///////////
 // Simple test of things like VIEWREPresentable
//struct SceneKit2View: View {
//	@Bindable var factalsModel : FactalsModel
//	@State var prefFpsC : CGFloat	= 30.0
//
//	var body: some View {
////		let x = factalsModel.simulator.timeNow
//		VStack (alignment:.leading) {
//			let size = CGFloat(12)		// of Text
//			Text("TextField:NSViewRepresentable / TextField:View ").font(.system(size:size))
//			HStack {
//				//Text("ViewRepTest:").foregroundStyle(.red).font(.system(size:18))	/// A: SwiftUI Text
//				Text("timeNow=(factalsModel.simulator.timeNow)")
//				TextField("timeNow=", value:$factalsModel.simulator.timeNow,
//						  format:.number.precision(.significantDigits(5)))
//					.frame(width:100)
//				Button("+=1") {
//					factalsModel.simulator.timeNow += 1.0						}
//			}
//			 .font(.system(size:12))
//			Text("SelfiePoleBar(selfiePole):View").font(.system(size:size))
//			VStack {									//Binding<VewBase>
//				let vewBase0		= $factalsModel.vewBases[0]
//				SelfiePoleBar(selfiePole:vewBase0.selfiePole)
//					.font(.system(size:12))
//			}
//			Text("SceneKitView:NSViewRepresentable").font(.system(size:size))
//			VStack {									//Binding<VewBase>
//				let vewBase0		= factalsModel.vewBases[0]
//				let scnBase	= vewBase0.scnBase
//				ZStack {
//					SceneKitView(scnBase:scnBase, prefFpsC:$prefFpsC)		 // New Way (uses old NSViewRepresentable)
//					 .frame(maxWidth: .infinity)
//					 .border(.black, width:1)
//					Text("Overlayed Text")
//					EventReceiver {	nsEvent in // Catch events (goes underneath)
// 						//print("EventReceiver:point = \(nsEvent.locationInWindow)")
//						if !scnBase.processEvent(nsEvent:nsEvent, inVew:vewBase0.tree) {
//							guard let c = nsEvent.charactersIgnoringModifiers?.first else {fatalError()}
//							//print("Key '\(c)' not recognized and hence ignored")
//						}
//					}
//					MySceneView(scnBase:scnBase)
//				}
//			//	VewBaseBar(vewBase:$vewBase0)
//			}
//		}
//		.font(.largeTitle)
//	}
//}
// Flock: nscontrol delegate controltextdideneediting nstextfield delegate nscontrol method
// MARK: END OF SCAFFOLDING //////////////////////////////////////////////////

// /////////////////////////////// SceneView ////////////////////////////

//struct MySceneView : View {
//	var scnBase : ScnBase?			// ARG1: exposes visual world
//
//	var body : some View {
//		SceneView(					 // Old Way
//			scene:scnBase?.nsView!.scene,		//scnBase.
//			pointOfView:nil,	// SCNNode
//			options:[.rendersContinuously],
//			preferredFramesPerSecond:30,
//			antialiasingMode:.none,
//			delegate:scnBase,	//SCNSceneRendererDelegate?
//			technique: nil		//SCNTechnique?
//		)
//		 .frame(maxWidth: .infinity)// .frame(width:500, height:300)
//		 .border(.black, width:1)
//	}
//}

// ///////////////////////  SCRAPS   //////////////////////////////////
						//		@State		var isLoaded	= false
						//		 .onChange(of:isLoaded) { oldVal, newVal in				// compiles, seems OK
						//		 	print(".onChange(of:isLoaded) { \(oldVal), \(newVal)")
						//		 }
							//	 .onAppear { 			//setupHitTesting
							//		let scnBase			= vewBase.scnBase
							//		let bind_fwView		= scnBase.scnView		//Binding<FwView?>
							//		var y				= "nil"
							//		if let scnView		= bind_fwView.wrappedValue,
							//		   let s			= scnView.scnBase {
							//			y				= s.pp()
							//		}
							//		print("\(scnBase).scnView.scnBase = \(y)")
							//	 .onAppear { 			//setupHitTesting
							//		//coordinator.onAppear()
							//		//$factalsModel.coordinator.onAppear {				}
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

