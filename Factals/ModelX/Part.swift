// Part.swift -- Base class for Factal Workbench Models C2017PAK

import Foundation
import SceneKit
import SwiftUI
// Josh:
class A {}
class B: A {}
let superclassOfB	: AnyClass? = Swift._getSuperclass (B.self)
let superclassOfPoly: AnyClass? = Swift._getSuperclass (Part.self)

extension Part : PolyWrappable {			}

extension Part : Equatable {
	static func == (lhs: Part, rhs: Part) -> Bool {
		bug; return false
	}
}
 // Generic struct 'ForEach' requires that 'Part' conform to 'Hashable' (from InspecPart.body.Picker)
extension Part : Hashable {
	func hash(into hasher: inout Hasher) {
bug;	hasher.combine(uid)					// fwClassName, fullName, children?
	}
}

 /// Base class for Factal Workbench Models
// Used to be based on NSObject, not now.  What about NSCopying, NSResponder,
class Part : Codable, ObservableObject, Uid, Logd {			//, Equatable
	var uid:UInt16				= randomUid()
	 // MARK: - 2. Object Variables:
	@objc dynamic var name		= "<unnamed>"
	var children	: [Part]	= []
	var child0		:  Part?	{	return children.count == 0 ? nil : children[0] }
	weak var parent :  Part?	= nil 		// add the parent property

	 // nil root defers to parent's root.
	var root		: RootPart?  {
		get {								//return parent?.root ?? self as? RootPart
			parent?.root ??					// RECURSIVELY up the parent tree
			self as? RootPart ??			// top should be RootPart
			{	fatalError("Mall-formed tree: nil parent should be RootPart")	} ()
		}
		set(v) {
			fatalError("root.set(v)")
		}
	}

	var dirty : DirtyBits		= .clean	// (methods in SubPart.swift)
 // BIG PROBLEMS: (Loops!)
//	{	willSet(v) {	markTree(dirty:v)  									}	}
	var localConfig	: FwConfig				// Configuration of Part
	 // Ugly:
	var nLinesLeft	: UInt8		= 0			// left to print in current atom

	 // MARK: - 2.1 Sugar
	var parts 		: [Part]	{ 		children 								}
	@objc dynamic var fullName	: String	{
		let rv					= name=="ROOT" ? 		   name :	// Leftmost component
								  parent==nil  ? "" :
								  parent!.fullName + "/" + name		// add lefter component
		return rv
	}
	var fullName16 	: String	{		return fullName.field(16)				}
	 // - Array of unsettled ports. Elements are closures that returns the Port's name
	func unsettledPorts()	-> [()->String]	{
		var rv					= [()->String]()
		for child in children {
			rv					+= child.unsettledPorts()
		}
		return rv
	}
/*
- (int) unsettledPorts;	{
	assert(coerceTo(Net, self) or coerceTo(Atom, self), (@"%@ * illegal", self.className));
	int rv = 0;
	for (id elt in self.parts)
		if (coerceTo(Part, elt))
			rv += [elt unsettledPorts];
	return rv;
}

 */

	 // MARK: - 2.4 Display Suggestions
	var initialExpose : Expose	= .open		// Hint to use on dumb creation of views. (never changed)
			// See View.expose for GUI interactions
	@Published var flipped : Bool = false
	{	didSet {	if flipped != oldValue {
						markTree(dirty:.size)
																		}	}	}
	 // MARK: - 2.2b INTERNAL to Part
	@Published var lat : Latitude = Latitude.northPole 			// Xyzzy87 markTree
	{	didSet {	if lat != oldValue {
						markTree(dirty:.size)
																		}	}	}
  //@Published var longitude
	@Published var spin : UInt8 = 0
	{	didSet {	if spin != oldValue {
						markTree(dirty:.size)
																		}	}	}
	@Published var shrink : Int8 = 0			// smaller or larger as one goes in
	{	didSet {	if shrink != oldValue {
						markTree(dirty:.size)
																		}	}	}
	var logger : Logger			{ 	root?.logger ?? Logger(title:"a new Part.Logger()", [:] )		}
//	var logger : Logger			{ 	root?.logger ?? .help						}

	 // MARK: - 2.2c EXTERNAL to Part
	// - position[3], 						external to Part, in Vew

	 // MARK: - 2.5 SwiftUI Stuff
	 // just put here to get things working?
	@Published var placeSelf = ""			// from config!
	{	didSet {	if placeSelf != oldValue {
						markTree(dirty:.vew)
																		}	}	}
// ///////////////////////////// Factory //////////////////////////////////////
	// MARK: - 3. Part Factory
	/// Base class for Factal Workbench Models
	/// - Value "n", "name", "named": name of element
	/// - Parameter config: FwConfig configuration hash 
	init(_ config:FwConfig = [:]) {
		localConfig				= config		// Set as my local configuration hash

	//	super.init() 	// NSObject \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		var nam : String?		= nil
		 // Do this early, to improve creation printout
		for key in ["n", "name", "named"] {		// (Name has 3 keys)
			if let na:String 	= localConfig[key] as? String {
				assert(nam==nil, "Conflicting names: '\(nam!)' != '\(na)' found")
				nam				= na
				localConfig[key] = nil			// remove from config
			}
		}			// -- Name was given
		name					= nam ?? {
			if let prefix		= prefixForClass[fwClassName],
			  let rootPart		= root
			{		// -- Use Default name: <shortName><index> 	(e.g. G1)
				let index		= rootPart.indexFor[prefix] ?? 0
				rootPart.indexFor[prefix] = index + 1		// for next
				return prefix + String(index)
			} else {	// -- Use fallback
				defaultPrtIndex	+= 1
				return "prt" + String(defaultPrtIndex)
			}

//			if let prefix		= prefixForClass[fwClassName],
//			  let rootPart		= root
//			{		// -- Use Default name: <shortName><index> 	(e.g. G1)
//				let index		= rootPart.indexFor[prefix] ?? 0
//				rootPart.indexFor[prefix] = index + 1		// for next
//				return prefix + String(index)
//			} else {	// -- Use fallback
//				defaultPrtIndex	+= 1
//				return "prt" + String(defaultPrtIndex)
//			}
		}()

		 // Print out invocation
		let n					= ("\'" + name + "\'").field(-8)
		atBld(6, logd("init(\(localConfig.pp(.line))) name:\(n)", note:fwClassName))

		 // Options:
		if let valStr			= localConfig["expose"] as? String,
		  let e : Expose		= Expose(string:valStr) {
			initialExpose		= e
			localConfig["expose"] = nil
		}
		for key in ["f", "flip", "flipped"] {
			if let ff			= localConfig[key],		// in config
			  let f				= Bool(fwAny:ff) {			// can be Bool
				flipped 		= f
				localConfig[key] = nil
			}
		}
		for key in ["lat", "latitude"] {
			if let ff			= localConfig[key] {
				if let f		= Int(fwAny:ff),
				  let g			= Latitude(rawValue:f) {
					lat				= g
					localConfig[key] = nil
				}
			}
		}
		if let s				= UInt8(fwAny:localConfig["spin"]) {
			spin 				= s
			localConfig["spin"] = nil
		}

//		if type(of:self) == Part.self && localConfig["parts"] != nil {
//			panic("key 'parts' can only be used in Atoms, not Parts")
//		}
		if let a 				= localConfig["parts"] as? [Part] {
			a.forEach { addChild($0) }						// add children in "parts"
			localConfig["parts"] = nil
		}
		if let parts 			= localConfig["parts"] {
			let arrayOfParts	= parts as? [Part]
			assert(arrayOfParts != nil, "Net([parts:<val>]), but <val> is not [Part]")
			arrayOfParts!.forEach { addChild($0) }				// add children in "parts"
			localConfig["parts"] = nil
		}
	}
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
	func setTree(root:RootPart, parent:Part?) {
		assertWarn(self.parent === parent, "\(fullName): Parent:\(self.parent?.fullName ?? "nil") should be \(parent?.fullName ?? "nil")")
		assertWarn(self.root   === root,   "\(fullName): Root:\(self  .root?  .fullName ?? "nil") should be \(root   .fullName         )")
		self.parent 			= parent
//		self.root   			= root
		for child in children {
			child.setTree(root:root, parent:self)
		}
	}
	deinit {//func ppUid(pre:String="", _ obj:Uid?, post:String="", showNil:Bool=false, aux:FwConfig=[:]) -> String {
		atBld(3, print("#### DEINIT    \(ppUid(self)):\(fwClassName)")) // 20221105 Bad history deleted
	}

