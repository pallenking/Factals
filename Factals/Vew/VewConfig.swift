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

	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		switch mode! {//.fwClassName, .uid, .uidClass, .classUid, .name, .nameUidClass, .fullName, .fullNameUidClass,
		case .line, .phrase, .short, .tree:
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
		default:
			return ppDefault(self:self, mode:mode, aux:aux)// NO return super.pp(mode, aux)
		}
	}
	 // MARK: - 16. Global Constants
	static let null				= subVew([:])
	 // MARK: - 17. Debugging Aids
	var description			: String 	{	return  "d'\(pp(.short))'"			}
	var debugDescription	: String	{	return "dd'\(pp(.short))'"			}
	var summary				: String	{	return  "s'\(pp(.short))'"			}
}

 // VewConfig's for testing
let vewConfig1					= VewConfig.openPath(to:Path(withName: "ROOT/a.P"))
let vewConfig2					= VewConfig.openAllChildren(toDeapth:8)
let vewConfig3					= VewConfig.subVewList([vewConfig1, vewConfig2])
//let vewConfig4  				= VewConfig.subVew(["name":"vewConfig1"])
let vewConfigAllToDeapth4		= VewConfig.openAllChildren(toDeapth:4)

extension Vew {
	/// Adorn self (a Part) in parentVew, using config (a VewConfig)
	///   Adorn scn tree too
	/// - Parameters:
	///   - in parentVew: where Vew of self goes. If parentVew already contains
	///   a Vew, try to use it. Otherwise create one
	///   - openChildrenUsing config: config to open children using
	func openChildren(using config:VewConfig) {
		atRve(3, part.logd("openChildren(using:\(config.pp(.fullNameUidClass)))"))
																 // A new skin is made by Part:
																//?	let bbox = parentVew.part.reSkin(fullOnto:parentVew)		// skin of Part
																//?	parentVew.part.markTree(dirty:.size)
		switch config {
		case .openPath(let path):
			guard let subPathName = path.dequeFirstName(),						//guard let name = p != nil && tok.count > 0 ? tok[0] : nil,
			  let subPart		= children.first(where: { $0.name == subPathName} ) else { return }
			subPart.openChildren(using:config)		// #### SEMI-RECURSIVE CALL
		case .openAllChildren(let deapth):
			if deapth <= 1 {	break											}
			 // open our child Vews
			for childPart in children {
				childPart.openChildren(using:.openAllChildren(toDeapth:deapth-1))
			}
		case .subVewList(let vewConfigs):
			for vewConfig in vewConfigs {
				self.openChildren(using:vewConfig)
			}
		case .subVew(let fwConfig):
bug//		self.localConfig	= fwConfig	//??
			//print("??? adorn(.subVew(let fwConfig): ???")
			//panic(".subVew(\(fwConfig.pp(.phrase))")
		}
	}
//	/// Insure the Vews for the parts in config are present in self
//	/// - Parameter config: which parts should be opened
//	func touchVews(ofConfig config:VewConfig) {}
}
