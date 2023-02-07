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
	@Published var scene:SCNScene = SCNScene(named:"art.scnassets/ship.scn")!
}
class DragonModel: 		ObservableObject {
	@Published var scene:SCNScene = dragonCurve(segments:1024)
	@Published var redrawValue:Int = 0
}
// /////////////////////////////////////////////////////////////////////////////

struct ContentView: View {
	@Binding	 var document	: FactalsDocument	// the Document
	@StateObject var    jetModel =    JetModel()		// test Model 1 (instantiates an observable object)
	@StateObject var dragonModel = DragonModel()		// test Model 2 (instantiates an observable object)
								
	var body: some View {
		if falseF, dragonModel.redrawValue & 1 == 1 {	//falseF, //
			Button(label: {	Text("dragonModel.redrawValue = \(dragonModel.redrawValue)") })
			{	dragonModel.redrawValue += 1									}
		} else {
			let select 			= 1//4//1//
			if select == 0 {	bodyNada										}
			if select == 1 {	bodySimple										}
			if select == 2 { 	bodyJet											}
			if select == 3 { 	bodyDragon										}
			if select == 4 { 	bodyAll											}
		}
	}
	var bodyNada: some View {		// Single HNW View
		VStack {
			Button(label: {	Text("dragonModel.redrawValue = \(dragonModel.redrawValue)") })
			{	dragonModel.redrawValue += 1									}
												//	if dragonModel.value != 17 {
												//		ButtonBar(document:$document, dragonModel:dragonModel)
												//	}
		}
	}
	var bodySimple: some View {		// Single HNW View
		VStack {
			 //  --- H a v e N W a n t  1  ---
			let sceneKitArgs	= SceneKitArgs(
				sceneIndex	: 0,
				title		: "0: Big main view",
				vewConfig	: vewConfigAllToDeapth4, //vewConfig1,//.null,
				background	: nil,	 // no specific background scene
				pointOfView	: document.fwGuts.rootVews[0]?.fwScene.cameraScn,//rootScn.cameraScn, //nil,//
				fwGuts		: document.fwGuts,
				options		: [.rendersContinuously],	//.allowsCameraControl,
				preferredFramesPerSecond:30
			)
			if dragonModel.redrawValue != 17 {
				SceneKitView(sceneKitArgs:sceneKitArgs)
				 .frame(maxWidth:.infinity)
				 .border(.black, width:2)
				 .onAppear() {						//was didLoadNib
					document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
				 }
			}
			ButtonBar(document:$document, dragonModel:dragonModel)
		}
//		 .toolbar {
//			ToolbarItem(placement: .primaryAction) {
//		//		NavigationStack {//view was automatically measured but had an ambiguous height or width
//	//				List {
//	//					Button("a") 		{	print("a") 						}
//	//				}															//}
//	//				.navigationTitle ("Menu")
//	//				.listStyle(DefaultListStyle())
//		//		}
//			}
//		}

//	//	ToolbarItem(placement: .primaryAction) {	//.primaryAction//.principal//.status//
//	//		NavigationStack {	// was NavigationView
//	//			List {	// Menu("Act") { // Menu
//	//				Button("a") 		{	print("a") 						}
//	//				Button(label:{	Label("b", systemImage: "plus")			})
//	//				{	print("b")											}
//	//				Menu("c...") {
//	//					Button("c1")	{	print("c1")						}
//	//					Button("c2")	{	print("c2")						}
//	//				}														//ForEach (menu123) { section in
//	//																		//	Section (header: Text (section.name)) {
//	//																		//		ForEach (section.items) { item in
//	//																		//			Text (item.name)
//	//																		//		}
//	//																		//	}
//	//			}															//}
//	//			.navigationTitle ("Menu")
//	//			.listStyle(DefaultListStyle())		// GroupedListStyle is unavailable in macOS
//	//		}
//	//	}
	}

