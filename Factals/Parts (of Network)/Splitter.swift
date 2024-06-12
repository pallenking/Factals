// Splitter.mm -- Abstract class that splits one Port into many C2011PAK C2018PAK

/* to do:
 */

/* CANONIC FORM (for all Share types):

		   U1 	   	   U2 	       U3 			   Broadcast   Unknown
		.--o--.		.--o--.		.--o--.			.--o--.		.--o--.
	+---|L|   |-----|L|   |-----|L|   |---------|L|   |-----|L|   |-----+
	|    ^	  v      ^	  v      ^	  v    		 ^	  v    	 ^	  v		|
	|											 |	 nil	 |	 nil	|
	|											 |	 		 |	 		|
	|	^^^  vvv								 |			 |			|
	|	 | 	COMBINE								 |			 |			|
	| SWITCH  |a1					  a1 = B ----'			 |			|
	|    |	  |-----------		 uP - a1 = U ----------------'			|
	|vGet|	  |takeValue												|
	+----|   |L|--------------------------------|   |L|-----------------+
		 '--o--'								 --o--
			P (Primary)							  KIND							*/

import SceneKit

  /// Atom with generic "split" Ports
  /// * .	    Maintains 1-port of information about the world.
  /// * .	        Unf_lipped, it distributes a single lower input to many upper outputs.
  /// * .	        f_lipped, it combines many lower inputs to produce a single upper output.
  /// * .		A Factal's numerical algorithms are chosen at birth
  /// * .			and can vary during simulation under control of the "KIND" port.
  /// * .	    ? Atom Atom 0 is not used. Rather, Share's send numerics up through the multi-cast. ?
class Splitter : Atom {

	 // MARK: - 2. Object Variables:
	 // Configuration						// kind is from Port, chooses 0 or 1:
	var onlyPosativeWinners = false			// inputs <0 cannot win

	 // Operational Kind
	var isBroadcast : Bool {
		return fwClassName == "Broadcast"	// for auto-Broadcast operation
	}
	// Operational State
	var combineWinner: Int 	= 0				// Winning Share number
												// >S	Winning Share
												//  0	no winner yet declared
												// -1	proportional sharing
	@Published var upIsDirty : Bool! = true	// must recompute upward, no matter what
		//weak  
		 // https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-binding-property-wrapper

	//@Published var isABcast	:  String!		//[shareClassName isEqualToString:@"Broadcast"];
	@Published var a1 		: Float = 0.0
	{	didSet {	if a1 != oldValue {
						markTree(dirty:.paint)
																		}	}	}
 //https://stackoverflow.com/questions/24561490/swift-protocol-iboutlet-property-cannot-have-non-object-type

	var uPort   : Port?	{ 	return ports["U"]		} //false
	var bPort   : Port?	{ 	return ports["B"]		} //down:false
	var kindPort: Port? { 	return ports["KIND"]	} //down:true

