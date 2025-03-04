//  Atoms.swift -- where all computations are performed C2018PAK

import SceneKit

 /// The base object for all parts, including the ones that do all the computations
class Atom : Part {	//Part//FwPart

	/* An UN-flipped Atom:	 ---- Other Ports ------	many Ports
							/|||||||||||||||||||||||\
							||||||||   Atom	 ||||||||
							\|||||||||||||||||||||||/
							 ----- 	|Port P |  -----	one Port
				'P' is unflipped:	'---o---'
				(not opensUp)			'--- 'P' is at origin, by s)
	*/

	 // MARK: - 2. Object Variables:
	var bandColor : NSColor?	= nil	 // Port whose value determines the Bundle's band color
	var proxyColor: NSColor?	= nil
	var postBuilt				= false		// object has been built
	var ports	 :[String:Port] = [:]
	var bindings :[String:String]? = nil	// a map of names to internal Ports.
			//	""	Major output
			//	+	Major output, cur
			//	-	Major output, previous
			//	G	DiscreteTime con2 point (a GenAtom.P)
			//	R	Set the state (esp of a Previouss)
	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		if let skin2			= partConfig["skin"] as? SCNNode {
			panic("skin2:\(skin2)")
			//skin				= skin2
			partConfig["skin"]	= nil
		}
		if let b				= partConfig["bindings"] as? [String:String] {  //config.fwConfig("bindings")
			bindings			= b
			partConfig["bindings"] = nil
		}

		 // Create PORTS in Atoms
		for (portName, portProp) in hasPorts() {	// process "c", "M" and "b"
			if portProp.contains("c") {		// c --> create at birth
				let newPort		=
					portProp.contains("M") ?
					   MultiPort(["named":portName, "portProp":portProp]) :
					portProp.contains("C") ?
						LinkPort(["named":portName, "portProp":portProp], parent:self) :
							Port(["named":portName, "portProp":portProp])
				ports[portName]	= newPort
				addChild(newPort)
			}
			if portProp.prefix(1) == "b" {	// b:<pathString> --> binding
				let tokens		= portProp.split(separator:":")
				assert(tokens.count == 2, "thin thread only")
				assert(tokens[0] == "b", "paranoia")
				bindings		= bindings ?? [:]		// ensure there is a bindings
				bindings![portName] = String(tokens[1])	// add to bindings
			}
		}
	}
	 // MARK: - 3.1 Port Factory
	 /// Declare the Ports in an Atom:
	/// ## Returns a hash with key:value, where key is Port name, and val describes the Port:
	/// -  c: ---- Create at birth,
	/// -  a: ---- Auto-populate,
	/// -  f: ---- Flipped,
	/// -  p: ---- ?????,
	/// -  M: ---- MultiPort
	/// -  C: ---- LinkPort				// C-->L ??
	/// -  B:path1 ---- Bind to internal path1
	/// ## Overidden by superclasses
	func hasPorts() -> [String:String]	{
		return ["P":"c"]
	}

	 // MARK: - 3.5 Codable
	enum AtomsKeys: String, CodingKey {
//		case bandColor 	// NSColor?
//		case proxyColor	// NSColor?
		case postBuilt	// Bool
		case ports	 	// [String:Port]
		case bindings	// [String:String]?
	}
	 // / Serialize
	override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)
		var container 				= encoder.container(keyedBy:AtomsKeys.self)

		try container.encode(postBuilt, forKey:.postBuilt)
//?		try container.encode(bandColor, forKey:.bandColor)
//?		try container.encode(proxyColor,forKey:.proxyColor)
		try container.encode(ports, 	forKey:.ports)
		try container.encode(bindings, 	forKey:.bindings)
		atSer(3, logd("Encoded  as? Atom        '\(fullName)'"))
	}
	 /// Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:AtomsKeys.self)

		postBuilt 				= try container.decode(			   Bool.self, forKey:.postBuilt)
//?		bandColor 				= try container.decode(			NSColor.self, forKey:.bandColor)
//?		proxyColor 				= try container.decode(			NSColor.self, forKey:.proxyColor)
		ports 					= try container.decode(	  [String:Port].self, forKey:.ports)
		bindings 				= try container.decode([String:String]?.self, forKey:.bindings)
		atSer(3, logd("Decoded  as? Atom       '\(name)'"))
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Atom
//		theCopy.postBuilt		= self.postBuilt
//		theCopy.bandColor		= self.bandColor
//		theCopy.proxyColor		= self.proxyColor
//		theCopy.ports	 		= self.ports
//		theCopy.bindings		= self.bindings
//		atSer(3, logd("copy(with as? Atom       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 						else {		return true			}
		guard let rhs			= rhs as? Atom	else {		return false		}
		guard super.equalsFW(rhs)				else {		return false		}
		guard postBuilt	 == rhs.postBuilt		else {		return false		}
		guard bandColor	 == rhs.bandColor		else {		return false		}
		guard proxyColor == rhs.proxyColor		else {		return false		}
		guard ports.equals(rhs.ports)			else {		return false		}		//. Ports are also in Children!!!
		guard bindings	 == rhs.bindings		else {		return false		}
		return true
// 		let rv					= super.equalsFW(rhs)
// 			&& postBuilt		== rhs.postBuilt
// 			&& bandColor		== rhs.bandColor
// 			&& proxyColor		== rhs.proxyColor
// 		//??	&& ports.equalsFW(rhs.ports)			//. Ports are also in Children!!!
//				//Referencing instance method 'equalsFW' on 'Dictionary' requires that 'Port' conform to 'Equatable'
// 			&& bindings			== rhs.bindings
// 		return rv
	}

	// MARK: - 4. Factory

