//  FwBundle.mm -- A hierarchical structure of Leafs, one per port C2013PAK

import SceneKit

//       Atom :_Part
//          Net : Atom
//          Actor : Net

//       FwBundle :_Net				// A hierarchical structure of Leafs, one per port
//             Leaf : FwBundle		// Terminal element of a FwBundle
//           Tunnel : FwBundle		// Combines multiple Ports into one MultiPort
//           Bundle : FwBundle		// A hierarchical structure of Leafs, one per port

//  DiscreteTime : Atom				// Connects HaveNWant analog time domain to discrete time


//      Generator : Net				// Generates stimulus for a HaveNWant network
//   WorldModel :_Atom				// Prototype discrete time world model
//  TimingChain : Atom				// Split analog time into Sample time
//   WorldModel : Atom				// A WorldModel ia a generic discrete time/value data source

//    BundleTap :_Atom				// an Atom which loads data into a Bundle
// ShaftBundleTap : BundleTap

class Bundle : FwBundle {
	init(of kind:LeafKind = .genAtom,  leafConfig:FwConfig=[:],
			_ tunnelConfig:FwConfig=[:], trailingHash:(()->Part)? = nil) {
		var kind			= trailingHash == nil ? kind :
							  .leafClosure(trailingHash!)
		super.init(of:.leafClosure(trailingHash!), tunnelConfig:tunnelConfig, leafConfig)
	}
	required init(from decoder: Decoder) throws {	debugger("unimplemented") }
	required init?(coder: NSCoder) 				{	debugger("unimplemented") }
}

 /// A FwBundle is a hierarchical structure of Leafs, one per port
class FwBundle : Net {

     // MARK: - 2. Object Variables:
	var leafStruc: FwAny?			// structure of name-structure				// boneyard:var leafStruc: FwConfigC?;var leafProto: Part?
	var leafKind : LeafKind			// an enum
	var label 	 : String?			// Of pattern IN FwBundle

	 // MARK: - 3. Part Factory

	     /// Grouping of Leaf
	    /// - parameter kind: 		-- of terminal Leaf
	   /// - parameter leafConfig: -- to configure Leaf
	  /// - parameter config:	  -- to configure FwBundle
	 /// ## --- struc: names	 -- names of the Bundle's leafs
	init(of leafKind:LeafKind = .genAtom,  tunnelConfig:FwConfig=[:], _ leafConfig:FwConfig=[:])	//FwBundle
	{
		let leafConfig			= ["placeMy":"linky" ] + leafConfig		//  default: // was stackx
		let tunnelConfig/*2*/	= ["placeMy":"stackx"] + tunnelConfig
		self.leafKind			= leafKind
		super.init(tunnelConfig/*2*/) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		 // Construct FwBundle elements
		assert(partConfig["leafKind"]==nil, "use leafKind as argument e.g: 'FwBundle(<dictionary>, leafKind), not in <dictionary>")
		leafStruc				= partConfig["struc"];	partConfig["struc"] = nil
		if leafStruc != nil {
			apply(constructor:leafStruc!, leafConfig:leafConfig, tunnelConfig)	//tunnelConfig=[struc:[1 elts],n:evi,placeMy:stackz 0 -1]
		}
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String] {	super.hasPorts()	}	//return[:]//["P":"pcM"]//

	 // MARK: - 3.5 Codable
	enum BundleKeys:String, CodingKey {
		case leafStruc
		case leafKind
		case label
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 		= encoder.container(keyedBy:BundleKeys.self)