		// MARK: - 3. Part Factory
	 /// Splitters funnel many links to a common one
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		 // a pragmatic default
		onlyPosativeWinners	= fwClassName == "MaxOr" || fwClassName == "MinAnd"
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()		// probably returns "P"
		rv["S"]					= nil	// no "S" port explicitly
		 // The following line was commented out 200820PAK, then reinserted 200915 to solve Bulb "share"
		// recommented 200917!
		//rv[""]				= "af"	// shared secondary	(noting initilly, shares added as required)
		rv["share"]				= "af"	// shared SECondary	(noting initilly, shares added as required)
		rv["U"]					= "af"	// Unknown					auto-populate
		rv["B"]					= "af"	// Broadcast (of P)			auto-populate
		rv["KIND"]				= "a"	// Chooses shareProto[0,1]
		return rv				//[:]//
	}
	 // MARK: - 3.5 Codable
	enum SplitterKeys: String, CodingKey {
		case onlyPosativeWinners
		case combineWinner
		case upIsDirty
		case a1
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:SplitterKeys.self)

		try container.encode(onlyPosativeWinners, forKey:.onlyPosativeWinners)
		try container.encode(combineWinner,		  forKey:.combineWinner)
		try container.encode(upIsDirty,			  forKey:.upIsDirty)
		try container.encode(a1, 				  forKey:.a1)
		atSer(3, logd("Encoded  as? Splitter    '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:SplitterKeys.self)

		onlyPosativeWinners 	= try container.decode(  Bool.self,	forKey:.onlyPosativeWinners)
		combineWinner			= try container.decode(   Int.self,	forKey:.combineWinner)
		upIsDirty				= try container.decode(  Bool.self,	forKey:.upIsDirty)
		a1 						= try container.decode( Float.self,	forKey:.a1)
		atSer(3, logd("Decoded  as? Splitter   named  '\(name)'"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Splitter
//		theCopy.onlyPosativeWinners = self.onlyPosativeWinners
//		theCopy.combineWinner 	= self.combineWinner
//		theCopy.upIsDirty 		= self.upIsDirty
//		theCopy.a1 				= self.a1
//		atSer(3, logd("copy(with as? LinkPort       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 						   else {	return true			}
		guard let rhs			= rhs as? Splitter else {	return false 		}
		let rv					= super.equalsFW(rhs)
								&& onlyPosativeWinners 	== rhs.onlyPosativeWinners
								&& combineWinner 		== rhs.combineWinner
								&& upIsDirty 			== rhs.upIsDirty
								&& a1 					== rhs.a1
		return rv
	}
	// MARK: - 4.4 Tree Navigation
	override func autoBroadcast(toPort:Port) -> Port {
		if //isBroadcast, 						// now for any type Splitter
		  toPort.flipped { 						// active end of a Splitter?
			return anotherShare(named:"*")		// + + make a new Share + +
		}
		return super.autoBroadcast(toPort:toPort) 
	}
	  /// Create a share for a Splitter
	 /// - Parameter name: -- of new share; "*"->s23, nil->anonymous
	/// - Returns: Share of type <shareTypeStr>
	func anotherShare(named name:String?=nil) -> Share {
		let newName : String	= name != nil && name! != "*" ? name! 	// name given
								: fmt("s%ld", ports.count)				// * -> unique name

		let newType : Share.Type = classFrom(string:fwClassName + "Sh")
								   //*********//
		let share				= newType.init(["named":newName, "f":1])	// INIT
								   //*********//

		 // If explicitly named, insert new share in ports:
		if name != nil {
			assert(ports[newName]==nil, "\(pp(.fullName)) already has a Share named '\(newName)'")
			ports[newName]	 	= share			// add to ports
			addChild(share)						// add to children
			upIsDirty 			= true			// new Shares need downward,
		}										 // then upward pass
		return share
	}
	override func biggestBit(openingUp upInSelf:Bool?) -> Port? {
		if flipped {
			return super.biggestBit(openingUp:flipped)	// follow P
		}
		 // Up in self canonic form
		if let rv 				= children[combineWinner] as? Port {
			return rv
		}
 //		let cw					= combineWinner,
 //		if cw >= 0 && cw < children.count {
 //			return children[cw] as? Port
 //		}
		var rv : Port?			= nil
		for port_ in children {
			if let port 		= port_ as? Port {
				if port.flipped == upInSelf {
					if port.name == "U" {										}
					else if rv==nil	{			// first
						rv 		= port										}
					else {
						atBld(4, logd("????? [%@ getBit_...]: ignoring %@, alrady found %",
							name, port.name, rv?.name ?? "-"))
					}
				}
			}
		}
		return rv
	}
	  // MARK: - 4.7 Editing Network
	override func port(named wantName:String, localUp wantUp:Bool?, wantOpen:Bool, allowDuplicates:Bool) -> Port? {

		 // Another Share of a Splitter, but no Share is open					//		if wantOpen, wantUp!{
		if (wantName=="share" || wantName==""),	// Want a new share
			wantOpen,							// It should be an open share
		   (wantUp == nil || wantUp!) 			// opens correctly
		{
			return anotherShare(named:"*")
		}
		return super.port(named:wantName, localUp:wantUp, wantOpen:wantOpen, allowDuplicates:allowDuplicates)
	}

	 // MARK: - 8. Reenactment Simulator
	override func reset() {								super.reset()
	
		// CHANGED 170419
		self.combineWinner		= -1		// proportional sharing
		//self.combineWinner	= 0			// no winner
	
		self.upIsDirty			= true		// recalculate all going UP, even if P in is unchanged
	
		//	 // 170311 Insure consistency of newly added parts
		//[self distributeTotal:self.pPortIn.getValues()]
	}
	 // Use the attached Shares to process data:
	override func simulate(up upLocal:Bool) {
		 // Sequence is special: just cycle its part Ports	 	// ///////////// //
		let pPort				= self.ports["P"]	 ?? .error // // DOWN  //// //
		//let kindPort			= self.ports["KIND"] ?? .error// ///////////// //
		  // *//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*/
		if (!upLocal) {

			super.simulate(up:upLocal)	// step super FIRST
			   //												 ///////////////
			  // GATHER/COMBINE from all the SHARES				/// COMBINE ///
			 //												   ///////////////
			// The value a1 in splitter scans through intermediary values: (161023)
			//!						a1
			//!	 Broadcast		Sum(inI)
			//!	 MaxOr:			Max(inI, 0.01)
			//!	 MinAnd:		Min(inI)
			//!	 Bayes			Sum(inI)
			//!	 Hamming:		Sum(inI-cut)+cut		cut is a global constant
			//!	 Multiply:		Prod(inI)
			//!	 KNorm			(Sum(inI^^k))^^(1/k)	k is a global constant
			//!	 Sequence:		  - n.a. -
			 
			combinePre()				// ==== Initialize

			 // ==== Scan Shares
			self.combineWinner 	= -1	// no winner yet
			for (i, sc) in children.enumerated() {
				 // Go through all Shares:
				if let sh 		= sc as? Share {	// ignore Primary and Unknown Ports
					 // Gather properties of input value
					if let shInPort = sh.con2?.port {	// ignore unconnected Ports
						let shareInputChanged = shInPort.valueChanged()
						upIsDirty	||= shareInputChanged	// changed --> dirty

						let val	= shInPort.getValue()		// (clears .valueChanged)

						// Combine into Primary Port												/*** NEXT: ***/
						if combineNext(val:val) {
							self.combineWinner = i		// current is winner -- record it
						}

						if shareInputChanged {
							atDat(4, sh.logd("   COMB:val=%.2f:a1=%.2f cWin=%d", val,	a1, combineWinner))
						}
					}
				}
			}														// POST:
			 // ==== Post Process
			combinePost()
			//!<< combinePost >>: OPERATION
			//! DEFAULT:		<nothing>
			//!	 Hamming:	a1	+= cut
			//!	 KNorm		a1	= a1**(1/cp)

			 // 160427: New mode: for MaxOr, no signal means no winner
			if onlyPosativeWinners && (combineWinner < 0) {	// and there is no declared winner
				self.combineWinner = 0		// declare part 0 (P) the winner
				self.a1 		= 0.0
			}

			 // Although Combine goes DOWN, it recalculates two UPward values: B and U
			let nextValueDifferent = pPort.value != self.a1
			upIsDirty 			||= nextValueDifferent
			if nextValueDifferent  {		// Put to Output
				pPort.take(value:self.a1)

				if let b 		= bPort {
					atDat(4, b.logd("   broadcast =%.2f", pPort.value))
					atDat(4, b.take(value:pPort.value))
				}
				if let u 		= uPort {
					var unknownValue = pPort.con2!.port!.value - a1	// unexplained residue
					unknownValue = unknownValue < 0 ? 0 : unknownValue	// (never negative)
	
					atDat(4, u.logd("   unknown =%.2f-%.2f", pPort.value, a1))
					u.take(value:unknownValue)
				}
			}
			 // Clear out runt changes (just read)
			let _			 	= bPort?.con2?.port?.getValue()
			let _			 	= uPort?.con2?.port?.getValue()

			if let kindPort2Port = ports["KIND"]?.con2?.port,
			  kindPort2Port.valueChanged() {			// KIND port changes mode
bug;			let (valNext, valPrev) = kindPort2Port.getValues() // ( get new value remove )
	//			atDat(4, log(" Branch: kind=%.2f (was %.2f)", valNext, valPrev))
				let shareIndex	=  valNext > 0.5
	//			shareProto 		= shareIndex ? self.shareProto1 : self.shareProto0
	//			assert(shareProto != nil, "")
			}
		}													  // ////////////// //
															 // ////  UP  //// //
		 //*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//
														   // ////////////// //
		if (upLocal) {									  // / DISTRIBUTE / //
			if let pPortIn 		= pPort.con2?.port,// ////////////// //
			   pPortIn.valueChanged() || upIsDirty 	// P Port or internal upIsDirty
			{	 // Push a portion of the value down to each Share
				let total		= pPortIn.getValue()

 				setDistributions(total:total)		// DOES ALL THE WORK

				 // Process UNKNOWNs (more sense than known)
				if let u 		= uPort {
					let accountedFor = pPort.value

					var unknownValue = total - accountedFor
					unknownValue = unknownValue < 0 ? 0 : unknownValue
	
					atDat(4, u.logd("   DIST U=%.2f (%.3f-%.3f)", unknownValue, total, accountedFor))
					u.value/*Take*/ = unknownValue	// silently
					u.markTree(dirty:.paint)
				}

				 // Process BROADCASTs (same to all)
				if let b		= bPort {
					atDat(4, b.logd("   DIST B=%.2f", total))
					b.value/*Take*/	= total			// silently
				}
			}
			super.simulate(up:upLocal)			// step super AFTER, to skip a step
		}
	}

	   //#######################################################################
	  //####################### DEFAULT SHARE NUMERICS #########################
	 //-- combine: (local DOWN)-- Default: //
	func combinePre() {
		a1 						= 0.0			// Default: set to 0 before scan
	}
	func combineNext(val:Float) -> Bool {	//class
		a1			   			+= val			// Default: a1 is a SUM
		return false							// Never declare a winner
	}
	func combinePost() {	/* Default: do nothing afterward */	//class
		if a1.isNaN || a1.isInfinite {
			a1				= 0.0			// Default: remove nan's and inf's
		}
	}
	 //-- distribute: (local UP)--//
	func bidTotal() -> Float {					// Splitter
		var rv : Float		= 0.0
		for child in children {
			if let sh 		= child as? Share {
				rv	   		+= sh.bid()
			}
		}
		return rv								// Default: denominator
	}


	 // Presuming Canonic Form (Tree of green leafs)
	func setDistributions(total:Float) {			    // /// DISTRIBUTE  /// //
		upIsDirty 				= false		// handshake: clear: soon will be not dirty
		if combineWinner >= 0 {   // Winner (new):	  // //////////////////// //
			var i				= -1				 // / WINNER TAKE ALL  / //
			for sc in children {		   			// //////////////////// //
				i				+= 1
				if i == 0 && combineWinner == 0 {
					atDat(3, logd("No winner: all Shares get 0.0"))
				}
				if let sh	 	= sc as? Share {
					var distribution = Float(0.0)	// loosers get nothing
					var msg 	= "LOOSER"
					if (i == self.combineWinner) {
						assert(i != 0, "0 is primary, not a share")
						distribution = total			// winner takes all
						msg 	= "WINNER"
					}
					atDat(4, sh.logd("  %@ val=%.2f", msg, distribution))
					sh.take(value:distribution)
				}
			}
		}												      // //////////////// //
		else if combineWinner < 0 {		   // No Winner: 	 // / PROPORTIONAL / //
			let bidTotal_ 		= bidTotal()				// //////////////// //
			//!<< bidSum >>: OPERATION
			//! DEFAULT:		Sum(inI)
			//!	 Broadcast:		1.0
			//!	 Hamming:		1.0
	
			for child in children {
				if let sh 		= child as? Share {
					let bidOfShare:Float = sh.bid()
	
//					assert(!(bidOfShare != 0.0 && bidTotal == 0), "bidOfShare isn't zero, but bidSum is Zero")
					let distribution = bidOfShare == 0.0 ? 0.0 : // (irrespective of bidTotal)
														 total * bidOfShare / bidTotal_
					let wasStr 	= sh.value==distribution ? "(unchanged)":
													  fmt("(was %.2f)", sh.value)
					atDat(4, sh.logd("   DIST: %.2f =%.2f*(%.2f/%.2f)  %",
						distribution, total, bidOfShare, bidTotal_, wasStr))
	
					if sh.value != distribution {
						sh.value/*Take*/= distribution	// silently
					}
//					  // 170725: In an attempt to have the key stop
//					 // between birth and setteling, we try this hack.
//					sh.valuePrev = distribution	// vewy siwently
				}
			}
		}
	}
	//\\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\    //
	// \\ \\ \\ \\ \\ \\ \\ \\ \ 3D Support\\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\  //
	//  \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\ \\//
	 // MARK: - 9.2 reSize
	override func reSize(vew:Vew) {
		super.reSize(vew:vew) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Split") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1.6))
			scn.color0			= .orange
			scn.name			= "s-Split"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.position.y			= 0.6
		scn.scale				= SCNVector3(1, 0.4, 1)
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let splitterBb : BBox	= vew.bBox
		let port 				= vew.part as! Port
		 // An Splitter's Shares are positioned at top, for the moment
		if let share 			= port as? Share {	// All Shares go to the origin for now
			assert(share.flipped, "Share in Splitter must be flipped")
			 // Place Shares at the origin 200731
			vew.scn.transform	= SCNMatrix4(.zero, flip:flipped) //.identity // vew.scn.transform	= SCNMatrix4(0, x.center.y, 0, flip:flipped) //.identity
		}					/// on top, center
		else if port === ports["U"] {				// U: Unknown Port
			assert(!port.flipped, "'U' in Splitter must be unflipped")
			vew.scn.transform	= SCNMatrix4(splitterBb.centerTop + SCNVector3(0, 0, -2),
									latitude:.pi/4, spin:0)//(port.spin+3)%4)
		}
		else if port === ports["B"] {				// B: Broadcast Port
			assert(!port.flipped, "'B' in Splitter must be unflipped")
			vew.scn.transform	= SCNMatrix4(splitterBb.centerTop + SCNVector3(2, 0, -2))
		}
		else if port === ports["M"] {				// M: mPort
			assert(!port.flipped,  "'M' in Splitter must be unflipped")
			vew.scn.transform	= SCNMatrix4(splitterBb.centerBottom + SCNVector3(2, 0, 0))	//2 * SCNVector3.uX)
			//port.latitude 	= 4
		}
		else if port === ports["KIND"] {				// KIND: kindPort
			panic()
			vew.scn.transform	= .identity
		}
		else {
			super.rePosition(portVew:vew)
		}
	}
	 // MARK: - 11. 3D Display
	override func typColor(ratio:Float) -> NSColor {
		if let proxyColor {
			return proxyColor//(self.proxyColor)
		}
		return .orange
	}

	 // MARK: - 15. PrettyPrint
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//
	   //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//
	  //\\//\\//\\//\\//\\// PRINTOUT //\\//\\//\\//\\//\\//
	 //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//
	//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 				= super.pp(mode, aux)
		if !aux.bool_("ppParam"),		// Ad Hoc: printing params is so voluminus, print nothing else!ppp
		  mode == .line { 
			rv				+= fwClassName
			rv				+= fmt(" a1=%.2f ", a1)
			if (self.combineWinner >= 0) {
				rv			+= fmt("cWin=%d ", combineWinner)				
			}
			rv				+= fwClassName + " "
			if isBroadcast {
				rv			+= "isBroadcast "									
			}
			rv				+=	"WTA \(onlyPosativeWinners.pp()) "
//			if let w 		= onlyPosativeWinners {
//				rv			+=	"WTA \(w.pp()) "
//			}
			if upIsDirty {
				rv			+= "reComp "									
			}
		}
		return rv
	}
	  /// Print a splitter's contents in 1 line.
	 ///   Gather pass loads allNames Output pass prints with allNames columnar
	func ppContentsGather(gather:Bool, names allNames:inout Array<String>) -> String {
		var rv 					= fmt("%@ %@: ", name.field(6), fwClassName.field(6))
		let rv0 				= rv.count
		for element in children 
				where element is Port && 
					  element !== ports["P"] {
			let port 			= element as! Port
			let p				= port.portPastLinks!
			 // rather ad hoc:
			let tokens 			= p.fullName.split(separator:"/")
			let printName		= String(tokens.last!)
//			let printName		= String(tokens[tokens.count-1])	// default
//			if let leaf			= p.enclosedByClass(fwClassName:"Leaf") as? Leaf {
//				let prev		= printName.contains(substring:"+.") ? "+" :
//								  printName.contains(substring:"-.") ? "-" : ""
//				printName		= leaf.name + prev
//			}
			if gather, !allNames.contains(printName) {			// first pass
				allNames.append(printName) 			// remember names
			}
			else {							// second pass --- output
				let printNameNSeparator = printName + ", "
				var posn 		= rv0				// find printName in allNames
				for name in allNames {
					if name == printName {
						break												}
					posn 		+= name.count + 2	// positions used (2, for ", ")
				}
				let (rloc,rlen) = (posn, printNameNSeparator.count)
				 // increase size of outBuf to handle printName
				while rv.count < rloc + rlen + 2 {
					rv 			+= "      "			// okay if too long
//					rv			+= replaceSubrange(r, with:printNameNSeparator)
//					rv			+= stringByReplacingCharactersInRange:r withString:printNameNSeparator]
				}
			}
		}
		return rv
	}
}
