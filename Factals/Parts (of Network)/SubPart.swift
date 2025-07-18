//  SubPart.swift -- support structure for Part ©202005PAK

import Foundation
import SceneKit

  /// An Array of Bits, stored in a Char.
 /// - To use 3 bits, 8 (=2**3) cases must be defined
var raw2string44 : [String] = [" ", "V", "S", "VS", "P", "VP", "SP", "VSP"]
enum DirtyBits : UInt8, CaseIterable, Codable {	// Identifiable
	case clean	= 0
	case vew	= 1		// The Vew structure for this part needs updating
	case size	= 2		// The sizing of this part needs updating
	case paint	= 4		// The painting and color of the skins
 	  // multiple values which might occur together:
	 // This is a wierd way to pack 3 dirty bits into one UInt8
	case vs		= 3		//
	case vp		= 5		// 2 on
	case sp		= 6		//
	case vsp	= 7		// all 3 ON
	case reset	= 255

	init(fromString string:String) {
		let rawInt	: Int	= raw2string44.firstIndex(of:string) ?? 9999
		let rawInt8	: UInt8 = UInt8(fwAny:rawInt) ?? 255
		self				= DirtyBits(rawValue:rawInt8) ?? .reset
	}
	mutating func turnOn(_  kind:DirtyBits) {	// just self
		self				= DirtyBits(rawValue:rawValue | kind.rawValue)!
	}
	mutating func turnOff(_ kind:DirtyBits) {	// just self
		self				= DirtyBits(rawValue:rawValue & ~kind.rawValue)!
	}
	func isOn(_  kind:DirtyBits) -> Bool {
		return rawValue & kind.rawValue != 0
	}
	func pp() -> String {
		let rv				= self == .reset				 ? 		"RST"
							: rawValue >= raw2string44.count ?		"ILL"
							: raw2string44[Int(rawValue)]
		return rv
	}
}

extension Part {
	/// Turn a dirty bit ON this node, and go up through all parents, and insure set.
	/// - parameter argBit: selects which bit is addressed
	/// - Marks the bit from the selected node, through parents to the root.
	/// - Stops if it encounters node marked with this bit
	func markTreeDirty(bit:DirtyBits) {
		 // Go up the containment tree, SEARCHING FOR an entry
		for s in selfNParents {
			if s.dirty.isOn(bit) {			// node has bits ON				// s.dirty != DirtyBits.clean
				break								// no need to go up farther
			}
			s.dirty.turnOn(bit)
		}
		
		// If size changed, notify connected links
		if bit.isOn(.size) {
			notifyConnectedLinksOfSizeChange()
		}
	}
	
	 /// Notify connected links that this part's size has changed
	func notifyConnectedLinksOfSizeChange() {
		 // Iterate through all ports in this part
		if let atom = self as? Atom {
			for (_, port) in atom.ports {
				 // If this port is connected to another port
				if let connectedPort = port.con2?.port {
					 // If the connected port belongs to a Link, mark the link as needing size update
					if let link = connectedPort.parent as? Link {
						link.markTreeDirty(bit: .size)
					}
				}
			}
		}
	}
	
	/// Ensure the dirtyBits of all leaf nodes are included here
	/// - Parameter gotLock: OBSOLETE
	/// - Returns: The correct dirtyness
	func rectifyTreeDirtyBits(gotLock:Bool=false) -> DirtyBits {
//		gotLock ? nop : SCNTransaction.lock()

						// --- Do for all Children
		var childrenDirtyRaw	= DirtyBits.clean.rawValue
		for child in children {			// cleanse

			childrenDirtyRaw	|= child.rectifyTreeDirtyBits(gotLock:true).rawValue

		}
		 				// --- Do for self
		let nodeDirtyRaw		= dirty.rawValue
						// --- bits in childrenDirty but not in nodeDirty are errors
		let extraBits 			= childrenDirtyRaw & ~nodeDirtyRaw
		if extraBits != 0 {	// in children unaccounted in self
			let newDirty		= DirtyBits(rawValue: nodeDirtyRaw | childrenDirtyRaw)!	//DirtyBits(rawValue:childrenDirtyRaw)!
			print("OOOO ERROR OOOO tree:'\(self.fullName)' extraBits:\(extraBits)|\(dirty)->\(newDirty)")	//\n\(pp(.tree))
			dirty				= newDirty
		}
//		gotLock ? SCNTransaction.unlock() : nop 
		return dirty
	}												// all dirty: Vew, Size, Paint
	
	/// Set dirtyness bits of all child Parts.
	/// - Parameters:
	///   - gotLock: OBSOLETE
	///   - dirtyness: kind of dirtyness bits involved
	func dirtySubTree(gotLock:Bool=false, _ dirtyness:DirtyBits = .vsp) {
//		gotLock ? nop : SCNTransaction.lock()

		let dirtyRaw			= dirtyness.rawValue | dirty.rawValue
		dirty					= DirtyBits(rawValue:dirtyRaw)!

		for child in children {
			child.dirtySubTree(gotLock:true, dirtyness)
		}

//		gotLock ? SCNTransaction.unlock() : nop 
	}

	/// Test a bit in property 'dirty'
	/// - Parameter bit: what kind of dirty
	/// - Returns: value of bit
	func test(dirty bit:DirtyBits) -> Bool {
		assert(bit != .reset, "Illegal semantics - should never test(dirty:.reset)")
		let rv					= dirty.rawValue & bit.rawValue
		return rv != 0
	}
}
var defaultPrtIndex = 0

 /// Establish defaults for named Parts (e.g. prv3):
