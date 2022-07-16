//
//  ContentView.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

class JetModel: ObservableObject {
	@Published var scene : SCNScene = SCNScene(named:"art.scnassets/ship.scn")!
}
class DragonModel: ObservableObject {
	@Published var scene : SCNScene = dragonCurve(segments:1024)
}
extension SCNCameraController : ObservableObject {	}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()
	@StateObject var dragonModel	= DragonModel()
//	@StateObject var cameraController: SCNCameraController

	var body: some View {
		//@GestureState var dragGestureActive: Bool = false
		//@State var dragOffset: CGSize = .zero
		HStack {
			VStack {
				let rootPart:Part	=  document.state.rootPart
				let rootVew :Vew	=  document.state.fwScene.rootVew
				let rootNode:SCNNode = document.state.fwScene.rootNode
				let aux				= DOCLOG.params4aux + ["ppDagOrder":true]

				SceneView(
					scene: 		 document.state.fwScene,
					pointOfView: document.state.fwScene.cameraNode,
					options: [//.allowsCameraControl,
							  .autoenablesDefaultLighting,
							  .jitteringEnabled,
							  .rendersContinuously,
							  .temporalAntialiasingEnabled
					],
					preferredFramesPerSecond:30,
			 		//antialiasingMode:SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
					delegate:document.state.fwScene			// FwScene			// SCNSceneRendererDelegate
					//technique:SCNTechnique?
				)
				 .gesture(gestures() )
				 .border(Color.black, width: 3)									// .frame(width:600, height:400)

				HStack {
					Spacer()
					Button(action: {	lldbPrint(ob:rootPart, mode:.tree)		}){
						Text("ptm").padding(.top, 300)							}
					Button(action: {	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true]) }){
						Text("ptLm").padding(.top, 300)							}
					Button(action: {	lldbPrint(ob:rootVew, mode:.tree) 		}){
						Text("ptv").padding(.top, 300)							}
					Button(action: {Swift.print(rootNode.pp(.tree, aux), terminator:"\n") }){
						Text("ptn").padding(.top, 300)							}
					Spacer()
					Button(action: {	breakToDebugger()						}){
						Text("LLDB").padding(.top, 300)							}
				}
				Spacer()
			}
			VStack {
				SceneView(
					scene: 		 jetModel.scene,
					pointOfView: jetModel.scene.cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
					.frame(width:200, height:200)
				SceneView(
					scene: 		 dragonModel.scene,
					pointOfView: dragonModel.scene.cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
					.frame(width:200, height:300)
			}
		}
	}
	func gestures() -> some Gesture {
		let drag 				= DragGesture(minimumDistance: 0)
		  .onChanged(	{ drag in 	self.onDragEnded("Drag Changed \(drag)")	})   // Do stuff with the drag - maybe record what the value is in case things get lost later on
		  .onEnded(		{ drag in 	self.onDragEnded("Drag Ended \(drag)")		})
		let hackyPinch 			= MagnificationGesture(minimumScaleDelta: 0.0)			// OMIT??
		  .onChanged(	{ delta in	self.onDragEnded("Pinch Changed \(delta)")	})
		  .onEnded(		{ delta in 	self.onDragEnded("Pinch Ended \(delta)")	})
		let tap1				= TapGesture(count:1)
		  .onEnded(		{ delta in 	self.onDragEnded("Tap1 Ended \(delta)")	})
		let tap2				= TapGesture(count:2)
		  .onEnded(		{ delta in 	self.onDragEnded("Tap2 Ended \(delta)")	})

		let hackyRotation 		= RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))// OMIT??
		  .onChanged(	{ delta in	self.onDragEnded("Rotation Changed \(delta)")})
		  .onEnded(		{ delta in	self.onDragEnded("Rotation Ended \(delta)")	})
		let hackyPress 			= LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
		  .onChanged(	{ delta in	self.onDragEnded("Press Changed \(delta)")	})
		  .onEnded(		{ delta in	self.onDragEnded("Press Ended \(delta)")	})
		let combinedGesture = drag
		  .simultaneously(with: hackyPinch)
		  .simultaneously(with: hackyRotation)
		  .simultaneously(with: tap1)
		  .simultaneously(with: tap2)
//		  .exclusively(before: hackyPress)
		return combinedGesture
	}
	func onDragEnded(_ msg:String="") {	print("onDragEnded: \(msg)") }	// set state, process the last drag position we saw, etc
}
