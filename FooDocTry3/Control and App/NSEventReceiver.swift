//
//  NSEventReceiver.swift
//      Concept by Zev Eisenberg, repackaged for NSEvent capture by Allen King on 8/18/22.
//
//	Usage Case:
//		ZStack {
//			 // This View goes underneath:
//			NSEventReceiver { 	nsEvent in receivedEvent(nsEvent:nsEvent) 		}
//			 // The View to have it's NSEvent's "stolen". E.g:
//			SceneView(scene:..., pointOfView:..., options:[], ...)
//		}

import SwiftUI

struct NSEventReceiver: NSViewRepresentable {
	let handler: (NSEvent) -> Void

	func makeNSView(context:Context) -> NSEventReceiverView {
		NSEventReceiverView(handler: handler)
	}
	func updateNSView(_ nsView: NSEventReceiverView, context: Context) {
	}
}

final class NSEventReceiverView: NSView {
	let handler: (NSEvent) -> Void

	init(handler: @escaping (NSEvent) -> Void) {
		self.handler = handler
		super.init(frame: .zero)
	}

	@available(*, unavailable) required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	 // Make self first responder to receive key press events
	override func viewDidMoveToWindow() {	        super.viewDidMoveToWindow()
		window?.makeFirstResponder(self)
	}
	override var acceptsFirstResponder: Bool { true 							}

	 // Capture first responder messages ///////////////////////////////////////
	override func keyDown(with nsEvent: NSEvent) {
		handler(nsEvent)
	}	// Don't call super, or we'll get the system beep

	override func scrollWheel(with nsEvent:NSEvent) {
		handler(nsEvent)
	}

	 // Add methods like this
	//override func mouseDown(with nsEvent:NSEvent) {  	handler(nsEvent)		}
}
