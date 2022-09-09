//
//  SelfiePole.swift
//  FooDocTry3
//
//  Created by Allen King on 9/8/22.
//

import Foundation

	 // Uses Cylindrical Coordinates
	struct SelfiePole {
		var height		: CGFloat = 0
		var spin  		: CGFloat = 0					// in degrees
		var horizonUp	: CGFloat = 0					// in degrees
		var zoom		: CGFloat = 1.0
		var uid			: UInt16  = randomUid()
	}
