//import Cocoa
//import PuzzleUI
//import SwiftUI
//
//struct KeyPressReceiver: NSViewRepresentable {
//
//    let handler: (GameAction) -> Void
//
//    func makeNSView(context: Context) -> KeyPressView {
//        KeyPressView(handler: handler)
//    }
//
//    func updateNSView(_ nsView: KeyPressView, context: Context) {
//    }
//}
//
//final class KeyPressView: NSView {
//
//    let handler: (GameAction) -> Void
//
//    init(handler: @escaping (GameAction) -> Void) {
//        self.handler = handler
//        super.init(frame: .zero)
//    }
//
//    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidMoveToWindow() {
//        super.viewDidMoveToWindow()
//        // Make self first responder to receive key press events
//        window?.makeFirstResponder(self)
//    }
//
//    override var acceptsFirstResponder: Bool { true }
//
//    override func keyDown(with nsEvent: NSEvent) {
//        let event: GameAction
//        let characters = nsEvent.charactersIgnoringModifiers ?? " "
//        switch characters {
//            // Directions
//
//        case String(Character(UnicodeScalar(NSUpArrowFunctionKey)!)):
//            event = .movement(.up)
//        case String(Character(UnicodeScalar(NSDownArrowFunctionKey)!)):
//            event = .movement(.down)
//        case String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)):
//            event = .movement(.left)
//        case String(Character(UnicodeScalar(NSRightArrowFunctionKey)!)):
//            event = .movement(.right)
//
//        // Character changes
//        case String(Character(UnicodeScalar(NSDeleteCharacter)!)):
//            event = .textChange(.delete)
//        case String(Character(UnicodeScalar(NSTabCharacter)!)):
//            event = .jump(Jump(direction: .next, mode: .firstBlank))
//        case String(Character(UnicodeScalar(NSBackTabCharacter)!)):
//            event = .jump(Jump(direction: .previous, mode: .firstBlank))
//        case " ":
//            event = .textChange(.space)
//        default:
//            event = .textChange(.character(characters.uppercased()))
//        }
//        handler(event)
//        // Don't call super, or we'll get the system beep
//    }
//
//}
//
//Collapse
//
//
//
//white_check_mark
//eyes
//raised_hands
//
//
//
//
//
//4:57
//:point_up::skin-tone-2:
//@Allen King
//
//
//
//
//class UserViaGui {
//	 // MARK: - 13.1 Keys
//	override func keyDown(with nsEvent:NSEvent)
//	override func keyUp(with nsEvent:NSEvent)
//	 // MARK: - 13.2 Mouse
//	//  ====== LEFT MOUSE ======
//	override func mouseDown(with nsEvent:NSEvent) {
//	override func mouseDragged(with nsEvent:NSEvent) {
//	override func mouseUp(with nsEvent:NSEvent) {
//	 //  ====== CENTER MOUSE ======
//	override func otherMouseDown(with nsEvent:NSEvent)	{
//	override func otherMouseDragged(with nsEvent:NSEvent) {
//	override func otherMouseUp(with nsEvent:NSEvent) {
//	 //  ====== CENTER SCROLL WHEEL ======
//	override func scrollWheel(with nsEvent:NSEvent) {
//}
