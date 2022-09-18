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
//	@Published var fwGuts : FwGuts  = FwGuts(fwConfig:[:])
//	@Published var fwGuts : FwGuts  = FwGuts(named:"art.scnassets/ship.scn")!
	@Published var scene   : SCNScene = SCNScene(named:"art.scnassets/ship.scn")!
}
class DragonModel: ObservableObject {
//	@Published var fwGuts : FwGuts  = dragonCurve(segments:1024)
	@Published var scene   : SCNScene = dragonCurve(segments:1024)
}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()		// bric-à-brac Models
	@StateObject var dragonModel	= DragonModel()

	var body: some View {
		Text("Hello World!")
		 .toolbar {
			ToolbarItem(placement: .primaryAction) {
				Menu {
//					Button(action: {}) {
//						Label("Create a file", systemImage: "doc")
//					}
					Button(label:{	Label("Create a file", systemImage: "doc")	})
					{	print("button pressed")								}

					Button(action: {}) {
						Label("Create a folder", systemImage: "folder")
					}
				}
				label: {
					Label("Add", systemImage: "plus")
				}
			}
		}.frame(width:200, height: 20, alignment:.center)
		HStack {
			if let fwGuts		= document.fwGuts {
				VStack {
					let rootPart:RootPart = document.fwGuts.rootPart
					ZStack {
						NSEventReceiver { nsEvent in
							DOCfwGuts.receivedEvent(nsEvent:nsEvent)			}
						SceneKitHostingView(SCNViewsArgs(
							fwGuts		: fwGuts,
							scnScene	: nil,
							pointOfView	: fwGuts.cameraScn,
							options		: [.autoenablesDefaultLighting,
				//**/					   .allowsCameraControl,
										   .jitteringEnabled,
										   .rendersContinuously,
										   .temporalAntialiasingEnabled			],
//			//							   .jitteringEnabled,
//			//							   .temporalAntialiasingEnabled,
//										   .rendersContinuously],
							preferredFramesPerSecond:30,
							antialiasingMode:.none,
							delegate:fwGuts
	//						technique:nil
						))
						 .allowsHitTesting(	true)
						 .onAppear {
							document.didLoadNib(to:self)						}
					//	 .border(Color.black, width: 10)
					//	 .background()//(NSColor("verylightgray")!)		// HELP
					//A	 .gesture(gestures())	// Removed 20220825 to Gestures.swift
					}
					HStack {
						HStack {
							Text("  Control:")
							Button(label:{	Text( "state").padding(.top, 300)	})
							{	printFwcState()									}
							Button(label:{	Text("config").padding(.top, 300)	})
							{	printFwcConfig()								}
						}
						Spacer()
						HStack {
							Text("Model:")
							Button(label:{	Text(   "ptm").padding(.top, 300)	})
							{	lldbPrint(ob:rootPart, mode:.tree)				}
							Button(label:{	Text(  "ptLm").padding(.top, 300)	})
							{	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true])}
							Text(" ")
							Button(label:{	Text(   "ptv").padding(.top, 300)	})
							{	lldbPrint(ob:fwGuts.rootVew, mode:.tree) 		}
							Button(label:{	Text(   "ptn").padding(.top, 300)	})
							{	lldbPrint(ob:fwGuts.scnScene.rootNode, mode:.tree)}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
							Button(label:{	Text(   "reV").padding(.top, 300)	})
							{	document.redo += 1								}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
						}
						Spacer()
						HStack {
							Text("Debug:")
							Button(label: {	Text("LLDB").padding(.top, 300) 	})
							{	breakToDebugger()								}
							Text(" ")
						}
					}
					Spacer()
				}
	 			 // From Peter Wu: https://stackoverflow.com/questions/56743724/swiftui-how-to-add-a-scenekit-scene
				// SceneView(scene:fwGuts, pointOfView:fwGuts.cameraScn, options:[], delegate:nil) .border(Color.yellow, width: 10)
			} else {
				Button(label:{Text("Document has nil fwGuts").padding(.top, 300)})
				{	fatalError(" ERROR ")										}
			}
			VStack {
				SceneKitHostingView(SCNViewsArgs( 	//SceneView(
					fwGuts		: nil,
					scnScene	: jetModel.scene,
					pointOfView	: nil,//jetModel.scene.cameraScn,
					options		: [.allowsCameraControl, .autoenablesDefaultLighting],
					preferredFramesPerSecond : 30,
					antialiasingMode : .none,
					delegate	: nil
				))
				 .frame(width:200, height:200)
				SceneView(
					scene	   : dragonModel.scene,
					pointOfView: nil,//dragonModel.scene.cameraScn,
					options: [.allowsCameraControl, .autoenablesDefaultLighting]
				)
				 .frame(width:200, height:300)
			}
		}
	}
}
