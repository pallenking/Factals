//// SoundAtom.mm -- an Atom to connect to Generators C2014PAK
///*
//	  Ports:
//		 S	             S
//			         ----o----
//			  .-----|L|     in|-----.
//			  [      ^       |      ]
//sound:		  [      |       |      ]
//			  [sound |       |      ]
//			  [    ^\|       |      ]
//			  '-----|in     |L|-----'
//				     ----o----
//		 P			     P
// */
//import SceneKit
//
//class SoundAtom : Atom {
//
//	 // MARK: - 2. Object Variables:
//	var sounds 	: [String]		= []		// "" is quiet
//	var playing	: Bool			= false
//
//	 // MARK: - 3. Part Factory
//	override init(_ config:FwConfig = [:]) {
//
//		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		if let snds				= partConfig["sounds"] as? [String] {
//			sounds				= snds
//		}
//		assert(partConfig["sound"]==nil)
//	}
//	 // MARK: - 3.1 Port Factory
//	override func hasPorts() -> [String:String]	{
//		var rv					= super.hasPorts()
//		rv["S"]					= "af"
//		return rv
//	}
//
//	 // MARK: - 3.5 Codable
//	enum SoundAtomKeys: String, CodingKey {
//		case sound
//		case playing
//	}
//	 // Serialize
//	override func encode(to encoder: Encoder) throws  {
//		try super.encode(to: encoder)
//		var container 			= encoder.container(keyedBy:SoundAtomKeys.self)
//bug
////		try container.encode(sound,   forKey:.sound)
//		try container.encode(playing, forKey:.playing)
//		atSer(3, logd("Encoded  as? SoundAtom   '\(fullName)'"))
//	}
//	 // Deserialize
//	required init(from decoder: Decoder) throws {
//		try super.init(from:decoder)
//		let container 			= try decoder.container(keyedBy:SoundAtomKeys.self)
//
//bug//	sound	 				= try container.decode(String.self, forKey:.sound)
//		playing	 				= try container.decode(  Bool.self, forKey:.playing)
//		atSer(3, logd("Decoded  as? SoundAtom  named  '\(name)'"))
//	}
//	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
////	 // MARK: - 3.6 NSCopying
////	override func copy(with zone: NSZone?=nil) -> Any {
////		let theCopy				= super.copy(with:zone) as! SoundAtom
////		theCopy.docSound 			= self.docSound
////		theCopy.playing 		= self.playing
////		atSer(3, logd("copy(with as? LinkPort       '\(fullName)'"))
////		return theCopy
////	}
//	 // MARK: - 3.7 Equatable
//	override func equalsFW(_ rhs:Part) -> Bool {
//		guard self !== rhs 							else {	return true			}
//		guard let rhs			= rhs as? SoundAtom else {	return false 		}
//bug;		let rv				= super.equalsFW(rhs)
////								&& sound 	== rhs.sound
//								&& playing 	== rhs.playing
//		return rv
//	}
//	// MARK: - 4.1 Part Properties
//	func apply(prop:String, withVal val:String) -> Bool {
//
//		if prop == "sound" {			// e.g. "sound:di-sound" or
//			panic("Must debug! old code was:")
//			self.sounds			= [val]		// sound's val must be string
//			return true						// found a spin property
//		}
//		if prop == "sounds" {
//bug;		panic("Must debug! old code was:")
//		}
//		return super.apply(prop:prop, withVal:val)
//	}
//
//	 // MARK: - 8. Reenactment Simulator
//	let tickTock	= ["b","tick","t","tock"]		// tick b		// b t
//
//	override func simulate(up:Bool)  {
//		super.simulate(up:up)
//		let pPort				= ports["P"] ?? .error
//		let sPort				= ports["S"] ?? .error
//
//		if up {						// /////// going UP /////////
//			if let pPort2Port 	= pPort.con2?.port,
//			  pPort2Port.valueChanged() {			// Input = other guy's output
//				let (val, valPrev) = pPort2Port.getValues()	// Get value from S // let v1 = val, v2 = valPrev
//				sPort.take(value:val)				// Pass it on to P
//
//				if sounds.count==4 {
//					if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
//						vew0?.scn.play(sound:sounds[0])
//					}
//					if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
//						vew0?.scn.play(sound:sounds[1])
//					}
//				}
//			}
//		}
//		if !up {					// /////// going DOWN ////////////
//			if let sPort2Port	= sPort.con2?.port,
//			  sPort2Port.valueChanged() {
//				let (val, valPrev) = sPort2Port.getValues()	// Get value from P
//				pPort.take(value:sPort2Port.getValue())
//
//				if sounds.count==4 {
//					if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
//						vew0?.scn.play(sound:sounds[2])
//					}
//					if val<=0.5 && valPrev>0.5 { 	// Fallling Edge +
//						vew0?.scn.play(sound:sounds[3])
//					}
//				}
//			}
//		}
//	}
//	 // MARK: - 9.0 3D Support
//	override func typColor(ratio:Float) -> NSColor {	return .orange			}
//	 // MARK: - 9.4 rePosition
//	override func rePosition(portVew vew:Vew) {
//		let port				= vew.part as! Port
//		if port === ports["S"] {			// P: Primary
//			vew.scnRoot.transform	= SCNMatrix4(0, 2 + port.height, 0, flip:true)
//		}
//		else {
//			super.rePosition(portVew:vew) 
//		}
//	}
//
//	 // MARK: - 15. PrettyPrint
//	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
//		var rv 					= super.pp(mode, aux)
//		if mode ==  .line {
//			rv 					+= " sounds=\(sounds.pp(.line))"
//			if playing {
//				rv				+= " playing"
//			}
////?			assert(!(playing && sound != nil), "should not be!!!");
//		}
//		return rv
//	}
//}
