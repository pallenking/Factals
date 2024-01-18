// Previous.swift -- Remembers what happened previously, used for prediction C2014PAK

/*
 */

import SceneKit

  /// A Previous is an Atom with a time delay. It has 3 Ports
class Previous : Atom {

	 // MARK: - 2. Object Variables:
	var bias : Float			= 0.0		// used for halucination

	// =============== Major Modes ==============
	enum MajorMode : String, Codable {
		case monitor, simModeDir, simMode2
	}
	var majorMode  : MajorMode	= .monitor// set during construction, constant during operation

	// =============== Minor Modes  ==============
	enum MinorMode : String, Codable {		//prevMinorMode
		case hold				= "hold"
		case monitor			= "monitor"
		case simForward			= "simForward"
		case simBackward		= "simBackward"
		case netForward			= "netForward"
		case netBackward		= "netBackward"		// FW used prevMinorModeNames
	}
	var minorMode  : MinorMode 	= .monitor		// changes per M&N .prevMinorModeMonitor

	// =============== Multiplexor Sources ==============
	enum PrevMuxSources : String, Codable {
		case UNDEF 				= "-"
		case fromPPri			= "p"
		case fromSCur			= "s"
		case fromTPrev			= "t"
		case fromLLatch			= "l"
		case fromZero			= "0"
		case fromBias			= "b"
	}
	 // UP
	var src4sCur  : PrevMuxSources = .UNDEF	// bias,  pPri,	lLatch
	var src4tPrev : PrevMuxSources = .UNDEF	// bias,  pPri,	lLatch
	 // LATCH
	var src4lLatch: PrevMuxSources = .UNDEF	// pPri,  sCur,	tPrev
	 // DOWN
	var src4pPri  : PrevMuxSources = .UNDEF	// zero,  sCur,	tPrev

	 // MARK: - 3. Part Factory
	 /// A Previous remembers what happened previously. It is used for prediction.
	/// 1.	"bias":<float> -- for hallucinations
	/// 2.	"mode" -- how it operates
	/// 	- zero
	/// 	- monitor
	/// 	- simForward
	/// 	- simBackward
	/// 	- netForward
	/// 	- netBackward
	override init(_ configArg:FwConfig = [:]) {

		super.init(configArg)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		let config 				= localConfig

		 // Set mode:	
		majorMode 				= .monitor				// Default is monitor  :MajorMode
		minorMode 				= .monitor				// ""
		if let modeStr 			= config.string("mode") {		// From factory
	print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Previous")
//		majorMode 			= MajorMode(rawValue: modeStr)	// never changes
//
//			let index : String	= modeStr
////bug;		let index 			= prevMinorModeNames.index(of:modeStr)			//NSInteger index = [prevMinorModeNames indexOfObject:mode]
//			 // default:
//			if let n			= modeStr as? Int {						// major mode = 0 --> Default
//				assert(n == 0, "only number 0 (=null mode) defined")
//				majorMode 		= .monitor
////				minorMode 		= .prevMinorModeMonitor
//			}
//			 // minor is static and equal to major
//			else if index != nil {						// major mode is also a minor mode:
////				minorMode		= (PrevMinorMode)index		// (presumes order maintained with prevMinorModeNames)
//			}
//			 // minor depends on major and M (?and N):
//			else if modeStr == "simModeDir" {
////				minorMode		= .prevMinorModeSimBackward	// Default: M==0 ==> Backward
//			}
//			else if modeStr == "simMode2" {
////				minorMode		= .prevMinorModeHold			// Default: M==N==0 ==> Hold
//			}
//			else {
////				panic("PreviousX: unknown mode:'%'", modeStr)
//			}
//			 // Set bias:
//			bias				= 0.555
//			if let b			= configArg.float("bias") {
//				bias 			= b
//			}	
		}
		src4					= .monitor			//.hold??

		   // Latch Port connects to self
		  // This causes it to be counted in the unsettledCount
		 // and thus it flows out to P,S, or T
		if let latchPort		= ports["L"] {
			latchPort.noCheck	= true				// of up/down
			latchPort.con2 		= .port(latchPort)
		}
		   // //////// check for consistency here... /////
		//configArg["addPreviousXClock"] = 1
	}

