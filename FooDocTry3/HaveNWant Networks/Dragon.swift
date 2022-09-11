//
//  Dragon.swift
//  FooDocTry3
//
//  Created by Allen King on 5/23/22.
//

import SceneKit

func dragonCurve(segments:Int=1024) -> SCNScene {
	let rv						= SCNScene()
	var direction				= 0
	var position				= SCNVector3(0,0,0)

	for i in 0..<segments{
	
		 // All scenens should have a  camera
		let square 				= SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.01))
//		square.color0			= NSColor("darkgreen")!//.change(alphaTo:0.3)
		square.name				= "square\(i)"
		square.position 		= position
//		rv.rootNode.addChild(node:square)
		rv.rootNode.addChildNode(square)

		 // Dragon index says left/right turn
		direction				+= dragon(index:i) ? 1 : -1 + 4		// left : right
		direction				%= 4

		 // Move in that x/y direction
		let len					= 0.25
		position.x				+= len * [0,1,0,-1][direction]
		position.y				+= len * [1,0,-1,0][direction]

		 // Makes picture prettier
		position.z				+= len / 20		//50
	}
	return rv
}

/* dragon -- turn left or right?
	1. Every corner point has an index, in 0..<BIG
	2. The point is either a left turn, or a right turn, depending on dragon(index:)
	3. dragon(index:) returns the bit to the left of the right-most 1. Consider:

	  index  in binary		returns (0:left, 1:right):
		0	  0 0 0 0 		(0) or (1)		<special case>
		1	  0 0(0>1		(0)
		2	  0(0>1 0		(0)
		3	  0 0(1>1		(1)
		4	 (0>1 0 0		(0)
		5	  0 1(0>1		(0)
		6	  0(1>1 0		(1)
		7	  0 1(1>1		(1)
 */
func dragon(index:Int) -> Bool {
	guard index != 0 else {		return false	} // special case
	var j = index
	while j & 1 == 0 {
		j /= 2			// alternately: j <<= 1
	}					// Move left till we find a 1
	return j & 2 == 0	// Bit after that is left/right
}
