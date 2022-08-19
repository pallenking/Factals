////
////  KeyPressView.swift
////  FooDocTry3
////
////  Created by Zev, sent to Allen King on 8/18/22.
////
import SwiftUI

struct KeyPressReceiver: NSViewRepresentable {									//	typealias NSViewType = NSView
	let handler: (Character) -> Void

	func makeNSView(context:Context) -> KeyPressView {
		KeyPressView(handler: handler)
	}
	func updateNSView(_ nsView: KeyPressView, context: Context) {
	}
}

final class KeyPressView: NSView {
	let handler: (Character) -> Void

	init(handler: @escaping (Character) -> Void) {
		self.handler = handler
		super.init(frame: .zero)
	}

	@available(*, unavailable) required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidMoveToWindow() {	        super.viewDidMoveToWindow()
		// Make self first responder to receive key press events
		window?.makeFirstResponder(self)
	}

	override var acceptsFirstResponder: Bool { true }

	override func keyDown(with nsEvent: NSEvent) {
		let characters			= nsEvent.charactersIgnoringModifiers ?? "X"
		let event : Character	= characters.count==0 ? "X" : Character(characters[0...0])
		handler(event)
		// Don't call super, or we'll get the system beep
	}
//	override func mouseDown(with nsEvent:NSEvent) {
//		print("func mouseDown(with:NsEvent")
//	}
}
