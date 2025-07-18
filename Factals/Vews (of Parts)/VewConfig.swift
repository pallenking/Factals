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
	case openPath(to:Path)					// Only children on path are effected
	case openAllChildren(toDeapth:Int = -1)	// Open all of children, down to deapth
	case subVewList([VewConfig])			// array of directives, to
	case subVew(FwConfig)

	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		switch mode {
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
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
	}
	 // MARK: - 16. Global Constants
	static let null				= subVew([:])
	static let atom				= subVew([:])
	 // MARK: - 17. Debugging Aids
	var description			: String 	{	return "'\(pp(.short))'"			}
	var debugDescription	: String	{	return "'\(pp(.short))'"			}
	var summary				: String	{	return "'\(pp(.short))'"			}
}

 // VewConfig's for testing
let vewConfig1					= VewConfig.openPath(to:Path(withName: "ROOT/a.P"))
let vewConfig2					= VewConfig.openAllChildren(toDeapth:8)
let vewConfig3					= VewConfig.subVewList([vewConfig1, vewConfig2])
//let vewConfig4  				= VewConfig.subVew(["name":"vewConfig1"])
let vewConfigAllToDeapth4		= VewConfig.openAllChildren(toDeapth:4)

extension Vew {
	/// Adorn a Part (self) in parentVew, using config (a VewConfig)
	///   Adorn scnScene tree too
	/// - Parameter config: how to open children
	func openChildren(using config:VewConfig) {
		logRve(3, "Vew(\(fullName)).openChildren(using:\(config.pp(.phrase))))")		// vew.
		switch config {
		case .openPath(let path):			// Open all Vews in Path
			if path.tokens.count > 0,
			  let subVew		= children.first(where:{$0.name==path.tokens[0]})
			{	subVew.openChildren(using:config)	}		// #### SEMI-RECURSIVE CALL
		case .openAllChildren(let deapth):
			if deapth <= 1 {	break											}
			 // ensure each childPart has a childVew
			for childPart in part.children {
				let childVew	= self.find(part:childPart, maxLevel:1) ?? {
					let vew		= childPart.VewForSelf()
					self.addChild(vew)
					return vew
				}()
				childVew?.openChildren(using:.openAllChildren(toDeapth:deapth-1))
			}
		case .subVewList(let vewConfigs):
			for vewConfig in vewConfigs {
				self.openChildren(using:vewConfig)
			}
		case .subVew(let fwConfig):
			bug//self.partConfig = fwConfig	//??
			print("??? adorn(.subVew(let fwConfig): ???")
			panic(".subVew(\(fwConfig.pp(.phrase))")
		}
	}
//	/// Insure the Vews for the parts in config are present in self
//	/// - Parameter config: which parts should be opened
//	func touchVews(ofConfig config:VewConfig) {}
}
