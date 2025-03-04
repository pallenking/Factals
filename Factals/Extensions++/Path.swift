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
/// *		/r/net/aa.P,l:5	to .../aa.P with length 5.0
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

	 // MARK: - 1. Class Variables:
	static let shortNames		= [ "=":"direct", "%":"flipPort", "^":"noCheck",
									"!":"dominant", "@":"invisible"]
	 // MARK: - 2. Object Variables:
	var atomTokens : [String]			// array of tokens in reversed order
										// abs has trailing "" string
										// (no Port or Link Options)
// xyzzyx4
//	var nameFull	: String
//
//	func sd(nameFull:String) {
//		self.nameFull = nameFull
//
//		  // NOTE: setNameStr can ignore leading '/'s to the atom
//		  // process link parameters; those after the first comma
//		 /// AAA in Path.h
//		let components		= nameFull.components(separatedBy:",")
//		var n 				= components.count - 1
//		nameAtom			= components[0]			// first is atom
//
//		self.linkOptions 	= []
//		while n > 0 {								// all but first --> linkOptions
//			let option 		= components[n];	n  -= 1
//			let nameVal		= option.components(separatedBy:"=")
//			assert(nameVal.count==2, "Syntax: '\(option)' not of form <prop>=<val> (HINT: older form was just length, no key)")
//			linkOptions[nameVal[0]] = nameVal[1]	// [self.linkOptions setValue:nameVal[1] forKey:nameVal[0]];
//		}
//		(direct, flipPort, dominant, invisible, noCheck) = (false, false, false, false, false)
//		nameAtom 			= takeOptionsFrom(nameAtom)
//
//		 ///! CCC in Path.h
//		namePort			= ""				/// Initially no Port
//		if let range 		= nameAtom.range(of:".", options:.backwards) {
//			namePort 		= String(nameAtom.suffix(from:nameAtom.index(after:range.lowerBound)))
//			nameAtom		= String(nameAtom.prefix(upTo:range.lowerBound))
//		}
//
//		suffixLoc 			= nameAtom.range(of:".", options:[BackwardsSearch].location;
//		if (suffixLoc != NSNotFound) {
//			self.namePort = [nameAtom substringFromIndex:suffixLoc+1];	// after  "."
//			nameAtom = [nameAtom substringToIndex:suffixLoc];				// before "."
//		}
//		self.nameAtom = nameAtom;							/// Name without options
//	}
//
//	var nameAtom	: String
//	var namePort	: String			// after last '.'
//	var linkOptions	:[String]	= []	// NSMutableArray;// just length now
//	var direct		: Bool				// trailing '='
//	var flipPort	: Bool				// trailing '%'
//	var noCheck		: Bool				// trailing '^'
//	var dominant	: Bool				// trailing '!'
//	var invisible	: Bool				// trailing '@'

	var portName   :  String? 	= nil	// after last '.'

	 /// Link's required propeties.
	var linkProps 	: FwConfig 	= [:]	// e.g. l=3

	func fullName() -> String {	// tokens and Port
		return atomTokens.reversed().joined(separator:"/") +
				(portName==nil ? "" : "." + portName!)
	}
	func dequeFirstName() -> String? {
		guard atomTokens.count > 0 		else {		return nil }
		let rv					= atomTokens[0]
		atomTokens				= Array(atomTokens[1...])
		return rv
	}

	 // MARK: - 3. Factory
	init(withName name:String) {

		  // Parse name into partNames, port, 1-char link modifiers, and val=prop link modifiers
		 // Split name separated by "/" into atom tokens
		 	            					 	//#  E.G: name = "r/bun/ab.P=@,l:5"
		atomTokens 				= name.components(separatedBy:"/").reversed()
		let atEnd				= atomTokens[0]	//#  E.G: "ab.P=@,l:5"
		let options				= atEnd.components(separatedBy:",")

		var lastName			= options[0]  	//#  E.G: "P=@,l:5"
		 // options[1..] are name=value pairs defining link E.G: [ "l=5", ... ]
		for option in options[1...] {	// all but first --> linkOptions
			let nameVal 		= option.components(separatedBy:":")	//"="
			assert(nameVal.count==2, "Syntax: '\(option)' not of form <prop>:<val>" +
												" E.G: \"l:5\", \"@\" and \"=\"")
			linkProps[nameVal[0]] = nameVal[1]
		}
		 // Strip trailing characters
		while let cSub 			= lastName.last {
			let c				= String(cSub)
			var found			= false
			 // Find long linkProp from short character
			if let x			= Path.shortNames[c] {
				found			= true			//#  E.G: "=" (->"direct")
				linkProps[x] 	= true			// 		linkProps["direct"] = true
			}
			if !found {							// NOT PRESENT
				break								// Stop on first non-special char
			}
			lastName 			= String(lastName.dropLast())		// remove trailing modifiers
		}
		 // Get Port name from lastName token:	//#  E.G: "P"
		let lastNameComps		= lastName.components(separatedBy:".")	// e.g=t1.P
		if  lastNameComps.count == 2 {			//#  E.G: "ab.P"
			portName 			= String(lastNameComps[1])	// Port name
			if lastNameComps[0].count != 0 {
				atomTokens[0] 	= lastNameComps[0]			// Atom part exists
			}
			else {											// No atom part
				assert(atomTokens.count == 1, "nil atom name, with other tokens")
				atomTokens		= []
			}
		}
		else if lastNameComps.count == 1 {		//#  E.G: "P" is a Port?
			atomTokens[0]		= lastName					// NO, Atom (or Part)
			if Port.reservedPortNames.contains(lastName) {	// YES, it's a Port!
				portName 		= lastName						// special Port Name
				atomTokens		= Array(atomTokens.dropFirst()) // shift other tokens
			}
//			if portName == "share" {				// Port name "share" --> ""
//				panic("WTF")
//				portName		= ""				// meaning ???
//			}
		}
		else {
			panic("token with multiple dots (\".\")")
		}
		//assert(tokens.allSatisfy({ $0.count != 0 }), "null string in token from '\(name)'")
	}

	 // MARK: - 3.5 Codable
	enum PathKeys : CodingKey { 	case atomTokens, portName, linkProps }
	func encode(to encoder: Encoder) throws {
//		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:PathKeys.self)
		try container.encode(atomTokens, forKey:.atomTokens)
bug;	try container.encode(portName,   forKey:.portName)
//		try container.encode(linkProps,  forKey:.linkProps)
//		atSer(3, logd("Encoded  as? Path        '\(String(describing: fullName))'"))  // CherryPick2023-0520:
	}
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:PathKeys.self)
		atomTokens				= try container.decode([String].self, forKey:.atomTokens)
