//  Uid.swift -- manage pseudo-unique id's used to identify objects for debug 2019PAK
// A lightweight UUID

import SceneKit

protocol Uid {
	var uid 		: UInt16 	{ 	get 										}
}
 ///  pp the Uid
func ppUid(pre:String="", _ obj:Uid?, post:String="", showNil:Bool=false, aux:FwConfig=[:]) -> String {
	 // For fwConTroL elements:
	var uidDigits : Int		= aux.int("ppNUid4Ctl")  ?? DOCLOG.ppNUid4Ctl
	 // For Parts, Vews, and SCN Stuff:
	if obj==nil ? false :			// obj==nil --> uses ppNUid4Ctl (AD HOC?)
	   obj is Part 			||
	   obj is Vew 			||
	   obj is SCNNode 		||
	   obj is SCNConstraint	||
	   obj is SCNPhysicsBody {
		uidDigits			= aux.int("ppNUid4Tree") ?? DOCLOG.ppNUid4Tree
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
func ppUidFoo(pre:String="", _ obj:Uid?, post:String="", showNil:Bool=false) -> String {
	return "ppUidFoo is for debug"
}
//func testPpUidFoo () -> Bool {
//	let y  : String				= ppUid(pre:"pre:", DOCLOG, post:":post")
//	return y.hasPrefix("pre:") && y.hasSuffix("post")
//}

 /// pp nil object as dashes ("-")s Uid with proper indents
func uidStrDashes(nilLike obj:Uid?) -> String {			// no object
	let forTree					= obj is Part || obj is Vew || obj is SCNNode
							   || obj is SCNConstraint || obj is SCNPhysicsBody
	let uidDigits 				= DOCLOG == nil ? 	4	// a desparate situation -- no DOCLOG
								: forTree ? 	DOCLOG.ppNUid4Tree
								:				DOCLOG.ppNUid4Ctl
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

