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
extension SCNCameraController : ObservableObject {	}

struct ContentView: View {
	@Binding     var document: FooDocTry3Document
	@StateObject var jetModel 		= JetModel()
	@StateObject var dragonModel	= DragonModel()
//	@StateObject var cameraController: SCNCameraController

	var body: some View {
		//@GestureState var dragGestureActive: Bool = false
		//@State var dragOffset: CGSize = .zero
//		HStack {
			VStack {
				let rootPart:Part	= document.docState.rootPart
				let scene			= document.docState.fwScene
				let rootVew :Vew	= scene.rootVew
				let rootNode		= scene.rootNode
				let aux				= DOCLOG.params4aux + ["ppDagOrder":true]
				SceneView(
					scene			: scene,
					pointOfView		: scene.cameraNode,
					options			: [.autoenablesDefaultLighting,
		//**/						   .allowsCameraControl,
									   .jitteringEnabled,
									   .rendersContinuously,
									   .temporalAntialiasingEnabled
					],
					preferredFramesPerSecond:30,
			 		antialiasingMode:.none,										//SCNAntialiasingModeNone, //SCNAntialiasingModeMultisampling2X SCNAntialiasingMode,
					delegate:document.docState.fwScene								// FwScene // SCNSceneRendererDelegate
				//	technique:SCNTechnique?
				)
				 .onAppear {
				 	document.didLoadNib()										}
				 .gesture(gestures() )
				 .border(Color.black, width: 3)									// .frame(width:600, height:400)\
				// .onKeyDown {		 }
				//.frame(width:600, height:400)

				HStack {
					Spacer()
					Button(label:{	Text( "ptm").padding(.top, 300)				})
					{	lldbPrint(ob:rootPart, mode:.tree)						}
					Button(label:{	Text("ptLm").padding(.top, 300)				})
					{	lldbPrint(ob:rootPart, mode:.tree, ["ppLinks":true]) 	}
					Button(label:{	Text( "  ")									}){}
						.buttonStyle(.borderless)
					Button(label:{	Text( "ptv").padding(.top, 300)				})
					{	lldbPrint(ob:rootVew, mode:.tree) 						}
					Button(label:{	Text( "ptn").padding(.top, 300)				})
					{	Swift.print(rootNode.pp(.tree, aux), terminator:"\n") 	}
					Spacer()
					Button(label: {	Text("LLDB").padding(.top, 300) 			})
					{	breakToDebugger()										}
					Button(label:{	Text( "  ")									}){}
						.buttonStyle(.borderless)
				}
				Spacer()
//			}
//			VStack {
//				SceneView(
//					scene: 		 jetModel.scene,
//					pointOfView: jetModel.scene.cameraNode,
//					options: [.allowsCameraControl, .autoenablesDefaultLighting]
//				)
//					.frame(width:200, height:200)
//				SceneView(
//					scene: 		 dragonModel.scene,
//					pointOfView: dragonModel.scene.cameraNode,
//					options: [.allowsCameraControl, .autoenablesDefaultLighting]
//				)
//					.frame(width:200, height:300)
//			}
		}
	}
	func gestures() -> some Gesture {
		let drag 				= DragGesture(minimumDistance: 0)
		  .onChanged(   // Do stuff with the drag - maybe record what the value is in case things get lost later on
			{	d in dragGesture(value:d)										})
		  .onEnded(
			{	d in dragGestureEnd(value:d)									})

		let hackyPinch 			= MagnificationGesture(minimumScaleDelta: 0.0)			// OMIT??
		  .onChanged(
			{	delta in onGesture("Pinch Changed \(delta)")					})
		  .onEnded(
			{	delta in onGesture("Pinch Ended \(delta)")						})

		let tap1				= TapGesture(count:1)
		  .onEnded(	//(SwiftUI.TapGesture.Value) $R0 = {}
			{	event in tapGesture(value:event, count:1);print(event)			})
		let tap2				= TapGesture(count:2)
		  .onEnded(
			{	event in tapGesture(value:event, count:2)						})

		let hackyRotation 		= RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))// OMIT??
		  .onChanged(
			{	delta in onGesture("Rotation Changed \(delta)")					})
		  .onEnded(
			{	delta in onGesture("Rotation Ended \(delta)")					})
		// HOW USED:
		let hackyPress 			= LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
		  .onChanged(
			{	delta in bug;onGesture("Press Changed \(delta)")				})
		  .onEnded(
			{	delta in bug;onGesture("Press Ended \(delta)")				})

		let combinedGesture = drag
		  .simultaneously(with: hackyPinch)
		  .simultaneously(with: hackyRotation)
		  .simultaneously(with: tap1)
		  .simultaneously(with: tap2)
		  .exclusively(before: hackyPress)		// seems to do nothing
		return combinedGesture
	}
	func onGesture(_ msg:String="") {	print("onGesture: \(msg)") }	// set state, process the last drag position we saw, etc

	//  ====== LEFT MOUSE ======
	func dragGesture(value v:DragGesture.Value) {
		let fwScene				= DOC.docState.fwScene
		let delta				= v.location - v.startLocation
	//	print(String(format:"dragGesture %10.2f%10.2f%16.2f%10.2f", v.location.x, v.location.y, delta.x, delta.y))
								
		var newPole : FwScene.SelfiePole = fwScene.lastSelfiePole
		newPole.cameraPoleSpin  -= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
		newPole.cameraHorizonUp += delta.y  * 0.2		// * self.cameraZoom/10.0
		fwScene.updateCameraTransform(to:newPole, for:"dragGesture")
	}
	func dragGestureEnd(value v:DragGesture.Value) {
		let fwScene				= DOC.docState.fwScene
		let delta				= v.location - v.startLocation
	//	print(String(format:"dragGestureEnd %10.2f%10.2f%16.2f%10.2f", v.location.x, v.location.y, delta.x, delta.y))

		fwScene.lastSelfiePole.cameraPoleSpin  -= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
		fwScene.lastSelfiePole.cameraHorizonUp += delta.y  * 0.2		// * self.cameraZoom/10.0
		fwScene.updateCameraTransform(for:"dragGestureEnd")
	}
	func tapGesture(value v:TapGesture.Value, count:Int) {
		let fwScene				= DOC.docState.fwScene
		print("tapGesture value:'\(v)' count:\(count)")
		//let v					= v.location	//'TapGesture.Value' has no member 'location'
		switch count {
		case 1: nop
		case 2: nop			// Double click  (HACK: use last drag location)

			 // Make NSEvent for Double Click
			let a				= fwScene.cameraNode.transform.position
			let location		= NSPoint(x: a.x, y: a.y)
			let nsEvent:NSEvent = NSEvent.mouseEvent(	with:.leftMouseDown,
												location:location,
												modifierFlags:.numericPad,//?? :NSEvent.ModifierFlags,
												timestamp:0,		// WTF
												windowNumber:0,		// WTF
												context:nil,		// WTF
												eventNumber:0,		// WTF
												clickCount:count,
												pressure:1.0)!
			let x:Vew? 			= DOC.docState.fwScene.modelPic(with:nsEvent)
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
								
		default: nop
		}
	}
}



/*
{

        
        public var time: Date		/// The time associated with the drag gesture's current event.
        public var location: CGPoint/// The location of the drag gesture's current event.
        public var startLocation: CGPoint/// The location of the drag gesture's first event.
        public var translation: CGSize { get } /// The total translation from the start of the drag gesture to the

        /// A prediction, based on the current drag velocity, of where the final
        /// location will be if dragging stopped now.
        public var predictedEndLocation: CGPoint { get }

        /// A prediction, based on the current drag velocity, of what the final
        /// translation will be if dragging stopped now.
        public var predictedEndTranslation: CGSize { get }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: DragGesture.Value, b: DragGesture.Value) -> Bool
    }
 */
