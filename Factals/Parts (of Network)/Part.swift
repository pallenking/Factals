// Part.swift -- Base class for Factal Workbench Models C2017PAK

import Foundation
import SceneKit
import SwiftUI

//// Josh:
//class A {}
//class B: A {}
//let superclassOfB	: AnyClass? = Swift._getSuperclass (B.self)
//let superclassOfPoly: AnyClass? = Swift._getSuperclass (Part.self)

protocol EquatableFW {
	func equalsFW(_:Part) -> Bool
}
extension Part : EquatableFW {													}

 // NOTE: 20230117 Equatable was only added for Hashable for ForEach for 
extension Part : Equatable {
	static func ==(lhs: Part, rhs: Part) -> Bool {
		return lhs.equalsFW(rhs)
	}
}
 // Generic struct 'ForEach' requires that 'Part' conform to 'Hashable' (from InspecPart.body.Picker)
extension Part : Hashable {
	func hash(into hasher: inout Hasher) {
		//DOClog.log("\(pp(.fullName)) hasher.combine(\(String(format: "%02X", nameTag)))")
		hasher.combine(nameTag)					// fwClassName, fullName, children?
	}
}

 /// Base class for Factal Workbench Models
// Used to be based on NSObject, not now.  What about NSCopying, NSResponder,
class Part : Codable, ObservableObject, Uid, Logd {			//, Equatable Hashable
	var nameTag					= getNametag()
	 // MARK: - 2. Object Variables:
	@objc dynamic var name		= "<unnamed>"
	var children	: [Part]	= []
	var child0		:  Part?	{	return children.count==0 ? nil : children[0]}
	weak
	 var parent 	:  Part?	= nil 	// add the parent property
	weak
	 var partBase	: PartBase?	= nil	//

	func checkTreeThat(parent p:Part?, partBase pb:PartBase?) -> Bool {
		var wasOk				= parent===p && partBase===pb
		parent 					= p
		partBase 		  		= pb
		for child in children {
			wasOk				&&= child.checkTreeThat(parent:self, partBase:partBase)
		}
//		wasOk					= children.reduce(wasOk) { (wasOk, child) in
//			wasOk && child.checkTreeThat(parent:self, partBase:partBase)
//		}
	//	print("######### \(pp(.fullName)): \(pp(.classUid)) returns \(wasOk)")
		return wasOk
	}

	var dirty : DirtyBits		= .clean	// (methods in SubPart.swift)
//	{	willSet(v) {  markTree(dirty:v) }  }// BIG PROBLEMS: (Loops!)
	var partConfig	: FwConfig				// Configuration of Part
	 // Ugly:
	var nLinesLeft	: UInt8		= 0			// left to print in current atom

	 // MARK: - 2.1 Sugar
	var parts 		: [Part]	{ 		children 								}
	/*@objc dynamic*/
	var fullName	: String	{
		return parent==nil  ? 		"/" + name :
			   parent!.fullName + 	"/" + name


//		let rv					= parent==nil  ? "" :
//								  parent!.fullName + "/" + name		// add lefter component
//		return rv
	}
	var fullName16 	: String	{		return fullName.field(16)				}
	 // - Array of unsettled ports. Elements are closures that returns the Port's name
	func portChitArray() -> [()->String]	{
		var rv					= [()->String]()
		for child in children {
			rv					+= child.portChitArray()
		}
		return rv
	}

	 // MARK: - 2.4 Display Suggestions
	var initialExpose : Expose	= .open		// Hint to use on dumb creation of views. (never changed)
			// See View.expose for GUI interactions
	var flipped : Bool = false
	{	didSet {	if flipped != oldValue {
						markTree(dirty:.size)
																		}	}	}
 //================= to the world:
	var downInWorld : Bool {
		var rv 					= false
		for p in selfNParents() {			//		for (Part *p=self; p.parent; p=p.parent)
			rv = rv != p.flipped;//^=		// rv now applies from self
		}
//		assert(rv == selfNParents().reduce(into:true) { rv, p:Part in rv = rv && (p == p.flipped)}, "OOps should ==")
		return rv;
	}

	 // MARK: - 2.2b INTERNAL to Part
	var lat : Latitude = Latitude.northPole 			// Xyzzy87 markTree
	{	didSet {	if lat != oldValue {
						markTree(dirty:.size)
																		}	}	}
  //var longitude
	var spin : UInt8 = 0
	{	didSet {	if spin != oldValue {
						markTree(dirty:.size)
																		}	}	}
	var shrink : Int8 = 0			// smaller or larger as one goes in
	{	didSet {	if shrink != oldValue {
						markTree(dirty:.size)
																		}	}	}
	var log : Log { partBase?.log ?? Log.app}
//	var log : Log { partBase?.log ?? { debugger("partBase not setup in Part") }()}

	 // MARK: - 2.2c EXTERNAL to Part
	// - position[3], 						external to Part, in Vew

