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
//	@Published var fwScene : FwScene  = FwScene(fwConfig:[:])
//	@Published var fwScene : FwScene  = FwScene(named:"art.scnassets/ship.scn")!
	@Published var scene   : SCNScene = SCNScene(named:"art.scnassets/ship.scn")!
}
class DragonModel: ObservableObject {
//	@Published var fwScene : FwScene  = dragonCurve(segments:1024)
	@Published var scene   : SCNScene = dragonCurve(segments:1024)
}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()		// bric-à-brac Models
	@StateObject var dragonModel	= DragonModel()

	 // From PW: https://stackoverflow.com/questions/56743724/swiftui-how-to-add-a-scenekit-scene

	var body: some View {
		HStack {
			VStack {
				let rootPart:RootPart = document.docState.rootPart
				let fwScene			= document.docState.fwScene
				ZStack {
					NSEventReceiver { nsEvent in
						DOCfwScene.receivedEvent(nsEvent:nsEvent)				}
					FwSceneAsSwiftUIView(args:FwViewsArgs(
						fwScene		: fwScene,
						pointOfView	: fwScene.cameraNode,
						options		: [.autoenablesDefaultLighting,
			//**/					   .allowsCameraControl,
									   .jitteringEnabled,
									   .rendersContinuously,
									   .temporalAntialiasingEnabled				],
						preferredFramesPerSecond:30,
						antialiasingMode:.none,
						delegate:nil
//						technique:nil
					))
					 .allowsHitTesting(	true)
					 .onAppear {
						document.didLoadNib(to:self)							}
					 .border(Color.black, width: 10)
				//	 .background()//(NSColor("verylightgray")!)		// HELP
				//A	 .gesture(gestures())	// Removed 20220825 to Gestures.swift
				}
//				SceneView(scene:fwScene, pointOfView:fwScene.cameraNode, options:[], delegate:nil) .border(Color.yellow, width: 10)
				HStack {
					HStack {
						Text("  Control:")
						Button(label:{	Text( "state").padding(.top, 300)				})
						{	printFwcState()												}
						Button(label:{	Text("config").padding(.top, 300)				})
						{	printFwcConfig()											}
					}
					Spacer()
					HStack {
						Text("Model:")
						Button(label:{	Text(   "ptm").padding(.top, 300)				})
						{	lldbPrint(ob:rootPart, mode:.tree)							}
						Button(label:{	Text(  "ptLm").padding(.top, 300)				})
						{	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true]) 		}
						Text(" ")
						Button(label:{	Text(   "ptv").padding(.top, 300)				})
						{	lldbPrint(ob:fwScene.rootVew, mode:.tree) 					}
						Button(label:{	Text(   "ptn").padding(.top, 300)				})
						{	lldbPrint(ob:fwScene.rootNode, mode:.tree)			 		}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
						Button(label:{	Text(   "reV").padding(.top, 300)				})
						{	document.redo += 1									 		}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
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
//				FwSceneAsSwiftUIView(args:FwViewsArgs( 	//SceneView(
//					fwScene		: jetModel.scene as! FwScene,
//					pointOfView	: nil,//jetModel.scene.cameraNode,
//					options		: [.allowsCameraControl, .autoenablesDefaultLighting],
//					preferredFramesPerSecond : 30,
//					antialiasingMode : .none, delegate:nil
//				))
//				 .frame(width:200, height:200)
				SceneView(
					scene	   : dragonModel.scene,
					pointOfView: nil,//dragonModel.scene.cameraNode,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
				 .frame(width:200, height:300)
			}
		}
	}
}
