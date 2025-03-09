//  FwTypes.swift -- new type system ©2021PAK
//


import Foundation

 // FwAny: Types known to the Factal Workbench (FW) system

enum FwKnown : Codable {
	case bool		(Bool		)
	case  int		(Int		)
	case uInt		(UInt		)
	case  int16		(Int16		)
	case uInt16		(UInt16		)
	case  int8		(Int8		)
	case uInt8		(UInt8		)
	case float		(Float		)
	case double		(Double		)
	case cgFloat	(CGFloat	)		//cGFloat
	case string		(String		)
	case vew		(Vew		)
	case part		(Part		)
	case bBox		(BBox		)
	case event		(FwwEvent	)
	//case log		(Log		)
	case path		(Path		)
//	case sCNVector4	(SCNVector4	)
//	case sCNVector3	(SCNVector3	)
//	case nSColor	(NSColor	)
//	case array		(Array		)
//	case dictionary	(Dictionary	)

	init(obj:Any) {
		switch obj {
		case let bool		as Bool			: 	self = .bool		(bool		)
		case let  int		as Int			: 	self = . int		( int		)
		case let uInt		as UInt			: 	self = .uInt		(uInt		)
		case let  int16		as Int16		: 	self = . int16		( int16		)
		case let uInt16		as UInt16		: 	self = .uInt16		(uInt16		)
		case let  int8		as Int8			: 	self = . int8		( int8		)
		case let uInt8		as UInt8		: 	self = .uInt8		(uInt8		)
		case let float		as Float		: 	self = .float		(float		)
		case let double		as Double		: 	self = .double		(double		)
		case let cgFloat	as CGFloat		: 	self = .cgFloat		(cgFloat	)	//
		case let string		as String		: 	self = .string		(string		)
		case let vew		as Vew			: 	self = .vew			(vew		)
		case let part		as Part			: 	self = .part		(part		)
		case let bBox		as BBox			: 	self = .bBox		(bBox		)
		case let event		as FwwEvent		: 	self = .event		(event		)
//		case let log		as Log			: 	self = .log			(log		)
		case let path		as Path			: 	self = .path		(path		)
//		case let sCNVector4	as SCNVector4	: 	self = .sCNVector4	(sCNVector4	)
//		case let sCNVector3	as SCNVector3	: 	self = .sCNVector3	(sCNVector3	)
//		case let nSColor	as NSColor		: 	self = .nSColor		(nSColor	)
//		case let array		as Array		: 	self = .array		(array		)
//		case let dictionary	as Dictionary	: 	self = .dictionary	(dictionary	)
		default: debugger("Could not encode \(obj)")
		}
	}
	func value() -> Codable {
		switch self {
		case let .bool		(bool		)	:		return bool
		case let . int		( int		)	:		return  int
		case let .uInt		(uInt		)	:		return uInt
		case let . int16	( int16		)	:		return  int16
		case let .uInt16	(uInt16		)	:		return uInt16
		case let . int8		( int8		)	:		return  int8
		case let .uInt8		(uInt8		)	:		return uInt8
		case let .float		(float		)	:		return float
		case let .double	(double		)	:		return double
		case let .cgFloat	(cgFloat	)	:		return cgFloat		// cGFloat
		case let .string	(string		)	:		return string
		case let .vew		(vew		)	:		return vew
		case let .part		(part		)	:		return part
		case let .bBox		(bBox		)	:		return bBox
		case let .event		(event		)	:		return event
//		case let .log		(log		)	:		return log
		case let .path		(path		)	:		return path
//		case let .sCNVector4(sCNVector4	)	:		return sCNVector4
//		case let .sCNVector3(sCNVector3	)	:		return sCNVector3
//		case let .nSColor	(nSColor	)	:		return nSColor
//		case let .array		(array		)	:		return array
//		case let .dictionary(dictionary	)	:		return dictionary
	//	default: debugger("Could not decode \(self)")
		}
	}
}