	 // MARK: - 2.5 SwiftUI Stuff
	 // just put here to get things working?
	var placeSelf = ""				// from config!
	{	didSet {	if placeSelf != oldValue {
						markTree(dirty:.vew)
																		}	}	}
// ///////////////////////////// Factory //////////////////////////////////////
	// MARK: - 3. Part Factory
	/// Base class for Factal Workbench Models
	/// - Value "n", "name", "named": name of element
	/// - Parameter config: FwConfig configuration hash 
	init(_ config:FwConfig = [:]) {
		partConfig				= config		// Set as my local configuration hash

		var nam : String?		= nil
		 // Do this early, to improve creation printout
		for key in ["n", "name", "named"] {		// (Name has 3 keys)
			if let na:String 	= partConfig[key] as? String {
				assert(nam==nil, "Conflicting names: '\(nam!)' != '\(na)' found")
				nam				= na
				partConfig[key] = nil			// remove from config
			}
		}			// -- Name was given
		name					= nam ?? { [self] in
			if let partBase		= partBase,
			  let prefix		= prefixForClass[fwClassName]
			{		// -- Use Default name: <shortName><index> 	(e.g. G1)
				let index		= partBase.indexFor[prefix] ?? 0
				partBase.indexFor[prefix] = index + 1		// for next
				return prefix + String(index)
			} else {	// -- Use fallback
				defaultPrtIndex	+= 1
				return "prt" + String(defaultPrtIndex)
			}
		}()

		 // Print out invocation
		let n					= ("\'" + name + "\'").field(8)
		atBld(6, logd("  \(n)\(pp(.nameTag)):\(fwClassName.field(12))(\(partConfig.pp(.line)))"))

		 // Options:
		if let valStr			= partConfig["expose"] as? String,
		  let e : Expose		= Expose(string:valStr) {
			initialExpose		= e
			partConfig["expose"] = nil
		}
		for key in ["f", "flip", "flipped"] {
			if let ff			= partConfig[key],		// in config
			  let f				= Bool(fwAny:ff) {			// can be Bool
				flipped 		= f
				partConfig[key] = nil
			}
		}
		for key in ["lat", "latitude"] {
			if let ff			= partConfig[key] {
				if let f		= Int(fwAny:ff),
				  let g			= Latitude(rawValue:f) {
					lat				= g
					partConfig[key] = nil
				}
			}
		}
		if let s				= UInt8(fwAny:partConfig["spin"]) {
			spin 				= s
			partConfig["spin"] = nil
		}

		if let a 				= partConfig["parts"] as? [Part] {
			a.forEach { addChild($0) }						// add children in "parts"
			partConfig["parts"] = nil
		}
		if let parts 			= partConfig["parts"] {
			let arrayOfParts	= parts as? [Part]
			assert(arrayOfParts != nil, "Net([parts:<val>]), but <val> is not [Part]")
			arrayOfParts!.forEach { addChild($0) }				// add children in "parts"
			partConfig["parts"] = nil
		}
	}
	required init?(coder: NSCoder) { debugger("init(coder:) has not been implemented")}
	deinit {//func ppUid(pre:String="", _ obj:Uid?, post:String="", showNil:Bool=false, aux:FwConfig = [:]) -> String {
		atBld(3, print("#### DEINIT    \(ppUid(self)):\(fwClassName)")) // 20221105 Bad history deleted
	}

//	func configNames(config:FwConfig = [:]) {
//		var nam : String?		= nil
//		 // Do this early, to improve creation printout
//		for key in ["n", "name", "named"] {		// (Name has 3 keys)
//			if let na:String 	= config[key] as? String {
//				assert(nam==nil, "Conflicting names: '\(nam!)' != '\(na)' found")
//				nam				= na
//				//config[key]	= nil			// remove from config
//			}
//		}			// -- Name was given
//		name					= nam ?? { [self] in
//			if let partBase		= partBase,
//			  let prefix		= prefixForClass[fwClassName]
//			{		// -- Use Default name: <shortName><index> 	(e.g. G1)
//				let index		= partBase.indexFor[prefix] ?? 0
//				partBase.indexFor[prefix] = index + 1		// for next
//				return prefix + String(index)
//			} else {	// -- Use fallback
//				defaultPrtIndex	+= 1
//				return "prt" + String(defaultPrtIndex)
//			}
//		} ()
//		children.forEach {	$0.configNames(config:config)	}
//	}
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
		let polyWrap			= PolyWrap([:])		// (B) backlink
		polyWrap.name			= "---"				// works nice with pp(.tree)
		polyWrap.addChild(self)						// We are poly's child
		parent					= polyWrap			// Backlink: our parent is poly

