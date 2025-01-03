//
//  PortSound.swift
//  Factals
//
//  Created by Allen King on 12/28/24.
//

import SceneKit

class PortSound : Part {
								
	 // MARK: - 2. Object Variables:
	var sounds 	: [String]		= []		// "" is quiet
	var playing	: Bool			= false

	var port 	: String?		= nil
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
		portPort				??= getPlayerNode()	 // source as yet unresolved. This is rather ugly, but:
		guard sounds.count==4 else { 	return 									}
		if up {						// /////// going UP /////////
			if let pPort2Port 	= portPort!.con2?.port,
			  pPort2Port.valueChanged() {			// Input = other guy's output

				let (val, valPrev) = pPort2Port.getValues()	// Get value from S // let v1 = val, v2 = valPrev
				if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
					portPort!.vew0?.scn.play(sound:sounds[0])					}
//					vew0?.scn.play(sound:sounds[0])								}
				if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
					portPort!.vew0?.scn.play(sound:sounds[1])					}
			}
			super.simulate(up:up)
		}
		if !up {					// /////// going DOWN ////////////
			if portPort!.valueChanged() {

//				let (val, valPrev) = portPort!.getValues()	// Get value from P
//				if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
//					vew0?.scn.play(sound:sounds[2])								}
//				if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
//					vew0?.scn.play(sound:sounds[3])								}
			}
			super.simulate(up:up)
		}
	}
	func getPlayerNode() -> Port? {
		port==nil ? nil :     find(name:port!, up2:true) as? Port
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
