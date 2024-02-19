// WorldModel.swift -- Prototype discrete time world model C2017PAK

import SceneKit

 /// A WorldModel ia a generic discrete time/value data source
class WorldModel : Atom {

         // MARK: - 2. Object Variables:
	var timingChain:TimingChain? = nil
	var delayedEvents : [FwwEvent]? = []//nil

	 // ////////    E V E N T    OUTPUT METERING         /////////
	var eventNow				= 0		// current event number (>=1)
	 /// stop if eventLimit would be <= eventNow
	var eventLimit				= 0		// stop if eventNow would be > eventLimit
										//  (-1 implies no limit)
	  // ////////   E V E N T    G E N E R A T I O N     /////////
	 // Events in Hash
    var event : FwwEvent?		= nil	// to get event data
	var eventIndex				= 0		// current index in events
	var prob : Float?			= nil	// Simple Probability

	 // MARK: - 3. Part Factory
	     /// Prototype discrete time world model 
	  /// - parameter config: -- to configure FwBundle
	 /// ## --- eventLimit: Int	 -- Limit on generated events
	 /// ## --- events: FwwEvent -- Array of events
	 /// ## --- prob: Float		 -- random data with probability
	override init(_ config:FwConfig = [:]) {

		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		//!		x			--		x==1 (all default to 0)
		//!		x=.4		--		x==0.4

		if let ev				= FwwEvent(any:partConfig["events"]) {
			partConfig["events"] = nil
			event				= ev
		}
		if let eli				= partConfig["eventLimit"]?.asInt {
			eventLimit = eli
		}
		prob					= nil
		if let f				= partConfig["prob"]?.asFloat {
//		if let str				= partConfig["prob"],
//		  let f					= str.asFloat {
			prob				= f
		}
	}

