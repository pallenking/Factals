//
//  PortSound.swift
//  Factals
//
//  Created by Allen King on 12/28/24.
//

import SceneKit

class PortSound : Part {
								
	 // MARK: - 2. Object Variables:
	var sounds 	: [String]		= []		// 4 sounds for up(/\) and down (/\), "" is quiet
	var playing	: Bool			= false

	var port 	: String?		= nil		// Port to both monitor and play sound on
	weak
	 var portPort : Port?		= nil

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig=[:]) {
		super.init(config)	 //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		if let snds				= partConfig["sounds"] as? [String] {
			sounds				= snds
		}
		if let pla				= partConfig["port"] as? String {
			port				= pla		// e.g. v.P or atom.S
		}
	}
	required init?(coder: NSCoder) {	fatalError("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}
	override func simulate(up:Bool)  {
		guard let portPort		= portPort ?? (port==nil ? nil
								:	find(name:port!, up2:true) as? Port)
								else { 	return 									}
		if !up {					// /////// going DOWN ////////////
			guard let vewFirstThatReferencesUs 		else { 	return 				}
			let (val, valPrev) = (portPort.value, portPort.valuePrev)
			if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
				vewFirstThatReferencesUs.scn.play(sound:sounds[0])				}
			if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
				vewFirstThatReferencesUs .scn.play(sound:sounds[1])				}
		}							// /////// going UP /////////
								//if up, let pPort2Port 	= portPort.con2?.port	{	// there is an UP
								//	let (val, valPrev) = (pPort2Port.value, pPort2Port.valuePrev)	// Get value from S // let v1 = val, v2 = valPrev
								//	if val>=0.5 && valPrev<0.5 { 	// Fallling Edge +
								//		portPort.vew0?.scn.play(sound:sounds[2])						}
								//	if val<=0.5 && valPrev>0.5 { 	// Rising Edge  +
								//		portPort.vew0?.scn.play(sound:sounds[3])						}
								//}
	}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1.6))
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-Leaf"
			return scn
		}()
		return vew.bBox						// vew.scnScene.bBox()//scnScene.bBox()// Xyzzy44 ** bb
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv					= super.pp(mode, aux)
		if mode ==  .line {						//		if case .line = mode {
			rv 					+= "sounds:\(sounds.count) port:\"\(port ?? "nil")\"" +
								   " -> \(portPort?.pp(.fullNameUidClass) ?? "nil")"
		}
		return rv
	}
}
