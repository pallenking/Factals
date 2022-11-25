//  MultiLink.swift -- a Link with multiple values flowing through it ©2020PAK

import SceneKit

/// A Link with multiple sub-Links
class MultiLink : Link {

	 // MARK: - 1. Class Variables:
	override var linkSkinType		: LinkSkinType	{	
		get {			return .ray 	}
		set(v) {		panic("MultiLink linkSkinType HELP!!")}
	}
	
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv					= super.hasPorts()			// has 2 ports:
		rv["P"]					= "cM"
		rv["S"]					= "cfM"
		return rv
	}
	override func simulate(up upLocal:Bool) {
	}
	// Simplicity -- no variables here!
	 // MARK: - 3.5 Codable
//	 // MARK: - 3.6 NSCopying
//	 // MARK: - 3.7 Equatable
//	override func equals(_ rhs:Part) -> Bool {
//		return super.equals(rhs)
//	}
}
