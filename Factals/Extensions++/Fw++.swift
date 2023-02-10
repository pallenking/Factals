//  FwTypes.swift -- Factal Workbench: common Swift types C2018PAK
import SceneKit
import SwiftUI

//static let error<C:FwAny>		= C()	// Any use of this should fail (NOT IMPLEMENTED)

  // ///////////////////////////////////////////////////////////////////////////
 /// For FactalWorkbench (SwiftFactal) Parts
protocol  FwAny  {		// : Codable : Equatable
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String
	var  fwClassName	: String 	{	get										}
}
 /// This extension provides uniform default values.
extension FwAny  {
	  // Default implementation, with default values:
	 // N.B: If this loops forever, check self's class .pp protocol
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig=params4aux) -> String {
		return pp(mode, aux)
	}
	var fwClassName 	: String 		{
		return String(describing:type(of:self))
	}
}

 /// Pretty Print Modes:
enum PpMode : Int {
	 // How to PrettyPrint Name and Class:
	case fwClassName	//    (Really should be "class"?)		(e.g: "Port"
	case uid			// 10 Uid								(e.g: "4C4")
	case uidClass		//5,8 Uid:Class							(e.g: "4C4:Port")
	case classUid		//  9 Class<uid>						(e.g: "Port<4C4>")
  
	case name			//6,14name in parent, a single token 	(e.g: "P")
	case nameUidClass	//  7 name/Uid:Class					(e.g: "P/4C4:Port")
  
	case fullName		// 13 path in composition 				(e.g: "/net/a.P")
	case fullNameUidClass//11 Identifier: fullName/Uid:Class	(e.g: "ROOT/max.P/4C4:Port")
  
	 // How to PrettyPrint Contents:
	case phrase			//  4 shortened form, sub short		(e.g: [z:1]
	case short			//  3 shortest, canonic form			(e.g: [0.0, 0.0, 0.0]
	case line			//  2 single line, often used in .tree	(e.g: 1 line)
	case tree			//  1 tree of all elements				(e.g: multi-line)
}//x 3->14

 // For building:
typealias PartClosure 		= () -> Part?
typealias FwConfig  		= [String:FwAny]									//https://blog.bobthedeveloper.io/generic-protocols-with-associated-type-7e2b6e079ee2

 // FwAny: Types known to the Factal Workbench (FW) system
extension Bool			: FwAny 	{}
extension  Int			: FwAny 	{}
extension UInt			: FwAny 	{}
extension  Int16		: FwAny 	{}
extension UInt16		: FwAny 	{}
extension  Int8			: FwAny 	{}
extension UInt8			: FwAny 	{}
extension Float			: FwAny 	{}
extension Double		: FwAny 	{}
extension CGFloat 		: FwAny		{}
extension String		: FwAny 	{}

extension Vew			: FwAny 	{}	//x Extension outside of file declaring class 'Vew' prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
extension Part			: FwAny 	{}
extension BBox			: FwAny 	{}

extension FwwEvent		: FwAny 	{}
//extension Log		: FwAny 	{}
extension Path			: FwAny 	{}

extension SCNVector4	: FwAny 	{}
extension SCNVector3	: FwAny 	{}

extension NSColor		: FwAny 	{}	//x Extension outside of file declaring class 'NSColor' prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
extension SCNMatrix4	: FwAny 	{}	//code Extension outside of file declaring struct 'CATransform3D' prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
extension Array 		: FwAny		{
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
		switch mode! {
			case .phrase, .short:
				return count == 0 ? "[]" : "[\(count) elts]"
			case .line:
				var (rv, sep)	= ("[", "")
				for elt in self {
					rv			+= sep + ppDefault(self:elt as! FwAny, mode:.short, aux:aux)
					sep 		= ", "
				}
				return rv + "]"
			case .tree:
				var (sep, rv)	= ("", "[")
				for elt in self {
					rv			+= sep + ppDefault(self:elt as! FwAny, mode:.line, aux:aux)
					sep 		= ",\n "
				}
				return rv + "]"
			default:
				return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
}

extension SCNScene 		: FwAny		{
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{	return "SCNScene:\(ppUid(self)) " }
}
extension NSView 		: FwAny		{		// also SCNView
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		let className			= self is SCNView ? "SCNView" : "NSView"
		switch mode ?? .nameUidClass {
		case .fwClassName:
			return className
		case .uid:
			return ppUid(self)
		case .line:
			return self.pp(.classUid)
		default:
			return "\(className):\(ppUid(self))"
		}
	}
}
extension FactalsDocument 	: FwAny { }
extension Dictionary		: FwAny {
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig=[:]) -> String	{
		switch mode! {
		case .phrase, .short:
			return count == 0 ? "[:]" : "[:\(count) elts]"
		case .line, .tree:
			var (rv, sep)		= ("[", "")
			var k3:Array<Key>	= Array(keys)
			let m 				= mode == .tree ? PpMode.line : PpMode.short	// downgrade mode
			for key in k3 {
				rv				+= "\(sep)\(key):\((self[key] as! FwAny).pp(m))"
				sep 			=  mode == .tree ? ",\n": ", "
			}
			return rv + "]"
		default:
			return ppDefault(self:self, mode:mode, aux:aux) // NO: return super.pp(mode, aux)
		}
	}
}
extension Dictionary where Key:Comparable, Value:FwAny {	// Comparable	//, Value:Equatable, Value :FwAny
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig=[:]) -> String	{
		switch mode! {
		case .phrase, .short:
			return count == 0 ? "[:]" : "[:\(count) elts]"
		case .line, .tree:
			var (rv, sep)		= ("[", "")
			for key in Array(keys).sorted() {
				let val			= self[key]!
				let m 			= mode == .tree ? PpMode.line : PpMode.short
				rv				+= "\(sep)\(key):\(val.pp(m))"
				sep 			= mode == .tree ? ",\n":  mode == .line ? ", " : "???"
			}
			return rv + "]"
		default:
			return ppDefault(self:self, mode:mode, aux:aux) // NO: return super.pp(mode, aux)
		}
	}
}



