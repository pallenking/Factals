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
	@Published var scene   : SCNScene = dragonCurve(segments:1024)
}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 	= JetModel()		// bric-à-brac Models
	@StateObject var dragonModel = DragonModel()
								//
	var body: some View {
		HStack {
			if let fwGuts		= document.fwGuts {
				VStack {
					let rootPart:RootPart = document.fwGuts.rootPart
					ZStack {
						NSEventReceiver { nsEvent in
							let rootVew = fwGuts.rootVews[zeroIndex]	// zeroIndex is DANGEROUS
							rootVew.eventCentral.processEvent(nsEvent:nsEvent, inVew:nil)
						}
						let sceneKitHostingView	= SceneKitHostingView(SCNViewsArgs(
							fwGuts		: fwGuts,
							scnScene	: nil,	// no specific background scene
							pointOfView	: nil,	// rootVew.fwScn.cameraScn, //pov,
							options		: [//	.autoenablesDefaultLighting,
										  //.allowsCameraControl,	// so we can control it
			//								.jitteringEnabled,
											.rendersContinuously,
			//								.temporalAntialiasingEnabled,
										  ],
							preferredFramesPerSecond:30,
							antialiasingMode:.none,
							delegate:nil				// O O O P S   fwGuts.eventCentral
	//						technique:nil
						))
						 .allowsHitTesting(	true)
						 .onAppear {
							document.didLoadNib(to:self)						}
					//	 .border(Color.black, width: 10)
					//	 .background()//(NSColor("verylightgray")!)		// HELP
					//A	 .gesture(gestures())	// Removed 20220825 to Gestures.swift
						sceneKitHostingView
					}
/*
 003  DOCctlr      . . . . . . . . . . . . . . 1 FwDocument:
 59a  | NSDocument   . . . . . . . . . . . . . Has 1 wc:   #ADD MORE HERE#
 96a  | | NSWindowCtlr . . . . . . . . . . . . nilNameNib,doc:59a win:66a nibOwner:96a
 66a  | | | NSWindow     . . . . . . . . . . . title:'Untitled' contentVC:fae contentView:745 delegate:---
 745  | | | | _TtGC7SwiftUI13NSHostingViewGVS_15ModifiedConten... . . .NSHostingView . . . . . . 3 children superview:bf8 window:66a noRedisplay
 529  | | | | | _TtGC7SwiftUI16PlatformViewHostGVS_P10$1cd823a88... . . .PlatformViewHost. . . . 1 children superview:745 window:66a noRedisplay
 18d  | | | | | | NSEventReceiverView                               . . . .NSEventReceiverView . 0 children superview:529 window:66a noRedisplay
 cd0  | | | | | _TtGC7SwiftUI16PlatformViewHostGVS_P10$1cd823a88... . . .PlatformViewHost. . . . 1 children superview:745 window:66a noRedisplay
 579  | | | | | | SCNView                                           . . . .SCNView       . . . . 0 children superview:cd0 window:66a noRedisplay
 519  | | | | | _TtC7SwiftUIP33_9FEBA96B0BC70E1682E82D239F242E73... . . . . . . . . 2 children superview:745 window:66a noRedisplay
 e02  | | | | | | NSButtonBezelView                                 . . . . . . . . 0 children superview:519 window:66a noRedisplay
 0c3  | | | | | | _TtCC7SwiftUIP33_9FEBA96B0BC70E1682E82D239F242E7... . . . . . . . 1 children superview:519 window:66a noRedisplay
 e92  | | | | | | | _TtCOCV7SwiftUI11DisplayList11ViewUpdater8Platfo... . . . . . . 0 children superview:0c3 window:66a noRedisplay
 */
					HStack {
						HStack {
							Text("  Control:")
							Button(label:{	Text( "state").padding(.top, 300)	})
							{	printFwcState()									}
							Button(label:{	Text("config").padding(.top, 300)	})
							{	printFwcConfig()								}
						}
						Spacer()
						let x = fwGuts.rootVew0?.fwScn.scnScene.rootNode
						HStack {
							Text("Model:")
							Button(label:{	Text(   "ptm").padding(.top, 300)	})
							{	lldbPrint(ob:rootPart, mode:.tree)				}
							Button(label:{	Text(  "ptLm").padding(.top, 300)	})
							{	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true])}
							Text(" ")
							Button(label:{	Text(   "ptv").padding(.top, 300)	})
							{	lldbPrint(ob:fwGuts.rootVews, mode:.tree) 		}
							Button(label:{	Text(   "ptn").padding(.top, 300)	})
							{	lldbPrint(ob:x!, mode:.tree)}
							Button(label:{	Text(   "reV").padding(.top, 300)	})
							{	document.redo += 1								}
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
//			VStack {
//				SceneKitHostingView(SCNViewsArgs( 	//SceneView(
//					fwGuts		: nil,
//					scnScene	: jetModel.scene,
//					pointOfView	: nil,//jetModel.scene.cameraScn,
//					options		: [.allowsCameraControl, .autoenablesDefaultLighting],
//					preferredFramesPerSecond : 30,
//					antialiasingMode : .none,
//					delegate	: nil
//				))
//				 .frame(width:200, height:200)
//				SceneView(
//					scene	   : dragonModel.scene,
//					pointOfView: nil,//dragonModel.scene.cameraScn,
//					options: [.allowsCameraControl, .autoenablesDefaultLighting]
//				)
//				 .frame(width:200, height:300)
//			}
		}
	}
}


//		Text("Hello World!")
//		 .toolbar {
//			ToolbarItem(placement: .primaryAction) {
//				Menu {
//					Button(label:{	Label("Create a file", systemImage: "doc")	})
//					{	print("button pressed")									}
//					Button(label:{	Label("Create a folder", systemImage: "folder")	})
//					{															}
//				}
//				label: {
//					Label("Add", systemImage: "plus")
//				}
//			}
//		}.frame(width:200, height: 20, alignment:.center)
