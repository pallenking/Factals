//  Port.swift -- Two Ports connect Atoms bidirectionally C2018PAK

import SwiftUI
import SceneKit
/* *********************** _IN_ATOM_ Usage:
										   *-origin	(at top of Port
	^ opensUp = true			 		__/ \__
	| FLIPPED			 		Port:  / L		\
	  (flipped = true)			   ===== top of Atom ====
								 ((		   				 ))
								 ((		   Atom			 ))
								 ((		   				 ))
								   == bottom of Atom ====
	| opensUp = false			Port:  \__   L_/
	v UNFLIPPED	 						  \ /
	  (flipped = false)					   *-origin (at bottom of Port)

 ***********************  _DATA_PASSING_ (up and down)
 							  (( Atom's Computation  ))
			 	INPUT		  ((	INPUT    OUTPUT  ))		OUTPUT
	Atom	 	^	v		  ((	\^^^/    \vvv/   ))		   |
				|	|		    \	 \^/      \v/   /		   v
				|	|		     |	  ^	     |PREV,|	  take(value:)
	 Port		|	|		     |____|______|VALUE| 	  getValues()
		 		|	|			      |   \ /   |   		 ^-->-v
		 		|	|			     /|\   V    |			 |	  |
				| con2				  |	   | 	|			con2  |
				|   |				  |    A   \|/			 |	  |
				^___v			  ____|___/ \___|__ 		 |	  |
	 Port	 getValue() 		 |VALUE|		|  |		 |	  |
			 take(value:)   	 |,PREV|		A  |		 |	  |
	 			  ^				/	 /^\	   /v\  \  		 ^	  v
	Atom		OUTPUT		  ((	/^^^\	  /vvv\	 ))		 INPUT

  ********************* _VISUAL_ Form:
	flipped	= false					 |    Port   |
	opensUp	= false					 '----   ----'
										  \ /
										   *--- origin (marked as truncated cone)
 */


 /// Defines port protocol for both 1-bit Ports and named MultiPort's
protocol PortTalk {

	  /// - Receives values set by the far Port
	 /// - Parameter value: ---- to set in
	/// - Parameter key: ---- nil if regular Port, sub-name if Multi-Port
	func take(value : Float, key:String?)			// sets value, usually in self

	 /// Read value from other, advancing previous value after get
	/// - Parameter key: --- if MultiPort, Port's name else nil
	func valueChanged(key:String?) -> Bool

	  /// Get new value, save current as prev .:. it's set to unchanged
	 /// * N.B: "getter" with side effect! 
	/// - Parameter key: --- if MultiPort, Port's name else nil
	func getValue(key:String?) -> Float				// get current value

	  /// Get new value and previous one, save current as prev .:. it's set to unchanged
	 /// * N.B: "getter" with side effect! 
	/// - Parameter key: --- if MultiPort, Port's name else nil
	func getValues(key:String?) -> (Float, Float)	// get (current value, previous value)
}

class Port : Part, PortTalk {

	 // MARK: - 2. Object Variables:
	  // MARK: - 2.1 ACTIVATION LEVELS
	 // ////////////////////////////////////////////////////////////////////////
	/*	210118PAK:
	Asynchronoush changes to model do not update value in inspector.
	No redraw. Redraw from another button does update it.
	*/

	var value 		: Float	= 0.0
	{	didSet {	if value != oldValue {
						markTree(dirty:.paint)							}	}	}
	var valuePrev	: Float	= 0.0
	{	didSet {	if valuePrev != oldValue {
						markTree(dirty:.paint)							}	}	}