extension NSNull		: FwAny 	{}	//extend Extension outside of file declaring class 'NSNull' prevents automatic synthesis of 'init(from:)' for protocol 'Decodable'
extension SCNNode		: FwAny 	{}	// Extension outside of file declaring class 'SCNNode' prevents automatic synthesis of 'init(from:)' for protocol 'Decodable'
extension FwGuts		: FwAny 	{}	// Extension outside of file declaring class 'FwGuts' prevents automatic synthesis of 'init(from:)' for protocol 'Decodable'
extension RootScn		: FwAny		{}
extension SCNMaterial	: FwAny 	{}	// Extension outside of file declaring class 'SCNMaterial' prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
extension SCNConstraint	: FwAny 	{}	// Extension outside of file declaring class 'SCNConstraint' prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
extension SCNGeometry	: FwAny 	{	// Extension outside of file declaring class 'SCNGeometry' prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
	func pp(_ mode: PpMode?, _ aux: FwConfig) -> String {
		return ppDefault(self:self, mode:mode, aux:aux)
	}
}
extension SCNAudioSource: FwAny 	{
	func pp(_ mode: PpMode?, _ aux: FwConfig) -> String {
		return ppDefault(self:self, mode:mode, aux:aux)		//fatalError("\n\n" + "SCNAudioSource not supported\n\n")
	}
}
extension SCNAudioPlayer: FwAny 	{
	func pp(_ mode: PpMode?, _ aux: FwConfig) -> String {
		return ppDefault(self:self, mode:mode, aux:aux)		//fatalError("\n\n" + "SCNAudioPlayer not supported\n\n")
	}}

/* Future
CGFloat.NativeType)
*/

// ///////////////////////////// FW_EVENT //////////////////////////////////////
enum FwType : String {
	case nop					= "nop"
	case writeHeadConcieve		= "writeHeadConcieve"
	case writeHeadLabor			= "writeHeadLabor"
	case clockPrevious			= "clockPrevious"
	case reconfigure			= "reconfigure"
}

enum FwError: Error {
	case string(_ kind:String)		// To Swift.throw a meaningess string
}
//
//class FwEvent {							// NOT NSObject
//	let fwType : FwType
//
//	let	nsType : Int 			= 999
//		// As defined in NSEvent.NSEventType:
//		//NSLeftMouseUp 		NSRightMouseDown 	NSRightMouseUp NSMouseMoved
//		//NSLeftMouseDragged	NSRightMouseDragged
//		//NSMouseEntered 		NSMouseExited
//		//NSKeyDown 			NSKeyUp 			NSFlagsChanged (deleted PAK170906)
//		//NSPeriodic 			NSCursorUpdate		NSScrollNSTablet 	NSTablet
//		//NSOtherMouse 			NSOtherMouseUp		NSOtherMouseDragged
//		//NSEventTypeGesture	NSEventTypeMagnify	NSEventTypeSwipe 	NSEventTypeRotate
//		//NSEventTypeBeginGesture NSEventTypeEndGesture NSEventTypeSmartMagnify NSEventTypeQuickLook
//	var clicks		 : Int		= 0		// 1, 2, 3?
//	var key			 :Character = " "
//	var modifierFlags : Int64	= 0
//		// As defined in NSEvent.modifierFlags:
//		// NSAlphaShiftKeyMask 	NSShiftKeyMask 		NSControlKeyMask 	NSAlternateKeyMask
//		// NSCommandKeyMask 	NSNumericPadKeyMask NSHelpKeyMask 		NSFunctionKeyMask
//	var mousePosition:SCNVector3 = .zero	// after[self convertPoint:[theEvent locationInWindow] fromVew:nil]
//	var deltaPosition:SCNVector3 = .zero	// since last time
//	var deltaPercent :SCNVector3 = .zero	// since last time, in percent of screen
//	var scrollWheelDelta		= 0.0
//
//	init(fwType f:FwType) {
//		fwType 					= f
//	}
//}
// ///////////////////////////// END FW_EVENT //////////////////////////////////////

 // DEFAULT IMPLEMENTATIONS, set to work for most uninteresting types
extension FwAny  {
	 // Any to Any
	// Shorter Coersion methods: E.G: x as? String ?? "<not string>"  -> x.string

