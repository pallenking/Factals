//  Actor.mm -- a Net with known upper context and lower evidence Bundles C2015PAK
// N.B: NAME CONVLICT: this is not a swift Actor!

// Follows "How Brains Think", by William H Calvin
//		1. What to Do Next
//		2. Evolving a Good Guess
//		3. The Janitor's Daemon
//		4. Evolving Intelligent Animals
//		5. ...

import SceneKit

/// An Actor has EVIdence and CONtext Bundles
class Actor : Net {

	 // MARK: - 2. Object Variables:
	var	con : FwBundle? 		= nil		// upper context  information
	var	evi : FwBundle? 		= nil		// lower evidence information
								
	 // Any previousClocks to be routed inside an actor get enabled here
	var previousClocks : [Part] = []
//	var previousClocksEnable : Port
 //	var timingChain :

	var positionViaCon : Bool 	= false		// con (above) involved in positions

	// MARK: - 3. Part Factory
	/// Create Actor module
	/// - Parameter config_: hash with parameters:
	/// 1.	"con" : Context FwBundle (flipped by default)
	/// 2.	"evi" : Evidence FwBundle:
	/// 	- a. evi.struc				: <>
	/// 	- b. evi.proto				:<Leaf>
	///		- c. evi.info				:{...}
	///		- d. evi.spin				: <spin>
	///		- e. evi.is					:"aTunnel", "aBundle"
	/// 3.	"viewAsAtom" : Bool - Initially view as Atomic
	/// 4.	"linkDisplayInvisible" : Bool
	/// 5.	"E"						: Bool -- Enable Actor operation
	/// 6.	"TimingChain":1		: add timing chain module
	override init(_ config_:FwConfig = [:]) {
		let config				= /*[placeMy:"stackx"] +*/ config_	// default: stackx
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

			// MAKE ALL PARTS OF ACTOR:
		   //
		  // CONTEXT, gather parameters and build
		 //
		if let con1				= partConfig["con"] as? FwBundle {
			con					= con1
			partConfig["con"] 	= nil
			con1.name 			= "con"
			addChild(con1)
		}
		let con1				= partConfig["con"]
		assertWarn(con1==nil, "'con:\(con1!.pp(.fullNameUidClass))' must be a FwBundle")

		  // EVIDENCE, gather parameters and build
		 //
		if let evi1				= partConfig["evi"] as? FwBundle {
			evi					= evi1
			partConfig["evi"]	= nil
			evi1.name			= "evi"
			addChild(evi1)
		}
		let evi1				= partConfig["evi"]
		assertWarn(evi1==nil, "'evi:\(evi1!.pp(.fullNameUidClass))' must be a FwBundle")

		viewAsAtom		 		= partConfig["viewAsAtom"			]?.asBool ?? false
		linkDisplayInvisible	= partConfig["linkDisplayInvisible"]?.asBool ?? false
		positionViaCon			= partConfig["positionViaCon"		]?.asBool ?? false

		 // Color EVIdence FwBundle GREEN (
		let _					= evi?.findCommon(firstWith:
		{(m:Part) -> Part? in
			(m as? Atom)?.proxyColor = .green
			return nil
		})
		 // Color CONtext FwBundle RED (
		let _					= con?.findCommon(firstWith:
		{(m:Part) -> Part? in
			(m as? Atom)?.proxyColor = .red
			return nil
		})

		enforceOrder()						// evi on bottom, con on top
		partConfig["addPreviousClock"] = 1	// Add Previous Clock for me
	}

	 // MARK: - 3.5 Codable
	enum ActorKeys: String, CodingKey {
		case con, evi, previousClocks, positionViaCon
		case viewAsAtom_, linkDisplayInvisible
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())

