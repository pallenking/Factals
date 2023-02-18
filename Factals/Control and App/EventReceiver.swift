//
//  EventReceiver.swift
//      Concept by Zev Eisenberg, repackaged for NSEvent capture by Allen King on 8/18/22.
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
	let handler: (NSEvent) -> Void					// OUTSKI: --> SceneKitHostingView

	func makeNSView(context:Context) -> EventReceiverView {
		return EventReceiverView(handler: handler)
	}
	func updateNSView(_ nsView: EventReceiverView, context: Context) {
	}
}

final class EventReceiverView: NSView {				// OUTSKI: --> FwView
	let handler: (NSEvent) -> Void

	init(handler: @escaping (NSEvent) -> Void) {
//		self.handler	= { nsEvent in print("EventReceiverView's BOGUS handler")}
		self.handler = handler
		super.init(frame: .zero)
	}

	@available(*, unavailable) required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	 // Make self first responder to receive key press events
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		window?.makeFirstResponder(self)
	}
	override var acceptsFirstResponder: Bool { true 							}

// WANTED: override ALL first responder messages, PW10 One sub to handle these 35 lines?
//	func processEvent(nsEvent:NSEvent, inVew vew:Vew) {}
								//.onAppear(perform: {
								//	NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
								//		print("\(isOverContentView ? "Mouse inside ContentView" : "Not inside Content View") x: \(self.mouseLocation.x) y: \(self.mouseLocation.y)")
								//		return $0
								//	}
								//})
	 // MARK: - 13.1 Keys
	override func keyDown(with 			event:NSEvent) 		{	handler(event)	}
	override func keyUp(with 			event:NSEvent) 		{	handler(event)	}
	 // MARK: - 13.2 Mouse
	 //  ====== LEFT MOUSE ======
	override func mouseDown(with 		event:NSEvent)		{	handler(event)	}
	override func mouseDragged(with 	event:NSEvent)		{	handler(event)	}
	override func mouseUp(with 			event:NSEvent)		{	handler(event)	}
	 //  ====== CENTER MOUSE ======
	override func otherMouseDown(with 	event:NSEvent)		{	handler(event)	}
	override func otherMouseDragged(with event:NSEvent)		{	handler(event)	}
	override func otherMouseUp(with 	event:NSEvent)		{	handler(event)	}
	 //  ====== CENTER SCROLL WHEEL ======
	override func scrollWheel(with 		event:NSEvent) 		{	handler(event)	}
	 //  ====== RIGHT MOUSE ======			Right Mouse not used
/*override*/ func rightmouseDown(with 	event:NSEvent) 		{	handler(event)	}
/*override*/ func rightmouseDragged(with event:NSEvent) 	{	handler(event)	}
/*override*/ func rightmouseUp(with 	event:NSEvent) 		{	handler(event)	}
	 // MARK: - 13.3 TOUCHPAD Enters
	override func touchesBegan(with 	event:NSEvent)		{	handler(event)	}
	override func touchesMoved(with 	event:NSEvent)		{	handler(event)	}
	override func touchesEnded(with 	event:NSEvent)		{	handler(event)	}

	 // MARK: - 15. PrettyPrint
	 // MARK: - 17. Debugging Aids
	override func  becomeFirstResponder()	-> Bool	{	return true				}
	override func validateProposedFirstResponder(_ responder: NSResponder,
					   for event: NSEvent?) -> Bool {	return true				}
	override func resignFirstResponder()	-> Bool	{	return true				}
}


