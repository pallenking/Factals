//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

var defaultScene : SCNScene		=
//	dragonCurve(segments:1024)
	aRootVew()

struct FooDocTry3Document: FileDocument {			// not NSDocument!!

	 // Model of a FooDocTry3Document:
	var scene: SCNScene

	init(scene scene_:SCNScene? = defaultScene) {
		scene					= scene_!
		scene.groomScene()
	}

/* ============== BEGIN FileDocument protocol: */
	static	 var readableContentTypes: [UTType] { [.sceneKitScene] }
	//https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
    //static var writableContentTypes: [UTType] { get }
	//private static let onlyScene = true
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
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		return .init(regularFileWithContents:scene.data!)
	}
}
//https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html
extension UTType {
	static var fooDocTry3: UTType { UTType(importedAs: "com.example.plain-text") }
//	static var exampleText: UTType { UTType(importedAs: "com.example.plain-text") }
}

/* ============== END FileDocument protocol: */
