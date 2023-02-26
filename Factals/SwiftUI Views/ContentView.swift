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
	@Published var selfiePole 	= SelfiePole()
}
struct ContentView1: View {
	@Binding var document		: FactalsDocument	// the Document
	@StateObject var fooModel 	= FooModel()
	var body: some View {
		SelfiePoleBar(selfiePole:$fooModel.selfiePole)
		Button(label:{	Text( "Z**").padding(.top, 300)							})
		{	fooModel.selfiePole.zoom *= 1.1										}
	}
}
////////////////////////////// Testing

struct ContentView: View {
	@Binding	var document	: FactalsDocument	// the Document
	var body: some View {
		FwGutsView(fwGuts:$document.fwGuts)	// document:$document,        r
		Spacer()
	}
}
struct FwGutsView: View {
	@Binding	var fwGuts		: FwGuts
	@State		var isLoaded	= false
	@StateObject var fooModel 	= FooModel()

	var body: some View {
		VStack {
			PartBar(fwGuts:$fwGuts).padding(.vertical, -10)

	//		SelfiePoleBar(selfiePole:$fwGuts.fooSelfiePole)
	//		Button(label:{	Text( "Z**").padding(.top, 300)						})
	//		{	fooModel.selfiePole.zoom *= 1.1									}
 
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
			//	VStack {
			//		 //  --- H a v e N W a n t  1  ---
			//		let sceneKitArgs	= SceneKitArgs(
			//			slot	: 1,
			//			title		: "1: Second smaller view",
			//			rootPart	: fwGuts.rootPart,
			//			vewConfig	: vewConfigAllToDeapth4, 				//vewConfig2,//.null,
			//			scnScene	: nil,	// no specific background scene
			//			pointOfView	: nil,
			//			options		: [.rendersContinuously],				//.allowsCameraControl,
			//			preferredFramesPerSecond:30
			//		//	handler		: { nsEvent in print("1: Second smaller view's handler") }
			//		)
			//		VewBar(rootVews: $fwGuts.rootVews,  keySlot: sceneKitArgs.slot)	// PW1: I don't understand the correct thing to pass in
			//		SceneKitView(sceneKitArgs:sceneKitArgs)
			//		 .frame(maxWidth: .infinity)								// .frame(width:500, height:300)
			//		 .border(.black, width:2)
			//		 .onAppear() {
			//			fwGuts.viewAppearedFor(sceneKitArgs:sceneKitArgs)
			//			isLoaded = true
			//		 }
			//	}
			}
			Spacer()
		}
	}
}
