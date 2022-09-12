//  FwView.swift -- A 2D NSView which displays a 3D FwScene
/// Key, Mouse, and Touch Events; mouse rotator, mouse pic, ...

import SceneKit
import SwiftUI

class FwView : SCNView, SCNSceneRendererDelegate {
	 // MARK: - 2. Object Variables:
	 //\\\///\\\///\\\  Our super, SCNView, conforms to SCNSceneRenderer:
	 //\\\				Therefore we have
	 //\\\ 	  .sceneTime					-
	 //\\\ 	  .autoenablesDefaultLighting	-
	 //\\\ 	  .hitTest:options:				***
	 //\\\ 	  .audioListener				***
	 //\\\ 	  .pointOfView					?
	 //\\\ 	  .projectPoint:unprojectPoint: ?
	 //\\\ 	  .delegate						***
	 //\\\ SCNView.scene		same as fwScene:
//	var fwScene : FwScene? {
//		get 		{		DOCfwScene										}
//		set(v)		{		if var doc = DOC, let val = v {
//								doc.docState.fwScene = val					}
//					}
//	}
	 // MARK: - 3. Factory
	override init(frame:CGRect, options:[String : Any]? = nil) {

		super.init(frame:frame, options:options) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		atCon(6, logd("initXXX:        FwView/\(ppUid(self)):()"))		// <\(pp(.uidClass))>

		showsStatistics 		= true			// doesn't work here
		isPlaying/*animations*/	= true			// works here?
		debugOptions = [
			SCNDebugOptions.showBoundingBoxes,	//Display the bounding boxes for any nodes with content.
			SCNDebugOptions.showWireframe,		//Display geometries in the scene with wireframe rendering.
			SCNDebugOptions.renderAsWireframe,	//Display only wireframe placeholders for geometries in the scene.
			SCNDebugOptions.showSkeletons,		//Display visualizations of the skeletal animation parameters for relevant geometries.
			SCNDebugOptions.showCreases,		//Display nonsmoothed crease regions for geometries affected by surface subdivision.
			SCNDebugOptions.showConstraints,	//Display visualizations of the constraint objects acting on nodes in the scene.
				// Cameras and Lighting
			SCNDebugOptions.showCameras,		//Display visualizations for nodes in the scene with attached cameras and their fields of view.
			SCNDebugOptions.showLightInfluences,//Display the locations of each SCNLight object in the scene.
			SCNDebugOptions.showLightExtents,	//Display the regions affected by each SCNLight object in the scene.
				// Debugging Physicsfa
			SCNDebugOptions.showPhysicsShapes,	//Display the physics shapes for any nodes with attached SCNPhysicsBody objects.
			SCNDebugOptions.showPhysicsFields,	//Display the regions affected by each SCNPhysicsField object in the scene.
		]
		allowsCameraControl 	= false			// dare to turn it on?
		autoenablesDefaultLighting = false		// dare to turn it on?
	}


