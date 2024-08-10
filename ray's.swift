import SwiftUI
import PlaygroundSupport
struct V: UIViewRepresentable {
  @Binding var text: String
  func makeUIView(context: Context) -> some UIView {
    let view = UITextField()
    view.addAction(UIAction { [weak view] action in
      text = view?.text ?? ""
    }, for: .editingChanged)
    view.text = text
    return view
  }
  func updateUIView(_ uiView: UIViewType, context: Context) {
    (uiView as! UITextField).text = text
  }
}
struct W: View {
  @State var text = "hello"
  var body: some View {
    VStack {
      Text(text).foregroundStyle(.red)
      Button("Reset") { text = "hello"}
      V(text: $text)
    }
    .font(.largeTitle)
  }
}
PlaygroundPage.current.setLiveView(W())
\

