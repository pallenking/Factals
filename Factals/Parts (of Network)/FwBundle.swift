//  FwBundle.mm -- A hierarchical structure of Leafs, one per port C2013PAK

import SceneKit
/*
decorators
dynamicMemberLookup
 */

//       Atom :_Part
//          Net : Atom
//          Actor : Net

//       FwBundle :_Net				// A hierarchical structure of Leafs, one per port
//             Leaf : FwBundle		// Terminal element of a FwBundle
//           Tunnel : FwBundle		// Combines multiple Ports into one MultiPort
//           Bundle : FwBundle		// A hierarchical structure of Leafs, one per port

//  DiscreteTime??:Atom				// Connects HaveNWant analog time domain to discrete time

//      Generator : Net				// Generates stimulus for a HaveNWant network
//   WorldModel :_Atom				// Prototype discrete time world model
//  TimingChain : Atom				// Split analog time into Sample time
//   WorldModel : Atom				// A WorldModel ia a generic discrete time/value data source

//    BundleTap :_Atom				// an Atom which loads data into a Bundle
// ShaftBundleTap : BundleTap

//class Bundle : FwBundle {
//	init(_ tunnelConfig:FwConfig=[:], leafConfig:FwConfig=[:], trailingHash:(()->Part)? = nil) {
//		fatalError("can't do leaf closure with leafKind enum")
////		var  x			= trailingHash != nil ? .leafClosure(trailingHash!) : nil
////		super.init(tunnelConfig, leafConfig:leafConfig)
//	}
////	init(leafConfig:FwConfig=[:],
////			_ tunnelConfig:FwConfig=[:], trailingHash:(()->Part)? = nil) {
////	//	var  			= trailingHash == nil ? kind :
////	//						  .leafClosure(trailingHash!)
//	required init(from decoder: Decoder) throws {	debugger("unimplemented") }
//	required init?(coder: NSCoder) 				{	debugger("unimplemented") }
//}

 /// A FwBundle is a hierarchical structure of Leafs, one per port
class FwBundle : Net {

     // MARK: - 2. Object Variables:
//	var leafStruc: FwAny?			// structure of name-structure				// boneyard:var leafStruc: FwConfigC?;var leafProto: Part?
//	var leafKind : LeafKind			// an enum for structure's atoms
	var label 	 : String?			// Of pattern IN FwBundle

	 // MARK: - 3. Part Factory

//	init(_ tunnelConfig:FwConfig=[:], 		leafConfig:FwConfig=[:])	//FwBundle
//	{	//[f:0,struc:[2 elts],of:genBcast]	[]
//		let tunnelConfig/*2*/	= ["placeMy":"stackx"] + tunnelConfig
//		let leafConfig			= ["placeMy":"linky" ] + leafConfig		//  default: // was stackx
//		super.init(tunnelConfig/*2*/) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

