//  BundleTap.mm -- an Atom which loads data into a Bundle C2014PAK

// 171004 -- removed TimingChain and SimpleWorlds.
// 231101 -- transliterated from objc

import SceneKit

	//	Loads Symbolic Discret Time named scalar values
	//			into an analog Port's value output in a HaveNWant Bundle
	//		Samples too??
	//	Resets Bundle at start of run
	//	Symbolic Discrete Time Data may come from worldModel.
	//		a) Incremental change model, including "again"
	//		b) anonValue ("a" -> "a=<ananVlue>")
	//		c) random data for initial testing
	//		d) per-run random data
	//		e) Epoch Marks
	//	Data may come from GUI			// not yet debugged

	/// BundleTap communicates between
	/// 	WorldModel's symbolic data
	/// 	and the leafs of its attached targetBundle.
	///
class BundleTap : Atom {

	 // Construction properties
	let  resetTo 				: [String]?	// event at reset
	let  heightAlongRightSide	: Float?	// vert placement
	var  incrementalEvents 		: Bool?		// /*IBOutlet*/char incrementalEvents;// Next event inherets previous
	let  inspectorNibName		: String?	// "nib"
	var  inspectorAlreadyOpen	= false	 	// kind of a hack

	  // Sometimes just a name and no floating point value is specified.
	 //   e.g: "a". What is meant is a=anonValue. Typically anonValue = 1.0
	var anonValue 				: Float?	// used when value is unknwon

	 /////// where we put our data
	var targetBundle 			: FwBundle?

