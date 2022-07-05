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
class Path : NSObject, Codable {						// NOT NSObject

	 // MARK: - 1. Class Variables:
	static let shortNames		= [ "=":"direct", "%":"flipPort", "^":"noCheck",
									"!":"dominant", "@":"invisible"]
	 // MARK: - 2. Object Variables:
	var atomTokens : [String]			// array of tokens in reversed order
										// abs has trailing "" string
										// (no Port or Link Options)
	var portName   :  String? 	= nil	// after last '.'

	 /// Link's required propeties.
	var linkProps 	: FwConfig 	= [:]	// e.g. l=3

	func fullName() -> String {	// tokens and Port
		return atomTokens.reversed().joined(separator:"/") +
				(portName==nil ? "" : "." + portName!)
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
			assert(nameVal.count==2, "Syntax: '\(option)' not of form <prop>:<val>")
			linkProps[nameVal[0]] = nameVal[1]
		}
		 // Strip trailing characters			//#  E.G: "l:5", "@" and "="
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
		atSer(3, logd("Encoded  as? Path        '\(String(describing: fullName))'"))
	}
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:PathKeys.self)
		atomTokens				= try container.decode([String].self, forKey:.atomTokens)
bug;	portName  				= try container.decode( String?.self, forKey:.portName)
//		linkProps 				= try container.decode(FwConfig.self, forKey:.linkProps)

		super.init()
 		atSer(3, logd("Decoded  as? Path       named  '\(String(describing: fullName))'"))
	}
	 // MARK: - 3.6 NSCopying
	func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : Path		= Path(withName:"")//super.copy(with:zone) as! Path
		theCopy.atomTokens 		= self.atomTokens
		theCopy.portName   		= self.portName
		theCopy.linkProps	  	= self.linkProps
		atSer(3, logd("copy(with as? Path       ''"))
		return theCopy
	}

	 // MARK: - 3.7 Equitable
	func varsOfPathEq(_ rhs:Part) -> Bool {
		guard let rhsAsPath	= rhs as? Path else {	return false				}
bug;	return atomTokens 		== rhsAsPath.atomTokens
			&& portName   		== rhsAsPath.portName
		//	&& linkProps	  	== rhsAsPath.linkProps
	}
	func equalsPart(_ part:Part) -> Bool {
bug;	return	/*super.equalsPart(part) &&*/ varsOfPathEq(part)
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode: PpMode? = .tree, _ aux: FwConfig=[:]) -> String {
		switch mode! {
		case .phrase, .short, .line, .tree:
			return fullName() + ",[" + ppLinkProps() + "]"
		case .name, .fullName:
			return "<nameless>"
		default:	// only root depricates
			return ppDefault(self:self, mode:mode, aux:aux) // NO: return super.pp(mode, aux)
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
//	override var description	  :String 	{	return  "\"\(pp(.short))\""		}
//	override var debugDescription :String	{	return   "'\(pp(.short))'"		}
//	var summary			 :String	{	return   "<\(pp(.short))>"				}
}