	/// * < TypeA >.as< TypeB >_ -- convert TypeA to TypeB! if possible, else use a standard default.
	var asBool_ 		  : Bool	{	return asBool ?? false					}
	/// * < TypeA >.as< TypeB >  -- convert TypeA to TypeB? if possible, else nil.
	var asBool 			  : Bool? 	{
		if let b = self as? Bool  	{	return b								}
		if let i = self as? Int		{	return i >= 1							}
		if let i = self as? Int8  	{	return i >= 1							}
		if let i = self as? UInt8 	{	return i >= 1							}
		if let f = self as? Float	{	return f > 0.5							}
		if let c = self as? CGFloat	{	return c > 0.5							}
		if let d = self as? Double	{	return d > 0.5							}
		if let s = self as? String	{	return Bool(s) ?? false					}
		return nil
	}
	var asInt_ 		 	  : Int		{	return asInt ?? 0						}
	var asInt 			  : Int? 	{
		if let b = self as? Bool  	{	return b ? 1 : 0						}
		if let i = self as? Int  	{	return i								}
		if let i = self as? Int8  	{	return Int(i)							}
		if let i = self as? UInt8 	{	return Int(i)							}
		if let f = self as? Float	{	return Int(f)							}
		if let c = self as? CGFloat	{	return Int(c)							}
		if let d = self as? Double	{	return Int(d)							}
		if let s = self as? String	{	return Int(s)							}
		return nil
	}
	var asFloat_ 		  : Float	{	return asFloat ?? 0.0					}
	var asFloat 		  : Float? 	{
		if let b = self as? Bool  	{	return b ? 1.0 : 0.0					}
		if let i = self as? Int 	{	return Float(i)							}
		if let i = self as? Int8  	{	return Float(i)							}
		if let i = self as? UInt8 	{	return Float(i)							}
		if let f = self as? Float 	{	return f								}
		if let c = self as? CGFloat	{	return Float(c)							}
		if let d = self as? Double 	{	return Float(d)							}
		if let s = self as? String	{	return Float(s)							}
		return nil
	}
	var asCGFloat_ 		  : CGFloat	{	return asCGFloat ?? 0.0					}
	var asCGFloat 		  : CGFloat?{
		if let b = self as? Bool  	{	return b ? 1.0 : 0.0					}
		if let i = self as? Int		{	return CGFloat(i)						}
		if let i = self as? Int8  	{	return CGFloat(i)						}
		if let i = self as? UInt8 	{	return CGFloat(i)						}
		if let f = self as? Float	{	return CGFloat(f)						}
		if let c = self as? CGFloat {	return c								}
		if let d = self as? Double	{	return CGFloat(d)						}
		if let s = self as? String	{	return CGFloat(s)						}
		return nil
	}
	var asDouble_ 		  : Double	{	return asDouble ?? 0.0					}
	var asDouble 		  : Double? {
		if let b = self as? Bool  	{	return b ? 1.0 : 0.0					}
		if let i = self as? Int 	{	return Double(i)						}
		if let i = self as? Int8  	{	return Double(i)						}
		if let i = self as? UInt8 	{	return Double(i)						}
		if let f = self as? Float 	{	return Double(f)						}
		if let c = self as? CGFloat	{	return Double(c)						}
		if let d = self as? Double 	{	return d								}
		if let s = self as? String	{	return Double(s)						}
		return nil
	}
//	func scnVector3_(_ k:Key)-> SCNVector3?{return    self[k] as? SCNVector3	}
	var asScnVector3_ 	  : SCNVector3{	return asScnVector3 ?? .origin			}
	var asScnVector3 	  : SCNVector3?{return self as? SCNVector3				}
	var asString_ 		  : String	{	return asString ?? ""					}
	var asString 		  : String?	{
		if let b = self as? Bool  	{	return b ? "true" : "false"				}
		if let i = self as? Int		{	return fmt("%d", i)						}
		if let i = self as? Int8  	{	return fmt("%d", i)						}
		if let i = self as? UInt8 	{	return fmt("%d", i)						}
		if let f = self as? Float	{	return fmt("%.3f", f)					}
		if let c = self as? CGFloat	{	return fmt("%.3f", c)					}
		if let d = self as? Double	{	return fmt("%.3f", d)					}
		if let c = self as? NSColor	{	return fmt("%02x %02x %02x",
				255*c.redComponent, 255*c.greenComponent, 255*c.blueComponent)	}
		if let s = self as? String	{	return s								}
		if let f = self as? FwConfig{	return f.pp(.line)						}
		return pp(.line)
	}
	var asColor_ 		  : NSColor	{	return asColor ?? .purple				}
	var asColor 		  : NSColor?{	return self as? NSColor					}
	var asFwConfig_ 	  :FwConfig	{	return asFwConfig ?? [:]				}
	var asFwConfig 		  :FwConfig?{	return self as?FwConfig					}
	var asFwAny_ 		  : FwAny	{	return self								}
	var asFwAny	 		  : FwAny	{	return self								}
	var asPart_ 		  : Part	{	return asPart!							}
	var asPart	 		  : Part?	{	return self	as? Part					}
}

extension Dictionary {
	  // Easy access: E.g: boolOfKey = hash.bool_("key"), "_" ==> if nil use default
	 /// :H: Trailing "_"	-- Provide a default if nil
	func bool_ 	   (_ k:Key) -> Bool	{  return     bool(k) ?? false			}
	func bool  	   (_ k:Key) -> Bool?	{  return    (self[k] as? FwAny)?.asBool}
	func int_      (_ k:Key) -> Int		{  return      int(k) ?? 0				}
	func int       (_ k:Key) -> Int?	{  return    (self[k] as? FwAny)?.asInt	}
	 // less any-any'ish:
	func uInt_     (_ k:Key) -> UInt	{  return     uInt(k) ?? 0				}
	func uInt      (_ k:Key) -> UInt?	{  return     self[k] as? UInt			}
	func int16_    (_ k:Key) -> Int16	{  return    int16(k) ?? 0				}
	func int16	   (_ k:Key) -> Int16?	{  let    x = self[k] as? Int
										   return x==nil ? nil : Int16(x!) 		}
	func uInt16_   (_ k:Key) -> UInt16	{  return   uInt16(k) ?? 0				}
	func uInt16    (_ k:Key) -> UInt16?	{  let    x = self[k] as? Int
										   return x==nil ? nil : UInt16(x!) 	}
	func int8_     (_ k:Key) -> Int8	{  return     int8(k) ?? 0				}
	func int8	   (_ k:Key) -> Int8?	{  let    x = self[k] as? Int
										   return x==nil ? nil : Int8(int:x!)	}
	func uInt8_    (_ k:Key) -> UInt8	{  return    uInt8(k) ?? 0				}
	func uInt8     (_ k:Key) -> UInt8?	{  let    x = self[k] as? Int
										   return x==nil ? nil : UInt8(fwAny:x!)}
	func float_    (_ k:Key) -> Float	{  return    float(k) ?? 0.0			}
	func float     (_ k:Key) -> Float?	{  return    (self[k] as? FwAny)?.asFloat}
	func double_   (_ k:Key) -> Double	{  return   double(k) ?? 0.0			}
	func double    (_ k:Key) -> Double?	{  return    (self[k] as? FwAny)?.asDouble}
	func cgFloat_  (_ k:Key) -> CGFloat {  return  cgFloat(k) ?? 0.0			}
	func cgFloat   (_ k:Key) -> CGFloat?{  return    (self[k] as? FwAny)?.asCGFloat}
	func scnVector3(_ k:Key) -> SCNVector3?{return    self[k] as? SCNVector3	}
	func scnVector3_(_ k:Key)-> SCNVector3?{return    self[k] as? SCNVector3	}
	func string_   (_ k:Key) -> String 	{  return   string(k) ?? ""				}
	func string    (_ k:Key) -> String?	{  return    (self[k] as? FwAny)?.asString}
	func color0_   (_ k:Key) -> NSColor {  return   color0(k) ?? .purple		}
	func color0    (_ k:Key) -> NSColor?{  return     self[k] as? NSColor		}
//	func color0    (_ k:Key) -> NSColor?{  return    (self[k] as? FwAny)?.asNSColor}
	func part_     (_ k:Key) -> Part 	{  return     part(k) ?? .null			}
	func part      (_ k:Key) -> Part?	{  return    (self[k] as? FwAny)?.asPart}
	func fwConfig_ (_ k:Key) -> FwConfig{  return fwConfig(k) ?? [:]			}
	func fwConfig  (_ k:Key) -> FwConfig?{ return    (self[k] as? FwAny)?.asFwConfig}
	func scnNode_  (_ k:Key) -> SCNNode {  return  scnNode(k) ?? SCNNode()		}
	func scnNode   (_ k:Key) -> SCNNode?{  return     self[k] as? SCNNode 		}
//	func scnNode   (_ k:Key) -> SCNNode?{  return    (self[k] as? FwAny)?.asSCNNode}
	func fwAny_    (_ k:Key) -> FwAny 	{  return    fwAny(k) ?? fwNull			}
	func fwAny     (_ k:Key) -> FwAny?	{  return     self[k] as? FwAny			}
}