	 // START CODABLE ///////////////////////////////////////////////////////////////
	   // MARK: - 3.4 PolyPart
			//			input		returned (E) ^backlink
			//			 |			 v
			//			 |			PolyWrap (A)
			//			 v			 v		 (B) ^backlink
			//			self		self
			//			v v v		v v v	 (C)
			//			C C C		C C C	 (D) ^backlink
			//			| | |		| | |
	  /// Wrap Part self in a PolyWrap, so Codable acts polymorphically.
	 /// - Return a PolyWrapped child (a PolyWrap with one child, self)
	//@objc
	func polyWrap() -> PolyWrap {
		 // stitch in our PolyWrap in where we were
		let pw					= PolyWrap([:])		// (B) backlink
		pw.name					= "---"				// works nice with pp(.tree)
		pw.addChild(self)							// We are poly's child
		parent					= pw				// Backlink: our parent is poly

		 // PolyWrap all Part's children
		// NFG: children		= children.polyWrap()
		for i in 0..<children.count {
			 // might only wrap polymorphic types?, but simpler to wrap all
			children[i]			= children[i].polyWrap()		// RECURSIVE			// (C)
			children[i].parent	= self													// (D) backlink
		}
		return pw
	}
	func polyUnwrap() -> Part {		fatalError("Part.polyUnwrap should be overridden by PolyWrap or RootPart")	}
	  // MARK: - 3.5 Codable
	 //https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
	enum PartsKeys: String, CodingKey {
		//case uid			// IGNORE
		case name
		case children		// --- (SUBSUMES .parts)
		//case parent		// IGNORE, weak, reconstructed
		//case root_		// IGNORE, weak regenerate
		case nLinesLeft		// new
		case dirty
		case localConfig	// ERRORS: want FwConfig to be Codable?
		case config		// IGNORE: temp/debug FwConfig	= ["placeSelfy":"foo31"]
		case initialExpose 	// --- (an Expose)	=.open	// Hint to use on dumb creation of views. (never changed)
		//case expose		// IGNORE, it's in Vew, not part
		case flipped
		case lat 			// --- (a Latitude)	=Latitude.northPole
		//case latitude		// IGNORE:
		case spin
		case shrink			// commented out
		case placeSelf		// new
	}

	func encode(to encoder: Encoder) throws  {
		//try super.encode(to:encoder)	// NSObject isn't codable
		var container 			= encoder.container(keyedBy:PartsKeys.self)

		try container.encode(name, 			forKey:.name)
		try container.encode(children,		forKey:.children)		// ignore parts. (it's sugar for children)

		try container.encode(nLinesLeft,	forKey:.nLinesLeft)		// ignore parts. (it's sugar for children)

	//	try container.encode(localConfig,	foarKey:.localConfig)	// FwConfig not Codable!//Protocol 'FwAny' as a type cannot conform to 'Encodable'
	//	try container.encode(config,		forKey:.config) 		// Type '(String) -> FwAny?' cannot conform to 'Encodable'
		try container.encode(dirty,			forKey:.dirty)			// ??rawValue?? //	var dirty : DirtyBits
		try container.encode(initialExpose,	forKey:.initialExpose)
		try container.encode(flipped, 		forKey:.flipped)
		try container.encode(lat,			forKey:.lat)
		try container.encode(spin, 			forKey:.spin)
		try container.encode(shrink,		forKey:.shrink)
		try container.encode(placeSelf,		forKey:.placeSelf)
		atSer(3, logd("Encoded  as? Part        '\(fullName)' dirty:\(dirty.pp())"))
	}

