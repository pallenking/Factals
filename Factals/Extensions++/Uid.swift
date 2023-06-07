//  Uid.swift -- manage pseudo-unique id's used to identify objects for debug 2019PAK
// A lightweight UUID

import SceneKit

protocol Uid {
	var uid 		: UInt16 	{ 	get 										}
}
  ///  Support for Uid:
 ///  Conformers to Uid can use this:
func ppUid(pre:String="", _ obj:Uid?, post:String="", showNil:Bool=false, aux:FwConfig=[:]) -> String {
	 // For fwConTroL elements:
	var uidDigits : Int		= aux.int("ppNUid4Ctl")  ?? DOCfwGutsQ?.log/*DOClog.*/.ppNUid4Ctl ?? 4
	 // For Parts, Vews, and SCN Stuff:
	if obj==nil ? false :			// obj==nil --> uses ppNUid4Ctl (AD HOC?)
	   obj is Part 			||
	   obj is Vew 			||
	   obj is SCNNode 		||
	   obj is SCNConstraint	||
	   obj is SCNPhysicsBody {
		uidDigits			= aux.int("ppNUid4Tree") ?? DOClog.ppNUid4Tree
	}
	assert(uidDigits >= 0 && uidDigits <= 4, "ppUid( haa illegal uidDigits=\(uidDigits)")

	if obj == nil  {				// Nil objects:
		return !showNil ? "" :			// don't show; or show as "---":
			pre + String(repeating: "-", count:uidDigits) + post // show fake
	}
	if uidDigits == 0 {				// Valid obj. Any UID digits desired
		return !showNil ? "" : "-"
	}

	 // return <pre>UID<post>
	let max : Int	= 1 << (4 * uidDigits)		// e.g: 0x00001000
	let mask		= UInt16(max - 1)			// e.g: 0x00000FFF
	return pre + fmt("%0*x", uidDigits, obj!.uid & mask) + post
}

 /// pp nil object as dashes ("-")s Uid with proper indents
func uidStrDashes(nilLike obj:Uid?) -> String {			// no object
	let forTree					= obj is Part || obj is Vew || obj is SCNNode
							   || obj is SCNConstraint || obj is SCNPhysicsBody
	let uidDigits 				= DOClog == nil ? 	4	// a desparate situation -- no DOClog
								: forTree ? 	DOClog.ppNUid4Tree
								:				DOClog.ppNUid4Ctl
	return  String(repeating: "-", count:uidDigits)
}
 /// Generate Uid of NSObject from hash of address
func uid4Ns(nsOb:NSObject) -> UInt16 {
	 /// Get bits of pointer to object:
	let str						= fmt("%p", nsOb).dropFirst(2)	// remove "0x"//"12345"//
	let i						= UInt64(str, radix:16) ?? 0
	var j						= i
	 /// arbitrary hash
	for k in [8, 24, 40] {		/// hash to get good low 16 bits:
		j						^= i>>k
	}
	for k in [8, 4, 2, 1] {		/// simple scramble
		j						^= j>>k
	}
	return UInt16(j & 0xffff)
}
 /// Generate a random Uid to initialize objects with a Uid variable
func randomUid() -> UInt16 {
	return UInt16(randomUInt() & 0xffff)
}

// Maximally separated
func pseudoAddressString<T>(_ t:T) -> String where T : NSObject
{	fmt("%p", t)				/* Memory Address of NSObject */				}
func pseudoAddressString<T>(_ t:T) -> String where T : Uid
{	fmt("%p", t.uid)			/* Uid of Swift */								}
func pseudoAddressString<T>(_ t:T) -> String
{	""							/* PUNT */										}

//protocol NativeSwiftObject: AnyObject { }	// Empty protocol used to identify native Swift objects
//extension NSObject: NativeSwiftObject { }	// NSObject does NOTconform to it
//func pseudoAddress<T:AnyObject>(_ ob:T) -> String where T: NativeSwiftObject {
//	"\(ob.uid())"
//}
//
//func pseudoAddress<T:AnyObject>(_ ob:T) -> String {
//	String(format:"%p", arguments:[ob])
//}
//
//func pseudoAddressX<T>(_ t:T) -> String where T : NSObject {
//}
//
//
//if let swiftClass = type(of: object) as? AnyClass,
//   _isNative(swiftClass) {
