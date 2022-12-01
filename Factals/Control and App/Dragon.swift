//
//  Dragon.swift
//  Factals
//
//  Created by Allen King on 5/23/22.
//

import SceneKit

/* dragon -- turn left (false) or right (true)?
	1. Every corner point has an index, in 0..<BIG
	2. The point is either a left turn, or a right turn, depending on dragon(index:)
	3. Consider binary representation of index.
	4. Return the bit to the left of the right-most 1.
	5. Notation in the following:
			']'  = rightmost '1' in index
			'O>' = 0 to the left of '[',  '0'  = 0 that is not O>
			'I>' = 1 to the left of '[',  '1'  = 1 that is not I>
	  index  in binary		Return value: 0=left, 1=right
		1	  0 0(O>]		(0)
		2	  0(O>] 0		(0)
		3	  0 0(I>]		(1)
		4	 (O>] 0 0		(0)
		5	  0 1(O>]		(0)
		6	  0(I>] 0		(1)
		7	  0 1(I>]		(1)
 */
func dragon(index:Int) -> Bool {
	guard index != 0 else {		return false	} // special case
	var j = index
	while j & 1 == 0 {
		j /= 2			// alternately: j <<= 1
	}					// Move left till we find a 1
	return j & 2 == 0	// Bit after that is left/right
}

func dragonCurve(segments:Int=1024) -> SCNScene {
	let rv						= SCNScene()
	let rootNode				= rv.rootNode
	rootNode.name				= "ROOT"

	let scnNode					= SCNNode()
	scnNode.name				= "ship"				// hack (should be more generic)
	scnNode.transform			= SCNMatrix4MakeRotation(90, 0, 1, 0)
	rootNode.addChildNode(scnNode)

	var direction				= 0
	var position				= SCNVector3(0,0,0)
	let colors	: [NSColor]		= [.red,.orange,.yellow,.green,.blue,.purple,.black]
	let nColors : Int			= colors.count

	for i in 0..<segments{
	
		 // All scenens should have a  camera
		let square 				= SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.01))
		square.color0			= colors[i%nColors]
		square.name				= "square\(i)"
		square.position 		= position
		scnNode.addChildNode(square)

		 // Turn 90 degrees Left or Right:
		direction				+= dragon(index:i) ? 1 : -1 + 4		// left : right
		direction				%= 4

		 // Move len
		let len					= 0.25
		position.x				+= len * [0,1,0,-1][direction]
		position.y				+= len * [1,0,-1,0][direction]

		 // Makes picture prettier
		position.z				+= len / 20		//50
	}
	return rv
}

//extension SCNNode {
//	var color0 : NSColor {
//		get {	 material_0()?.diffuse.contents as? NSColor ?? .black		}
//		set(newColor) {
//			if let m 			= material_0() {
//				m.lightingModel	= .blinn		// 190220 Try it out!s
//				m.diffuse.contents = newColor
//				m.specular.contents = NSColor.white
//			}
//		}
//	}
//	func material_0() -> SCNMaterial? {
//		let geom : SCNGeometry? = geometry 				// A: I have a geometry
//						?? (childNodes.count <= 0 ? nil // B: no child nodes
//						  : childNodes[0].geometry)		// C: child node's geometry
//		assert(geom != nil, "Setting color0 before its geometry has been established")
//		geom!.name				= "material"
//
//		var rv : SCNMaterial?	= geom?.materials[0]
//		if rv==nil {
//			rv 					= SCNMaterial()
//			geom!.materials.append(rv!)
//		}
//		return rv!
//	}
//}
