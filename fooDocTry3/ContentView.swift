//
//  ContentView.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: fooDocTry3Document

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(fooDocTry3Document()))
    }
}