	func take(value newValue:Float, key:String?=nil) {
		assert(key==nil,		"Key mode only supported on MPort, not on Port"	)
		assert(!newValue.isNaN,		"Setting Port value with NAN"				)
		assert(!newValue.isInfinite, "Setting Port value with INF"				)

		 // set our value.  (Usually done from self)
		if value != newValue {
			atDat(3, logd("<------' %.2f (was %.2f)", newValue, self.value))
			 //*******//
			value 				= newValue
			 //*******//
			markTree(dirty:.paint)					// repaint myself
			con2?.port?.markTree(dirty:.paint)// repaint my other too
			partBase?.factalsModel?.simulator.startChits = 4			// start simulator after Port value changes
//			partBase!.simulator.startChits = 4			// start simulator after Port value changes
		}
	}
	func valueChanged(key:String?=nil) -> Bool {
		assert(key==nil, "key mode not supported")
		return valuePrev != value
	}
	   /// get new value, save current as prev .:. it's set to unchanged
	  /// - N.B: getter with side effect!
	func getValue(key:String?=nil) -> Float {
		assert(key==nil, "key mode not supported")
		if valueChanged() {
			atDat(3, logd(">------. %.2f (was %.2f)", value, valuePrev))
		}
		 // mark value taken
		if valuePrev != value {			// Only do this on a change, so debug easier
			valuePrev 			= value		// returning the inValue promotes it to the previous
		}
		return value
	}
	   /// get new value, save current as prev .:. it's set to unchanged
	  /// - N.B: getter with side effect!
	func getValues(key:String?=nil) -> (Float, Float) {
		assert(key==nil, "key mode not supported")
		if valueChanged() {
			atDat(3, logd(">------. %.2f (was %.2f)", value, valuePrev))
		}
		 // mark value taken
		let prevValuePrev 		= valuePrev
		valuePrev 				= value// returning the inValue promotes it to the previous
		return (value, prevValuePrev)
	}
	 // Design Note: uses [()->String]: efficient, allows count or
	override func portChitArray() -> [()->String] {
		let portChanged			= self.con2 != nil &&			// Connected Port
								  self.value != self.valuePrev	// and Value changed
		return !portChanged ? [] :
				[{ "\(self.fullName)," }]
//				[{ fmt("\(self.fullName)%.2f->%.2f, ", self.value, self.valuePrev) }]
	}

	 // maintain consistent with Atom's ports[]
	override var name		: String {
		get {
			let name			= super.name			// get Part's name
			return name
		}
		set(newName) {
			if var ports		= atom?.ports {			// Set Atom's ports:[String:Port]
				let oldName		= super.name
				let oldName2	= ports.first { $1===self }?.key
				assert(oldName == oldName2, "inconsistency")
				ports.removeValue(forKey:oldName)		// remove from old hash
				ports[newName]	= self					// add    to   new hash
//													let x =  ports.first { (name, port) in port===self }?.value ?? self
//													let x2 = x.value
//													let oldName2 = ports.first { $1===self }?.key
//											//		let (oldName2, _) = ports.first { (name, port) in port===self } ?? ("", self)
//									//				let (oldName2, _) = p.first(where: { $1 === self }) ?? ("", self)
			}
			super.name			= newName				 // Set name
		}
	}
	override var fullName	: String {
		return (parent?.fullName ?? "") + "." + name
	}

	 // MARK: - 2.2 Connections:
	enum Con2 : Codable, Equatable {
		case port(Port)				// direct Port-Port
		case string(String)			// symbolic

		static func == (lhs: Port.Con2, rhs: Port.Con2) -> Bool {
			switch lhs {
			case .port(let lhsPort):
				switch rhs {
				case .port(let rhsPort):
					return lhsPort === rhsPort
				case .string(let rhsString):
					return lhsPort.fullName == rhsString
				}
			case .string(let lhsString):
				return lhsString == rhs.string
			}
		}
		 // Accessors, to simplify accessor readability
		var port : Port? {
			if case .port(let port_) = self 		{ return port_				}
			return nil
		}
		var string : String? {
			if case .string(let string_) = self 	{ return string_			}
			return nil
		}
	}

	var con2 : Con2? = nil
	func connect(to:Port) {
		let assertString 		= con2?.port?.pp(.fullName) ?? ""
		assert(self.con2==nil, "Port '\(pp(.fullName))' "	+ "already connected to \(assertString)")
		assert(  to.con2==nil, "'\(assertString)' "		+ "FAILS; the latter is already connected to '\(assertString)'")
		self.con2 				= .port(to)
		to.con2					= .port(self)
	}

