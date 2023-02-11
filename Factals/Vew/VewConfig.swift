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
		case .openPath(to:let path):
			return ".openPath(to:\(path.fullName()))"
		case .openAllChildren(toDeapth:let deapth):
			return ".openAllChildren(toDeapth:\(deapth))"
		case .subVewList(let vewConfigs):			// array of directives, to
			return ".subVewList([\(vewConfigs.count)])"
		case .subVew(let fwConfig):
			return ".subVew(fwConfig:[\(fwConfig.count) elts])"
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
//let vewConfig4  				= VewConfig.subVew(["name":"vewConfig1"])
let vewConfigAllToDeapth4		= VewConfig.openAllChildren(toDeapth:4)

extension Part {
	/// Adorn self (a Part) in parentVew, using config (a VewConfig)
	///   Adorn scn tree too
	/// - Parameters:
	///   - in parentVew: where Vew of self goes. If parentVew already contains
	///   a Vew, try to use it. Otherwise create one
	///   - openChildrenUsing config: config to open children using
	func adorn(in parentVew:Vew, openChildrenUsing config:VewConfig) {
		atRve(3, parentVew.part.logd("adorn(in:\(parentVew.pp(.fullName).field(-15)), openChildrenUsing:\(config.pp(.fullNameUidClass)))"))

		 // If a Vew for part is already in parentVew, use it:
		var vew					= parentVew.children.first { $0.part === self}
		if vew != nil,					// Check if correct
		   vew!.name != "_" + name ||		// name and part
		   vew!.part !== self {
			vew					= nil			// Incorrect, force rebuild
		}
		if vew == nil {					// Must create a new View?
			vew					= VewForSelf()
			parentVew.addChild(vew)
		}

		 // Remove any old skins:
	//	parentVew.scn.find(name:"s-atomic")?.removeFromParent()

		 // A new skin is made by Part:
		let bbox				= parentVew.part.reSkin(fullOnto:parentVew)		// skin of Part
		parentVew.part.markTree(dirty:.size)

		switch config {
		case .openPath(let path):
			guard let subPathName = path.dequeFirstName(),						//guard let name = p != nil && tok.count > 0 ? tok[0] : nil,
			  let subPart		= children.first(where: { $0.name == subPathName} ) else { return }
			subPart.adorn(in:parentVew, openChildrenUsing:config)	// #### SEMI-RECURSIVE CALL
		case .openAllChildren(let deapth):
			if deapth <= 1 {	break											}
			 // open our child Vews
			for childPart in children {
				childPart.adorn(in:vew!, openChildrenUsing:.openAllChildren(toDeapth:deapth-1))
			}
		case .subVewList(let vewConfigs):
			for vewConfig in vewConfigs {
				adorn(in:parentVew, openChildrenUsing:vewConfig)
			}
		case .subVew(let fwConfig):
			self.localConfig	= fwConfig	//??
			//print("??? adorn(.subVew(let fwConfig): ???")
			//panic(".subVew(\(fwConfig.pp(.phrase))")
		}
	}
//	/// Insure the Vews for the parts in config are present in self
//	/// - Parameter config: which parts should be opened
//	func touchVews(ofConfig config:VewConfig) {}
}

extension RootVew {
	func ppLine() -> String {
		guard let rootVew							else {	return "Vew.rootVew == nil "}
		guard let fwGuts 		= rootVew.fwGuts 	else {	return "Vew.rootVew?.fwGuts == nil "}
		guard let myI			= fwGuts.rootVews.firstIndex(where:{ $0.value === self })
			else {		bug;		return "Oops 2242"							}

		let (key, _)			= fwGuts.rootVews[myI]
		var rv					= "rootVew:\(ppUid(rootVew, showNil:true)) "
		rv						+= "(\(nodeCount()) Nodes) "
		rv						+= "LockVal:\(rootVewLock.value ?? -99) "
		rv						+= fwGuts.rootVews[key] === self ? "" : "OWNER:'\(String(describing: fwGuts))' BAD "
		rv						+=  rootVewOwner != nil ? "OWNER:\(rootVewOwner!) " : "UNOWNED "
//		rv						+= "pole:\(rootScn.selfiePole.pp())-"
//		rv						+= "w[\(scn.convertPosition(.zero, to:nil).pp(.short))] "
		rv						+= "lookAtVew:\(rootScn.lookAtVew?.pp(.fullName) ?? "?")"
		return rv
	}
}
