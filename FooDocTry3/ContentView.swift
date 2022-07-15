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

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()
	@StateObject var dragonModel	= DragonModel()
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
							  .jitteringEnabled,
							  .rendersContinuously,
							  .temporalAntialiasingEnabled
					]
				)
				 .frame(width:600, height:400)
/*
SceneView(			    scene:SCNScene?,
	 			  pointOfView:SCNNode?,
	 				  options:SceneView.Options,
	 preferredFramesPerSecond:Int,
			 antialiasingMode:SCNAntialiasingMode,
					 delegate:SCNSceneRendererDelegate?,
					technique:SCNTechnique?)
 */
				HStack {
					Spacer()
					Button(action: {	lldbPrint(ob:rootPart, mode:.tree)		}){
						Text("ptm").padding(.top, 300)							}
					Button(action: {	lldbPrint(ob:rootPart, mode:.tree)		}){
						Text("ptLm").padding(.top, 300)							}
					Button(action: {	lldbPrint(ob:rootVew, mode:.tree) 		}){
						Text("ptv").padding(.top, 300)							}
					Button(action: {Swift.print(rootNode.pp(.tree, aux), terminator:"\n") }){
						Text("ptn").padding(.top, 300)							}
					Spacer()
					Button(action: {	breakToDebugger()						}){
						Text("LLDB").padding(.top, 300)							}
				}
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
