////  FwTypes.swift -- Factal Workbench: common Swift types C2018PAK
//import SceneKit
//
///* Future
//CGFloat.NativeType)
//*/
// // For building:
//typealias PartClosure 	= () -> Part?
//typealias FwConfig 		= [String:FwAny]										//https://blog.bobthedeveloper.io/generic-protocols-with-associated-type-7e2b6e079ee2
//
//  // ///////////////////////////////////////////////////////////////////////////
// /// PROTOCOL for all FactalWorkbench (SwiftFactal) Parts
//protocol  FwAny {		// : Codable : Equatable
//	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	//      Call this
//  //Default argument not permitted in a protocol method:
// //	func pp(_ mode:PpMode?, _ aux:FwConfig=[:]) -> String	//      Call this
//	func pp_(_ mode:PpMode?, _ aux:FwConfig) -> String	// Implement this
//	var  fwClassName	: String 	{	get											}
//}
// /// This extending of FwAny allows uniform default values. ??Maybe not needed??
//extension FwAny  {	
//	  // callers        use pp(..)   This has correct defauts
//	 // implementations use pp_(..). This does all the work
//	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig=params4pp) -> String {	// PROTOCOL
//		return pp_(mode, aux)
//	}
//}
// /// Pretty Print Modes:
//enum PpMode : Int {
//	// How to PrettyPrint Name and Class:
//	case fwClassName		// (Really should be "class"?)		(e.g: "Port"
//	case name			// name in parent, a single token 	(e.g: "P")
//	case fullName		// path in composition 				(e.g: "/net/a.P")
//	case id				// Identifier: name/Uid:Class		(e.g: "P/xxx:Port")
//	// How to PrettyPrint Contents:
//	case phrase			// shortest							(e.g: 1/4 line)
//	case line			// single line, often used in .tree	(e.g: 1 line)
//	case tree			// tree of all elements				(e.g: multi-line)
////	case full
//}
//
// // /// EXTENSIONS
////enum FwKinds { case Bool, Int, Int16, Int8, Float, Double, CGFloat, String, NSColor,
////					Part, View, BBox, SCNNode, SCNMaterial, SCNConstraint, Log,
////					SCNMatrix4, SCNVector4, SCNVector3, Array, Dictionary, NSNull, Path
////}
//
//extension Bool			: FwAny 	{}
//extension  Int			: FwAny 	{}
//extension UInt			: FwAny 	{}
//extension  Int16		: FwAny 	{}
//extension UInt16		: FwAny 	{}
//extension  Int8			: FwAny 	{}
//extension UInt8			: FwAny 	{}
//extension Float			: FwAny 	{}
//extension Double		: FwAny 	{}
//extension CGFloat 		: FwAny		{}
//extension String		: FwAny 	{}
//extension NSColor		: FwAny 	{}
//
//extension Part			: FwAny 	{}
//extension View			: FwAny 	{}
//extension BBox			: FwAny 	{}
//
//extension SCNNode		: FwAny 	{}
//extension SCNMaterial	: FwAny 	{}
//extension SCNConstraint	: FwAny 	{}
//extension SCNGeometry	: FwAny 	{
//	func pp_(_ mode: PpMode?, _ aux: FwConfig) -> String { fatalError("\n\n" + "SCNGeometry not supported\n\n") }}
//extension SCNAudioSource: FwAny 	{											
//	func pp_(_ mode: PpMode?, _ aux: FwConfig) -> String { fatalError("\n\n" + "SCNAudioSource not supported\n\n") }}
//extension SCNAudioPlayer: FwAny 	{											
//	func pp_(_ mode: PpMode?, _ aux: FwConfig) -> String { fatalError("\n\n" + "SCNAudioPlayer not supported\n\n") }}
//
//extension Event			: FwAny 	{}
//extension Log			: FwAny 	{}
//extension Path			: FwAny 	{}
//
//extension SCNMatrix4	: FwAny 	{}
//extension SCNVector4	: FwAny 	{}
//extension SCNVector3	: FwAny 	{}
//extension Array			: FwAny 	{}
//extension Dictionary	: FwAny 	{}
//extension NSNull		: FwAny 	{}
//
// // DEFAULT IMPLEMENTATIONS, set to work for most uninteresting types
//extension FwAny  {
//	var fwClassName 	: String 		{ 	/// spruce up desc.
//		let cName 			= String(describing:type(of:self))
//		return [
//			"SCNNode"		:"Scn",
//			"Broadcast"		:"Bcast",
//		][cName] ?? cName
//	}
//	 /// Any to Any
//	/// Shorter Coersion methods: E.G: x as? String ?? "<not string>"  -> x.string
//
//	/// * < TypeA >.as< TypeB >_ -- convert TypeA to TypeB! if possible, else use a standard default.
//	var asBool_ 		  : Bool	{	return asBool ?? false					}
//	/// * < TypeA >.as< TypeB >  -- convert TypeA to TypeB? if possible, else nil.
//	var asBool 			  : Bool? 	{
//		if let b = self as? Bool  	{	return b								}
//		if let i = self as? Int		{	return i >= 1							}
//		if let i = self as? Int8  	{	return i >= 1							}
//		if let i = self as? UInt8 	{	return i >= 1							}
//		if let f = self as? Float	{	return f > 0.5							}
//		if let c = self as? CGFloat	{	return c > 0.5							}
//		if let d = self as? Double	{	return d > 0.5							}
//		if let s = self as? String	{	return Bool(s) ?? false					}
//		return nil
//	}
//	var asInt_ 		 	  : Int		{	return asInt ?? 0						}
//	var asInt 			  : Int? 	{
//		if let b = self as? Bool  	{	return b ? 1 : 0						}
//		if let i = self as? Int  	{	return i								}
//		if let i = self as? Int8  	{	return Int(i)							}
//		if let i = self as? UInt8 	{	return Int(i)							}
//		if let f = self as? Float	{	return Int(f)							}
//		if let c = self as? CGFloat	{	return Int(c)							}
//		if let d = self as? Double	{	return Int(d)							}
//		if let s = self as? String	{	return Int(s)							}
//		return nil
//	}
//	var asFloat_ 		  : Float	{	return asFloat ?? 0.0					}
//	var asFloat 		  : Float? 	{
//		if let b = self as? Bool  	{	return b ? 1.0 : 0.0					}
//		if let i = self as? Int 	{	return Float(i)							}
//		if let i = self as? Int8  	{	return Float(i)							}
//		if let i = self as? UInt8 	{	return Float(i)							}
//		if let f = self as? Float 	{	return f								}
//		if let c = self as? CGFloat	{	return Float(c)							}
//		if let d = self as? Double 	{	return Float(d)							}
//		if let s = self as? String	{	return Float(s)							}
//		return nil
//	}
//	var asCGFloat_ 		  : CGFloat	{	return asCGFloat ?? 0.0					}
//	var asCGFloat 		  : CGFloat?{
//		if let b = self as? Bool  	{	return b ? 1.0 : 0.0					}
//		if let i = self as? Int		{	return CGFloat(i)						}
//		if let i = self as? Int8  	{	return CGFloat(i)						}
//		if let i = self as? UInt8 	{	return CGFloat(i)						}
//		if let f = self as? Float	{	return CGFloat(f)						}
//		if let c = self as? CGFloat {	return c								}
//		if let d = self as? Double	{	return CGFloat(d)						}
//		if let s = self as? String	{	return CGFloat(s)						}
//		return nil
//	}
//	var asDouble_ 		  : Double	{	return asDouble ?? 0.0					}
//	var asDouble 		  : Double? {
//		if let b = self as? Bool  	{	return b ? 1.0 : 0.0					}
//		if let i = self as? Int 	{	return Double(i)						}
//		if let i = self as? Int8  	{	return Double(i)						}
//		if let i = self as? UInt8 	{	return Double(i)						}
//		if let f = self as? Float 	{	return Double(f)						}
//		if let c = self as? CGFloat	{	return Double(c)						}
//		if let d = self as? Double 	{	return d								}
//		if let s = self as? String	{	return Double(s)						}
//		return nil
//	}
//	var asString_ 		  : String	{	return asString ?? ""					}
//	var asString 		  : String?	{
//		if let b = self as? Bool  	{	return b ? "true" : "false"				}
//		if let i = self as? Int		{	return fmt("%d", i)						}
//		if let i = self as? Int8  	{	return fmt("%d", i)						}
//		if let i = self as? UInt8 	{	return fmt("%d", i)						}
//		if let f = self as? Float	{	return fmt("%.3f", f)					}
//		if let c = self as? CGFloat	{	return fmt("%.3f", c)					}
//		if let d = self as? Double	{	return fmt("%.3f", d)					}
//		if let c = self as? NSColor	{	return fmt("%02x %02x %02x",
//				255*c.redComponent, 255*c.greenComponent, 255*c.blueComponent)	}
//		if let s = self as? String	{	return s								}
//		if let f = self as? FwConfig{	return f.pp(.line)						}
//		return pp(.line)						
//	}
//	var asColor_ 		  : NSColor	{	return asColor ?? .purple				}
//	var asColor 		  : NSColor?{	return self as? NSColor					}
//	var asFwConfig_ 	  :FwConfig	{	return asFwConfig ?? [:]				}
//	var asFwConfig 		  :FwConfig?{	return self as?FwConfig					}
//	var asFwAny_ 		  : FwAny	{	return self								}
//	var asFwAny	 		  : FwAny	{	return self								}
//	var asPart_ 		  : Part	{	return asPart!							}
//	var asPart	 		  : Part?	{	return self	as? Part					}
//}
//
//extension Dictionary {
//	  // Easy access: E.g: boolOfKey = hash.bool_("key"), "_" ==> if nil use default
//	 /// :H: Trailing "_"	-- Provide a default if nil
//	func bool_ 	   (_ k:Key) -> Bool	{  return     bool(k) ?? false			}
//	func bool  	   (_ k:Key) -> Bool?	{  return    (self[k] as? FwAny)?.asBool}
//	func int_      (_ k:Key) -> Int		{  return      int(k) ?? 0				}
//	func int       (_ k:Key) -> Int?	{  return    (self[k] as? FwAny)?.asInt	}
//	 // less any-any'ish:
//	func uInt_     (_ k:Key) -> UInt	{  return     uInt(k) ?? 0				}
//	func uInt      (_ k:Key) -> UInt?	{  return     self[k] as? UInt			}
//	func int16_    (_ k:Key) -> Int16	{  return    int16(k) ?? 0				}
//	func int16	   (_ k:Key) -> Int16?	{  let x=self[k] as? Int
//										   return x==nil ? nil : Int16(x!) 	}
//	func uInt16_   (_ k:Key) -> UInt16	{  return   uInt16(k) ?? 0				}
//	func uInt16    (_ k:Key) -> UInt16?	{  let x=self[k] as? Int
//										   return x==nil ? nil : UInt16(x!) 	}
//
//	func int8_     (_ k:Key) -> Int8	{  return     int8(k) ?? 0				}
//	func int8	   (_ k:Key) -> Int8?	{  let x=self[k] as? Int
//										   return x==nil ? nil : Int8(int:x!)	}
//	func uInt8_    (_ k:Key) -> UInt8	{  return    uInt8(k) ?? 0				}
//	func uInt8     (_ k:Key) -> UInt8?	{  let x=self[k] as? Int
//										   return x==nil ? nil : UInt8(int:x!)}
//	func float_    (_ k:Key) -> Float	{  return    float(k) ?? 0.0			}
//	func float     (_ k:Key) -> Float?	{  return (self[k] as? FwAny)?.asFloat 	}
//	func double_   (_ k:Key) -> Double	{  return    double(k) ?? 0.0			}
//	func double    (_ k:Key) -> Double?	{  return (self[k] as? FwAny)?.asDouble }
//	func cgFloat_  (_ k:Key) -> CGFloat {  return  cgFloat(k) ?? 0.0			}
//	func cgFloat   (_ k:Key) -> CGFloat?{  return (self[k] as? FwAny)?.asCGFloat}
//	func string_   (_ k:Key) -> String 	{  return   string(k) ?? ""				}
//	func string    (_ k:Key) -> String?	{  return (self[k] as? FwAny)?.asString }
//	func color0_   (_ k:Key) -> NSColor {  return   color0(k) ?? .purple		}
//	func color0    (_ k:Key) -> NSColor?{  return     self[k] as? NSColor		}
////	func color0    (_ k:Key) -> NSColor?{  return (self[k] as? FwAny)?.asNSColor}
//	func part_     (_ k:Key) -> Part 	{  return     part(k) ?? .null			}
//	func part      (_ k:Key) -> Part?	{  return (self[k] as? FwAny)?.asPart	}
//	func fwConfig_ (_ k:Key) -> FwConfig{  return fwConfig(k) ?? [:]			}
//	func fwConfig  (_ k:Key) -> FwConfig?{ return (self[k] as? FwAny)?.asFwConfig}
//	func scnNode_  (_ k:Key) -> SCNNode {  return  scnNode(k) ?? SCNNode()		}
//	func scnNode   (_ k:Key) -> SCNNode?{  return     self[k] as? SCNNode 		}
////	func scnNode   (_ k:Key) -> SCNNode?{  return (self[k] as? FwAny)?.asSCNNode}
//	func fwAny_    (_ k:Key) -> FwAny 	{  return    fwAny(k) ?? fwNull			}
//	func fwAny     (_ k:Key) -> FwAny?	{  return  self[k] as? FwAny			}
//
//// PROBABLY USELESS
////	 /// :H: Trailing "$"	-- Look in parents and Controller.current
////	func bool$_    (_ k:Key) -> Bool		{  return    bool$(k) ??  false		}
////	func bool$ 	   (_ k:Key) -> Bool?		{  return   lookup(k) as? Bool		??
////										  Controller.current[k] as? Bool		}
////	func int$_     (_ k:Key) -> Int			{  return     int$(k) ??  0			}
////	func int$      (_ k:Key) -> Int?		{  return   lookup(k) as? Int 		??
////										  Controller.current[k] as? Int		}
////	func float$_   (_ k:Key) -> Float		{  return   float$(k) ??  0.0		}
////	func float$    (_ k:Key) -> Float?		{  return   lookup(k) as? Float   	??
////										  Controller.current[k] as? Float		}
////	func cgFloat$_ (_ k:Key) -> CGFloat  	{  return cgFloat$(k) ??  0.0		}
////	func cgFloat$  (_ k:Key) -> CGFloat? 	{  return   lookup(k) as? CGFloat 	??
////										  Controller.current[k] as? CGFloat	}
////	func string$_  (_ k:Key) -> String 		{  return  string$(k) ??  ""		}
////	func string$   (_ k:Key) -> String?		{  return   lookup(k) as? String  	??
////										  Controller.current[k] as? String	}
////	func color0$_  (_ k:Key) -> NSColor  	{  return  color0$(k) ??  .purple	}
////	func color0$   (_ k:Key) -> NSColor? 	{  return   lookup(k) as? NSColor 	??
////										  Controller.current[k] as? NSColor	}
////	func part$_    (_ k:Key) -> Part 		{  return    part$(k) ??  .null		}
////	func part$     (_ k:Key) -> Part?		{  return   lookup(k) as? Part 		??
////										  Controller.current[k] as? Part		}
////	func fwConfig$_(_ k:Key) -> FwConfig 	{ return fwConfig$(k) ??  [:]		}
////	func fwConfig$ (_ k:Key) -> FwConfig?	{  return   lookup(k) as? FwConfig	??
////										  Controller.current[k] as? FwConfig	}
////	func scnNode$_ (_ k:Key) -> SCNNode  	{  return scnNode$(k) ??  SCNNode()	}
////	func scnNode$  (_ k:Key) -> SCNNode? 	{  return   lookup(k) as? SCNNode 	??
////										  Controller.current[k] as? SCNNode	}
////	func fwAny$_   (_ k:Key) -> FwAny 		{  return   fwAny$(k) ??  fwNull	}
////	func fwAny$    (_ k:Key) -> FwAny?		{  return   lookup(k) 				??
////										  Controller.current[k]				}
////	 // Look in all parent
////	private func lookup(_ key:Key) -> FwAny? {
////		var s : Dictionary<Key, Value>?	= self
////		while s != nil {
////			var prefs : FwConfig?		= self as? FwConfig
////			if s![key] != nil {
////				return prefs?[name]
////			}
////			s							= s!["parent"]
////		}
////	}
//}
// /// When keys conflict, pick existing
//func resolveKeys(_ val1:FwAny, _ val2:FwAny) -> FwAny {		return val1			}
//func +=( d0: inout FwConfig, d1:FwConfig) 			  {	d0 = d0 + d1			}
//////func +=( left: inout FwConfig, right:FwConfig){ 	left=left + right	}
//func +( d0:FwConfig, d1:FwConfig) -> FwConfig {
//	var rv					= d0
//																				//rv.merge(d1, uniquingKeysWith: {val0, val1 in
//																				//	log("Key '??': new '\(val0)' overwriting '\(val1)'")
//																				//	return val1
//																				//	//resolveKeys(val0, val1)
//																				//})
//	for (key1, value1) in d1 {
//		if let value0 			= d0[key1] { 	/// key1 in d0: possible conflict
//			atBld(9, FwLog!.log("Dictionary Conflict, Key: \(key1.field(20)) " +
//					"was \(value0.pp(.phrase).field(10)) \t<-- \(value1.pp(.phrase))"))
//		}
//		rv[key1] = value1
//	}
//	return rv
//}
//extension Dictionary {
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig=[:]) -> String	{
//		switch mode! {
//		case .phrase:
//			return count == 0 ? "[]" : "[:\(count) elts]"
//		case .line, .tree:
//			var (rv, sep)			= ("[", "")
//			let k3					= Array(keys).sortIfComparable()
//				//.sorted(by:{(a, b) -> Bool in return a.key < b.key}) {		
//				//.sorted(by:{((key: Key, value: Value), (key: Key, value: Value)) -> Bool in
//				//.sorted(by:>)	//Referencing operator function '<' on 'Comparable' requires that '(key: Key, value: Value)' conform to 'Comparable'
//				//.sorted(by:<)
//				//.sorted(by:{$0.key < $1.key}) {
//				//.sorted(by: ((key: Key, value: Value), (key: Key, value: Value)) -> Bool) -> [(key: Key, value: Value)]
//				//let k2 : Dictionary<Key, Value>.Keys = keys
//			for keyX in k3 {
//				let valX	= self[keyX]
//				if let keyY = keyX as? FwAny,
//				  let valY 	= valX as? FwAny
//				{
//					let m 	= mode == .tree ? PpMode.line : PpMode.phrase
//					rv		+= "\(sep)\(keyY):\(valY.pp(m))"
//				}
//				else {
//					rv 		+= sep + "?\(String(describing:type(of:keyX)))" +
//									 ":\(String(describing:type(of:valX)))"
//				}
//				sep 		=  mode == .tree ? ",\n": ", "
//			}
//			return rv + "]"
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux) // NO: return super.pp_(mode, aux)
//		}
//	}
//}
//
// // Only gets called after CLASS.pp() has given up. It doesn't support exceptions
//			//if self.responds(to:#selector(FwAny.pp(_:_:))) {	}
//func ppFwDefault(self:FwAny, mode:PpMode?, aux:FwConfig) -> String {
//	switch mode! {
//	case .fwClassName:
//		return self.fwClassName
//	case .name:							// -> ""
//		return "_"
//	case .fullName:						// -> .name
//		return self.pp(.name,   aux)
//	case .id:							// -> uid + name + fwClassName
//		return "\(self.pp(.fullName, aux))\(ppUid(pre:".", self as? Uid)):\(self.fwClassName)"
////		return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//	case .phrase:						// -> .id
//		return self.pp(.id,		aux)
//	case .line:							// -> .phrase
//		return self.pp(.phrase, aux)
//	case .tree:							// -> .line
//		return self.pp(.line,   aux)
//	default:							// -> ERROR
//		return "ERROR: pp mode value unsuported"
//	}
//}
//
//// BUG:
////	e.g: Cannot convert value of type '[SCNMaterial]' to expected argument type 'inout Any?'
////	e.g:	self.scn.name? 				??= "*-" + part.name	// DOESN'T WORK
//infix operator ??= : AssignmentPrecedence
////func ??=( lhs: inout FwAny?, rhs:FwAny?)	{
////	if lhs==nil {
////		lhs 			= rhs
////	}
////}
//
///// If lhs is nil, assign lhs to it.
///// - Parameters:
/////   - lhs: --- updated if lhs is nil
/////   - rhs: 
//public func ??=<T>(lhs:inout T?, rhs: T?) {
//	if lhs == nil {
//		lhs = rhs
//	}
//}
//
////func |(  left:Bool, right:Bool) -> Bool {	return left | right		/* OR */	}
////func &(  left:Bool, right:Bool) -> Bool {	return left & right		/* OR */	}
////func ^(  left:Bool, right:Bool) -> Bool {	return left != right	/* EXOR= */	}
////infix operator |= : AssignmentPrecedence
////infix operator &= : AssignmentPrecedence
////infix operator ^= : AssignmentPrecedence
////infix operator ^  : ComparisonPrecedence
////func |=( left: inout Bool, right:Bool) {	left=left | right	/* OR */	}
////func &=( left: inout Bool, right:Bool) {	left=left & right	/* AND */	}
////func ^=( left: inout Bool, right:Bool) {	left=left ^ right	/* EXOR */	}
//
//infix operator ||= : AssignmentPrecedence
//func ||=( left: inout Bool, right:Bool) {	left=left || right	/* OR */	}
//infix operator &&= : AssignmentPrecedence
//func &&=( left: inout Bool, right:Bool) {	left=left && right	/* AND */	}
//infix operator ^^= : AssignmentPrecedence
//func ^^=( left: inout Bool, right:Bool) {	left=left ^^ right	/* EXOR */	}
//infix operator ^^  : ComparisonPrecedence
//func ^^(left:Bool, right:Bool) -> Bool  {	return left != right	/* EXOR= */	}
//
//extension Bool {
//	init?(fwAny:FwAny) {
//		let val:Bool?					=
//				fwAny is Bool 	?			 fwAny as? Bool				:
//				fwAny is String ? (	
//					fwAny as! String == "0" ?	false :		// good coersion
//					fwAny as! String == "1" ?	true  :		// good coersion
//												Bool(fwAny as! String))	:
//				fwAny is Int 	?			(fwAny as! Int) >= 1		:
//				fwAny is Float	?			(fwAny as! Float) >= 0.5	:
//										nil
//		if (val==nil) {
//			return nil
//		}
//		self.init(val!) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
//		if mode == .phrase {
//			return self ? "true" : "false"										}
//		return ppFwDefault(self:self, mode:mode, aux:aux)
//				// NO: return super.pp_(mode, aux)
//	}
//}
//var falseF			= false		// false which supresses optimizer warning
//var  trueF			= true		// true  which supresses optimizer warning
//var  zeroF			= 0			// zero  which supresses optimizer warning
//
////////////////////////// 		Int			/////////////////////////////////
//extension Int {
//	init?(fwAny:FwAny) {
//		let val:Int?					=
//				fwAny is Int 	?			 (fwAny as! Int)				:
//				fwAny is String ?	     Int(fwAny as! String)			:
//				fwAny is Bool   ?	        (fwAny as! Bool ? 1 : 0)	:
//										nil
//		if (val==nil) {
//			return nil
//		}
//		self.init(val!) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return String(self)
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//	static func + ( d0:Int, d1:Int) -> Int {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func += ( d0: inout Int, d1:Int) {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//	static func - ( d0:Int, d1:Int) -> Int {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func -= ( d0: inout Int, d1:Int) {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//}
//
//extension UInt {
////	subscript(value:UInt) -> UInt {
////		get {
////			return self[value]
////		}
////	}
//	func pp_(_ mode:PpMode?	= .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return String(self)
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//	static func + ( d0:UInt, d1:UInt) -> UInt {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func += ( d0: inout UInt, d1:UInt) {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//	static func - ( d0:UInt, d1:UInt) -> UInt {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func -= ( d0: inout UInt, d1:UInt) {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//}
//
//
////////////////////////// 		Int16		/////////////////////////////////
//
//extension Int16 {
////	subscript(value:Int16) -> Int16 {
////		get {
////			return self[value]
////		}
////	}
//	func pp_(_ mode:PpMode?	= .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return String(self)
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//	static func + ( d0:Int16, d1:Int16) -> Int16 {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func += ( d0: inout Int16, d1:Int16) {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//	static func - ( d0:Int16, d1:Int16) -> Int16 {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func -= ( d0: inout Int16, d1:Int16) {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//}
//
//extension UInt16 {
////	subscript(value:UInt16) -> UInt16 {
////		get {
////			return self[value]
////		}
////	}
//	func pp_(_ mode:PpMode?	= .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return String(self)
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//	static func + ( d0:UInt16, d1:UInt16) -> UInt16 {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func += ( d0: inout UInt16, d1:UInt16) {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//	static func - ( d0:UInt16, d1:UInt16) -> UInt16 {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func -= ( d0: inout UInt16, d1:UInt16) {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//}
//
//
////////////////////////// 		Int8		/////////////////////////////////
//extension Int8	{
//	init(int n:Int) {
//		assert(n >= -127 && n<127, "overflow")
//		self.init(n)
//	}
//	init?(fwAny:FwAny) {
//		let val:Int8?					=
//				fwAny is Int 	?		Int8(int:fwAny as! Int)			:
//				fwAny is String ?	    Int8(fwAny as! String)			:
//				fwAny is Bool   ?	        (fwAny as! Bool ? 1 : 0)	:
//										nil
//		if (val==nil) {
//			return nil
//		}
//		self.init(val!) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//	}
//	func pp_(_ mode: PpMode?, _ aux: FwConfig) -> String {
//		return String(self)
//	}
//	static func + ( d0:Int8, d1:Int8) -> Int8 {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func += ( d0: inout Int8, d1:Int8) {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//	static func - ( d0:Int8, d1:Int8) -> Int8 {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		return d
//	}
//	static func -= ( d0: inout Int8, d1:Int8) {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "overflow")
//		d0 = d
//	}
//}
//
//extension UInt8 {
//	init(int n:Int) {
//		assert(n>=0 && n<256, "overflow")
//		self.init(n)
//	}
//	func pp_(_ mode: PpMode?, _ aux: FwConfig) -> String {
//		return String(self)
//	}
//	static func + ( d0:UInt8, d1:UInt8) -> UInt8 {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "UInt8 '+' overflows")
//		return d
//	}
//	static func += ( d0: inout UInt8, d1:UInt8) {
//		let (d, overflow) 		= d0.addingReportingOverflow(d1)
//		assert(!overflow, "UInt8 '+=' overflows")
//		d0 = d
//	}
//	static func - ( d0:UInt8, d1:UInt8) -> UInt8 {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "UInt8 '-' overflows")
//		return d
//	}
//	static func -= ( d0: inout UInt8, d1:UInt8) {
//		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
//		assert(!overflow, "UInt8 '-=' overflows")
//		d0 = d
//	}
//}
//
//extension Float	{
//	var isNan			: Bool 		{	return self != self						}
//	static func random(from n1:Float, to n2:Float) -> Float {
//		let rand		= (Float(arc4random()) / 0x100000000)
////		let rand		= (Float(arc4random()) / 4294967296) // 0xFFFFFFFF + 1
//		return n1 + (n2 - n1) * rand
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return String(self)
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//}
//
//extension Double	{
//	var isNan			: Bool 		{	return self != self						}
//	static func random(from n1:Double, to n2:Double) -> Double {
//		let rand		= (Double(arc4random()) / 0xFFFFFFFF)
//		return n1 + (n2 - n1) * rand
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return String(self)
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//}
//func pegBetween0n1<T: Comparable & FloatingPoint>(_ v: T) -> T { return max(min(v, 1), 0) }
//extension FloatingPoint {
// /// THIS SHOULD WORK, BUT DOESN't
////	func pegBetween0n1<T: Comparable & FloatingPoint>() -> T 	{	return T(min(max(self, 1), 0))	}
//}
//extension CGFloat {
//	init?(_ string:String) {
//		if let f = Float(string) {
//			self = CGFloat(f)
//		}
//		else {
//			return nil
//		}
//	}
//	var isNan			: Bool 		{
//		return self != self
//	}
//
//	static func random(from n1:CGFloat, to n2:CGFloat) -> CGFloat {
//		let rand		= (CGFloat(arc4random()) / 0xFFFFFFFF)
//		return n1 + (n2 - n1) * rand
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return self.description
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//}
//
////func allItemsMatch<C1: Container, C2: Container>
////    (_ someContainer: C1, _ anotherContainer: C2) -> Bool
////    where C1.Item == C2.Item, C1.Item: Equatable {
////func !~= <left:V, right:V>(_ left:V, _ right:V) -> Bool {
////	return abs(left - right) < NSValue(epsilon)									}
//
//func ~==( left:Float, right:Float) -> Bool {
//	return abs(left-right) < Float(epsilon)										}
//func ~==( left:Double, right:Double) -> Bool {
//	return abs(left-right) < Double(epsilon)									}
//func ~==( left:CGFloat, right:CGFloat) -> Bool {
//	return abs(left-right) < CGFloat(epsilon)									}
//
//func !~==( left:Float, right:Float) -> Bool {
//	return abs(left-right) > Float(epsilon)										}
//func !~==( left:Double, right:Double) -> Bool {
//	return abs(left-right) > Double(epsilon)									}
//func !~==( left:CGFloat, right:CGFloat) -> Bool {
//	return abs(left-right) > CGFloat(epsilon)									}
//
//// https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
////					let text		= "Hello world"
////					let a 			= text[...3]							// "Hell"
////					let a2 			= text[1...]							// "Hell"
////					//let a3 		= text[1...3]							// "Hell"
////					//let b 		= text[6..<text.count] 					// world
////					let c 			= text[NSRange(location: 6, length: 3)]	// wor
////					print(a,c)
////					//let newStr = str.substring(from: index) // Swift 3
////					let newStr = String(valStr[index...]) // Swift 4
//extension String : Uid {
//	var uid: UInt16 {		return SwiftFactals.uid(nsOb:(self as? NSObject)!)	}
//}
//extension String {
//	subscript(value: NSRange) -> Substring {
//		return self[value.lowerBound..<value.upperBound]
//	}
//}
//extension String {
//	subscript(value: CountableClosedRange<Int>) -> Substring {
//		get {
//			return self[index(at: value.lowerBound)...index(at: value.upperBound)]
//		}
//	}
//	subscript(value: CountableRange<Int>) -> Substring {
//		get {
//			return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
//		}
//	}
//	subscript(value: PartialRangeUpTo<Int>) -> Substring {
//		get {
//			return self[..<index(at: value.upperBound)]
//		}
//	}
//	subscript(value: PartialRangeThrough<Int>) -> Substring {
//		get {
//			return self[...index(at: value.upperBound)]
//		}
//	}
//	subscript(value: PartialRangeFrom<Int>) -> Substring {
//		get {
//			return self[index(at: value.lowerBound)...]
//		}
//	}
//	func index(at offset: Int) -> String.Index {
//		return index(startIndex, offsetBy: offset)
//	}
//}
//
//extension String {
//	subscript (bounds: CountableClosedRange<Int>) -> String {
//		let start = index(startIndex, offsetBy: bounds.lowerBound)
//		let end = index(startIndex, offsetBy: bounds.upperBound)
//		return String(self[start...end])
//	}
//	subscript (bounds: CountableRange<Int>) -> String {
//		let start = index(startIndex, offsetBy: bounds.lowerBound)
//		let end = index(startIndex, offsetBy: bounds.upperBound)
//		return String(self[start..<end])
//	}
//
//	 /// Fixed length field to format a String
//	/// - Parameters:
//	///		- _: 		------ length of field, in characters
//	///		- dots: 	------ add "..." at end, to show truncation
//	///		- fill: 	------ string to fill with
//	/// - Parameter grow: ------ allow long fields to exceed length
//	func field(_ length:Int, dots:Bool=true, fill:Character?=" ", grow:Bool=false) -> String {
//		let excess 				= self.count - abs(length)	// amount string is too big
//		if excess > 0 && grow {
//			return self
//		}
//		let truncLen			= max(0, abs(length) - (dots ? 2:0))
//		let truncDots			= dots ? "..":""
//
//		//										excess=-5 <0	excess=3 >0
//		// 	Arguments:			\	Input:	abc				abcdefghijk
//		// 	length---------dots--			--------		--------
//		// 	>0 (RIGHT)		no			  A:_____abc	  B:defghijk
//		// 	>0 (RIGHT)		yes			  C:_____abc	  D:..fghijk
//
//		// 	<0 (LEFT)		no			  E:abc_____	  F:abcdefgh
//		// 	<0 (LEFT)		yes			  G:abc_____	  H:abcdef..
//		if (length >= 0) {								// RIGHT justified
//			return excess > 0 ?								//    dots      !dots
//				truncDots + String(suffix(truncLen)):		// D:..fghijk B:defghijk
//				   fill==nil ? self :						//      A:abc      C:abc
//				String(repeating:fill!,count:-excess) + self// A:_____abc C:_____abc
//		} else {
//			return excess > 0 ?							// LEFT justified
//				String(prefix(truncLen)) + truncDots :		// F:abcdefgh H:abcdef..
//				   fill==nil ? self :						//      E:abc      G:abc
//				self + String(repeating:fill!,count:-excess)// E:abc_____ G:abc_____
//		}
//	}
//
//	func contains(substring str:String) -> Bool {
//		return range(of:str) != nil												}
//	func fieldTests() {
//		print("abcdefghijklmnopqrstuvwxyz".field(-14, dots:false), "|")
//		print("abcdefghijklmnopqrstuvwxyz".field(-14, dots:true),  "|")
//		print("abcdefgh".field(-14, 				  dots:false), "|")
//		print("abcdefgh".field(-14, 				  dots:true),  "|")
//		print("abcdefghijklmnopqrstuvwxyz".field( 14, dots:false), "|")
//		print("abcdefghijklmnopqrstuvwxyz".field( 14, dots:true),  "|")
//		print("abcdefgh".field( 14, 				  dots:false), "|")
//		print("abcdefgh".field( 14, 				  dots:true),  "|")
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
//		switch mode! {
//		case .id:
//			return "\(ppUid(self, post:"."))\"\(self)\" :\(self.fwClassName)"
//		case .name:
//			return "_"
//		case .phrase, .line, .tree:
//			return self
//		default:
//			return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//	func stripLeadingNewLines() -> (String, String) {
//		var (s, rv)				= (self, "")
//		while s.hasPrefix("\n") {
//			s 					= String(s.dropFirst())
//			rv					+= "\n"
//		}
//		return (rv, s)
//	}
//	func removeUnneededSpaces() -> String {
//		var str = self
//		 /// Use shorter names:
//		for (key,val) in [
//							"[ "	:"[",
//							"< "	:"<",
//							"  "	:" ",
//							" -"	:"-",
//						  ] {
//			str = str.replacingOccurrences(of:key, with:val)
//		}
//		return str
//	}
//	func shortenStringDescribing() -> String {
//		  /// Eliminate hex address, which is from first " " to following "|"
//		 /// e.g. "<SCNNode: 0x6040001e4d00 pos(5.000000 15.000000 5.000000) | light=<SCNLight: 0x6040001e4700 | type=omni> | no child>"
//		let regex = try! NSRegularExpression(pattern: "\\b0x[0-9a-f]*")
//		var str = regex.stringByReplacingMatches(in: self, options: [],
//								range:NSRange(0..<self.count), withTemplate: "")
//		 /// Use shorter names:
//		for (key,val) in [
//			"  ":" ",   				"|":"",
//			"00"			:"",
//			"SCN"			:"", 		"Geometry: "	:"",
//			"Cylinder"		:"Cyl",		"3DPictureframe":"3DFrame",
//
//		/*	"elementsXX":"elts",	*/	"elements "		:"elts",
//
//			"radius"		:"r", 		"height"		:"h",
//			"width"			:"w", 		"length"		:"l", 	"chamferRadius":"cr",
//			"topRadius"		:"rT", 		"bottomRadius"	:"rB",
//			"ringRadius"	:"rR", 		"pipeRadius"	:"rP",
//			"innerRadius"	:"iR", 		"outerRadius"	:"oR",
//			"'material'"	: "",
//
//			"SwiftFactals."	:"", 		"SwiftFactals"	:"",
//						  ] {
//			str = str.replacingOccurrences(of:key, with:val)
//		}
//		return str
//	}
//}
//
// // 180623 Why doesn't this work?		// public?
//extension NSObject : Uid {
//
//	var uid: UInt16 			{ 	return SwiftFactals.uid(nsOb:self)			}
////	func fooFoo() {}
//
//
//	func testExceptionHandler2(string: String, filename: String) -> Bool {
//
//		NSObject.startHandlingExceptions()
//
//		 // Test 1: OPEN file for writing:
//		let nextEntry			= wallTime("YYMMDD.HHMMSS: ") + " FOO MUM BAR\n"
//		let documentDirURL 		= try! FileManager.default.url(
//										for:.documentDirectory,
//										in:.userDomainMask,
//										appropriateFor:nil,
//										create:true)
//		let fileURL 			= documentDirURL.appendingPathComponent("logOfRuns")
//		let fileUpdater			= try? FileHandle(forUpdating:fileURL)
//
//		fileUpdater!.seekToEndOfFile()		// Start writing at EOF
//		fileUpdater!.write(nextEntry.data(using:.utf8)!)
//		fileUpdater!.closeFile()
//	
//		 // Test 2: 
//		guard let fileHandle	= FileHandle(forUpdatingAtPath: filename) else { return false }
//		// will cause seekToEndOfFile to throw an excpetion
//		fileHandle.closeFile()
//		fileHandle.seekToEndOfFile()
//		fileHandle.write(string.data(using:.utf8)!)
//
//		NSObject.stopHandlingExceptions()
//	
//		return true
//	}
//
//	static var existingHandler: (@convention(c) (NSException) -> Void)?
//	static func startHandlingExceptions() {
//		NSObject.existingHandler = NSGetUncaughtExceptionHandler()
//		NSSetUncaughtExceptionHandler({ exception in
//			print("exception: \(exception))")
//			NSObject.existingHandler?(exception)
//		})
//	}
//	static func stopHandlingExceptions() {
//		NSSetUncaughtExceptionHandler(NSObject.existingHandler)
//		NSObject.existingHandler = nil
//	}
//
//	var fwClassName : String {
//		get {
//			var cn		= className
//			let module	= "SwiftFactals"
//			if cn.hasPrefix(module) {
//				cn		= String(cn.dropFirst(module.count + 1))
//			}
//			return cn
//		}
//	}
//	 // MARK: ??. log
//	func logg(banner:String?=nil, _ format:String, _ args:CVarArg..., terminator:String?=nil) {
//		let (nl, fmt)			= format.stripLeadingNewLines()
//		let str					= nl + "\(ppUid(self)):\(self.fwClassName):".field(-18) + fmt
//		FwLog!.log(banner:banner, str, args, terminator:terminator)
//	}
//}
//
//extension Array where Element: Equatable {
//	func distinct(anObject:Element) -> [Element]{
//		var unique = [Element]()
//		for elt in self {
//			if !unique.contains(elt){
//				unique.append(elt)
//			}
//		}
//		return unique
//	}
//	mutating func fooBar(anObject:Element) -> Element? {
//		if self.contains(anObject) {
//			return anObject
//		}
//		return nil
//	}
////	mutating func addIfAbsent(anObject:Element) -> Element {
////		if !self.contains(anObject) {
////			self.append(anObject)
////		}
////		return anObject
////	}
//	mutating func setObject(at index:Int, toValue:Element) {
//		while self.count <= index {				// extend self to have an object[index]
//			self.append(toValue)
//		}
//		self[index]			= toValue
//	}
//	mutating func dequeFromHead() -> Element? {
//		var rv : Element?	= nil
//		if count > 0 {
//			rv 				= self[0]
//			removeFirst()
//		}
//		return rv
//	}
//}
//
//extension Array where Element: Comparable {
//	func sortIfComparable() -> Array {
//		return sorted()
//	}
//}
//extension Array {
//	func sortIfComparable() -> Array {
//		return self
//	}
//	func pp_(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
//		switch mode! {
//			case .phrase:
//				return count == 0 ? "[]" : "[:\(count) elts]"
//			case .line:
//				var (rv, sep)	= ("[", "")
//				for elt in self {
//					rv			+= sep + ppFwDefault(self:elt as! FwAny, mode:.phrase, aux:aux)
//					sep 		= ", "
//				}
//				return rv + "]"
//			case .tree:
//				var (sep, rv)	= ("", "[")
//				for elt in self {
//					rv			+= sep + ppFwDefault(self:elt as! FwAny, mode:.line, aux:aux)
//					sep 		= ",\n "
//				}
//				return rv + "]"
//			default:
//				return ppFwDefault(self:self, mode:mode, aux:aux)
//		}
//	}
//}
//
////class BoxedArray<T> : MutableCollection {
////
////	var array : Array<T> 		= []
////
////	var startIndex: Int						{	return 0 						}
////	var endIndex: Int						{	return array.count-1 			}
////	func index(after i: Int) -> Int 		{	return i + 1					}
////	func insert(_ obj:T, at index:Int)		{	array.insert(obj, at:index)		}
////	func remove(at index:Int)				{	array.remove(at:index)			}
////
////	init() {}
////
////	subscript (index: Int) -> T {
////		get { return array[index] }
////		set(newValue) { array[index] = newValue }
////	}
////}
//extension NSColor {
//	func pp_(_ mode:PpMode? = .tree, _ aux_: FwConfig) -> String {
//		return "NSColor"
////		panic(); return "yeuch"
//	}
//}
//extension NSNull {
//	func pp_(_ mode:PpMode? = .tree, _ aux_: FwConfig) -> String {
//		return "NSNull"
////		panic(); return "yeuch"
//	}
//}
//
//let fwNull : FwAny = (NSNull() as NSObject) as! FwAny
////		      return (NSNull() as NSObject) as! FwAny			/// NSNull
//
//extension DispatchSemaphore {
//	var value : Int? {
//		let str				= debugDescription
//		let valueRange		= str.range(of:"value")
//		let a:String.Index	= valueRange!.upperBound
//		let str0			= str.index(a, offsetBy: 3)	// skip over " = "
//		let valuePP			= str[str0...].split(separator:",")
//		return Int(String(valuePP[0])) ?? -999
//	}
//}
//
//							//// TESTING ////
//func fwTypesTest() -> Bool {
//	print("""
//		\n\n\n
//		 ============================================================================
//		======================== Testing with fwTypesTest(): =========================
//		""")
//
//	 /// All these Object Kinds
//	let objects :[FwAny] = [
//		SCNMatrix4(1.0,2.0,3.0,4.0,  1.1,1.2,1.3,1.4,  2.1,2.2,2.3,2.4,  1.1,1.2,1.3,1.4),
//		SCNVector3(1,2,3),
//		String("abcdefg"),
//		Bool(true),
//		Int(1234),
//		Int16(32767),					// No Int8 or UInt*
//		Float(12.34),
//		CGFloat(777.2),
//		//Array(),
//		//Dictionary(),
//		//NSObject(),					// needs work
// // 190627 eliminated
////		Port(),
////		MaxOr(),						// needs work, ...
////		Net(["parts":[Port(), MaxOr()]]),
//		//-------- top -------
//		SCNVector4(1.0,2.0,3.0,4.0),	// ppXYZMask == 7?
//		SCNMatrix4Identity,				// test the various stringification of various forms
//					]
//					
//
//	for obj in objects {
//		print("\n"+"======== \(obj.pp(.fwClassName)) ==========")
//		print("   pp( .fwClassName )  -->  \(obj.pp(.fwClassName))")
//		print("   pp( .id        )  -->  \(obj.pp(.id))")
//		print("   pp( .name      )  -->  \(obj.pp(.name))")
//		print("   pp( .fullName  )  -->  \(obj.pp(.fullName))")
//		print("   pp( .phrase    )  -->  \(obj.pp(.phrase))")
//		print("   pp( .line      )  -->  \(obj.pp(.line))")
//		print("   pp( .tree      )  --> ------------------\n\(obj.pp(.tree))"
//			   + "\n" + "-----------------------------------------------")
//	}
////	print("Look okay? [y]")
////	let pass = readLine()
////	let p						= pass == nil || pass == "y" || pass == ""
////	print("\"\(pass)\" -> " + (p ? "PASS" : "FAIL\n"))
////	return p
//	return true
//}
//
///// No Operation
///// * A legal statement that does nothing and returns nothing.
//var nop : () 		{		return 												}
////func nop()		{					}
//
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
////
////// want Swift equivalent for: void panic_gutsC(const char *fmt, ...) __attribute__ ((format (printf, 1, 2)))
//////int	 fprintf(FILE * __restrict, const char * __restrict, ...) __printflike(2, 3);
//////#define __printflike(a,b) __attribute__((format(printf, a, b)))
////
////func fmt(_ format:String, _ args:CVarArg...) -> String {
////	return  String(format:format, arguments:args)
////}
////
//
//
