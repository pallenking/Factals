//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers													//extension UTType {
																				//	static var exampleText: UTType { UTType(importedAs: "com.example.plain-text") }
																				//}
struct FooDocTry3Document: FileDocument {			// not NSDocument!!

	//private static let onlyScene = true
	static var readableContentTypes: [UTType] { [.sceneKitScene] }

	 // Model of a FooDocTry3Document:
	var scene: SCNScene
																				//	static var readableContentTypes: [UTType] { [.exampleText] }
	init(configuration: ReadConfiguration) throws {
		let wrapper:FileWrapper	= configuration.file
		let data : Data? 		= wrapper.regularFileContents
		if let data 			= data	// If non-nil
		{									// data -> SCNScene:
			let s : SCNScene?	= SCNScene(data: data, encoding: .utf8)
			self.init(scene:s)				// -> FooDocTry3Document
		}
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
	}

	init(scene scene_:SCNScene? = dragonCurve(segments:1024)) {
		scene					= scene_!
		scene.groomScene()
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		return .init(regularFileWithContents:scene.data!)
	}
}

