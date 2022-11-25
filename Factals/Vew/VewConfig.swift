//
//  VewConfig.swift -- Specify which Vews are created
//  Factals
//
//  Created by Allen King on 9/29/22.
//

import Foundation

enum VewConfig : FwAny {
	typealias RawValue			= String

	  // Open a path from self to the Factal at <path> from self.
	case openPath(to:Path)				// Only children on path are effected
	case openAllChildren(toDeapth:Int)	// Open all of children, down to deapth
	case subVewList([VewConfig])		// array of directives, to
	case subVew(FwConfig)

	func ppLine() -> String {
		switch self {
		case .openPath(to:let path): nop
			return ".openPath(to:\(path.fullName()))"
		case .openAllChildren(toDeapth:let deapth): nop
			return ".openAllChildren(toDeapth:\(deapth))"
		case .subVewList(let vewConfigs): nop			// array of directives, to
			return ".subVewList([\(vewConfigs.count)])"
		case .subVew(let fwConfig): nop
			return ".subVew(fwConfig:\(fwConfig.count))"
		}
	}
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		switch mode! {//.fwClassName, .uid, .uidClass, .classUid, .name, .nameUidClass, .fullName, .fullNameUidClass,
		case .line, .phrase, .short, .tree:
			return ppLine()
		default:
			return ppDefault(self:self, mode:mode, aux:aux)// NO return super.pp(mode, aux)
		}
	}
	 // MARK: - 16. Global Constants
	static let null				= subVew([:])
	 // MARK: - 17. Debugging Aids
	var description			: String 	{	return  "\"\(pp(.short))\""			}
	var debugDescription	: String	{	return   "'\(pp(.short))'"			}
	var summary				: String	{	return  "<\(pp(.short))>"			}
}

 // VewConfig's for testing
let vewConfig1					= VewConfig.openPath(to:Path(withName: "ROOT/a.P"))
let vewConfig2					= VewConfig.openAllChildren(toDeapth:8)
let vewConfig3					= VewConfig.subVewList([vewConfig1, vewConfig2])
let vewConfig4					= VewConfig.subVew(["name":"vewConfig1"])
let vewConfigAllToDeapth4		= VewConfig.openAllChildren(toDeapth:4)

extension Vew {
	func adorn(from part:Part, using config:VewConfig) {
		atTst(3, log("adorn(from:\(part.pp(.fullName)) using:\(config.pp(.fullNameUidClass))"))
		switch config {
		case .openPath(let path):
			var part : Part?	= part				// a part already
			guard let subName	= path.dequeFirstName(),						//guard let name = p != nil && tok.count > 0 ? tok[0] : nil,
			  let subPart		= part!.children.first(where: { $0.name == subName}) else {
				return
			}
			let subVew			= Vew(forPart:subPart)
			addChild(subVew)
			adorn(from:subPart, using:config)
									//	touchVews(ofConfig:VewConfig.openPath(to:path))
							//			 // Descend path, explode area
							//			adornTargetVew		= nil			// HACK
							//bug;		for name in path.atomTokens {
							//				 // Dive into
							//				if let subVew	= self.find(name:"_"+name),
							//				  let subPart	= part.find(name:	 name) {
							//					adornTargetVew	= subVew
							//					subVew.adorn(from:subPart, using:config)
							//				}
							//			}
		case .openAllChildren(let deapth):
//bug
//let x = pp(.uid)
			if deapth <= 1 {	break											}
			 // open our child Vews
			for childPart in part.children {
				adorn(from:childPart, using: .openAllChildren(toDeapth:deapth-1))
			}
		case .subVewList(let vewConfigs):
			for childVew in children {
				for vewConfig in vewConfigs {
					childVew.adorn(from: part, using:vewConfig)
				}
			}
		case .subVew(let fwConfig):
			self.part.localConfig	= fwConfig	//??
			//panic(".subVew(\(fwConfig.pp(.phrase))")
		}
	}
//	/// Insure the Vews for the parts in config are present in self
//	/// - Parameter config: which parts should be opened
//	func touchVews(ofConfig config:VewConfig) {
//		switch config {
//		case .openPath(var path):
//		case .openAllChildren(let toDeapth):
//bug;		let deapth			= toDeapth - 1
//			if deapth > 0 {
//				for child in children {
//					child.touchVews(ofConfig:.openAllChildren(toDeapth:deapth))
//				}
//			}
//			nop
//		case .subVewList(let vewConfigs):
//bug;		for config in vewConfigs {
//				touchVews(ofConfig:config)
//			}
//		case .subVew(let fwConfig):
//			nop
//		}
//	}
}

extension RootVew {
	func ppLine() -> String {
		guard let rootVew		= rootVew			else {	return "Vew.rootVew == nil "}
		guard let fwGuts 		= rootVew.fwGuts 	else {	return "Vew.rootVew?.fwGuts == nil "}
		let i					= fwGuts.rootVews.firstIndex { $0 === self 		} ?? -1
//		var rv					= "trunkVew:\(ppUid(trunkVew, showNil:true)) "
		var rv					= "rootVew:\(ppUid(rootVew, showNil:true)) "
		rv						+= "(\(nodeCount()) Nodes) "
		rv						+= "LockVal:\(rootVewLock.value ?? -99) "
		rv						+= fwGuts.rootVews[i] === self ? "" : "OWNER:'\(String(describing: fwGuts))' BAD "
		rv						+=  rootVewOwner != nil ? "OWNER:\(rootVewOwner!) " : "UNOWNED "
		rv						+= "pole:\(lastSelfiePole.pp())-"
		rv						+= "w[\(fwScn.scn.convertPosition(.zero, to:nil).pp(.short))] "
		rv						+= "lookAtVew:\(lookAtVew?.pp() ?? "?")"
		assert(eventCentral.rootVew == self, "EventCentral link BAD")
		return rv
	}
}
