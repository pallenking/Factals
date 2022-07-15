//  DiscreteTime.swift -- Connects to the continuous-time HaveNWant network C2014PAK
// We assume that the network settles between samples.
// The Generator exposes a sequence of samples to a and records its response.
// The HaveNWant Network is exposed a sequence of numbers, and is given enough time inbetween samples for th

import SceneKit

class DiscreteTime : Atom {

	 // MARK: - 2. Object Variables:
	var resetTo			: Event?	= nil	// event at reset
	var inspecNibName	: String?	= nil 	// "nib"
	var inspecIsOpen	: Bool? 	= nil	// kind of a hack
	var incrementalEvents: Bool 	= false	// Next event inherets previous
	  // Sometimes just a name and no floating point value is specified.
	 //   e.g: "a". What is meant is a=anonValue. Typically anonValue = 1.0
	var anonValue : Float?		= nil

	 // MARK: - 3. Part Factory
	 /// Generates sample data in time
	 /// - parameter config_: 	-- configure FwBundle
	 /// # resetTo: String			-- event at start
	 /// # nib: String				-- name of Inspec's nib file
	 /// # incrementalEvents: Bool	-- values hold between events, must be explicitly cleared
	override init(_ config_:FwConfig = [:]) {
		let show : FwConfig = [:]//"expose":"atomic"]	///
		let config				= show + config_

		super.init(config) //\/\/\/\/\/\/\/\/\/

		if let nibString		= localConfig["nib"] as? String {
			inspecNibName		= nibString
			localConfig["nib"]	= nil
		}
		if let str 				= localConfig["resetTo"] as? Event {	//String
			resetTo				= str
		}
		if let incEv 			= localConfig["incrementalEvents"] as? Bool {
			incrementalEvents	= incEv
			localConfig["incrementalEvents"] = nil
		}
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()		// has 2 ports:
		rv["S"]					= "pcf"		// Secondary (always create)
		rv["P"]?				+= "M"		// Primary -- data comes out here
		return rv
	}

	 // MARK: - 3.5 Codable
	enum DiscreteTimeKeys:String, CodingKey {
		case resetTo
		case inspecNibName
		case inspecIsOpen
		case incrementalEvents
		case anonValue
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:DiscreteTimeKeys.self)

		try container.encode(resetTo, 			forKey:.resetTo)
		try container.encode(inspecNibName, 	forKey:.inspecNibName)
		try container.encode(inspecIsOpen, 		forKey:.inspecIsOpen)
		try container.encode(incrementalEvents, forKey:.incrementalEvents)
		try container.encode(anonValue, 		forKey:.anonValue)
		atSer(3, logd("Encoded  as? DiscTime    '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
        let container 			= try decoder.container(keyedBy:DiscreteTimeKeys.self)
    
		resetTo					= try container.decode(   Event.self, forKey:.resetTo)
		inspecNibName			= try container.decode(  String.self, forKey:.inspecNibName)
		inspecIsOpen 			= try container.decode(   Bool.self, forKey:.inspecIsOpen)
		incrementalEvents		= try container.decode(    Bool.self, forKey:.incrementalEvents)
		anonValue				= try container.decode(   Float.self, forKey:.anonValue)
		atSer(3, logd("Decoded  as? DiscTime   named  '\(name)'"))
	}

	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : DiscreteTime = super.copy(with:zone) as! DiscreteTime
		theCopy.resetTo			= self.resetTo
		theCopy.inspecNibName	= self.inspecNibName
		theCopy.inspecIsOpen	= self.inspecIsOpen
		theCopy.incrementalEvents = self.incrementalEvents
		theCopy.anonValue		= self.anonValue
		atSer(3, logd("copy(with as? DiscreteTime       '\(fullName)'"))
		return theCopy
	}

	 // MARK: - 3.7 Equitable
	func varsOfDiscreteTimeEq(_ rhs:Part) -> Bool {
		guard let rhsAsDiscreteTime = rhs as? DiscreteTime else { return false }
		return			    resetTo == rhsAsDiscreteTime.resetTo
			&& 		  inspecNibName == rhsAsDiscreteTime.inspecNibName
			&& 		   inspecIsOpen == rhsAsDiscreteTime.inspecIsOpen
			&& 	  incrementalEvents == rhsAsDiscreteTime.incrementalEvents
			&& 			  anonValue == rhsAsDiscreteTime.anonValue
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfDiscreteTimeEq(part)
	}

