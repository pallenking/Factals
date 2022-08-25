//
//  ContentView.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//
import SwiftUI
import SceneKit

extension SCNCameraController : ObservableObject {	}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	//let win0 : NSWindow?		= DOC.window0
	var body: some View {
		VStack {
			let rootPart:RootPart = document.docState.rootPart
			let scene			= document.docState.fwScene
			//let aux			= DOCLOG.params4aux + ["ppDagOrder":true]
			ZStack {
				NSEventReceiver { nsEvent in DOCfwScene.receivedEvent(nsEvent:nsEvent)		}
				SceneView(
					scene			: scene,
					pointOfView		: scene.cameraNode,
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
					{	lldbPrint(ob:scene.rootVew, mode:.tree) 					}
					Button(label:{	Text( "ptn").padding(.top, 300)					})
					{	lldbPrint(ob:scene.rootNode, mode:.tree)			 		}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
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
	}
}