// xyzzyx4
//	func resolveInwardReference(_ path:Path, openingDown downInSelf:Bool, except:Part?) -> Part? {
//
//		if path.atomNameMatches(part:self) {		// matches as Atom, ignoring Port
//			var rv : Part?			= nil;
//			if path.namePort.count {					// if named Port is specified
//
//				  // Search all existing component Ports:
//				 //
//				for port in parts where port is Port {
//					if port.name == path.portName {
//						assert(rv == nil, "multiple Ports named '\(path.portName)' found")
//						if let portAbility = atomsDefinedPorts[path.portName] {
//							let aPort 	= addPart(Port())
//							aPort.flipped = portAbility.contains("d")
//							aPort.name = path.portName;
//							rv = aPort;						// return newly created Port
//						}
//					}
//				}
//				if rv == nil,
//				  let portAbility = atomsDefinedPorts[path.portName] {
//					let aPort = Port()
//					addPart(aPort)
//					aPort.flipped = portAbility.contains("d")
//					aPort.name = path.portName;
//					rv = aPort;						// return newly created Port
//
//				 // If not found, perhaps it could be built
//				if (rv == 0)
//					if (NSString *portAbility = [self xxx) {
//						Port *aPort = [self addPart:[Port another]];
//					}
//			}
//			else {
//				rv = self							// matches the Atom
//			}
//			 // report and return results:
//			if rv != nil {
//				atBld(5, "   MATCHES Inward check: \(rv.fullName)")
//				return rv
//			}
//		}
//		atBld(5, "   FAILS   Inward check")
//
//		return super.resolveInwardReference(path, openingDown:downInSelf, except:exception)
//	}

	// MARK: - 4.4 Navigating Network
	func biggestBit(openingUp  upInSelf:Bool) -> Port? {
		var rv : Port? 			= nil
		for child in children {
			if let port 		= child as? Port,
			  port.flipped == upInSelf {					// correct facing?
				if rv==nil {
					rv 			= port
				}
				else {
					atBld(4, logd("[getBit)????? : ignoring %@, alrady found %", port.name, rv!.name))
				}
			}
		}
		return rv
	}

	  // MARK: - 4.7 Editing Network
	 /// Search an Atom for a Port, create if needed.
	/// * If desired port not in Atom's .ports, check delayed populate and bindings.
	/// - Parameter named:			 --- required name of Port, "*" generates automatic name, nil or "" allows any name
	/// - Parameter localUp:		 --- required flip of Port, nil->either
	/// - Parameter wantOpen:		 --- required that Port be open
	/// - Parameter allowDuplicates: --- pick the first match
	/// - Returns: selected Port
	func port(named wantedName:String, localUp wantUp:Bool?=nil, wantOpen:Bool=false, allowDuplicates:Bool=false) -> Port? {
		atBld(7, logd(" '\(fullName)'   .port(   named:\"\(wantedName)\" want:\(ppUp(wantUp)) wantOpen:\(wantOpen) allowDuplicates:\(allowDuplicates))"))
		var rvPort : Port?		= nil					// Initially no return value

		 // Check BINDINGS?
		if let bindingString 	= bindings?[wantedName] {
			let bindingPath		= Path(withName:bindingString)
			if let boundPart	= find(path:bindingPath) {	// Decode binding target Part
				rvPort 			=  boundPart as? Port			// Case 1: already a Port?
				if let boundAtom = boundPart as? Atom {			// Case 1: Atom's Port?
					let sWantUp	= wantUp==nil ? nil : wantUp! ^^ boundAtom.upInPart(until:self)
					atBld(6, logd(" .BINDING \"\(wantedName)\":\"\(bindingString)\" now at \(fwClassName): \"\(boundAtom.pp(.fullName))\""))

					// Binding leads to an atom:  ******* RECURSIVE CALL: deapth < 3
			/**/	rvPort		= boundAtom.port(named:wantedName, localUp:sWantUp, wantOpen:wantOpen, allowDuplicates:allowDuplicates)
				}
//				rvPort 			=  boundPart as? Port			// Case 2: Port?
			}
			atBld(4, logd("-----Returns (BINDING \"\(wantedName)\":\"\(bindingString)\") -> Port '\(rvPort?.fullName ?? "nil")'"))
		}
		 // If Existing Port?
		atBld(4, logd("xxxxxxxx"))
		rvPort					??= existingPorts(named:wantedName, localUp:wantUp).first
		 // If Delayed Populate Port?
		rvPort					??= delayedPopulate(named:wantedName, localUp:wantUp)

		 // Auto-Broadcast: Want open, but its occupied. Make a :H:Clone
		if rvPort == nil,
		  wantOpen,								// want an open port
		  let origConPort		= rvPort?.con2?.port// found a port, but it's not open!
		{
			 // :H:Clone rv
			let cPort 			= rvPort!					// Clone non-open rv

			 // Get another Port similar to similarPort from Splitter?:
			if let splitter 	= self as? Splitter,
			  cPort.flipped,
			  splitter.isBroadcast {
				rvPort				= splitter.anotherShare(named:"*")
				atBld(4, logd("-----Returns Splitter Share: '\(rvPort!.pp(.fullNameUidClass))'"))
				return rvPort
			}

			 // Get another Port from an attached Splitter?:
			else if let cPort	= cPort.con2?.port,
			  let conSplitter 	= cPort.atom as? Splitter,
			  conSplitter.isBroadcast {
				rvPort				= conSplitter.anotherShare(named:"*")
				atBld(4, logd("-----Returns Another Share from Attached Splitter: '\(rvPort!.pp(.fullNameUidClass))'"))
				return rvPort
			}

			 // Add Auto Broadcast?:
			else if let x		= rvPort!.atom?.autoBroadcast(toPort:cPort) {
				atBld(4, logd("-----Returns Another in autoBroadcast Attached Splitter Share: '\(x.pp(.fullNameUidClass))'"))
				return x
			}
			panic("FAILS to find Port it: '\(fullName)'.port(named:\"\(wantedName)\" want:\(ppUp(wantUp)) wantOpen:\(wantOpen) allowDuplicates:\(allowDuplicates))")
		}
		return rvPort
	}
	  // MARK: - 4.7 Editing Network

	 /// Find all existing Ports (those in .ports) that match parameters
	/// * Only Ports in Atom's .port array are considered.
	/// * (Bindings and Delayed Populate are ignored.)
	/// - Parameters:
	///   - wantName: name the port must have (or nil)
	///   - portUp: if the port must be up (down, or nil)
	/// - Returns: A (possibly empty) array of matching ports.
	func existingPorts(named wantName:String?=nil, localUp portUp:Bool?=nil) -> [Port] {
		var rv 					= [Port]()	// initially empty

		 // Is wantName in ports[]?
		for (pName, port) in ports {		// Search ports:
			if wantName    == ""		||		// (name unimportant     OR
			  wantName     == pName,			//  name matches port's)  AND
			  portUp       == nil 		||		// (flip unimportant     OR
			  port.flipped == portUp!			//  flipped properly)     AND	// port.connectedX==nil || !wantOpen// open if need be
			{
				rv.append(port)					// found unique acceptable Port
			}
		}
		return rv
	}

	 /// Create auto-populated Ports
	/// * Port must be in hasPorts() with an "a" (autopopulate) character
	/// - Parameters:
	///   - wantName: name
	///   - wantUp: up
	/// - Returns: created Port, or nil
	func delayedPopulate(named wantName:String?=nil, localUp wantUp:Bool?) -> Port? {
		 // Delayed pouplate -- Create the Port
		if let wantName				= (wantName != nil && wantName != "") ? wantName! : // name supplied
									     wantUp != nil ? (wantUp! ? "S": "P") : nil   , // pick up or down
   		  ports[wantName] == nil, 			// Its not already in ports[]
		  let pProp					= hasPorts()[wantName],	// process "a", "f", "M"
		  (wantUp == nil ||					// (flip unimportant OR
			pProp.contains("f") == wantUp!),//  flip matches)
		  pProp.contains("a")				// a=auto-populate
		{		// Make a new Port:
			let newPort				= (self is Splitter) ? (self as? Splitter)?.anotherShare(named:"*") :
									  !pProp.contains("M") ?
										   Port(["named":wantName, "portProp":pProp]) :
									  MultiPort(["named":wantName, "portProp":pProp])
			ports[wantName] = newPort
			addChild(newPort)
			return newPort					// (always open)
		}
		return nil
	}

	 /// Get a (perhaps open) Port like the prototype
	/// * If port is open, or mustn't be open, return it
	/// * If port is on a Splitter, add another share
	/// * If port is connected to a Broadcast, make a Port on it.
	/// - Parameter givenPort: --- prototype to duplicate
	/// - Returns: the wanted Port, or nil
