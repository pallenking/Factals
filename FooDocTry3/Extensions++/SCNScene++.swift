//
//  SCNScene++.swift
//  FooDocTry3
//
//  Created by Allen King on 5/25/22.
//

import SceneKit

protocol FileDocumentHelper {
	var data : Data?		{ set get }
	init?(data:Data, encoding:String.Encoding)
}
extension FileDocumentHelper {

}

var fileURL : URL 				= 	{
	let path					= NSTemporaryDirectory()
	let directoryURL			= URL(fileURLWithPath:path)
	 // Must have suffix ".scn". Reason: ???
	return directoryURL.appendingPathComponent("t1.scn")
}()

// //// -- WORTHY GEMS: -- ///// //
//
//	typealias PolyWrap = Part
//	class Part : Codable /* PartProtocol*/ {
//		func polyWrap() -> PolyWrap {	polyWrap() }
//		func polyUnwrap() -> Part 	{	Part()		}
//	}
//	//protocol PartProtocol {
//	//	func polyWrap() -> PolyWrap
//	//}
//
//func serializeDeserialize(_ inPart:Part) throws -> Part? {
//
//	 //  - INSERT -  PolyWrap's
//	let inPolyPart:PolyWrap	= inPart.polyWrap()	// modifies inPart
//
//		 //  - ENCODE -  PolyWrap as JSON
//		let jsonData 			= try JSONEncoder().encode(inPolyPart)
//
//			print(String(data:jsonData, encoding:.utf8) ?? "")
//
//		 //  - DECODE -  PolyWrap from JSON
//		let outPoly:PolyWrap	= try JSONDecoder().decode(PolyWrap.self, from:jsonData)
//
//	 //  - REMOVE -  PolyWrap's
//	let outPart				= outPoly.polyUnwrap()
//	 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
//	let _					= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()
//
//	return outPart
//}