	//	try container.encode(leafStruc,	forKey:.leafStruc)	//Protocol 'FwAny' as a type cannot conform to 'Encodable'
		try container.encode(leafKind,	forKey:.leafKind)
		try container.encode(label, 	forKey:.label)
		atSer(3, logd("Encoded  as? FwBundle      '\(fullName)'"))
	}
	  // Deserialize
	required init(from decoder: Decoder) throws {
		leafKind			= .nil_		// WTF?
		try super.init(from:decoder)

		let container 		= try decoder.container(keyedBy:BundleKeys.self)
	//	leafStruc			= try container.decode(leafStruc.self,forKey:.leafStruc)//No exact matches in call to instance method 'decode'
		leafKind			= try container.decode(LeafKind.self, forKey:.leafKind)
		label	 			= try container.decode(String.self,   forKey:.label)
		atSer(3, logd("Decoded  as? FwBundle     named  '\(name)'"))
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy			= super.copy(with:zone) as! FwBundle
//		theCopy.leafStruc 	= self.leafStruc
//		theCopy.leafKind 	= self.leafKind
//		theCopy.label 		= self.label
//		atSer(3, logd("copy(with as? FwBundle       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 						   else {	return true			}
		guard let rhs			= rhs as? FwBundle else {	return false 		}
		let rv					= super.equalsFW(rhs)
//								&& leafStruc == rhs.leafStruc	//Type 'any FwAny' cannot conform to 'Equatable'
								&& leafKind  == rhs.leafKind
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
		<bunListDesc>	::= "spin:L"|"sL"| "spin:R"|"sR"| "spin:2"|"s2"| <nil>
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

	// MARK: - 4.1 Part Properties
	func apply(constructor con:FwAny, leafConfig:FwConfig, _ tunnelConfig:FwConfig) {
		atBld(7, logd("apply(constructor:\(con.pp(.line))))"))

		  // ==== Parse constructor:  It has many forms:
		 // STRING:
		if con is String {
			apply(spec:con, leafConfig:leafConfig, tunnelConfig)
		}
		 // ARRAY: apply each element of con to self
		else if let conArray = con as? [FwAny] {// Array of constructors to apply to bundle
			for subSpec in conArray {				// paw through array, build each
				apply(spec:subSpec, leafConfig:leafConfig, tunnelConfig)		//tunnelConfig=[struc:[1 elts],n:evi,placeMy:stackz 0 -1]
			}
		}
		  // HASH: apply each par of con to self (key->con; val->subSpec
		 // <key>=name of new element; <val>=kind of element
		else if let con3 = con as? FwConfig{// Hash of name:kind
			for (conKey, conValue) in con3 {	// paw through hash
				apply(spec:conKey, arg:conValue, leafConfig:leafConfig, tunnelConfig)
				// newElt		name		  constructor	prototypes
			}								//BUGGY:.name; = subSpecKey;
		}
		 // BUNDLE (and Leaf):
		else if con is FwBundle {
			apply(spec:con, leafConfig:leafConfig, tunnelConfig)
		}
		 // NULL	 -- do nothing
		else if con is NSNull {
			let _ 				= 33
		}
		else {
			panic("Apply(struc:'\(con.pp(.tree))'...) not understood")	// 180903 WHY NOT JUST pp() ???
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
								
	 /// Add leaves by apply a specification to ourselves
	func apply(spec:FwAny, arg:FwAny?=nil, leafConfig:FwConfig, _ tunnelConfig:FwConfig) {
		atBld(7, logd("apply(spec:\(spec.pp(.line)), arg:\(arg?.pp(.line) ?? "nil"))"))
								
		   // Interpret << spec >>, making appropriate changes to self, a FwBundle
		  //
		 // Case 1: STRINGs -- rich semantics
		if let specStr = spec as? String {
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
						newsProperty = { (p : Part) in		// ##BLOCK: set name
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
					let dummy : Part = Leaf(leafKind)
//					let dummy : Part = leafKind == .port ? Port(["f":1]) :Leaf(leafKind)
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
					let newBun 	= FwBundle()				// Build a new FwBundle or Tunnel
					newsProperty!(newBun)					// Apply delayed property
					newBun.apply(constructor:arg!, leafConfig:leafConfig, tunnelConfig)
					addChild(newBun)
				}
				 // CASE 1.4b: Get a new Leaf:
				else {
					let newLeaf	= Leaf(leafKind, leafConfig, tunnelConfig)	//tunnelConfig=[struc:[1 elts], n:evi, placeMy:stackz 0 -1]
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
		 // Case 2: ARRAYs and HASHs -- add all, recursively// E.g: @[name1, ..], or @{name1:kind1, ...}
		else if (spec is Array<Any> || spec is FwConfig) {
			let newElt				= FwBundle()				// Build a new FwBundle
			newElt.apply(constructor:spec, leafConfig:leafConfig, tunnelConfig)
			addChild(newElt)
		}
		 // Case 3: BUNDLE -- ready immediately				// E.g: leaf:Leaf
		else if let spec1 = spec as? FwBundle {
			addChild(spec1)									// silently reach inside and insert
		}
		else {
			panic("Unknown FwBundle spec type")
		}
	}

	  // MARK: - 4.5 Iterate (forAllLeafs)
	 typealias LeafOperation = (Leaf) -> ()
	 func forAllLeafs(_ leafOperation : LeafOperation)  {
		 for elt in self.children {
			 if let subBlk = elt as? Leaf {		// ignore Ports and numbers
				 subBlk.forAllLeafs(leafOperation)
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
		return soughtLeaf?.port4leafBinding(name:"G") as? Port

	}
	 // MARK: - 9. 3D Support
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.find(name:"s-Bun") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-Bun"
			return scn
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
		if portVew.part === ports["P"] {		//"ALL" is in bottom center
//		if portVew.part == ports["P"] {		//"ALL" is in bottom center
			let flip			= portVew.part.flipped
			let bBox			= portVew.bBox
			let place			= flip ? bBox.centerTop : bBox.centerBottom
			portVew.scnRoot.transform = SCNMatrix4(place, flip:flip)
//			portVew.scn.transform = SCNMatarix4(portVew.bBox.centerBottom.x, 0, 0, flip:flip)
		}
		else {
			super.rePosition(portVew:portVew)
		}
	}
}
