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
	@State		var fooSlot0	= 0
	@State		var fooSlot1 	= 1
	@State		var rootVewReady0 = false
	@State		var rootVewReady1 = false

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
						//	handler		: { nsEvent in print("0: Big main view's handler") }
						)
						SceneKitView(sceneKitArgs:sceneKitArgs)
						 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
						 .border(.black, width:2)
						 .onAppear() {
							document.fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
							rootVewReady0 = true
						 }
						if rootVewReady0, document.fwGuts.rootVews.count-1 >= sceneKitArgs.keyIndex {
							VewBar(rootVew: $document.fwGuts.rootVews[sceneKitArgs.keyIndex])	// PW1: I don't understand the correct thing to pass in
						}
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
							rootVewReady1 = true
						}
						if rootVewReady1, document.fwGuts.rootVews.count-1 >= sceneKitArgs.keyIndex {
							VewBar(rootVew: $document.fwGuts.rootVews[sceneKitArgs.keyIndex])	// PW1: I don't understand the correct thing to pass in
						}
					}
				}
				else {
					Button(label:{Text("Document has no fwGuts").padding(.top, 300) } 	)
					{	fatalError(" ERROR ")											}
				}
			}
		PartBar(document: $document)
		Spacer()
		}
	}
}