	 // MARK: - 5 Groom
	override func groomModelPostWires(root:RootPart) {
											super.groomModelPostWires(root:root)
		  // Connect up our targetBundle:
		 //
		guard let pPort			= ports["P"] else {
			return error("DiscreteTime has no 'P' Port")
		}
		if let targPort 		= pPort.portPastLinks {
			let targetBundle 	= targPort.parent as? FwBundle
			assert(targetBundle != nil, "targetBundle is nil")

			  // Test new target bundle has both R (for reset) and G (for generate)
			 //   (Commonly, these are Bindings)
			targetBundle?.forAllLeafs(
			{(leaf : Leaf) in									//##BLOCK
				assert(leaf.port(named:"R") != nil, "\(leaf.fullName): Leaf<\(leaf.type)>: nil 'R' Port")
				assert(leaf.port(named:"G") != nil, "\(leaf.fullName): Leaf<\(leaf.type)>: nil 'G' Port")
			})
		}
	}

	  // MARK: - 8. Reenactment Simulator
	override func reset() {								super.reset()
	  // / Generates a "resetTo" pattern to target bundle
		anonValue 				= 1.0			// first so resetTo = "a" sets a=1
		if let resetTo 			= self.resetTo {
			atEve(4, logd("|| resetTo '\(resetTo.pp())'"))
			let _ 				= loadTargetBundle(event:resetTo)
		}
	}
	func resetForAgain() {
		anonValue = 1.0				// anonymous value restarts on "again"
		atEve(4, logd("/// resetForAgain():"))
		ports["P"]?.portPastLinks?.take(value:0.0, key:nil)	// Perhaps discreteTimes[*]
	}
	 /// Load the next event to the target bundle:
	func loadTargetBundle(event:Event) {
		let pPort				= ports["P"]!				// Perhaps discreteTimes[*]
		let targetPort			= pPort.portPastLinks
		self.anonValue 			= 1.0
		switch event {
		case .anArray(let eventArray):	 // Event is an Array
			atEve(4, logd("|| LOAD Event '\(eventArray.pp())' into target \(pPort.fullName)"))

			 // First element of an array might set the current anonymous value
			if let ea0 			= eventArray.first {
			  	if case .aProb(let anonValue) = ea0 {		// cannot chain w ,
					self.anonValue = anonValue
					atEve(4, logd("|| Element 1 ='\(ea0.pp())'; \(anonValue) => anonValue"))
			  	}
			}
			 // Clear all Ports:
			if !incrementalEvents {
/**/			targetPort?.take(value:0.0, key:nil)	// nil -> all
			}
			 // Load Event:
/**/		if let label 		= loadEvent(event:event) {
				let tunnel		= targetPort!.atom! as! Tunnel
				tunnel.label	= label
//				targetBundle?.label = label // GUI: Labels in events are moved onto the bundle
			}
			root!.simulator.kickstart = 4 		// start simulator when event loads
		case .aString(let eventStr):	 	// Event is an String
			if eventStr == "incrementalEvents" {// "incrementalEvents" -- reserved word
				self.incrementalEvents = true	//  (do not use as signal name)
				atEve(4, logd("|| Event 'incrementalEvents' -- hold previous values"))
				return
			}
			loadTargetBundle(event: .anArray([event]))	// package up eventStr
		case .aProb(let prob):			 	// Event is a Floating Point --> Random Events (for easy first tests)
			atEve(4, logd("|| Event '\(prob)': RANDOMIZE targetBundle \(targetPort?.fullName ?? "?232")"))
			 // Put in random data
			let value = prob <= Float.random(from:0.0, to:1.0)
			panic("This doesn't give independent random values!")
			targetPort?.take(value:value ? 1.0 : 0.0, key:"*")
		 // Epochs are unsupported
		case .anEpoch(let eInt):			 // Event is a single number
			atEve(4, logd("|| Event '\(eInt)': Epoch Mark")) /// Integer --> 0 Epoch Mark
		default: 				// e.g: Event is an NSInteger, etc. -- no effect on
			atEve(4, atEve(4, logd("|| Event '\(event.pp(.line))': targetBundle '\(pPort.connectedTo?.fullName ?? "-")' UNCHANGED")))
		}
	}
	  /// Load an event into the target bundle.
	 /// The event may be a String, Number, or Array
	/// - parameter event: - data to be loaded through 
	/// - returns: a label for display (e.g. for Morse Code)
	func loadEvent(event:Event) -> String? {
		var rv_label:String? 	= nil// A label that the event has for the bundle.
									//  e.g: the name of the letter for Morse Code
		switch event {
		case .aString(let eventStr): 	//  EVENT STRING: A lone string acts as an array of 1 element
			rv_label 			= loadBit(named:eventStr)			// E.g: "a"
		case .anArray(let eventArray):	//  EVENT ARRAY: process multiple signals inside
			for event in eventArray {								// E.g: [ ... ]
				switch event {	 	  	// go through all signals in event:
				case .aString(let signal):
					if let ev_label = loadBit(named:signal) {
						rv_label = (rv_label ?? "") + ev_label  // catenate all event labels
					}
				default: panic()
				}
//				if case .aString(var signal) = event {
//					if let ev_label = loadBit(named:signal) {
//						rv_label = (rv_label ?? "") + ev_label  // catenate all event labels
//					}
//				}
//				else {
//					panic()
//				}
			}
		case .anEpoch(let eventNum):	 //  EVENT NUMBER: 0 means no signals: n is illegal
			assert(eventNum == 0, "\(eventNum) is illegal epoch")	// E.g: 0
		default:
			panic("event '\(event.pp(.line)))' malformed")
		}
		return rv_label
	}

