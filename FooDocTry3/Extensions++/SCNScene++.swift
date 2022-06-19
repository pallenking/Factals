//
//  SCNScene++.swift
//  FooDocTry3
//
//  Created by Allen King on 5/25/22.
//

import SceneKit

extension SCNScene {

	 // Get camera node from SCNScene; generate if necessary
	var cameraNode : SCNNode {
		return rootNode.childNode(withName: "camera", recursively: false) ?? {
			groomScene()						// Try a groom once
			return rootNode.childNode(withName: "camera", recursively: false) ?? {
				fatalError("something's amiss")	// Still a problem
			}()
		}()
	}

	 // Add Lights and Camera
	func groomScene() {
		
		 // create and add a light to the scene:
		func addLight(name:String, lightType:SCNLight.LightType, color:Any?=nil, position:SCNVector3?=nil) {
			let newLight 		= SCNNode()
			newLight.name		= name
			newLight.light 		= SCNLight()
			newLight.light!.type = lightType
			if let color		= color {
				newLight.light!.color = color
			}
			if let position		= position {
				newLight.position = position
			}
			rootNode.addChildNode(newLight)
		}
		addLight(name:"light",   lightType:.omni, position:SCNVector3(0, 0, 15))
		addLight(name:"ambient", lightType:.ambient, color:NSColor.darkGray)

		 // Add camera
		let cameraNode 			= SCNNode()
		cameraNode.name			= "camera"
		cameraNode.camera 		= SCNCamera()
		cameraNode.position 	= SCNVector3(0, 0, 15)
		rootNode.addChildNode(cameraNode)
	}

	// FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {
					// 1. Write SCNScene to file. (older, SCNScene supported serialization)
		write(to:fileURL, options:nil, delegate:nil, progressHandler:nil)
					// 2. Get file to data
		let data				= try? Data(contentsOf:fileURL)
		return data
	}
	 // initialize new SCNScene from Data
	convenience init?(data:Data, encoding:String.Encoding) {
		do {		// 1. Write data to file.
			try data.write(to: fileURL)
		} catch {
			print("error writing file: \(error)")
		}
		do {		// 2. Init self from file
			try self.init(url: fileURL)
		} catch {
			print("error initing from url: \(error)")
			return nil
		}
	}

	func printModel() {
		print("rootNode.name = '\(rootNode.name ?? "<nil>")'")
		print("rootNode.children = '\(rootNode.childNodes.count)'")
		for scn in rootNode.childNodes {
			print("name:'\(scn.name ?? "<nil>")'")
		}
	}
}

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

// //// -- WORTHY GEM: -- ///// //
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

