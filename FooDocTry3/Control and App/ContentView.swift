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
			 		antialiasingMode:.none,										//SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
					delegate:document.docState.fwScene								// FwScene // SCNSceneRendererDelegate
				)
				 .onAppear {
				 	document.didLoadNib(to:self)								}
	//A			 .gesture(gestures())	// Removed 20220825 to Gestures.swift
				//.border(Color.black, width: 3)
//				 .background(NSColor("verylightgray")!)		// HELP
				//.frame(width:600, height:400)
			}
			HStack {
				Spacer()
				Button(label:{	Text( "ptm").padding(.top, 300)				})
				{	lldbPrint(ob:rootPart, mode:.tree)						}
				Button(label:{	Text("ptLm").padding(.top, 300)				})
				{	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true]) 	}
				Button(label:{		Text( "  ") }){}.buttonStyle(.borderless)
				Button(label:{	Text( "ptv").padding(.top, 300)				})
				{	lldbPrint(ob:scene.rootVew, mode:.tree) 				}
				Button(label:{	Text( "ptn").padding(.top, 300)				})
				{	lldbPrint(ob:scene.rootNode, mode:.tree)			 	}//				{	Swift.print(scene.rootNode.pp(.tree, aux), terminator:"\n") 	}
				Spacer()
				Button(label: {	Text("LLDB").padding(.top, 300) 			})
				{	breakToDebugger()										}
				Button(label:{		Text( "  ")}){} .buttonStyle(.borderless)
			}
			Spacer()
		}
	}
}
