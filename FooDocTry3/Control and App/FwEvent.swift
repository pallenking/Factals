//
//  FwEvent.swift
//  FooDocTry3
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

class FwEvent {							// NOT NSObject
	let fwType : FwType

	let	nsType : Int 			= 999
		// As defined in NSEvent.NSEventType:
		//NSLeftMouseUp 		NSRightMouseDown 	NSRightMouseUp NSMouseMoved
		//NSLeftMouseDragged	NSRightMouseDragged
		//NSMouseEntered 		NSMouseExited
		//NSKeyDown 			NSKeyUp 			NSFlagsChanged (deleted PAK170906)
		//NSPeriodic 			NSCursorUpdate		NSScrollNSTablet 	NSTablet
		//NSOtherMouse 			NSOtherMouseUp		NSOtherMouseDragged
		//NSEventTypeGesture	NSEventTypeMagnify	NSEventTypeSwipe 	NSEventTypeRotate
		//NSEventTypeBeginGesture NSEventTypeEndGesture NSEventTypeSmartMagnify NSEventTypeQuickLook
	var clicks	   : Int		= 0		// 1, 2, 3?
	var key			: Character = " "
	var modifierFlags: Int64	= 0
		// As defined in NSEvent.modifierFlags:
		// NSAlphaShiftKeyMask 	NSShiftKeyMask 		NSControlKeyMask 	NSAlternateKeyMask
		// NSCommandKeyMask 	NSNumericPadKeyMask NSHelpKeyMask 		NSFunctionKeyMask
	var mousePosition:SCNVector3 = .zero	// after[self convertPoint:[theEvent locationInWindow] fromVew:nil]
	var deltaPosition:SCNVector3 = .zero	// since last time
	var deltaPercent :SCNVector3 = .zero	// since last time, in percent of screen
	var scrollWheelDelta		= 0.0

	init(fwType f:FwType) {
		fwType 					= f
	}
}

class EventCentral : NSObject, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
	var fwGuts : FwGuts!

	override init() {
		super.init()
	}
	func reconfigureWith(config:FwConfig) {
	}

// /////////////////////////////////////////////////////////////////////////////
// ///////////////////  SCNSceneRendererDelegate:  /////////////////////////////
// /////////////////////////////////////////////////////////////////////////////
  // called by SCNSceneRenderer

		// MARK: - SCNSceneRendererDelegate
	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("\n<><><> 9.5.1: Update At Time       -> updateVewSizePaint"))
			if let f			= self.fwGuts {

				f.lockBoth("updateAtTime")
				f.rootVew.updateVewSizePaint(needsLock:"renderLoop", logIf:false)		//false//true
				f.unlockBoth("updateAtTime")
			}
			else { fatalError("renderer(_ r:SCNSceneRenderer, updateAtTime")	}
		}
	}
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
			if let f			= self.fwGuts {
				f.lockBoth("didApplyAnimationsAtTime")
				f.rootPart.computeLinkForces(vew:DOCfwGuts.rootVew)
				f.unlockBoth("didApplyAnimationsAtTime")
			}
			else { fatalError("renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime")	}
		}
	}
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
			if let f			= self.fwGuts {
				f.lockBoth("didSimulatePhysicsAtTime")
				f.rootPart.applyLinkForces(vew:DOCfwGuts.rootVew)
				f.unlockBoth("didSimulatePhysicsAtTime")
			}
		}
	}
	public func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			if let f			= self.fwGuts {
				f.lockBoth("willRenderScene")
				f.rootPart.rotateLinkSkins(vew:DOCfwGuts.rootVew)
				f.unlockBoth("willRenderScene")
			}
		}
	}
	   // ODD Timing:
	public func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.@: Scenes Rendered -- NOP"))
	}
	public func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
	}

