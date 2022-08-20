//
//  KeyPressView.swift
//      Concept by Zev Eisenberg, repackaged for NSEvent capture by Allen King on 8/18/22.
//
//	Usage Case:
//	ZStack {
//		NSEventReceiverView { 	nsEvent in receivedEvent(nsEvent:nsEvent) 		}
//		 // Another A SwiftUI view, to have it's NSEvent's "stolen". E.g:
//		SceneView(scene:..., pointOfView:..., options:[], ...)
//	}

import SwiftUI

struct NSEventReceiverView: NSViewRepresentable {									//	typealias NSViewType = NSView
	let handler: (NSEvent) -> Void

	func makeNSView(context:Context) -> KeyPressView {
		KeyPressView(handler: handler)
	}
	func updateNSView(_ nsView: KeyPressView, context: Context) {
	}
}

final class KeyPressView: NSView {
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

	override func keyDown(with nsEvent: NSEvent) {
		handler(nsEvent)
	}	// Don't call super, or we'll get the system beep

	 // Add methods like this
	//override func mouseDown(with nsEvent:NSEvent) {  	handler(nsEvent)		}
}
