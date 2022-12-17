//
//  EventCentral.swift
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit
			// Remove NSObject?
class EventCentral : NSObject, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {	// NEVER NSCopying, Equatable

	weak // owner
	 var rootVew : RootVew!
	var  rootScn : RootScn		{	return rootVew!.rootScn						}

	override init() {
		super.init()
	}
	func pushControllersConfig(to c:FwConfig) {	/* nada */ }

// /////////////////////////////////////////////////////////////////////////////
// ///////////////////  SCNSceneRendererDelegate:  /////////////////////////////
// ////////////////////////////////////// called by SCNSceneRenderer ///////////
		// MARK: - SCNSceneRendererDelegate
	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("\n<><><> 9.5.1: Update At Time       -> updateVewSizePaint"))
			let rVew			= self.rootVew!
			rVew.lockBoth("updateAtTime")
			rVew.updateVewSizePaint(needsLock:"renderLoop", logIf:false)		//false//true
			rVew.unlockBoth("updateAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
			let rVew			= self.rootVew!
			rVew .lockBoth("didApplyAnimationsAtTime")
			rVew .part.computeLinkForces(vew:rVew)
			rVew .unlockBoth("didApplyAnimationsAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
			let rVew			= self.rootVew!
			rVew.lockBoth("didSimulatePhysicsAtTime")
			rVew.part.applyLinkForces(vew:rVew)
			rVew.unlockBoth("didSimulatePhysicsAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			let rVew			= self.rootVew!
			rVew.lockBoth("willRenderScene")
			rVew.part.rotateLinkSkins(vew:rVew)
			rVew.unlockBoth("willRenderScene")
		}
	}
	   // ODD Timing:
	func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.@: Scenes Rendered -- NOP"))
	}
	func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
	}

