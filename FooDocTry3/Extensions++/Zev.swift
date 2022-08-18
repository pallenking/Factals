////
////  Zev.swift
////  FooDocTry3
////
////  Created by Allen King on 8/18/22.
////
import Cocoa
//import PuzzleUI
import SwiftUI

struct KeyPressReceiver: NSViewRepresentable {
	func makeNSView(context: Context) -> NSView {
		bug
	}
	
	func updateNSView(_ nsView: NSView, context: Context) {
		bug
	}
	
	typealias NSViewType = NSView

    let handler: (GameAction) -> Void

    func makeNSView(context: Context) -> KeyPressView {
		KeyPressView(coder: handler) !
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

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Make self first responder to receive key press events
        window?.makeFirstResponder(self)
    }

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with nsEvent: NSEvent) {
        let event: GameAction
        let characters = nsEvent.charactersIgnoringModifiers ?? " "
        switch characters {
            // Directions

        case String(Character(UnicodeScalar(NSUpArrowFunctionKey)!)):
            event = .movement(.up)
        case String(Character(UnicodeScalar(NSDownArrowFunctionKey)!)):
            event = .movement(.down)
        case String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)):
            event = .movement(.left)
        case String(Character(UnicodeScalar(NSRightArrowFunctionKey)!)):
            event = .movement(.right)

        // Character changes
        case String(Character(UnicodeScalar(NSDeleteCharacter)!)):
            event = .textChange(.delete)
        case String(Character(UnicodeScalar(NSTabCharacter)!)):
            event = .jump(Jump(direction: .next, mode: .firstBlank))
        case String(Character(UnicodeScalar(NSBackTabCharacter)!)):
            event = .jump(Jump(direction: .previous, mode: .firstBlank))
        case " ":
            event = .textChange(.space)
        default:
            event = .textChange(.character(characters.uppercased()))
        }
        handler(event)
        // Don't call super, or we'll get the system beep
    }

}