extension Dictionary {


}
  func +=(        dict1: inout FwConfig,       dict2:FwConfig) 	{	dict1 = dict1 + dict2	}
//func +=<Value>( dict1: inout [String:Value], dict2:[String:Value]) where Value:FwAny, Value:Equatable 	{	dict1 = dict1 + dict2	}

func +(lhs:FwConfig, rhs:FwConfig) -> FwConfig {
	var rv						= lhs						// initial values, older, overwritten
	let rhsSorted				= rhs.sorted(by: {$0.key > $1.key})	 // Sort so comparisons match on successive runs

	let u						= FwConfig.Value.self
	let w						= u is any Equatable

	for (keyRhs, valueRhs) in rhsSorted {
		if let valueLhs 		= lhs[keyRhs] { 			// possible conflict if keyRhs in lhs
			let x				= valueLhs is (any Equatable)
			let y				= valueRhs is (any Equatable)
			atBld(9, print("Dictionary Conflict 2 L=\(x) R=\(y), Key: \(keyRhs.field(20)) was \((valueLhs as! FwAny).pp(.short).field(10)) \t<-- \((valueRhs as! FwAny).pp(.short))"))
		}
		rv[keyRhs] 				= valueRhs
	}
	return rv
}
func dictAdd<Value>(lhs:[String:Value], rhs:[String:Value]) -> [String:Value] where Value:FwAny {
	var rv						= lhs						// initial values, older, overwritten
	let rhsSorted				= rhs.sorted(by: {$0.key > $1.key})	 // Sort so comparisons match on successive runs
	func isEq(_ v:Value)->String { 	v is any Equatable ? "(Equatable)" : "(-------)" }
	for (keyRhs, valueRhs) in rhsSorted {
		if let valueLhs 		= lhs[keyRhs] { 			// possible conflict if keyRhs in lhs
//			let x				= "L=\(valueLhs is (any Equatable)),
//			let y				= valueRhs is (any Equatable)
			let val1			= valueLhs.pp(.short).field(10) + isEq(valueLhs)
			let val2			= valueRhs.pp(.short)			+ isEq(valueRhs)
			atBld(9, print("dictAdd conflict 1, Key: \(keyRhs.field(20)) was \(val1) \t<-- \(val2)"))
		}
		rv[keyRhs] 				= valueRhs
	}
	return rv
}

func dictAdd<Value>(lhs:[String:Value], rhs:[String:Value]) -> [String:Value] where Value:FwAny, Value:Equatable {
	var rv						= lhs						// initial values, older, overwritten
	let rhsSorted				= rhs.sorted(by: {$0.key > $1.key})	 // Sort so comparisons match on successive runs
	for (key, valRhs) in rhsSorted {		// Paw through lhs Dictionary
		if let valLhs 			= lhs[key] {	// key in BOTH Dictionaries

			 // fancy xoring for Boolean:
//			if (key == "f" || key == "flip") {
//				if let v0		= valLhs as? Bool,
//				   let v1		= valRhs as? Bool {
//					rv[key]		= v0 ^^ v1			// PW: Compile ERROR
//				} else {
//					panic("Dictionary keys \"f\" or \"flip\" with non-Boolean Value")
//					rv[key] 	= valRhs
//				}
//			} else

			 // Same key, different values
			if valLhs != valRhs {
				atBld(9, DOClog.log("Dictionary Conflict 3, Key: \(key.field(20)) was \(lhs.pp(.phrase).field(10)) \t<-- \(rhs.pp(.phrase))"))
				rv[key] 		= valRhs
			}
		}
	}
	return rv
}

//extension Dictionary<String, Value>  where Value : Equatable {
//				let valX		= self[keyX]
//				if let keyY 	= keyX as? FwAny,
//				  let valY 		= valX as? FwAny
//				{
//					let m 	= mode == .tree ? PpMode.line : PpMode.short
//					rv			+= "\(sep)\(keyY):\(valY.pp(m))"
//				}
//				else {
//					rv 			+= sep + "?\(String(describing:type(of:keyX)))" +
//										 ":\(String(describing:type(of:valX)))"
//				}
//				sep 			= mode == .tree ? ",\n":  mode == .line ? ", " : "???"

																				//extension Dictionary<Key, Value> where Key : Comparable, Hashable {			//Cannot find type 'Key' in scope
																				//extension Dictionary<Key, Value> where Key : Hashable, Value : Comparable {  	//Cannot find type 'Key' in scope
extension Dictionary : Uid {
	var uid: UInt16 {		return uid4Ns(nsOb:(self as NSObject))	}	//SwiftFactals
	
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil, note:String="") {
		let msg					= String(format:format, arguments:args)
		let (nls, msg2)			= msg.stripLeadingNewLines()
		let str					= nls + "\(ppUid(self)):\(self.fwClassName):".field(-18) + msg2	//-nFullN uidClass
		DOClog.log(str, terminator:terminator)
	}//Argument type 'Dictionary<Key, Value>' does not conform to expected type 'Uid'
}

