//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//
import SwiftUI
import SceneKit

extension SCNCameraController : ObservableObject {	}

class JetModel: 		ObservableObject {
	@Published var scene:SCNScene=SCNScene(named:"art.scnassets/ship.scn")!
}
class DragonModel: 		ObservableObject {
	@Published var scene:SCNScene=dragonCurve(segments:1024)
	@Published var value:Int = 0
}
// /////////////////////////////////////////////////////////////////////////////
struct ContentView: View {
	@Binding     var document		: FactalsDocument	// the Document
	@StateObject var	   jetModel	=    JetModel()		// test Model 1
	@StateObject var	dragonModel	= DragonModel()		// test Model 2

	 // from https://stackoverflow.com/questions/56743724/swiftui-how-to-add-a-scenekit-scene
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
        return cameraNode
    }

 	var body: some View {
 		let select 					= 1//1/3
		if select == 1 {	 	bodySimple									}
		if select == 2 { 		bodyJet										}
		if select == 3 { 		bodyAll										}
 	}
  	var bodySimple: some View {		// Single HNW View
 		VStack {
 			 //  --- H a v e N W a n t  1  ---
 			let sceneKitArgs		= SceneKitArgs(
 				sceneIndex	: 0,
 				title		: "0: Big main view",
 				vewConfig	: vewConfigAllToDeapth4, //vewConfig1,//.null,
 				background	: nil,	 // no specific background scene
 				pointOfView	: cameraNode,//nil,//document.fwGuts.rootVews[0].lookAtVew?.scn,//
 				fwGuts		: document.fwGuts,
 				options		: [.rendersContinuously],	//.allowsCameraControl, 
 				preferredFramesPerSecond:30
 			)
			SceneKitView(sceneKitArgs:sceneKitArgs)
			 .frame(maxWidth: .infinity)
 			 .border(.black, width:2)
			 .onAppear() {
				document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
			 }
//didLoadNib
			ButtonBar(document:$document)//, dragonValue:dragonModel.$value)
			// 'ObservedObject<DragonModel>.Wrapper' -xx-> 'Binding<DragonModel>'
 		}
 	}

 	var bodyJet: some View {
 		HStack {
 			if let fwGuts			= document.fwGuts {
				HStack {	 // JET
					let sceneKitArgs	= SceneKitArgs( 	//SceneView(
						sceneIndex	: 0,
						title		: "Jet",
						vewConfig	: .null,
						background	: jetModel.scene,
						pointOfView	: cameraNode,//nil,//jetModel.scene.cameraScn,
						fwGuts		: fwGuts,
						options		: [.allowsCameraControl, .autoenablesDefaultLighting],
						preferredFramesPerSecond : 30
					)
					SceneKitHostingView(sceneKitArgs)
					 .frame(maxWidth: .infinity)
					 .border(.black, width:2)
					 .onAppear() {
						document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
					 }
				}
 			}
 			else {
 				Button(label:{Text("Document has nil fwGuts").padding(.top, 300) } 	)
 				{	fatalError(" ERROR ")											}
 			}
 		}
 	}

	var bodyAll: some View {	// bodyAll
		HStack {		// ***** 3 VStacks columns
			if let fwGuts			= document.fwGuts {
				VStack {
					HStack {
						 //  --- H a v e N W a n t  0  ---
						let sceneKitArgs	= SceneKitArgs(
							sceneIndex	: 0,
							title		: "0: Big main view",
							vewConfig	: vewConfigAllToDeapth4, //vewConfig1,//.null,
							background	: nil,	 // no specific background scene
 							pointOfView	: cameraNode,//document.fwGuts.rootVews[0].lookAtVew?.scn,//nil,//
							fwGuts		: fwGuts,
							options		: [.allowsCameraControl, .rendersContinuously],
							preferredFramesPerSecond:30
						)
						SceneKitView(sceneKitArgs:sceneKitArgs)
						 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
						 .border(.black, width:2)
						 .onAppear() {
							document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						 }
						Text(":0")
					}
					ButtonBar(document:$document)//, dragonValue:dragonModel.$value)
				}
				VStack {
					HStack {
						Text("1:")
						 //  --- H a v e N W a n t  1  ---
						let sceneKitArgs	= SceneKitArgs(
							sceneIndex	: 1,
							title		: "1: Second smaller view",
							vewConfig	: vewConfigAllToDeapth4, 				//vewConfig2,//.null,
							background	: nil,	// no specific background scene
							pointOfView	: cameraNode,//document.fwGuts.rootVews[0].lookAtVew?.scn,//rootVew.fwScn.cameraScn, //pov,//nil,//
							fwGuts		: fwGuts,
							options		: [.allowsCameraControl, .rendersContinuously],
							preferredFramesPerSecond:30
						)
						SceneKitView(sceneKitArgs:sceneKitArgs)
						 .frame(maxWidth: .infinity)
						 .border(.black, width:2)
						 .onAppear() {
							document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						 }
					}
					HStack {
						Text("x:")
						 // --- D R A G O N ---
						SceneView(
							scene		: dragonModel.scene,
							pointOfView	: cameraNode,//nil,//dragonModel.scene.rootNode,//.childNode(withName: "ship", recursively: true),
							options		: [.allowsCameraControl, .autoenablesDefaultLighting]
						)
						 .frame(width:150, height:150)
						 .border(.black, width:2)
						 .onAppear() {	print("x: Dragon APPEARED") }
						 .onAppear() {
							guard let scn = dragonModel.scene.rootNode.childNode(withName: "ship", recursively: true) else {return}
							let i = dragonModel.value
							scn.transform = [SCNMatrix4MakeRotation(0,     1,1,1),
											 SCNMatrix4MakeRotation(.pi/2, 1,0,0),
											 SCNMatrix4MakeRotation(.pi/2, 0,1,0),
											 SCNMatrix4MakeRotation(.pi/2, 0,0,1)] [i % 4]
							let rotationAxis = SCNVector3(i/4==1 ? 1 : 0, i/4==2 ? 1 : 0, i/4==3 ? 1 : 0)
							scn.runAction(SCNAction.repeatForever(SCNAction.rotate(by:.pi/4, around:rotationAxis, duration:10) ))
						 }
						 // --- J E T ---
						Text("2:")
						let sceneKitArgs	= SceneKitArgs( 	//SceneView(
							sceneIndex	: 2,
							title		: "2: Jet View",
							vewConfig	: .null,
							background	: jetModel.scene,
							pointOfView	: cameraNode,//document.fwGuts.rootVews[0].lookAtVew?.scn,//nil,//jetModel.scene.cameraScn,
							fwGuts		: fwGuts,
							options		: [.allowsCameraControl, .autoenablesDefaultLighting],
							preferredFramesPerSecond : 30
						)
						SceneKitHostingView(sceneKitArgs)
						 .frame(width:150, height:150)
						 .border(.black, width:2)
						 .onAppear() {
							document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						 }
						Spacer()
					}
				}
			}
			else {
				Button(label:{Text("Document has no fwGuts").padding(.top, 300) } 	)
				{	fatalError(" ERROR ")											}
			}
		}
		 .environmentObject(dragonModel)
	}
}
/*
 003  DOCctlr      . . . . . . . . . . . . . . 1 FwDocument:
 59a  | NSDocument   . . . . . . . . . . . . . Has 1 wc:   #ADD MORE HERE#
 96a  | | NSWindowCtlr . . . . . . . . . . . . nilNameNib,doc:59a win:66a nibOwner:96a
 66a  | | | NSWindow     . . . . . . . . . . . title:'Untitled' contentVC:fae contentView:745 delegate:---
 745  | | | | _TtGC7SwiftUI13NSHostingViewGVS_15ModifiedConten... . . .NSHostingView . . . . . . 3 children superview:bf8 window:66a noRedisplay
 529  | | | | | _TtGC7SwiftUI16PlatformViewHostGVS_P10$1cd823a88... . . .PlatformViewHost. . . . 1 children superview:745 window:66a noRedisplay
 18d  | | | | | | EventReceiverView                               . . . .EventReceiverView . 0 children superview:529 window:66a noRedisplay
 cd0  | | | | | _TtGC7SwiftUI16PlatformViewHostGVS_P10$1cd823a88... . . .PlatformViewHost. . . . 1 children superview:745 window:66a noRedisplay
 579  | | | | | | SCNView                                           . . . .SCNView       . . . . 0 children superview:cd0 window:66a noRedisplay
 519  | | | | | _TtC7SwiftUIP33_9FEBA96B0BC70E1682E82D239F242E73... . . . . . . . . 2 children superview:745 window:66a noRedisplay
 e02  | | | | | | NSButtonBezelView                                 . . . . . . . . 0 children superview:519 window:66a noRedisplay
 0c3  | | | | | | _TtCC7SwiftUIP33_9FEBA96B0BC70E1682E82D239F242E7... . . . . . . . 1 children superview:519 window:66a noRedisplay
 e92  | | | | | | | _TtCOCV7SwiftUI11DisplayList11ViewUpdater8Platfo... . . . . . . 0 children superview:0c3 window:66a noRedisplay
 */


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