	func loadBit(named signal:String) -> String? {
		var rv : String?		= nil
		assert(!signal.contains(substring:"/"), "Signal '\(signal)' must not contain '/'")

		 // Parse signal string. <name> = <valueSpec>
		let comp 				= signal.split(separator:"=")
		var theValue 			= Float(1.0)		  // Default value to load
		if (comp.count==1), 				 		 // e.g: "foo"
		  !(anonValue?.isNan)! {					//   anonValue ==> foo
			theValue 			= anonValue!
		}
		else if comp.count==2 && comp[0].count != 0 { // it is legal for names to start wit an "="
			let sigVal 			= String(comp[1])
			if let v 			= Float(sigVal) {	 // e.g: "foo=0.2"
				theValue 		= v					//   0.2 ==> foo
			}
			else if sigVal.hasPrefix("rnd ") {    	 // e.g: "foo=rnd 0.3"
				let prob 		= Float(sigVal[4...])!//   1 with prob 0.3 ==> foo
				let r 			= Float.random(from:0, to:1.0)
				theValue 		= prob < r ? 1.0 : 0.0
			}
			else if sigVal.hasPrefix("rVal ") {		 // e.g: "foo=rVal 0.3"
				let rVal 		= Float(sigVal[5...])!//   0 >= foo >= 0.3 (boxcar)
				theValue 		= Float.random(from:0, to:rVal)
			}
			rv 					= sigVal	// signal has bundle label, based on contents
		}
		let sigName				= String(comp[0])	// Leaf name <== value
		if let pPort			= ports["P"]?.portPastLinks {
			let was				= pPort.valuePrev	// pPort!.getValues(key:sigName)
			atEve(4, pPort.logd("|| /\\/\\ '\(pPort.name)'.take(value:\(theValue), key:\(sigName)), was \(was)"))
			pPort.take(value:theValue, key:sigName)
		}
//		else { panic("DiscreteTime 'P' Port fault") }

		  // hack: If we are part of a GenAtom, load the S Port also.
		 //        This allows initial values to be synced with .nib values
		if let ga 				= parent as? GenAtom {
			ga.ports["S"]?.take(value:theValue)
		}
		return rv		//  label
	}
	 // MARK: - 9.3 reSkin
	var height : CGFloat	{		return 1									}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Atom") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Atom"
			scn.geometry		= SCNBox(width:7, height:height, length:7, chamferRadius:1)
//			scn.geometry		= SCNCylinder(radius:3, height:height)
			scn.position.y		= height/2
			scn.color0			= NSColor("darkgreen")!//.orange
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port == ports["P"] {
			assert(!port.flipped, "P Port in DiscreteTime must be unflipped")
			vew.scn.transform	= SCNMatrix4(0, -port.height,0)
		}
		else if port == ports["S"] {
			vew.scn.transform	= SCNMatrix4(0, height + port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}
	override func reVew(vew:Vew?, parentVew:Vew?) {
	  // / Add InspecVc
		super.reVew(vew:vew, parentVew:parentVew)
		 // inspecNibName --> automatically add an InspecVc panel
		// (might move into -postBuild
		if inspecNibName != nil && !inspecIsOpen! {
			panic()
			//[self.brain.simNsWc.inspecVcs2open addObject:mustBe(Vew, view)]
		}
		self.inspecIsOpen = true		// only open once
	}
		 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv					= super.pp(mode, aux)
		switch mode! {
		case .phrase, .short, .line:
			if aux.bool_("ppParam") {	// a long line, display nothing else.
				return rv
			}
			rv					+= " resetTo='\(resetTo?.pp(.line) ?? "nil")'"
			rv					+= " inspecNibName='\(inspecNibName ?? "nil")'"
//			if resetTo != nil {
//				rv				+= " resetTo='\(resetTo!.pp(.line))'"
//			}
//			if inspecNibName != nil {
//				rv				+= " inspecNibName='\(inspecNibName!)'"
//			}
		default:
			break
		}
		return rv
	}
}