	var bodyJet: some View {
		HStack {
			if let fwGuts			= document.fwGuts {
				VStack {	 // JET
					let sceneKitArgs	= SceneKitArgs( 	//SceneView(
						sceneIndex	: 0,
						title		: "Jet",
						vewConfig	: vewConfigAllToDeapth4,//.null,//.openAllChildren(toDeapth:99),//			// No HaveNWant Vews in Jet
						background	: (jetModel.scene as! FwScene),		// iffy
						pointOfView	: nil,//cameraNode,//nil,//jetModel.scene.cameraScn,
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
					ButtonBar(document:$document, dragonModel:dragonModel)//, dragonValue:dragonModel.$value)
				}
			}
			else {
				Button(label:{Text("Document has nil fwGuts").padding(.top, 300) } 	)
				{	fatalError(" ERROR ")											}
			}
		}
	}

	var pov : SCNNode? {
		let rv					= dragonModel.scene.rootNode.find(name:"*-camera")
		print("fetched camera pov")
//		let i 					= dragonModel.value
//		rv?.transform 			= [SCNMatrix4MakeRotation(0,     1,1,1),
//								   SCNMatrix4MakeRotation(.pi/2, 1,0,0),
//								   SCNMatrix4MakeRotation(.pi/2, 0,1,0),
//								   SCNMatrix4MakeRotation(.pi/2, 0,0,1)] [i % 4]
		return rv
	}

	var bodyDragon: some View {
		HStack {
			Button(label: {	Text("Dragon:value\(dragonModel.redrawValue)")			})
			{	dragonModel.redrawValue += 1; dragonModel.redrawValue %= 12 				}
			 .onAppear() {
				print("y: Button APPEARED \(dragonModel.redrawValue)")
			 }
			if dragonModel.redrawValue % 2 == 0 {
				SceneView(
					scene		: dragonModel.scene,
					pointOfView	: pov,//nil,//dragonModel.scene.rootNode,//cameraNode,//nil,//.childNode(withName: "ship", recursively: true),
					options		: [.autoenablesDefaultLighting]//.allowsCameraControl,
				)
				.frame(width:150, height:150)
				.border(.black, width:2)
				.onAppear() {
					DOClog.log("Dragon APPEARED")
					guard let scn = dragonModel.scene.rootNode.childNode(withName: "ship", recursively: true) else {return}
					let i 		  = dragonModel.redrawValue / 2
					scn.transform = [SCNMatrix4MakeRotation(0,     1,1,1),
									 SCNMatrix4MakeRotation(.pi/2, 1,0,0),
									 SCNMatrix4MakeRotation(.pi/2, 0,1,0),
									 SCNMatrix4MakeRotation(.pi/2, 0,0,1)] [i % 4]
					let rotationAxis = SCNVector3(i/4==1 ? 1 : 0, i/4==2 ? 1 : 0, i/4==3 ? 1 : 0)
					scn.runAction(SCNAction.repeatForever(SCNAction.rotate(by:.pi/4, around:rotationAxis, duration:10) ))
				}
				.onDisappear() {
					DOClog.log("Dragon DISAPPEARED")
					print()
				}
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
							pointOfView	: nil,//cameraNode,//document.fwGuts.rootVews[0].lookAtVew?.scn,//nil,//
							fwGuts		: fwGuts,
							options		: [.rendersContinuously],	//.allowsCameraControl,
							preferredFramesPerSecond:30
						)
						if dragonModel.redrawValue != 17 {
							SceneKitView(sceneKitArgs:sceneKitArgs)
							 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
							 .border(.black, width:2)
							 .onAppear() {
								document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
							 }
						}
						Text(":0")
					}
					ButtonBar(document:$document, dragonModel:dragonModel)//, dragonValue:dragonModel.$value)
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
							pointOfView	: nil,//cameraNode,//document.fwGuts.rootVews[0].lookAtVew?.scn,//rootVew.rootScn.cameraScn, //pov,//nil,//
							fwGuts		: fwGuts,
							options		: [.rendersContinuously],				//.allowsCameraControl,
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
							pointOfView	: nil,//cameraNode,//nil,//dragonModel.scene.rootNode,//.childNode(withName: "ship", recursively: true),
							options		: [.allowsCameraControl, .autoenablesDefaultLighting]
						)
						 .frame(width:150, height:150)
						 .border(.black, width:2)
						 .onAppear() {
							DOClog.log("Dragon APPEARED")
							guard let scn = dragonModel.scene.rootNode.childNode(withName: "ship", recursively: true) else {return}
							let i = dragonModel.redrawValue
							scn.transform = [SCNMatrix4MakeRotation(0,     1,1,1),
											 SCNMatrix4MakeRotation(.pi/2, 1,0,0),
											 SCNMatrix4MakeRotation(.pi/2, 0,1,0),
											 SCNMatrix4MakeRotation(.pi/2, 0,0,1)] [i % 4]
							let rotationAxis = SCNVector3(i/4==1 ? 1 : 0, i/4==2 ? 1 : 0, i/4==3 ? 1 : 0)
							scn.runAction(SCNAction.repeatForever(SCNAction.rotate(by:.pi/4, around:rotationAxis, duration:10) ))
							DOClog.log("Dragon DISAPPEARED")
						 }
						 // --- J E T ---
						Text("2:")
						let sceneKitArgs	= SceneKitArgs( 	//SceneView(
							sceneIndex	: 2,
							title		: "2: Jet View",
							vewConfig	: .null,
							background	: (jetModel.scene as! FwScene),
							pointOfView	: nil,//cameraNode,//document.fwGuts.rootVews[0].lookAtVew?.scn,//nil,//jetModel.scene.cameraScn,
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
