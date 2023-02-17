//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//
import SwiftUI
import SceneKit

extension SCNCameraController : ObservableObject {	}

struct ContentView: View {
	@Binding	 var document	: FactalsDocument	// the Document

	var body: some View {	// bodyAll
	  VStack {
		HStack {
			if let fwGuts			= document.fwGuts {
				VStack {
					 //  --- H a v e N W a n t  0  ---
					let sceneKitArgs	= SceneKitArgs(
						keyIndex	: 0,
						title		: "0: Big main view",
						rootPart	: fwGuts.rootPart,
						vewConfig	: vewConfigAllToDeapth4, 				//vewConfig1,//.null,
						scnScene	: nil,	 // no specific background scene
						pointOfView	: nil,
						options		: [.rendersContinuously],	//.allowsCameraControl,
						preferredFramesPerSecond:30
//						handler		: { nsEvent in print("0: Big main view's handler") }
					)
					SceneKitView(sceneKitArgs:sceneKitArgs)
					 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
					 .border(.black, width:2)
					 .onAppear() {
						 document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
					 }
//					let rootVew			= fwGuts.rootVews[sceneKitArgs.keyIndex]
//					VewBar(rootVew:$rootVew)	// PW BUG: Only displays 0, not 1
				}
				VStack {
					 //  --- H a v e N W a n t  1  ---
					let sceneKitArgs	= SceneKitArgs(
						keyIndex	: 1,
						title		: "1: Second smaller view",
						rootPart	: fwGuts.rootPart,
						vewConfig	: vewConfigAllToDeapth4, 				//vewConfig2,//.null,
						scnScene	: nil,	// no specific background scene
						pointOfView	: nil,
						options		: [.rendersContinuously],				//.allowsCameraControl,
						preferredFramesPerSecond:30
//						handler		: { nsEvent in print("1: Second smaller view's handler") }
					)
					SceneKitView(sceneKitArgs:sceneKitArgs)
					 .frame(maxWidth: .infinity)
					 .border(.black, width:2)
					 .onAppear() {
						 document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
					 }
//					VewBar(document:$document)
				}
			}
			else {
				Button(label:{Text("Document has no fwGuts").padding(.top, 300) } 	)
				{	fatalError(" ERROR ")											}
			}
		}
	  }
	}
}