	required init(from decoder: Decoder) throws {
		//try super.init(from:decoder)	// NSObject isn't codable
		localConfig				= [:]//try container.decode(FwConfig.self,forKey:.localConfig)
//		super.init()	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		let container 			= try decoder.container(keyedBy:PartsKeys.self)
			//  po container.allKeys: 0 elements

		name 					= try container.decode(	   String.self, forKey:.name)
		children				= try container.decode([PolyWrap].self, forKey:.children)
		children.forEach({ $0.parent = self})	// set parent
		// root?
		nLinesLeft				= try container.decode(		UInt8.self, forKey:.nLinesLeft)
		localConfig 			= [:]	// PUNT
		//config				= [:]	// PUNT
		dirty					= try container.decode( DirtyBits.self, forKey:.dirty)
		initialExpose			= try container.decode(	   Expose.self, forKey:.initialExpose)
		flipped					= try container.decode(		 Bool.self, forKey:.flipped)
		lat						= try container.decode(  Latitude.self, forKey:.lat)
		spin					= try container.decode( 	UInt8.self, forKey:.spin)
		shrink					= try container.decode(		 Int8.self, forKey:.shrink)
		placeSelf				= try container.decode(	   String.self, forKey:.placeSelf)

		var str					=  "name='\(name)', "
		str						+= "\(children.count) children, "
		str						+= "dirty:\(dirty.pp())"
		atSer(3, logd("Decoded  as? Part       \(str)"))
	}
	// END CODABLE /////////////////////////////////////////////////////////////////
//	 // MARK: - 3.6 NSCopying
//	func copy(with zone: NSZone?=nil) -> Any {
//bug;	let theCopy 			= Part()
////		let theCopy : Part		= super.copy(with:zone) as! Part
//		theCopy.name			= self.name
//		theCopy.children		= self.children
//		theCopy.nLinesLeft		= self.nLinesLeft
//		theCopy.localConfig		= self.localConfig
//	//	theCopy.config			= self.config
//		theCopy.dirty			= self.dirty
//		theCopy.initialExpose	= self.initialExpose
//		theCopy.flipped			= self.flipped
//		theCopy.lat				= self.lat
//		theCopy.spin			= self.spin
//		theCopy.shrink			= self.shrink
//		theCopy.placeSelf		= self.placeSelf
//		atSer(3, logd("copy(with as? Part       '\(fullName)'"))
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	// https://forums.swift.org/t/implement-equatable-protocol-in-a-class-hierarchy/13844
//	// https://stackoverflow.com/questions/39909805/how-to-properly-implement-the-equatable-protocol-in-a-class-hierarchy
//	// https://jayeshkawli.ghost.io/using-equatable/
//	  // Allow Arrays of Equatables to be Equatable
//	 // https://jayeshkawli.ghost.io/using-equatable/
////	static func ==(lhs:Part, rhs:Part) -> Bool {
////		atTst(7, lhs.logd("Testing Part: \(lhs.pp(.nameUidClass)) == \(rhs.pp(.nameUidClass))"))
////
////		 // Option 1:	note offenders-checking
////bug
////
////		 // Option 2: Value Equivalence
////		guard type(of:lhs) == type(of:rhs)	else {	return false				}
////		let rv					= lhs.equals(rhs)	// now == means equivalent values
////
////		 // Option 3: Identity (A MAJOR regression)
////  //	let rv					= lhs === rhs		//
////
////		atTst(7, lhs.logd("Result  Part: \(lhs.pp(.nameUidClass)) == \(rhs.pp(.nameUidClass))  ---> \(rv)"))	//debugDescription
////		return rv
////	}
//	func equals(_ rhs:Part) -> Bool {
//		guard self !== rhs 					  else {	return true				}
//
//		 // It appears short circuit is broken
//		let (cldrn, rhsCldrn)	= (children, rhs.children)
//		let rv 					= true
//			&& type(of:self) 	== type(of:rhs)			// A
//			&& fwClassName 		== rhs.fwClassName		// B==A
//			&& name				== rhs.name
//		//	&& parent			== rhs.parent			// weak
//	//		&& cldrn.equals(rhsCldrn)					//
// //!!		&& cldrn			== rhsCldrn				// experimental
//	//?		&& cldrn			== rhsCldrn				// DOESN'T SEEM TO WORK
////			&& children			== rhs.children			// DOESN'T SEEM TO WORK
//			&& nLinesLeft		== rhs.nLinesLeft
//			&& dirty			== rhs.dirty			// allowed to differ
//		//	&& localConfig		== rhs.localConfig		// not Equatable
//		//	&& config			== rhs.config			// not Equatable
//			&& initialExpose 	== rhs.initialExpose
//			&& flipped			== rhs.flipped
//			&& lat				== rhs.lat
//			&& spin				== rhs.spin
//			&& shrink			== rhs.shrink
//			&& placeSelf		== rhs.placeSelf
//		guard rv									else {	return false}
//		 // Paw through children by hand:
//		guard  children.count == rhs.children.count else {	return false}
//		for i in 0 ..< children.count {
//			guard children[i] == rhs.children[i]	else {	return false }
//		}
//		return true
//	}
	 // MARK: - 4.1 Part Properties
	 /// Short forms for Spin
	static let str2spin : [String : Int] = [
					"s0":0,     "s1":1,     "s2":2,     "s3":3,
				"spin_0":0, "spin_1":1, "spin_2":2, "spin_3":3,
								"sR":1, 				"sL":3, ]
	func apply(propNVal:String) -> Bool {
		let tokens : [String]	= propNVal.components(separatedBy:":")
		if tokens.count == 1 {
			if let opts 		= Part.str2spin[tokens[0]] {
				return apply(prop:"spin", withVal:opts)	// more parsed form
			}
		}
		 // process key:value
		else if (tokens.count == 2) {
			panic()
			return apply(prop:tokens[0], withVal:tokens[1])
		}
		else {
			panic(" add stuff here ")
		}
		return false
	}
	static let spinMax			= 16
	func apply(prop:String, withVal val:FwAny?) -> Bool {
		guard let val			= val else {		return false				}

		if prop == "n" || prop == "name" || prop == "named",
		  let n 				= val as? String{ // e.g: "named":"foo"
			name 				= n
			return true							// found a flip property
		}
		if prop == "f" || prop == "flip" || prop == "flipped",
		  let flipVal 			= Bool(fwAny:val) { // e.g: "flip:1"
			flipped 			^^= flipVal
			return true							// found a flip property
		}
		if prop == "s" || prop == "spin" {						// e.g. "spin:3"
			var spinVal : Int?	= nil				// initiall no spinVal
			if let valNum 		= val as? Int {
				spinVal 		= valNum				// carries spin value
			}
			else if let valStr 	= val as? String {	// String
				 // Production: symbolic "r" --> 1
				let (a, b)		= (Part.spinMax/4, 3*Part.spinMax/4)
				let lr2int  	= [ "r":a, "R":a, "l":b, "L":b]
				if let n		= lr2int[valStr] {
					spinVal 	= n			// symbolic spin --> numeric spin
				}
				else if let n 	= Int(valStr) {
					spinVal		= n
				}
			}
			assert(spinVal != nil, "spin value \(val.pp(.short)) ILLEGAL")
			assert(spinVal!>=0 && spinVal!<Part.spinMax, "spinVal \(spinVal!) out of range")

			let x				= (Int(spin) - spinVal! + Part.spinMax) % Part.spinMax
			spin				= UInt8(x)
			return true						// found a spin property
		}
		if prop == "sound" {	// e.g. "sound:di-sound" or
			bug
			if let val = val.asString,
			   let leaf				= self as? Leaf,
			   let genPort			= leaf.port(named:"G"),
			   let genAtom  		= genPort.atom as? SoundAtom	// was GenAtom!
			{
				genAtom.sound		= val
			}
			else {
				panic("sound's val must be string")
			}
			return true							// found a spin property
		}
		//if ([prop isEqualToString:"sound"]) {	// e.g. "sound:di-sound" or
		//	panic("")
		//	//if (coerceTo(NSString, val)) {
		//	//	Leaf *leaf			= mustBe(Leaf, self)
		//	//	Port *genPort		= [leaf port(named:"G")
		//	//	GenAtom *genAtom 	= mustBe(GenAtom, genPort.atom)
		//	//	genAtom.sound		= val
		//	//}
		//	//else
		//	//	panic("sound's val must be string")
		//	//
		//	//return true							// found a spin property
		//}
		return false
	}



	// MARK: - 4.2 Manage Tree
	/// Add a child part
	/// - Parameters:
	///   - child: child to add
	///   - index: index to added after. >0 is from start, <=0 is from start, nil is at end
	/// dirtyness of child is inhereted by self
	func addChild(_ child:Part?, atIndex index:Int?=nil) {
		guard let child 		= child else {		return						}
		assert(self !== child, "can't add self to self")

		 // Find right spot in children
		var doppelganger : Int?	= children.firstIndex(where: {$0 === child})//(of:child)	// child already in children
		if var i 				= index {
			if i < 0 {
				i = children.count - i		// Negative indices are distance from end
			}
			assert(i>=0 && i<=children.count, "index \(i) out of range")
			children.insert(child, at:i)	// add at index i
			if let d			= doppelganger {
				doppelganger	= d + (i < d ? 1 : 0)
			}
		}
		else {
			children.append(child)			// add at end
		}

		if let d				= doppelganger {
			children.remove(at:d)
		}

		 // link
		child.parent			= self
//		child.root				= self.root

		 // Process tree dirtyness:
		markTree(dirty:.vew)				// ? tree has dirty.vew
		markTree(dirty:child.dirty)			// ? tree also inherits child's other dirtynesses
	}										// (child is not dirtied any more)
	func removeChildren() {
		children.removeAll()
		markTree(dirty:.vew)
	}
	/// Groom Part tree after construction.
	/// - Parameters:
	///   - parent_: ---- if known
	///   - root_: ---- set in Part
	func groomModel(parent p:Part?, root r:RootPart?)  {
		parent					= p
		root					=  r					// from arg (if there)
								?? root					// my root	(if there)
								?? self as? RootPart 	// me, if I'm a RootPart
								?? child0 as? RootPart	// if PolyWrapped
		markTree(dirty:.vew)							// set dirty vew

		 // Do whole tree
		for child in children {							// do children
			child.groomModel(parent:self, root:root)		// ### RECURSIVE
		}
	}

	func groomModelPostWires(root:RootPart)  {
		 // Check for duplicate names:
		var allNames : [String] = []
		for child in children {
			assertWarn(!allNames.contains(child.name), "\(self.fullName) contains duplicate name \(child.name)")
			allNames.append(child.name)
		}
		 // Do whole tree
		for child in children {
			child.groomModelPostWires(root:root) 	// ### RECURSIVE
		}
	}

	 // Get Part's configuration from localConfig of Part and parents, and model
	func config(_ name:String) -> FwAny? {
		 // Look in self and parents:
		for s in selfNParents {					 // look in: self, parent?,...,root
			if let rv			= s.localConfig[name] {
				return rv							 // found in self and ancestor's config
			}
		}										 // Look in application:
		return nil
//		return root?.fwGuts?.document.config[name] ?? // Look in doument
//			   APP?					 .config[name]	 // Application?a
	}
	 // MARK: - 4.3 Iterate over parts
	typealias PartOperation 	= (Part) -> ()
	func forAllParts(_ partOperation : PartOperation)  {
		partOperation(self)
		for child in children {
			child.forAllParts(partOperation)
		}
	}
//	func forAllPorts<T>() -> T? 	{		return nil							}

