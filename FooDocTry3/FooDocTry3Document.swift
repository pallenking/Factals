//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

struct DocState {
	var model	: RootPart
	var vew		: Vew
	var scene	: SCNScene
}

let stateType = 3		// quiet compiler errors
func newDocState() -> DocState		{

	var rootPart	: RootPart?	= nil
	var vew		: Vew?			= nil
	var scene	: SCNScene

	switch stateType {
	case 1:
		scene					= dragonCurve(segments:1024)	// for testing
	case 2:
		scene					= aSimpleScene()				// future direction
	case 3:
		scene					= SCNScene()
		rootPart				= RootPart()//"parts":[Part()]])
		rootPart?.name			= "ROOT"
		for i in 1...2 {
			let p				= Part()
			p.name				= "p\(i)"
			rootPart!.addChild(p)
		}
		scene.addLightsAndCamera()
		vew	  					= Vew(forPart:rootPart, scn: scene.rootNode)
		vew?.updateVewTree()

	default:
		fatalError("newDocState stateType:\(stateType) is ILLEGAL")
	}

	return DocState(model:rootPart ?? RootPart(), vew:vew ?? Vew(), scene:scene)
}

struct FooDocTry3Document: FileDocument {			// not NSDocument!!

	 // Model of a FooDocTry3Document:
	var state : DocState

	let newDocStateType			= 1
	init(state:DocState 		= newDocState()) {
		self.state 				= state
	}

	/* ============== BEGIN FileDocument protocol: */
	static var readableContentTypes: [UTType] { [.fooDocTry3, .sceneKitScene] }
	static var writableContentTypes: [UTType] { [.fooDocTry3] }
	//private static let onlyScene = true
																				//	static var readableContentTypes: [UTType] { [.exampleText] }
	init(configuration: ReadConfiguration) throws {
			//	struct FileDocumentReadConfiguration (FileDocument: typealias ReadConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the document content.
		guard let data : Data 	= configuration.file.regularFileContents else {
								  throw CocoaError(.fileReadCorruptFile)		}
		switch configuration.contentType {
		case .fooDocTry3:
			let rootPart: RootPart!	= RootPart(data: data, encoding: .utf8)!
			let state0 			= DocState(model:rootPart, vew:Vew(), scene:SCNScene())
			self.init(state:state0)				// -> FooDocTry3Document
		case .sceneKitScene:
			let scene:SCNScene!	= SCNScene(data: data, encoding: .utf8)!
			let state0 			= DocState(model:RootPart(), vew:Vew(), scene:scene)
			self.init(state:state0)				// -> FooDocTry3Document
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
			//	struct FileDocumentWriteConfiguration (FileDocument: typealias WriteConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the current document content. nil if the document is unsaved.
		switch configuration.contentType {
		case .fooDocTry3:
			return .init(regularFileWithContents:state.model.data!)
		case .sceneKitScene:
			return .init(regularFileWithContents:state.scene.data!)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
}

//https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
//https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
//https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html

 // Define new UTType
extension UTType {
	static var fooDocTry3: UTType 	{ UTType(exportedAs: "com.example.footry3") 	}
}

/* ============== END FileDocument protocol: */
