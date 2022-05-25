//
//  FooDocTry3App.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI

@main
struct FooDocTry3App: App {
	var body: some Scene {
		DocumentGroup(newDocument: FooDocTry3Document()) { file in
			ContentView(document: file.$document)
		}
	}
}
