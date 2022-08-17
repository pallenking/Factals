//
//  UserViaGui.swift
//  FooDocTry3
//
//  Created by Allen King on 7/16/22
// 		From FwView.swift -- A 2D NSView which displays a 3D FwScene
// 			Key, Mouse, and Touch Events; mouse rotator, mouse pic, ...

import SceneKit

class UserViaGui {


					  // ///////////////////////// //////////// //
					 // ///                   /// //
					// ///		 PIC         /// //
				   // ///                   /// //
	 // //////////// ///////////////////////// //
	
	/// Mouse Down NSEvent becomes a FwEvent to open the selected vew
	/// - Parameter nsEvent: mouse down
	/// - Returns: The Vew of the part pressed
	func modelPic(with nsEvent:NSEvent) -> Vew?
	{
		 // CONVERT to window coordinates
bug//	let view				= DOC?.fwView
//		if let mouse 			= view?.convert(nsEvent.locationInWindow, from:view),
//		   // SELECT 3D point from 2D position
//		  let picdVew			= findVew(at:mouse)
//		{
//			 // DISPATCH to PART that was pic'ed
//			if picdVew.part.processKey(from:nsEvent, inVew:picdVew) == false {
//				atEve(3, print("\t\t" + "\(picdVew.part.pp(.fullName)).processKey('') ignored\n"))
//				return nil
//			}
//			return picdVew
//		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}
//	func findVew(at mouse:CGPoint) -> Vew? {
//		var msg					= "******************************************\n modelPic:\t"
//
//		 // Find the 3D Vew for the Part under the mouse:
//		let configHitTest : [SCNHitTestOption:Any]? = [
//			.backFaceCulling	:true,	// ++ ignore faces not oriented toward the camera.
//			.boundingBoxOnly	:false,	// search for objects by bounding box only.
//			.categoryBitMask	:		// ++ search only for objects with value overlapping this bitmask
//					FwNodeCategory.picable  .rawValue  |// 3:works ??, f:all drop together
//					FwNodeCategory.byDefault.rawValue  ,
//			.clipToZRange		:true,	// search for objects only within the depth range zNear and zFar
//		  //.ignoreChildNodes	:true,	// BAD ignore child nodes when searching
//		  //.ignoreHiddenNodes	:true 	// ignore hidden nodes not rendered when searching.
//			.searchMode:1,				// ++ any:2, all:1. closest:0, //SCNHitTestSearchMode.closest
//		  //.sortResults:1, 			// (implied)
//			.rootNode:rootScn, 			// The root of the node hierarchy to be searched.
//		]
//bug;	let fwView				= DOC.fwView
//		//return nil
//		//						 + +   + +
//		let hits:[SCNHitTestResult]	= fwView?.hitTest(mouse, options:configHitTest) ?? []
//		//						 + +   + +
//
//		 // SELECT HIT; prefer any child to its parents:
//		var rv					= rootVew			// Nothing hit -> root
//		if var pickedScn		= fwView?.trunkVew?.scn {	// pic trunkVew
////		if var pickedScn		= fwView?.trunkVew?.scn {	// pic trunkVew
//
////			if hits.count > 0 {
//				 // There is a HIT on a 3D object:
//				let sortedHits	= hits.sorted { $0.node.depth > $1.node.depth }
//				pickedScn		= sortedHits[0].node // pic node with lowest deapth
//				msg 			+= "SCNNode: \((pickedScn.name ?? "8r23").field(-10)): "
//
//				 // If Node not picable,
//				while pickedScn.categoryBitMask & FwNodeCategory.picable.rawValue == 0,
//				  let parent 	= pickedScn.parent 	// try its parent:
//				{
//					msg			+= fmt("--> Ignore mask %02x", pickedScn.categoryBitMask)
//					pickedScn 	= parent				// use parent
//					msg 		+= "\n\t" + "parent:\t" + "SCNNode: \(pickedScn.fullName): "
//				}
//				 // Got SCN, get its Vew
//				if let cv		= trunkVew,
//				  let vew 		= cv.find(scnNode:pickedScn, inMe2:true)
//				{
//					rv			= vew
//					msg			+= "      ===>    ####  \(vew.part.pp(.fullNameUidClass))  ####"
//				}else{
//					panic(msg + "\n" + "couldn't find vew for scn:\(pickedScn.fullName)")
//					if let cv	= trunkVew,				// for debug only
//					  let vew 	= cv.find(scnNode:pickedScn, inMe2:true) {
//						let _	= vew
//					}
//				}
////			}else{
////				 // Background hit
////				msg				+= "background -> trunkVew"
////			}
////		}else{
////			print("trunkVew.scn nil")
//		}
//		atEve(3, print("\n" + msg))
////		return rv
//bug;	return nil
//	}


//class FwView: SCNView {
// MARK: - 2. Object Variables:
//\\\///\\\///\\\  SCNView conforms to SCNSceneRenderer:
																				 //\\\ SCNView.sceneTime					-
																				 //\\\ SCNView.autoenablesDefaultLighting	-
																				 //\\\ SCNView.hitTest:options:				***
																				 //\\\ SCNView.audioListener				***
																				 //\\\ SCNView.pointOfView					?
																				 //\\\ SCNView.projectPoint: unprojectPoint: ?
																				 //\\\ SCNView.delegate						***

//	 //\\\ SCNView.scene		same as fwScene:
//	var fwScene : FwScene?		= nil
//
//	 // MARK: - 3. Factory
//	override init(frame:CGRect, options:[String : Any]? = nil) {
//
//		super.init(frame:frame, options:options) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		DOC.fwView				= self			// Register in global Fw struct
//		atCon(6, logd("initXXX:        FwView/\(ppUid(self)):()"))		// <\(pp(.uidClass))>
//
////		showsStatistics 		= true			// doesn't work here
////		window!.backgroundColor = NSColor.yellow// doesn't work here // cocoahead x: only frame
//		isPlaying/*animations*/	= true			// works here?
//
//		allowsCameraControl 	= false			// dare to turn it on?
//		autoenablesDefaultLighting = false		// dare to turn it on?
//	}
//
//	 // MARK: - 3.5 Codable
//	required init?(coder decoder: NSCoder) {
//		super.init(coder:decoder) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//	}
//	 // MARK: - 3.6 NSCopying
//	func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : FwView	= FwView(frame:CGRect(x: 100, y: 200, width: 300, height: 400))//super.copy(with:zone) as! FwView
//	//	theCopy.con				= self.con
//		atSer(3, logd("copy(with as? FwView       ''"))
//		return theCopy
//	}
//
//	 // MARK: - 3.7 Equitable
//	func varsOfFwViewEq(_ rhs:Part) -> Bool {
//		guard let rhsAsFwView	= rhs as? FwView else {	return false		}
//bug;	return false
//	}
//	func equalsPart(_ part:Part) -> Bool {
//bug;	return	false//super.equalsPart(part) && varsOfFwViewEq(part)
//	}
//	 // MARK: - 13.1 Keys
//	// ////////////////////////////////////
//	//
//	//			K  K EEEE Y   Y  SSS
//	//			K K  E     Y Y  S
//	//			KK   EEE    Y    SS
//	//			K K  E      Y      S
//	//			K  K EEEE   Y   SSS
//	//
//	// //////////////////////////////////
//	var isAutoRepeat : Bool 	= false // filter out AUTOREPEAT keys
//	override func keyDown(with nsEvent:NSEvent) {
//		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {
//			return
//		}
//		assert(nsEvent.charactersIgnoringModifiers!.count == 1, "multiple keystrokes not supported")
//		if nsEvent.isARepeat {				// Ignore repeats
//			return
//		}
//		if isAutoRepeat {
//			print("the above isARepeat didn't work!")
//		}
//		isAutoRepeat 			= true
//		 		// Let Document process key:
//		if let doc				= DOC,
//		  doc.processKey(from:nsEvent, inVew:nil) == false {
//
//			if character != "?" {	// okay for "?" to get here
//				atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
//			}
//		}
//	}
//	override func keyUp(with nsEvent:NSEvent) {
//		assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
//		isAutoRepeat 		= false
//		let _ 				= DOC?.processKey(from:nsEvent, inVew:nil)
//	}

	// ///////////////////////////////////////
	//
	//			M   M  OO  U  U  SSS EEEE
	//			MM MM O  O U  U S    E
	//			M M M O  O U  U  SS  EEE
	//			M   M O  O U  U    S E
	//			M   M  OO   UU  SSS  EEEE
	//
	// ///////////////////////////////////////
//	 // MARK: - 13.2 Mouse
//	//  ====== LEFT MOUSE ======
//	let nsTrackPad				= true//false//
//	let duration				= Float(1)
//	var mouseWasDragged			= false
//	func mouseDown(with nsEvent:NSEvent) {
//		motionFromLastEvent(with:nsEvent)
//bug
//		if !nsTrackPad  {					// 3-button Mouse
////			let _				= fwScene?.modelPic(with:nsEvent)
//		}
////		fwScene?.updateCameraRotator(for:"Left mouseDown", overTime:duration)
//	}
//	override func mouseDragged(with nsEvent:NSEvent) {
//		if nsTrackPad  {					// Trackpad
//			motionFromLastEvent(with:nsEvent)
//			mouseWasDragged 	= true		// drag cancels pic
//			spinNUp(with:nsEvent)			// change Spin and Up of camera
//			fwScene?.updateCameraRotator(for:"Left mouseDragged")
//		}
//	}
//	override func mouseUp(with nsEvent:NSEvent) {
//		if nsTrackPad  {					// Trackpad
//			motionFromLastEvent(with:nsEvent)
//			if !mouseWasDragged {			// UnDragged Up
//				let _			= fwScene?.modelPic(with:nsEvent)
//			}
//			mouseWasDragged 	= false
//			fwScene?.updateCameraRotator(for:"Left mouseUp", overTime:duration)
//		}
//	}
////	 //  ====== RIGHT MOUSE ======			Right Mouse not used
//	 //  ====== CENTER MOUSE ======
//	override func otherMouseDown(with nsEvent:NSEvent)	{
//		motionFromLastEvent(with:nsEvent)
//		fwScene?.updateCameraRotator(for:"Other mouseDown", overTime:duration)
//	}
//	override func otherMouseDragged(with nsEvent:NSEvent) {
//		motionFromLastEvent(with:nsEvent)
//		spinNUp(with:nsEvent)
//		mouseWasDragged 		= true		// drag cancels pic
//		fwScene?.updateCameraRotator(for:"Other mouseDragged")
//	}
//	override func otherMouseUp(with nsEvent:NSEvent) {
//		motionFromLastEvent(with:nsEvent)
//		fwScene?.updateCameraRotator(for:"Other mouseUp", overTime:duration)
//		print("camera = [\(fwScene!.ppCam())]")
//		//at("All", 3, print("camera = [\(fwScene!.ppCam())]"))
//		atEve(9, print("\(fwScene!.cameraNode.transform.pp(.tree)))"))
//	}
//
//	 //  ====== CENTER SCROLL WHEEL ======
//	override func scrollWheel(with nsEvent:NSEvent) {
//		let d					= CGFloat(nsEvent.deltaY)
//		let delta : CGFloat		= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
//		fwScene?.cameraZoom		*= delta
//		fwScene?.updateCameraRotator(for:"Scroll Wheel")
//	}

	 // MARK: - 13.4 Mouse Variables
	func motionFromLastEvent(with nsEvent:NSEvent) {
bug//		let delt2d :CGPoint		= convert(nsEvent.locationInWindow, from: nil)//nil=screen
//		// convert(_ point: NSPoint, from view: NSView?) -> NSPoint
//
//		let eventPosn			= SCNVector3(delt2d.x, delt2d.y, 0)		// BAD: unprojectPoint(
//		 // Movement since last
//		let prevPosn : SCNVector3 = lastPosition ?? eventPosn
//		deltaPosition			= eventPosn - prevPosn
//		lastPosition			= eventPosn
	}

	var lastPosition : SCNVector3? = nil				// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	func spinNUp(delta:CGPoint) {
bug
//		fwScene!.cameraPoleSpin	 -= deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
//		fwScene!.cameraHorizonUp += deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
	}
//
//	 // MARK: - 13.3 TOUCHPAD Enters
//	// ///////////////////////////////////////
//	//
//	//			TTTTT  OO  U  U  CC  H  H PPP   AA  DDD
//	//			  T   O  O U  U C  C H  H P  P A  A D  D
//	//			  T   O  O U  U C    HHHH PPP  AAAA D  D
//	//			  T   O  O U  U C  C H  H P    A  A D  D
//	//			  T    OO   UU   CC  H  H P    A  A DDD
//	//
//	// //////////////////////////////////////
//	override func touchesBegan(with event:NSEvent) {
//		let t 					= event.touches(matching:.began, in:self)
//		for touch in t {
//			let _:CGPoint		= touch.location(in:nil)
//		}
//	}
//	override func touchesMoved(with event:NSEvent) {
//		let t 					= event.touches(matching:.began, in:self)
//		for touch in t {
//			let prevLoc			= touch.previousLocation(in:nil)
//			let loc				= touch.location(in:nil)
//			atEve(3, (print("\(prevLoc) \(loc)")))
////			let prevKey			= soloKeyboard?.keyAt(point:prevLoc)
////			let key				= soloKeyboard?.keyAt(point:loc)
////			key?.curPoint		= loc
//		}
//	}
//	override func touchesEnded(with event:NSEvent) {
//		let t 					= event.touches(matching:.began, in:self)
//		for touch in t {
//			let _:CGPoint		= touch.location(in:nil)
//		}
//	}
//	 // MARK: - 13.4 First Responder
//			 func acceptsFirstResponder()	-> Bool	{	return true				}
//	 // MARK: - 15. PrettyPrint
//	 // MARK: - 17. Debugging Aids
//	override func  becomeFirstResponder()	-> Bool	{	return true				}
//	override func validateProposedFirstResponder(_ responder: NSResponder,
//					   for event: NSEvent?) -> Bool {	return true				}
//	override func resignFirstResponder()	-> Bool	{	return true				}
//}
//
//
//
//// REFERENCES: https://github.com/ManuW/SceneKit-Swift-Moving-Objects
////class GameView: SCNView {
////
////	var mark : SCNNode? = nil
////	var selection : SCNHitTestResult? = nil
////	var hitOld = SCNVector3Zero
////
////	// mark an object (= selection)
////	override func mouseDown(theEvent: NSEvent) {
////
////		let p = self.convertPoint(theEvent.locationInWindow, fromVew: nil)
////		let options = [SCNHitTestSortResultsKey : NSNumber(bool: true), SCNHitTestBoundingBoxOnlyKey : NSNumber(bool: true)]
////
////		if let hitResults 		= self.hitTest(p, options: options) {
////
////			if (hitResults.count > 0){
////				let result: AnyObject = hitResults[0]
////				if  result is SCNHitTestResult {
////					selection 	= result as? SCNHitTestResult
////				}
////			}
////		}
////		super.mouseDown(theEvent)
////	}
////	// if there is a marked object, clone it and move it
////	override func mouseDragged(theEvent: NSEvent) {
////		if selection != nil {
////			let mouse			= self.convertPoint(theEvent.locationInWindow, fromVew: self)
////			var unPoint			= unprojectPoint(SCNVector3(x: mouse.x, y: mouse.y, z: 0.0))
////			let p1				= selection!.node.parentNode!.localPosition(of:unPoint, inSubVew:nil)
////			unPoint = unprojectPoint(SCNVector3(x: mouse.x, y: mouse.y, z: 1.0))
////			let p2				= selection!.node.parentNode!.localPosition(of:unPoint, inSubVew:nil)
////			let m				= p2 - p1
////
////			let e				= selection!.localCoordinates
////			let n				= selection!.localNormal
////
////			let t				= ((e * n) - (p1 * n)) / (m * n)
////			var hit				= SCNVector3(x: p1.x + t * m.x, y: p1.y + t * m.y, z: p1.z + t * m.z)
////			let offset			= hit - hitOld
////			hitOld				= hit
////			if mark != nil {
////				mark!.position = mark!.position + offset
////			} else {
////				mark 			= selection!.node.clone() as? SCNNode
////				mark!.opacity 	= 0.333
////				mark!.position 	= selection!.node.position
////				selection!.node.parentNode!.addChildNode(mark!)
////			}
////		}else{
////			super.mouseDragged(theEvent)
////		}
////	}
////	//   when the mouse button is released
////	// + an object was marked
////	// + the CRTL button is pressed
////	// = copy the object (means: don't remove the cloned object)
////	override func mouseUp(theEvent: NSEvent) {
////		if selection != nil {
////			if theEvent.modifierFlags == NSEventModifierFlags.ControlKeyMask {
////				mark!.opacity 	= 1.0
////			} else {
////				selection!.node.position = selection!.node.localPosition(of:mark!.position, inSubVew:selection!.node)
////				mark!.removeFromParent()
////			}
////	//		selection 			= nil
////			mark = nil
////		} else {
////			super.mouseUp(theEvent)
////		}
////	}
}