extension Dictionary where Value : FwAny, Value : Equatable {	// PW: Best to far?
	static func ==(lhs: Dictionary, rhs: Dictionary) -> Bool {
		let rv				= lhs.equals(rhs)
		atTst(7, lhs.logd("Result  Dict:    \(lhs.debugDescription) == \(rhs.debugDescription) ---> \(rv)"))
		return rv
	}
	func equals(_ dict:Dictionary) -> Bool {
		guard keys.count == dict.keys.count 		else {	return false }	// counts mismatch

		for key in keys {
			if self[key] != dict[key] {			// Value for key MISMATCH
				atTst(7, logd("(\(self[key]!.pp(.nameUidClass))) != (\(dict[key]!.pp(.nameUidClass))) ?"))
				return false
			}
		}
		atTst(7, logd("Testing Dict:    .equals(\(dict.pp(.nameUidClass)))  ---> true"))
		return true
	}
}

protocol Nib2Bool {
	var bool	: Bool 		{ set get }
	var int 	: Int		{ set get }
	var string	: String	{ set get }
}
extension NSTextField : Nib2Bool {
	var bool : Bool {
		set(v) 	{	stringValue		= String(v)									}
		get 	{	Bool(stringValue) ?? false 									} /// PUNT
	}
	var int : Int {
		set(v) 	{	stringValue		= String(v)									}
		get 	{	Int(stringValue) ?? 0	 									} /// PUNT
	}
	var string : String {
		set(v) 	{	stringValue		= v											}
		get 	{	stringValue 		 										}
	}
}

 // Only gets called after CLASS.pp() has given up. It doesn't support exceptions
func ppDefault(self:FwAny, mode:PpMode?, aux:FwConfig) -> String {
	switch mode! {
	case .fwClassName:
		return self.fwClassName
	case .name:							// -> ""
  //	return self.pp(.name,   	 aux)
		return ""
	case .fullName:						// -> .name
  //	return self.pp(.fullName,	 aux)
		return self.pp(.name,   	 aux)
	case .fullNameUidClass:				// -> uid + name + fwClassName
		return "\(self.pp(.fullName, aux))\(ppUid(pre:".", self as? Uid)):\(self.fwClassName)"
	case .nameUidClass:
		return "\(self.pp(    .name, aux))\(ppUid(pre:".", self as? Uid)):\(self.fwClassName)"
	case .uidClass:
		return "\(ppUid(self as? Uid)):\(self.pp(.fwClassName))"	// e.g: "xxx:Port"
	case .classUid:
		return "\(self.pp(.fwClassName))(\(ppUid(self as? Uid)))"	// e.g: "Port<xxx>"
	case .uid:							// -> uid
		return ppUid(self as? Uid)
	case .phrase:						// -> .fullNameUidClass
		return self.pp(.fullNameUidClass,		aux)
	case .short:						// -> .phrase
		return self.pp(.phrase,		aux)
	case .line:							// -> .short
		return self.pp(.short, aux)
	case .tree:							// -> .line
		return self.pp(.line,   aux)
//	default:							// -> ERROR
//		let x = self.pp(.fullNameUidClass)
//		return "ppDefault ERROR: \(x) unsuported"
	}
}

infix operator ??= :  AssignmentPrecedence
/// If lhs is nil, assign rhs to it
/// - Parameters:
///   - lhs: --- update if nil
///   - rhs: --- new value to replace it with
func ??=<T> (lhs:inout T?, rhs:T?) {											//func ??= (lhs: inout Any?, rhs:  Any?) {
	if lhs == nil {
		lhs					= rhs
	}
}

infix operator ||= : AssignmentPrecedence
func ||=( left: inout Bool, right:Bool) {	left	= left || right	/* OR */	}
infix operator &&= : AssignmentPrecedence
func &&=( left: inout Bool, right:Bool) {	left	= left && right	/* AND */	}
infix operator ^^= : AssignmentPrecedence
func ^^=( left: inout Bool, right:Bool) {	left	= left ^^ right	/* EXOR */	}
infix operator ^^  : ComparisonPrecedence
func ^^(left:Bool, right:Bool) -> Bool  {	return left != right	/* EXOR= */	}

extension Bool {
	init?(fwAny:FwAny) {
		let val:Bool?					=
				fwAny is Bool 	?			 fwAny as? Bool				:
				fwAny is String ? (
					fwAny as! String == "0" ?	false :		// good coersion
					fwAny as! String == "1" ?	true  :		// good coersion
												Bool(fwAny as! String))	:
				fwAny is Int 	?			(fwAny as! Int) >= 1		:
				fwAny is Float	?			(fwAny as! Float) >= 0.5	:
										nil
		if (val==nil) {
			return nil
		}
		self.init(val!) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		if mode == .short {
			return self ? "true" : "false"										}
		 // NO: return super.pp(mode, aux)
		return ppDefault(self:self, mode:mode, aux:aux)
	}
}
var  trueF			= true		// true  which supresses optimizer warning
var  trueF_ :Bool?	= true		// true  which supresses optimizer warning and might be nil
var falseF			= false		// false which supresses optimizer warning
var nilBool :Bool?	= nil		// Bool which is nil
var  zeroF			= 0			// zero  which supresses optimizer warning

