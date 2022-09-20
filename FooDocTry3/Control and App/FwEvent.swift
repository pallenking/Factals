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
