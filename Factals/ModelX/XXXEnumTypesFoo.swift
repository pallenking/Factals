////
////  EnumTypesFoo.swift
////  SwiftFactals
////
////  Created by Allen King on 11/9/21.
////  Copyright © 2021 Allen King. All rights reserved.
////
//
//import Foundation
//struct YPart : Uid {
//	var uid			: UInt16	= randomUid()
////	var uid						= UUID()
//	var name		: String 	= ""
//	var children	: [YPart]	= []
//	var parent  	:  YPart?	= nil 			// add the parent property
//	// Value type 'YPart' cannot have a stored property that recursively contains it
//	var fullName	: String 	= ""
//	var fwClassName	: String 	= ""
//	/*@Published*/
//	var flipped 	: Bool 		= false
//	//{	didSet {		markTree(dirty:.size)  								}	}
//
//	 /// Ancestor array starting with parent
//	var parents : [YPart] {
//		var rv 		 : [YPart]	= []
//		var ancestor :  YPart?	= parent
//		while ancestor != nil {
//			rv.append(ancestor!)
//			ancestor 			= ancestor!.parent
//		}
//		return rv
//	}
//	/// Ancestor array starting with self
//	var selfNParents : [YPart] {
//		return selfNParents()
//	}
//	/// Ancestor array, from self up to but excluding 'inside'
//	func selfNParents(upto:YPart?=nil) -> [YPart] {
//		var rv 		 : [YPart]	= []
//		var ancestor :  YPart?	= self
//		while ancestor != nil, 			// ancestor exists and
//			  ancestor! !== upto  {		// not at explicit limit
////		  ancestor!.name != "ROOT" {
//			rv.append(ancestor!)
//			ancestor 			= ancestor!.parent
//		}
//		return rv
//	}
//
//	/// Up has 2 meanings:
//	///	- UPsidedown (as controlled by fliped)
//	///	- Port opens UP
//	var upInWorld : Bool {						// true --> flipped in World
//		var rv 					= false
//		for part in selfNParents {
//			rv 					^^= part.flipped	// rv now applies from self
//		}
//		return rv
//	}
//}
//enum XPart {
//
//	case atom(XAtom)
//		enum XAtom {
//			case ago			(XAgo)
//			case discreteTime	(XDiscreteTime)
//			case genAtom		(XGenAtom)
//			case link			(XLink)
//			case mirror			(XMirror)
//			case modulator		(XModulator)
//			case net			(XNet)
//			case portless		(XPortless)
//			case previous		(XPrevious)
//			case soundAtom		(XSoundAtom)
//			case splitter		(XSplitter)
//			case timingChain	(XTimingChain)
//			case worldModel		(XWorldModel)
//			case writeHead		(XWriteHead)
//		}
//
//	case commonPart(XCommonPart)
//		enum XCommonPart {}
//}
//
//
//func pp(part:YPart, _ mode:PpMode, _ aux:FwConfig) -> String	{		// Why is this not an override
//		var rv					= ""
//		switch mode {
//		case .name:
//			return part.name
//		case .fullName:
//			rv					+= part.fullName
//		case .fullNameUidClass:
//			return "\(part.name)\(ppUid(pre:"/", part)):\(part.fwClassName)"
//		case .uidClass:
//			return "\(ppUid(part)):\(part.fwClassName)"	// e.g: "xxx:Port"
//		case .classUid:
//			return "\(part.fwClassName)<\(ppUid(part))>"	// e.g: "Port<xxx>"
//		case .phrase, .short:
//				return "\(part.name):\(pp(part:part, .fwClassName, aux)) \(part.children.count) children"
////			return "\(part.name):\(pp(part.fwClassName, aux)) \(part.children.count) children"
//		case .line:
//			  //      AaBbbbbbCccDdddddddddddddddddddddddEeeeeeeeeeeee
//			 // e.g: "Ff| | | < 0      prev:Prev  o> 76a8  Prev mode:?
//			rv					= ppUid(part, post:"", aux:aux)
//			rv					+= (upInWorld ? "F" : " ") + (part.flipped ? "f" : " ")	// Aa
//			rv 					+= log.indentString() ?? "Bb..."				// Bb..
//			let ind				= parent?.children.firstIndex(where: {$0 === self})
//			rv					+= ind != nil ? fmt("<%2d", Int(ind!)) : "<##"		// Cc..
//				// adds "name;class<unindent><Expose><ramId>":
//			rv					+= ppCenterPart(aux)								// Dd..
//			if config("physics")?.asBool ?? false {
//				rv				+= "physics,"
//			}
//			if aux.bool_("ppParam") {
//				rv 				+= localConfig.pp(.line)
//			}
//																					// Ee..
//		case .tree:
//			let ppDagOrder 		= aux.bool_("ppDagOrder")	// Print Ports early
//			let reverseOrder	= ppDagOrder && (upInWorld ^^ printTopDown) //trueF//falseF//
//
//			if ppDagOrder {				// Dag Order
//				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:true)
//				rv				+= ppSelf	 (aux)
//			}
//			else {
//				rv				+= ppSelf	 (aux)
//				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:true)
//			}
//		default:
//			return ppDefault(self:part, mode:mode, aux:aux)// NO return super.pp(mode, aux)
//		}
//		return rv
//	}
//	switch part {
//	case atom(XAtom)
//	case commonPart(XCommonPart)
//	}
//}
//
//
//
//enum XAgo {}
//enum XDiscreteTime {}
//enum XGenAtom {}
//enum XLink {
//	case multiLink(MultiLink)
////	case labelLink(LabelLink)
//}
//enum XMirror {
//}
//enum XModulator {
//}
//enum XNet {
//}
//enum XPortless {
//}
//enum XPrevious {
//}
//enum XSoundAtom {
//}
//enum XSplitter {
//}
//enum XTimingChain {
//}
//enum XWorldModel {
//}
//enum XWriteHead {
//}
//
