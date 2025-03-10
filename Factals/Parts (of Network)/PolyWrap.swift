 //  PolyWrap.swift -- make Part polymorphic for codable 190808PAK

import SceneKit

//awakeAfter(using:)

//https://www.digitalflapjack.com/blog/2018/5/29/encoding-and-decoding-polymorphic-objects-in-swift
//https://gist.github.com/mdales/fe362d54568eece5eccff8135df5cf34
/*@objc*/ protocol PolyWrappable {
	func polyWrap() -> PolyWrap
	func polyUnwrap() -> Part
}


extension Part : PolyWrappable {												}

 // Why aren't these used?
extension Array : PolyWrappable where Element : PolyWrappable {
	/*@objc*/ func polyWrap() -> PolyWrap {
		bug;return PolyWrap()		// needs codeing
	}
	/*@objc*/ func polyUnwrap() -> Part {
		bug;return Part()			// needs codeing
	}
}
extension Dictionary : PolyWrappable where Value : PolyWrappable {
	func polyWrap() -> PolyWrap {
		bug;return PolyWrap()		// needs codeing
	}
	func polyUnwrap() -> Part {
		bug;return Part()		// needs codeing
	}
}

class PolyWrap : Part {

	 // MARK: - 2. Object Variables:
	/*@objc*/ override func polyWrap() -> PolyWrap {	debugger("Cannot polyWrap a PolyWrap") }
	/*@objc*/ override func polyUnwrap() -> Part {

		 // check proper form of PolyWrap
		assert(children.count == 1, "PolyWrap should have exactly one child")

		 // remove the PartWrap (self) from tree
		let rv : Part			= children[0]	// Child isn't a PolyWrap

		 // Unwrap all children RECURSIVELY
		for (i, rvsChild) in rv.children.enumerated() {
			guard let rvsChildPoly = rvsChild as? PolyWrap else { fatalError()	}

			 // Replace Wrapped with Unwrapped:
			rv.children[i]		= rvsChildPoly.polyUnwrap()
			rv.children[i].parent = rv
		}
		return rv
	}
	 // MARK: - 3. Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		if let parts 			= partConfig["parts"] {
			let arrayOfParts	= parts as? [Part]
			assert(arrayOfParts != nil, "PolyWrap([parts:<val>]), but <val> is not [Part]")
			assert(arrayOfParts!.count == 1, "paranoia")
			let child			= arrayOfParts![0]
//			self.partBase			= child.partBase			// WTF
			self.addChild(child)
//			arrayOfParts!.forEach { addChild($0) }		// add children in "parts"
			partConfig["parts"] = nil
		}
	}
	 // MARK: - 3.5 Codable Serialization
	enum PolyWrapCodingKeys: CodingKey {
		case polyWrapsType			// CodingKey to access classname of polyWrap
		case polyWrap				// CodingKey to access polyWrap
	}
	//@objc func polyUnwrap() -> Part {
	//	debugger("Should be overridden")
	//}
	override func encode(to encoder: Encoder) throws {
		let polyWrap			= child0!
		let typeString			= polyWrap.fwClassName

		  // PolyWraps do not care about Part's variables, don't encode them
		 // try super.encode(to:encoder)
		var container 			= encoder.container(keyedBy: PolyWrapCodingKeys.self)
		try container.encode(typeString, 			   forKey:.polyWrapsType)
		try polyWrap .encode(to:container.superEncoder(forKey:.polyWrap))
		atSer(3, "Encoded  as? PolyWrap    '\(fullName)'")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {

		 // PolyWraps do not care about Part's variables; don't use super.init(from:decoder)!!!
		super.init(["name":"---"])	// /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
						 			// "---" needed for similar/equatable

		let container 			= try decoder.container(keyedBy:PolyWrapCodingKeys.self)

		 // ////// Newbie Part's class comes from from .polyType:String
		let newbieClassString 	= try container.decode(String.self, forKey:.polyWrapsType)
		let newbiePartType:Part.Type = classFrom(string:newbieClassString)
		atSer(6, "Decoding as? PolyWrap,  has \(container.allKeys.count) keys, partType:\(newbiePartType)")

		 // ////// Get Part of type/class partType
		let polyWrapsContainer 	= try container.superDecoder(forKey:.polyWrap)
		let newbiePart			= try newbiePartType.init(from:polyWrapsContainer)

		//name = ""
		partConfig				= [:]
		atSer(3, "Decoded  as? PolyWrap   named '\(name)', partType\(newbiePartType)")
		self.addChild(newbiePart)
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
	
	 // MARK: - 3.6 NSCopying
	 // MARK: - 3.7 Equatable
	 //	 MARK: - 15. PrettyPrint
}

/*	https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/2
extension Encodable {
	fileprivate func encode(to container: inout SingleValueEncodingContainer) throws {
		try container.encode(self)
	}
}

struct AnyEncodable : Encodable {
	var value: Encodable
	init(_ value: Encodable) {
		self.value = value
	}
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try value.encode(to: &container)
	}
}

let a: AnyFoo = Foo()
do {
	let data = try JSONEncoder().encode(AnyEncodable(a))
	print(String(decoding: data, as: UTF8.self))
} catch {
	print(error)
}
 */