// /////////////////////////////////////////////////////////////////////////////
// ///////////////////  SCNPhysicsContactDelegate:  ////////////////////////////
// /////////////////////////////////////////////////////////////////////////////

		// MARK: - SCNPhysicsContactDelegate
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		bug
	}
	func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
		bug
	}
	func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
		bug
	}

	 // MARK: - 13. IBActions
	var nextIsAutoRepeat : Bool = false 	// filter out AUTOREPEAT keys
	var mouseWasDragged			= false		// have dragging cancel pic

	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) {
		let nsTrackPad			= trueF//falseF//
		let duration			= Float(1)
		guard let rootVew else { print("processEvent.rootVew[..] is nil"); return }
		let fwGuts				= rootVew.fwGuts		// why ! ??
		let rootScn				= rootVew.rootScn
		let cam					= rootScn.cameraScn

		switch nsEvent.type {

		  //  ====== KEYBOARD ======
		 //
		case .keyDown:
			if nsEvent.isARepeat {	return }			// Ignore repeats
			guard let char : String	= nsEvent.charactersIgnoringModifiers else { return }
			assert(char.count==1, "multiple keystrokes not supported")
			nextIsAutoRepeat 	= true
			if fwGuts != nil && fwGuts!.processEvent(nsEvent:nsEvent, inVew:nil) == false,
			  char != "?" {		// okay for "?" to get here
				atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
			}
		case .keyUp:
			assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
			nextIsAutoRepeat 	= false
			let _				= fwGuts != nil && fwGuts!.processEvent(nsEvent:nsEvent, inVew:nil)

		  //  ====== LEFT MOUSE ======
		 //
		case .leftMouseDown:
			motionFromLastEvent(with:nsEvent)
			if !nsTrackPad  {					// 3-button Mouse
				let vew			= fwGuts?.modelPic(with:nsEvent)
			}//
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Left mouseDown")
		case .leftMouseDragged:	// override func mouseDragged(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				mouseWasDragged = true			// drag cancels pic
				spinNUp(with:nsEvent)			// change Spin and Up of camera
				cam.transform 	= rootScn.cameraTransform(reason:"Left mouseDragged")
			}
		case .leftMouseUp:	// override func mouseUp(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				if !mouseWasDragged {			// UnDragged Up
					if let vew	= fwGuts?.modelPic(with:nsEvent) {
						rootScn.lookAtVew = vew			// found a Vew: Look at it!
					}
				}
				mouseWasDragged = false
				cam.transform 	= rootScn.cameraTransform(duration:duration, reason:"Left mouseUp")
			}

		  //  ====== CENTER MOUSE (scroll wheel) ======
		 //
		case .otherMouseDown:	// override func otherMouseDown(with nsEvent:NSEvent)	{
			motionFromLastEvent(with:nsEvent)
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Other mouseDown")
		case .otherMouseDragged:	// override func otherMouseDragged(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			spinNUp(with:nsEvent)
			cam.transform 		= rootScn.cameraTransform(reason:"Other mouseDragged")
		case .otherMouseUp:	// override func otherMouseUp(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Other mouseUp")
			atEve(9, print("\( cam.transform.pp(PpMode.tree))"))

		  //  ====== CENTER SCROLL WHEEL ======
		 //
		case .scrollWheel:
			let d				= nsEvent.deltaY
			let delta:CGFloat	= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
			rootScn.selfiePole.zoom *= delta
			let p				= rootScn.selfiePole
			print("processEvent(type:  .scrollWheel  ) found pole\(p.pp()).zoom = \(p.zoom)")
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Scroll Wheel")

		  //  ====== RIGHT MOUSE ======			Right Mouse not used
		 //
		case .rightMouseDown:	bug
		case .rightMouseDragged:bug
		case .rightMouseUp:		bug

		  //  ====== TOUCH PAD ======(no touchesBegan, touchesMoved, touchesEnded)
		case .magnify:			bug
		case .smartMagnify:		bug
		case .swipe:			bug
		case .rotate:			bug
		case .gesture:			bug
		case .directTouch:		bug
		case .tabletPoint:		bug
		case .tabletProximity:	bug
		case .pressure:			bug
		case .changeMode:		bug

		case .beginGesture:		// override func touchesBegan(with event:NSEvent) {
			let t 				= nsEvent.touches(matching:.began, in:rootScn.scnView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		case .mouseMoved:		bug
			let t 				= nsEvent.touches(matching:.moved, in:rootScn.scnView)
			for touch in t {
				let prevLoc		= touch.previousLocation(in:nil)
				let loc			= touch.location(in:nil)
				atEve(3, (print("\(prevLoc) \(loc)")))
			}
		case .endGesture:	//override func touchesEnded(with event:NSEvent) {
			let t 				= nsEvent.touches(matching:.ended, in:rootScn.scnView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		default:
			print("33333333 processEvent(type:\(nsEvent.type)) EEEEEEE")
		}
	}
	 // MARK: - 13.4 Mouse Variables
	func motionFromLastEvent(with nsEvent:NSEvent) {
		if let view				= nsEvent.window?.contentView {

			 // Ask event's view for point in screen coords
			let pScreen:CGPoint	= view.convert(nsEvent.locationInWindow, from: nil)//nil=screen
			let eventPosn		= SCNVector3(pScreen.x, pScreen.y, 0)		// BAD: unprojectPoint(

			 // Movement since last, 0 if first time and there is none
			deltaPosition		= lastPosition == nil ? SCNVector3.zero
								: eventPosn - lastPosition!
			lastPosition		= eventPosn
		}
	}
	var lastPosition : SCNVector3? = nil				// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	func spinNUp(with nsEvent:NSEvent) {
		//let rootVew  			= rootVew!
		rootScn.selfiePole.spin -= 		deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
		rootScn.selfiePole.horizonUp -= deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
	}
	 // MARK: - 14. Building
	var logger : Logger 		{	rootVew.fwGuts.logger								}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		logger.log(banner:banner, format_, args, terminator:terminator)
	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		return "EventCentral:\(ppUid(self))"
	}
	  // MARK: - 16. Global Constants
	static let null 			= EventCentral()		/// Any use of this _should_? fail
}
