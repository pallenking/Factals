//  CommonAtoms.swift

import SceneKit

  /// An Ago is an Atom with a time delay. It has 2 Ports
 ////////////////////////////////////////////////////////////////////////////
class Portless : Atom {

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)		//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]			{	[:]					}
	 // Deserialize
	required init(from decoder: Decoder) throws { try super.init(from:decoder)	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Portless") ??  {
			let scn				= SCNNode()
			scn.name			= "s-Portless"
			scn.geometry 		= SCNCapsule(capRadius:0.5, height:2) //(width:[1,4][i], height:1, length:[4,1][i], chamferRadius:0.5)
			scn.color0			= .yellow
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}

class Ago : Atom {

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)		//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	// MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var ports 				= super.hasPorts()
		ports["S"]				= "cf"
		return ports
	}

	 // MARK: - 3.5 Codable
	required init(from decoder: Decoder) throws { try super.init(from:decoder)	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!

	// MARK: - 8. Reenactment Simulator
	override func simulate(up upLocal:Bool)  {
	  // / BROKEN, no clock!!!
		super.simulate(up:upLocal)
		let pPort				= ports["P"]
		let sPort				= ports["S"]
		if upLocal, 									/////// going UP
			let pPortCon2		= pPort?.connectedTo,
			pPortCon2.valueChanged() 	// ( and do nothing if no pPortIn )
		{
			let val		 		= pPortCon2.getValue()	///////	GET to my INPUT
			sPort!.take(value:val)			 		///////	PUT to my OUTPUT
		}
		if !upLocal, 									/////// going UP
			let sPortCon2		= sPort?.connectedTo,
			sPortCon2.valueChanged() 	// ( and do nothing if no pPortIn )
		{
			let val		 		= sPortCon2.getValue()	///////	GET to my INPUT
			pPort!.take(value:val)			 		///////	PUT to my OUTPUT
		}
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Ago") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Ago"

			for i in 0...1 {	// Two arms of an cross:
				let geom 		= SCNBox(width:[1,4][i], height:1, length:[4,1][i], chamferRadius:0.5)
				let arm 		= SCNNode(geometry:geom)
				arm.position	= SCNVector3(0, height/2, 0)
				arm.color0		= .purple
				arm.name		= "s-Ago\(i)"
				scn.addChild(node:arm, atIndex:0)
			}
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	var height : CGFloat	{ return 1.0		}
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port == ports["S"] {			//// S: Secondary
			assert(port.flipped, "S Port in Ago must be flipped")
			vew.scn.transform	= SCNMatrix4(0, height + port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv = super.pp(mode, aux)
		if mode == .line  && !aux.bool_("ppParam") {		//$
			rv					+= " Ago:?" /*self.majorMode + prevMinorModeNames[self.minorMode] + self ppSrc4*/
		}
		return rv
	}
}
// MARK: --------------------------------------
class Mirror : Atom {

	 // MARK: - 2. Object Variables:
	@Published var gain : Float = 1.0		// Default is Identity function
	{	didSet {	if gain != oldValue {
						root?.simulator.kickstart = 4		// gain changes simulation
						markTree(dirty:.paint)
																		}	}	}
	@Published var offset:Float = 0.0
	{	didSet {	if offset != oldValue {
						root?.simulator.kickstart = 4
						markTree(dirty:.paint)
																		}	}	}
	 // MARK: - 3. Part Factory
	/// Mirror input to output
	/// - Parameter config: configure Mirror
	/// * gain:Float
	/// * offset:Float
	override init(_ config:FwConfig = [:]) {
		super.init(config) // -/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		if let g				= localConfig["gain"]?.asFloat {
			gain 				= g
			localConfig["gain"]	= nil
		}
		if let ofs				= localConfig["offset"]?.asFloat {
			offset 				= ofs
			localConfig["offset"] = nil
		}
	}

	 // MARK: - 3.5 Codable
	enum MirrorKeys: String, CodingKey {
		case gain
		case offset
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:MirrorKeys.self)

		try container.encode(gain,	forKey:.gain)
		try container.encode(offset,forKey:.offset)
		atSer(3, logd("Encoded  as? Mirror      '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
        let container 			= try decoder.container(keyedBy:MirrorKeys.self)

		gain					= try container.decode(Float.self, forKey:.gain)
		offset					= try container.decode(Float.self, forKey:.offset)
		atSer(3, logd("Decoded  as? Mirror"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	 // MARK: - 3.7 Equitable
	func varsOfMirrortEq(_ rhs:Part) -> Bool {
		guard let rhsAsMirror		= rhs as? Mirror else {	return false		}
		return   gain == rhsAsMirror.gain
			&& offset == rhsAsMirror.offset
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfMirrortEq(part)
	}
	
	 // MARK: - 8. Reenactment Simulator
	override func simulate(up upLocal:Bool)  {
		super.simulate(up:upLocal)
		if upLocal {									/////// going UP
			assert(ports.count == 1, "Mirror: \(ports.count) Ports illegal")
			if let pPort		= ports["P"],
			  let pPortCon2		= pPort.connectedTo
			{
				let val		 	= pPortCon2.getValue()	///////	GET to my INPUT
				let val2 :Float = val * gain + offset
				let val3		= min(1.0, max(0.0, val2))
				if val3 != pPort.value {
					atDat(3, logd("mirror ===/=\\=/=\\=== \(val) -> \(val3)"))
					pPort.take(value:val3)			 		///////	PUT to my OUTPUT
				}
			}
		}
	}
	 // MARK: - 9.3 reSkin
	var height : CGFloat		{ 		return 0.6										}
	var size   : CGFloat		{ 		return 3.0										}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Mir") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Mir"

			scn.geometry		= SCNBox(width:size, height:height, length:size, chamferRadius:0.2)
			scn.position 		= SCNVector3(0, height/2, 0)
			scn.color0			= .orange
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}

// MARK: --------------------------------------
class Modulator : Atom {
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()	// probably returns "P"
		rv["S"]					= "cf"	// sCur;	Secondary Port
		rv["T"]					= "cf"	// tPrev:	Terciary Port
		return rv;
	}
	 // MARK: - 3.7 Equitable
	func varsOfModulatorEq(_ rhs:Part) -> Bool {
		guard let rhsAsModulator = rhs as? Modulator else {	return false		}
bug;	return sHeight == rhsAsModulator.sHeight
			&& sRadius == rhsAsModulator.sRadius
			&&  armLen == rhsAsModulator.armLen
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfModulatorEq(part)
	}
	 // MARK: - 9.3 reSkin
	let sHeight : CGFloat		= 0		//1.5
	let sRadius : CGFloat		= 2.5	//1.5
	let armLen  : CGFloat		= 4.0/2	//2.0
	override func reSkin(fullOnto vew:Vew) -> BBox {
		let scn					= vew.scn.find(name:"s-Modu") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Modu"
			scn.geometry		= SCNSphere(radius:sRadius/2)
			scn.position.y		= sHeight
			scn.color0			= NSColor.orange	//.change(alphaTo:0.3)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let p : Part			= vew.part
		var angle : CGFloat?	= nil
		if      p == ports["S"] { angle	=  .pi/3 }
		else if p == ports["T"] { angle	= -.pi/3 }
		else if p == ports["P"] { angle	= -.pi	 }
		else {
			return super.rePosition(portVew:vew)
		}
		let x					= -armLen * CGFloat(sin(angle!))
		let y					=  armLen * CGFloat(cos(angle!)) + sHeight
		vew.scn.transform		=  SCNMatrix4(x, y, 0, flip:true, latitude:angle!)
	}
}

// MARK: --------------------------------------
class Rotator : Modulator {
}

// MARK: --------------------------------------
class WriteHead : Atom {
}
//	class func conceiveBabyIn(wh:WriteHead, evi:Part, con:Part) -> Part {
//
//		  // Build this new element inside actor
//		 //
//		let baby : Part			= Hamming()
// //		let baby : Part		= aHamming(con, evi, ["flip":true])
// //
// //		 // Insert baby in its Actor's:
// //		wh.actor.addChild(baby)
// //		wh.baby 				= baby			// Restriction: 1 baby per WriteHead.  BAD!!
//panic()
//		return baby
//	}

