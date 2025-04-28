//  Path.swift -- Parsed reference to a Network element C2015PAK
// Do it once here, rather than often via decoding the string

import SceneKit

/// *	A Path has a String representation:
/// *		The tokens of a Path are separated by a '/'
/// 			or a '.', if the last token of a Path is a Port.
/// *		The Path may be absolute or relative:
/// 			_absolute_  Paths contain an initial '/':
/// 				e.g: /r/net/a or /s/net
/// 			_relative_  Paths can be evaluated
/// 				to find the closest network element
/// 					to an absolute reference Path
/// 				closest involves the distance to a common ancestor
/// 				e.g: /r/net to above
/// *		The last characters of a path
/// 			it may contain link hints e.g. 
/// 				"=" -- direct    -- no link
/// 				"%" -- flipPort  -- ?
/// 				"^" -- noCheck   -- suspend "correct" checking up/down
/// 				"!" -- dominant  -- ?
/// 				"@" -- invisible -- invisible link
/// 
/// *	Examples:
/// *		bun/a/prev			the Atom bun/a/prev
/// *		bun/a/prev.S		the Port bun.a.prev.S
/// *		i=					direct link to closet part named "i"
/// *		i!^					link to "i", position only by it, suspend checking
/// *		a.P					name ends in "a", the Port name is "P"
/// *		/r/net/aa.P,l:5		to .../aa.P with length 5.0
/// *		foob!,max:5 		to foo, positioning using this link only, link max=5
/// 
/// *	Code NOTATION (pretty vanilla:)
/// 	a) 'c'			-- the character code c	( '' is no char)
/// 	b) <varName>	-- the variable named varName
/// 	c) (<operation>)-- a grammar operation  (e.g. (+) is the string catenate operator)
/// 	d) (<a>)*		-- do <a> 0 or more times,  (<a>)+ one or more times, ...
/// 	e) ||			-- alternatives,				a || b

// CherryPick2023-0520: remove NSObject
class Path : NSObject, Codable, FwAny {			// xyzzy4
	static let shortNames		= [ "=":"direct", "%":"flipPort", "^":"noCheck",
									"!":"dominant", "@":"invisible"]
	 // MARK: - 2. Object Variables:
	var tokens  	: [String]			// array of tokens in reversed order
	var atomName	: String?			// Only Leaf uses this
	var portName   	: String?	= nil	// after last '.'
	var linkProps 	: FwConfig 	= [:]	// Link's required propeties. e.g. [l:3, f:1]

	 // MARK: - 3. Factory
	init(from path:Path) {
		tokens 					= path.tokens
		atomName 				= path.atomName
		portName 				= path.portName
		linkProps 				= path.linkProps
	}
	init(withName name:String) {

		  // Parse name into 1) partName(s), 2) port, 3) 1-char link modifiers, and val=prop link modifiers
		 // Split name separated by "/" into atom tokens //#  E.G: name = "r/bun/ab.P=@,l:5"
		tokens 					= name.components(separatedBy:"/").reversed()
		let lastToken			= tokens[0]		//#  E.G: "ab.P=@,l:5"
		let options				= lastToken.components(separatedBy:",")
		var lastName			= options[0]  	//#  E.G: "P=@,l:5,v:3"

		 // options[1..] are name=value pairs defining link E.G: [ "l=5", ... ]
		for option in options[1...] {			// all but first --> linkOptions
			let nameVal 		= option.components(separatedBy:":")	//"="
			assert(nameVal.count==2, "Syntax: '\(option)' not of form <prop>:<val>" +
												" E.G: \"l:5\", \"@\" and \"=\"")
			linkProps[nameVal[0]] = nameVal[1]
		}
		 // Strip trailing option characters
		while let cSub 			= lastName.last {
			let c				= String(cSub)
			 // Find long linkProp from short character
			guard let shortName	= Path.shortNames[c] else { break }
			linkProps[shortName] = true			// 		linkProps["direct"] = true
			lastName 			= String(lastName.dropLast())		// remove trailing modifiers
		}

		 // Get Port name from lastName token:	//#  E.G: "P"
		let lastNameComps		= lastName.components(separatedBy:".")	// e.g=t1.P
		if  lastNameComps.count == 2 {			//#  E.G: "ab.P"
			portName 			= String(lastNameComps[1])	// Port name
			atomName			= lastNameComps[0]			// Atom part exists
			tokens[0] 			= lastNameComps[0]
		}
		else if lastNameComps.count == 1 {		//#  E.G: "P" is a Port?
			tokens[0]			= lastName					// NO, Atom (or Part)
			if Port.reservedPortNames.contains(lastName) {	// YES, it's a Port!
				portName 		= lastName						// special Port Name
				tokens			= Array(tokens.dropFirst()) // shift other tokens
			}
		}
		else {
			panic("token with multiple dots (\".\")")
		}
		//assert(tokens.allSatisfy({ $0.count != 0 }), "null string in token from '\(name)'")
	}
	func fullName() -> String {	// tokens and Port
		return tokens.reversed().joined(separator:"/") +
				(portName==nil ? "" : "." + portName!)
	}
	func dequeFirstName() -> String? {
		guard tokens.count > 0 		else {		return nil }
		let rv					= tokens[0]
		tokens				= Array(tokens[1...])
		return rv
	}


