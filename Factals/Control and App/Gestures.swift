//
//  Gestures.swift
//  Factals
//
//  Created by Allen King on 8/25/22.
//
import SwiftUI
import SceneKit

//class XXXX_StuffToSave {
//	func gestures() -> some Gesture {
//		let drag 				= DragGesture(minimumDistance: 0)
////		  .onChanged(   // Do stuff with the drag - maybe record what the value is in case things get lost later on
////			{	d in self.dragGesture(value:d)									})
////		  .onEnded(
////			{	d in self.dragGestureEnd(value:d)								})
//
//		let hackyPinch 			= MagnificationGesture(minimumScaleDelta: 0.0)			// OMIT??
//		  .onChanged(
//			{	delta in self.onGesture("Pinch Changed \(delta)")				})
//		  .onEnded(
//			{	delta in self.onGesture("Pinch Ended \(delta)")					})
//
//		let tap1				= TapGesture(count:1)
//		  .onEnded(	//(SwiftUI.TapGesture.Value) $R0 = {}
//			{	event in self.tapGesture(value:event, count:1);print(event)		})
//		let tap2				= TapGesture(count:2)
//		  .onEnded(
//			{	event in self.tapGesture(value:event, count:2)					})
//
//		let hackyRotation 		= RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))// OMIT??
//		  .onChanged(
//			{	delta in self.onGesture("Rotation Changed \(delta)")			})
//		  .onEnded(
//			{	delta in self.onGesture("Rotation Ended \(delta)")				})
//		// HOW USED:
//		let hackyPress 			= LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
//		  .onChanged(
//			{	delta in bug;self.onGesture("Press Changed \(delta)")			})
//		  .onEnded(
//			{	delta in bug;self.onGesture("Press Ended \(delta)")				})
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
////	//  ====== LEFT MOUSE ======
////	func dragGesture(value v:DragGesture.Value) {
////		let fwGuts				= DOCfwGuts
////		let delta				= v.location - v.startLocation
////	//	print(String(format:"dragGesture %10.2f%10.2f%16.2f%10.2f", v.location.x, v.location.y, delta.x, delta.y))
////
////		var selfiePole			= fwGuts.lastSelfiePole
////		selfiePole.spin  -= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
////		selfiePole.horizonUp -= delta.y  * 0.2		// * self.cameraZoom/10.0
////		fwGuts.fwScn.updatePole2Camera(reason:"dragGesture")
////	}
////	func dragGestureEnd(value v:DragGesture.Value) {
////		let fwGuts				= DOCfwGuts
////		let delta				= v.location - v.startLocation
////	//	print(String(format:"dragGestureEnd %10.2f%10.2f%16.2f%10.2f", v.location.x, v.location.y, delta.x, delta.y))
////
////		fwGuts.lastSelfiePole.spin  -= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
////		fwGuts.lastSelfiePole.horizonUp -= delta.y  * 0.2		// * self.cameraZoom/10.0
////		fwGuts.fwScn.updatePole2Camera(reason:"dragGestureEnd")
////	}
//	func tapGesture(value v:TapGesture.Value, count:Int) {
//		let fwGuts				= DOCfwGuts
//		print("tapGesture value:'\(v)' count:\(count)")
//
//		 // Make NSEvent for Double Click
//		let a					= fwGuts.fwScns[zeroIndex].scnScene.cameraScn!.position
//		let location			= NSPoint(x: a.x, y: a.y)
//		let nsEvent:NSEvent	 	= NSEvent.mouseEvent(	with:.leftMouseDown,
//											location:location,
//											modifierFlags:.numericPad,//?? :NSEvent.ModifierFlags,
//			/* WTF: */			  timestamp:0,windowNumber:0,context:nil,eventNumber:0,
//											clickCount:count,
//											pressure:1.0)!
//		 // dispatch Pic event
//		let x:Vew? 				= DOCfwGuts.modelPic(with:nsEvent)
////		print(windowController0)
//		print(x ?? "<<nil>>")
//	}
//}
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
// DragGesture.Value:
//		var time: Date							/// The time associated with the drag gesture's current event.
//		var location: CGPoint					/// The location of the drag gesture's current event.
//		var startLocation: CGPoint				/// The location of the drag gesture's first event.
//		var translation: CGSize { get } 		/// The total translation from the start of the drag gesture to the
//		var predictedEndLocation: CGPoint { get}/// A prediction, based on the current drag velocity, of where the final
//		var predictedEndTranslation: CGSize { get}/// A prediction, based on the current drag velocity, of what the final