	  // /////////////////////////// Navigation //////////////////////////////////////
	 // MARK: - 4.4 Navigation
	var enclosingNet : Net? {
		for s in parents {
			if let n 			= s as? Net {
				return n
			}
		}
		return nil
	}
	func ancestorThats(childOf child:Part) -> Part? {
		for part in selfNParents {
			if part.parent === child {
//			if part.parent == child {
				return part
			}
		}
		return nil		// no ancestor or self is child of anAncestor
	}
	func enclosedByClass(fwClassName:String) -> Part {
		let cl : Part.Type		= classFrom(string:fwClassName)
		return enclosedByClass(class:cl)!	 // get the appropriate class object
	}
	func enclosedByClass(class:AnyClass?) -> Part? {
		for part in parent?.selfNParents ?? [] {					// Search outward
			panic()
			return part
		}
		return nil
	}
	func hasAsAncestor(ancestor:Part) -> Bool {
		for part in selfNParents {
			if part === ancestor {
				return true
			}
		}
		return false
	}
	func smallestNetEnclosing(_ m1:Part, _ m2:Part?=nil) -> Net? {
		let a1 					= m1.selfNParents					// of Parts
		 // just 1 Part supplied or both Parts are the same
		if m2 === nil ||  m2 === m1	{
//		if m2==nil ||  m2 == m1	{
			for m in a1.reversed() {
				if let mNet = m as? Net {
			 	  // the smallest parent that is a Net
					return mNet
				}
			}
		}
		 // 2 Parts supplied -- find the smallest Net they have in common
		else {
			let a2				= m2!.selfNParents
			let (am1, am2)		= (a1.count - 1, a2.count - 1)
			var (n, i)			= (min(am1, am2) + 1, 0)
			while i < n {
				if a1[am1 - i] !== a2[am2 - i] {    // working backward			//!=
					break
				}
				i				+= 1
			}					// i now at first difference
			while i > 0 {
				i				-= 1
				if let a1Net	= a1[am1 - i] as? Net  {
					return a1Net
				}
			}
		}
		return nil          // no Net in any of m1's parents
	}
	 /// Ancestor array starting with parent 
	var parents : [Part] {				
		var rv 		 : [Part]	= []
		var ancestor :  Part?	= parent
		while ancestor != nil {
			rv.append(ancestor!)
			ancestor 			= ancestor!.parent
		}
		return rv
	}
	/// Ancestor array starting with self 
	var selfNParents : [Part] {	
		return selfNParents()
	}
	/// Ancestor array, from self up to but excluding 'inside'
	func selfNParents(upto:Part?=nil) -> [Part] {
		var rv 		 : [Part]	= []
		var ancestor :  Part?	= self
		while ancestor != nil, 			// ancestor exists and
			  ancestor! !== upto  {		// not at explicit limit
//		  ancestor!.name != "ROOT" {
			rv.append(ancestor!)
			ancestor 			= ancestor!.parent
		}
		return rv
	}

	/// Class Inheritance Ancestor Array, from self up to but excluding 'inside'
	var inheritedClasses : [String] {
		var rv 	: [String]		= []
		var curClass:Part.Type? = type(of:self)	
		repeat { 
			rv.append(String(describing:curClass!))

/* 1: *///	let supererClass	= Swift._getSuperclass(curClass!) as? Part.Type
/* 2: */	let supererClass	= class_getSuperclass(curClass!) as? Part.Type	// JOSH?
/* 3: *///	let supererClass	= curClass?.superclass()						// Type 'Part' has no member 'superclass'
/* 4: *///	let supererClass	= superclass() as? Part.Type					// Cannot find 'superclass' in scope

			curClass			= supererClass
		} while curClass != nil
		return rv
	}
	func dagIndex(ancestorOf part:Part) -> Int? {
		if let p 				= part.ancestorThats(childOf:self) {
			return children.firstIndex(where: {$0 === p})//(of:p)
		}
		return nil
	}



	/// Up has 2 meanings:
	///	- UPsidedown (as controlled by fliped)
	///	- Port opens UP
	var upInWorld : Bool {						// true --> flipped in World
		var rv 					= false
		for part in selfNParents {
			rv 					^^= part.flipped	// rv now applies from self
		}
		return rv
	}
	 /// self isUp in Part
	 /// - argument: inPart -- part which is parent of self
	func upInPart(until endPart:Part) -> Bool {

		 // Trace from self to endPart:
		let (flip0, end0)		= self   .flipTo(endPart:endPart)
		if end0 === endPart {		// found endPart
//		if end0 == endPart {		// found endPart
			return  flip0				// return its flip
		}

		 // Trace from endPart to self:
		let (flip1, end1)		= endPart.flipTo(endPart:self   )
		if end1 === self {			// found self
//		if end1 == self {			// found self
			return  flip1				// return its flip
		}

		 // They end at the same root!
		if end0 === end1 {
//		if end0 == end1 {
			return flip0 ^^ flip1
		}
		fatalError("self:\(fullName) and endPart:\(endPart.fullName) don't share a root")
	}
	 /// scan up the tree from self to (but not including) endPart
	private func flipTo(endPart:Part) -> (Bool, Part) {
		var flipd				= false
		var endP : Part			= self
		while endP !== endPart && 				// we are not endpart			//!=
			  endP.parent != nil 				// we have a parent
		{
			flipd				^^= endP.flipped		
			endP 				= endP.parent!
		}
		return (flipd, endP)
	}
	func upInWorldStr()		 	 -> String {
		return upInWorld ? "up" : "down"
	}

		 // MARK: - 4.6 Find Children
	   /// A boolean predicate of a Part
	typealias Part2PartClosure 	= (Part) -> Part?
	 /// Find Part with desired name
	/// - name		-- sought name
	func find(name desiredName:String,
								
			  all searchParent 	 : Bool	= false,
			  inMe2 searchSelfToo: Bool	= false,
			  maxLevel			 : Int?	= nil,
			  except exception	 :Part?	= nil) -> Part? { // Search by name:
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel, except:exception, firstWith:
					{	$0.fullName.contains(desiredName) ? $0 : nil			} )
//					{	$0.fullName == desiredName ? $0 : nil					} )
	}
	func find(path				 : Path,

			  all searchParent	 : Bool	= false,
			  inMe2 searchSelfToo: Bool	= false,
			  maxLevel			 : Int?	= nil,
			  except exception	 :Part?	= nil) -> Part? { // Search by Path:
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel, except:exception, firstWith:
					{	$0.partMatching(path:path) 								} )
//		{(part:Part) -> Part? in
//			return part.partMatching(path:path)		// part.fullName == "/net0/bun0/c/prev.S"
//		} )
	}
	func find(part				 : Part,

			  all searchParent 	 : Bool	= false,
			  inMe2 searchSelfToo: Bool = false,
			  maxLevel 		:Int?		= nil,
			  except exception:Part?	= nil) -> Part? { // Search for Part:
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel, except:exception, firstWith:
					{	$0 === part ? $0 : nil	 								} )
