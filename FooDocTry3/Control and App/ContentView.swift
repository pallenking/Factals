//
//  ContentView.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//
import SwiftUI
import SceneKit

extension SCNCameraController : ObservableObject {	}

class JetModel: ObservableObject {
	@Published var scene : SCNScene = SCNScene(named:"art.scnassets/ship.scn")!
}
class DragonModel: ObservableObject {
	@Published var scene : SCNScene = dragonCurve(segments:1024)
}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()
	@StateObject var dragonModel	= DragonModel()


	 // From PW: https://stackoverflow.com/questions/56743724/swiftui-how-to-add-a-scenekit-scene
	var scene: SCNScene? {
		SCNScene(named: "Models.scnassets/Avatar.scn")
	}

	var cameraNode: SCNNode? {
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
		return cameraNode
	}
//	var body: some View {
//		SceneView(
//			scene: scene,
//			pointOfView: cameraNode,
//			options: [
//				.allowsCameraControl,
//				.autoenablesDefaultLighting,
//				.temporalAntialiasingEnabled
//			]
//		)
//	}

	//let win0 : NSWindow?		= DOC.window0
	var body: some View {
		HStack {
			VStack {
				let rootPart:RootPart = document.docState.rootPart
				let fwScene			= document.docState.fwScene
				//let aux			= DOClog.params4aux + ["ppDagOrder":true]
				ZStack {
					NSEventReceiver { nsEvent in DOCfwScene.receivedEvent(nsEvent:nsEvent)		}
					SceneView(
						scene			: fwScene,
						pointOfView		: fwScene.cameraNode,
						options			: [//.autoenablesDefaultLighting,
			//**/						   //.allowsCameraControl,
										   //.jitteringEnabled,
										   //.rendersContinuously,
										   //.temporalAntialiasingEnabled
						],
						preferredFramesPerSecond:30,
						antialiasingMode:.none,				//SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
						delegate:document.docState.fwScene	// FwScene // SCNSceneRendererDelegate
					)
					.allowsHitTesting(	true)
					 .onAppear {
						document.didLoadNib(to:self)								}
					.border(Color.black, width: 3)
	//				 .background(NSColor("verylightgray")!)		// HELP
		//A			 .gesture(gestures())	// Removed 20220825 to Gestures.swift
				}
				HStack {
					HStack {
						Text("  Control:")
						Button(label:{	Text( "state").padding(.top, 300)				})
						{	printFwcState()												}
						Button(label:{	Text( "config").padding(.top, 300)				})
						{	printFwcConfig()											}
					}
					Spacer()
					HStack {
						Text("Model:")
						Button(label:{	Text( "ptm").padding(.top, 300)					})
						{	lldbPrint(ob:rootPart, mode:.tree)							}
						Button(label:{	Text("ptLm").padding(.top, 300)					})
						{	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true]) 		}
						Text(" ")
						Button(label:{	Text( "ptv").padding(.top, 300)					})
						{	lldbPrint(ob:fwScene.rootVew, mode:.tree) 					}
						Button(label:{	Text( "ptn").padding(.top, 300)					})
						{	lldbPrint(ob:fwScene.rootNode, mode:.tree)			 		}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
					}
					Spacer()
					HStack {
						Text("Debug:")
						Button(label: {	Text("LLDB").padding(.top, 300) 				})
						{	breakToDebugger()											}
						Text(" ")
					}
				}
				Spacer()
			}
			VStack {
				SceneView(
					scene: 		 jetModel.scene,
					pointOfView: /*jetModel.scene.*/cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
					.frame(width:200, height:200)
				SceneView(
					scene: 		 dragonModel.scene,
					pointOfView: /*dragonModel.scene.*/cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
					.frame(width:200, height:300)
			}
		}
	}
}
