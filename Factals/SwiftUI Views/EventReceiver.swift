//
//  EventReceiver.swift
//      Concept by Zev Eisenberg, repackaged for NSEvent capture by Allen King on 8/18/22.
//		Capture all event outputs, send them to
//
//	Usage Case:
//		ZStack {
//			 // This View goes underneath:
//			EventReceiver { 	nsEvent in processEvent(nsEvent:nsEvent) 		}
//			 // The View to have it's NSEvent's "stolen". E.g:
//			SceneView(...)
//		}

import SwiftUI

struct EventReceiver: NSViewRepresentable {
	let eventHandler:EventHandlerType.EventHandler
	func makeNSView(context:Context) -> EventReceiverView {
		return EventReceiverView(eventHandler:eventHandler)
	}
	func updateNSView(_ nsView:EventReceiverView, context:Context) {
	}
}
								
final class EventReceiverView : NSView {
	let eventHandler:EventHandlerType.EventHandler

	init(eventHandler: @escaping EventHandlerType.EventHandler) {
		self.eventHandler		= eventHandler
		super.init(frame:.zero)
	}
	@available(*, unavailable) required init?(coder aDecoder: NSCoder) {
		debugger("init(coder:) has not been implemented")
	}

	 // Make self first responder to receive key press events
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		window?.makeFirstResponder(self)
	}
	override var acceptsFirstResponder: Bool { true 							}


	  // Intercept these messages to this NSView
	 // MARK: - 13.1 Keys
	override func keyDown(with 			event:NSEvent) 		{	eventHandler(event)	}
	override func keyUp(with 			event:NSEvent) 		{	eventHandler(event)	}
	 // MARK: - 13.2 Mouse
	 //  ====== LEFT MOUSE ======
	override func mouseDown(with 		event:NSEvent)		{	eventHandler(event)	}
	override func mouseDragged(with 	event:NSEvent)		{	eventHandler(event)	}
	override func mouseUp(with 			event:NSEvent)		{	eventHandler(event)	}
	 //  ====== CENTER MOUSE ======
	override func otherMouseDown(with 	event:NSEvent)		{	eventHandler(event)	}
	override func otherMouseDragged(with vent:NSEvent)		{	eventHandler( vent)	}
	override func otherMouseUp(with 	event:NSEvent)		{	eventHandler(event)	}
	 //  ====== CENTER SCROLL WHEEL ======
	override func scrollWheel(with 		event:NSEvent) 		{	eventHandler(event)	}
	//override func scrollWheel(with		event:NSEvent)		{	eventHandler(event)
	//	super.scrollWheel(with: event)  // Let system handle scrolling too
	//}
	 //  ====== RIGHT MOUSE ======			Right Mouse not used
	override func rightMouseDown(with 	event:NSEvent) 		{	eventHandler(event)	}
	override func rightMouseDragged(with event:NSEvent) 	{	eventHandler(event)	}
	override func rightMouseUp(with 	event:NSEvent) 		{	eventHandler(event)	}
	 // MARK: - 13.3 TOUCHPAD Enters
	override func touchesBegan(with 	event:NSEvent)		{	eventHandler(event)	}
	override func touchesMoved(with 	event:NSEvent)		{	eventHandler(event)	}
	override func touchesEnded(with 	event:NSEvent)		{	eventHandler(event)	}

	 // MARK: - 15. PrettyPrint
	 // MARK: - 17. Debugging Aids
	override func becomeFirstResponder()	-> Bool	{	return true				}
	override func validateProposedFirstResponder(_ responder: NSResponder,
					   for event: NSEvent?) -> Bool {	return true				}
	override func resignFirstResponder()	-> Bool	{	return true				}
}