//					{	$0 == part  ? $0 : nil	 								} )
//		{(aPart:Part) -> Part? in
//			return aPart == part ? aPart : nil
//		} )
	}
	 /// First where closure is true:
	/// - inMe2		-- search this node as well
	/// - all		-- search parent outward
	/// - maxLevel	-- search children down to this level
	/// - except	-- don't search, already search
	func find(inMe2	 :Bool		= false, 	all searchParent:Bool=false,
			  maxLevel :Int?	= nil,   	except exception:Part?=nil,
			  firstWith partClosure:Part2PartClosure) -> Part? { /// Search by closure:
		 // Check self:
		if inMe2,
		  let cr 				= partClosure(self) {		// Self match?
			return cr
		}
		if (maxLevel ?? 1) > 0 {		// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
			let orderedChildren	= (upInWorld ^^ findWorldUp) ? children.reversed() : children
			 // Check children:
			for child in orderedChildren where exception === nil || child !== exception! { // don't redo exception
				if let rv 		= child.find(inMe2:true, all:false, maxLevel:mLev1, firstWith:partClosure) {
					return rv
				}
			}
		}
		if searchParent,						// Check parent
		  let p					= parent,		// Have parent
		  p.name != "ROOT" {					// parent not ROOT
			return parent?.find(inMe2:true, all:true, maxLevel:maxLevel, except:self, firstWith:partClosure)
		}
		return nil
	}
	// MARK: - 4.8 Matches Path
	/// Get a Proxy Part matching path
	/// # The Path must specify a Part inside self.
	/// - Parameter path: ---- the path
	/// - Returns: ---- the part matching the path
	func partMatching(path:Path) -> Part? {

		 // Does my Path's tokens match Atom:
		for (index, part) in selfNParents.enumerated() {
			assert(!(self is Port), "Ports can only be last element of a Path")
			if index >= path.atomTokens.count {		// Past last token?
				return self								// .:. match!
			}
			if index == path.atomTokens.count-1,	// At the token to the left of the first '/'?
			  path.atomTokens[index] == "" {		  // "" before --> Absolute Path
				logd("Absolute Path '\(path.pp(.line))', and at last token: UNTESTED")
				return self								// .:. match!
			}
			if part.name != path.atomTokens[index]{	// name MISMATCH
				return nil								// .:. nfg
			}
		}
		if parent == nil, 							// no parents and
		  path.atomTokens.count != 0 {				  //  still more tokens?
			return nil									// mismatch
		}
		return self									// Match
	}


	 // MARK: - 5. Wiring
	/// Scan self and children for wires to add to model
	/// - Wires are gathered after model is built, and applied at later phase
	/// - Parameter wirelist: 		where wires added
	func gatherLinkUps(into linkUpList:inout [() -> ()]) {    //super gatherWiresInto:wirelist];
		 // Gather wires from  _children_   into wirelist first:
		for child in children {
			if let atom       	= child as? Atom {
				atom.gatherLinkUps(into:&linkUpList)  // ### RECURSIVE
			}
		}
	}

	   //------------- Reenactment Simulator -- simulation protocol ----
	  // MARK: - 7. Simulator Messages
	 // Inject message
	func sendMessage(fwType:FwType) {
		atEve(4, logd("      all parts ||  sendMessage(\(fwType))."))
		let fwEvent 			= HnwEvent(fwType:fwType)
		return receiveMessage(fwEvent:fwEvent)
	}
	 /// Recieve message and broadcast to all children
	func receiveMessage(fwEvent:HnwEvent) {
	//	atEve(4, log("$$$$$$$$ all parts receiveMessage:\(fwTypeDefnNames[fwEvent->fwType])") )))
		for elt in children {				// do for our parts too
			elt.receiveMessage(fwEvent:fwEvent)
		}
	}
	 // MARK: - 8. Reenactment Simulator
	
	/// Reset all Parts of tree
	func reset() {
		for child in children {
			child.reset()
		}
	}
	  /// Perform one micro-step in time simulation
	 /// - up -- direction of scan
	func simulate(up upLocal:Bool) {
		 // Step all my parts:
		let orderedChildren		= upLocal ? children : children.reversed()
		for child in orderedChildren {
			let upInEnt 		= child.flipped ^^ upLocal
			child.simulate(up:upInEnt)		// step all somponents
		}
	}

	  // MARK: - 9. 3D Support
	  // :H: RExxx -- update xxx efficiently
	 // Views are constructed in 4 phases: reVew, Skins, reSize and place
	//		9.1 reVew			-- Build/correct Vew's from Part's. Overrides 190924:
	// 		Net: 				use NetVew; tree height
	//			Link:				only open Links ??
	//			Atom:				Views for Ports
	//			Port:				check not invis or atomic
	//			Discre	eTime:		Inspec's
	//		 *) reVewPost		-- Clean up
	//		9.2 reSize
	// 		Actor:				Insure order of con, ..., evi
	//			Net:				gapTerminalBlock
	//			Atom:				placeOf(portVew
	//		 *) reSizePost			190924: BBox for Net,FwBundle,Leaf,Atom,Port,Part
	//			Atom:				port.reSizePost
	//			Part:				reset PB xform, all children
	//		9.3 Skins			-- reSkinFull, reSkinAtom, reSkinInvisible
	//		9.4 place
	//			Port:				panic
	//		 *)	placeStacked
	//		 *) placeByLinks

	// MARK: - 9.0 make a Vew for Part
	 /// Make a new Vew for self, and add it to parentVew
	func addNewVew(in parentVew:Vew?) -> Vew? {
		let v					= VewForSelf()
		v!.name					= "_" + name			// UNNEEDED
		parentVew?.addChild(v)
		return v
	}
	func VewForSelf() -> Vew? 	{		return Vew(forPart:self)				}

	  // MARK: - 9.1 reVew
	 /// Ensure Vew has proper child Vew's
	/// - Parameter vew_: 	------ Possible Vew of self
	/// - Parameter pVew:   ------ Possible Vew of parent
	/// - Either vew or parentVew must be non-nil
	/// * Depending on self.expose:Expose
	/// * --- .open -> full; .atomic -> sphere; .invisible -> nothing
	func reVew(vew vew_:Vew?=nil, parentVew pVew:Vew?=nil) {
		var vew 				= vew_ ??	// 1 supplied as ARG, or from parent:
								  pVew?.find(part:self, maxLevel:1)
								  			// 2. FIND in parentVew by part
								// 202006PAK: after animation, vew is old "M_xxxx" vew
		 // Discard if it doesn't match self, or names mismatch.
		if let v				= vew,		// Vew supplied and
		 (v.part !== self ||				//  it seems wrong:	//!=
		  v.name != "_" + v.part.name) {
			vew				= nil				// don't use it
		}

		switch vew?.expose ?? initialExpose{// (if no vew, use default in part)

		case .open:					// //// Show insides of Part ////////////
			vew					= vew ?? 	// 3. CREATE:
								  addNewVew(in:pVew)
			 // Remove old skins:
			vew!.scn.find(name:"s-atomic")?.removeFromParent()
			markTree(dirty:.size)

			 // For the moment, we open all Vews
			for childPart in children {
				if	childPart.testNReset(dirty:.vew) ||		// 210719PAK do first, so it gets cleared
				 	childPart.initialExpose == .open    {
					childPart.reVew(parentVew:vew!)
				}
			}

		case .atomic:				// //// "think harder"
			vew					= vew ?? 	// 3. CREATE:
								  addNewVew(in:pVew)
			if vew != nil,
			  vew!.children.count > 0 {
				vew!.removeAllChildren()	// might eliminate later
//				markTree(dirty:.size)		// (.vew loops endlessly!)
			}
			let _				= reSkin(atomicOnto:vew!)	// Put on skin.

		default:					// ////  including .invisible
			if vew != nil {					// might linger
				let _			= reSkin(invisibleOnto:vew!)
			}
		}
		vew?.expose				= vew?.expose ?? initialExpose	// for the future
		vew?.keep				= true
	}
	   /// - Link:			Position Views (e.g. lookAt)
	  /// -	Atom:			Mark unused
	 /// -	Part:			remove Views for unused Parts
	func reVewPost(vew:Vew) {
		vew.keep				= false
		if vew.expose == .open {
			for childVew in vew.children {				// (Post Recursion)
				childVew.part.reVewPost(vew:childVew)
			}
		}
	}
	     // MARK: - 9.2 reSize
	    /// Re-pack vew and children
	   /// - May be called multiply, at the start with .zero .bBox, and after packing internal atoms.
      /// - Parameter vew: -- The Vew to use
     /// - Returns: nothing
	func reSize(vew:Vew) {

		 //------ Put on my   Skin   on me.
		vew.bBox				= .empty			// Set view's bBox EMPTY
		vew.bBox				= reSkin(vew:vew)	// Put skin on Part

		 //------ reSize all  _CHILD Atoms_
		let orderedChildren		= upInWorld==findWorldUp ? vew.children : vew.children.reversed()
		for childVew in orderedChildren where// For all Children, except
		  !(childVew.part is Port) 				// ignore child Ports (Atom handles)
		{	let childPart		= childVew.part

			 // 1. Repack insides (if dirty size):
			if childPart.testNReset(dirty:.size) {
				childPart.reSize(vew:childVew)	// #### HEAD RECURSIVEptv
			}
			  // If our shape was just added recently, it has no parent.
			 //   That it is "dangling" signals we should swap it in
			if childVew.scn.parent == nil {
				vew.scn.removeAllChildren()
				vew.scn.addChild(node:childVew.scn)
			}

			 // 2. Reposition:
			childPart.rePosition(vew:childVew)
			childVew.orBBoxIntoParent()			// child.bbox -> bbox
			childVew.keep		= true
		}

		 //------ Part PROPERTIES for new skin:
		vew.scn.categoryBitMask = FwNodeCategory.picable.rawValue // Make node picable:

		 // ------ color0
		if let colorStr 		= config("color")?.asString,					//localConfig["color"]?.asString,
		  let c	 				= NSColor(colorStr),
		  vew.expose == .open {			// Hack: atomic not colored				//localConfig["color"] = nil
			vew.scn.color0 		= c			// in SCNNode, material 0's reflective color
		}
		markTree(dirty:.paint)

		 //------ Activate Physics:
		if let physConf			= localConfig["physics"] {
			physics(vew:vew, setConfiguration:physConf)
		}
	}
	 // MARK: - 9.3 reSkin
	/// Put skins onto Part.
    /// - Parameter vew: The Vew to use
    /// - Parameter expose_: full, atomic, or invisible, according to expose.
	///			If nil, use View's exposure
    /// - returns: The BBox of the part with new skins on.
    /// - note: The BBox of the view's SCNNode is INVALID at this point. (This is from a problem with non-zero gaps)
	func reSkin(_ expose_:Expose?=nil, vew:Vew) -> BBox 	{
		vew.expose				= expose_ ?? vew.expose
		switch vew.expose {
		case .invis, .null:
			return reSkin(invisibleOnto:vew)	// no skin visible
		case .atomic:
			return reSkin(atomicOnto:vew) 		// atomic skin (sphere/line)
		case .open:
			return reSkin(fullOnto:vew)			// skin of Part
		}
	}
	/// Put on full skins onto a Part
    /// - Parameter vew: -- The Vew to use.
	/// - Returns: FW Bounding Box of skin
	/// - vew.bBox contains value bBox SHOULD be
	/// - Called _ONCE_ to get skin, as Views are constructed:
	func reSkin(fullOnto vew:Vew) -> BBox  {	// Bare Part
		 // No Full Skin overrides; make purple
		let atomBBox			= reSkin(atomicOnto:vew)		// Expedient: uses atomic skins
		vew.scn.children[0].color0 = .purple
		return atomBBox
	}
	static let atomicRadius 	= CGFloat(1)
	func reSkin(atomicOnto vew:Vew) -> BBox 	{

		 // Remove most child skins:	REALLY???
		for childScn in vew.scn.children {
			if childScn.name != "s-atomic" {
				childScn.removeFromParent()
			}
		}
		 // Ensure 1 skin exists:
		var scn4atom : SCNNode
		if vew.scn.children.count == 0 {		// no children
			scn4atom 			= SCNNode(geometry:SCNSphere(radius:Part.atomicRadius/2)) //SCNNode(geometry:SCNHemisphere(radius:0.5, slice:0.5, cap:false))
			scn4atom.name		= "s-atomic"		// Make atomic skin
			scn4atom.color0		= .black			//systemColor
			vew.scn.addChild(node:scn4atom, atIndex:0)
		}
		scn4atom				= vew.scn.children[0]
		return scn4atom.bBox() * scn4atom.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	func reSkin(invisibleOnto vew:Vew) -> BBox {
		vew.scn.removeAllChildren()
//		 // Remove skin named "s-..."
//		if let skin				= vew.scn.find(name:"s-", prefixMatch:true) {
//			skin.removeFromParent()
//		}
//		assert(vew.scn.find(name:"s-", prefixMatch:true)==nil, "Part had more than one skin")
		return .empty
	}

	/// Confures a physicsBody for a Vew.
	/// - Parameters:
	///    vew: 				specifies scn
//	func foo(vew:Vew, setConfiguration config:FwAny?) {
//	}
	
	/// Confures a physicsBody for a Vew.
	/// - Parameters:
	///   * vew 				specifies scn
	///   * config
	///   - FwConfig	==> recognizes keys: gravity, force, and impulse
	///   - Bool	         ==> enable gravity
	///   - nil			==> remove any physicsBody
	func physics(vew:Vew, setConfiguration config:FwAny?) {
		guard let config 		= config else {
			vew.scn.physicsBody	= nil			// remove physicsBody
			return
		}
		assert(!(self is Port) && !(self is Link), "Ports and Links cannot have physics property")

		 // PhysicsBody Shape is   A SPHERE
		let physicsShape		= SCNNode(geometry:SCNSphere(radius:1.5))	// (acceptable simplification)
		physicsShape.name		= "q" + name
		let shape 				= SCNPhysicsShape(node:physicsShape)
		let pb					= SCNPhysicsBody(type:.dynamic, shape:shape)//kinematic OK
		vew.scn.physicsBody		= pb

		 // Default PhysicsBody properties
		pb.contactTestBitMask	= FwNodeCategory.collides.rawValue
		pb.angularVelocityFactor = .zero
		pb.rollingFriction		= 0.0	// resistance to rolling motion.
		pb.restitution			= 1.5	// It determines how much kinetic energy the body loses or gains in collisions.
		pb.damping				= 0.8	// It reduces the body’s linear velocity.
		pb.usesDefaultMomentOfInertia = false // does SceneKit automatically calculates the body’s moment of inertia or allows setting a custom value.
		// not used currently:
		//	pb.resetTransform()
		//	pb.mass				= 1 	// The mass of the body, in kilograms.
		//	pb.charge			= 0 	// electric charge of the body, in coulombs.
		//	pb.angularDamping	= 1		// It reduces the body’s angular velocity.
		//	pb.momentOfInertia 	= SCNVector3(1,1,1) // The moment of inertia, expressed in the local coordinate system of the node that contains the body.

		 // Settable PhysicsBody's properties:
		if let config			= config.asFwConfig {
			for (key, value) in config {
				let val			= SCNVector3(from:value) ?? SCNVector3(0,0.1,0)
				switch key {
				case "impulse":
					pb.applyForce(val, at: SCNVector3.zero, asImpulse:true)
				case "force":
					pb.applyForce(val, at: SCNVector3.zero, asImpulse:false)
				case "gravity":
					let v 			= value.asBool
					assert(v != nil, "gravity: value (\(value)) is not Bool")
					pb.isAffectedByGravity = v!
				default:
					break
				}
			}
			pb.isAffectedByGravity	= false
		}
		else if let doGravity	= config.asBool {
			pb.isAffectedByGravity	= doGravity
		}
	}
	func reSizePost(vew:Vew) {

		 // Do   CHILDREN   first
		for childVew in vew.children { //where !(childVew is LinkVew) {
			childVew.part.reSizePost(vew:childVew)		// #### HEAD RECURSIVE
		}
		  // Reset transforms if there's a PHYSICS BODY:
		 //https://stackoverflow.com/questions/51456876/setting-scnnode-presentation-position/51679718?noredirect=1#comment91086879_51679718
		if let pb				= vew.scn.physicsBody {
			pb.resetTransform()			// scn.transform -> scn.presentation.transform
		}
		vew.updateWireBox()				// Add/Refresh my wire box scn
		vew.scn.isHidden		= false	// Include elements hiden for sizing:
	}
	 // MARK: - 9.4 rePosition
	func rePosition(vew:Vew) { //}, first:Bool=false) {
		guard vew.parent != nil else {		return			}
		 // Get Placement Modep
		let placeMode		=  localConfig["placeMe"]?.asString ?? // I have place ME
							parent?.config("placeMy")?.asString ?? // My Parent has placy MY
										   "linky"				   // default is position by links
		  // Set NEW's orientation (flip, lat, spin) at origin
		vew.scn.transform	= SCNMatrix4(.origin,
								 flip	 : flipped,
								 latitude: CGFloat(lat.rawValue) * .pi/8,
								 spin	 : CGFloat(spin)		 * .pi/8)
		 // First has center at parent's origni
		if vew.parent?.bBox.isEmpty ?? true {
			let newBip		= vew.bBox * vew.scn.transform //new bBox in parent
			vew.scn.position = -newBip.center
		}
		 // Place by stacking
		else if placeMode.hasPrefix("stack") {	// Position Stacked
			assert(placeStacked(inVew:vew, mode:placeMode), "placeStacked failed")
		}
		 // Place by links, errs -> stacking
		else if placeMode.hasPrefix("link")  {	// Position Link or Stacked
			assert(placeByLinks(inVew:vew, mode:placeMode)	// try link first
				|| placeStacked(inVew:vew, mode:"stacky"), "placeByLinks and placeStacked failed")
		}
		else {
			panic("positioning method '\(placeMode)' unknown")
		}
	}
	  /// STACK selfNode onto side, per PARENT's placeBy:
	 /// - e.g: "placeMy":"stackX 1 1" stacks on -x axis, aligning corners in +y and +z
	func placeStacked(inVew vew:Vew, mode:String) -> Bool {
		if vew.parent != nil {
			  // :H:		 	   ..BBoxInP -- BoundingBox In Parent coords
			 // 			 StacKeD objects -- are those already included in parent
			// 					  NEW object -- being added, (= self)
			var newBip			= vew.bBox * vew.scn.transform //new bBox in parent
			var rv				= -newBip.center // center selfNode in parent
			newBip.center		= .zero
			atRsi(4, vew.log(">>===== Position \(self.fullName) by:\(mode) (stacked) in \(parent?.fullName ?? "nil") "))
			let stkBip 			= vew.parent!.bBox
			rv		 			+= stkBip.center // center of stacked in parent
			let span			= stkBip.size + newBip.size	// of both parent and self
			let slop			= stkBip.size - newBip.size	// amount parent is bigger than self
			atRsi(6, vew.log("   newBip:\(newBip.pp(.phrase)) stkBip:\(stkBip.pp(.phrase))"))
			atRsi(5, vew.log("   span:\(span.pp(.short)) slop:\(slop.pp(.short))"))	//\(stkBip.size.pp(.phrase)) += \(newBip.size.pp(.phrase)):

			  // e.g. mode = "stackY 0.5 1"
			 // determine: u0,u1,u2, stackSign, alignU1, alignU2
			let modeWords:[Substring] = mode.split(separator:" ")
			let c 				= String(modeWords[0].last!)
			guard let stackAxis:Int = ["x":0,"y":1,"z":2,"X":3,"Y":4,"Z":5][c] else {
				panic("No x/y/z axis specifier in  mode:\(mode)")
				return false
			}
			  // Determine which Axis to stack on (u0), and which others to center:
			let (u0, u1, u2)	= (stackAxis%3, (stackAxis+1)%3, (stackAxis+2)%3)	// 0=x, 1=y, 2=z
			let stackSign:CGFloat =  stackAxis < 3 ? 0.5 : -0.5
			 // Align to:	 -1:minusCorners, 0:centers, 1:plusCorners
			var alignU1 		= Float(0.0)	/// ( stackAxis + 1 ) % 3
			if modeWords.count > 1,
			  let a1 			= Float(modeWords[1]) {
				alignU1			= 0.5 * a1
			}
			var alignU2 		= Float(0.0)	/// ( stackAxis + 2 ) % 3
			if modeWords.count > 2,
			  let a2 			= Float(modeWords[2]) {
				alignU2			= 0.5 * a2
			}
			let ax				= ["x", "y", "z"] 
			atRsi(5, vew.log("   Stack:\(stackSign > 0 ? "+" : "-")\(ax[u0]): Align \(ax[u1])=\(alignU1), \(ax[u2])=\(alignU1)"))

			 // the move (delta) to put self's bBox centered within parent's bBox
			   // Place next Vew (self) on side of stacked parts   \\\
			  //   Calculation done in p parent's coord system      \\\
			 //   assumes self.transform has only 90deg's turns      \\\
			//( Consider just \[min+---o----------------+max  stk     )))
			 //\   the X axis:/[  min+-o--+max                new    ///
			  //\  o = origin/      AABBBBBCCCCCCCCCCCCCC           ///
			   //\   span: A + 2*B + C,   slop = A + C             ///

			/*==Parent's Coords     	IN MORE DETAIL:
			||                      0      2        v~---- origin
			||   stkBBox            +---s--+        o<----------- parent SCNNode
			||                    +====p===+
			||   slop:             --            p - s = -1
			||   span:     +====p===+--s---+     p + s = 3
			||   newSelfPosition   +===p===+
			\\   selfBip:          +===p===+         |
			 >>==                /       /         /position xform
			//                  +===p===+         o<--------------- self SCNNode
			\\==My Coords   -.5     .5*/

			 // Stack self in axis u0, onto a side of parent, extending it:
			rv[u0] 				+= span[u0] * stackSign		// NB: SCNVector3[Int] yields component numbered Int
			 // Center self on Parent's face: [-1:left, 0:center, 1:right]
			rv[u1] 				+= slop[u1] * alignU1
			rv[u2] 				+= slop[u2] * alignU2

			let gap				= config("gapStackingInbetween")?.asCGFloat ?? 0.0
			rv[u0] 				+= gap * stackSign		/// gap on stacking axis
				 // H A C K: !!!!
			rv					+= SCNVector3(newBip.center.x,0,newBip.center.z)
	//		let delta			= newBip.center - stkBip.center
	//		rv					+= SCNVector3(delta.x,0,delta.z) /// H A C K !!!!
			atRsi(4, vew.log("<<===== rv=\(rv.pp(.short))\n"))
			vew.scn.position	= rv + (vew.jog ?? .zero)
	//		vew.scn.transform	= SCNMatrix4(rv + (vew.jog ?? .zero))
		}
		return true		// Success
	}
	  /// Place Atoms by Links
	 /// - raw parts not positioned by links:
	func placeByLinks(inVew vew:Vew, mode:String?=nil) -> Bool {
		return false		 
	}

	   // MARK: - 9.5: Render Protocol
	 // MARK: - 9.5.2: didApplyAnimations 		-- Compute spring forces
	func computeLinkForces(vew:Vew) {
		for childVew in vew.children {			// by Vew
			childVew.part.computeLinkForces(vew:childVew) // #### HEAD RECURSIVE
		}
	}
	  // MARK: - 9.5.3: did Simulate Physics 	-- Apply spring forces
	 /// Distribute Forces
	func applyLinkForces(vew:Vew) {
		for childVew in vew.children {			// repeat over Vew tree
			childVew.part.applyLinkForces(vew:childVew) // #### HEAD RECURSIVE
		}
		if let pb 				= vew.scn.physicsBody,
		  !(vew.force ~== .zero) {					/// to all with Physics Bodies:
			pb.applyForce(vew.force, asImpulse:false)
			atRve(9, logd(" Apply \(vew.force.pp(.line)) to    \(vew.pp(.fullName))"))
//			atRve(9, logd(" posn: \(vew.scn.transform.pp(.line))"))
		}
		vew.force				= .zero
	}
	 // MARK: - 9.5.5: will Render Scene -- Rotate Links toward camera
	func rotateLinkSkins(vew:Vew) {
		for childVew in vew.children {			// by Vew
			childVew.part.rotateLinkSkins(vew:childVew) // #### HEAD RECURSIVE
		}
	}


	  // MARK: - 9.6: Paint Image:
	func rePaint(vew:Vew) 	{		/* prototype */
		for childVew in vew.children 				// by Vew
		  where childVew.part.testNReset(dirty:.paint) {
			childVew.part.rePaint(vew:childVew)		// #### HEAD RECURSIVE
		}
		assertWarn(!vew.scn.transform.isNan, "vew.scn.transform == nan!")
	}

	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: ---- NSEvent to process
    /// - Parameter vew: ---- The 3D scene Vew to use
	/// - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		var rv					= false
		if nsEvent.type == .keyUp || nsEvent.type == .keyDown {
			let kind			= nsEvent.type == .keyUp ? ".keyUp" : ".keyDown"
			print("\(pp(.fwClassName)):\(fullName): NSEvent (key(s):'\(nsEvent.characters ?? "-")' \(kind)")
		}
		else {			 // Mouse event
			var doc				= root?.fwGuts?.document	// take struct out
			print("    NSEvent (clicks:\(nsEvent.clickCount)) ==> \(pp(.fullName)) :"
											+ "\(pp(.fwClassName))\n\(pp(.tree))")
			 // SINGLE/FIRST CLICK  -- INSPECT									// from SimNsWc:
			if nsEvent.clickCount == 1 {
				 		// // // 2. Debug switch to select Instantiation:
				let alt 		= nsEvent.modifierFlags.contains(.option)
				if let vew {
					doc?.showInspecFor(vew:vew, allowNew:alt)
					rv			= true
				}
			}
						// Double Click: show/hide insides
			if nsEvent.clickCount > 1 {
				if let vew {
					doc?.fwGuts?.toggelOpen(vew:vew)
					rv			= true
				}
			}
			else if nsEvent.clickCount == 2 {		///// DOUBLE CLICK or DOUBLE DRAG   /////
				
bug				 // Let fwPart handle it:
				print("-------- mouseDragged (click \(nsEvent.clickCount))\n")

				 // Process the FwwEvent to the picked Part's Vew:
				let m : Part 	= vew!.part
bug;			let _			= m.processEvent(nsEvent: nsEvent, inVew:vew)	
			//	[m sendPickEvent:&fwEvent toModelOf:pickedVew]
			//	[self.simNsVc buildRootFwVforBrain:self.brain]	// model may have changed, so remake vew
			}
			root?.fwGuts?.document = doc				// Put struct back
		}
		return rv
	}

	//------------------------------ Printout -- pretty print ------------------------
	 // MARK: - 14. Logging
	let nFullN					= 18//12
