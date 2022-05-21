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
	var text: String
	var scene: SCNScene?

	init(text: String = "Hello, world!") {
		self.text = text
	}

	static var readableContentTypes: [UTType] { [.exampleText] }

	init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents,
			  let string = String(data: data, encoding: .utf8)
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
		text = string
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		//assert(text != nil)
		let data = text.data(using: .utf8)!
		return .init(regularFileWithContents: data)
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


}