//////////////////////// 		Int			/////////////////////////////////
extension Int {
	init?(fwAny:FwAny) {
		let val:Int?			=
				fwAny is Int 	?			(fwAny as! Int)				:
				fwAny is String ?	     Int(fwAny as! String)			:
				fwAny is Bool   ?	        (fwAny as! Bool ? 1 : 0)	:
										nil
		if (val==nil) {
			return nil
		}
		self.init(val!) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:				//
			// Type of expression is ambiguous without more context
			return "\(ppUid(self as Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return String(self)
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
	static func + ( d0:Int, d1:Int) -> Int {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func += ( d0: inout Int, d1:Int) {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
	static func - ( d0:Int, d1:Int) -> Int {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func -= ( d0: inout Int, d1:Int) {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
}

extension UInt {
//	subscript(value:UInt) -> UInt {
//		get {
//			return self[value]
//		}
//	}
	func pp(_ mode:PpMode?	= .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
			return "\(ppUid(self as Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return String(self)
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
	static func + ( d0:UInt, d1:UInt) -> UInt {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func += ( d0: inout UInt, d1:UInt) {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
	static func - ( d0:UInt, d1:UInt) -> UInt {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func -= ( d0: inout UInt, d1:UInt) {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
}


//////////////////////// 		Int16		/////////////////////////////////

extension Int16 {
//	subscript(value:Int16) -> Int16 {
//		get {
//			return self[value]
//		}
//	}
	func pp(_ mode:PpMode?	= .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
			return "\(ppUid(self as Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return String(self)
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
	static func + ( d0:Int16, d1:Int16) -> Int16 {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func += ( d0: inout Int16, d1:Int16) {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
	static func - ( d0:Int16, d1:Int16) -> Int16 {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func -= ( d0: inout Int16, d1:Int16) {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
}

extension UInt16 {
//	subscript(value:UInt16) -> UInt16 {
//		get {
//			return self[value]
//		}
//	}
	func pp(_ mode:PpMode?	= .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
			return "\(ppUid(self as Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return String(self)
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
	static func + ( d0:UInt16, d1:UInt16) -> UInt16 {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func += ( d0: inout UInt16, d1:UInt16) {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
	static func - ( d0:UInt16, d1:UInt16) -> UInt16 {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func -= ( d0: inout UInt16, d1:UInt16) {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
}


//////////////////////// 		Int8		/////////////////////////////////
extension Int8	{
	init(int n:Int) {
		assert(n >= -127 && n<127, "overflow")
		self.init(n)
	}
	init?(fwAny:FwAny) {
		let val:Int8?					=
				fwAny is Int 	?		Int8(int:fwAny as! Int)			:
				fwAny is String ?	    Int8(fwAny as! String)			:
				fwAny is Bool   ?	        (fwAny as! Bool ? 1 : 0)	:
										nil
		if (val==nil) {
			return nil
		}
		self.init(val!) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
	func pp(_ mode: PpMode?, _ aux: FwConfig) -> String {
		return String(self)
	}
	static func + ( d0:Int8, d1:Int8) -> Int8 {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func += ( d0: inout Int8, d1:Int8) {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
	static func - ( d0:Int8, d1:Int8) -> Int8 {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		return d
	}
	static func -= ( d0: inout Int8, d1:Int8) {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "overflow")
		d0 = d
	}
}

extension UInt8 {
//	init?(int n:Int) {
//		if n<0 || n>=256 {
//			return nil
//		}
//		self.init(n)
//	}
	init?(fwAny:FwAny?) {
		if let n				= fwAny?.asInt,		// Can Arg become an Int?
		  n >= 0 && n < 256 {						// It fits in a UInt8?
			self.init(n)								// yes
		}else{
			return nil									// no, failure
		}
	}
	func pp(_ mode: PpMode?, _ aux: FwConfig) -> String {
		return String(self)
	}
	static func + ( d0:UInt8, d1:UInt8) -> UInt8 {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "UInt8 '+' overflows")
		return d
	}
	static func += ( d0: inout UInt8, d1:UInt8) {
		let (d, overflow) 		= d0.addingReportingOverflow(d1)
		assert(!overflow, "UInt8 '+=' overflows")
		d0 = d
	}
	static func - ( d0:UInt8, d1:UInt8) -> UInt8 {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "UInt8 '-' overflows")
		return d
	}
	static func -= ( d0: inout UInt8, d1:UInt8) {
		let (d, overflow) 		= d0.subtractingReportingOverflow(d1)
		assert(!overflow, "UInt8 '-=' overflows")
		d0 = d
	}
}

extension Float	{
	var isNan			: Bool 		{	return self != self						}
	static func random(from n1:Float, to n2:Float) -> Float {
		let rand		= (Float(arc4random()) / 0x100000000)
//		let rand		= (Float(arc4random()) / 4294967296) // 0xFFFFFFFF + 1
		return n1 + (n2 - n1) * rand
	}
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
			return "\(ppUid(self as Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return String(self)
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
}

extension Double	{
	var isNan			: Bool 		{	return self != self						}
	static func random(from n1:Double, to n2:Double) -> Double {
		let rand		= (Double(arc4random()) / 0xFFFFFFFF)
		return n1 + (n2 - n1) * rand
	}
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
bug;		return "\(self.pp(.fullName, aux)) :\(self.fwClassName)"
//			return "\(ppUid(self as? Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return String(self)
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
}
func pegBetween0n1<T: Comparable & FloatingPoint>(_ v: T) -> T { return max(min(v, 1), 0) }
extension FloatingPoint {
 /// THIS SHOULD WORK, BUT DOESN't
//	func pegBetween0n1<T: Comparable & FloatingPoint>() -> T 	{	return T(min(max(self, 1), 0))	}
}
extension CGFloat {
	init?(_ string:String) {
		if let f = Float(string) {
			self = CGFloat(f)
		}
		else {
			return nil
		}
	}
	var isNan			: Bool 		{
		return self != self
	}

	static func random(from n1:CGFloat, to n2:CGFloat) -> CGFloat {
		let rand		= (CGFloat(arc4random()) / 0xFFFFFFFF)
		return n1 + (n2 - n1) * rand
	}
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
			return "\(ppUid(self as Uid, post:"."))\(self.pp(.fullName, aux)) :\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return self.description
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
}

//func allItemsMatch<C1: Container, C2: Container>
//    (_ someContainer: C1, _ anotherContainer: C2) -> Bool
//    where C1.Item == C2.Item, C1.Item: Equatable {
//func !~= <left:V, right:V>(_ left:V, _ right:V) -> Bool {
//	return abs(left - right) < NSValue(epsilon)									}

infix operator ~==  : AdditionPrecedence	// Read as "Approximately Equal"
infix operator !~== : AdditionPrecedence	// Read as "Not Approximately Equal"
func ~==( left:Float, right:Float) -> Bool {
	return abs(left-right) < Float(epsilon)										}
func ~==( left:Double, right:Double) -> Bool {
	return abs(left-right) < Double(epsilon)									}
func ~==( left:CGFloat, right:CGFloat) -> Bool {
	return abs(left-right) < CGFloat(epsilon)									}

func !~==( left:Float, right:Float) -> Bool {
	return abs(left-right) > Float(epsilon)										}
func !~==( left:Double, right:Double) -> Bool {
	return abs(left-right) > Double(epsilon)									}
func !~==( left:CGFloat, right:CGFloat) -> Bool {
	return abs(left-right) > CGFloat(epsilon)									}
//func +=(left:String?, right:String?) -> String? {
//	return left == nil || right == nil ? nil
//										: left! + right!
//}

// https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
//					let text		= "Hello world"
//					let a 			= text[...3]							// "Hell"
//					let a2 			= text[1...]							// "Hell"
//					//let a3 		= text[1...3]							// "Hell"
//					//let b 		= text[6..<text.count] 					// world
//					let c 			= text[NSRange(location: 6, length: 3)]	// wor
//					print(a,c)
//					//let newStr = str.substring(from: index) // Swift 3
//					let newStr = String(valStr[index...]) // Swift 4
extension String : Uid {
	var uid: UInt16 {		return uid4Ns(nsOb:(self as NSObject))	}	//SwiftFactals
}
extension String {
	init(bool:Bool) {			// Bool -> String
		self						= bool ? "t" : "f"
	}
}
extension String.StringInterpolation {
	mutating func appendInterpolation(_ value: Float, decimals:Int) {
		appendInterpolation(fmt("%.*f", value, decimals))
	}
}

extension Bool {
	init(string:String) {		// String -> Bool
		let cvt = ["t":true,  "true":true,
				   "f":false, "false":false, "":false]
		let x						= cvt[string]		// very proplematic
		assert(x != nil, "Cannot convert String \(string) to Bool")
		self						= x!
	}
}

extension String {
	subscript(value: NSRange) -> Substring {
		return self[value.lowerBound..<value.upperBound]
	}
}
extension String {
	subscript(value: CountableClosedRange<Int>) -> Substring {
		get {
			return self[index(at: value.lowerBound)...index(at: value.upperBound)]
		}
	}
	subscript(value: CountableRange<Int>) -> Substring {
		get {
			return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
		}
	}
	subscript(value: PartialRangeUpTo<Int>) -> Substring {
		get {
			return self[..<index(at: value.upperBound)]
		}
	}
	subscript(value: PartialRangeThrough<Int>) -> Substring {
		get {
			return self[...index(at: value.upperBound)]
		}
	}
	subscript(value: PartialRangeFrom<Int>) -> Substring {
		get {
			return self[index(at: value.lowerBound)...]
		}
	}
	func index(at offset: Int) -> String.Index {
		return index(startIndex, offsetBy: offset)
	}
}

extension String {
	subscript (bounds: CountableClosedRange<Int>) -> String {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		return String(self[start...end])
	}
	subscript (bounds: CountableRange<Int>) -> String {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		return String(self[start..<end])
	}

	 /// Fixed length field to format a String
	/// - Parameters:
	///		- _: 		------ length of field, in characters
	///		- dots: 	------ add "..." at end, to show truncation
	///		- fill: 	------ string to fill with
	/// - Parameter grow: ------ allow long fields to exceed length
	func field(_ length:Int, dots:Bool=true, fill:Character?=" ", grow:Bool=false) -> String {
		let excess 				= self.count - abs(length)	// amount string is too big
		if excess > 0 && grow {
			return self
		}
		let truncLen			= max(0, abs(length) - (dots ? 2:0))
		let truncDots			= dots ? "..":""

		//										excess=-5 <0	excess=3 >0
		// 	Arguments:			\	Input:	abc				abcdefghijk
		// 	length---------dots--			--------		--------
		// 	>0 (RIGHT)		no			  A:_____abc	  B:defghijk
		// 	>0 (RIGHT)		yes			  C:_____abc	  D:..fghijk

		// 	<0 (LEFT)		no			  E:abc_____	  F:abcdefgh
		// 	<0 (LEFT)		yes			  G:abc_____	  H:abcdef..
		if (length >= 0) {								// RIGHT justified
			return excess > 0 ?								//    dots      !dots
				truncDots + String(suffix(truncLen)):		// D:..fghijk B:defghijk
				   fill==nil ? self :						//      A:abc      C:abc
				String(repeating:fill!,count:-excess) + self// A:_____abc C:_____abc
		} else {
			return excess > 0 ?							// LEFT justified
				String(prefix(truncLen)) + truncDots :		// F:abcdefgh H:abcdef..
				   fill==nil ? self :						//      E:abc      G:abc
				self + String(repeating:fill!,count:-excess)// E:abc_____ G:abc_____
		}
	}
	func wrap(min:Int=0, cur:Int=0, max:Int=80) -> String {
		var rv					= ""
		var column				= cur
		forEach({						// paw through characters
			rv.append($0)					// put each to output
			if $0 == "\n" {				// '\n' -> start new line
				column			= min
				rv.append(String(repeating:" ", count:min))
			}
			else if  column < max {		// normal, go to next
				column			= column + 1
			}
			else {
				column			= min			// begin next line
				rv.append("\n" + String(repeating:" ", count:min))
			}
			//column				=
			//	$0 == "\n" ?		min :
			//	column < max ?		column + 1 :
			//	{	rv.append("\n" + String(repeating:" ", count:min))
			//		return min					// begin next line
			//	} ()
			//column				=
			//	$0 == "\n" ?		min :		// a) "\n" starts new line
			//	column < max ?		column + 1 :// b) normal next character
			//	{	rv.append("\n" + String(repeating:" ", count:min))
			//		return min					// c) begin next line
			//	} ()
		})
		return rv
	}
	func contains(substring str:String) -> Bool {
		return range(of:str) != nil												}
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
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {
		case .fullNameUidClass:
			return "\(ppUid(self, post:"."))\"\(self)\":\(self.fwClassName)"
		case .name:
			return "_"
		case .phrase, .short, .line, .tree:
			return self
		case .fullName, .uid:		//.name, .fwClassName,
				return ""
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
	func stripLeadingNewLines() -> (String, String) {
		var (s, rv)				= (self, "")
		while s.hasPrefix("\n") {
			s 					= String(s.dropFirst())
			rv					+= "\n"
		}
		return (rv, s)
	}
	func removeUnneededSpaces() -> String {
		var str = self
		 /// Use shorter names:
		for (key,val) in [
							"[ "	:"[",
							"< "	:"<",
							"  "	:" ",
							" -"	:"-",
						  ] {
			str = str.replacingOccurrences(of:key, with:val)
		}
		return str
	}
	func shortenStringDescribing() -> String {
		  // Eliminate hex address, which is from first " " to following "|"
		 // e.g. "<SCNNode: 0x6040001e4d00 pos(5.000000 15.000000 5.000000) | light=<SCNLight: 0x6040001e4700 | type=omni> | no child>"
		let regex = try! NSRegularExpression(pattern: "\\b0x[0-9a-f]*")
		var str = regex.stringByReplacingMatches(in: self, options: [],
								range:NSRange(0..<self.count), withTemplate: "")
		 // Use shorter names:
		for (key,val) in [
			"|":"",
			"00"			:"",
			"SCN"			:"", 		"Geometry:"		:"",
			"Cylinder"		:"Cyl",		"3DPictureframe":"3DFrame",
			"elements"		:"elts",

			"radius"		:"r", 		"height"		:"h",
			"width"			:"w", 		"length"		:"l", 	"chamferRadius":"cr",
			"topRadius"		:"rT", 		"bottomRadius"	:"rB",
			"ringRadius"	:"rR", 		"pipeRadius"	:"rP",
			"innerRadius"	:"iR", 		"outerRadius"	:"oR",
			"'material'"	: "",

			"SwiftFactals."	:"",		"SwiftFactalTests."	:"",	// remove an extra "."
			"SwiftFactals"	:"",		"SwiftFactalTests"	:"",
		] {
			str 				= str.replacingOccurrences(of:key, with:val)
		}
		 // remove all dual spaces
		var strPre				= str
		repeat {
			strPre				= str
			str 				= str.replacingOccurrences(of:"  ", with:" ")
		} while strPre.count != str.count
		return str
	}
}


protocol Logd: Uid {
	func logd(_ format:String, _ args:CVarArg..., terminator:String?, note:String)
}
extension Logd {
	// MARK: - 14. Logging
	/// Log critical actions with a line that starts with
	/// - Parameters:
	///   - banner: Descriptive message to display before message
	///   - format: printf format
	///   - args: printf args
	///   - terminator: for print
	///   - note: HACK
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil, note:String="") {
		let msg					= String(format:format, arguments:args)
		let (nls, msg2)			= msg.stripLeadingNewLines()
		let str					= nls + (note + ppUid(self) + ":Logd").field(-28) + msg2	//-nFullN uidClass
//		let str					= nls + (note + ":" + ppUid(self)).field(-28) + msg2	//-nFullN uidClass
		DOClog.log(str, terminator:terminator)
	}
}

 // 180623 Why doesn't this work?		// public?
extension NSObject : Uid {
	var uid: UInt16 			{ 	return uid4Ns(nsOb:self)					}
}

extension NSObject : Logd {
}

extension NSObject {
	@objc dynamic var fwClassName : String {
		get {
			let classNamePath		= className
			let classNameElements	= classNamePath.split(separator:".")
			let rv					= classNameElements.last
			return String(rv!)
		}
	}
}
func possibleNameSpaces() -> [String] {
	return [
		Bundle.main.infoDictionary!["CFBundleExecutable"] as! String,
		"Factals",				// ZEV: Shouldn't this be in Bundle.main
		"FactalsTests",
	]
}

 /// Get AnyClass from name String
func classFrom<T>(string:String) -> T.Type where T : Any {
	for namespace in possibleNameSpaces() {
		 // Desired Class:
		let aClass : AnyClass?		= NSClassFromString("\(namespace).\(string)")
		 // Desired T/Specified Class:
		let aTClass					= aClass as? T.Type	//30
		if aTClass != nil {
			return aTClass!
		}
	}
	fatalError("classFrom(string:\(string)) FAILS")
}

extension Array where Element: Equatable {
	func distinct(anObject:Element) -> [Element]{
		var unique = [Element]()
		for elt in self {
			if !unique.contains(elt){
				unique.append(elt)
			}
		}
		return unique
	}
	mutating func appendIfAbsent(_ anObject:Element){
		if !self.contains(anObject) {
			self.append(anObject)
		}
	}
	mutating func setObject(at index:Int, toValue:Element) {
		while self.count <= index {				// extend self to have an object[index]
			self.append(toValue)
		}
		self[index]			= toValue
	}
	mutating func dequeFromHead() -> Element? {
		var rv : Element?	= nil
		if count > 0 {
			rv 				= self[0]
			removeFirst()
		}
		return rv
	}
}

extension Array where Element: Comparable {
	func sortIfComparable() -> Array {
		return sorted()
	}
}
extension Array {
	func sortIfComparable() -> Array {
		return self
	}
}

//class BoxedArray<T> : MutableCollection {	// NOT NSObject
//
//	var array : Array<T> 		= []
//
//	var startIndex: Int						{	return 0 						}
//	var endIndex: Int						{	return array.count-1 			}
//	func index(after i: Int) -> Int 		{	return i + 1					}
//	func insert(_ obj:T, at index:Int)		{	array.insert(obj, at:index)		}
//	func remove(at index:Int)				{	array.remove(at:index)			}
//
//	init() {}
//
//	subscript (index: Int) -> T {
//		get { return array[index] }
//		set(newValue) { array[index] = newValue }
//	}
//}
extension Data {
	var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
		guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
			  let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
			  let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
			  												else { return nil 	}
		return prettyPrintedString
	}
}

extension NSColor {
	func pp(_ mode:PpMode? = .tree, _ aux_: FwConfig) -> String {
		return "NSColor"
//		panic(); return "yeuch"
	}
}
extension NSNull {
	func pp(_ mode:PpMode? = .tree, _ aux_: FwConfig) -> String {
		return "NSNull"
//		panic(); return "yeuch"
	}
}

let fwNull : FwAny = (NSNull() as NSObject) as! FwAny
//		      return (NSNull() as NSObject) as! FwAny			/// NSNull

extension DispatchSemaphore {
	var value : Int? {
		let str				= debugDescription
		let valueRange		= str.range(of:"value")
		let a:String.Index	= valueRange!.upperBound
		let str0			= str.index(a, offsetBy: 3)	// skip over " = "
		let valuePP			= str[str0...].split(separator:",")
		return Int(String(valuePP[0])) ?? -999
	}
}

/// No Operation
/// * A legal statement that does nothing and returns nothing.
@inline(never)
var nop : () 		{		return 												}
