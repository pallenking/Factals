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

func urlOfLocalFile(named name:String) -> URL {
	let directoryURL			= URL(fileURLWithPath:NSTemporaryDirectory())
	return directoryURL.appendingPathComponent(name)
}

var fileURL : URL 				= 	{
	let directoryURL			= URL(fileURLWithPath:NSTemporaryDirectory())
	 // Must have suffix ".scn". Reason: ???
	return directoryURL.appendingPathComponent("t1.scn")
}()

extension SCNScene {
	var cameraNode : CameraNode {
		let camera 				= rootNode.find(name:"camera")
		let rv 					= camera as! CameraNode
		return rv
	}
}

