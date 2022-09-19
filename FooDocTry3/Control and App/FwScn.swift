//
//  FwScn.swift
//  FooDocTry3
//
//  Created by Allen King on 9/19/22.
//

import SceneKit


//		Concepts:
//	The camera is positioned in the world with the camera transform
//
//                3D MODEL SPACE       camera
//    model             v                ^         LOCAL
//     coords:          |                |					getModelViewMatrix()
//                \ ∏ Tmodel i/    trans = cameraScn.transform
//                 \  Matrix /           |
//    world    =====    v   =============*============ WORLD		[x, y, z, 1]
//     coords:          |
//               \ trans.inverse /
//                \   Matrix    /
//    camera   ======   v    ========================= EYE			[x, y, z, 1]
//     coords:          |
//                \ PROJECTION /
//                 \  Matrix  /pm
//    clip     ======   v    ========================= ?        	[x, y, 1]
//     coords:          |
//                \ Perspective/         (not used)
//                 \ division /
//    device   ======   v    ========================= RETINA:		[x, y, 1]
//     coords:          |								CLIP
//                 \ Viewport /  A = | fx 0  cx |  Intrinsic Matrix
//                  \ Matrix /       | 0  fy cy |  f = focal length
//    window            v			 			   c = center of image
//     coords:          |
//             ====== SCREEN ========================= SCREEN		[x, y]
// https://learnopengl.com/Getting-started/Coordinate-Systems

class FwScn {
	weak
	 var fwGuts	 : FwGuts!		= nil

	var scnView	 : SCNView!		= nil
	var scnScene : SCNScene!
	var rootScn  : SCNNode	{	scnScene.rootNode									}	//scnRoot

	init() {
	}
	init(fwGuts: FwGuts? = nil, scnView: SCNView? = nil, scnScene: SCNScene) {
		self.scnView = scnView
		self.scnScene = scnScene
	}

	var trunkScn : SCNNode? {
		if let tv				= fwGuts?.trunkVew  {
			return tv.scn
		}
		fatalError("trunkVew is nil")
	}
}
