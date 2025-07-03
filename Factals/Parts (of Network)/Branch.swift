//
//  Branch.swift
//  Factals
//
//  Created by Allen King on 2/21/25.
//

import SceneKit

//#pragma mark  4a Factory Access						// Methods defined by Factory
var atomsDefinedPorts:[String:String]	= [ //				id rv = [super atomsDefinedPorts];
//	 /// upper (splitter) half: Has P U
	 // Just as a reminder:
	//"P" 	: "pcd", 	// Bottom of upper half, connects to L <-.
	//"U" 	: "p  ",	// Unknown sensation
//	 /// bottom half:												 |
	"S"		: "pcd",	// Lowest Port in Branch 170202
	"L"		: "pc ",	// Top of bottom half, connects to P <---'
	"M"		: "p d",	// Modulator, enables
	"SPEAK"	: "p, d",	// Chooses shareProto[0,1]
	]


class Branch : Splitter {
	var speak		: Bool 		= false			// or 0->listen
	var noMInSpeak	: Bool 		= false
	var lPreLatch	: Float 	= 0.0
	
//	init() {														super.init()
//	}
	
	required init?(coder: NSCoder) {	fatalError("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {	fatalError("init(from:) has not been implemented") }
	
//    func deepMutableCopy() -> Branch {
//        let rv 				= super.deepMutableCopy() as! Branch
//        rv.speak 				= self.speak
//        rv.noMInSpeak 		= self.noMInSpeak
//        rv.lPreLatch 			= self.lPreLatch
//        return rv
//    }
								//
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()
		rv["S"] 				= "pcd"
		rv["L"] 				= "pc "
		rv["M"] 				= "p d"
		rv["SPEAK"] 			= "p d"
		return rv
	}
	 // atomsPortAccessors(sPort,	S,	 true)
	var     sPort   : Port! { getPort(named:"sPort", localUp:true, wantOpen:false, allowDuplicates:false) }
	var     sPortIn : Port! { sPort.con2?.port									}
	 // atomsPortAccessors(lPort,	L,	 false)
	var     lPort   : Port! { getPort(named:"lPort", localUp:false, wantOpen:false, allowDuplicates:false) }
	var     lPortIn : Port! { lPort.con2?.port 									}
	 // atomsPortAccessors(mPort,	M,	 true)
	var     mPort   : Port! { getPort(named:"mPort", localUp:true, wantOpen:false, allowDuplicates:false) }
	var     mPortIn : Port! { mPort.con2?.port 									}
	 // atomsPortAccessors(speakPort,SPEAK,true)
	var speakPort   : Port! { getPort(named:"speakPort", localUp:true, wantOpen:false, allowDuplicates:false) }
	var speakPortIn : Port! { speakPort.con2?.port 								}

	override init(_ config:FwConfig = [:]) {
		let config1 			= ["P":".L=", "bandColor":".L"] + config
		super.init(config1)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		if let speak 			= partConfig["SPEAK"]?.asPart as? Port {
			self.speak 			= speak.value == 0
		}
		if let noMInSpeak 		= partConfig["noMInSpeak"] as? Bool {
			self.noMInSpeak 	= noMInSpeak
		}
//		self.parameters["addPreviousClock"] = 1
	}
	override func sendMessage(fwType:FwType) {
bug;	logEve(4, "||      all parts: sendMessage(\(fwType)).")
		let fwEvent 			= HnwEvent(fwType:fwType)
		return receiveMessage(fwEvent:fwEvent)
	}
	 /// Recieve message and broadcast to all children
	override func receiveMessage(fwEvent:HnwEvent) {
		if fwEvent.fwType == .clockPrevious {
			logEve(4,"$$$$$$$$ << clockPrevious >>")
			clockPrevious()
		}
	}
	
	func clockPrevious() {
		logEve(4, "|| $$ clockPrevious to Branch: L=\(lPreLatch) (was \(lPort?.value ?? -1))")
		lPort!.take(value:lPreLatch)
	}
	
	override func simulate(up upLocal:Bool) {
		let sInPort 			= sPort.con2!.port ?? sPort
		//let mInPort 			= mPort.con2!.port ?? mPort
		let lInPort 			= lPort.con2!.port ?? lPort
		let speakInPort 		= speakPort.con2!.port ?? speakPort
		
		if speakInPort?.valueChanged() ?? false {
			let valPrev 		= speakInPort!.valuePrev
			let valNext 		= speakInPort!.value
			logEve(4, "Branch: speak=\(valNext) (was \(valPrev))")
bug//		self.speak = Int(valNext)
		}

		if !self.speak {
			if upLocal { //!downLocal {
				if sInPort!.valueChanged() {
					logEve(4, "Branch: S->lPre =(was)")
					logEve(4, "Branch: S->lPre =\(sInPort!.value) (was \(lPreLatch))")
					lPreLatch 	= sInPort!.value
				}
				super.simulate(up:upLocal)	// BOTTOM same
			} else {
				super.simulate(up:upLocal)	// TOP same
				if lInPort?.valueChanged() ?? false {
					let valPrev = lInPort!.valuePrev
					let valNext = lInPort!.value
					if let mPort = self.mPort {
						logEve(4, "Branch: L->M=\(valNext) (was \(valPrev))")
						mPort.take(value:valNext)
					} else {
						logEve(4, "Branch: L->S=\(valNext) (was \(valPrev))")
						sPort.take(value:valNext)
					}
				}
			}
		}
	}
	
//	override func pp1line(aux: Any?) -> String {
//		var rv = super.pp1line(aux: aux)
//		rv += " speak=\(speak) lPrev=\(lPreLatch) "
//		if noMInSpeak {
//			rv += "noMInSpeak "
//		}
//		return rv
//	}
}

let discThickness: Float = 0.5
let discDiameter: Float = 3.5

