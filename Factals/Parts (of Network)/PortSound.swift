//
//  PortSound.swift
//  Factals
//
//  Created by Allen King on 12/28/24.
//

import SceneKit

class PortSound : Part {
								
	 // MARK: - 2. Object Variables:
	var sounds 	: [String]		= ["", "", "", ""]		// 4 sounds for up(/\) and down (/\), "" is quiet
	var playing	: Bool			= false

	var inPstr 	: String?		= nil		// monitor Port's in-side
	var outPstr : String?		= nil		// monitor Port's out-side
	var inPort  : Port?			= nil
	var outPort : Port?			= nil

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig=[:]) {
		super.init(config)	 //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		if let snds				= partConfig["sounds"] as? [String] {
			guard snds.count==4 else {	fatalError("PortSound: sounds array must have 4 elements")}
			sounds				= snds											}
		if let inStr			= partConfig["inP"] as? String {
			inPstr				= inStr		/* e.g. v.P or atom.S	*/			}
		if let out_				= partConfig["outP"] as? String {
			outPstr				= out_		/* e.g. v.P or atom.S	*/			}
	}
	required init?(coder: NSCoder) 				{fatalError("init(coder:) has not been implemented") }
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	 }

	override func simulate(up:Bool)  {
		 // might be done once in a late phase of initialization
		let inPort				= inPort ?? (inPstr==nil ? nil
								:	find(name:inPstr!, up2:true) as? Port)
		let outPort				= outPort ?? (outPstr==nil ? nil
								:	find(name:outPstr!, up2:true) as? Port)

		if let port				= up ? inPort : outPort,
		  (port.value >= 0.5) != (port.valuePrev >= 0.5) {
			let soundIndex		= port.value >= 0.5 ? (up ? 0 : 2) : (up ? 1 : 3)
			vewFirstThatReferencesUs?.scn.play(sound:sounds[soundIndex])
		}
	}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn : SCNNode		= vew.scn.findScn(named:"s-Sound") ?? {
			let rv				= SCNNode(geometry:SCNSphere(radius:0.2))
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-Sound"
			rv.color0			= .red.change(alphaTo:0.7)	//skinAlpha
			return rv
		} ()
		let bbox 			 	= scn.bBox()
		return bbox * scn.transform  // return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
//		return vew.bBox						// vew.scnScene.bBox()
	}											 //scnScene.bBox()// Xyzzy44 ** bb
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv					= super.pp(mode, aux)
		if mode ==  .line {						//		if case .line = mode {
			rv 					+= "sounds:\(sounds.count) inP:\"\(inPstr ?? "nil")\"" +
								   " -> \(inPort?.pp(.fullNameUidClass) ?? "nil")"
		}
		return rv
	}
}
