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
//	var scnView 				= ScnView(scnScene:nil, eventHandler:{_ in})
	var scnView  		 		= ScnView()	// ARG1: exposes visual world // was SCNView()
	@Binding var prefFpsC : CGFloat				// ARG2: (DEBUG)

	typealias Visible			= SCNNode
	typealias Vect3 			= SCNVector3
	typealias Vect4 			= SCNVector4
	typealias Matrix4x4 		= SCNMatrix4
	typealias NSViewType 		= ScnView		// Type represented

	 // NSViewRepresentable calls this, aka init
	func makeNSView(context:Context) -> ScnView {
		guard let fm			= FACTALSMODEL 		else { fatalError("FACTALSMODEL is nil!!") }

		 // BUG AVOIDANCE HACK: find existing one:
		guard let vewBase		= fm.vewBases.first(where: {
				$0.gui == nil 					// not used yet
			&&	$0.factalsModel === fm 			// matches my factory
			&&	$0.partBase === fm.partBase		//  and part
		})
		 else { fatalError("no preMade VewBase matches")						}
		assert(vewBase === fm.vewBases.last,	 "paranoia")
						//	assert(vewBase.factalsModel === fm,		 "paranoia")
						//	assert(vewBase.partBase === fm.partBase, "paranoia")
												 // ELSE NORMAL:
										//		let vewBase				= VewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
										//		vewBase.factalsModel	= fm
										//		vewBase.partBase		= fm.partBase
										 //		if false == fm.vewBases.contains(where: { $0 === vewBase }) 	// $0.id == vewBase.id
										 //		{	fm.vewBases.append(vewBase)							}
	//	scnView.delegate		=
	//	scnView.getScene		= 							// wrapped.scnScene //gui.scene //.scene
		vewBase.gui 			= scnView		//
										//		 // Make delegate ScnBase
										//		let scnBase 			= ScnBase(gui:scnView)							// scnBase.gui = rv // important BACKPOINTER
										//		scnView.delegate		= scnBase 		// (the SCNSceneRendererDelegate)
										//		scnView.getScene		= scnBase.gui!.getScene							// wrapped.scnScene //gui.scene //.scene
										//		vewBase.gui 			= scnView		// needed
		scnView.vewBase			= vewBase
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
	func updateNSView(_ nsView: ScnView, context:Context) {
	//	let scnView				= scnView as SCNView			//	scnBase.scnView
		scnView.preferredFramesPerSecond = Int(prefFpsC)		//args.preferredFramesPerSecond
	}
}

//------------------------------ Scraps to end -------------------------
// ///////////////// Texting Scaffolding, after Josh and Peter help:///////////
// Flock: nscontrol delegate controltextdideneediting nstextfield delegate nscontrol method
// MARK: END OF SCAFFOLDING //////////////////////////////////////////////////

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
		//animatePhysics 		= c.bool("animatePhysics") ?? false
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

