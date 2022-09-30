//
//  VewConfig.swift -- maintain Vew openness statat.
//  FooDocTry3
//
//  Created by Allen King on 9/29/22.
//

import Foundation

enum VewConfig {
	typealias RawValue			= String

	  // Open a path from self to the Factal at <path> from self.
	 // Only children on path are effected
	case openPath(Path)
	 // Open all of children, down to deapth
	case openChildren(Int)

	case subVewList([VewConfig])			// array of directives, to
	case subVew(FwConfig)

}

extension Vew {
	func adornAt(from:Part, using config:VewConfig) {
		switch config {
		case .openPath(let path):
			 // Descend path, explode area
			adornTargetVew		= nil			// HACK
bug;		for name in path.atomTokens {
				 // Dive into
				if let subVew	= self.find(name:"_"+name),
				  let subPart	= from.find(name:	 name) {
					adornTargetVew	= subVew
					subVew.adornAt(from:subPart, using:config)
				}
			}
		case .openChildren(let deapth):
			let deapth			= deapth - 1
			if deapth <= 0 {	break											}
			 // open our child Vews
			for childVew in children {
				childVew.adornAt(from:childVew.part, using: .openChildren(deapth))
			}
		case .subVewList(let vewConfigs):
			for childVew in children {
				for vewConfig in vewConfigs {
					childVew.adornAt(from: from, using:vewConfig)
				}
			}
		case .subVew(let fwConfig):
			nop
		}
	}
}
//extension RootPart {
//	func openUsing(config:VewConfig) -> RootVew {
//		switch config {
//		case .openArea(let path3, let area)
//			nop
//		case .subVewList(let vewConfigs):
//			for elt in vewConfigs {
//				openUsing(config)
//			}
//		case .subVew(let fwConfig)
//			nop
//		}
//	}
//}