// /////////////////////////////////////////////////////////////////////////////
// ///////////////////  SCNPhysicsContactDelegate:  ////////////////////////////
// /////////////////////////////////////////////////////////////////////////////

		// MARK: - SCNSceneRendererDelegate
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
	}
	func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
	}
	func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
	}

	 // MARK: - 13. IBActions
	var nextIsAutoRepeat : Bool = false 	// filter out AUTOREPEAT keys
	var mouseWasDragged			= false		// have dragging cancel pic

	func receivedEvent(nsEvent:NSEvent) {
		print("--- func received(nsEvent:\(nsEvent))")
		let nsTrackPad			= true//false//
		let duration			= Float(1)
		let fooDoc				= fwGuts.fooDocTry3Document

		switch nsEvent.type {

		  //  ====== KEYBOARD ======
		 //
		case .keyDown:
			if nsEvent.isARepeat {	return }			// Ignore repeats
			guard let char : String	= nsEvent.charactersIgnoringModifiers else { return }
			assert(char.count==1, "multiple keystrokes not supported")
			nextIsAutoRepeat 	= true
			if fooDoc?.processKey(from:nsEvent, inVew:nil) == false {
				if char != "?" {		// okay for "?" to get here
					atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
				}
			}
		case .keyUp:
			assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
			nextIsAutoRepeat 	= false
			let _				= fooDoc?.processKey(from:nsEvent, inVew:nil)

		  //  ====== LEFT MOUSE ======
		 //
		case .leftMouseDown:
			motionFromLastEvent(with:nsEvent)
			if !nsTrackPad  {					// 3-button Mouse
				let vew			= fwGuts.modelPic(with:nsEvent)
			}
			fwGuts.fwScn.updatePole2Camera(duration:duration, reason:"Left mouseDown")
		case .leftMouseDragged:	// override func mouseDragged(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				mouseWasDragged = true		// drag cancels pic
				spinNUp(with:nsEvent)			// change Spin and Up of camera
				fwGuts.fwScn.updatePole2Camera(reason:"Left mouseDragged")
			}
		case .leftMouseUp:	// override func mouseUp(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				if !mouseWasDragged {			// UnDragged Up
					if let vew	= fwGuts.modelPic(with:nsEvent) {
						rootVew.lookAtVew	= vew			// found a Vew: Look at it!
					}
				}
				mouseWasDragged = false
				fwGuts.fwScn.updatePole2Camera(duration:duration, reason:"Left mouseUp")
			}

		  //  ====== CENTER MOUSE (scroll wheel) ======
		 //
		case .otherMouseDown:	// override func otherMouseDown(with nsEvent:NSEvent)	{
			motionFromLastEvent(with:nsEvent)
			fwGuts.fwScn.updatePole2Camera(duration:duration, reason:"Other mouseDown")
		case .otherMouseDragged:	// override func otherMouseDragged(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			spinNUp(with:nsEvent)
			fwGuts.fwScn.updatePole2Camera(reason:"Other mouseDragged")
		case .otherMouseUp:	// override func otherMouseUp(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			fwGuts.fwScn.updatePole2Camera(duration:duration, reason:"Other mouseUp")
			atEve(9, print("\(fwGuts.fwScn.scnScene.cameraScn?.transform.pp(.tree) ?? "cameraScn is nil")"))

		  //  ====== CENTER SCROLL WHEEL ======
		 //
		case .scrollWheel:
			let d				= nsEvent.deltaY
			let delta : CGFloat	= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
			rootVew.lastSelfiePole.zoom *= delta
//			let scene			= DOCfwGuts
//			scene.lastSelfiePole.zoom *= delta
			print("receivedEvent(type:.scrollWheel) found pole\(rootVew.lastSelfiePole.uid).zoom = \(rootVew.lastSelfiePole.zoom)")
			fwGuts.fwScn.updatePole2Camera(reason:"Scroll Wheel")

		  //  ====== RIGHT MOUSE ======			Right Mouse not used
		 //
		case .rightMouseDown:	bug
		case .rightMouseDragged:bug
		case .rightMouseUp:		bug

		  //  ====== TOUCH PAD ====== (no touchesBegan, touchesMoved, touchesEnded)
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
			let t 				= nsEvent.touches(matching:.began, in:fwGuts.fwScn.scnView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		case .mouseMoved:		bug
			let t 				= nsEvent.touches(matching:.moved, in:fwGuts.fwScn.scnView)
			for touch in t {
				let prevLoc		= touch.previousLocation(in:nil)
				let loc			= touch.location(in:nil)
				atEve(3, (print("\(prevLoc) \(loc)")))
			}
		case .endGesture:	//override func touchesEnded(with event:NSEvent) {
			let t 				= nsEvent.touches(matching:.ended, in:fwGuts.fwScn.scnView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		default:
			print("33333333 receivedEvent(type:\(nsEvent.type)) EEEEEEE")
		}
	}
	 // MARK: - 13.4 Mouse Variables
	func motionFromLastEvent(with nsEvent:NSEvent) {
		if let view				= nsEvent.window?.contentView {
			let delt2d :CGPoint	= view.convert(nsEvent.locationInWindow, from: nil)//nil=screen
			// convert(_ point: NSPoint, from view: NSView?) -> NSPoint

			let eventPosn		= SCNVector3(delt2d.x, delt2d.y, 0)		// BAD: unprojectPoint(
			 // Movement since last
			let prevPosn : SCNVector3 = lastPosition ?? eventPosn
			deltaPosition		= eventPosn - prevPosn
			lastPosition		= eventPosn
		}
	}
	var lastPosition : SCNVector3? = nil				// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	func spinNUp(with nsEvent:NSEvent) {
		rootVew.lastSelfiePole.spin		 -= deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
		rootVew.lastSelfiePole.horizonUp -= deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		return "EventCentral:\(ppUid(self))"
	}
}
