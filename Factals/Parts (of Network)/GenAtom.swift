// GenAtom.swift -- an Atom to connect to Generators C2014PAK

import SceneKit


/*  Shown unflipped (not opening up)

	  Ports:
		LOOP  .-----------------.          LOOP (Optional)
			  [					 \    ----o----
			  [	                  '--|L|     in|-.
			  [	     		                /    ]
gen:		  [			 loop		       /     ]
              [     	.-----------------~      ]
			  [        v              			 ]
			  [	   .->-x-->. val      			 ]
			  [    |       | /         			 ]
		P	  '---|in     |L|--------------------"
				   ----o----
		 			   P				        --> slider/button

   		 P	           P
                   ----o----
 				  |L|     in|

 */

class GenAtom : Atom {

	 // MARK: - 2. Object Variables:
	var value : Float?	= nil
	var loop :  Bool?	= nil
    	// loop!=0 ==> always loop P.in-->P.L
		// loop==0 ==> loop P.in-->P.L if Port LOOP.in>0.5

	 // MARK: - 3. Part Factory
	/// - Parameter config_: hash with parameters:
	/// 1.	"value" -- value of Atom's Port
	/// 2.	"loop" -- perform loop
	override init(_ config:FwConfig = [:]) {

		super.init(config) //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

		self.value				= Float.nan			// initial value
		if let v				= partConfig["value"] {  // Single String:
			value				= v.asFloat ?? Float.nan
			partConfig["value"] = nil
		}
//		self.value				= Float.nan			// initial value
//		if let v				= partConfig["value"] as? String {  // Single String:
//			self.value			= Float(v)
//			partConfig["value"] = nil
//		}
		if let loop				= partConfig["loop"] as? String {
			self.loop			= Bool(loop)
			partConfig["loop"] = nil
		}
	}

	 // MARK: - 3.5 Codable
	enum GenAtomKeys: String, CodingKey {
		case value
		case loop
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:GenAtomKeys.self)

		try container.encode(value, forKey:.value)
		try container.encode(loop, 	forKey:.loop)
		logSer(3, "Encoded  as? GenAtom     '\(fullName)'")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:GenAtomKeys.self)

		value	 				= try container.decode(Float.self, forKey:.value)
		loop	 				= try container.decode( Bool.self, forKey:.loop)
		logSer(3, "Decoded  as? GenAtom    named  '\(name)'")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()
		rv["LOOP"]				= "p"
		return rv
	}
	 // All Atoms have a P Port, made at init(): (for some reason)
	lazy var loopPort: Port	= .error		// nullPort gone by end of init()
	var loopPortIn	: Port { return loopPort.con2!.port! }
	 // MARK: - 3.5 Codable
	 // MARK: - 3.6 NSCopying
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 						  else {	return true			}
		guard let rhs			= rhs as? GenAtom else {	return false		}
		let rv					=  super.equalsFW(rhs)
								&& value == rhs.value
								&& loop  == rhs.loop
		return rv
	}
	 // MARK: - 8. Reenactment Simulator
	override func reset() {								super.reset()

		 // We want self.value to be set up before bindings
		if !(value?.isNan ?? true)	{						// constant value from self.value
			ports["P"]!.take(value:value!)						// set it
		}
	}
	override func simulate(up upLocal:Bool) {
		super.simulate(up:upLocal)
								
		if upLocal,				// /////// going UP /////////
		  let pPort				= ports["P"],
		  let _					= pPort.con2?.port?.getValue(),	// drain any existing
		  let loopPort 			= ports["LOOP"],
		  let loopPort2Port		= loopPort.con2?.port,
		  let pPort2Port		= pPort.con2?.port
		{
			let loopVal			= loopPort2Port.getValue()	// always read LOOP to clear changed
		//	let pPortVal		= pPort2Port.valueChanged()

			let pInVal 			= pPort2Port.getValue()		// always read P to clear changed
			if loopVal > 0.5 || (loop ?? false) {	// Two causes, port or config
				logDat(4, "Loop to value \(pInVal) to sPort")
				pPort.take(value:pInVal)					// looped value from pPortIn
			}
			 // GenAtom has the power to generate a constant value
			if !(value?.isNan ?? true) {			// constant value from self.value
				pPort.take(value:value!)					// set it
			}
		}
	}

	 // MARK: - 9.0 3D Support
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["LOOP"] {
			assert(port.flipped == false, "LOOP Port in Previous must be unflipped")
			vew.scnRoot.transform	= SCNMatrix4(1, vew.bBox.max.y+port.height, 0)
		}
		else if port === ports["S"] {
			assert(port.flipped, "S Port in Previous must be flipped")
			vew.scnRoot.transform	= SCNMatrix4(0, vew.bBox.max.y+port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}

	 // MARK: - 9.3 reSkin
	var height : CGFloat	{ return 0.2	}
	var radius : CGFloat	{ return 1.2	}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-GenAtom") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-GenAtom"

			scn.geometry		= SCNCylinder(radius:radius, height:height)
			scn.position.y		= height/2
			scn.color0			= .orange
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
	override func typColor(ratio:Float) -> NSColor {	return .orange			}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv 					= super.pp(mode, aux)
		if mode == .line {
			rv 					+= loop ?? false ? " loop" : ""
			rv					+= value==nil || value!.isNaN ? ""
									: fmt(" value=%.2f", value!)
		}
		return rv
	}
}