bug;	portName  				= try container.decode( String?.self, forKey:.portName)
//		linkProps 				= try container.decode(FwConfig.self, forKey:.linkProps)

		super.init()
 		atSer(3, logd("Decoded  as? Path       named  '\(String(describing: fullName))'"))
	}
//	 // MARK: - 3.6 NSCopying
//	func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : Path		= Path(withName:"")//super.copy(with:zone) as! Path
//		theCopy.atomTokens 		= self.atomTokens
//		theCopy.portName   		= self.portName
//		theCopy.linkProps	  	= self.linkProps
//		atSer(3, logd("copy(with as? Path       ''"))
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
//	func atomNameMatches(part:Part) -> Bool {
//
//		  // Compare Atom names:
//		 /// DDD in Path.h
//		 //											Hungarian COMPonentS
//		let partComps 				= part.fullName.components(separatedBy:"/")
//		let pathComps				= atomTokens
//
//		 // loop through PATH, in REVERSE order, while scanning PART (in rev too)
//		var nPart 					= partComps.count-1		// e.g: 3 [ "", brain1, main]
//		var nPath					= pathComps.count-1;		// e.g: 2         [ "", main]
//
//		 // Check all components specified in Path match
//		while nPath >= 0 && pathComps.count >= 0 {
//			guard nPath>=0 else {break}
//			assert(nPart>=0, "Path has more components than Part.nameFull")
//			var partComp 			= partComps[nPart]
//			var pathComp 			= pathComps[nPath];
//			guard partComp == pathComp else { return false }
//
//			nPath -= 1; nPart -= 1
//		}
//		assert(nPath == 0 && pathComps.count == 0, "if first component is ")
//		return true;							// all tests pass
//	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
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