let prefixForClass = [						// prefix for naming Part
 // Undefined symbol: FwShapes.prefixForClass.unsafeMutableAddressor : [Swift.String : Swift.String]
		"Part"		:"prt",				"PolyWrap"	:"---",
	/**/"Box"		:"box",				"Atom"		:"atm",
		"Sphere"	:"sph",				"Cylinder"	:"cyl",
		"Hemisphere":"hem",				"TunnelHood":"tuh",
	/**/"Mirror"	:"mir",
		"Previous"	:"prv",				"Prev"		:"prv",
		"Ago"		:"ago",				"Known"		:"kno",
		"Modulator"	:"mod",				"Mod"		:"mod",
		"Rotator"	:"rot",
	/**/"Net"		:"net",
		"FwBundle"	:"bun",				"Leaf"		:"leaf",
		"BundleTap"	:"bt",				"ShaftBundleTap":"sbt",
		"Tunnel"	:"tun",
		"Actor"		:"atr",
	/**/"Splitter"	:"s",				"Splitr"	:"s",
		"Share"		:"sh",
		"MaxOr"		:"or",				"MinAnd"	:"and",
		"Broadcast"	:"bc",				"KNorm"		:"kn",
		"Multiply"	:"mul",				"Sequence"	:"seq",
		"Bayes"		:"bay",				"Bulb"		:"bulb",
		"Hamming"	:"ham",
	/**/"Link"		:"l",
		"Vew"		:"v",
		"NetVew"	:"nv", 				"NVew"		:"nv",
		"LinkVew"	:"nv",				"LVew" 		:"nv",
		"Generator"	:"g", 				"Gen"		:"g",
		"DiscreteTime":"dt", 			"DiTime"	:"dt",
		"TimingChain":"tc", 			"TChain"	:"tc",
		"WorldModel":"wm", 				"WModel"	:"wm",
		"MultiPort"	:"mp", 				"MPort"		:"mp",
		"MultiLink"	:"ml", 				"MLink"		:"ml",
]

 /// Short names for printout:
let commonNameDefinitions = [
	"Previous"		: "Prev",
	"Modulator"		: "Mod",
//	"Rotator"		: "Rotate",
	"Splitter"		: "Splitr",
	"HaveNWant"		: "Hnw",
	"NetVew"		: "NVew",
	"LinkVew"		: "LVew",
	"Generator"		: "Gen",
	"DiscreteTime"	: "DiTime",
	"TimingChain"	: "TChain",
	"WorldModel"	: "WModel",
	"MultiPort"		: "MPort",
	"MultiLink"		: "MLink",
]
let printTopDown				= false 		// print top line first
let firstIsUp 	 				= true			// find scans parts bottom up


 /// Expose: how to vew the contents.
enum Expose 	: UInt8, Codable, CaseIterable 	{ 			//	CodingKey // enum AdditionalInfoKeys: String, CodingKey { //https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
	// Case A:		CASE
	case null					= 0x01			// Does not exist
	case invis					= 0x02			// Do not display anything
	case atomic 				= 0x04 			// Display as an Atom (sphere)
	case same					= 0x08			// Leave unchanged
	case open					= 0x10			// Display all contents
	// Case B:		Raw from String
	static let name2raw : [String:UInt8]	= [
		"undef"	:0x00,
		"open"	:0x02,
		"atom"	:0x04, 	"atomic"	:0x04,
		"invis"	:0x08, 	"invisible"	:0x08,
		"null"	:0x10,
	]
	// Case C:		Funcky PP String from raw
	static let raw2pp : [UInt8:String]	= [
		8:"i",
		4:"a",
		2:"o",
		0:"?",
	]
	// All 3 cases must be kept in sync

	 /// Create an Expose by String.
	/// - E.g. Expose("invis")
	init?(string:String)	{
		if let intVal			= Expose.name2raw[string] {
			self.init(rawValue:intVal)
			return
		}
		return nil
	}
	 /// Create an Expose by String.
	/// - E.g. Expose(432) (= nil)
	init?(intVal:Int)	{
		if let uInt8Val 		= NSNumber(value:intVal) as? UInt8 {// Swift 4.2 ugly
			self.init(rawValue:uInt8Val)
			return
		}
		return nil
	}

	var asInt 		:Int 		{	return Int(rawValue) 						}
	var asString	:String?	{
		let raw		:Int		= Int(self.rawValue)
		for (name, rawVal) in Expose.name2raw
								where rawVal == raw && name.count <= 5	{
			return name					// pick first one that's short
		}
		return ""
	}

//	func pp(_  ERROR, SHOULD BE
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		switch mode {
		case .name:
			return asString ?? "?49"					// e.g. "invis"
		case .phrase, .short:
			return Expose.raw2pp[UInt8(rawValue)] ?? "?48"
		default:
			panic()
		}
		return "?47"
	}
}

enum Latitude: Int, CaseIterable, Identifiable, Codable {
	case northPole	= 0
	case arctic		= 1
	case northern	= 2
	case cancer		= 3
	case equator	= 4
	case capricorn	= 5
	case southern	= 6
	case antarctic	= 7
	case southPole	= 8
	var id: Int { self.rawValue }		// Identifiable
	static var latitude2string = [
		"NorthPole",
		"Arctic",
		"Northern",
		"Cancer",
		"Equator",
		"Capricorn",
		"Southern",
		"Antarctic",
		"SouthPole",
	]
}

