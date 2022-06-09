//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

  // PlatformDocument.init() calls FooDocTry3Document.init() with NO args.
 // Here we declare its content:
var defaultSceneForNewDocument : SCNScene		{
//	dragonCurve(segments:1024)	// for testing
	aRootVew()					// future direction
}

struct FooDocTry3Document: FileDocument {			// not NSDocument!!

	 // Model of a FooDocTry3Document:
	var model : Part
	var vew	  : Vew
	var scene : SCNScene

	init(model:Part = Part(), scene:SCNScene = defaultSceneForNewDocument) {
		self.model 				= model
		self.scene				= scene
		vew	  					= Vew(forPart: model, scn: scene.rootNode)
		scene.groomScene()
	}

	/* ============== BEGIN FileDocument protocol: */
	static var readableContentTypes: [UTType] { [.fooDocTry3, .sceneKitScene] }
	static var writableContentTypes: [UTType] { [.fooDocTry3] }
	//private static let onlyScene = true
																				//	static var readableContentTypes: [UTType] { [.exampleText] }
	init(configuration: ReadConfiguration) throws {
/*	struct FileDocumentReadConfiguration (FileDocument: typealias ReadConfiguration = ~)
		let contentType : UTType		// The expected uniform type of the file contents.
		let existingFile: FileWrapper?	// The file wrapper containing the document content.
*/
		guard let data : Data 	= configuration.file.regularFileContents else {
								  throw CocoaError(.fileReadCorruptFile)		}
		switch configuration.contentType {
		case .fooDocTry3:
			let model: Part?	= Part	  (data: data, encoding: .utf8)
			self.init(model:model!)				// -> FooDocTry3Document
		case .sceneKitScene:
			let scene:SCNScene?	= SCNScene(data: data, encoding: .utf8)
			self.init(scene:scene!)				// -> FooDocTry3Document
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
/*	struct FileDocumentWriteConfiguration (FileDocument: typealias WriteConfiguration = ~)
		let contentType : UTType		// The expected uniform type of the file contents.
		let existingFile: FileWrapper?	// The file wrapper containing the current document content. nil if the document is unsaved.
*/
		switch configuration.contentType {
		case .fooDocTry3:
			return .init(regularFileWithContents:model.data!)
		case .sceneKitScene:
			return .init(regularFileWithContents:scene.data!)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
}

//https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
//https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
//https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html
extension UTType {
	static var fooDocTry3: UTType 	{ UTType(importedAs: "com.example.fooDoc") 	}
}

/* ============== END FileDocument protocol: */
