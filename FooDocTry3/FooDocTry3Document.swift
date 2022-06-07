//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

var defaultScene : SCNScene		{
	dragonCurve(segments:1024)
//	aRootVew()
}

struct FooDocTry3Document: FileDocument {			// not NSDocument!!

	 // Model of a FooDocTry3Document:
	var model : Part
	var vew	  : Vew
	var scene : SCNScene

	init(model:Part = Part(), scene:SCNScene = defaultScene) {
		self.model 				= model
		self.scene				= scene
		vew	  					= Vew(forPart: model, scn: scene.rootNode)
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
			let scene:SCNScene?	= SCNScene(data: data, encoding: .utf8)
			let string:String?	= String  (data: data, encoding: .utf8)
			let model: Part?	= Part	  (data: data, encoding: .utf8)
			self.init(model:model!)				// -> FooDocTry3Document
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