	 // MARK: - 2.3 Con2 Properties:
	var noCheck					= false			// don't check up/down
	var dominant				= false 		// dominant in positioning

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		 /// Flipped
		if let portProp 		= config["portProp"] as? String {
			flipped				^^=  portProp.contains(substring:"f")
		}				// f:1 ^^ portProp:"xx f yy"
		 /// Illegal on Port
		assert(config["jog"]==nil,   "Jog not allowed on Ports")
		assert(config["spin"]==nil, "Spin not allowed on Ports")
	}

	 // MARK: - 3.5 Codable
	enum PortsKeys: String, CodingKey {
		case valuePrev
		case value
		case connectedTo
		case connectedX
		case noCheck
		case dominant
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:PortsKeys.self)

		try container.encode(value,		forKey:.value)
		try container.encode(valuePrev,	forKey:.valuePrev)
		assert(con2 == nil, "Port.connectedTo is not nil")//try container.encode(connectedTo,forKey:.connectedTo)
		try container.encode(con2, 		forKey:.connectedX)
		try container.encode(noCheck,	forKey:.noCheck)
		try container.encode(dominant,	forKey:.dominant)

		atSer(3, logd("Encoded  as? Port        '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:PortsKeys.self)

		value 					= try container.decode(  Float.self, forKey:.value)
		valuePrev				= try container.decode(  Float.self, forKey:.valuePrev)
		con2					= try container.decode(Con2?.self, forKey:.connectedX)
		noCheck 				= try container.decode(   Bool.self, forKey:.noCheck)
		dominant				= try container.decode(   Bool.self, forKey:.dominant)

		let msg					= "value:\(value.pp(.line))," 				+
							 	  "valuePrev:\(valuePrev.pp(.line)), " 		+
								  "conTo:\(con2?.port?.fullName ?? "xxq8ahx")"
		atSer(3, logd("Decoded  as? Port       \(msg)"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : Port		= super.copy(with:zone) as! Port
//		theCopy.value			= self.value
//		theCopy.valuePrev		= self.valuePrev
//		theCopy.connectedTo		= self.connectedTo
//		theCopy.connectedX = self.connectedX
//		theCopy.noCheck			= self.noCheck
//		theCopy.dominant		= self.dominant
//		atSer(3, logd("copy(with as? Actor       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 								else { return true		}
		guard let rhs			= rhs as? Port 			else { return false		}
		guard super.equalsFW(rhs)						else { return false		}
		guard value     		== rhs.value			else { return false		}
		guard con2 		== rhs.con2 		else { return false		}
		guard noCheck			== rhs.noCheck			else { return false		}
		guard dominant			== rhs.dominant			else { return false		}
		return true
	}
	 // MARK: - 4.4 Navigation
	var atom 		: Atom? {	return parent as? Atom 							}
	var otherPort 	: Port? {	 // Assumes Atom has 2 Ports, named P and Q
		if let myLink			= parent as? Link,
			myLink.ports[name] === self,
			let otherName : String? = name == "P" ? "S" : name == "S" ? "P" : nil {
				return myLink.ports[otherName!]!
		}
		return nil
	}
	 /// Return the first Port connected to non-link, starting at this one.
	var portPastLinks : Port? {		
		var scan : Port?		= self				  // ATOM]o - o[P1 link P2]o - o[
		while let p1Port		= scan?.con2?.port, 	 // self-^		     self-^ rv-^
		  p1Port.parent is Link {
			scan 				= p1Port.otherPort
		}
		return scan?.con2?.port
	}

	   /// Return the first Port connected to non-link, starting at this one.
	  /// - Parameter rv: A string describing the links traversed: e.g: "->b->c"
	 /// - Returns: The Port found
	func portPastLinksPp(ppStr rv:inout String) -> Port {
		 // Trace out Links, till some non-Link (including nil) is found
		var scan :Port			= self		      //scan]o -- o[P1 link P2]o -- o[
		while let scan2Port		= scan.con2?.port,	  // -------'     /     /|\
		  let link				= scan2Port.parent as? Link {   // --------'       |
			scan				= scan2Port.otherPort ?? {       // scan----------'
				fatalError("Malformed Link: could not find otherPort")			}()
			let linkPName 		= scan2Port.name
			let linkName 		= link.name
			rv		 			+= " ->\(linkName).\(linkPName)"
		}
		return scan
	}
	   // MARK: - 4.8 Matches Path
	override func partMatching(path:Path) -> Part? {

		 // Port name matches
		guard path.portName == nil ||			// portName specified in Path?
		   path.portName! == name else {		  // matches?
			return nil								// no, mismatch
		}
		 // Is Port known to Atom, with portName?
		if let atom				= parent as? Atom {
			 // Path has portName
			if let pathPortName	= path.portName {
				 // Is registered in atom's ports?
				if atom.ports[pathPortName] != nil {
				}									// registered in ports
				 // Port is defined in bindings
				else if let bindingName = atom.bindings?[pathPortName] {// is in bindings:
					let bindingPath	= Path(withName:bindingName)	// Path for binding
					if find(path:bindingPath) == nil {				// exists in self
						return nil
					}
				}else{	// Port is unknown
					return nil
				}
			}
			let atomPath		= path 			// make a path for Atom
			atomPath.portName 	= nil			// ignore
			if atom.partMatching(path:atomPath) != nil {
				return self
			}
		}
		return nil								// failed test
	}
	  
	//	- -	- -	BBox+-------------------------------+ - - - - CenterYTop
	//				|								|
	//				|   <origin> .					|
	//			   	|			  \					|
	//				|		      <center>			|
	//				| KEEPOUT	     | radius		|
	//	- - - - - -	+-------.        | 		  .-----+ - - - - CenterYBottom
	//				 GO-ZONE \ 		 |		 /__
	//						  --__   |   __--|\
	//							  ---^---		\
	//											  \		  (PRESUMES flipped	= false,
	//						   O P E N I N G    Link\ 				opensUp	= false)
	//
	 /// Con2 Spot
	 /// - All in my Atom's (parent's) coordinate systems:
	struct ConSpot {			// 	
		var center  : SCNVector3	// link aims toward center
		var radius  : CGFloat		// link end stays this distance from center
		var exclude : BBox?			// link end must not stop inside this bBox
		init(center:SCNVector3 = .zero, radius:CGFloat=0, exclude:BBox?=nil) {
			self.center			= center
			self.radius			= radius
			self.exclude		= exclude
		}
		mutating func convertToParent(vew:inout Vew) {
			 // Move v (and rv) to v's parent
			let t				= vew.scnRoot.transform	// my position in parent
			center				= t * center
			radius				= abs((t * .uY * radius).y)
			exclude				= exclude==nil ? vew.bBox * t :
								  exclude! * t | vew.bBox * t
	//		 // HIghest part self is a part of..
	//		let hiPart  		= ancestorThats(childOf:commonVew.part)!
	//		let hiVew 			= commonVew.find(part:hiPart)!					//, maxLevel:1??
	//		let hiBBoxInCom		= hiVew.bBox * hiVew.scnScene.transform
			vew					= vew.parent!
			atRsi(8, vew.log("--A-- rv:\(pp(inVew:vew)) after t:\(t.pp(.short))"))
		}
	 	// MARK: - 15. PrettyPrint
		func pp(inVew:Vew?=nil, _ aux:FwConfig = [:]) -> String {
			let wpStr			= !aux.string_("ppViewOptions").contains("W") ? "" : {		// World position
				guard let vb	= inVew?.vewBase() else { return "root of inVew bad" }
				return "w" + inVew!.scnRoot.convertPosition(center, to:vb.scnBase.roots?.rootNode).pp(.short, aux) + " "
			} ()
			return fmt("c:\(center.pp(.short, aux)), r:%.3f, e:\(exclude?.pp(.short, aux) ?? "nil")", radius)
		}
		var description	  	 	: String	{	return "d'\(pp())'"				}
		var debugDescription 	: String	{	return "e'\(pp())'"				}
		var summary		 	 	: String	{	return "s'\(pp())'"				}
	
		static let zero 		= ConSpot()
		static let nan	 		= ConSpot(center:.nan)
		static let atomic 		= ConSpot(radius:Part.atomicRadius)
	}

	  /// The con2 spot of a Port, in it's coordinates (not it's parent Atom's nay more 20200810)
	 /// (Highly overriden)
	func basicConSpot() -> ConSpot {
		return ConSpot(center:.zero, radius:0)
//		return ConSpot(center:SCNVector3(0, -radius, 0), radius:0)
	}
	 /// Convert self.portConSpot to inVew
	func portConSpot(inVew vew:Vew) -> ConSpot {
		let aux					= params4partPp				//log.params4aux
		guard var openParent	= parent else {	fatalError("portConSpot: Port with nil parent")	}
		atRsi(8, openParent.logd("---------- \(vew.pp(.fullName)).portConSpotNEW"))

		  // H: SeLF, ViEW, World Position, ConSpot
		 // If atomized, up for a visible Vew:
		var rv	: ConSpot		= basicConSpot()	// in parent's coords
		// :H: find VEW where ConSpot VISible		// Is it inside of openParent
		var csVisVew : Vew?		= vew.find(part:self, inMe2:true)					//openParent
		while csVisVew == nil, 						// we have no Vew yet
			  let p				= openParent.parent {// but we do have a parent
			atRsi(8, openParent.logd(" not in Vew! (rv = [\(rv.pp(aux))]) See if parent '\(p.fullName)' has Vew"))
			// Move to parent if Vew for slf is not currently being viewed;;;;;;;
			openParent			= p
			csVisVew			= vew.find(part:openParent, inMe2:true)
			rv					= .zero
		}
		guard let csVisVew else {
			panic("No Vew could be found for Part \(self.fullName)) in its parents")
			return rv
		}
		// ---- Now rv contain's self's portConSpot in conSpotsVew ----
		
		var worldPosn			= ""
		let enaPpWorld			= aux.string_("ppViewOptions").contains("W")
		if let scnScene			= vew.vewBase()?.scnBase.roots, enaPpWorld {
			worldPosn			= "w" + csVisVew.scnRoot.convertPosition(rv.center, to:nil/*scnRoot*/).pp(.short, aux) + " "
		}	// ^-- BAD worldPosn	String	"w[ 0.0 0.9] "
		atRsi(8, csVisVew.log("INPUT spot=[\(rv.pp(aux))] \(worldPosn). OUTPUT to '\(vew.pp(.fullName, aux))'"))

		  // Move openVew (and rv) to its parent, hopefully finding refVew along the way:
		 //
		guard let scnScene		= csVisVew.vewBase()?.scnBase.roots else {return rv}
		for openVew in csVisVew.selfNParents {								// while openVew != vew {
			guard openVew != vew else 	{				break					}
			let scn				= openVew.scnRoot
			let activeScn		= scn.physicsBody==nil ? scn : scn.presentation

			 // Update rv by :H: Local TRANSformation, from self to parent:
			let lTrans			= activeScn.transform
			rv.center			= lTrans * rv.center					// (SCNVector3)
			rv.radius			= length(lTrans.m3x3 * .uY) * rv.radius	// might be scaling
			rv.exclude			= rv.exclude==nil ? openVew.bBox * lTrans :
								 (rv.exclude! * lTrans | openVew.bBox * lTrans)
//			 // HIghest part self is a part of..	From Long Ago...
//			let hiPart  		= ancestorThats(childOf:openVew.part)!			// commonVew
//			let hiVew 			= openVew.find(part:hiPart)!					// commonVew
//			let hiBBoxInCom		= hiVew.bBox * hiVew.scnScene.transform

			let openWPosn		= openVew.scnRoot.convertPosition(rv.center, to:nil/*scnScene*/).pp(.short, aux)
			let wpStr 			= !enaPpWorld ? "" :  "w\\(openWPosn) "
			atRsi(8, openVew.log("  now spot=[\(rv.pp(aux))] \(wpStr) (after \(lTrans.pp(.phrase)))"))
		}
		return rv
	}
//	func portConSpotOLD(inVew vew:Vew) -> ConSpot {
//		guard var openParent	= parent else {	fatalError("portConSpot: Port with nil parent")	}
//		var rv	: ConSpot		= basicConSpot()		// in parent's coords
//		let aux					= params4partPp				//log.params4aux
//print("---------- portConSpotOLD")
//		// H: SeLF, ViEW, World Position
//		// AVew will not exist when it (and its parents) are atomized.
//		// Search upward thru its parents for a visible Vew
//		var openVew : Vew?		= vew.find(part:openParent, inMe2:true)
//		while openVew == nil, 						// we have no Vew yet
//			  let p		= openParent.parent {	// but we do have a parent
//			atRsi(8, openParent.logd(" not in Vew! (rv = [\(rv.pp(aux))]) See if parent '\(p.fullName)' has Vew"))
//			// Move to parent if Vew for slf is not currently being viewed;;;;;;;
//			openParent			= p
//			openVew				= vew.find(part:openParent, inMe2:true)
//			rv					= .zero
//		}
//		guard var openVew : Vew else {
//			panic("No Vew could be found for Part \(self.fullName)) in its parents")
//			return rv
//		}
//		// Now rv contain's self's portConSpot, in aVew
//		let enaPpWorld			= aux.string_("ppViewOptions").contains("W")
//		
//		var worldPosn			= ""
//		if let rootScn			= vew.vewBase()?.scnScene, enaPpWorld {
//			worldPosn			= "w" + openVew.scnScene.convertPosition(rv.center, to:rootScn).pp(.short, aux) + " "
//		}	// ^-- BAD worldPosn	String	"w[ 0.0 0.9] "	
////		var worldPosn			= !enaPpWorld ? "" :
////			"w" + openVew.scn.convertPosition(rv.center, to:rootScn).pp(.short, aux) + " "
//		atRsi(8, openVew.log("INPUT spot=[\(rv.pp(aux))] \(worldPosn). OUTPUT to '\(vew.pp(.fullName, aux))'"))
//
//		  // Move vew (and rv) to vew's parent, hopefully finding refVew along the way:
//		 //
//		let rootScn				= openVew.vewBase()!.scnScene
//		while openVew != vew {
//			 // my position in parent
//			let scnScene				= openVew.scnScene
//			let activeScn		= scnScene.physicsBody==nil ? scnScene : scnScene.presentation
//			let t				= activeScn.transform
//			rv.center			= t * rv.center						// (SCNVector3)
//			rv.radius			= length(t.m3x3 * .uY) * rv.radius	// might be scaling
//			rv.exclude			= rv.exclude==nil ? openVew.bBox * t :
//								 (rv.exclude! * t | openVew.bBox * t)
//			let wpStr 			= !enaPpWorld ? "" :
//								  "w" + openVew.scnScene.convertPosition(rv.center, to:rootScn).pp(.short, aux) + " "
//			guard openVew.parent != nil else {				break				}
//
//			// // HIghest part self is a part of..	From Long Ago...
//			//let hiPart  			= ancestorThats(childOf:commonVew.part)!
//			//let hiVew 			= commonVew.find(part:hiPart)!
//			//let hiBBoxInCom		= hiVew.bBox * hiVew.scnScene.transform
//			openVew					= openVew.parent!
//			atRsi(8, openVew.log("  now spot=[\(rv.pp(aux))] \(wpStr) (after \(t.pp(.phrase)))"))
//		} //while openVew != inVew			// we have not found desired Vew
//		return rv
//	}

	   /// Find the Peak Spot of me (my Vew) in vew
	  /// - Parameter inVew: -- coordinate system of returned point
	 /// - Returns: Point to connect to
	/// :H: InCommon
	func peakSpot(inVew vew:Vew, openingUp:Bool) -> SCNVector3 {
																				//bool dn = (openingUp =) [self downInPart:commonView.part];
		assert(vew.part !== self, "Vew must contain self's Vew, not be it")
		let spotIC				= portConSpot(inVew:vew)					//Hotspot hs = [self hotspotOfPortInView:commonView];
		var rv					= spotIC.center
		let exclude				= spotIC.exclude
		if openingUp {		// want largest upper value:
			rv.y				+= spotIC.radius	// assume straight up
			rv.y				= max(rv.y, exclude?.max.y ?? rv.y)	// Exclude zone too?
		} else {				// want smallest lower value:
			rv.y				-= spotIC.radius	// assume straight down
			rv.y				= min(rv.y, exclude?.min.y ?? rv.y) // Exclude zone too?
		}
		atRsi(8, vew.log("rv:\(rv.pp(.short)) returns peakSpot"))
		return rv
	}

	 // MARK: - 8. Reenactment Simulator
	override func reset() {											super.reset()
		value					= 0.0
	}
	 // no specific action required for Ports:
	override func simulate(up upLocal:Bool) {									}

	  // MARK: - 9.1 reVew
	override func reVew(vew:Vew?, parentVew:Vew?) {
		let vew					= vew							// 1. vew specified
					?? parentVew?.find(part:self, maxLevel:1)	// 2. vew in parent:
					?? addNewVew(in:parentVew)!					// 3. vew created
		assert(vew.part === self, "sanity check")// "=="?
		assert(vew.expose != .invis,  "Invisible not supported!")//atomic//invis//
		markTree(dirty:.size)					// needed ??
		vew.keep				= true				// Mark it's done:
	}

	 // MARK: - 9.3 reSkin
	var height : CGFloat	{ return 1.0	}//1.0  //0.5//0.01//0.5//1.0//2.0//4.0//
	var radius : CGFloat	{ return 1.0	}

	override func reSkin(fullOnto vew:Vew) -> BBox  {		// Ports and Shares
		let scn : SCNNode		= vew.scnRoot.find(name:"s-Port")
								?? newPortSkin(vew:vew, skinName:"s-Port")
		let bbox 			 	= scn.bBox()
		return bbox * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
	func newPortSkin(vew:Vew, skinName:String) -> SCNNode {
		assert(!(parent is Link), "paranoia")
		if parent is Link {			// UGLY
			let rv				= SCNNode(geometry:SCNSphere(radius:0.1))		// the Ports of Links are invisible
			rv.name				= skinName
			rv.color0 			= NSColor("lightpink")!//.green"darkred"
			vew.scnRoot.addChild(node:rv)
			return rv
		}
		let r					= radius
		let h0:CGFloat			= 0.04
		let h					= height
		let h2					= height * 0.5
		let ep :CGFloat 		= 0.002

		 // Origin is at bottom, where con2 point is // All below origin
	/*								   spin axis
	Disc        _________________________________________________________
	Tube	 B |_|						 \ | /						   |_|
	Cone 								A \|/
										   + Parent's Origin:

				 scnDisc:Disc		scnCone:Cone					scnTube:Tube
		-h0/2-ep   ep  		  		    ep							  ep/2
			.->+  .-->.<PORT......\.......-->....../	  .->+		 .-->...
			|  '->+.h0..SKIN....+======= | =============* |	 |h2/2-ep|..^...
		h	|	  '-->..ORIGIN>.|...\....|.^...../		| |	 v------>+ h2/2-ep
			| 		 			|  .---->+h-2*ep		| |		x	 |..v...
			|					|  |  \..|.v.../		| |			 '-->...
	 <VIEW's|		   -scnDiskY|  |h/2\.|..../-scnDiskY| |+h
	 ORIGIN>+					'->+	\'-+>/			v-*
	 */
		
		let geom				= SCNCylinder(radius: 0.9*r, height:h0)	// elim tear with ring
		let scnDisc				= SCNNode(geometry:geom)
		scnDisc.name			= skinName
		vew.scnRoot.addChild(node:scnDisc)
		let scnDiskY			= h - h0/2 - ep		// top is at h
		scnDisc.position.y 		= scnDiskY
		scnDisc.color0 			= NSColor("lightpink")!//.green"darkred"

		 // A: Cone's tip marks con2 point:
		let geomCone			= SCNCone(topRadius:r/2, bottomRadius:r/5, height:h-2*ep)
		let scnCone 			= SCNNode(geometry:geomCone)
		scnDisc.addChild(node:scnCone, atIndex:0)
		scnCone.name			= "s-Cone"
		scnCone.position.y 		= h/2 - scnDiskY - ep/2
		scnCone.color0			= NSColor.black

		 // B: Tube visible from afar:
		let geomTube			= SCNTube(innerRadius: 0.8*r, outerRadius:r, height:h2-ep)
		let scnTube				= SCNNode(geometry:geomTube)
		scnDisc.addChild(node:scnTube, atIndex:0)
		scnTube.name			= "s-Tube"
		scnTube.position.y 		= h - scnDiskY - h2/2 - ep
		scnTube.color0			= NSColor.blue

		 // C: 3D Origin Mark (for debug)
		let scnOrigin			= originMark(size:0.5, partBase:partBase!)
		scnOrigin.color0 		= NSColor.black
		scnOrigin.position.y 	= -scnDiskY
		scnOrigin.isHidden		= true
		scnDisc.addChild(node:scnOrigin)

		return scnDisc
	}
	 // MARK: - 9.2 reSize
	override func reSize(vew:Vew) {
		super.reSize(vew:vew)
//		panic("Port.reSize")
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(vew:Vew) {
bug;	(parent as? Atom)?.rePosition(portVew:vew)	// use my parent to reposition me (a Port)
		vew.scnRoot.transform = SCNMatrix4(0, -height/2, 0, flip:flipped)/// lone Port
	}
	 // MARK: - 9.5: RePaint:
	override func rePaint(vew:Vew) {
				// Tube with connectedTo's value:
		let tube				= vew.scnRoot.find(name:"s-Tube", maxLevel:2)
		let  curTubeColor0		= tube?.color0
		let     tubeColor0	 	= upInWorld ? NSColor.green : .red
		tube?.color0			= NSColor(mix:NSColor.whiteX, with:value, of:tubeColor0)
		if tube?.color0 != curTubeColor0 {
//			vew.scnScene.play(sound:value>0.5 ? "tick1" : "tock0")
		}
				// Cone with connectedTo's value:
		let cone				= vew.scnRoot.find(name:"s-Cone", maxLevel:2)
		if let valPort			= con2?.port {	//	GET to my INPUT
			let val				= valPort.value
			let coneColor0		= upInWorld ? NSColor.red : .green
			cone?.color0		= NSColor(mix:NSColor.whiteX, with:val, of:coneColor0)
		}
		else {	// Cone unconnected
			cone?.color0		= .black
		}
	}
	// MARK: -
	//static var alternate = 0
	static var colorOfBidirActivations : [NSColor] {[
			NSColor.white,		//	colorWhite,			// <all zero>
			NSColor.green,		//	colorGreen,			// have
			NSColor.red,		//	colorRed,			// want
			NSColor.black		//	colorBlack			// haveNwant
	]}
	func colorOfValue() -> NSColor {
		let rv					= self.color(ofValue:self.value)
		return rv;
	}
	func color(ofValue val:Float) -> NSColor {
		let downInWorld 		= self.downInWorld
		let index  				= downInWorld ?
					2: // 1 --> opening down --> Red   colorOfBidirActivations[2]
					1  // 0 --> opening up   --> Green colorOfBidirActivations[1]
		let on  				= Port.colorOfBidirActivations[index];
		let off					= Port.colorOfBidirActivations[0];

		return NSColor(mix:on, with:val, of:off)					//lerp(on, off, val);
	}

	func colorOf2Ports(localValUp:Float, localValDown:Float, downInWorld:Bool) -> NSColor {
		var localValUp			= localValUp  .isNan ?  0.0: localValUp;		// nan --> 0
		var localValDown		= localValDown.isNan ?  0.0: localValDown;

		 // AGC/ signal compression:  POOR PERFORMANCE
		let pMax				= max(localValUp, localValDown)
		if pMax > 1.0   {
			localValUp			/= pMax
			localValDown		/= pMax
		}
		
		let valUp				= downInWorld ? localValDown : localValUp
		let valDown				= downInWorld ? localValUp   : localValDown

		var color				= NSColor(0, 0, 0, 1)
		for i in 0..<4 {	// scan: -, s, d, sd
			let a				= i&1 != 0 ? valUp:   1.0 - valUp
			let b				= i&2 != 0 ? valDown: 1.0 - valDown
			let ab				= CGFloat(a * b)
			let cc				= Port.colorOfBidirActivations[i]
			color				= NSColor(
				red:   color.redComponent   + cc.redComponent   * ab,
				green: color.greenComponent + cc.greenComponent * ab,
				blue:  color.blueComponent  + cc.blueComponent  * ab,
				alpha: 1)//color.alphaComponent + cc.alphaComponent * ab)
		}
		return color;
	}




	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .fullName:						// -> .name
			return (parent?.pp(.fullName, aux) ?? "") + "." + name
		case .phrase, .short:
			return self.pp(.fullNameUidClass, aux)
		case .line:
			// e.g: "Ff| |/            P:Port  . . . o| <0.00> -> /prt4/prt2/t1.s0
			var rv				= ppUid(self, post:" ", aux:aux)
			rv					+= (upInWorld ? "F" : " ") + (flipped ? "f" : " ")
			rv 					+= log.indentString(minus:1)
			//rv  				+= root?.factalsModel?.log.indentString(minus:1) ?? ";;"
			rv					+= self.upInWorld 	? 	"|/   " :
								   						"|\\   "
			rv					+= ppCenterPart(aux)	// adds "name;class<unindent><Expose><ramId>"
			if aux.bool_("ppParam") {		// when printing parameters
				return rv						// stop normal stuff
			}
			rv 					+=  ppPortOutValues() + ">"

			  // Print out the non-Link:
			 // If we are connected to anything, what is it sending to us?
			guard let con2 		else { return rv + " unconnected"				}
			switch con2 {
			case .port(let con2Port):
				rv 				+= "<" + con2Port.ppPortOutValues()		// e.g. <1.00/0.00
				let scPort		= portPastLinksPp(ppStr:&rv)
				guard let sc2Port = scPort.con2?.port else { return rv + " No connect Port"	}
				rv 				+= " -> \(sc2Port.fullName)"
			case .string(let con2string):
				rv 				+= " -> \"\"\(con2string)\"\""
			}
			return rv
		default:
			return super.pp(mode, aux)
		}
	}
	func ppPortOutValues() -> String {		// return self.[prev]val
		let before 				= valuePrev ~== value ? "" : fmt("/%.2f", valuePrev)
		return fmt("%.2f%@", value, before)
	}

	 // MARK: - 16. Global Constants
	static let error			= Port()	// Should (?) print error if ever touched
	static let reservedPortNames = [ "P", "S", "T", "U", "B", "KIND", "share"]

	 // MARK: - 17. Debugging Aids
	override var description	  : String 	{	return  "d'\(pp(.short))'"		}
	override var debugDescription : String	{	return "dd'\(pp(.short))'"		}
	override var summary		  : String	{	return  "s'\(pp(.short))'"		}
}

class ParameterPort : Port {
// TODO: rename GlobalPort

}