	 // MARK: - 3.5 Codable
	enum PathKeys : CodingKey { 	case atomTokens, portName, linkProps }
	func encode(to encoder: Encoder) throws {
//		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:PathKeys.self)
		try container.encode(tokens, forKey:.atomTokens)
bug;	try container.encode(portName,   forKey:.portName)
//		try container.encode(linkProps,  forKey:.linkProps)
//		logSer(3, "Encoded  as? Path        '\(String(describing: fullName))'")  // CherryPick2023-0520:
	}
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:PathKeys.self)
		tokens				= try container.decode([String].self, forKey:.atomTokens)
bug;	portName  				= try container.decode( String?.self, forKey:.portName)
//		linkProps 				= try container.decode(FwConfig.self, forKey:.linkProps)
		

		super.init()
 		logSer(3, "Decoded  as? Path       named  '\(String(describing: fullName))'")
	}
//	 // MARK: - 3.6 NSCopying
//	func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : Path		= Path(withName:"")//super.copy(with:zone) as! Path
//		theCopy.atomTokens 		= self.atomTokens
//		theCopy.portName   		= self.portName
//		theCopy.linkProps	  	= self.linkProps
//		logSer(3, "copy(with as? Path       ''")
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	func equalsFW(_ rhs:Path) -> Bool {
//		return true
//			&& atomTokens 			== rhs.atomTokens
//			&& portName   			== rhs.portName
//		//	&& linkProps	  		== rhs.linkProps
//	}

// xyzzyx4
	func atomNameMatches(part:Part) -> Bool {

		  // Compare Atom names:
		 /// DDD in Path.h
		 //											Hungarian COMPonentS
		let partComps 				= part.fullName.components(separatedBy:"/")
		let pathComps				= tokens

		 // loop through PATH, in REVERSE order, while scanning PART (in rev too)
		var nPart 					= partComps.count-1		// e.g: 3 [ "", brain1, main]
		var nPath					= pathComps.count-1;		// e.g: 2         [ "", main]

		 // Check all components specified in Path match
		while nPath >= 0 && pathComps.count >= 0 {
			guard nPath>=0 else {break}
			assert(nPart>=0, "Path has more components than Part.nameFull")
			var partComp 			= partComps[nPart]
			var pathComp 			= pathComps[nPath];
			guard partComp == pathComp else { return false }

			nPath -= 1; nPart -= 1
		}
		assert(nPath == 0 && pathComps.count == 0, "if first component is ")
		return true;							// all tests pass
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String {
		switch mode {
		case .phrase, .short, .line, .tree:
			return fullName() + ",[" + ppLinkProps() + "]"
		case .name, .fullName:
			return "<nameless>"
		default:	// only root depricates
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
	}
	func ppLinkProps() -> String {
		var (boolProp, kvProp, sep)			= ("", "", "")
		 // Print linkPorps
		for (propKey, propValue) in linkProps {
			if Bool(fwAny:propValue) == true,
			  let (k, _) 		= Path.shortNames.first(where: { $1 == propKey }) {
				boolProp		+= sep + k	// true Bools just print their name:
			}									// boolProp = "bool1,...,boolN"
			else {							// else it's e.g. ",l:5":
				kvProp 			+= sep + propKey + ":" + propValue.pp()
			}									//   kvProp = "k1:v1,...,kN:vN"
			sep					= ","
		}
		sep						= boolProp == "" && kvProp == "" ? "" : ","
		return boolProp + sep + kvProp
	}

         // MARK: - 17. Debugging Aids
	override var description	  :String 	{	return  "d'\(pp(.short))'"		}
	override var debugDescription :String	{	return "dd'\(pp(.short))'"		}
	var summary					  :String	{	return  "s'\(pp(.short))'"		}
}