	 // MARK: - 3.5 Codable
	enum WorldModelKeys:String, CodingKey {
		case timingChain
		case delayedEvents
		case eventNow
		case eventLimit
		case event
		case eventIndex
		case prob
	}
	 // SerializeaddIdStr(self)
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:WorldModelKeys.self)

		try container.encode(timingChain, 	forKey:.timingChain)
		try container.encode(delayedEvents, forKey:.delayedEvents)
		try container.encode(eventNow, 		forKey:.eventNow)
		try container.encode(eventLimit, 	forKey:.eventLimit)
		try container.encode(event, 		forKey:.event)
		try container.encode(eventIndex, 	forKey:.eventIndex)
		try container.encode(prob, 			forKey:.prob)
		atSer(3, logd("Encoded  as? WorldModel  '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
        let container 			= try decoder.container(keyedBy:WorldModelKeys.self)

		timingChain		= try container.decode(TimingChain.self, forKey:.timingChain)
		delayedEvents	= try container.decode(	[FwwEvent].self, forKey:.delayedEvents)
		eventNow		= try container.decode(  	   Int.self, forKey:.eventNow)
		eventLimit		= try container.decode(  	   Int.self, forKey:.eventLimit)
		event			= try container.decode(   FwwEvent.self, forKey:.event)
		eventIndex		= try container.decode(  	   Int.self, forKey:.eventIndex)
		prob			= try container.decode(  	 Float.self, forKey:.prob)
		atSer(3, logd("Decoded  as? WorldModel named  '\(name)'"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! WorldModel
//		theCopy.timingChain		= self.timingChain
//		theCopy.delayedEvents	= self.delayedEvents
//		theCopy.eventNow		= self.eventNow
//		theCopy.eventLimit		= self.eventLimit
//		theCopy.event			= self.event
//		theCopy.eventIndex		= self.eventIndex
//		theCopy.prob			= self.prob
//		atSer(3, logd("copy(with as? Actor       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 							 else {		return true		}
		guard let rhs			= rhs as? WorldModel else {		return false 	}
		let rv 					= super.equalsFW(rhs)
						//??		&& timingChain 	 == rhs.timingChain
						//??		&& delayedEvents == rhs.delayedEvents
								&& eventNow 	 == rhs.eventNow
								&& eventLimit	 == rhs.eventLimit
						//??		&& event 		 == rhs.event
								&& eventIndex 	 == rhs.eventIndex
								&& prob 		 == rhs.prob
bug;	return rv
	}
	 // MARK: - 5 Groom
	override func groomModelPostWires(parts:PartBase) {
											super.groomModelPostWires(parts:parts)
		let timingChainPort		= ports["P"]!.portPastLinks
		timingChain 			= timingChainPort?.parent as? TimingChain	//****
	}

	 // MARK: - 7. Simulator Messages
	func addDelayed(event:FwwEvent, asyncData:Bool, eventDownPause:Bool) {
		delayedEvents?.insert(event, at:0)
	}

	 // return next event generated by WorldModel, and it's simple methods
	func dequeEvent() -> FwwEvent? {

		 // Delayed Events have been stored here if timing chain was busy
		if let rv:FwwEvent	= delayedEvents?.popLast() {
			return rv
		}

		guard eventLimit < 0 || eventLimit > eventNow else { return nil			}
		guard event != nil 						else {	return nil	/* space in event */}
		guard case .anArray(let array)? = event else {	fatalError("Need an FwwEvent array here!")	}
		guard eventIndex < array.count			else {	return nil				}

		let rv 					= array[eventIndex]// get next FwwEvent
		eventIndex				+= 1

		 // Loop if rv (an enum) has the String value "again"
		if case let FwwEvent.aString(s) = rv, s == "again" {
			assert(eventIndex > 1, "'Again' cannot be first element of FwwEvent array")
			eventIndex 			= 0			// loop back to start
			// removed 191125
			// timingChain?.resetForAgain()	// clear out state in timingChain
			return dequeEvent()				// recursive call for next
		}
		 // Release FwwEvent to caller
		eventNow				+= 1
		return rv
	}

	 // MARK: - 8. Reenactment Simulator
	override func reset() {										super.reset()

		eventNow				= 0
		eventIndex				= 0
	}
	let wmDiam 					= 6.0

	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Wm") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Wm"
			scn.geometry		= SCNCylinder(radius:1.4, height:0.2)// (width: 0.2, height:2, length:4, chamferRadius:1)
//			scn.geometry		= SCNBox(width: 0.2, height:2, length:4, chamferRadius:1)
			scn.position.y		= 1
			scn.rotation		= SCNVector4(1,0,0, CGFloat.pi/2)
			scn.color0			= NSColor.red.change(saturationBy:0.85)//NSColor("lightslategray")!//.change(saturation:0.9)
			return scn
		} ()
		return scn.bBox() * scn.transform	// vew.scn.bBox()// Xyzzy44 ** sbt
	}

	// MARK: - 13. IBActions
	override func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {return false }

		 /* Single Step */				// //// key DOWN ///////
		if nsEvent.type == .keyDown {
			switch character {
			case "S":
				let el			= eventLimit >= 0 	// any Limits?
								?	-1 			  		// yes: START by turnomg limits OFF
								:	eventNow			// no:  STOP by limiting events
				atEve(4, logd("\n" + "=== EVENT: Key 'S' DOWN: eventLimit = \(el) (was \(eventLimit)) eventNow=\(eventNow)"))
				eventLimit		= el					// N.B: other process reads and starts
				return true
			case "s":
				let el			= eventLimit >= 0 ?	// any Limits?
									eventLimit + 1 :	// yes: increase by 1
									eventNow   + 1 		// no:  let 1 event through
									
				print("\n******************** 's' DOWN: eventLimit = \(el) (was \(eventLimit)) eventNow=\(eventNow)")
				eventLimit		= el					// N.B: other process reads and starts
				return true
			case "?":
				print("   === WorldModel \(timingChain!.fullName) commands:",
						"\t's'             -- single step generator",
						"\t'S'             -- toggle unlimited generation",
						separator:"\n")
			default: nop
			}
		}
		else if nsEvent.type == .keyUp {
			atEve(4, logd("\n=== EVENT: Key 's' UP, userUpEvent=1"))
		}
		return false
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 					= super.pp(mode, aux)
		if mode == .line {
			rv					= super.pp(mode, aux)
			if aux.bool_("ppParam") {	// a long line, display nothing else.
				return rv
			}
			rv					+= "sClk:'\(timingChain?.fullName16 ?? "nil")', "
			rv					+= "eventNow:\(eventNow) eventLimit=\(eventLimit) "

			if event != nil {
				rv				+= "eventIndex:\(eventIndex), events:\"\(event!.pp(.line, aux))\" "
		//		assert(eventIndex < events!.count, "eventIndex EXCEEDS LIMIT")
			}
			if prob != nil {
				rv				+= fmt(" prob=%.2f", prob!)
			}
		}
		return rv
	}
}