	     /// Grouping of Leaf
	    /// - parameter kind: 		-- of terminal Leaf
	   /// - parameter leafConfig: -- to configure Leaf
	  /// - parameter config:	  -- to configure FwBundle
	 /// ## --- struc: names	 -- names of the Bundle's leafs
  	init(_ tc:FwConfig=[:], leafConfig lc:FwConfig=[:]) {			//FwBundle

		let tunnelConfig		= ["placeMy":"stackx"] + tc
		super.init(tunnelConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		 // Construct FwBundle elements
		if let  leafStruc 		= partConfig["struc"] {
			guard let partConfigOf	= partConfig["of"] else
			{	fatalError("What kind of Leafs? No 'of' key specified")								}

			var leafKind 		= partConfigOf as? LeafKind			// LeafKind is given
			if let lks			= partConfigOf as? String			// convert from String
			{	leafKind		= LeafKind(rawValue:lks) ??
				{	fatalError("LeafKind: '\(lks)' undefined")					}()
			}
			let leafConfig		= ["placeMy":"linky" ] + lc			// default
			apply(struc:leafStruc, of:leafKind ?? .genAtom, leafConfig:leafConfig)	// xyzzy342
		}																		//tunnelConfig=[struc:[1 elts],n:evi,placeMy:stackz 0 -1]
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String] {	super.hasPorts()	}	//return[:]//["P":"pcM"]//

	 // MARK: - 3.5 Codable
	enum BundleKeys:String, CodingKey {
		case leafStruc
		case label
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 		= encoder.container(keyedBy:BundleKeys.self)

	//	try container.encode(leafStruc,	forKey:.leafStruc)	//Protocol 'FwAny' as a type cannot conform to 'Encodable'
//		try container.encode(leafKind,	forKey:.leafKind)
		try container.encode(label, 	forKey:.label)
		logSer(3, "Encoded  as? FwBundle      '\(fullName)'")
	}
	  // Deserialize
	required init(from decoder: Decoder) throws {
//		leafKind			= .nil_		// WTF?
		try super.init(from:decoder)

		let container 		= try decoder.container(keyedBy:BundleKeys.self)
//		leafStruc			= try container.decode(String.self, forKey:.leafStruc)//No exact matches in call to instance method 'decode'
//		leafStruc			= try container.decode(leafStruc.self,forKey:.leafStruc)//No exact matches in call to instance method 'decode'
//		leafKind			= try container.decode(LeafKind.self, forKey:.leafKind)
		label	 			= try container.decode(String.self, forKey:.label)
		logSer(3, "Decoded  as? FwBundle     named  '\(name)'")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy			= super.copy(with:zone) as! FwBundle
//		theCopy.leafStruc 	= self.leafStruc
//		theCopy.leafKind 	= self.leafKind
//		theCopy.label 		= self.label
//		logSer(3, "copy(with as? FwBundle       '\(fullName)'")
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 						   else {	return true			}
		guard let rhs			= rhs as? FwBundle else {	return false 		}
		let rv					= super.equalsFW(rhs)
//								&& leafStruc == rhs.leafStruc	//Type 'any FwAny' cannot conform to 'Equatable'
//								&& leafKind  == rhs.leafKind
								&& label 	 == rhs.label
		return rv
	}
	   // /////////////////////////////////////////////////////////////////// //
	  // ///////////////// FwBundle Sub-Tree NAVIGATION ////////////////////// //
	 // /////////////////////////////////////////////////////////////////// //

	/* Specifying the elements, at current level:
	1. String										 // E.G:
		<leafSTR>		::= "<name>"				// <name>
						::= "<name>:<spin>"			// <spin> = (spin,R), ...
						::= "<name>:spin:<dir>"	// <dir> = L, R, ?
		<bunListDesc>	::= "spin:<dir>"|"s<dir>"  <dir> = L, R, 0,1,2...
	2. Array
			[<subSpec>, ...]				// apply each subSpec in Array to self
					properties:		-- strings that apply to the PARENT
										e.g. "spin:L" or "minSize":"3,3,3"
					subBundle 		-- from complex Bundles to simple Leafs
					constructors:	-- all valid strings are allowed
			e.g: a = ["name:foo", "spin:L", v1, v2]
				a is named foo,                 has left spin, and subBundles v1 and v2

	3. Hash
			{<specKey>:<specVal>,...]		// apply each pair in Hash to self
					keys k* 		-- strings naming the object <specVal>
					values v*		-- are as above.
			e.g: h = {"name":"foo2", "spin":"L", k2:v2}
				h has name foo2, spin left and subBundle v2 named k2

	4. FwBundle:		xx
	5. NULL
	 */

	/* Apply one specification/subSpecification to self
		- applyASpec:spec subSpec:subSpec
		:H: CONstructor SPECification

									FUNCTIONS

	spec:___________subSpec:_//___FUNCTION_PERFORMED___________EXAMPLE___________

	STRING:
	 "<propNval>"		  0	 // 1a self.PROP=VAL			// E.g: "minSize:3,4,5"
	 "<prop>"		   <val> // 1b self.PROP=VAL			// E.g: "minSize":"3,4,5"
	 "<prop>:<val>"		  0	 // 2A self.PROP=VAL			// E.g: "minSize:3,4,5"

	 "<name>"		   <spec>// 1c ADD(<spec>)				// E.g: "foo:"
	 "<name>:<prop>"   <val> // 2B ADD(factory[0]).PROP=VAL	// E.g: "foo:spin":"R"
	 "<name>:<propNval>"  0	 // 2c ADD(factory[0]).PROP=VAL	// E.g: "foo:spin_R"
	 "<name>:<i>"		  0	 // 2d ADD(factory[<i>]).PROP=VAL//E.g: "foo:1"
	 "<name>:<prop>:<val>"0	 // 3a ADD(factory[0]).PROP=VAL	// E.g: "foo:spin:

	If <name> is specified, a new is added so named. <prop>=<val> applies to it.
	If no <name>			  new is added			 <prop>=<val> applies to self.
	ARRAY					 // 4  PROCESS con's in array	// E.g: [con1, ..]
	HASH					 // 4  PROCESS key:con's in hash// E.g: {name1:con1, ...}
	BUNDLE					 // 5  ADD bundle				// E.g: (Leaf *)leaf
	 */
/*
xxx			func apply(struc:FwAny, of leafKind:LeafKind, leafConfig:FwConfig) { 		// xyzzy342
xxx			func apply(prop:String, withVal val:FwAny?) -> Bool {
xxx			func apply(struc:FwAny, of leafKind:LeafKind = .genAtom, arg:FwAny?=nil, leafConfig:FwConfig, _ sub1:FwConfig=[:], _ sub2:FwConfig=[:]) {
  */

	// MARK: - 4.1 Part Properties
	func apply(struc:FwAny, of leafKind:LeafKind, leafConfig:FwConfig) { 		// xyzzy342
		  // ==== Parse constructor:  It has many forms:
		logBld(7, "apply(struc:\(struc) of:'\(leafKind)'s leafConfig:\(leafConfig))")
		 // STRING:
		if struc is String {			/// Instantiate the leaf
			let newLeaf			= Leaf(["n":struc, "of":leafKind], leafConfig)
			addChild(newLeaf)
	//		apply(struc:struc, of:leafKind, leafConfig:leafConfig)				//, tunnelConfig)
		}
		  // HASH: apply each par of con to self (key->con; val->subSpec
		 // <key>=name of new element; <val>=kind of element
		else if let config = struc as? FwConfig{// Hash of name:kind
bug;		for (conKey, conValue) in config {		// paw through hash
				let newLeaf		= Leaf(["n":conKey, "of":leafKind], leafConfig)
 // what is conValue used for?
				addChild(newLeaf)
	//			apply(struc:conKey, arg:conValue, leafConfig:leafConfig)		//, tunnelConfig)
				// newElt		name		  constructor	prototypes
			}								//BUGGY:.name; = subSpecKey;
		}
		 // ARRAY: apply each element of con to self
		else if let strucArray = struc as? [FwAny] {// Array of constructors to apply to bundle
			for subStruc in strucArray {				// paw through array, build each
				apply(struc:subStruc, of:leafKind, leafConfig:leafConfig)		//, tunnelConfig)		//tunnelConfig=[struc:[1 elts],n:evi,placeMy:stackz 0 -1]
			}
		}
		 // BUNDLE (and Leaf):
		else if struc is FwBundle {
bug;		apply(struc:struc, leafConfig:leafConfig)							//, tunnelConfig)
		}
		 // NULL	 -- do nothing
		else if struc is NSNull {
bug;		nop // for break
		}
		else {
			panic("Apply(struc:'\(struc.pp(.tree))'...) not understood")	// 180903 WHY NOT JUST pp() ???
		}
	}
	override func apply(prop:String, withVal val:FwAny?) -> Bool {
		let copyKeys			= ["placeMy", "placeMe"]

		if copyKeys.contains(prop) {
			 // copy into bundle: DANGEROUS
			partConfig[prop]	= val
		}
		else {
			return super.apply(prop:prop, withVal:val)
		}
		return true
	}
								
	 // Apply a specification to ourselves to form leaves
	func apply(struc:FwAny, of leafKind:LeafKind = .genAtom, arg:FwAny?=nil, leafConfig:FwConfig, _ sub1:FwConfig=[:], _ sub2:FwConfig=[:]) {
		logBld(7, "apply(struc:\(struc.pp(.short)) of:\(leafKind.pp(.phrase)) arg:\(arg?.pp(.line) ?? "nil"))")
								
		   // Interpret << spec >>, making appropriate changes to self, a FwBundle
		  //
		 // Case 1: BUNDLE -- ready immediately				// E.g: leaf:Leaf
		if let spec1 = struc as? FwBundle {			// WHY HAVE THIS OPTION?
			addChild(spec1)									// silently reach inside and insert
		}
		 // Case 2: ARRAYs -- add all (recursively)// E.g: @[name1, ..], or @{name1:kind1, ...}
		else if let struc = struc as? Array<Any> {
			for elt in struc {
				let newElt		= FwBundle()				// Build a new FwBundle
				newElt.apply(struc:struc, leafConfig:leafConfig)//, tunnelConfig)
				addChild(newElt)
			}
		}
		 // Case 3: HASHs -- add all, recursively// E.g: @[name1, ..], or @{name1:kind1, ...}
		else if let struc = struc as? Dictionary<String,Any> {
			for (name, elt) in struc {
				let newElt		= FwBundle()				// Build a new FwBundle
				newElt.apply(struc:struc, leafConfig:leafConfig)//, tunnelConfig)
				addChild(newElt)
			}
		}
		 // Case 1: STRINGs -- rich semantics
		else if let specStr 	= struc as? String {
			typealias DelayedProperty = (Part) -> ()
			var newsProperty : DelayedProperty?	= nil	// to apply to new element
			 // Apply string constructor to newElt, either augment self or make new element below.
			let tokens : [String] = specStr.components(separatedBy:":")
			switch tokens.count {
				case 1:							// con1=tokens[0] subSpec
					 // Case 1.1a: -- token[0]:propNVal			   E.g: "minSize:3,4,5"
					if apply(propNVal:tokens[0]) {					// check no subSpec
						assert(arg==nil, "property \(specStr): Non-nil subSpec not supported")
					}
					 // Case 1.1b: -- token[0]:prop, subSpec:Val   E.g: "minSize":"3,4,5"
					else if arg != nil,
					  apply(prop:tokens[0], withVal:arg!) {
														// property -- no newElt
					}
					 // Case 1.1c: -- set name of new element	   E.g: "a" sets name
					else {
						newsProperty = { (p : Part) in
							p.name = tokens[0]
						}
					}
				case 2: 						// con1=tokens[0,..1]; subSpec
					let dummy 	= Net()								//;panic()//Leaf()
					  // Try each case, in succession:
					 // Case 1.2a: -- Try (0)prop : (1)val		    E.g: "minSize":"3,0,0"
					if apply(prop:tokens[0], withVal:tokens[1]) {
						assert(arg==nil, "property \(specStr) has non-nil subSpec") // no newElt
					}
					  // --- All decodings past here apply to the new bundle ---
					 // Case 1.2b: -- Try (0)name:(1)prop (s)val		// E.g: "<name>:minSize":"3,0,0"
					else if dummy.apply(prop:tokens[1], withVal:arg) {
						newsProperty = { (p : Part) in
							let _ = p.apply(prop:tokens[1], withVal:arg!)
							p.name = tokens[0]
						}
					}
					 // Case 1.2c: -- Try (0)name:(1)propNVa		 E.g: "<name>:sR"	// prop affects newbie
					else if dummy.apply(propNVal:tokens[1]) {
						newsProperty 		= { (p : Part) in
							let _ 			= p.apply(propNVal:tokens[1])
							p.name 			= tokens[0]
						}
					}
					 // Case 1.2d: -- (0)name : (1)number			  E.g: "name:1"	// number chooses prototype
					else if arg==nil && tokens[1].hasPrefix("@") {
						newsProperty = { (p : Part) in
							p.name = tokens[0]
						}
					}
					else {
						panic("\(fullName): unable to parse '\(specStr)' '\(arg?.pp(.tree) ?? "??")")
					}
				case 3:							// con1=tokens[0,..2]
					  // --- All decodings past here apply to the new bundle ---
					 // case 1.3: name : prop : val
					let dummy : Part = Leaf()
					if dummy.apply(prop:tokens[1], withVal:tokens[2]) {
						newsProperty = { (p : Part) in
							let _ = p.apply(prop:tokens[1], withVal:tokens[2])
							p.name = tokens[0]
						}
					}
					else {
						panic("\(fullName): unable to parse '\(specStr)' '\(arg?.pp(.tree) ?? "??")")
					}
				default:
					panic("\(fullName): unable to parse '\(specStr)' '\(arg?.pp(.tree) ?? "??")'")
			}
			   // Make a new element, per newsName
			  //    Copy the properties of decoder into the new element.
			 //
			if (newsProperty != nil) {
				 // CASE 1.4a: Make newElt from subSpec
				if arg is Array<FwAny> || arg is FwConfig
				{
					let newBun 	= FwBundle()			// Build a new FwBundle or Tunnel
					newsProperty!(newBun)				// Apply delayed property
					newBun.apply(struc:arg!, of:.genPrev, leafConfig:leafConfig)	//, tunnelConfig)// xyzzy342
					addChild(newBun)
				}
				 // CASE 1.4b: Get a new Leaf:
				else {
					//guard let leafKind else { fatalError() 						}
					let leafConfig		= leafConfig + ["leafKind":leafKind]
					let newLeaf	= Leaf(leafConfig, sub1)	//leafKind, //tunnelConfig=[struc:[1 elts], n:evi, placeMy:stackz 0 -1]
					addChild(newLeaf)
					newsProperty!(newLeaf)					// Apply delayed property to it

					   /// For the special case where newLaf contains just
					  /// 1 Port as child (no atom), add them to Leaf.ports
					 /// (More interior ports get generated and added in hasPorts())
					for nlChild in newLeaf.children { 
						if let nlPort = nlChild as? Port {
							if newLeaf.ports[nlPort.name]==nil {
								newLeaf.ports[nlPort.name] = nlPort
								nlPort.parent = newLeaf
							}
						}
					}
				}
			}
		}
		else {
			panic("Unknown FwBundle spec '\(struc.pp())'")
		}
	}

	  // MARK: - 4.5 Iterate (forAllLeafs)
	 typealias LeafOperation = (Leaf) -> ()
	 func forAllLeafs(_ leafOperation : LeafOperation)  {
		 for elt in children {
			 if let leaf = elt as? Leaf {		// ignore Ports and numbers
				 leafOperation(leaf)
				 leaf.forAllLeafs(leafOperation)
			 }
		 }
	 }

	// MARK: - 6. Navigation
	  // Find Port in targetBundle whose name is leafPathStr.
	 // Returns nil if Leaf not found, or if it has no "G" bindings
	func genPortOfLeafNamed(_ leafStr:String) -> Port? {
		var soughtLeaf:Leaf?	= nil
		forAllLeafs { leaf in
			if leaf.name == leafStr {
				soughtLeaf = leaf
			}
		}
		return soughtLeaf?.boundPort(named:"G")
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Bun") ?? {
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-Bun"
			return rv
		}()
		
		let gsnb				= vew.config("gapTerminalBlock")?.asCGFloat ?? 0.0
		let bb					= vew.bBox
		 // Green Ring at bottom:
		scn.geometry 			= SCN3DPictureframe(width:bb.size.x, length:bb.size.z, height:gsnb, step:gsnb)
		scn.color0				= NSColor("darkgreen")!
		scn.position			= bb.centerBottom //+ .uY * gsnb/2
		return bb						//view.scnScene.bBox() //scnScene.bBox() // Xyzzy44 ** bb
	}
	 // MARK: - 11. 3D Display
	override func typColor(ratio:Float) -> NSColor {
		let inside  			= NSColor(red:0.9, green:0.9, blue:1.0,  alpha:1)
		let outside 			= NSColor(red:0.8, green:0.8, blue:1.0,  alpha:1)
//		let inside				= NSColor{0.7, 0.7, 0.7,  1}
//		let outside				= NSColor{0.7, 0.7, 0.7,  1};
		return NSColor(mix:inside, with:ratio, of:outside)
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew:Vew) {
		 // Place 'ALL' Port specially: the tip of the funnel
		if portVew.part === ports["P"] {	//"ALL" is in bottom center
//		if portVew.part == ports["P"] {		//"ALL" is in bottom center
			let flip			= portVew.part.flipped
			let bBox			= portVew.bBox
			let place			= flip ? bBox.centerTop : bBox.centerBottom
			portVew.scn.transform = SCNMatrix4(place, flip:flip)
//			portVew.scn.transform = SCNMatarix4(portVew.bBox.centerBottom.x, 0, 0, flip:flip)
		}
		else {
			super.rePosition(portVew:portVew)
		}
	}
}
