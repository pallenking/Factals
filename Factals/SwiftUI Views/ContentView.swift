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
	@Binding	var document	: FactalsDocument	// the Document
	var body: some View {
		PartBar(document: $document)
		 .padding(.vertical, -10)
		FwGutsView(fwGuts:$document.fwGuts)	// document:$document,        r
		Spacer()
	}
}
struct FwGutsView: View {
	@Binding	var fwGuts		: FwGuts
	@State		var isLoaded	= false

	var body: some View {
		VStack {
			HStack {
				VStack {
					 //  --- H a v e N W a n t  0  ---
					let sceneKitArgs	= SceneKitArgs(
						slot	: 0,
						title		: "0: Big main view",
						rootPart	: fwGuts.rootPart,
						vewConfig	: vewConfigAllToDeapth4, 				//vewConfig1,//.null,
			 			scnScene	: nil,	 // no specific background scene
						pointOfView	: nil,
						options		: [.rendersContinuously],	//.allowsCameraControl,
						preferredFramesPerSecond:30
					//	handler		: { nsEvent in print("0: Big main view's handler") }
					)
					VewBar(rootVews: $fwGuts.rootVews,  keySlot: sceneKitArgs.slot)	// PW1: I don't understand the correct thing to pass in
					SceneKitView(sceneKitArgs:sceneKitArgs)
					 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
					 .border(.black, width:2)
					 .onAppear() {
						fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						isLoaded = true
					 }
				}
				VStack {
					 //  --- H a v e N W a n t  1  ---
					let sceneKitArgs	= SceneKitArgs(
						slot	: 1,
						title		: "1: Second smaller view",
						rootPart	: fwGuts.rootPart,
						vewConfig	: vewConfigAllToDeapth4, 				//vewConfig2,//.null,
						scnScene	: nil,	// no specific background scene
						pointOfView	: nil,
						options		: [.rendersContinuously],				//.allowsCameraControl,
						preferredFramesPerSecond:30
					//	handler		: { nsEvent in print("1: Second smaller view's handler") }
					)
					VewBar(rootVews: $fwGuts.rootVews,  keySlot: sceneKitArgs.slot)	// PW1: I don't understand the correct thing to pass in
					SceneKitView(sceneKitArgs:sceneKitArgs)
					 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
					 .border(.black, width:2)
					 .onAppear() {
						fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						isLoaded = true
					 }
				}
			}
//			PartBar(document: $document)
//			Spacer()
		}
	}
}
