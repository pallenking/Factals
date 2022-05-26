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
	var scene: SCNScene

	//private static let onlyScene = true
	static var readableContentTypes: [UTType] { [.sceneKitScene] }
																				//	static var readableContentTypes: [UTType] { [.exampleText] }
	init(configuration: ReadConfiguration) throws {
		let wrapper:FileWrapper	= configuration.file
		let data : Data? 		= wrapper.regularFileContents
		if let data 			= data {
			let s		 		= SCNScene(data: data, encoding: .utf8)
			self.init(scene:s)
		}
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
	}
//			let s		 		= String(data: data, encoding: .utf8)
		//	print("ERROR FileDocument(configuration:) finds '\(s)'. Generating NULL document")
		//	let sScene			= SCNScene()									//named:"art.scnassets/ship.scn")!//(data: data, encoding: .utf8)
		//	let sScene			= SCNScene(rawValue:s)
		//	let sScene			= SCNScene(named:"art.scnassets/ship.scn")!
		//	let sScene			= SCNScene(data: data, encoding: .utf8)

	init(scene scene_:SCNScene? = dragonCurve(segments:1024)) {
		scene					= scene_!
		scene.groomScene()
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		return .init(regularFileWithContents:scene.data!)
	}
}

