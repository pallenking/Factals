//  BundleTap.mm -- an Atom which generates data for a Bundle C2014PAK

// 171004 -- removed TimingChain and SimpleWorlds.
// 231101 -- transliterated from objc

import SceneKit

/*!
	Loads discret time discrete value data into analog HaveNWant Bundle
	Resets Bundle at start of run
	Data may come from GUI
	Data may come from worldModel.
		a) Incremental change model, including "again"
		b) anonValue ("a" -> "a=<ananVlue>")
		c) random data for initial testing
		d) per-run random data
		e) Epoch Marks
*/

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
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}
	
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
		assert(config["asyncData"]==nil, "BundleTap does not support setting syncData")
	}

	// MARK: - 7. Simulation Actions
	override func reset() {											super.reset()

			 //   MOVE TO groomModelPostWires(root:RootPart) {
			/// Connect up our targetBundle:
		   ///
		 // my P-Port connects where?
		guard let pPort			= ports["P"],
		  let targPort 			= pPort.portPastLinks,
		  let targetBundle		= targPort.parent as? FwBundle
		else 						{	fatalError("targetBundle is nil") 		}
								//
		 // Test new target bundle; must have both R (for reset) and G (for generate)
		targetBundle.forAllLeafs { leaf in
			guard let _			= leaf.port4leafBinding(name: "R"),
			 let _ 				= leaf.port4leafBinding(name: "G") else {
				fatalError("Leaf \(self.pp(.fullName)) type '\(leaf.type)' has no R or G port, needed by\n")
				// "%@: %@: %@\nConsider using Leaf with a BundleTap", self.pp, self.targetBundle.pp, leaf.pp)
			}
		}

		  //// reset to an BundleTap generates a resetTo pattern to target bundle
		 ///
		self.anonValue 			= 1.0				// first so resetTo = @"a" sets a=1
		if let resetTo {
			logd("|| resetTo '\(resetTo.pp(.tree)))'")							//[self logEvent:@"|| resetTo '%@'", [resetTo pp]];
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
	func loadTargetBundle(event:FwwEvent) {		//fatalError("Not implemented")		}
		guard let targetBundle 			else { print("@@@@@@@@@ Burp fkwfj");return}

			  /// Floating Point --> Random Events
bug
		self.anonValue = 1.0;

		switch event {
		case .aProb(let prob): 				/// Event is a single number
			logd("|| Event '%@': RANDOMIZE targetBundle %@",
										event.pp(), targetBundle.fullName)
			 // Put in random data
			targetBundle.forAllLeafs { leaf in
				if let leafsGport = leaf.port4leafBinding(name:"G") {
					let value	= randomProb(p:prob)
bug					//leafsGport.valueTake = value
				}
			}
		case .anEpoch(let epoch):			/// Integer --> @0 Epoch Mark
			logd("|| Event '%@': Epoch Mark", epoch)
		case .anArray(let array):			/// Event is an Array
			logd("|| Event '%@' LOADS targetBundle %@...",
								event.pp(), self.targetBundle!.fullName)
			 // First element of an array sets the current anonymous value
			if array.count > 0,
			  case .aProb(let f) = array[0] {				// OR anEpoch(Int)
				self.anonValue	= f
				logd("|| Element 1 ='%@' sets %f => anonValue", array[0].pp(), f)
			}
								//
			// ofphan
			 /// Clear:
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
				logd("|| Event 'incrementalEvents' -- hold previous values")
				self.incrementalEvents = true;
				return;
			}
			logd("|| Event '%@' to targetBundle %@", event.pp(), targetBundle.fullName)
			if (!self.incrementalEvents!) {
				loadPreClear()
			}
			if let label 		= loadHashEvent(event:event) {
				targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
			}
		case .aNil_:			bug
		}
		// [self.brain kickstartSimulator];	// start simulator
		logd("|| Event '%@': targetBundle %@ UNCHANGED", event.pp(), self.targetBundle!.fullName)
	}

	func loadPreClear() {
		guard let targetBundle	else {	print(" Burp 3wff!"); return			}

	//	if (self.incrementalEvents) {
	//		[self logEvent:@"|| .incrementalEvents ABORTS loadPreClear of '%@'", self.targetBundle.name];
	//		return;
	//	}
		logd("|| loadPreClear: Clears all '%@'.G Ports:", self.targetBundle!.name)

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
			genPort.logd("|| /\\/\\ '%@'.valueTake = %.2f was%.2f", genPort.name, value, genPort.value)
			genPort.take(value:value)
		}

		  // hack: If we are part of a GenAtom, load the S Port also.
		 //        This allows initial values to be synced with .nib values
		if let ga 				= self.parent as? GenAtom {
			ga.port(named:"S")?.take(value:value)
		}
		return labeled;
	}

	// MARK: -9. 3D Support
//	- (Bounds3f) gapAround:(View *)v;	{
//		float r = self.brain.bitRadius, f = 3.0;
//		return Bounds3f(-f*r, 0, -f*r,	 f*r, 3*r, f*r); // 160824
//	}

	 // MARK: - 9.1 reVew
	override func reVew(vew:Vew?, parentVew:Vew?) {
		super.reVew(vew:vew, parentVew:parentVew)
bug
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
		let scn					= vew.scn.find(name:"s-xxxx") ?? {
			let scn				= SCNNode()
//			vew.scn.addChild(node:scn, atIndex:0)
//			scn.name			= "s-Atom"
			return scn
		} ()
		return scn.bBox() * scn.transform
	}

//	- (void) drawFullView:(View *)v context:(RenderingContext *)rc; {
//
//		float r = self.brain.bitRadius;
//		Vector3f ctr = v.bounds.center();			// origin2center of BundleTap
//		Vector3f siz = v.bounds.size();
//
//		if (self.inspectorNibName) {
//			glutSolidCube(self.brain.bitRadius);		// Billboard
//		} //		else {
//				glutSolidCube(r);
//			glPopMatrix();
//		}
//		[super drawFullView/*Ports*/:v context:rc];	// paint Ports and bounding box
//	}


	 // MARK: - 9.4 rePosition
	/// Reposition a Port's vew in parent, by name
	/// - Parameter vew: --- a Port's views
	override func rePosition(portVew vew:Vew) {
	bug
//		let port				= vew.part as! Port
//		if port === ports["P"] {			// P: Primary
//			assert(!port.flipped, "'M' in Atom must be unflipped")
//			vew.scn.position.y	= -port.height
//		}
//		else {
//			atRsi(3, warning("Did not find position for '\(port.pp(.fullNameUidClass))'"))
//			vew.scn.transform	= .identity
//		}
	}

	 //	 MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{		// Why is this not an override
		var rv					= super.pp(mode, aux)
		if let resetTo {
			rv					+= "resetTo=\(resetTo.pp(.tree))"				//rv=[rv addF:@"resetTo=%@ ", [self.resetTo pp]];
		}
		if let inspectorNibName {
			rv					+= "nibName33=\(inspectorNibName.pp()) "
		}
		rv						+= "tBundle=\(self.targetBundle?.fullName ?? " Burp sv3wrs?") "
		return rv
	}
}