	 // Set the Previous's "plumbing", who connects to whom.
	//- (void) setSrc4:(PrevMinorMode)mode {	}
	var src4 : MinorMode {
		get {	return  .hold }
		set(mode) {
			switch (mode) {
			case	.hold:
				src4pPri		= .fromLLatch
				src4sCur		= .fromZero
				src4tPrev		= .fromZero
				src4lLatch		= .fromLLatch
			case	.monitor:
				src4pPri		= .fromSCur
				src4sCur		= .fromPPri
				src4tPrev		= .fromLLatch
				src4lLatch		= .fromPPri
			case	.simForward:
				src4pPri		= .fromSCur
				src4sCur		= .fromBias
				src4tPrev		= .fromLLatch
				src4lLatch		= .fromSCur
			case	.simBackward:
				src4pPri		= .fromTPrev
				src4sCur		= .fromLLatch
				src4tPrev		= .fromBias
				src4lLatch		= .fromTPrev
			case	.netForward:		// added 160402
				src4pPri		= .fromSCur				// <-SNext
				src4sCur		= .fromBias
				src4tPrev		= .fromPPri				// ->tCur
				src4lLatch		= .fromLLatch//fromZero
			case	.netBackward:
				src4pPri		= .fromTPrev
				src4sCur		= .fromPPri
				src4tPrev		= .fromBias
				src4lLatch		= .fromLLatch//fromZero
//			default:
//				panic("Previous' minorMode illegal")
			}
		}
	}
	  // MARK: - 3.1 Port Factory
 	override func hasPorts() -> [String:String]	{
		//return [:]
 	//	rv["P"]					= nil

 		var rv 					= super.hasPorts()		// probably returns P
		rv["S"]					= "cf"	// Create at birth
// 		rv["S"]					= "pc "	// sCur	Secondary Port, value at Current time	//rv["P"]		= "pcd"	// pPri	Primary Port
		rv["T"]					= "cf"
// 		rv["T"]					= "pc "	// tPrev:	Terciary Port, value at PreviousX time
 		rv["L"]					= "pc"	// lLatch:	the State Port held in the PreviousX
 		rv["M"]					= "p"	// mMode	controls dir or fwd
 		rv["N"]					= "p"	// nMode:	controls bkw
		// permanent bindings
		rv["+"]					= "b:S"
		rv[""]					= "b:S"
		rv["-"]					= "b:T"
 		return rv
 	}
	 // MARK: - 3.5 Codable
	enum PreviousKeys:String, CodingKey {
		case bias
		case majorMode
		case minorMode
		case src4sCur
		case src4tPrev
		case src4lLatch
		case src4pPri
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 		= encoder.container(keyedBy:PreviousKeys.self)

