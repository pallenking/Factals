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
/*

    var body: some View {
        ZStack(alignment: .bottom) {
            SceneView(scene: scene,
            		  pointOfView: camera,
            		  options: [],
            		  delegate: cameraController)
                .gesture(dragGesture)
        }
    }
 */
extension SCNCameraController : ObservableObject {	}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()
	@StateObject var dragonModel	= DragonModel()
//	@StateObject var cameraController: SCNCameraController

	func onDragEnded() {
	 bug // set state, process the last drag position we saw, etc
	}

    var dragGesture: some Gesture {
//        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
//            .onChanged(cameraController.onDragChange(value:))
//            .onEnded(cameraController.onDragEnded(value:))

		DragGesture(minimumDistance: 0)
//			  .onChanged({ drag in
//			   // Do stuff with the drag - maybe record what the value is in case things get lost later on
//			  })
//			  .onEnded({ drag in
//				self.onDragEnded()
//			  })
//
//			 let hackyPinch = MagnificationGesture(minimumScaleDelta: 0.0)
//			  .onChanged({ delta in
//				self.onDragEnded()
//			  })
//			  .onEnded({ delta in
//				self.onDragEnded()
//			  })
//
//			let hackyRotation = RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))
//			  .onChanged({ delta in
//				self.onDragEnded()
//			  })
//			  .onEnded({ delta in
//				self.onDragEnded()
//			  })
//
//			let hackyPress = LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
//			  .onChanged({ _ in
//				self.onDragEnded()
//			  })
//			  .onEnded({ delta in
//				self.onDragEnded()
//			  })
//
//			let combinedGesture = drag
//			  .simultaneously(with: hackyPinch)
//			  .simultaneously(with: hackyRotation)
//			  .exclusively(before: hackyPress)
//
//		/// The pinch and rotation may not be needed - in my case I don't but
//		///   obviously this might be very dependent on what you want to achieve

    }

	var body: some View {
		HStack {
			VStack {
				let rootPart:Part	=  document.state.model
				let rootVew :Vew	=  document.state.scene.rootVew
				let rootNode:SCNNode = document.state.scene.rootNode
				let aux				= DOCLOG.params4aux + ["ppDagOrder":true]

				SceneView(
					scene: 		 document.state.scene,
					pointOfView: document.state.scene.cameraNode,
					options: [.allowsCameraControl,
							  .autoenablesDefaultLighting,
//							  .jitteringEnabled,
							  .rendersContinuously,
							  .temporalAntialiasingEnabled
					],
					preferredFramesPerSecond:10,
			 		//antialiasingMode:SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
					delegate:document.state.scene			// FwScene
//					delegate:SCNSceneRendererDelegate?,
//					technique:SCNTechnique?)
				)
				 .gesture(dragGesture)
				 .border(Color.black, width: 3)
				// .frame(width:600, height:400)
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
}
