////
////  KeyPressView.swift
////  FooDocTry3
////
////  Created by Zev, sent to Allen King on 8/18/22.
////
import SwiftUI

enum KeyPressCharacter {
	case up, down, left, right
	case delete, space
	case next, previous, firstBlank			// Note: not really a key press
	case character(_:Character)
}
enum GameAction  {							//: String, RawRepresentable typealias RawValue = NSView 	//
	case movement(_ : KeyPressCharacter)	// .up, .down, .left, .right,  NSLayoutConstraint.Attribute)
	case textChange(_:KeyPressCharacter)	// .delete, .space, .character(characters.uppercased())
	case jump(direction:KeyPressCharacter, mode:KeyPressCharacter)
}

struct KeyPressReceiver: NSViewRepresentable {									//	typealias NSViewType = NSView
	let handler: (GameAction) -> Void

	func makeNSView(context:Context) -> KeyPressView {
		KeyPressView(handler: handler)
	}
	func updateNSView(_ nsView: KeyPressView, context: Context) {
	}
}

final class KeyPressView: NSView {
	let handler: (GameAction) -> Void

	init(handler: @escaping (GameAction) -> Void) {
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
		let characters			= nsEvent.charactersIgnoringModifiers ?? " "
		let event : GameAction

		switch characters {

		 // Directions
		case String(Character(UnicodeScalar(NSUpArrowFunctionKey)!)):
			event 				= .movement(.up)
		case String(Character(UnicodeScalar(NSDownArrowFunctionKey)!)):
			event 				= .movement(.down)
		case String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)):
			event 				= .movement(.left)
		case String(Character(UnicodeScalar(NSRightArrowFunctionKey)!)):
			event 				= .movement(.right)

		case String(Character(UnicodeScalar(NSTabCharacter)!)):
			event 				= .jump(direction:.next, mode: .firstBlank)
		case String(Character(UnicodeScalar(NSBackTabCharacter)!)):
			event 				= .jump(direction:.previous, mode: .firstBlank)

		 // Character changes
		case String(Character(UnicodeScalar(NSDeleteCharacter)!)):
			event 				= .textChange(.delete)
		case " ":
			event 				= .textChange(.space)
		default:
			let char			= characters.count==0 ? "X" : Character(characters[0...0])
			event 				= .textChange(.character(char))
		}
		handler(event)
		// Don't call super, or we'll get the system beep
	}

}