	 // MARK: - 3.5 Codable
	required init?(coder decoder: NSCoder) {
		super.init(coder:decoder) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
//	 // MARK: - 3.6 NSCopying
//	func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : FwView	= FwView(frame:CGRect(x: 100, y: 200, width: 300, height: 400))//super.copy(with:zone) as! FwView
//	//	theCopy.con				= self.con
//		atSer(3, logd("copy(with as? FwView       ''"))
//		return theCopy
//	}

//	 // MARK: - 3.7 Equitable
//	func varsOfFwViewEq(_ rhs:Part) -> Bool {
//		guard let rhsAsFwView	= rhs as? FwView else {		return false		}
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
//		  true {//doc.processKey(from:nsEvent, inVew:nil) == false {
//
//			if character != "?" {	// okay for "?" to get here
//				atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
//			}
//		}
//	}
//	override func keyUp(with nsEvent:NSEvent) {
//		assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
//		isAutoRepeat 		= false
//		let _ 				= true //DOC?.processKey(from:nsEvent, inVew:nil)
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
//	override func mouseDown(with nsEvent:NSEvent) {
//bug;	motionFromLastEvent(with:nsEvent)
//		if !nsTrackPad  {					// 3-button Mouse
//			let _				= true //fwScene?.modelPic(with:nsEvent)
//		}
//		fwScene?.updateCameraRotator(for:"Left mouseDown", overTime:duration)
//	}
//	override func mouseDragged(with nsEvent:NSEvent) {
//bug;	if nsTrackPad  {					// Trackpad
//			motionFromLastEvent(with:nsEvent)
//			mouseWasDragged 	= true		// drag cancels pic
//			spinNUp(with:nsEvent)			// change Spin and Up of camera
//			fwScene?.updateCameraRotator(for:"Left mouseDragged")
//		}
//	}
//	override func mouseUp(with nsEvent:NSEvent) {
//bug;	if nsTrackPad  {					// Trackpad
//			motionFromLastEvent(with:nsEvent)
//			if !mouseWasDragged {			// UnDragged Up
//				bug//let _			= fwScene?.modelPic(with:nsEvent)
//			}
//			mouseWasDragged 	= false
//			fwScene?.updateCameraRotator(for:"Left mouseUp", overTime:duration)
//		}
//	}
////	 //  ====== RIGHT MOUSE ======			Right Mouse not used
//	 //  ====== CENTER MOUSE ======
//	override func otherMouseDown(with nsEvent:NSEvent)	{
//bug;	motionFromLastEvent(with:nsEvent)
//		fwScene?.updateCameraRotator(for:"Other mouseDown", overTime:duration)
//	}
//	override func otherMouseDragged(with nsEvent:NSEvent) {
//bug;	motionFromLastEvent(with:nsEvent)
//		spinNUp(with:nsEvent)
//		mouseWasDragged 		= true		// drag cancels pic
//		fwScene?.updateCameraRotator(for:"Other mouseDragged")
//	}
//	override func otherMouseUp(with nsEvent:NSEvent) {
//bug;	motionFromLastEvent(with:nsEvent)
//		fwScene?.updateCameraRotator(for:"Other mouseUp", overTime:duration)
//		print("camera = [\(fwScene!.ppCam())]")
//		//at("All", 3, print("camera = [\(fwScene!.ppCam())]"))
//		atEve(9, print("\(fwScene!.cameraNode.transform.pp(.tree)))"))
//	}
//
//	 //  ====== CENTER SCROLL WHEEL ======
//	override func scrollWheel(with nsEvent:NSEvent) {
//bug;	let d					= CGFloat(nsEvent.deltaY)
//		let delta : CGFloat		= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
//		fwScene?.cameraZoom		*= delta
//		fwScene?.updateCameraRotator(for:"Scroll Wheel")
//	}

//	 // MARK: - 13.4 Mouse Variables
//	func motionFromLastEvent(with nsEvent:NSEvent) {
//		let delt2d :CGPoint		= convert(nsEvent.locationInWindow, from: nil)//nil=screen
//		// convert(_ point: NSPoint, from view: NSView?) -> NSPoint
//
//		let eventPosn			= SCNVector3(delt2d.x, delt2d.y, 0)		// BAD: unprojectPoint(
//		 // Movement since last
//		let prevPosn : SCNVector3 = lastPosition ?? eventPosn
//		deltaPosition			= eventPosn - prevPosn
//		lastPosition			= eventPosn
//	}
//
//	var lastPosition : SCNVector3? = nil				// spot cursor hit
//	var deltaPosition			= SCNVector3.zero

//	func spinNUp(with nsEvent:NSEvent) {
//		fwScene!.cameraPoleSpin	 -= deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
//		fwScene!.cameraHorizonUp += deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
//	}

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
//	//		let prevKey			= soloKeyboard?.keyAt(point:prevLoc)
//	//		let key				= soloKeyboard?.keyAt(point:loc)
//	//		key?.curPoint		= loc
//		}
//	}
//	override func touchesEnded(with event:NSEvent) {
//		let t 					= event.touches(matching:.began, in:self)
//		for touch in t {
//			let _:CGPoint		= touch.location(in:nil)
//		}
//	}
	 // MARK: - 13.4 First Responder
			 func acceptsFirstResponder()	-> Bool	{	return true				}
	 // MARK: - 15. PrettyPrint
	 // MARK: - 17. Debugging Aids
	override func  becomeFirstResponder()	-> Bool	{	return true				}
	override func validateProposedFirstResponder(_ responder: NSResponder,
					   for event: NSEvent?) -> Bool {	return true				}
	override func resignFirstResponder()	-> Bool	{	return true				}
}

