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
	var scene	: FwScene
	init(model:RootPart?, scene:FwScene?=nil) {
		self.model				= model	?? RootPart([:])
		self.scene				= scene	?? { fatalError()}()	//SCNNode(
	}
}

struct FooDocTry3Document: FileDocument {			// not NSDocument!!

	 // Model of a FooDocTry3Document:
	var state : DocState

	init(state:DocState?=nil) {
		self.state 				= state ?? { 		// state given
			var scene	 : FwScene
			var rootPart:RootPart? = nil

			  // Generate a new document:
//			 //
//			switch 1 {
//			case 1:		// ///// Library-defined RootPart -> Vew -> scn
				//	   selectionString+------FUNCTION-----------+-wantName:---wantNumber:
			//	let entry		= nil	//	 Blank scene		|	nil			-1
			//	let entry		= 34	//	 entry N			|	nil			N *
				let entry		= "xr()"//	 entry with xr()	|	"xr()"		-1
			//	let entry		= "name"//	 entry named scene	|	"name" *	-1
				rootPart		= RootPart(fromLibrary:entry)//, fwDocument:self)
				scene			= FwScene(fwConfig:[:])					// A Part Tree

//			case 2:		// ///// RootPart defined here -> Vew -> scn
//				scene			= FwScene(fwConfig:[:])					// A Part Tree
//				 // Add some children
//				let rootPart	= RootPart(["name":"ROOT"])	// create state
//				for (i, px) in [		// IS									//		let b			= Box(["size":"2 1 2", "color":"red"])
//					Sphere(		["size":"2 2 2"]),								//	//	b.color0		= NSColor.red
//					Cylinder(	["size":"2 2 2"]),								//		rootPart.addChild(b)
//					Box(		["size":"2 2 2"]),								//		for i in 1...3 {
//					Hemisphere(	["size":"2 2 2"]),								//			let p		= Sphere()
//				].enumerated() {												//			p.nam		= "p\(i)"
//					let p		= px											//			rootPart.addChild(p)
//					p.nam		= "p\(i)"										//		}							//
//					rootPart.addChild(p)										//		let b			= Box(["size":"2 1 2", "color":"red"])
//				}																//	//	b.color0		= NSColor.red
//
//			case 3:		// ///// Dragon Curve -> scn
//				scene			= dragonCurve(segments:1024)	// Dragon Curve
//				rootPart		= RootPart(["name":"ROOT"])	// create state
//
//			case 4:		// ///// A Simple Scene -> scn
//				scene			= aSimpleScene()				// Two Cubes and a Sphere
//				rootPart		= RootPart(["name":"ROOT"])	// create state
//
//			default:
//				fatalError("stateType is ILLEGAL")
//			}
			return DocState(model:rootPart, scene:scene)
		}()
		// Now self.state has full DocState, holding rootPart
		let lldbRootScn:SCNNode	= rootScn

		 // KNOWN EARLY
		DOC						= self				// INSTALL FooDocTry3
		let scene				= self.state.scene	// INSTALL SCNScene
		let rootScn				= scene.rootScn		// INSTALL SCNNode

		let rVew				= Vew(forPart:self.state.model, scn:rootScn)//.scene!.rootNode)
		scene.rootVew			= rVew			// INSTALL vew

		rVew.updateVewTree()					// rootPart -> rootView, rootScn
		//let x = rVew.pp(.tree)


		state?.scene.addLightsAndCamera()
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
				let docState 		= DocState(model:rootPart, scene:FwScene(fwConfig:[:]))
			self.init(state:docState)			// -> FooDocTry3Document
		case .sceneKitScene:
			let scene:FwScene?	= FwScene(data: data, encoding: .utf8)
			let state0 			= DocState(model:RootPart(), scene:scene!)
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