 	// MARK: - 4. Factory
 	override func hasPorts() -> [String:String]	{
 		var rv 					= super.hasPorts()		// probably returns P
		rv["S"]					= "pc";			// Secondary		(always create)
		return rv;
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {debugger("init(from:) has not been implemented")	}
	
		/// an Atom which generates data for a Bundle
		/// - Parameter config:
		/// -    key:"resetTo"				  value:<event>	-- on reset
		/// -    key:"nib"					  value:<name of nib file>.nib
		/// -    key:"heightAlongRightSide"   value:<float>
		/// -    key:"incrementalEvents"      value:<bool>	-- values hold between events, must be explicitly cleared
		/// -    key:"inspectorNibName"		  ???

	override init(_ config:FwConfig = [:]) {

		self.resetTo			= config["resetTo"] as? [String]
		self.inspectorNibName	= config.string("nib")
		self.heightAlongRightSide = config.float("heightAlongRightSide")
		self.incrementalEvents	= config.bool("incrementalEvents")

		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		assert(config["events"] == nil, "BundleTap does not support events any more")
		assert(config["asyncData"]==nil, "BundleTap does not support setting syncronousData")
	}

	// MARK: - 7. Simulation Actions
	override func reset() {											super.reset()

			 //   MOVE TO groomModelPostWires(partBase:PartBase) {
			/// Connect up our targetBundle:
		   ///
		 // my P-Port connects where?
		guard let pPort			= ports["P"],
		  let targPort 			= pPort.portPastLinks,
		  let targetBundle		= targPort.parent as? FwBundle
		else {
			print("$$$$$$$$ Burp: targetBundle is nil")
			return
		}
								//
		 // Test new target bundle; must have both R (for reset) and G (for generate)
		targetBundle.forAllLeafs {leaf in
			assert(leaf.port4leafBinding(name:"R") != nil, "\(leaf.fullName): 'R' Port") //Leaf<\(leaf.type)>: nil
			assert(leaf.port4leafBinding(name:"G") != nil, "\(leaf.fullName): 'G' Port") //Leaf<\(leaf.type)>: nil
//			guard let _			= leaf.port4leafBinding(name: "R"),
//			 let _ 				= leaf.port4leafBinding(name: "G") else {
//				debugger("Leaf \(self.pp(.fullName)) has no R or G port, needed by\n")	//type '\(leaf.type)' 
//				// "%@: %@: %@\nConsider using Leaf with a BundleTap", self.pp, self.targetBundle.pp, leaf.pp)
//			}
		}

		  //// reset to an BundleTap generates a resetTo pattern to target bundle
		 ///
		self.anonValue 			= 1.0				// first so resetTo = @"a" sets a=1
		if let resetTo {
			logEve(3, "|| resetTo '\(resetTo.pp(.tree)))'")							//[self logEvent:@"|| resetTo '%@'", [resetTo pp]];
			bug; let _ = loadHashEvent(event: FwwEvent(any:resetTo)!)
/*event*/
		}
	}

	func resetForAgain() {
		self.anonValue = 1.0;		// anonymous value restarts on "again"

		// 180123 added back in for Chevy 2
		// 171227 removed: "again" kept Previous from working
		loadPreClear()
	}
	// MARK:  -8. Reenactment Simulator

	 /// Load the next event to the target bundle:
	func loadTargetBundle(event:FwwEvent) {		//debugger("Not implemented")		}
		guard let targetBundle 			else { print("@@@@@@@@@ Burp fkwfj");return}

			  /// Floating Point --> Random Events
bug
		self.anonValue = 1.0;

		switch event {
		case .aProb(let prob): 				/// Event is a single number
			logEve(7, "|| Event '%@': RANDOMIZE targetBundle %@", event.pp(), targetBundle.fullName)
			 // Put in random data
			targetBundle.forAllLeafs {leaf in
				if let leafsGport = leaf.port4leafBinding(name:"G") as? Port {
					let value:Float	= prob < randomDist(0, 1) ? 0.0 : 1.0
					leafsGport.take(value:value) 		// let value	= randomProb(p:prob)
				}
			}
		case .anEpoch(let epoch):			/// Integer --> @0 Epoch Mark
			logEve(7, "|| Event '%@': Epoch Mark", epoch)
		case .anArray(let array):			/// Event is an Array
			logEve(7, "|| Event '%@' LOADS targetBundle %@...", event.pp(), self.targetBundle!.fullName)
			 // First element of an array sets the current anonymous value
			if array.count > 0,
			  case .aProb(let f) = array[0] {				// OR anEpoch(Int)
				self.anonValue	= f
				logEve(7, "|| Element 1 ='%@' sets %f => anonValue", array[0].pp(), f)
			}
			if self.incrementalEvents! == false {
				self.loadPreClear()
			}
			 /// Load:
			if let label 		= loadHashEvent(event: event) {
				targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
			}
			//[self.brain kickstartSimulator];	// start simulator
		case .aString(let eventStr):		/// Event is an String
			 // ("incrementalEvents" is a reserved word amongst signal names)
			if eventStr == "incrementalEvents" {
				logEve(7, "|| Event 'incrementalEvents' -- hold previous values")
				self.incrementalEvents = true;
				return;
			}
			logEve(7, "|| Event '%@' to targetBundle %@", event.pp(), targetBundle.fullName)
			if (!self.incrementalEvents!) {
				loadPreClear()
			}
			if let label 		= loadHashEvent(event:event) {
				targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
			}
		case .aNil_:			bug
		}
		// [self.brain kickstartSimulator];	// start simulator
		logEve(7, "|| Event '%@': targetBundle %@ UNCHANGED", event.pp(), self.targetBundle!.fullName)
	}

	func loadPreClear() {
		guard let targetBundle	else {	print(" Burp 3wff!"); return			}

	//	if (self.incrementalEvents) {
	//		[self logEvent:@"|| .incrementalEvents ABORTS loadPreClear of '%@'", self.targetBundle.name];
	//		return;
	//	}
		logEve(7, "|| loadPreClear: Clears all '%@'.G Ports:", self.targetBundle!.name)

		   /////// 2. CLEAR all Port value's inValue
		  ///
		targetBundle.forAllLeafs { leaf in										//[self.targetBundle forAllLeafs:^(Leaf *leaf) {					//##BLOCK
								//
			let genPort			= leaf.port4leafBinding(name:"G")
			if let p			= genPort as? Port {
				p.take(value:0.0)												// wild removal: genPort.valuePrev = 0.01;		// set different
			}
			//else if let n		= genPort as? Float {
			//	assert(n == 0, "@0 is ignore, others not permitted")
			//}
			else {
				panic("Leaf '\(genPort?.name ?? "<nunnaamed>d)' has no \"G\" binding")")
			}
		}															//##BLOCK
	}

	  /// Load an event into the target bundle.
	 /// The event may be a String, Number, or Array
	/// Returns a label for display
	func loadHashEvent(event:FwwEvent) -> String? {
		var rv_label = ""	// For any label that the event has for the bundle.
							//  e.g: the name of the letter for Morse Code
bug
		switch event {
		case .aString(let eventStr):	// Load one bit from String E.g: @"a"
			if let rvx 			= loadOneBitFromString(signal:eventStr) {
				rv_label		= rvx
			}
		case .anEpoch(let eventNum):	// @0 means no signals: @n is illegal
			assert(eventNum == 0, "\(eventNum) is illegal epoch")
			bug
		case .anArray(let eventArray):	// ARRAY: process multiple signals inside
			for fwwEvent in eventArray {	  // go through all signals in event:
				if let ev_label = loadHashEvent(event:fwwEvent) {				//if let ev_label = loadOneBitFromString(signal:fwwEvent) {
					rv_label	+= ev_label  // catenate all event labels
				}
			}
		default:
			panic("event '\(event.pp())' malformed")
		}
		return rv_label.count > 0 ? rv_label: nil
	}

	func loadOneBitFromString(signal:String) -> String? {
		var signal				= signal

		var labeled : String? = nil;
								//
		 //////// Parse signal string. <name> = <valueSpec>
		let comp 				= signal.components(separatedBy:"=")
		var value : Float		= 1.0
		if comp.count == 2 && comp[0].count != 0 { // it is legal for names to start wit an "="
			signal  			= comp[0]
			let eval 			= comp[1]
			if let v 			= Float(eval) {
				value 			= v					/// fixed value e.g. "foo=0.7"
			}
			else if eval.hasPrefix("rnd "),
			  let prob 			= Float(eval.dropFirst(3)) {
				value 			= Float.random(from:0.0, to:1.0) > prob ? 1 : 0
			}								///             e.g. "foo=rnd 0.3"
			labeled = eval			// signal has bundle lable, based on contents
		}
		else if comp.count==1,				///				e.g. "foo"
		  let anonValue,
		    anonValue.isNan == false {	/// set to anonValue; allows clearing
			value 				= anonValue
		}
		if let genPort			= targetBundle!.genPortOfLeafNamed(signal) {
			logEve(7, "|| /\\/\\ '%@'.valueTake = %.2f was%.2f", genPort.name, value, genPort.value)
			genPort.take(value:value)
		}

		  // hack: If we are part of a GenAtom, load the S Port also.
		 //        This allows initial values to be synced with .nib values
		if let ga 				= self.parent as? GenAtom {
bug//		ga.port(named:"S")?.take(value:value)
		}
		return labeled;
	}

	 // MARK: - 9.1 reVew
	override func reVew(vew:Vew?, parentVew:Vew?) {
		super.reVew(vew:vew, parentVew:parentVew)
	//	if inspectorNibName != nil && !self.inspectorAlreadyOpen {				// if (self.inspectorNibName and !self.inspectorAlreadyOpen)
//			[self.brain.simNsWc.autoOpenInspectors addObject:mustBe(View, v)];
	//	}
		inspectorAlreadyOpen	= true;		// only open once
	}

	 // MARK: - 9.2 reSize
	override func reSize(vew:Vew) {
		super.reSize(vew:vew)
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
bug
		let scn					= vew.scnRoot.find(name:"s-xxxx") ?? {
			let scn				= SCNNode()
//			vew.scnScene.addChild(node:scnScene, atIndex:0)
//			scnScene.name			= "s-Atom"
			return scn
		} ()
		return scn.bBox() * scn.transform
	}

	 // MARK: - 9.4 rePosition
	/// Reposition a Port's vew in parent, by name
	/// - Parameter vew: --- a Port's views
	override func rePosition(portVew vew:Vew) {	//override
	bug
		let port				= vew.part as! Port
		if port === ports["P"] {			// P: Primary
			assert(!port.flipped, "'M' in Atom must be unflipped")
			vew.scnRoot.position.y	= -port.height
//			vew.scnScene.position.y	= -port.height
		}
		else {
			if Log.shared.eventIs(ofArea:"rsi", detail:3) {
				warning("Did not find position for '\(port.pp(.fullNameUidClass))'")
			}
			vew.scn.transform		= .identity
//			vew.scnScene.transform	= .identity
		}
	}

	 //	 MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{		// Why is this not an override
		var rv					= super.pp(mode, aux)
		if mode == .line {
			if let resetTo {
				rv					+= "resetTo=\(resetTo.pp(.tree))"				//rv=[rv addF:@"resetTo=%@ ", [self.resetTo pp]];
			}
			if let inspectorNibName {
				rv					+= "nibName33=\(inspectorNibName.pp()) "
			}
			rv						+= "tBundle=\(self.targetBundle?.fullName ?? "<nil>") "
		}
		return rv
	}
}