		var container 			= encoder.container(keyedBy:ActorKeys.self)
		try container.encode(con, forKey:.con)
		try container.encode(evi, forKey:.evi)
		try container.encode(previousClocks, forKey:.previousClocks)
		try container.encode(positionViaCon, forKey:.positionViaCon)
		try container.encode(viewAsAtom_, forKey:.viewAsAtom_)
		try container.encode(linkDisplayInvisible, forKey:.linkDisplayInvisible)
		atSer(3, logd("Encoded  as? Actor       '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:ActorKeys.self)

		con	 					= try container.decode(FwBundle.self, forKey:.con)
		evi	 					= try container.decode(FwBundle.self, forKey:.evi)
		previousClocks			= try container.decode([Part].self, forKey:.previousClocks)
		positionViaCon			= try container.decode(Bool  .self, forKey:.positionViaCon)
		viewAsAtom_				= try container.decode(Bool  .self, forKey:.viewAsAtom_)
		linkDisplayInvisible	= try container.decode(Bool  .self, forKey:.linkDisplayInvisible)
		atSer(3, logd("Decoded  as? Actor      named  '\(name)'"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy 			= super.copy(with:zone) as! Actor
//		theCopy.con				= self.con
//		theCopy.evi				= self.evi
//		theCopy.previousClocks	= self.previousClocks
//		theCopy.positionViaCon	= self.positionViaCon
//		theCopy.viewAsAtom_		= self.viewAsAtom_
//		theCopy.linkDisplayInvisible = self.linkDisplayInvisible
//		atSer(3, logd("copy(with as? Actor       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					  	else {	return true				}
		guard let rhs			= rhs as? Actor else {	return false			}
		let rv					= super.equalsFW(rhs)
			&& con != nil && rhs.con != nil && con!.equalsFW(rhs.con!)
			&& evi != nil && rhs.evi != nil && evi!.equalsFW(rhs.evi!)
&& {bug;return false}()// Value of type '[Part]' has no member 'equals'
//			&& previousClocks != nil && rhs.previousClocks != nil
//											&& previousClocks.equals(rhs.previousClocks)
			&& positionViaCon 	== rhs.positionViaCon
			&& viewAsAtom_ 	  	== rhs.viewAsAtom_
			&& linkDisplayInvisible == rhs.linkDisplayInvisible
		return rv
	}
	 // MARK: - 4.2 Manage Tree
	///	ALGORITHM:	scan through Net,
	///				move improper forward references infront of us
	func orderPartsByConnections() {
		panic()//return
		var retryCount 			= 100
		var orderIsGood			= false
		while !orderIsGood {
			enforceOrder()

			 // Make a try to clear out children
			var scanI 			= 0
			orderIsGood 		= true			// presume scan succeeds

			 // Scan through our Actor's Parts, from bottom up
			while scanI < children.count {
				let scanPart = children[scanI]
//				if scanPart is NSNumber {
//					continue
//				}
				 // Look only at Atoms:
				/*else*/ if let scanAtom = scanPart as? Atom {

					 // Scan thru Ports of Atoms:
					for (_, scanPort) in scanAtom.ports {
						//if scanPort_ is NSNumber {	continue }
						if !scanPort.flipped ^^ scanAtom.flipped { // going down is OKAY
							continue
						}

						if let otherAtom  = scanPort.con2?.port?.atom {		// Identify otherAtom
							 // If ancestor of otherAtom is part of self
//							let othersActorPart = otherAtom.ancestorThats(childOf:self)
							if let otherI = children.firstIndex(where: {$0 === otherAtom}), //(of:otherAtom),
							  otherI > scanI		 {
								 // pull that worker to just below us
								atBld(4, logd("Actor reordering '%@' to index %d", otherAtom.name, scanI))
								children.remove(at:otherI)//	children.removeObject(otherAtom)
								children.insert(otherAtom, at:scanI)
								 // and start all over again...
								orderIsGood = false
								break
							}
						}
						else {
							assert(scanPort.con2==nil, "peculiar")
						}
					}
					if orderIsGood == false {
						break
					}
				}
			}
			orderIsGood 		=  scanI == children.count
			retryCount			-= 1
			if retryCount < 0 {
				panic("In ordering Actor Parts, Looped 100x: Actor has an unusual net!")
				break
			}
			scanI				-= 1
		}
		enforceOrder()
	}

	 /// Ensure EVIdence is first element (if it exists), and CONtext the last (if it exists):
	func enforceOrder() {
		if con != nil {			// ///// con exists:
			if let ind 			= children.firstIndex(where: {$0 === con!}),//(of:con!),
			  ind != 0 {						  // con not first:
				children.remove(at:ind)				// remove
				children.insert(con!, at:0)			// at start
				con!.parent 	= self				// required first time
			}
		if evi != nil {			// ///// evi exists:
			if let ind 			= children.firstIndex(where: {$0 === evi!}),//(of:evi!),
			  ind != children.count-1 {			// evi not last:
				children.remove(at:ind)				// remove
				children.append(evi!)				// add at end
				evi!.parent 	= self				// required first time
			}
		}
		}
	}
	// / also add actor.previousClocks
	override func gatherLinkUps(into linkUpList:inout [() -> ()], partBase:PartBase) {
		super.gatherLinkUps(into:&linkUpList, partBase:partBase)

		 // An enable for previousClock.
		if let _		 		= partConfig["clockEnable"] {
			panic("this has never been activated")
			let enaPort			= Port()
			addChild(enaPort)
			enaPort.name		= "Ena"
			enaPort.flipped		= true

			for part in parent?.selfNParents ?? [] {
				if let actor = part as? Actor {
					actor.previousClocks.append(self)
					atBld(4, logd("CLOCK  '\(actor.fullName16)'.previousClocks now contains '\(fullName16)'"))
					break
				}
			}
		}
	}

	 // MARK: - 7. Simulator Messages
	override func receiveMessage(fwEvent:HnwEvent) {

		 // Actors convert event:.clockPrevious --> clock Previous
		if fwEvent.fwType == .clockPrevious {
			clockPrevious()
			return
		}
		super.receiveMessage(fwEvent:fwEvent)		// default behavior
	}

	 // Propigate cockPrevious to all contents registered in previousClocks
	func clockPrevious()  {

		let v0				= self.enable3?.con2?.port?.getValue() ?? 0
		if v0 > 0.5 {			// no enable Port --> enabled
			atEve(4, logd("|| $$ clockPrevious to Actor; send to \(previousClocks.count) customer(s):"))
bug//		for user in self.previousClocks {
//				user as? Actor?.clockPrevious() // Actor got -clockPrevious; send to customer
//			}
		}
		else {
			atEve(4, logd("|| $$ clockPrevious to Actor: IGNORED"))
		}
	}

	 // MARK: - 8. Reenactment Simulator
	override func simulate(up:Bool) {

		if (up) {				// /////// going UP /////////	enable
			if let enaInPort	= enable3?.con2?.port {
				let _ 			= enaInPort.getValue()
				panic()
			}
//
////						if case .direct(let otherPort) = scanPort.connectedX,
//
//			guard case .direct(let enaInPort) = self.enable3?.connectedX else {fatalError()}
//			let _ 			= enaInPort.getValue()
		}
		super.simulate(up:up)
	}

	 // MARK: - 9. 3D Support
	// Actors do not use superclass methods
	var viewAsAtom : Bool	{
		get {
			return viewAsAtom_
		}
		set(val) {
			viewAsAtom_		= val
			markTree(dirty:.vew)
		}
	}
	var viewAsAtom_			= false		// force our content to be Atomic
    var linkDisplayInvisible = false	// Ignore link invisibility

//	 reSize; fw boundIntoVew
//	 override func reSize(vew:Vew) {
//		super.reSize(vew vew:vew)
//		panic("Un-debugged")
//		  //// 1. BOUND all, in order of v.superViews (==self.parts):  DO NOT PLACE
//		 /**/	// CONtext (if it exists)
//				// ... other entries ...
//				// EVIdence (if it exists)
//		var first				= true
//		for childVew in vew.children {			// Subviews:
//			let childPart		= childVew.part
//			 /// First Repack:
//			childPart    .reSize(vew vew:childVew)		// #### HEAD RECURSIVE
//			 /// Then Reposition:
//			childPart.rePosition(vew:childVew)
//			childVew.orBBoxIntoParent()
//			first				= false
//			childVew.placed	= true
//		}
//		vew.bBox 				= .empty	// initially nil, to occupy elt 0's origin
//
//		  /// 2. PLACE   (CONtext FIRST, at the BOTTOM,
//		 /// so the assimilated content can be better placed
//		if con != nil && positionViaCon {
//			guard let conVew 	= vew.children.last else {
//				return panic("why is't there an element in v?")
//			}
//			con!.rePosition(vew:conVew, first:true)
//			conVew.orBBoxIntoParent()
//		}
//		vew.bBox = .empty					// remove con from self, but it's still placed
//		  /// 3. Scan subVews: begin<< [evi], . .. ., [con] >>end
//		 /// and insure 2..n-1 were at least gardenSize
//		var eviGardenBounds 	= BBox.empty
//		for subVew in vew.children {	// SubVews:
//			let subPart 		= subVew.part
//			let subBun 			= subPart as? FwBundle
//			  ///// Two special Cases:
//			 /// CONtext    (this is processed SECOND)
//			if subBun == con {		/* and self.positionViaCon*/
//				if !eviGardenBounds.isNan {	// if already set up
//					vew.bBox	|= eviGardenBounds	// lay gardenSize upon v.bounds
//				}
//			}
//			subPart.rePosition(vew:subVew)
//			subVew.orBBoxIntoParent()
//			  /// EVIdence  (this is processed FIRST)
//			 // Now place the garden on top EVIdence
//			if (subBun == evi/* and self.positionViaCon*/) {
//				 // lay gardenSize upon v.bounds
//				let minSize_	= minSize ?? .zero
//				let gardenCenter = (vew.bBox.size  + minSize_)/2.0
//				let gardenBBox	= BBox(gardenCenter, minSize_)
//				 // eviGardenBounds includes evi and gardenBounds:
//				assert(eviGardenBounds.isNan, "")
//				eviGardenBounds = vew.bBox | gardenBBox
//			}
//		}
	//	if vew.bBox.isNan {			// NO NON-Cohort subvews
	//		vew.bBox 			= .empty	// use our un-gapped size as zero
	//	}
	//}

	 // MARK: - 13. IBActions
	//guiVector3fAccessors4(gardenSize, GardenSize, _gardenSize)
	//- (IBAction) atomicStateAction:(NSMenuItem *)sender {
	//	panic("\n\n ***** I'm here\n\n\n")

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 				= super.pp(mode, aux)
		switch mode {
		case .line:			// add to end of line
			if aux.bool_("ppParam") {	// a long line, display nothing else.
				return rv
			}
			if evi != nil {
				rv			+= "evi:'\(evi!.name)' "
			}
			if con != nil {
				rv			+= "con:'\(con!.name)' "
			}
			if previousClocks.count != 0 {
				var separator = ""
				rv			+= "prevClks("
				for prevClockClient in previousClocks {
					rv		+= separator + prevClockClient.name
					separator=","
				}
				rv			+= ") "
			}
		default:
			break
		}
		return rv
	}
	func printContents() {
		panic()
		var allNames :[String] = []
		for element in children  {
			if let es		= element as? Splitter {
				print(es.ppContentsGather(gather:true, names:&allNames))
			}
		}
		 // alphebetize all the names found
		allNames			= allNames.sorted()//by:{	$0.name > $1.name })//allNames = [allNames sortedArrayUsingSelector:selector(caseInsensitiveCompare:)]

		for element in children  {
			if let se		= element as? Splitter {
				print(se.ppContentsGather(gather:false, names:&allNames))
			}
		}
	}
}