		 // PolyWrap all Part's children
		// NFG: children		= children.polyWrap()
		for i in 0..<children.count {
			 // might only wrap polymorphic types?, but simpler to wrap all
			children[i]			= children[i].polyWrap()		// RECURSIVE			// (C)
			children[i].parent	= self													// (D) backlink
		}
		return polyWrap
	}
	func polyUnwrap() -> Part {		debugger("Part.polyUnwrap should be overridden by PolyWrap or Parts")	}
	  // MARK: - 3.5 Codable
	 //https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
	enum PartsKeys: String, CodingKey {
		//case nameTag			// IGNORE
		case name
		case children		// --- (SUBSUMES .parts)
		//case parent		// IGNORE, weak, reconstructed
		//case root_		// IGNORE, weak regenerate
		case nLinesLeft		// new
		case dirty
		case partConfig		// ERRORS: want FwConfig to be Codable?
//		case config			// IGNORE: temp/debug FwConfig	= ["placeSelfy":"foo31"]
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
		var container 			= encoder.container(keyedBy:PartsKeys.self)

		try container.encode(name, 			forKey:.name)
		try container.encode(children,		forKey:.children)		// ignore parts. (it's sugar for children)

		try container.encode(nLinesLeft,	forKey:.nLinesLeft)		// ignore parts. (it's sugar for children)

	//	try container.encode(partConfig,	foarKey:.partConfig)	// FwConfig not Codable!//Protocol 'FwAny' as a type cannot conform to 'Encodable'
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
		partConfig				= [:]//try container.decode(FwConfig.self,forKey:.partConfig)
//		super.init()	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		let container 			= try decoder.container(keyedBy:PartsKeys.self)
			//  po container.allKeys: 0 elements

		name 					= try container.decode(	   String.self, forKey:.name)
		children				= try container.decode([PolyWrap].self, forKey:.children)
		children.forEach({ $0.parent = self})	// set parent
		// root?
		nLinesLeft				= try container.decode(		UInt8.self, forKey:.nLinesLeft)
		partConfig 			= [:]	// PUNT
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
//		theCopy.partConfig		= self.partConfig
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
	 // MARK: - 3.7 EquatableFW
	// https://forums.swift.org/t/implement-equatable-protocol-in-a-class-hierarchy/13844
	// https://stackoverflow.com/questions/39909805/how-to-properly-implement-the-equatable-protocol-in-a-class-hierarchy
	// https://jayeshkawli.ghost.io/using-equatable/
	  // Allow Arrays of Equatables to be Equatable
	 // https://jayeshkawli.ghost.io/using-equatable/

	// 2023-0725PAK: EquatableFW uses ".equals()", not "==". This prevents abuse
//	static func ==(lhs:Part, rhs:Part) -> Bool {
//		//bug  			// Option for abuse-checking: Illegal to use
//		guard type(of:lhs) == type(of:rhs)	else {	return false				}
//		let rv					= lhs.equals(rhs)	// "==" means equivalent values
//  	//let rv  				= lhs === rhs		// "==" means same object
//		return rv
//	}

	func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					  else {	return true				}
		let rv 					= true				// Swift types use "=="
			&& type(of:self) 	== type(of:rhs)			// A
			&& fwClassName 		== rhs.fwClassName		// B==A
			&& name				== rhs.name
			&& nLinesLeft		== rhs.nLinesLeft
			&& dirty			== rhs.dirty			// allowed to differ
		//	&& partConfig		== rhs.partConfig		// not Equatable
		//	&& config			== rhs.config			// not Equatable
			&& initialExpose 	== rhs.initialExpose
			&& flipped			== rhs.flipped
			&& lat				== rhs.lat
			&& spin				== rhs.spin
			&& shrink			== rhs.shrink
			&& placeSelf		== rhs.placeSelf
		guard rv									else {	return false}
		 // Paw through children by hand:
		guard  children.count == rhs.children.count else {	return false}
		for i in 0 ..< children.count {				// Parts use ".equals()"
			guard children[i].equalsFW(rhs.children[i])else {	return false }
		}
		return true
	}
	func containsFW(_ part:Part) -> Bool {
		bug
		return false
	}

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
		guard let child 		else {		return								}
		assert(self !== child, "can't add self to self (non-exhaustive check)")
 // 20241019PAK: uses == on Part, which is depricated?
