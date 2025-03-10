//  LinkVew.swift -- Vew for a Link C20200115PAK

import SceneKit
import SwiftUI

class LinkVew : Vew {

	 // MARK: - 2. Object Variables:
	var  pCon2Vew : Vew?		= nil		// Vew to which my Ports are connected
	 var sCon2Vew : Vew?		= nil		// dummy values for now
//	lazy var  pCon2Vew : Vew	= .null		// Vew to which my Ports are connected
//	 lazy var sCon2Vew : Vew	= .null		// dummy values for now
	var  pEndVip : SCNVector3?	= nil		// H: P END scnVector3 position In Parent coordinate system
	 var sEndVip : SCNVector3?	= nil		// H: S END scnVector3 position In Parent coordinate system

	 // MARK: - 3. Factory
	override init(forPart part:Part/*?=nil*/, expose expose_:Expose? = nil) {
		super.init(forPart:part, expose:expose_)
	}
	 // MARK: - 3.5 Codable
	enum LinkVewKeys : CodingKey { 	case pCon2Vew, sCon2Vew, pEndVip, sEndVip	}
	override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:LinkVewKeys.self)
		try container.encode(pCon2Vew, 	forKey:.pCon2Vew 	)
		try container.encode(sCon2Vew,	forKey:.sCon2Vew 	)
		try container.encode(pEndVip, 	forKey:.pEndVip 	)
		try container.encode(sEndVip,	forKey:.sEndVip 	)
		atSer(3, "Encoded  as? Path        '\(String(describing: fullName))'")
	}
	required init(from decoder: Decoder) throws {
		super.init(forPart: Part())
		let container 			= try decoder.container(keyedBy:LinkVewKeys.self)
		pCon2Vew				= try container.decode( Vew.self, forKey:.pCon2Vew )
		sCon2Vew 				= try container.decode( Vew.self, forKey:.sCon2Vew )
		pEndVip					= try container.decode( SCNVector3.self, forKey:.pEndVip )
		sEndVip 				= try container.decode( SCNVector3.self, forKey:.sEndVip )
 		atSer(3, "Decoded  as? Vew       named  '\(String(describing: fullName))'")
	}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : LinkVew	= super.copy(with:zone) as! LinkVew
//		theCopy.pCon2Vew		= self.pCon2Vew
//		theCopy.sCon2Vew		= self.sCon2Vew
//		atSer(3, logd("copy(with as? LinkVew       '\(fullName)'"))
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	override func equalsFW(_ rhs:Vew) -> Bool {
//		guard let rhs			= rhs as? LinkVew else {	return false		}//false }
//		let rv					= super.equalsFW(rhs)
//								&& pCon2Vew	== rhs.pCon2Vew
//								&& sCon2Vew	== rhs.sCon2Vew
//		return rv																//rv
//	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig) -> String	{
		var rv			= super.pp(mode, aux)
		if mode == .line {
//			rv				+= " ->\(pCon2Vew?.pp(.nameTag, aux)),\(sCon2Vew.pp(.nameTag, aux))"
		}
		return rv
	}

	 // MARK: - 17. Debugging Aids
	override var description	  : String 	{ return  "d'\(pp(.short))'"		}
	override var debugDescription : String	{ return "dd'\(pp(.short))'"		}
	override var summary		  : String	{ return  "s'\(pp(.short))'"		}
}