//	func makeOpenIfNot(port givenPort:Port) -> Port? {
//		let s					= givenPort.atom
//		assert(s != nil && s !== self, "")		// "!==" -> same identity
//
//		let similarPorts		= s!.existingPorts(named:givenPort.name, localUp:givenPort.flipped)
//		if  similarPorts.count > 0 {
//			let similarPort = similarPorts[0]	// Just pick one
//			assert(similarPort.connectedX != nil, "should be occupied")
//
//			 // Get another Port similar to similarPort from Splitter?
//			if let splitter = self as? Splitter,
//			  similarPort.flipped,
//			  splitter.isBroadcast {
//				return splitter.anotherShare(named:"*")
//			}
//
//			 // Get another Port from an attached Splitter:
//			if let conSplitter = similarPort.connectedX?.atom as? Splitter,
//			  conSplitter.isBroadcast {
//				return conSplitter.anotherShare(named:"*")
//			}
//			return s!.autoBroadcast(toPort:similarPort)
//		}
//		return nil
//	}

	 /// Edit a Network to splice in a Broadcast unit
	/// - At the Port that needs tapping
	/// - Trace through the Links
	/// - Try, perhaps it's a Bcast
	/// - Otherwise, insert a new Broadcast Element into the network
	/// - Parameter toPort: one end of the link that gets the Broacast added
	/// - Returns: a free port in the added Broadcast
	func autoBroadcast(toPort:Port) -> Port {

		  //   "AUTO-BCAST": Add a new Broadcast to split the port
		 //					/auto Broadcast/auto-broadcast/
		atBld(4, logd("<<++ Auto Broadcast ++>>"))

		 // 1.  Make a Broadcast Splitter Atom:
		let newName				= "\(name)\(toPort.name)"
		let newBcast 			= Broadcast(["name":newName, "placeMe":"linky"])	//"flipped"
		newBcast.flipped		= true												// elim

		 // 2.  Find a spot to insert it (above or below):
		 // Choose so inserted element is in scan order, to reduces settle time.
		let papaNet				= toPort.atom!.enclosingNet! /// Find Net
									// worry about toPort inside Tunnel
		let child	 			= toPort.ancestorThats(childOf:papaNet)!
		guard var ind 			= papaNet.children.firstIndex(where: {$0 === child}) else {
			debugger("Broadcast index bad of false'\(toPort.fullName)'")
		}
		newBcast.flipped		= toPort.upInPart(until:papaNet) == false
		ind						+= newBcast.flipped ? 1 : 0		// orig,	3:Broadcast, 4:Previous		GOOD	//		ind						+= newBcast.flipped ? 0 : 1		// proposed,3:Previous,  4:Broadcast	BAD
		papaNet.addChild(newBcast, atIndex:ind)
nop
		 //	 3,  Wire up new Broadcast into Network:
		//		|___			  ________|
		//			\.connectedX /				 inPort:Port
		//			 \--|--V----/				 inCon :Con2
		//				A  V
		//		before #A  V# 		   #A V# after
		//				 |			    V A
		//				 |		.____/-=|-A--\___s2Con :Con2.
		//				 |		|		|		 s2Port:Port|
		//				 | 		|		|					|
		//				 |		|		|  .----rv:Port		 \
		//				 |		|		| /					  > ADDED BCAST
		//				 |		|	 newBcast				 /
		//				 |		|		|					|
		//				 |		|___P pPort "abc"_pPort:Port
		//				 |			 \--|-V--*-/  pCon :Con2
		//				 |				A V
		//		before #A  V# 		   #A V# after	(A)
		//				V    A
		//			 /--|----A-=-----\		   toPort:Con2
	   	//		 ___P toPort "def"    \_____   toPort:Port
		//		|		|					|
		//		|		Atom				|
		let newS1Port: Port		= newBcast.anotherShare(named:"*")
		let newPPort : Port		= newBcast.ports["P"]!					//to go to self.P

		let con2Port			= toPort.con2!.port
		
		toPort.con2				= .port(newPPort)
		newPPort.con2			= .port(toPort)		// 1. move old connection to share1

		con2Port!.con2			= .port(newS1Port)	  	// 2. link newBcast to toPort
		newS1Port.con2			= .port(con2Port!)

//		guard let toPort		= inPort.con2?.port else { debugger("Link error slhf")}		// l0.P
//		toPort.con2 			= .port(pPort)		// toPort -> pPort
//		pPort.con2				= .port(toPort)	// pPort -> toPort

		return newBcast.anotherShare(named:"*") 	// 3. share2 is autoBroadcast
	}
	   // MARK: - 4.8 Matches Path
	override func partMatching(path:Path) -> Part? {

		 // location matches partArray
		guard let _				= super.partMatching(path:path) else {	//proxy
			return nil						// partArray mismatch
		}
	//	assert(proxy==self, "proxy?")

		if path.portName != nil { 		// path has portName:
								
			 // reBind Atom's Port to an internal Port?
			if let bindingName	= bindings?[path.portName!] {
				let bindingPath	= Path(withName:bindingName) // Path for binding
				return find(path:bindingPath)					// exists in self
			}
			return nil 						// has portName ==> must be Port
		}
		return self						// we match!
	}

	 // MARK: - 5. Wiring
