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

	var soundNodeName : String?	= nil
	weak
	 var soundNode	  : Port?	= nil

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig=[:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		if let snds				= partConfig["sounds"] as? [String] {
			sounds				= snds
		}
		if let mon				= partConfig["monitor"] as? String {
			soundNodeName		= mon
		}
	}
	
	required init?(coder: NSCoder) {	fatalError("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}
	override func simulate(up:Bool)  {
		super.simulate(up:up)

		 // source as yet unresolved. This is rather ugly, but:
		if soundNode == nil {
			if soundNodeName != nil  {
				soundNode		= find(name:soundNodeName!, up2:true) as? Port
							//parent?.port(named:soundNodeName!, localUp:true,  wantOpen:true)
				soundNodeName 	= nil
			}
			guard soundNode != nil else { 		return 							}
		}

		if up {						// /////// going UP /////////
			if let pPort2Port 	= soundNode!.con2?.port,
			  pPort2Port.valueChanged() {			// Input = other guy's output
				let (val, valPrev) = pPort2Port.getValues()	// Get value from S // let v1 = val, v2 = valPrev

				if sounds.count==4 {
					if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
						vew0?.scn.play(sound:sounds[0])
					}
					if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
						vew0?.scn.play(sound:sounds[1])
					}
				}
			}
		}
		if !up {					// /////// going DOWN ////////////
			if soundNode!.valueChanged() {
				let (val, valPrev) = soundNode!.getValues()	// Get value from P

				if sounds.count==4 {
					if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
						vew0?.scn.play(sound:sounds[2])
					}
					if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
						vew0?.scn.play(sound:sounds[3])
					}
				}
			}
		}
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
}
