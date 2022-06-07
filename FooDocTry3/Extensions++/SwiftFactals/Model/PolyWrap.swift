 //  PolyWrap.swift -- make Part polymorphic for codable 190808PAK

import SceneKit
//https://www.digitalflapjack.com/blog/2018/5/29/encoding-and-decoding-polymorphic-objects-in-swift
//https://gist.github.com/mdales/fe362d54568eece5eccff8135df5cf34
protocol PolyWrappable {
	func polyWrap() -> PolyWrap
}

extension Array : PolyWrappable where Element : PolyWrappable {
	func polyWrap() -> PolyWrap {
		bug;return PolyWrap()
	}
}
extension Dictionary : PolyWrappable where Value : PolyWrappable {
	func polyWrap() -> PolyWrap {
		bug;return PolyWrap()
	}
}

class PolyWrap : Part {

	 // MARK: - 2. Object Variables:
	@objc override func polyWrap() -> PolyWrap {	fatalError("Cannot polyWrap a PolyWrap") }
	@objc func polyUnwrap() -> Part {
		 // check proper form of PolyWrap
		assert(children.count == 1, "PolyWrap should have exactly one child")
		 // remove self (a Part9Poly) from tree
		let rv					= children[0]	// non-poly child
		for (i, rvsChild) in rv.children.enumerated() {
			let rvsChildPoly	= rvsChild as! PolyWrap
			rv.children[i]		= rvsChildPoly.polyUnwrap()
			rv.children[i].parent = rv
		}
		return rv
	}

	 // MARK: - 3. Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		if let parts 			= localConfig["parts"] {
			let arrayOfParts	= parts as? [Part]
			assert(arrayOfParts != nil, "PolyWrap([parts:<val>]), but <val> is not [Part]")
			assert(arrayOfParts!.count == 1, "paranoia")
			let child			= arrayOfParts![0]
			self.root			= child.root			// WTF
			self.addChild(child)
//			arrayOfParts!.forEach { addChild($0) }		// add children in "parts"
			localConfig["parts"] = nil
		}
	}
	 // MARK: - 3.5 Codable Serialization
	enum PolyWrapCodingKeys: CodingKey {
		case polyWrapsType			// CodingKey to access classname of polyWrap
		case polyWrap				// CodingKey to access polyWrap
	}
	override func encode(to encoder: Encoder) throws {
		let polyWrap			= child0!
		let typeString			= polyWrap.fwClassName

		  // PolyWraps do not care about Part's variables, don't encode them
		 // try super.encode(to:encoder)
		var container 			= encoder.container(keyedBy: PolyWrapCodingKeys.self)
		try container.encode(typeString, 				 forKey:.polyWrapsType)
		try polyWrap .encode(to:container.superEncoder(forKey:.polyWrap))
		atSer(3, logd("Encoded  as? PolyWrap    '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {

		 // PolyWraps do not care about Part's variables; don't use super.init(from:decoder)!!!
		super.init(["name":"---"])	// /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
						 			// "---" needed for similar/equitable

		let container 			= try decoder.container(keyedBy:PolyWrapCodingKeys.self)

		 // ////// Newbie Part's class comes from from .polyType:String
		let newbieClassString 	= try container.decode(String.self, forKey:.polyWrapsType)
		let newbiePartType:Part.Type = classFrom(string:newbieClassString)
		atSer(6, logd("Decoding as? PolyWrap,  has \(container.allKeys.count) keys, partType:\(newbiePartType)"))

		 // ////// Get Part of type/class partType
		let polyWrapsContainer 	= try container.superDecoder(forKey:.polyWrap)
		let newbiePart			= try newbiePartType.init(from:polyWrapsContainer)

		//name = ""
		localConfig				= [:]
		atSer(3, logd("Decoded  as? PolyWrap   named '\(name)', partType\(newbiePartType)"))
		self.addChild(newbiePart)
	}
	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : PolyWrap	= super.copy(with:zone) as! PolyWrap
bug		//theCopy.con			= self.con
		atSer(3, logd("copy(with as? Actor       '\(fullName)'"))
		return theCopy
	}
	 // MARK: - 3.7 Equitable substitute
	func varsOfPolyPartEq(_ rhs:Part) -> Bool {
		guard let rhsAsPolyPart	= rhs as? PolyWrap else {	return false		}
		return true
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfPolyPartEq(part)
	}

	 //	 MARK: - 15. PrettyPrint
//	// Override: Method does not override any method from its superclass
//	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
//		var rv					= ""
//		switch mode! {
//		case .line:
//			  //      AaBbbbbbCccDdddddddddddddddddddddddEeeeeeeeeeeee
//			 // e.g: "Ff| | | < 0      prev:Prev  o> 76a8  Prev mode:?
//			rv					= ppUid(self, post:"", aux:aux)
//		default:
//			return ppDefault(self:self, mode:mode, aux:aux)// NO return super.pp(mode, aux)
//		}
//		return rv
//	}
}
extension Part {
	/*
			input		returned (E) ^backlink
			 |			 v
			 |			PolyWrap (A)
			 v			 v		 (B) ^backlink
			self		self
			v v v		v v v	 (C)
			C C C		C C C	 (D) ^backlink
			| | |		| | |
	*/
   
   /// Wrap a Part in a PolyWrap, so it's subclasses can be processed by Codable.
   /// - Returns: a PolyWrap with one child, self.
	@objc func polyWrap() -> PolyWrap {
		 // stitch in our PolyWrap in where we were
		let p					= PolyWrap(["name":"---", "parts":[self]])				// (B) backlink
		parent					= p
		 // PolyWrap Atom's children
		// NFG: children		= children.polyWrap()
		for i in 0..<children.count {
			children[i]			= children[i].polyWrap()		// RECURSIVE			// (C)
			children[i].parent	= self													// (D) backlink
		}
		return p
	}
}
//extension Atom {
//			// Atoms have a var ports : Dictionary<String:Port>
//			// 20210907PAK To do this right would require another PolyWrap class, or perhaps a generic.
//			//  TODO
//			//  .:. DON'T WRAP PORTS. Leave un-wrapped.
//			//		Deal with it's subclasses later after things settle down
//			// N.B: At this point, two polyWraps for a Port exists, on in children, one in ports
//	@objc override func polyWrap() -> PolyWrap {
//		let poly				= super.polyWrap()
//		 // Paw through Atom's Ports:
//		for (i, (name, port)) in ports.enumerated() {
//		}
//		return poly
//	}
//}