//	var defaultLinkProps : FwConfig	{ return [:]		}
	override func gatherLinkUps(into linkUpList:inout [() -> ()], partBase:PartBase) {
/**/	super.gatherLinkUps(into:&linkUpList, partBase:partBase)

		   // /////////////////////////////////////////////////////////////////////
		  // //    :H: src=SouRCe, lnk=LiNK, trg=TaRGet con=CONtaining net      //
		 // /////////////////////////////////////////////////////////////////////
		let srcPortAbilities	= self.hasPorts()	// key --> Port exists
		var sRetiredKeys : [String] = []

		 // Paw through Atom's local configuration
		for (srcPortString, targets_) in partConfig {

			  // Find a configuration key which is a Port con2:
			 // :H: SouRCe is always a Port name
			let srcPortPath		= Path(withName:srcPortString)
			let srcPortName 	= srcPortPath.portName
			if srcPortName == nil || srcPortAbilities[srcPortName!] == nil {
				continue				// Not Port connections
			}
			sRetiredKeys.append(srcPortString)

			 // source --> targets
			for var trgAny : FwAny in targets_ as? [FwAny] ?? [targets_] {
				 // STATE: self!, srcPortName!, trgAny!
				let wireNumber	= (partBase.indexFor["wire"] ?? 0) + 1				// root.wireNumber += 1
				partBase.indexFor["wire"] = wireNumber								// let wireNumber	= root.wireNumber
				let breakAtWireNo = partBase.indexFor["breakAtWire"]
				let brk			= wireNumber == breakAtWireNo
				assert(!brk, "Break at Creation of wire \(wireNumber) (at entryNo \(Log.shared.eventNumber-1)")
				atBld(4, logd("L\(wireNumber) source:   \(fullName16).\'\((srcPortString + "'").field(-6))  -->  target:   \(trgAny.pp(.line))"))

  /* **************************************************************************/
 /* *********/	let aWire = { () -> () in    /* ******* DO LATER: ************/
/* **************************************************************************/

					 // WIRE:   self.(srcPortName)  -->  trgAny
					let trgAnyIn = trgAny
					if wireNumber == breakAtWireNo {
						panic("Break at wiring up wire \(wireNumber)")
					}

					  // ///////////////////////////////////
					 // 1. Find Target Atom from trgAny
					var linkProps  : FwConfig = [:]//self.defaultLinkProps
					var trgPortName: String?  = nil
					 // //// 1a. FwConfig? --> name in L2(),D2() *--> link props
					if var trgConfig = trgAny as? FwConfig,
					  let trgName = trgConfig["name"]?.asString {
						trgAny	= trgName
						trgConfig["name"] = nil		// remove name
						linkProps = trgConfig		// the rest is link properties
					}								// replaces default
					 // //// 1b. String? ----> Path
					if let trgStr = trgAny as? String {
						trgAny	= Path(withName:trgStr)
					}
					 // //// 1c. Path? ------> Atom, *----------> port name,
					if let trgPath	= trgAny as? Path {			// link props
						guard let trgAtom = self.find(path:trgPath, up2:true, inMe2:true) else {	//, all:true
							panic("Starting at '\(self.pp(.fullName))', " +
								  "Failed to follow Path <\(trgPath.pp(.line))>.")
							return
						}
						linkProps += trgPath.linkProps
						trgPortName	= trgPath.portName
						trgAny	= trgAtom
					}
					  // /// If trgAny is a Port, get it's Atom:
					 // //// 1d. Port? ------> Atom, *-----------> port name
					if let trgPort1	= trgAny as? Port {	// We have target as a Port
						let atom = trgPort1.atom			// find it's Atom
						assert(atom != nil, "Port's parent isn't an Atom")
						trgAny	= atom!
						trgPortName	= trgPort1.name
					}
					 // //// 1e. Atom!
					guard let trgAtom = trgAny as? Atom else {
						panic("In  \(self.pp(.fullName)):  target  '\(trgAnyIn.pp(.short))'  cannot be resolved to Atom")
						return
					}
					trgPortName	= trgPortName ?? ""		/// portName: nil -> ""
					linkProps	+= srcPortPath.linkProps

					   // //////////////////////////////////
					  // /// 2. Find CONTAINING NETWORK, and who is Boss?
					 //  Now we have:
					//	    Source: 		   Link:  			Target:
					//		+ self			+ linkProps			+ trgAtom?
					//		+ srcPortName						+ trgPortName
					//		  |   	         					 	|(trgAny no longer valid)
					//		  +-----------> # conNet <--------------+
					//		  |	  	 		    |					|
					//		  |    		    #: targAboveInConNet	|
					//		  | 				|					|
					// 		#: srcPort <--------^-------------> #: trgPort
											// linkProps
					 //  #: conNet <== Encloses source and target Atoms
					guard let conNet = self.smallestNetEnclosing(self, trgAtom) else {
						panic("Could not find Net conaining '\(self.pp(.fullName))' and '\(trgAtom.pp(.fullName))'")
						return
					}
					  // #: Target ABOVE Source? If unflipped, above means:
					 // a) lower index, b) higher on printed page (given DAG ordering)ppppp
					// ---------> This is a seminal decision <-------
					let trgInd	= conNet.dagIndex(ancestorOf:trgAtom)
					assert(trgInd != nil, "conNet doesn't contain Target")
					let srcInd 	= conNet.dagIndex(ancestorOf:self)
					assert(srcInd != nil, "conNet doesn't contain Self")
					assert(trgAtom !== self, "Self and target are at the same location: \(self.fullName)")
					assert(trgInd! != srcInd!, "Self and Target enter at same index \(trgInd!). This is strange")
// BAD CHANGE!		let trgAboveSInCon = trgInd! > srcInd!
					let trgAboveSInCon = trgInd! < srcInd!
					let lnkInsInd = min(trgInd!, srcInd!) + 1	// insert after first
								//
					   // /////////////////////////////////
					  //   3. Get Ports for Atoms. MAKE NEW ONES IF NEEDED

					 //    3a. //// SouRCe (is self)				// Log
					let trgAboveSInS = trgAboveSInCon ^^ self.upInPart(until:conNet)
					atBld(4, self.logd("L\(wireNumber)-SOURCE in \(conNet.fullName) opens _\(ppUp(trgAboveSInS))_"))

					 // 	3b. //// Get the SouRCe Port			// source Port
					let srcPort	= self.port(named:srcPortName!, localUp:trgAboveSInS, wantOpen:true)
					assert(srcPort != nil, "srcPort==nil")
								
					 //		3c. //// TaRGet:						// Log
					let trgAboveSInT = trgAboveSInCon==trgAtom.upInPart(until:conNet)
					let trgInfo	= "---TARGET:\(trgAtom.fullName16)" +
								  ".'\((trgPortName! + "'").field(-6))" +
								  " opens _\(ppUp(trgAboveSInT))_"
					atBld(4, self.logd(trgInfo))

					 //		3d. //// Get the TaRGet Port			// target Port
					let trgPort = trgAtom.port(named:trgPortName!, localUp:trgAboveSInT, wantOpen:true)//	(name=="" -> share)
					assert(trgPort != nil, "trgPort==nil")

					  // //////////////////////////////////
					 //   4. Link
					//			srcPort		linkProps				trgPort
					//			--. 		      					.--
					//	  Atom	  ]o========= Link? ===============o[    Atom
					//			--'									'--
					 // Is this a direct con2? or is there a Link involved?
					var msg1 	= "L\(wireNumber) ADDED: << \(srcPort?.fullName ?? "") "
					 // Link properties depend on those of Ports involved and Link
					let neighbors:[FwAny] = [linkProps, trgPort!, srcPort!]
					var link :Link?	= nil
					let direct 	= self.check("direct", in:neighbors) == true
					if !direct {		// Make (Multi)Link:
						let s	=    srcPort! is MultiPort
						let t	=    trgPort! is MultiPort
						assert( !(s  && !t), "srcPort=\(srcPort!.pp(.fullName)) is a MultiPort, but trgPort=\(trgPort!.pp(.fullName)) isn't.")
						assert( !(!s &&  t), "srcPort=\(srcPort!.pp(.fullName)) isn't a MultiPort, but trgPort=\(trgPort!.pp(.fullName)) is.")
						link 	=  !s ? Link(linkProps) : MultiLink(linkProps)
						msg1 	+= " <->\(link!.name)"
					}
					atBld(4, self.logd(msg1 + "<-> \(trgPort!.fullName) >> in:\(conNet.fullName)"))

					 // CHECK: Boss and Worker Ports face opposite // MIGHT BETTER CHECK s->d wrt children.index
					if trgPort!.upInWorld ^^ !srcPort!.upInWorld,	// direction fault and
					  !(self.check("noCheck", in:neighbors) == true)	// checks enabled
					{	msg1	=  "\n  Within Containing Net" + conNet.fullName + ":"
						msg1	+= "\n\t" + "Source: " + srcPort!.fullName
						msg1	+= " " + srcPort!.upInWorldStr()
						msg1    += "\n\t" + "Target: " + trgPort!.fullName
						msg1	+= " " + trgPort!.upInWorldStr()
						atBld(4, self.warning("Attempt to link 2 Ports both with worldDown=\(srcPort!.upInWorldStr())." +
								" Consider using config[noCheck] '^'." + msg1))
					}
					assert(srcPort?.con2 == nil, "SouRCe PORT occupied")
					assert(trgPort?.con2 == nil, "TarGeT PORT occupied")
							// DIRECT Connect: ?? ""
					if link==nil {						// no Link made
						srcPort!.connect(to:trgPort!)		// Direct Con2
					}
					else { 								// LINK'ed Con2:
						link!.ports[trgAboveSInCon ? "P" : "S"]!.connect(to:srcPort!)
						link!.ports[trgAboveSInCon ? "S" : "P"]!.connect(to:trgPort!)
						conNet.addChild(link, atIndex:lnkInsInd)
						 // Active segments from creation
						partBase.factalsModel?.simulator.linkChits += link!.curActiveSegments
						//self.partBase!.simulator.linkChits += link!.curActiveSegments
					}
				}
/* ***************************** END OF CLOSURE **************************/
				// /////////////////////////////////////////////////////////
				linkUpList.append(aWire)  // must copy, cause this stack goes away //.copy()
			}
		}
		for key in sRetiredKeys {	// Retire used keys in partConfig
			partConfig[key] 	= nil
		}
	}
	 /// Check con2 atributes in FwAny
	 /// - Paramete attribute: -- sought in constraints
	 /// - Paramete in: -- Array where attribute might exist
	func check(_ attribute:String, in constraints:[FwAny]) -> Bool? {
		if self is Link, attribute == "direct" {
			return true			// to Link: always direct
		}
		for constraint:FwAny in constraints { /// return first attribute found
			if let fwPart 		= constraint as? Part,		//FwPart
			  let rv				= fwPart.config(attribute)?.asBool {
				return rv		// FwPart looks up in its config
			}
			else if let fwConfig = constraint as? [String:FwAny],
			  let rv:Bool		= fwConfig[attribute]?.asBool {
				return rv		// Dictionary lookup
			}
		}
		return nil
	}

	 // MARK: - 8. Reenactment Simulator
	 // Use the attached Shares to process data:
	 // Don't simulate Ports (before or after)
	override func portChitArray() -> [()->String] {
		var rv : [()->String]	= []
		for child in children {
			rv 					+= child.portChitArray()
		}
		return rv;
	}

	 // MARK: - 9.1 reVew
 // UNNEEDED since Ports are in children
//	override func reVewfunc reVew(vew vew:Vew?, parentVew:Vew?) {
//		super.reVew(vew:vew, parentVew:parentVew)
//
//			// ///// reView PORTS
//		if initialExpose == .open {
//			let vew				= vew ?? parentVew!.find(part:self, maxLevel:1)
//			for (_, port) in ports {			// FOR ALL Ports
//				port.reVew(vew:nil, parentVew:vew)
//			}
//		}
//	}
	// (Most of work is done in Part)

	 // MARK: - 9.2 reSize
	 /*		Ports packed around bound of children's Views:
		+---------------------------------------+
		|		Port	Port	Port			|
		|Port	+-----------------------+  Port |
		|		| Bound of _CHILD Atoms_|		|
		|	Port|   non-Port Views		|		|
		|		+-----------------------+ Port  |
		|		Port	Port	Port			|
		+---------------------------------------+
	 */
	override func reSize(vew:Vew) {
		vew.children.forEach {$0.keep = false}	// mark all Views as unused

				// 1. Resizes all  _CHILD Atoms_ FIRST (no _CHILD Ports_)
		super.reSize(vew:vew)

				// 2. reSize  _CHILD Ports_ around the packed Atoms LAST
		if vew.expose == .open {
			var bBoxAccum		= vew.bBox		// Accumulate wo disturbing Atom's vew.bBox
			 // Loop through Ports:
			for (portName, port) in ports {		// if a Vew exists:
				if let portVew	= vew.find(name:"_" + portName, maxLevel:1) {
					portVew.keep = true
//bug//NReset
					if port.test(dirty:.size) {
						port.reSize(vew:portVew)	// 2A. Pack Port (why is this needed)
					}
					rePosition(portVew:portVew)		// 2B. Reposition Port via Atom:

					 // Get Port's position in parent:
					let bBoxInAtom = portVew.bBox * portVew.scnRoot.transform
					bBoxAccum	|= bBoxInAtom		// Accumulate into _tmpBBox_
				}
			}
			vew.bBox			= bBoxAccum	 	// Install temporary BBox
		}
		 		// 3. Remove unused Views
		for childVew in vew.children where
				!(childVew.keep)  &&				// bug?  childVew.keep == false
				!(childVew is LinkVew) {			//200124 expedient, to prevent thrashing LinkViews
			childVew.scnRoot.removeFromParent()			// needed?
			childVew.removeFromParent()
		}
		 // Add gap around Atom, so lines don't overlap
		let gap				= vew.config("gapAroundAtom")?.asCGFloat ?? 0.01
		vew.bBox.size		+= 2*gap
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.find(name:"s-Atom") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-Atom"

			let hei				= CGFloat(2.0)
			scn.geometry		= SCNBox(width:0.6, height:hei, length:0.6, chamferRadius:0)
			scn.position.y		= hei/2
			scn.color0			= .orange
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}

	 // MARK: - 9.4 rePosition
	/// Reposition a Port's vew in parent, by name
	/// - Parameter vew: --- a Port's views
	func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["P"] {			// P: Primary
			assert(!port.flipped, "'M' in Atom must be unflipped")
			vew.scnRoot.position.y	= -port.height
		}
		else {
			atRsi(3, warning("Did not find position for '\(port.pp(.fullNameUidClass))'"))
			vew.scnRoot.transform	= .identity
		}
	}
		  // ////////////////////////////////////////////////////////////
		 // ////////////////////////////////////////////////////////////
		// /////        Place ABOVE rest of existing           ////////
	   // ////////////////////////////////////////////////////////////
	  // ////////////////////////////////////////////////////////////
	 //
	override func placeByLinks(inVew vew:Vew, mode:String?=nil) -> Bool {
		func atPri_fail(_ format:String, _ args:CVarArg...) -> Part? {
			atRsi(5, print("\t\t" + "ABORT: " + format, args))
			return nil
		}
		assert(mode == "linky", "placeByLinks only debugged for 'linky' mode")

		 // ////////////   Compute Position from wires   //////////
		// presumes mode uses +Y
		let popVew 				= vew.parent
		vew.scnRoot.position		= .zero		// remove nan spot, leave rotation part

		  // :H: my	 -- a Part of me, whose position is being found
		 // :H: trial -- a boss in the lower atom which has its position known

		   // get the spot I will attach to, presuming I'm at the origin.
		  // N.B: Everything is spun and bound. Placing only deals with setting the position spot
		 // set up the flipped matrix to be flipped if our part is.

		   // ////// Position by fixed Ports self is connected to
		  //
		 // calculation performed in refVew, aka pop
		let refVew   	: Vew	= popVew!
		var maxPositionY: CGFloat = -CGFloat(MAXFLOAT)		// ugly
		var weightSum 	: CGFloat = 0			// <N>:N, 0:none, -1:dominated
		var avgPosition	:SCNVector3	= .zero		// default return position is Nan
		var lastDomIf2	: Part?	= nil

		atRsi(4, vew.log(">>===== Position \(self.fullName) by:\(mode ?? "2r23") (via links) in \(parent?.fullName ?? "nil")"))
			   // /////////////////////////////////////////////////////////////// //
			  // 															     //
			 //  For all enclosed subBits, looking for things to position it by //
			//  :H: Searching for two Ports: inMePort and fixedPort			   //
		   // 																  //
		  // ////////////////   Scan through subparts:   /////////////////// //
		let _					= findCommon(firstWith:
		{ (inMe:Part) -> Part? in		// Count Ports:
			return nil		// nil -> not found -> look at all in self
		})

		let _					= findCommon(up2:false, inMe2:true, firstWith:					//all:false,
		{ (inMe:Part) -> Part? in		// all Parts inside self ##BLOCK## //
			atRsi(5, vew.log("  TRY \(inMe.fullName.field(10)) ", terminator:""))

			   // /////////////////////////////////////////////////////////////// //
			  // /////// Search for a Link to fixed ground
			 //							// // a. Ignore if not Port
			guard let inMePort	= inMe as? Port else {
				return atPri_fail(		"inMe not Port")
			}
			atRsi(4, print("Port ", terminator:""))
			if inMe.parent is Link {
				return atPri_fail(		"inMe's atom is Link inside of self!")
			}
										// // b. Ignore Ports named M (ad-hoc)
			if inMePort.name == "M" {
				return atPri_fail(		"inMe name==M !")
			}
			  // /////// Go through a LINK to a (hopefully) fixed point
			 //							// // c. invisible link
			if let lnk			= inMePort.con2?.port?.atom as? Link,
			  lnk.config("initialDisplayMode")?.asString == "invisible" {
				return atPri_fail(		"inMe goes through invisible Link")	// invisible if invisible link connects
			}
										// // d. not connected
			guard let fixedPort	= inMePort.portPastLinks else {
				return atPri_fail(		"inMe is not connected")
			}
										// // e. connected to ParameterPort
			if fixedPort is ParameterPort {
				return atPri_fail(		"Fixed Port is a ParameterPort")
			}
			atRsi(4, print("-->\(fixedPort.fullName16) ", terminator:""))
										// // f. INSIDE of self, IGNORE
			if find(part:fixedPort) != nil {
				return atPri_fail(		"fixedP is inside self")
			}
										// // g. If other end is not in parent, IGNORE
			if parent?.find(part:fixedPort)==nil {
				return atPri_fail(		"fixedP is not inside parent")
			}
										// // h. If other end is a Write Head (AD HOC)
			if fixedPort.parent is WriteHead {
				return atPri_fail(		"fixedP goes to WriteHead")// do not position via WriteHead
			}
				// /////// FOUND:
			   // inMeP is a Port somewhere in me (self)
			  // fixedP is a Port somewhere on "terra firma", outside of me
			 // commonNet encloses them
			/*		       _____________  *//** COMPUTATION *//*
					ATOM  |			    |		(assumes vew.position == .zero)
					self < to position  | 	o position	 (starts as .zero,
					inMe  |	  (self)    |	|			   see newInMePosn)
					 PORT  \Port/ \Port/	|  <--- inMeP
							 |      |		v^ <=== inMeSpotIC
							 P      P	     |
							Link   Link		 |  gap
							 P      P		 |
							 | 	    |		^o <=== fixedSpotIC
					  PORT /Port\_/Port\    |  <---	fixedP
						  |	 (fixed)    |	|
					ATOM <  reference   |	o^
					fixed |_____________|	 |
				commonNet					 o  .zero commonNet
			 */
			guard let commonNet	= smallestNetEnclosing(fixedPort, self) else {
				return atPri_fail(		"smallestNetEnclosing failed")
			}
			let commonVew 		= refVew.find(part:commonNet, up2:true, inMe2:true)
			let inMePOpensUpIC	= inMePort.upInPart(until:commonNet)		// ???wtf???

			atRsi(4, print(inMePOpensUpIC ? "facingUp " : "facingDown -> SUCCESS\n", terminator:""))
			if  inMePOpensUpIC {		// // g. pointing up, but not into a Context
				return atPri_fail(		"not in context")
			}

			  // ///// Compute pessimistic spot estimates in commonVew
			let  inMeSpot		= inMePort .peakSpot(inVew:commonVew!, openingUp:false)
			let fixedSpot		= fixedPort.peakSpot(inVew:commonVew!, openingUp:true)		//print(fixedSpot.pp(.fullName))
			var newInMePosn		= fixedSpot - inMeSpot		// (all SCNVector3's)
			 // ///// GAPs for con2 via Link or Direct
			var gap 			= vew.config("gapLinkFluff")?.asCGFloat ?? 4	// minimal distance above

										// DOMINATED CONNECTION? (e.g. with no Link):
			if inMePort.con2?.port === fixedPort ||
			   inMePort.dominant ||  inMePort.con2!.port!.dominant ||
			  fixedPort.dominant || fixedPort.con2!.port!.dominant
			{
				assert(weightSum==0, "Two positioning paths are both dominant\n" +
									 " 1. \(inMe.pp(.fullName))\n" +
									 " 2. \(lastDomIf2?.pp(.fullName) ?? "sdjsjvsjvjsd")")// not already dominated
				weightSum		= -1.0			// enter dominant mode
				gap				= vew.config("gapLinkDirect")?.asCGFloat ?? 0.1
				 // would like gap=-2, but overlap forces moveSoNoOverlapping
				lastDomIf2		= inMe
			}
			else if weightSum >= 0	{	// LINK CONNECTION:
				weightSum 		+= 1.0			// number of fixedP inMeP's
				// BUG: Move this to link!!!
				 // Gap: Fluff + extraGap
				let theLink		= inMePort.con2?.port?.parent as? Link
				for key in ["length", "len", "l"] {
					if let linksGap = theLink?.partConfig[key]?.asCGFloat {
						gap 	= linksGap
					}
				}
				 // Line type
				for key in ["type", "t"] {
					if let any  = theLink?.partConfig[key] {
						let str	= any as? String ?? "xxx"
						let dla = LinkSkinType(rawValue:str)
						assertWarn(dla != nil, "\(pp(.fullNameUidClass).field(-35)) linkSkinType:'\(any.pp())'")
						theLink!.linkSkinType = dla ?? .tube
					}
				}
			}
			else {
				panic("Second dominant Link con2 (\(fixedPort.pp(.fullName)) were found")
			}
			newInMePosn.y		+= gap
			atRsi(4, logd("\t\t\t\t" + "<<===== FOUND: p=\(newInMePosn.pp(.short)); "
						  + "\(vew.part.fullName).vew.bBox = (\(vew.bBox.pp(.line)))"))

			 // ////// Accumulate position: average for x,z; max for y
			avgPosition 		+= newInMePosn//* weightVect // bit by bit *
			if (!inMePOpensUpIC) {	 		// keep track of highest downward
				maxPositionY 	= max(maxPositionY, newInMePosn.y)// (except height is max)
			}
			return nil						// ALWAYS FAIL, keep going thru ports in self
		} )													//## BLOCK
		 // ///////////////////////////////////////////////////////////////////
		  // /////         END OF SCANNING ALL PARTS INSIDE            ///////
		   // ///////////////////////////////////////////////////////////////

		guard !maxPositionY.isInfinite else {									//guard weightSum > 0 && !maxPositionY.isInfinite else {
			atRsi(4, print("\t\t ABORT: ============ FAILS link positioning: position unchanged"))
			return false														}

		// <N>:average of N, 0:nothing found, -1:dominated
		guard weightSum != 0 	else {		return false	}	// 0: no support connections
		if weightSum >= 0 {							// unless dominated
			avgPosition 		/=  weightSum		// take average
		}											// height calculation from max:
		avgPosition.y 			= maxPositionY		// height calculation from max:
		atRsi(4, vew.log("<<===== found position in parent \(avgPosition.pp(.line)) by Links (weightSum=\(weightSum))"))
		//atRsi(6, vew.log("    === childVew.bBox = ( \(vew.bBox.pp(.line)) )"))
		vew.scnRoot.position = avgPosition + (vew.jog ?? .zero)

		vew.moveSoNoOverlapping()					// MOVE UPWARD
		vew.orBBoxIntoParent()

		return true			// Success
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv		= ""
		switch mode {
		case .line:
			rv 					= super.pp(mode, aux)
			if aux.bool_("ppParam") {			// Ad Hoc: if printing Param's,
				return rv							// don't print extra
			}
			rv					+= bindings==nil ? "" : "bindings:\(bindings!.pp(.line, aux)) "
		case .tree:
			let ppDagOrder 		= aux.bool_("ppDagOrder")	// Print Ports early
			let reverseOrder	= ppDagOrder && (upInWorld ^^ printTopDown)

			 // Compute the number of lines in this Atom
			let n				= !ppDagOrder ? 0 :			// !dag --> never mark
								  children.count + 1		// includes ports
			nLinesLeft			= UInt8(fwAny:n) ?? 255

			if !ppDagOrder {	// Array Order:
				rv				+= printPorts(aux, early:true)
				rv				+= ppSelf(	  aux)
				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:false)
				rv				+= printPorts(aux, early:false)
			}
			else {				// Dag Order:
				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:false)
				rv				+= printPorts(aux, early:true)
				rv				+= ppSelf(	  aux)
				rv				+= printPorts(aux, early:false)
			}
		default:
			return super.pp(mode, aux)
		}
		return rv
	}
	 // MARK: - 17. Debugging Aids
	override var description	  : String 	{	return  "d'\(pp(.short))'"		}
	override var debugDescription : String	{	return "dd'\(pp(.short))'"		}
	override var summary		  : String	{	return  "s'\(pp(.short))'"		}
}

