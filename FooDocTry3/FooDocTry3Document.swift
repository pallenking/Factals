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

	let newDocStateType			= 1
	init(state:DocState?=nil) {
		self.state 				= state ?? { 		// state given
			var rootPart : RootPart = RootPart()	// create state
			rootPart.nam		= "ROOT"
			var scene	 : FwScene

			  // Generate a new document:
			 //
			let stateType 		= 3
			switch stateType {
			case 1:		// Test Pattern of Parts -> Vew -> scn
				scene			= FwScene(fwConfig:[:])					// A Part Tree
			case 2:		// Test Pattern of Parts -> Vew -> scn
				scene			= FwScene(fwConfig:[:])					// A Part Tree
				 // Add some children
//				let b			= Box(["size":"2 1 2", "color":"red"])
				//"1.0 1.0 1.0""0.5 0.5 0.5"
		//		b.color0		= NSColor.red
//				rootPart.addChild(b)
//				for i in 1...3 {
//					let p		= Sphere()
//					p.nam		= "p\(i)"
//					rootPart.addChild(p)
//				}
										//		 // Add some children
										//		let b			= Box(["size":, "color":"red"])
										//		//"2 2 2""1.99 1.99 1.99""1.8 1.8 1.8""1 1 1""0.9 0.9 0.9"
										//		//
								//		//		b.color0		= NSColor.red
										//		rootPart.addChild(b)
								// "0.2 0.2 0.2" --> -0.02< 0.02		1/10
								// "0.3 0.3 0.3" --> -0.05< 0.05		1/6
								// "0.4 0.4 0.4" --> -0.08< 0.08		1/5
								// "0.5 0.5 0.5" --> -0.12< 0.12		1/4
								// "1.0 1.0 1.0" --> -0.50< 0.50		1/2				good
								// "2 2 2"		 --> -2.0< 2.0			2
								// 1.8 --> -1.6< 1.6		2x  - 0.2
								// 0.8 --> -0.x< 0.2		x/2 + 0
								// 0.6 --> -0.2< 0.2		x/2 + 0
								// 0.4 --> -0.1< 0.1		x/2 + 0
												for (i, px) in [		// IS
													Sphere(		["size":"2 2 2"]),
													Cylinder(	["size":"2 2 2"]),
													Box(		["size":"2 2 2"]),
													Hemisphere(	["size":"2 2 2"]),
				//									Box(["size":"2 2 2"]),
				//									Box(["size":"2 2 2"]),
								////					"0.2 0.2 0.2",		// -0.02< 0.02		0.2*0.2 / 2
								////					"0.4 0.4 0.4",		// -0.08< 0.08		0.4*0.4 / 2
								////					"0.6 0.6 0.6",		// -0.18< 0.18		0.6*0.6 / 2
								////					"0.8 0.8 0.8",		// -0.32< 0.32		0.8*0.8 / 2
								////					"1.0 1.0 1.0",		// -0.50< 0.50		1.0*1.0 / 2
								////					"1.2 1.2 1.2",		// -0.72< 0.72		1.2*1.2 / 2
								////					"1.4 1.4 1.4",		// -0.98< 0.98		1.4*1.4 / 2
								////					"1.6 1.6 1.6",		// -1.28< 1.28		1.6*1.6 / 2
								////					"1.8 1.8 1.8",		// -1.62< 1.62		1.8*1.8 / 2
								////					"2.0 2.0 2.0",		// -2.00< 2.00		2.0*2.0 / 2
								////					"2.2 2.2 2.2",		// -2.42< 2.42		2.2*2.2 / 2
								////					"2.4 2.4 2.4",		// -2.88< 2.88		2.4*2.4 / 2
								//
								////					" 4  4  4",			//  -8.00< 8.00		 4* 4 /2
								////					" 5  5  5",			// -12.50<12.50		 5* 5 /2
								////					"10 10 10",			// -50.00<50.00		10x10 /2
								////					"20 20 20",			//-200.00<200.00,	20x20 /2
								////					"40 40 40",			//-800.00<800.00
												].enumerated() {
//													let p		= px(["size":v3])
													let p		= px
													p.nam		= "p\(i)"
													rootPart.addChild(p)
												}
			case 3:
				scene			= dragonCurve(segments:1024)	// Dragon Curve
			case 4:
				scene			= aSimpleScene()				// Two Cubes and a Sphere
			default:
				fatalError("newDocState stateType:\(stateType) is ILLEGAL")
			}
			return DocState(model:rootPart, scene:scene)
		}()
		// Now self.state has full DocState, holding rootPart
		let lldbRootScn:SCNNode	= rootScn

		 // KNOWN EARLY
		DOC						= self				// INSTALL
		let scene				= self.state.scene
		let rootScn				= scene.rootScn		// INSTALL scn

		let rVew				= Vew(forPart:self.state.model, scn:rootScn)//.scene!.rootNode)
		scene.rootVew			= rVew			// INSTALL vew

		rVew.updateVewTree()					// rootPart -> rootView, rootScn
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
