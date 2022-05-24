//
//  fooDocTry3Document.swift
//  fooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

extension UTType {
	static var exampleText: UTType {
		UTType(importedAs: "com.example.plain-text")
	}
}

struct fooDocTry3Document: FileDocument {
	var scene: SCNScene
	var partz: SCNScene

	private static let onlyScene = true
	static var readableContentTypes: [UTType] { [.exampleText] }

	init(configuration: ReadConfiguration) throws {
		if let data = configuration.file.regularFileContents {
			let _		 		= String  (data: data, encoding: .utf8)
			let sScene			= SCNScene(named:"art.scnassets/ship.scn")!//SCNScene()//(data: data, encoding: .utf8)
			self.init(scene:sScene)
		}
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
	}

	init(scene:SCNScene?=SCNScene(named:"art.scnassets/ship.scn")!) {
		self.scene				= scene!
		self.scene.groomScene()
		self.partz				= makePartz()
		self.partz.groomScene()
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//		let data 				= text .data(using:.utf8)!
//		let data				= scene.data(using:.utf8)
		let data				= "".data(using:.utf8)!
			///Value of type 'SCNScene' has no member 'data'
			///Cannot infer contextual base in reference to member 'utf8'

		return .init(regularFileWithContents: data)
	}
}

extension SCNScene {
	func printModel() {
		print("rootNode.name = '\(rootNode.name ?? "<nil>")'")
		print("rootNode.children = '\(rootNode.childNodes.count)'")
		for scn in rootNode.childNodes {
			print("name:'\(scn.name ?? "<nil>")'")
		}
	}
	var cameraNode : SCNNode {
		return rootNode.childNode(withName: "camera", recursively: false) ?? {
			fatalError("something's amiss")
		}()
	}

	func groomScene() {
		
		// All scenens should have a  camera
		let cameraNode 			= SCNNode()
		cameraNode.name			= "camera"
		cameraNode.camera 		= SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
		rootNode.addChildNode(cameraNode)

		// create and add a light to the scene
		let lightNode 			= SCNNode()
		lightNode.name			= "light"
		lightNode.light 		= SCNLight()
		lightNode.light!.type 	= .omni
		lightNode.position 		= SCNVector3(x: 0, y: 10, z: 10)
		rootNode.addChildNode(lightNode)

		// create and add an ambient light to the scene
		let ambientLightNode 	= SCNNode()
		ambientLightNode.name	= "ambient"
		ambientLightNode.light 	= SCNLight()
		ambientLightNode.light!.type = .ambient
		ambientLightNode.light!.color = NSColor.darkGray
		rootNode.addChildNode(ambientLightNode)
	}
}




	typealias PolyWrap = Part
	class Part : Codable /* PartProtocol*/ {
		func polyWrap() -> PolyWrap {	polyWrap() }
		func polyUnwrap() -> Part 	{	Part()		}
	}
	//protocol PartProtocol {
	//	func polyWrap() -> PolyWrap
	//}

func serializeDeserialize(_ inPart:Part) throws -> Part? {

	 //  - INSERT -  PolyWrap's
	let inPolyPart:PolyWrap	= inPart.polyWrap()	// modifies inPart

		 //  - ENCODE -  PolyWrap as JSON
		let jsonData 			= try JSONEncoder().encode(inPolyPart)

			print(String(data:jsonData, encoding:.utf8) ?? "")

		 //  - DECODE -  PolyWrap from JSON
		let outPoly:PolyWrap	= try JSONDecoder().decode(PolyWrap.self, from:jsonData)

	 //  - REMOVE -  PolyWrap's
	let outPart				= outPoly.polyUnwrap()
	 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
	let _					= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()
	
	return outPart
}