//	func logg(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
//		let msg					= String(format:format, arguments:args)
//		let (nls, str2)			= msg.stripLeadingNewLines()
//		let str					= nls + (pp(.uidClass) + ":").field(-nFullN) + str2
//		DOClogger.log(str, terminator:terminator)
//	}
	func warning(_ format:String, _ args:CVarArg...) {
		let fmtWithArgs			= String(format:format, arguments:args)
		let targName 			= fullName.field(nFullN) + ": "
		warningLog.append(targName + fmtWithArgs)
		root != nil ? root!.log(banner:"WARNING", targName + fmtWithArgs + "\n")
					: print("WARNING" + targName + fmtWithArgs  + "\n")
	}
	func error(_ format:String, _ args:CVarArg...) {
		logNErrors 				+= 1
		let fmtWithArgs			= String(format:format, arguments:args)
		let targName 			= fullName.field(nFullN) + ": "
		root != nil ? root!.log(banner:"ERROR", targName + fmtWithArgs + "\n")
					: print("ERROR", targName + fmtWithArgs + "\n")
	}

	func ppUnusedKeys() -> String {
		let uid					= ppUid(self)
		let approvedConfigKeys	= ["placeMe", "placeMy", "portProp", "l", "len", "length"]
		let dubiousConfig		= localConfig.filter { key, value in !approvedConfigKeys.contains(key) }
		var rv 					= dubiousConfig.count == 0 ? "" :	// ignore empty configs
  								  "######\(pp(.fullNameUidClass).field(35)) UNUSED KEY: \(dubiousConfig.pp(.line))\n"
		for child in children {
			rv					+= child.ppUnusedKeys()
		}
		return rv
	}
	 //	 MARK: - 15. PrettyPrint
	// Override: Method does not override any method from its superclass
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{		// Why is this not an override
		var rv					= ""
		switch mode! {
		case .name:
			return name
		case .fullName:
			rv					+= fullName
		case .fullNameUidClass:
			return "\(name)\(ppUid(pre:"/", self)):\(fwClassName)"
//		case .uidClass:
//			return "\(ppUid(self)):\(fwClassName)"	// e.g: "xxx:Port"
//		case .classUid:
//			return "\(fwClassName)<\(ppUid(self))>"	// e.g: "Port<xxx>"
		case .phrase, .short:
			return "\(name):\(pp(.fwClassName, aux)) \(children.count) children"
		case .line:
			  //      AaBbbbbbCccDdddddddddddddddddddddddEeeeeeeeeeeee
			 // e.g: "Ff| | | < 0      prev:Prev  o> 76a8  Prev mode:?
			rv					= ppUid(self, post:" ", aux:aux)
			rv					+= (upInWorld ? "F" : " ") + (flipped ? "f" : " ")	// Aa
			rv 					+= logger.indentString()							// Bb..
			let ind				= parent?.children.firstIndex(where: {$0 === self})			//firstIndex(of:self)
			rv					+= ind != nil ? fmt("<%2d", Int(ind!)) : "<##"		// Cc..
				// adds "name;class<unindent><Expose><ramId>":
			rv					+= ppCenterPart(aux)								// Dd..
			if config("physics")?.asBool ?? false {
				rv				+= "physics,"
			}
			if aux.bool_("ppParam") {
				rv 				+= localConfig.pp(.line)
			}
																					// Ee..
		case .tree:
			let ppDagOrder 		= aux.bool_("ppDagOrder")	// Print Ports early
			let reverseOrder	= ppDagOrder && (upInWorld ^^ printTopDown) //trueF//falseF//

			if ppDagOrder {				// Dag Order
				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:true)
				rv				+= ppSelf	 (aux)
			}
			else {
				rv				+= ppSelf	 (aux)
				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:true)
			}
		default:
			return ppDefault(self:self, mode:mode, aux:aux)// NO return super.pp(mode, aux)
		}
		return rv
	}
	func ppCenterPart(_ aux:FwConfig) -> String {
		var rv 			 		=  name.field(10) + ":"					// " net0:"
		rv 						+= fwClassName.field(-6, dots:false)	// "Net "
		rv 						=  logger.unIndent(rv)
//		rv 						=  root?.logger.unIndent(rv) ?? "___ "
//		rv 						+= root?.log.unIndent(rv) ?? "___ "
		rv						+= initialExpose.pp(.short, aux)		// "o"
		rv						+= dirty.pp()
//		rv						+= " s:\(spin)"
//		rv						+= " l:\(lat)"
		return rv + " "
	}
	  //	 MARK: - 15.1 pp support
	 /// Print children
	func ppSelf(_ aux:FwConfig) -> String {
		let rv					= mark_line(aux, pp(.line, aux) + "\n")
		return rv
	}
	 /// Print children
	func ppChildren(_ aux:FwConfig, reverse:Bool, ppPorts:Bool) -> String {
		var rv					= ""
		logger.nIndent			+= 1		//root?.
		let orderedChildren		= reverse ? children.reversed() : children
		for child in orderedChildren where ppPorts || !(child is Port) {
			 // Exclude undesireable Links
			if !(child is Link) || aux["ppLinks"]?.asBool == true {
				rv				+= mark_line(aux, child.pp(.tree, aux))
			}
		}
		logger.nIndent			-= 1
		return rv
	}
	 /// Print Ports
	func printPorts(_ aux:FwConfig, early:Bool) -> String {
		var rv 					= ""
		logger.nIndent			+= 1		// root?.
		if logger.ppPorts {	// early ports // !(port.flipped && ppDagOrder)
			for part in children {
				if let port 	= part as? Port,
				  early == port.upInWorld {
					rv			+=  mark_line(aux, port.pp(.line, aux) + "\n")
				}
			}
		}
		logger.nIndent			-= 1
		return rv
	}
	 /// Marking line with '_'s improves readability
	func mark_line(_ aux:FwConfig, _ line:String) -> String {
		var rv					= line
		if nLinesLeft == 1 {
			let sta 			= line.index(line.startIndex, offsetBy: 0)
			let end 			= line.index(line.startIndex, offsetBy: min(line.count, 30))
			let range			= Range(uncheckedBounds:(lower:sta, upper:end))
			rv					= line.replacingOccurrences(of:" ", with:"_", range:range)
		}
		nLinesLeft				-= nLinesLeft != 0 ? 1 : 0	// decrement if non-zero
		return rv
	}
	 // MARK: - 16. Global Constants
	static let null 			= Part(["n":"null"])	// Any use of this should fail (NOT IMPLEMENTED)
	 // MARK: - 17. Debugging Aids
	var description	  : String 	{	return  "\"\(pp(.short))\""	}
	var debugDescription : String	{	return   "'\(pp(.short))'"		}
//	var summary					  : String	{	return   "<\(pp(.short))>"		}

//	 // MARK: - 19. Inspector SwiftUI.Vew
//	static var body : some Vew {
//		Text("Part.body lives here")
//	}
}
 /// Pretty print an up:Bool as String
func ppUp(_ up:Bool?=nil) -> String {
	return up==nil ? "<nil>" : up! ? "up" : "down"
}
