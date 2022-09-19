//
//  SelfiePole.swift
//  FooDocTry3
//
//  Created by Allen King on 9/8/22.
//

import SceneKit

	 // Uses Cylindrical Coordinates
	struct SelfiePole {
		var at							= SCNVector3.origin
//		var height		: CGFloat 		= 0
		var spin  		: CGFloat 		= 0					// in degrees
		var horizonUp	: CGFloat 		= 0					// in degrees
		var zoom		: CGFloat 		= 1.0
		var uid			: UInt16  		= randomUid()

		func pp() -> String {
			return fmt("[at:%s, s:%.0f, u:%.0f, z:%.4f]", at.pp(), spin, horizonUp, zoom)
		}
	}
