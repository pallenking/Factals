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
	let win0 : NSWindow?		= DOC.window0
	var body: some View {
		VStack {
			let rootPart:RootPart = document.docState.rootPart
			let scene			= document.docState.fwScene
			//let aux			= DOCLOG.params4aux + ["ppDagOrder":true]
			ZStack {
				NSEventReceiver { nsEvent in DOCstate.fwScene.receivedEvent(nsEvent:nsEvent)		}
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
	//A			 .gesture(gestures())
				 .border(Color.black, width: 3)
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
			//Spacer()
		}
	}
	// SEE "//	func gestures() -> some Gesture" below
}
																				//			let nsEvent:NSEvent = NSEvent.keyEvent(with:.leftMouseDown,
																				//												   location:location,
																				//												   modifierFlags:0,
																				//												   timestamp:0,
																				//												   windowNumber:0,
																				//												   context: nil,
																				//												   characters: "",
																				//												   charactersIgnoringModifiers: "???lf3ru8",
																				//												   isARepeat:false,
																				//												   keyCode:0
																				//												  )!
/*
		public var time: Date							/// The time associated with the drag gesture's current event.
		public var location: CGPoint					/// The location of the drag gesture's current event.
		public var startLocation: CGPoint				/// The location of the drag gesture's first event.
		public var translation: CGSize { get } 			/// The total translation from the start of the drag gesture to the
		public var predictedEndLocation: CGPoint { get}	/// A prediction, based on the current drag velocity, of where the final
		public var predictedEndTranslation: CGSize { get}/// A prediction, based on the current drag velocity, of what the final
 */




 																				//	func gestures() -> some Gesture {
																				//		let drag 				= DragGesture(minimumDistance: 0)
																				//		  .onChanged(   // Do stuff with the drag - maybe record what the value is in case things get lost later on
																				//			{	d in dragGesture(value:d)										})
																				//		  .onEnded(
																				//			{	d in dragGestureEnd(value:d)									})
																				//
																				//		let hackyPinch 			= MagnificationGesture(minimumScaleDelta: 0.0)			// OMIT??
																				//		  .onChanged(
																				//			{	delta in onGesture("Pinch Changed \(delta)")					})
																				//		  .onEnded(
																				//			{	delta in onGesture("Pinch Ended \(delta)")						})
																				//
																				//		let tap1				= TapGesture(count:1)
																				//		  .onEnded(	//(SwiftUI.TapGesture.Value) $R0 = {}
																				//			{	event in tapGesture(value:event, count:1);print(event)			})
																				//		let tap2				= TapGesture(count:2)
																				//		  .onEnded(
																				//			{	event in tapGesture(value:event, count:2)						})
																				//
																				//		let hackyRotation 		= RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))// OMIT??
																				//		  .onChanged(
																				//			{	delta in onGesture("Rotation Changed \(delta)")					})
																				//		  .onEnded(
																				//			{	delta in onGesture("Rotation Ended \(delta)")					})
																				//		// HOW USED:
																				//		let hackyPress 			= LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
																				//		  .onChanged(
																				//			{	delta in bug;onGesture("Press Changed \(delta)")				})
																				//		  .onEnded(
																				//			{	delta in bug;onGesture("Press Ended \(delta)")				})
																				//
																				//		let combinedGesture = drag
																				//		  .simultaneously(with: hackyPinch)
																				//		  .simultaneously(with: hackyRotation)
																				//		  .simultaneously(with: tap1)
																				//		  .simultaneously(with: tap2)
																				//		  .exclusively(before: hackyPress)		// seems to do nothing
																				//		return combinedGesture
																				//	}
																				//	func onGesture(_ msg:String="") {	print("onGesture: \(msg)") }	// set state, process the last drag position we saw, etc
																				//
																				//	//  ====== LEFT MOUSE ======
																				//	func dragGesture(value v:DragGesture.Value) {
																				//		let fwScene				= DOCstate.fwScene
																				//		let delta				= v.location - v.startLocation
																				//	//	print(String(format:"dragGesture %10.2f%10.2f%16.2f%10.2f", v.location.x, v.location.y, delta.x, delta.y))
																				//
																				//		var newPole : FwScene.SelfiePole = fwScene.lastSelfiePole
																				//		newPole.spin  -= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
																				//		newPole.horizonUp -= delta.y  * 0.2		// * self.cameraZoom/10.0
																				//		fwScene.updateCameraTransform(to:newPole, for:"dragGesture")
																				//	}
																				//	func dragGestureEnd(value v:DragGesture.Value) {
																				//		let fwScene				= DOCstate.fwScene
																				//		let delta				= v.location - v.startLocation
																				//	//	print(String(format:"dragGestureEnd %10.2f%10.2f%16.2f%10.2f", v.location.x, v.location.y, delta.x, delta.y))
																				//
																				//		fwScene.lastSelfiePole.spin  -= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
																				//		fwScene.lastSelfiePole.horizonUp -= delta.y  * 0.2		// * self.cameraZoom/10.0
																				//		fwScene.updateCameraTransform(for:"dragGestureEnd")
																				//	}
																				//	func tapGesture(value v:TapGesture.Value, count:Int) {
																				//		let fwScene				= DOCstate.fwScene
																				//		print("tapGesture value:'\(v)' count:\(count)")
																				//
																				//		 // Make NSEvent for Double Click
																				//		let a					= fwScene.cameraNode.position
																				//		let location			= NSPoint(x: a.x, y: a.y)
																				//		let nsEvent:NSEvent	 	= NSEvent.mouseEvent(	with:.leftMouseDown,
																				//											location:location,
																				//											modifierFlags:.numericPad,//?? :NSEvent.ModifierFlags,
																				//			/* WTF: */			  timestamp:0,windowNumber:0,context:nil,eventNumber:0,
																				//											clickCount:count,
																				//											pressure:1.0)!
																				//		 // dispatch Pic event
																				//		let x:Vew? 				= DOCstate.fwScene.modelPic(with:nsEvent)
																				////		print(windowController0)
																				//		print(x ?? "<<nil>>")
																				//	}
