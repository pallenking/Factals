//  BundleTap.mm -- an Atom which generates data for a Bundle C2014PAK
// 171004 -- removed TimingChain and SimpleWorlds.
// 231101 -- transliterated from objc

import SceneKit

class BundleTap : Atom {

	 // Construction properties
	let  inspectorNibName		: String?	// "nib"
	let  resetTo 				: [String]?	// event at reset
	let  heightAlongRightSide	: Float?	// vert placement
	let  incrementalEvents 		: Bool?		// /*IBOutlet*/char incrementalEvents;// Next event inherets previous
	var  inspectorAlreadyOpen	: Bool?	 	// kind of a hack

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
	
//BundleTap *aBundleTap(id etc) {
//	BundleTap *newbie = anotherBasicPart([BundleTap class]);
//XX	newbie = [newbie build:etc];
//	return newbie;
//}
//BundleTap *aBundleTap(int limit, id etc) {
//	panic(@"Old style Generator -- DEPRICATED");
//	id info = @{@"eventLimit":[NSNumber numberWithInt:limit], etcEtc};
//
//	BundleTap *newbie = anotherBasicPart([BundleTap class]);
//XX	newbie = [newbie build:info];
//	return newbie;
//}


//! xzzy1 BundleTap::	1. resetTo				  :<event>	-- on reset
//!	xzzy1 BundleTap::	2. nib					  :<name of nib file>.nib
//!	xzzy1 BundleTap::	3. heightAlongRightSide :<float>
//!	xzzy1 BundleTap::	4. incrementalEvents	  :<bool>	-- values hold between events, must be explicitly cleared

//	init(config:FwConfig) {		}
	override init(_ config:FwConfig = [:]) {

		self.resetTo			= config["resetTo"] as? [String]
		self.inspectorNibName	= config.string("nib")
		self.heightAlongRightSide = config.float("heightAlongRightSide")
		self.incrementalEvents	= config.bool("incrementalEvents")

		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

			//assert(!self.parameters[@"events"], (@"BundleTap does not support events any more"));
	//	assert(self.parameters[@"asyncData"], (@"BundleTap does not support setting syncData"));??
	}

