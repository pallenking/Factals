// SoundAtom.mm -- an Atom to connect to Generators C2014PAK
/*
	  Ports:
		 S	             S
			         ----o----
			  .-----|L|     in|-----.
			  [      ^       |      ]
sound:		  [      |       |      ]
			  [sound |       |      ]
			  [    ^\|       |      ]
			  '-----|in     |L|-----'
				     ----o----
		 P			     P
 */
import SceneKit

class SoundAtom : Atom {

	 // MARK: - 2. Object Variables:
	var sound 	: String? 		= nil
	var playing	: Bool			= false

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {

		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		if let snd				= localConfig["sound"] as? String {
			sound				= snd
			localConfig["sound"] = nil
		}
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv					= super.hasPorts()
		rv["S"]					= "af"
		return rv
	}

	 // MARK: - 3.5 Codable
	enum SoundAtomKeys: String, CodingKey {
		case sound
		case playing
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:SoundAtomKeys.self)

		try container.encode(sound,   forKey:.sound)
		try container.encode(playing, forKey:.playing)
		atSer(3, logd("Encoded  as? SoundAtom   '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:SoundAtomKeys.self)

		sound	 				= try container.decode(String.self, forKey:.sound)
		playing	 				= try container.decode(  Bool.self, forKey:.playing)
		atSer(3, logd("Decoded  as? SoundAtom  named  '\(name)'"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! SoundAtom
//		theCopy.sound 			= self.sound
//		theCopy.playing 		= self.playing
//		atSer(3, logd("copy(with as? LinkPort       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 							else {	return true			}
		guard let rhs			= rhs as? SoundAtom else {	return false 		}
		let rv					= super.equalsFW(rhs)
								&& sound 	== rhs.sound
								&& playing 	== rhs.playing
		return rv
	}
	// MARK: - 4.1 Part Properties
	func apply(prop:String, withVal val:String) -> Bool {

		if prop == "sound" {			// e.g. "sound:di-sound" or
			panic("Must debug! old code was:")
			self.sound			= val		//sound's val must be string
			return true						// found a spin property
		}
		return super.apply(prop:prop, withVal:val)
	}

	 // MARK: - 8. Reenactment Simulator
	override func simulate(up:Bool)  {
		super.simulate(up:up)
		let pPort				= ports["P"] ?? .error
		let sPort				= ports["S"] ?? .error

		if up {						// /////// going UP /////////

			if let pPort2Port 	= pPort.con2?.port,
			  pPort2Port.valueChanged() {			// Input = other guy's output
				let (val, valPrev) = pPort2Port.getValues()	// Get value from S
//				let v1 = val, v2 = valPrev 

				sPort.take(value:val)			// Pass it on to P

				 // Rising edge starts a Sound
				if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
					atDat(4, logd("starting sound '\(self.sound ?? "-")'"))
					
//					AppDel.appSounds.play(sound, onNode:)
//					if sObj.isPlaying {
//						print("\n\n NOTE: Going TOO FAST\n\n")
//					}
//					 // If this terminates the previous sound, it's okay!
//panic()//			sObj.play						// start playing sound
//					playing 	= true;				// delay loading primary.L
				}
			}
		}
		if !up {					// /////// going DOWN ////////////
			if let sPort2Port	= sPort.con2?.port,
			  sPort2Port.valueChanged() {
				pPort.take(value:sPort2Port.getValue())
			}
		}
		return;
	}
	 // MARK: - 9.0 3D Support
	func colorOf(ratio:Float) -> NSColor {	return .orange						}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["S"] {			// P: Primary
			vew.scn.transform	= SCNMatrix4(0, 2 + port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew) 
		}
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 					= super.pp(mode, aux)
		if mode ==  .line {
			if let s			= sound {
				rv 				+= " sound:'\(s)'"
			}
			if playing {
				rv				+= "playing"
			}
			assert(!(playing && sound != nil), "should not be!!!");
		}
		return rv
	}
}