		try container.encode(bias, 				   forKey:.bias)
		try container.encode(majorMode	.rawValue, forKey:.majorMode)
		try container.encode(minorMode	.rawValue, forKey:.minorMode)
		try container.encode(src4sCur	.rawValue, forKey:.src4sCur)
		try container.encode(src4tPrev	.rawValue, forKey:.src4tPrev)
		try container.encode(src4lLatch	.rawValue, forKey:.src4lLatch)
		try container.encode(src4pPri	.rawValue, forKey:.src4pPri)
		atSer(3, logd("Encoded  as? Previous      '\(fullName)'"))
	}
	  // Deserialize
	required init(from decoder: Decoder) throws {

		let container 			= try decoder.container(keyedBy:PreviousKeys.self)
		bias	 				= try container.decode(			Float.self,	forKey:.bias)
		majorMode	 			= try container.decode(		MajorMode.self, forKey:.majorMode)
		minorMode	 			= try container.decode(		MinorMode.self, forKey:.minorMode)
		src4sCur	 			= try container.decode(PrevMuxSources.self,	forKey:.src4sCur)
		src4tPrev	 			= try container.decode(PrevMuxSources.self,	forKey:.src4tPrev)
		src4lLatch	 			= try container.decode(PrevMuxSources.self,	forKey:.src4lLatch)
		src4pPri	 			= try container.decode(PrevMuxSources.self, forKey:.src4pPri)
		try super.init(from:decoder)
		atSer(3, logd("Decoded  as? Previous     named  '\(name)'"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Previous
//		theCopy.majorMode	 	= self.majorMode
//		theCopy.minorMode	 	= self.minorMode
//		theCopy.src4sCur	 	= self.src4sCur
//		theCopy.src4tPrev	 	= self.src4tPrev
//		theCopy.src4lLatch	 	= self.src4lLatch
//		theCopy.src4pPri	 	= self.src4pPri
//		atSer(3, logd("copy(with as? Actor       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 						   else {	return true			}
		guard let rhs			= rhs as? Previous else {	return false 		}
		let rv					= super.equalsFW(rhs)
								&& bias		  == rhs.bias
								&& majorMode  == rhs.majorMode
								&& minorMode  == rhs.minorMode
								&& src4sCur	  == rhs.src4sCur
								&& src4tPrev  == rhs.src4tPrev
								&& src4lLatch == rhs.src4lLatch
								&& src4pPri	  == rhs.src4pPri
		return rv
	}
	 // MARK: -  7. Simulator Messages
	override func receiveMessage(fwEvent:HnwEvent) {
		if fwEvent.fwType == .clockPrevious {//sim_clockPreviousX {
			atEve(4, logd("$$$$$$$$ clockPrevious generated by Previous:"))
			clockPrevious()		// PreviousX got -receiveMessage send customers
			return 					 // do not call super
		}
		super.receiveMessage(fwEvent:fwEvent)		// default behavior
	}

	func clockPrevious ()	{

		  // Update 'L' LATCH
		 //
		var newVal  : Float? 	= 0.0 				// do nothing initially
		var msg 				= "from zero "
		if let fromPort	=
			src4lLatch == .fromPPri   ?	ports["P"] : //pPriPort:	// pPri   //
			src4lLatch == .fromSCur   ?	ports["S"] : //sCurPort:	// sCur   //
			src4lLatch == .fromTPrev  ?	ports["T"] : //tPrevPort:	// tPrev  //
			src4lLatch == .fromLLatch ?	ports["L"] : //lLatchPort:	// lLatch //
			nil,
		  let from2Port			= fromPort.con2?.port {	// and it's connected
			newVal				= from2Port.getValue()		// +
			msg					+= "(from Port '\(src4lLatch.rawValue)') "
		} else if src4lLatch != .fromZero {
			panic("Illegal src4lLatch value")
		}
		 // Put new value in L
		if newVal != nil && !newVal!.isNan {
			atEve(4, logd("$$$$$$$$ \(msg) = %.2f was %.2f", newVal!, ports["L"]!.value))
			 //********//
			ports["L"]?.take(value:newVal!)
			 //********//
			RootPartActor_factalsModel?.simulator.startChits = 4	// start simulator after L port changes
			//root!.simulator.startChits = 4	// start simulator after L port changes
		}else{
			atEve(4, logd("$$$$$$$$ " + msg))
		}
	}

	// MARK: -  8. Reenactment Simulator
	// *//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*// ///
	// //*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//* ///
	// /*//*//*//*//*//*//*//    Reenactment Simulator   //*//*//*//*//*//*//*/ ///
	// *//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*// ///
	// //*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//* ///

	override func simulate(up upLocal:Bool) {
		super.simulate(up:upLocal)
		let pPriPort			= ports["P"]!	//  Pri Port
		let sCurPort			= ports["S"]!	//  Cur Port
		let tPrevPort			= ports["T"]!	// Prev Port
		let lLatchPort			= ports["L"]!	//Latch Port
		let (lLatchInVal, lLatchInPrev) = lLatchPort.con2?.port?.getValues() ?? (99,99)// must read every time to settle

		if upLocal {				//============: going UP ==================
			let (pPriInVal, pPriInPrev)	=   pPriPort.con2?.port?.getValues() ?? (99,99)// must read every time to settle
			if pPriInVal == pPriInPrev &&  lLatchInVal == lLatchInPrev {
				return
			}
			 // UP to 'S' (CUR) selector:				///--> sCur <-- //
			let nextValS 		= 		// ??? 
				src4sCur == .fromBias	?  bias			:	// bias  
				src4sCur == .fromPPri	?  pPriInVal	:	// pPri  
				src4sCur == .fromLLatch	?  lLatchInVal	:	// lLatch
				src4sCur == .fromZero	?  0.0			:	// zero  
										  .nan				// src4sCur is bad
			assert(!nextValS.isNan, "Illegal src4sCur value \(pp(fs:self.src4sCur))")
			sCurPort.take(value:nextValS)

			 // UP to 'T' (PREV) selector:				///--> tPrev <--///
			let nextValT = 
				src4tPrev == .fromBias	 ?	bias  		:	// bias  
				src4tPrev == .fromPPri	 ?	pPriInVal 	:	// pPri  
				src4tPrev == .fromLLatch ?	lLatchInVal :	// lLatch
				src4tPrev == .fromZero	 ?	0.0			:	// zero  
											.nan			// src4tPrev is bad
			assert(!nextValT.isNan, "Illegal src4tPrev value\(pp(fs:self.src4tPrev))")
			tPrevPort.take(value:nextValT)
		}
										//============: going DOWN ================

		else {	// DOWN to 'P' (SELF) selector:			///--> pPri <--///
			let (sCurInVal,  sCurInPrev) =  sCurPort.con2?.port?.getValues() ?? (99,99)
			let (tPrevInVal,tPrevInPrev) = tPrevPort.con2?.port?.getValues() ?? (99,99)
			if sCurInVal == sCurInPrev  &&  tPrevInVal == tPrevInPrev &&  lLatchInVal == lLatchInPrev {
				return
			}
			let nextVal 		= 
				src4pPri == .fromSCur   ?	sCurInVal	:	// sCur  //
				src4pPri == .fromTPrev  ?	tPrevInVal	:	// tPrev //
				src4pPri == .fromLLatch ?	lLatchInVal	:	// lLatch//
				src4pPri == .fromZero   ?	0.0			:	// zero  //
									.nan//("src4pPri bad")
			assert(!nextVal.isNan, "Illegal src4pPri value \(pp(fs:self.src4pPri))")
			pPriPort.take(value:nextVal)
			  // /// M and N Ports control the various PrevMuxSources
			 //
			if let mMode2Port	= ports["M"]?.con2?.port,
			  let nMode2Port 	= ports["N"]?.con2?.port {
				 // EITHER value changed
				let mvc : Bool?	= mMode2Port.valueChanged()
				let nvc : Bool?	= nMode2Port.valueChanged()
				if mvc! || nvc! {
					 // Read BOTH M and N mode Ports
					let mModeValue = mMode2Port.getValue()
					let nModeValue = nMode2Port.getValue()
					assert(mModeValue<=0.5 || nModeValue<=0.5, "Illegal: M and N Ports are both ON")

					var nextminorMode = minorMode	//case hold, monitor, simForward, simBackward, netForward, netBackward	*/
					 // here M determines fwd/bkw:
					if majorMode == .simModeDir {	//case monitor, simModeDir, simMode2
						nextminorMode = mModeValue > 0.5 ? .simForward  //prevMinorModeSim
														 : .simBackward //prevMinorModeSimBackward
					} // here M determines fwd N bkw
					else if self.majorMode == .simMode2 {
						nextminorMode = mModeValue > 0.5 ? .simForward	//prevMinorModeSimForward
									  :	nModeValue > 0.5 ? .simBackward	//prevMinorModeSimBackward
									  :					   .hold		//prevMinorModeHold
					}
					if minorMode != nextminorMode {
						self.minorMode = nextminorMode
						src4		= minorMode		// push mode into machine
						//Expression took 15258ms to type-check (limit: 200ms)
bug;						atDat(4, logd("Mode Port: " + //%% curMode=%-->%",
								(mvc! ? fmt("M=%.2f ", mModeValue) : "") +	//		cm? ["" addF:"M=%.2f ", mModeValue]: "",
								(nvc! ? fmt("N=%.2f ", nModeValue) : "") +
								self.minorMode.rawValue + " --> " + ppSrc4))	//prevMinorModeNames[self.minorMode], [self ppSrc4]))
						RootPartActor_factalsModel?.simulator.startChits = 4	// start simulator after changing minor mode
						//root!.simulator.startChits = 4	// start simulator after changing minor mode
					}
				}
			}
		}
	}

	 // MARK: - 9.3 reSkin
	var height : CGFloat	{ return 1.0		}	// 5
	var width  : CGFloat	{ return 6.0		}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Prev") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Prev"
//			scn.geometry		= SCNBox(width:0.2, height:0.2, length:0.2, chamferRadius:0.01)	//191113
			scn.geometry		= SCNBox(width:width, height:height, length:3, chamferRadius:0.4)
//			scn.position		= SCNVector3(1.0, height/2, 0)
			scn.position		= SCNVector3(1.5, height/2, 0)
			let color			= vew.scn.color0
//			let color			= NSColor.blue//.gray//.white//NSColor("lightpink")!//NSColor("lightslategray")!
			scn.color0			= color.change(saturationBy:0.3, fadeTo:0.5)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		let h 					= height + port.height
		if port === ports["S"] {					// S: Secondary
			vew.scn.transform	= SCNMatrix4(0, 	   h, 0, flip:true)
		}
		else if port === ports["T"] {				// T: Terciary
			vew.scn.transform	= SCNMatrix4(width/2, h, 0, flip:true)
		}
		else if port === ports["L"] { 				// Latch (internal)
			vew.scn.transform 	= SCNMatrix4(previousLatchX-1, -port.height*0.6, 0, flip:false)
		}
		else if port === ports["M"] {				// Mode
			port.spin 			= 3
//			port.latitude		= previousLatchX
			vew.scn.transform 	= SCNMatrix4(previousWidth-4, 1.5, -2, flip:false)
		}
		else if port === ports["N"] {				// Mode 2
			port.spin 			= 3
//			port.latitude 		= previousLatchX
	//		assert(!port.flipped, "N Port in Previous must be unflipped")
			vew.scn.transform 	= SCNMatrix4(previousWidth-4, 2.5, -2)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}

	 // MARK: -  9. 3D Support
	let previousWidth  : CGFloat = 6.0
	let previousHeight : CGFloat = 3.0
	let previousDeapth : CGFloat = 2.0
	let previousLatchX : CGFloat = 3.0

	   // MARK: -  15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
		var rv 					= super.pp(mode, aux)
		if mode == .line && !aux.bool_("ppParam")  {			//$
			rv					+= " Prev mode:?" /*self.majorMode + prevMinorModeNames[self.minorMode] + self ppSrc4*/
		}
		var xx					= self.minorMode
		return rv
	}
	var ppSrc4 : String {
		return fmt("P%S%T%L%", pp(fs:src4pPri),  pp(fs:src4sCur), pp(fs:src4tPrev), pp(fs:src4lLatch))
	}
	func pp(fs:PrevMuxSources) -> String  {
		return "fixme" //prevMuxSourceNames[fs]
	}
}