//		assert(!children.containsFW(child), "Adding child that's already there")

		 // add at index
		if var index {							// Find right spot in children
			if index < 0 {						// Negative are distance from end
				index = children.count - index
			}
			assert(index>=0 && index<=children.count, "index \(index) out of range")
			children.insert(child, at:index)	// add at index
		}
		else {	// add at end
			children.append(child)
		}

		 // link in as self
		child.parent			= self
		child.partBase			= self.partBase
		let a 					= child.checkTreeThat(parent:self, partBase:partBase)

		 // Process tree dirtyness:
		markTree(dirty:.vew)				// ? tree has dirty.vew
		markTree(dirty:child.dirty)			// ? tree also inherits child's other dirtynesses
	}										// (child is not dirtied any more)
	/// Groom Part tree after construction.
	/// - Parameters:
	///   - parent_: ---- if known
	///   - root_: ---- set in Part
	func groomModel(parent p:Part?, partBase r:PartBase?)  {
		parent					= p
		if partBase == nil || partBase !== r {
			print("This will probably ERR ..... ####### ")
			partBase			=  r					// from arg (if there)
			assert(r != nil, "protocol error")
	//							?? self as? PartBase 	// me, I'm a RootPart
	//							?? child0 as? PartBase	// if PolyWrapped
		}
		markTree(dirty:.vew)							// set dirty vew

		for child in children {							// do all children
			child.groomModel(parent:self, partBase:partBase)	// ### RECURSIVE
		}
	}

	func groomModelPostWires(partBase:PartBase)  {
		 // Check for duplicate names:
		var allNames : [String] = []
		for child in children {
			assertWarn(!allNames.contains(child.name), "\(self.fullName) contains duplicate name \(child.name)")
			allNames.append(child.name)
		}
		 // Do whole tree
		for child in children {
			child.groomModelPostWires(partBase:partBase) 	// ### RECURSIVE
		}
	}

	 // Get Part's configuration from partConfig of Part and parents, and model
	func config(_ name:String) -> FwAny? {
		 // Look in self and parents:
		for s in selfNParents {					 // look in: self, parent?,...,root
			if let rv			= s.partConfig[name] {
				return rv							 // found in self and ancestor's config
			}
		}										 // Look in application:
		return partBase?.factalsModel?.fmConfig[name]  // ?? Look in doument
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
			rv.append(ancestor!)
			ancestor 			= ancestor!.parent
		}
		return rv
	}

	/// Class Inheritance Ancestor Array, from self up to but excluding 'inside'
	func inheritedClasses() -> [String] {
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
		debugger("self:\(fullName) and endPart:\(endPart.fullName) don't share a root")
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
	 /// Find Part with desired name
	/// - name		-- sought name
	func find(name desiredName:String,
								
			  up2 			 	: Bool	= false,
			  inMe2				: Bool	= false,
			  maxLevel			: Int?	= nil) -> Part? { // Search by name:
		return findCommon(up2:up2, inMe2:inMe2, maxLevel:maxLevel) {
			$0.fullName.contains(desiredName) ? $0 : nil
		}		//$0.fullName == desiredName ? $0 : nil
	}
	   /// A boolean predicate of a Part
	typealias Part2PartClosure 	= (Part) -> Part?
	func find(path				: Path,

			  up2				: Bool	= false,
			  inMe2 			: Bool	= false,
			  maxLevel			: Int?	= nil) -> Part? { // Search by Path:
		return findCommon(up2:up2, inMe2:inMe2, maxLevel:maxLevel) {
			$0.partMatching(path:path)
		}
	}
	func find(part				: Part,

			  up			 	: Bool	= false,
			  inMe2 			: Bool	= false,
			  maxLevel 			: Int?	= nil) -> Part? { // Search for Part:
		return findCommon(up2:up, inMe2:inMe2, maxLevel:maxLevel) {
			$0 === part ? $0 : nil
		}
	}

	 /// First where closure is true:
	/// - up		-- search parent outward
	/// - mineBut	-- search children of node, except this child
	/// - except	--  (node to exclude in search)
	/// - maxLevel	-- search children down to this level
	/// - except	-- don't search, already search
	func findCommon(
					up2		 :Bool	= false,			// search relatives of my parent
					inMe2	 :Bool	= true,				// search me
					mineBut  :Part?	= nil,				// search my children, except
					maxLevel :Int?	= nil,
					firstWith:Part2PartClosure) -> Part? { /// Search by closure:
		 // Check self:
		if inMe2,
		  let cr 				= firstWith(self) {		// Self match?
			return cr
		}
		if (maxLevel ?? 1) > 0 {		// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
			let orderedChildren	= (upInWorld ^^ findWorldUp) ? children.reversed() : children
			 // Check children:
			for child in orderedChildren
			  where mineBut === nil || child !== mineBut! { // don't redo exception
				if let rv 		= child.findCommon(up2:false, mineBut:self, maxLevel:mLev1, firstWith:firstWith) {
					return rv
				}
			}
		}
		if up2,								// Check parent
		  let parent {						// Have parent
			return parent.findCommon(up2:true, mineBut:self, maxLevel:maxLevel, firstWith:firstWith)
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
	func gatherLinkUps(into linkUpList:inout [() -> ()], partBase:PartBase) {    //was gatherWiresInto:wirelist]
		 // Gather wires from  _children_   into wirelist first:
		for child in children {
			if let atom       	= child as? Atom {
				atom.gatherLinkUps(into:&linkUpList, partBase:partBase)  // ### RECURSIVE
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
	func VewForSelf() -> Vew? 	{
		return Vew(forPart:self)
	}
	  // MARK: - 9.1 reVew
	 /// Ensure Vew has proper child Vew's
	/// - Parameter vew_: 	------ Possible Vew of self
	/// - Parameter pVew:   ------ Possible Vew of parent
	/// - Either vew or parentVew must be non-nil
	/// * Depending on self.expose:Expose
	/// * --- .open -> full; .atomic -> sphere; .invisible -> nothing
	func reVew(vew vew_:Vew?=nil, parentVew pVew:Vew?=nil) {
		var vew 	= vew_ ??							// 1 supplied as ARG, or from parent:
					  pVew?.find(part:self, maxLevel:1)	// 2. FIND in self in parentVew
		 // Discard if it doesn't match self, or names mismatch.
		if let v		= vew,							// Vew supplied and
		 (v.part !== self ||							//  it seems wrong:	//!=
		  v.name != "_" + v.part.name) {
			vew				= nil							// don't use it
		}

		switch vew?.expose ?? initialExpose { // (if no vew, use default in part)

		case .open:					// //// Show insides of Part ////////////
			vew					= vew ??
								  addNewVew(in:pVew) 	// 3. CREATE:
			 // Remove old skins:
			vew!.scnRoot.find(name:"s-atomic")?.removeFromParent()
			markTree(dirty:.size)

			 // For the moment, we open all Vews
			for childPart in children {
//bug//NReset
				if	childPart.test(dirty:.vew) ||		// 210719PAK do first, so it gets cleared
				 	childPart.initialExpose == .open    {
					childPart.reVew(parentVew:vew!)
				}
			}

		case .atomic:				// //// "think harder"
			vew					= vew ??
								  addNewVew(in:pVew) 	// 3. CREATE:
			if vew != nil,
			  vew!.children.count > 0 {
				vew!.removeAllChildren()	// might eliminate later
//				markTree(dirty:.size)		// (.vew loops endlessly!)
			}
			let _				= reSkin(atomicOnto:vew!)	// xyzzy32 -- Put on skin after going atomic.
// sound support bulse wireless headphones case: 02108778 $195 june
		default:					// ////  including .invisible
			if vew != nil {					// might linger
				let _			= reSkin(invisibleOnto:vew!)				// xyzzy32
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
		vew.bBox				= reSkin(expose:.same, vew:vew)	// Put skin on Part	// xyzzy32 xyzzy18

		 //------ reSize all   _CHILD Atoms_     No Ports
		let orderedChildren		= upInWorld==findWorldUp ? vew.children : vew.children.reversed()
		for childVew in orderedChildren 	// For all Children, except
		  where !(childVew.part is Port) 		// Atom handles child Ports
		{	let childPart		= childVew.part

			 // 1. Repack insides (if dirty size):
			if childPart.test(dirty:.size) {
				childPart.reSize(vew:childVew)	// #### HEAD RECURSIVEptv
			}
			  // If our shape was just added recently, it has no parent.
			 //   That it is "dangling" signals we should swap it in
			if childVew.scnRoot.parent == nil {
				vew.scnRoot.addChild(node:childVew.scnRoot) // Single-Scene mode
		//				PAK20240929: other thoughts, perhaps for Many-Scene mode
		//		vew.scnRoot.removeAllChildren()
		//		let x = childVew.scnScene.rootNode
		//		x.removeFromParent()
		//		vew.scnRoot.addChild(node:x)
			}

			 // 2. Reposition:
			childPart.rePosition(vew:childVew)

			childVew.orBBoxIntoParent()			// child.bbox -> bbox
			childVew.keep		= true
		}

		 //------ Part PROPERTIES for new skin:
		vew.scnRoot.categoryBitMask = FwNodeCategory.picable.rawValue // Make node picable:

		 // ------ color0
		if let colorStr 		= config("color")?.asString,					//partConfig["color"]?.asString,
		  let c	 				= NSColor(colorStr),
		  vew.expose == .open {			// Hack: atomic not colored				//partConfig["color"] = nil
			vew.scnRoot.color0 		= c			// in SCNNode, material 0's reflective color
		}
		markTree(dirty:.paint)

		 //------ Activate Physics:
		if let physConf			= partConfig["physics"] {
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
	func reSkin(expose:Expose, vew:Vew) -> BBox 	{
		let vewExposeWas		= vew.expose
		vew.expose				= expose
		switch vew.expose {
		case .invis, .null:
			return reSkin(invisibleOnto:vew)	// no skin visible			// xyzzy32
		case .atomic:
			return reSkin(atomicOnto:vew) 		// atomic skin (sphere/line)// xyzzy32
		case .same:
			return reSkin(expose:vewExposeWas, vew:vew)	// try over			// xyzzy32
		case .open:
			return reSkin(fullOnto:vew)			// skin of Part				// xyzzy32
		}
	}

	/// Put on full skins onto a Part
    /// - Parameter vew: -- The Vew to use.
	/// - Returns: FW Bounding Box of skin
	/// - vew.bBox contains value bBox SHOULD be
	/// - Called _ONCE_ to get skin, as Views are constructed:
	func reSkin(fullOnto vew:Vew) -> BBox  {	// Bare Part
		 // No Full Skin overrides; make purple
		let atomBBox			= reSkin(atomicOnto:vew)		// xyzzy32 // Expedient: uses atomic skins // xyzzy32
		vew.scnRoot.children[0].color0 = .purple
		return atomBBox
	}
	static let atomicRadius 	= CGFloat(1)
	func reSkin(atomicOnto vew:Vew) -> BBox 	{

		 // Remove most child skins:	REALLY???
		for childScn in vew.scnRoot.children {
			if childScn.name != "s-atomic",
			   childScn.name != "ship" {			// TOTAL HACK
				childScn.removeFromParent()
			}
		}
		 // Ensure 1 skin exists:
		var scn4atom : SCNNode
		if vew.scnRoot.children.count == 0 {		// no children
			scn4atom 			= SCNNode(geometry:SCNSphere(radius:Part.atomicRadius/2)) //SCNNode(geometry:SCNHemisphere(radius:0.5, slice:0.5, cap:false))
			scn4atom.name		= "s-atomic"		// Make atomic skin
			scn4atom.color0		= .black			//systemColor
			scn4atom.categoryBitMask = FwNodeCategory.picable.rawValue
			vew.scnRoot.addChild(node:scn4atom, atIndex:0)
		}
		scn4atom				= vew.scnRoot.children[0]
		return scn4atom.bBox() * scn4atom.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
	func reSkin(invisibleOnto vew:Vew) -> BBox {
		vew.scnRoot.removeAllChildren()
//		 // Remove skin named "s-..."
//		if let skin				= vew.scnScene.find(name:"s-", prefixMatch:true) {
//			skin.removeFromParent()
//		}
//		assert(vew.scnScene.find(name:"s-", prefixMatch:true)==nil, "Part had more than one skin")
		return .empty
	}

	/// Confures a physicsBody for a Vew.
	/// - Parameters:
	///    vew: 				specifies scn
//	func foo(vew:Vew, setConfiguration config:FwAny?) {
//	}
	
	/// Confures a physicsBody for a Vew.
	/// - Parameters:
	///   * vew 				specifies scnScene
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
		if let pb				= vew.scnRoot.physicsBody {
			pb.resetTransform()			// scnScene.transform -> scnScene.presentation.transform
		}
		vew.updateWireBox()				// Add/Refresh my wire box scnScene
		vew.scnRoot.isHidden		= false	// Include elements hiden for sizing:
	}
/*
	a = xyz
	dirn = + -
	b = a + 1
	c = a + 2
 */
func foo () {

}

		//typedef enum : unsigned char {
	/// Parts a, b, and c  can be placed so min, max, or CenTeR align:

		//	aNeg  = 0x40,	aPos=0x00,											char 0 +-
		//	aUndef=0x00,	aX  =0x10,	aY  =0x20,	aZ	=0x30,	aMask=0x30,		char 1 xyz
		///// 					'<'			'>'			'c'
		//	cUndef=0x00,	cMin=0x01,	cMax=0x02,	cCtr=3,		cMask=0x03,		char 3 c<>?
		//	bUndef=0x00,	bMin=0x04,	bMax=0x08,	bCtr=0xC,	bMask=0x0C,		char 2 c><?
		//	isLink= 0x80,
		//}		PlaceType;


		//	NSString *s = placeString.lowercaseString;
		//	if ([placeString isEqualToString:@"link"])
		//		return isLink;
		//
		//	assert(placeString.length==4, (@"Length of PlaceType string '%@' BAD", placeString));
		//	PlaceType rv0=nilPlaceType, rv1=rv0, rv2=rv0, rv3=rv0;
		//
		// We have this enum : unsigned char {
		///// Parts a, b, and c  can be placed so min, max, or CenTeR align:
		//	cUndef=0x00,	cMin=0x01,	cMax=0x02,	cCtr=3,		cMask=0x03,		char 3 c<>?
		//	bUndef=0x00,	bMin=0x04,	bMax=0x08,	bCtr=0xC,	bMask=0x0C,		char 2 c><?
		//	aUndef=0x00,	aX  =0x10,	aY  =0x20,	aZ	=0x30,	aMask=0x30,		char 1 xyz
		//	aNeg  = 0x40,	aPos=0x00,											char 0 +-
		//	isLink= 0x80,
		//}		PlaceType;

		//	 // All Place Types are 4 e.g: +Ycc
		//	character 0
		//		case '+':		rv0 = aPos;			break;
		//		case '-':		rv0 = aNeg;			break;
		//	character 1
		//		case 'x':		rv1 = aX;			break;
		//		case 'y':		rv1 = aY;			break;
		//		case 'z':		rv1 = aZ;			break;
		//	character 2
		//		case 'c':		rv2 = cCtr;			break;
		//		case '>':		rv2 = cMax;			break;
		//		case '<':		rv2 = cMin;			break;
		//		case '?':		rv2 = cUndef;		break;
		//	character 3
		//		case 'c':		rv3 = cCtr;			break;
		//		case '>':		rv3 = cMax;			break;
		//		case '<':		rv3 = cMin;			break;
		//		case '?':		rv3 = cUndef;		break;



	enum AxisDirn {
		case x, y, z, X, Y, Z
	}

	enum PlaceType {
		case link(AxisDirn)
		case stack(AxisDirn)
	}






	 // MARK: - 9.4 rePosition
	func rePosition(vew:Vew) { //}, first:Bool=false) {
		guard vew.parent != nil else {		return			}
		 // Get Placement Mode
		let placeMode		=   partConfig["placeMe"]?.asString ?? // I have place ME
							parent?.config("placeMy")?.asString ?? // My Parent has place MY
										   			  "linky"	   // default is position by links
		  // Set NEW's orientation (flip, lat, spin) at origin
		vew.scnRoot.transform	= SCNMatrix4(.origin,
								 flip	 : flipped,
								 latitude: CGFloat(lat.rawValue) * .pi/8,
								 spin	 : CGFloat(spin)		 * .pi/8)
		 // First has center at parent's origni
		if vew.parent?.bBox.isEmpty ?? true {
			let newBip		= vew.bBox * vew.scnRoot.transform //new bBox in parent
			vew.scnRoot.position = -newBip.center
		}
		 // Place by links
		else if placeMode.hasPrefix("link")  {	// Position Link or Stacked
			if !placeByLinks(inVew:vew, mode:placeMode),	// (else)
			   !placeStacked(inVew:vew, mode:"stacky") {
					panic("placeByLinks and placeStacked failed")
			}
		}			// "-> errs -> stacking
		 // Place by stacking
		else if placeMode.hasPrefix("stack") {	// Position Stacked
			if !placeStacked(inVew:vew, mode:placeMode) {
					panic("placeStacked failed")
			}
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
			var newBip			= vew.bBox * vew.scnRoot.transform //new bBox in parent
			var rv				= -newBip.center // center selfNode in parent
			newBip.center		= .zero
			atRsi(4, vew.log(">>===== Position \(self.fullName) by:\(mode) (stacked) in \(parent?.fullName ?? "nil") "))
			let stkBip 			= vew.parent!.bBox
			rv		 			+= stkBip.center // center of stacked in parent
			let span			= stkBip.size + newBip.size	// of both parent and self
			let slop			= stkBip.size - newBip.size	// amount parent is bigger than self
			atRsi(6, vew.log("   newBip:\(newBip.pp(.phrase)) stkBip:\(stkBip.pp(.phrase))"))
			atRsi(5, vew.log("   span:\(span.pp(.line)) slop:\(slop.pp(.line))"))

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
			atRsi(4, vew.log("=====>> FOUND: rv=\(rv.pp(.short)); \(vew.name).bbox=(\(vew.bBox.pp(.line)))\n"))
			vew.scnRoot.position	= rv + (vew.jog ?? .zero)
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
		if let pb 				= vew.scnRoot.physicsBody,
		  !(vew.force ~== .zero) {					/// to all with Physics Bodies:
			pb.applyForce(vew.force, asImpulse:false)
			atRve(9, logd(" Apply \(vew.force.pp(.line)) to    \(vew.pp(.fullName))"))
//			atRve(9, logd(" posn: \(vew.scnScene.transform.pp(.line))"))
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
		  where childVew.part.test(dirty:.paint) {
//bug//NReset
//		  where childVew.part.testNReset(dirty:.paint) {
			childVew.part.rePaint(vew:childVew)		// #### HEAD RECURSIVE
		}
		assertWarn(!vew.scnRoot.transform.isNan, "vew.scnScene.transform == nan!")
	}

	 // MARK: - 11. 3D Display
	func typColor(ratio:Float) ->  NSColor {					// was colorOf(
		let inside				=  NSColor(0.7, 0.7, 0.7,  1)
		let outside				=  NSColor(0.7, 0.7, 0.7,  1)
		return NSColor(mix:inside, with:ratio, of:outside)
	}

	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: ---- NSEvent to process
    /// - Parameter vew: ---- The 3D scene Vew to use
	/// - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew pickedVew:Vew?) -> Bool {
		guard let pickedVew		else {	return false							}
		var rv					= false
		if nsEvent.type == .keyDown || nsEvent.type == .keyUp {
			let kind			= nsEvent.type == .keyUp ? ".keyUp" : ".keyDown"
			print("\(pp(.fwClassName)):\(fullName): NSEvent (key(s):'\(nsEvent.characters ?? "-")' \(kind)")
		}
		else {			 // Mouse event
			if let factalsModel	= partBase?.factalsModel { 	// take struct out
				let s			= ", vew.scn:\(pickedVew.scnRoot.pp(.classTag))"
				print("NSEvent (clicks:\(nsEvent.clickCount)\(s)) "
								+ "==> '\(pp(.fullName))' :\(pp(.classTag))")		//\n\(pp(.tree))

				 // SINGLE/FIRST CLICK  -- INSPECT									// from SimNsWc:
				if nsEvent.clickCount == 1 {
							// // // 2. Debug switch to select Instantiation:
					let alt 	= nsEvent.modifierFlags.contains(.option)

					print("Show Inspec for Vew '\(pickedVew.pp(.fullName))'")
					//let vewsInspec = Inspec(vew:pickedVew)
					pickedVew.vewBase()?.addInspector(forVew:pickedVew, allowNew:alt)

					rv			= true		//trueF//
				}

				 // Double Click: show/hide insides
				if nsEvent.clickCount > 1 {
					factalsModel.toggelOpen(vew:pickedVew)
					rv			= true
				}
				else if nsEvent.clickCount == 2 {		///// DOUBLE CLICK or DOUBLE DRAG   /////
					
					 // Let fwPart handle it:
					print("-------- mouseDragged (click \(nsEvent.clickCount))\n")

					 // Process the FwwEvent to the picked Part's Vew:
					let m:Part 	= pickedVew.part
					let _		= m.processEvent(nsEvent: nsEvent, inVew:pickedVew)
				}
				//root!.factalsModel!.document = factalsModel				// Put struct back
			} else {
				panic("processEvent(:inVew:) BAD ARGS")
			}
		}
		return rv
	}

	//------------------------------ Printout -- pretty print ------------------------
	 // MARK: - 14. Logging
	let nFullN					= 18//12
	func warning(_ format:String, _ args:CVarArg...) {
		let fmtWithArgs			= String(format:format, arguments:args)
		let targName 			= fullName.field(nFullN) + ": "
		warningLog.append(targName + fmtWithArgs)
		partBase != nil ? partBase!.log(banner:"WARNING", targName + fmtWithArgs + "\n")
					: print("WARNING" + targName + fmtWithArgs  + "\n")
	}
	func error(_ format:String, _ args:CVarArg...) {
		logNErrors 				+= 1
		let fmtWithArgs			= String(format:format, arguments:args)
		let targName 			= fullName.field(nFullN) + ": "
		partBase != nil ? partBase!.log(banner:"ERROR", targName + fmtWithArgs + "\n")
					: print("ERROR", targName + fmtWithArgs + "\n")
	}

	func ppUnusedKeys() -> String {
		let approvedConfigKeys	= ["placeMe", "placeMy", "portProp", "l", "len", "length"]
		let dubiousConfig		= partConfig.filter { key, value in !approvedConfigKeys.contains(key) }
		var rv 					= dubiousConfig.count == 0 ? "" :	// ignore empty configs
  								  "######\(pp(.fullNameUidClass).field(35)) UNUSED KEY: \(dubiousConfig.pp(.line))\n"
		for child in children {
			rv					+= child.ppUnusedKeys()
		}
		return rv
	}
	 //	 MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{		// Why is this not an override
		var rv					= ""
		switch mode {
		case .name:
			return name
		case .fullName:
			rv					+= fullName
		case .fullNameUidClass:
			return "\(name)\(ppUid(pre:"/", self)):\(fwClassName)"
//		case .tagClass:
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
			rv 					+= log.indentString()							// Bb..
			let ind				= parent?.children.firstIndex(where: {$0 === self})			//firstIndex(of:self)
			rv					+= ind != nil ? fmt("<%2d", Int(ind!)) : "<##"		// Cc..
				// adds "name;class<unindent><Expose><ramId>":
			rv					+= ppCenterPart(aux)								// Dd..
			if config("physics")?.asBool ?? false {
				rv				+= "physics,"
			}
			if aux.bool_("ppParam") {
				rv 				+= partConfig.pp(.line, aux)
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
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
		return rv
	}
	func ppCenterPart(_ aux:FwConfig) -> String {
		var rv 			 		=  name.field(10) + ":"					// " net0:"
		rv 						+= fwClassName.field(-8, dots:false)	// "Net "
		rv 						=  log.unIndent(rv)
//		rv 						=  root?.log.unIndent(rv) ?? "___ "
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
		log.nIndent				+= 1		//root?.
		let orderedChildren		= reverse ? children.reversed() : children
		for child in orderedChildren where ppPorts || !(child is Port) {
			 // Exclude undesireable Links
			if !(child is Link) || aux["ppLinks"]?.asBool == true {
				rv				+= mark_line(aux, child.pp(.tree, aux))
			}
		}
		log.nIndent				-= 1
		return rv
	}
	 /// Print Ports
	func printPorts(_ aux:FwConfig, early:Bool) -> String {
		var rv 					= ""
		log.nIndent				+= 1		// root?.
		if log.ppPorts {	// early ports // !(port.flipped && ppDagOrder)
			for part in children {
				if let port 	= part as? Port,
				  early == port.upInWorld {
					rv			+=  mark_line(aux, port.pp(.line, aux) + "\n")
				}
			}
		}
		log.nIndent				-= 1
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
		nLinesLeft				-= nLinesLeft != 0 ?  1 : 0	// decrement if non-zero
		return rv
	}
	 // MARK: - 17. Debugging Aids
	var description	 	 : String 	{	return  "d'\(pp(.short))'"				}
	var debugDescription : String	{	return "dd'\(pp(.short))'"				}
	var summary			 : String	{	return  "s'\(pp(.short))'"				}
}

 /// Pretty print an up:Bool as String
func ppUp(_ up:Bool?=nil) -> String {
	return up==nil ? "<nil>" : up! ? "up" : "down"
}
