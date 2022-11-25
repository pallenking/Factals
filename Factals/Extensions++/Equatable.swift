// Equatable.swift -- extended conformances to Equatable
//  SCNVector9XCTest.swift -- Fix BUG: Redundant conformance to protocol in unit test only ©21200909PAK
// https://stackoverflow.com/questions/56169303/redundant-conformance-to-protocol-in-unit-test-only

import SceneKit

// // MARK: - 3.7 Equatable in Bulb : Splitter
//infix operator =+=
//
//protocol UnderEquatable {
//	static func =+=<T> (_ lhs:Self, _ rhs:T) -> Bool
////	static func =+= (_ lhs:Self, _ rhs:Self) -> Bool
//}
////extension Part : UnderEquatable {
////	static func =+= <T>(lhs: Part, rhs: T) -> Bool { 	return false					}
////}
////func ==<T> (lhs:T, rhs:T) -> Bool where T : Part {
////	var rv						= true
////	if let lhsSuper				= lhs.superclass {
////		rv	  					&&= lhs.superclass == rhs.superclass
////	}
////	rv							&&= lhs.varsEqOf(rhs)
////}
//extension Bulb  { //######################################################
////	static func =+= (_ lhs:Bulb, _ rhs:Bulb) -> Bool {
////		return ((lhs as Splitter)	=+= (rhs as Splitter))
////			&& lhs.pValue 			== rhs.pValue
////			&& lhs.gain 			== rhs.gain
////			&& lhs.offset 			== rhs.offset
////			&& lhs.currentRadius 	== rhs.currentRadius
////	}
//}
//extension Splitter  { //######################################################
////	func =+= (_ lhs:Bulb, _ rhs:Bulb) -> Bool {
////		return ((lhs as Splitter)	=+= (rhs as Splitter))
////			&& lhs.pValue 			== rhs.pValue
////			&& lhs.gain 			== rhs.gain
////			&& lhs.offset 			== rhs.offset
////			&& lhs.currentRadius 	== rhs.currentRadius
////	}
//}
////	func equalsX<SuperclassX>(_ part:Part) -> Bool where Part : SuperclassX  {
//////	func equalsX<SelfX, SuperclassX where SuperclassX : ClassX>(_ part:SelfX) -> Bool {
//////	func equalsX<SelfX>(_ part:SelfX) -> Bool {
////		let superX				= superclass
////		return	superX.equalsX(part) && varsEqOf(part)
////	}
////	func varsEqOf<ClassX, SuperclassX> (_ rhs:ClassX) -> Bool where ClassX : SuperclassX {
////		guard let rhsAsClassX = rhs as? ClassX else {	return false			}
////		return 		  pValue == rhsAsClassX.pValue
////			&& 			gain == rhsAsClassX.gain
////			&& 		  offset == rhsAsClassX.offset
////			&& currentRadius == rhsAsClassX.currentRadius
////	}




// Original
//extension FactalsDocument: Equatable {
//	static func ==(lhs: FactalsDocument, rhs: FactalsDocument) -> Bool {
//		lhs.uid == rhs.uid				// almost good enough 2^-16			//&& lhs.config == rhs.config	// slow? broken
//	}
//}
//extension SCNNode : ObservableObject {	}

extension SCNVector3 : Equatable {
	public static func ==(lhs:SCNVector3, rhs:SCNVector3) -> Bool {
		lhs.x == rhs.x  &&  lhs.y == rhs.y  && lhs.z == rhs.z
		//return lhs.equals(rhs)
	}
	//func equals(_ rhs: SCNVector3) -> Bool {
	//	x == rhs.x  &&  y == rhs.y  && z == rhs.z
	//}
}

extension SCNVector4 : Equatable {		//, Codable
	public static func ==(lhs: SCNVector4, rhs: SCNVector4) -> Bool {
		lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
//		return lhs.equals(rhs)
	}
	//func equals(_ rhs: SCNVector4) -> Bool {
	//	return x == rhs.x && y == rhs.y && z == rhs.z && w == rhs.w
	//}
}

extension SCNMatrix4 : Equatable {
	public static func ==(lhs: SCNMatrix4, rhs: SCNMatrix4) -> Bool {
		return lhs.equals(rhs)
	}
	func equals(_ rhs: SCNMatrix4) -> Bool {
		let rv					=
		m11 == rhs.m11  &&  m21 == rhs.m21  &&  m31 == rhs.m31  &&  m41 == rhs.m41 &&
		m12 == rhs.m12  &&  m22 == rhs.m22  &&  m32 == rhs.m32  &&  m42 == rhs.m42 &&
		m13 == rhs.m13  &&  m23 == rhs.m23  &&  m33 == rhs.m33  &&  m43 == rhs.m43 &&
		m14 == rhs.m14  &&  m24 == rhs.m24  &&  m34 == rhs.m34  &&  m44 == rhs.m44
		return rv
	}
}
