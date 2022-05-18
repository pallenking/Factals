//
//  fooDocTry3App.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI

@main
struct fooDocTry3App: App {
    var body: some Scene {
        DocumentGroup(newDocument: fooDocTry3Document()) { file in
            ContentView(document: file.$document)
        }
    }
}
