//
//  ContentView.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//
import SwiftUI
import SceneKit

extension SCNCameraController : ObservableObject {	}

////////////////////////////// Testing
final class FooModel : ObservableObject {
	@Published var selfiePole 	= SelfiePole()		// debug
}
struct ContentView: View {
	@Binding	 var document	: FactalsDocument	// the Document
	@StateObject var fooModel 	= FooModel()
	var body: some View {
		FwGutsView(fwGuts:$document.fwGuts)	// document:$document,        r
		HStack {
//			Text("$fooModel.\nselfiePole").foregroundColor(.red).bold()
			SelfiePoleBar(selfiePole:$fooModel.selfiePole)
			Button(label:{	Text("Z//foo").padding(.top, 300).foregroundColor(.red)})
			{	var s	= fooModel.selfiePole
				s.zoom	/= 1.1
				print("======== \(s.pp(.uidClass)) z=\(s.pp(.line))")
				fooModel.selfiePole = s	// Put struct's val back
			}
			//{	fooModel.selfiePole.zoom *= 1.1										}
		}
	}
}
struct FwGutsView: View {
	@Binding	var fwGuts		: FwGuts
	@State		var isLoaded	= false

	var body: some View {
		VStack {
			GutsBar(fwGuts:$fwGuts).padding(.vertical, -10)
 
			HStack {
//	$publisher
//	$view
//
//	Publisher $zoommodel.zoom
//	viewmodel.$zoom
//				}
//				HStack {  	 //  --- H a v e N W a n t  0  ---
//					ForEach(fwGuts.rootVews) {	rootVew in
//						VStack {	 //  --- H a v e N W a n t  0  ---
//							let slot		= 0
//							VewBar(rootVews:$fwGuts.rootVews,  slot:slot)	// PW1: I don't understand the correct thing to pass in
//							//
//							let sceneKitArgs = SceneKitArgs(
//								slot		: slot,
//								title		: "\(slot): Big main view",
//								rootPart	: fwGuts.rootPart,
//								vewConfig	: vewConfigAllToDeapth4, 				//vewConfig1,//.null,
//								scnScene	: nil,	 // no specific background scene
//								pointOfView	: nil,
//								options		: [.rendersContinuously],	//.allowsCameraControl,
//								preferredFramesPerSecond:30
//							//	handler		: { nsEvent in print("0: Big main view's handler") }
//							)
//							SceneKitView(sceneKitArgs:sceneKitArgs)
//							 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
//							 .border(.black, width:2)
//							 .onAppear() {
//								fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
//								isLoaded = true
//							 }
//						}
//
//					}
//				}
				VStack {	 //  --- H a v e N W a n t  0  ---
					let slot		= 0
					VewBar(rootVews:$fwGuts.rootVews,  slot:slot)	// PW1: I don't understand the correct thing to pass in
					//
					let sceneKitArgs = SceneKitArgs(
						slot		: slot,
						title		: "\(slot): Big main view",
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
						fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						isLoaded = true
					 }
				}
				if false { VStack {	 //  --- H a v e N W a n t  1  ---
					let slot		= 1
					VewBar(rootVews:$fwGuts.rootVews,  slot:slot)	// PW1: I don't understand the correct thing to pass in
					//
					let sceneKitArgs = SceneKitArgs(
						slot		: slot,
						title		: "\(slot): Big main view",
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
						fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
						isLoaded = true
					 }
				}}
		//		VStack {	 //  --- H a v e N W a n t  2  ---
		//			let slot		= 2
		//			VewBar(rootVews:$fwGuts.rootVews,  slot:slot)	// PW1: I don't understand the correct thing to pass in
		//			//
		//			let sceneKitArgs = SceneKitArgs(
		//				slot		: slot,
		//				title		: "\(slot): Big main view",
		//				rootPart	: fwGuts.rootPart,
		//				vewConfig	: vewConfigAllToDeapth4, 				//vewConfig1,//.null,
		//	  			scnScene	: nil,	 // no specific background scene
		//				pointOfView	: nil,
		//				options		: [.rendersContinuously],	//.allowsCameraControl,
		//				preferredFramesPerSecond:30
		//			//	handler		: { nsEvent in print("0: Big main view's handler") }
		//			)
		//			SceneKitView(sceneKitArgs:sceneKitArgs)
		//			 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
		//			 .border(.black, width:2)
		//			 .onAppear() {
		//				fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
		//				isLoaded = true
		//			 }
		//		}
			}
			Spacer()
		}
	}
}