	// MARK: - 7. Simulation Actions
	override func reset() {											super.reset()

			 //   MOVE TO groomModelPostWires(root:RootPart) {
			/// Connect up our targetBundle:
		   ///
		 // my P-Port connects where?
		guard let pPort				= ports["P"],
		  let targPort 				= pPort.portPastLinks,
		  let targetBundle			= targPort.parent as? FwBundle
		else 						{	fatalError("targetBundle is nil") 		}
		
		 // Test new target bundle; must have both R (for reset) and G (for generate)
		targetBundle.forAllLeafs { leaf in
			guard let _				= leaf.port4leafBinding(name: "R"),
			 let _ 					= leaf.port4leafBinding(name: "G") else {
				fatalError("Leaf \(self.pp(.fullName)) type '\(leaf.type)' has no R or G port, needed by\n")
				// "%@: %@: %@\nConsider using Leaf with a BundleTap", self.pp, self.targetBundle.pp, leaf.pp)
			}
		}

		  //// reset to an BundleTap generates a resetTo pattern to target bundle
		 ///
		self.anonValue 				= 1.0				// first so resetTo = @"a" sets a=1
		if let resetTo {
			logd("|| resetTo '\(resetTo.pp(.tree)))'")							//[self logEvent:@"|| resetTo '%@'", [resetTo pp]];
bug//		loadHashEvent(resetTo)
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
//	func loadTargetBundle(event {
//bug
//		self.anonValue = 1.0;
//
//		  /// Event is a single number
//		 ///
//		if (NSNumber *e = coerceTo(NSNumber, event)) {
//
//			  /// Floating Point --> Random Events
//			 ///
//			if ([e respondsToSelector:@selector(floatValue)]) {
//				float prob = [e floatValue];
//				[self logEvent:@"|| Event '%@': RANDOMIZE targetBundle %@",
//											[event pp], self.targetBundle.fullName];
//				 // Put in random data
//				[self.targetBundle forAllLeafs:^(Leaf *leaf) {			//##BLOCK
//					Port *genPort			= mustBe(Port, [leaf port4leafBinding:@"G"]);
//					float value				= randomProb(prob);
//					genPort.valueTake		= value;
//				} ];
//			}
//
//			  /// Integer --> @0 Epoch Mark
//			 ///
//			else if (e.objCType[0]=='i' and e.intValue==0) // 'i' is integer
//				[self logEvent:@"|| Event '%@': Epoch Mark", [event pp]];
//
//			else
//				panic(@"|| Event '%@' ILLEGAL", [event pp]);
//		}
//		
//		  /// Event is an Array
//		 ///
//		else if (NSArray *eventArray = coerceTo(NSArray, event)) {
//			[self logEvent:@"|| Event '%@' LOADS targetBundle %@...",
//										[event pp], self.targetBundle.fullName];
//
//			  /// First element of an array sets the current anonymous value
//			 ///
//			if (id ea0 = eventArray.firstObject) {
//				if (coerceTo(NSNumber, ea0)) {
//					if ([ea0 respondsToSelector:@selector(floatValue)]) {
//						self.anonValue = [ea0 floatValue];
//						[self logEvent:@"|| Element 1 ='%@'; %f => anonValue", ea0, self.anonValue];
//					}
//				}
//			}
//			 /// Clear:
//			if (!self.incrementalEvents)
//	XX			[self loadPreClear];
//			 /// Load:
//	XX		if (id label = [self loadHashEvent:event])
//				self.targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
//
//			[self.brain kickstartSimulator];	// start simulator
//		}
//
//		  /// Event is an String
//		 ///
//		else if (NSString *eventStr = coerceTo(NSString, event)) {
//
//			/// ("incrementalEvents" is a reserved word amongst signal names)
//			if ([eventStr isEqualToString:@"incrementalEvents"]) {
//				[self logEvent:@"|| Event 'incrementalEvents' -- hold previous values"];
//				self.incrementalEvents = true;
//				return;
//			}
//
//			[self logEvent:@"|| Event '%@' to targetBundle %@",
//										[event pp], self.targetBundle.fullName];
//			if (!self.incrementalEvents)
//	XX			[self loadPreClear];
//
//	XX		if (id label = [self loadHashEvent:event])
//				self.targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
//
//			[self.brain kickstartSimulator];	// start simulator
//		}
//
//		  /// Event is an NSInteger, etc. -- no effect on
//		 ///
//		else
//			[self logEvent:@"|| Event '%@': targetBundle %@ UNCHANGED",
//										[event pp], self.targetBundle.fullName];
//		return;
//	}

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
	func loadHashEvent(event:FwAny) {
//	- (id) loadHashEvent:(id)event; {
		let rv_label = ""	// For any label that the event has for the bundle.
							//  e.g: the name of the letter for Morse Code
bug
//		   ////////////  EVENT STRING: A lone string acts as an array of 1 element
//		  ///
//		 // E.g: @"a"
//	//	id foo = [event asString];
//		if (NSString *eventStr = [event asString])
//	XX		rv_label = [self loadOneBitFromString:event];
//
//		   ////////////  EVENT NUMBER: @0 means no signals: @n is illegal
//		  ///
//		 // E.g: @0
//		else if (NSNumber *eventNum = [event asNumber])
//			assert(eventNum.intValue==0, (@"@%d is illegal epoch", eventNum.intValue));
//			
//		   ////////////  EVENT ARRAY: process multiple signals inside
//		  ///
//		 // E.g: @[ ... ]
//		else if (NSArray *eventArray = mustBe(NSArray, event)) {
//			for (NSString *signal in eventArray)	  // go through all signals in event:
//	XX			if (id ev_label=[self loadOneBitFromString:signal])
//					rv_label=[rv_label addF:@"%@", ev_label];  // catenate all event labels
//		}
//		else
//			panic(@"event '%s' malformed", [event ppC]);
//
//		return [rv_label length]? rv_label: nil;
	}

	func loadOneBitFromString(signal:FwAny) {
bug
//		if (coerceTo(NSNumber, signal))			// ignore defaultValues, ...
//			return nil;
//
//		if ([mustBe(NSString, signal) componentsSeparatedByString:@"/"].count > 1)
//			panic(@"Signal '%s' must not contain components (e.g. using '/')", [signal UTF8String]);
//		id labeled = nil;
//
//		 //////// Parse signal string. <name> = <valueSpec>
//		NSArray *comp = [signal componentsSeparatedByString:@"="];
//		float value = 1.0;
//		if (comp.count==2 and [comp[0] length]!=0) { // it is legal for names to start wit an "="
//			signal  = comp[0];
//			id eval = comp[1];
//			if (float v = [eval floatValue])
//				value = v;					/// fixed value e.g. "foo=0.7"
//			else if ([eval hasPrefix:@"rnd "]) {
//				float prob = [[eval substringFromIndex:4] floatValue];
//				value = randomProb(prob);	/// 1 with probability prob
//			}								///             e.g. "foo=rnd 0.3"
//			else if ([eval hasPrefix:@"rVal "]) {
//				float rVal = [[eval substringFromIndex:5] floatValue];
//				value = randomDist(0, rVal);/// Boxcar      e.g. "foo=rVal 4"
//			}
//			labeled = eval;			// signal has bundle lable, based on contents
//		}
//		else if (comp.count==1)				///				e.g. "foo"
//			if (!isNan(self.anonValue))	/// set to anonValue; allows clearing
//				value = self.anonValue;
//
//	XX	Port *genPort			= [self.targetBundle genPortOfLeafNamed:signal];
//
//		[genPort logEvent:@"|| /\\/\\ '%@'.valueTake = %.2f was%.2f", genPort.name, value, genPort.valueGet];
//		genPort.valueTake		= value;
//
//		  // hack: If we are part of a GenAtom, load the S Port also.
//		 //        This allows initial values to be synced with .nib values
//		if (GenAtom *ga = coerceTo(GenAtom, self.parent))
//			ga.sPort.valueTake	= value;
//			
//		return labeled;
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

//	- (void) drawFullView:(View *)v context:(RenderingContext *)rc; {
//
//		float r = self.brain.bitRadius;
//		Vector3f ctr = v.bounds.center();			// origin2center of BundleTap
//		Vector3f siz = v.bounds.size();
//
//		if (self.inspectorNibName) {
//			glPushMatrix();
//				glTranslatefv(ctr);				// Billboard
//				glScalef(siz.x, siz.y, 0.1);
//				FColor outside =  {0.55,0.0, 0.0,  1};
//				rc.color = outside;//colorRed3;	//colorWhite
//				glutSolidCube(self.brain.bitRadius);
//			glPopMatrix();
//		}
//		else {
//			glPushMatrix();
//				siz -= Vector3f(0.1, 0, 0.1);				// main body is inset
//				ctr.y += r/2;
//				glTranslatefv(ctr + Vector3f(0, -0.5,0));
//				rc.color = colorYellow;
//				glScalef(siz.x*0.8, 1, siz.z-r);
//				glutSolidCube(r);						// CUBE
//				rc.color = colorBlue;
//				glTranslatef(0, 0.5*r, 0);
//				glScalef(1.1, 0.5, 1.1);
//				glutSolidCube(r);
//			glPopMatrix();
//		}
//		[super drawFullView/*Ports*/:v context:rc];	// paint Ports and bounding box
//	}


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
