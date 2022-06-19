// Part.swift -- Base class for Factal Workbench Models C2017PAK

import SceneKit
import SwiftUI

var defaultPrtIndex = 0

 /// Base class for Factal Workbench Models
// @objc ??
class Part : NSObject, HasChildren, Codable, ObservableObject 					//, Equatable, NSCopying, PolyWrappable
{
	
	 // MARK: - 2. Object Variables:

//	var localConfig	: FwConfig				// Configuration of Part

   @objc dynamic
	var name					= "<unnamed>"
	var children	: [Part]	= []
	var child0		:  Part?	{	return children.count == 0 ? nil : children[0] }
   weak
	var parent :  Part?	= nil 			// add the parent property

	typealias RootPart			= Part	// STUB
	lazy var root	: RootPart? = root__		// Lazy provides caching
	var root__		: RootPart? {		 		// NO CACHING, no var!
		return parent != nil ? parent!.root : self	// set to our parent's root ##RECURSIVE
	}

//	var dirty : DirtyBits		= .clean	// (methods in SubPart.swift)
 // BIG PROBLEMS: (Loops!)
//	{	willSet(v) {	markTree(dirty:v)  									}	}

//	 // Ugly:
//	var nLinesLeft	: UInt8		= 0			// left to print in current atom
//	var uidForDeinit			= "uninitialized"


	 // MARK: - 2.1 Sugar
	var parts 		: [Part]	{ 		children 								}
																				//	@objc dynamic var fullName	: String	{
																				//		let rv					= name=="ROOT" ? 		   name :	// Leftmost component
																				//								  parent==nil  ? "" :
																				//								  parent!.fullName + "/" + name		// add lefter component
																				//		return rv
																				//	}
//	var fullName16 	: String	{		return fullName.field(16)				}

																				//	 // - Array of unsettled ports. Elements are closures that returns the Port's name
																				//	func unsettledPorts()	-> [()->String]	{
																				//		var rv					= [()->String]()
																				//		for child in children {
																				//			rv					+= child.unsettledPorts()
																				//		}
																				//		return rv
																				//	}

																				//- (int) unsettledPorts;	{
																				//	assert(coerceTo(Net, self) or coerceTo(Atom, self), (@"%@ * illegal", self.className));
																				//	int rv = 0;
																				//	for (id elt in self.parts)
																				//		if (coerceTo(Part, elt))
																				//			rv += [elt unsettledPorts];
																				//	return rv;
																				//}

//	 // MARK: - 2.4 Display Suggestions
//	var initialExpose : Expose	= .open		// Hint to use on dumb creation of views. (never changed)
//			// See View.expose for GUI interactions
//	@Published var flipped : Bool = false
//	{	didSet {	if flipped != oldValue {
//						markTree(dirty:.size)
//																		}	}	}
//	 // MARK: - 2.2b INTERNAL to Part
//	@Published var lat : Latitude = Latitude.northPole 			// Xyzzy87 markTree
//	{	didSet {	if lat != oldValue {
//						markTree(dirty:.size)
//																		}	}	}
//  //@Published var longitude
//	@Published var spin : UInt8 = 0
//	{	didSet {	if spin != oldValue {
//						markTree(dirty:.size)
//																		}	}	}
//	@Published var shrink : Int8 = 0			// smaller or larger as one goes in
//	{	didSet {	if shrink != oldValue {
//						markTree(dirty:.size)
//																		}	}	}
//	 // MARK: - 2.2c EXTERNAL to Part
//	// - position[3], 						external to Part, in Vew
//
//	 // MARK: - 2.5 SwiftUI Stuff
//	 // just put here to get things working?
//	@Published var placeSelf = ""			// from config!
//	{	didSet {	if placeSelf != oldValue {
//						markTree(dirty:.vew)
//																		}	}	}
//// ///////////////////////////// Factory //////////////////////////////////////
//	// MARK: - 3. Part Factory
//	/// Base class for Factal Workbench Models
//	/// - Value "n", "name", "named": name of element
//	/// - Parameter config: FwConfig configuration hash
 //	init(_ config:FwConfig = [:]) {
//		localConfig				= config		// Set as my local configuration hash
//
 //		super.init() 	// NSObject \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		uidForDeinit			= ppUid(self)
//
//		var nam : String?		= nil
//		 // Do this early, to improve creation printout
//		for key in ["n", "name", "named"] {		// (Name has 3 keys)
//			if let na:String 	= localConfig[key] as? String {
//				assert(nam==nil, "Conflicting names: '\(nam!)' != '\(na)' found")
//				nam				= na
//				localConfig[key] = nil			// remove from config
//			}
//		}			// -- Name was given
//		name					= nam ?? {
//			if let prefix		= prefixForClass[fwClassName]
//			{		// -- Use Default name: <shortName><index> 	(e.g. G1)
//				let index		= DOC?.indexForClass[prefix] ?? 0
//				DOC?.indexForClass[prefix] = index + 1		// for next
//				return prefix + String(index)
//			}else{	// -- Use fallback
//				defaultPrtIndex	+= 1
//				return "prt" + String(defaultPrtIndex)
//			}
//		}()
//
//		 // Print out invocation
//		let n					= ("\'" + name + "\'").field(-8)
//		atBld(6, logd("init(\(localConfig.pp(.line))) name:\(n)"))
//
//		 // Options:
//		if let valStr			= localConfig["expose"] as? String,
//		  let e : Expose		= Expose(string:valStr) {
//			initialExpose		= e
//			localConfig["expose"] = nil
//		}
//		for key in ["f", "flip", "flipped"] {
//			if let ff			= localConfig[key],		// in config
//			  let f				= Bool(fwAny:ff) {			// can be Bool
//				flipped 		= f
//				localConfig[key] = nil
//			}
//		}
//		for key in ["lat", "latitude"] {
//			if let ff			= localConfig[key] {
//				if let f		= Int(fwAny:ff),
//				  let g			= Latitude(rawValue:f) {
//					lat				= g
//					localConfig[key] = nil
//				}
//			}
//		}
//		if let s				= UInt8(fwAny:localConfig["spin"]) {
//			spin 				= s
//			localConfig["spin"] = nil
//		}
//		if type(of:self) == Part.self && localConfig["parts"] != nil {
//			panic("key 'parts' can only be used in Atoms, not Parts")
//		}
 //	}
//	func setTree(root:RootPart, parent:Part?) {
////			//  "Root mismatch")
////		assertWarn(self.parent === parent, "\(fullName): Parent:\(self.parent?.fullName ?? "nil") should be \(parent?.fullName ?? "nil")")
////		assertWarn(self.root   === root,   "\(fullName): Root:\(self  .root?  .fullName ?? "nil") should be \(root   .fullName         )")
//		self.parent 			= parent
//		self.root   			= root
//		for child in children {
//			child.setTree(root:root, parent:self)
//		}
//	}
//																//	WTF:	isMember(of:Part.Type) // && localConfig["parts"]
//	deinit {
//		// 20210109: executes properly, but in AppDelegate it causes: (note Controller.deinit!)
//		//		EXC_BAD_ACCESS (code=1, address=0x368bb2a8b60)
//		//atBld(0, DOCLOG.log("###  DEINIT   \(fwClassName.field(-13))\(self.pp(.uidClass))"))
//		// workaround:
////		atBld(3, print("#### DEINIT   \(fwClassName.field(-13))"))								// WORKS
// //		print("#### DEINIT   \(uidForDeinit):\(fwClassName.field(-13))")						// WORKS
//	//	atBld(3, DOCLOG.log("#### DEINIT   \(uidForDeinit):\(fwClassName.field(-13))'\(name)'"))	// FAILED 20210911PAK
////		atBld(3, print("#### DEINIT   \(fwClassName.field(-13)) \(ppUid(self))"))				// FAILS
//	}
//
//	 // START CODABLE ///////////////////////////////////////////////////////////////
//	 // MARK: - 3.5 Codable
//	 //https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
//	enum PartsKeys: String, CodingKey {
//		//case uid			// IGNORE
//		case name
//		case children		// --- (SUBSUMES .parts)
//		//case parent		// IGNORE, weak, reconstructed
//		//case root_		// IGNORE, weak regenerate
//
//		case nLinesLeft		// new
//		case uidForDeinit	// new
//
//		case dirty
//		case localConfig	// ERRORS: want FwConfig to be Codable?
//		case config		// IGNORE: temp/debug FwConfig	= ["placeSelfy":"foo31"]
//		case initialExpose 	// --- (an Expose)	=.open	// Hint to use on dumb creation of views. (never changed)
//		//case expose		// IGNORE, it's in Vew, not part
//		case flipped
//		case lat 			// --- (a Latitude)	=Latitude.northPole
//		//case latitude		// IGNORE:
//		case spin
//		case shrink			// commented out
//		case placeSelf		// new
//	}
//
//	func encode(to encoder: Encoder) throws  {
//		//try super.encode(to:encoder)	// NSObject isn't codable
//		var container 			= encoder.container(keyedBy:PartsKeys.self)
//
//		try container.encode(name, 			forKey:.name)
//		try container.encode(children,		forKey:.children)		// ignore parts. (it's sugar for children)
//
//		try container.encode(nLinesLeft,	forKey:.nLinesLeft)		// ignore parts. (it's sugar for children)
//		try container.encode(uidForDeinit,	forKey:.uidForDeinit)		// ignore parts. (it's sugar for children)
//
//	//	try container.encode(localConfig,	foarKey:.localConfig)	// FwConfig not Codable!//Protocol 'FwAny' as a type cannot conform to 'Encodable'
//	//	try container.encode(config,		forKey:.config) 		// Type '(String) -> FwAny?' cannot conform to 'Encodable'
//		try container.encode(dirty,			forKey:.dirty)			// ??rawValue?? //	var dirty : DirtyBits
//		try container.encode(initialExpose,	forKey:.initialExpose)
//		try container.encode(flipped, 		forKey:.flipped)
//		try container.encode(lat,			forKey:.lat)
//		try container.encode(spin, 			forKey:.spin)
//		try container.encode(shrink,		forKey:.shrink)
//		try container.encode(placeSelf,		forKey:.placeSelf)
//		atSer(3, logd("Encoded  as? Part        '\(fullName)' dirty:\(dirty.pp())"))
//	}
//
//	required init(from decoder: Decoder) throws {
//		//try super.init(from:decoder)	// NSObject isn't codable
//		localConfig				= [:]//try container.decode(FwConfig.self,forKey:.localConfig)
//		super.init()	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		let container 			= try decoder.container(keyedBy:PartsKeys.self)
//			//  po container.allKeys: 0 elements
//
//		name 					= try container.decode(	   String.self, forKey:.name)
//		children				= try container.decode([PolyWrap].self, forKey:.children)
//		children.forEach({ $0.parent = self})	// set parent
//		// root?
//		nLinesLeft				= try container.decode(		UInt8.self, forKey:.nLinesLeft)
//		uidForDeinit			= try container.decode(    String.self, forKey:.uidForDeinit)
//		localConfig 			= [:]	// PUNT
//		//config				= [:]	// PUNT
//		dirty					= try container.decode( DirtyBits.self, forKey:.dirty)
//		initialExpose			= try container.decode(	   Expose.self, forKey:.initialExpose)
//		flipped					= try container.decode(		 Bool.self, forKey:.flipped)
//		lat						= try container.decode(  Latitude.self, forKey:.lat)
//		spin					= try container.decode( 	UInt8.self, forKey:.spin)
//		shrink					= try container.decode(		 Int8.self, forKey:.shrink)
//		placeSelf				= try container.decode(	   String.self, forKey:.placeSelf)
//
//		var str					=  "name='\(name)', "
//		str						+= "\(children.count) children, "
//		str						+= "dirty:\(dirty.pp())"
//		atSer(3, logd("Decoded  as? Part       \(str)"))
//	}
//// END CODABLE /////////////////////////////////////////////////////////////////


																				//	// FileDocument requires these interfaces:
																				//	 // Data in the SCNScene
																				//	var data : Data? {
																				//		return try! JSONEncoder().encode(self)
																				//	}															// B: (WORKS)	//let encoder 			= JSONEncoder()
																				//																				//encoder.outputFormatting = .prettyPrinted
																				//																				//let data 				= try! encoder.encode(self)
																				//	 // initialize new Part from Data
																				//	convenience init?(data:Data, encoding:String.Encoding) {
																				//// A: (BROKEN)
																				//		let newPart : Part?		= try? JSONDecoder().decode(Part.self, from:data)
																				////		self					= newPart
																				//		//Cannot assign to value: 'self' is immutable
																				//
																				//// B: (DEBUG/BROKEN)
																				//		let decoder : Decoder?	= JSONDecoder() as? Decoder
																				//	//	decoder.data			= data
																				//		do {
																				//			try self.init(from:decoder!)
																				//		} catch {
																				//			fatalError("funny: \(error)")
																				//		}
																				//
																				//// C: (BLOCKED)
																				//		do {		// 1. Write data to file.
																				//			try data.write(to: fileURL)
																				//		} catch {
																				//			print("error writing file: \(error)")
																				//		}
																				//
																				//		do {		// 2. Init self from file
																				//			self.init()//url: fileURL)
																				//			fatalError("debug me:")
																				//		//    Argument passed to call that takes no arguments
																				////			try self.init(NSObject, forKeyPath: <#T##String#>, options: <#T##NSKeyValueObservingOptions#>, context: <#T##void?#>)
																				//		} //catch {
																				//		 //	print("error initing from url: \(error)")
																				//		//	return nil
																				//		//}
																				//	}



//	 // MARK: - 3.6 NSCopying
//	func copy(with zone: NSZone?=nil) -> Any {
//bug;	let theCopy 			= Part()
////		let theCopy : Part		= super.copy(with:zone) as! Part
//		theCopy.name			= self.name
//		theCopy.children		= self.children
//		theCopy.nLinesLeft		= self.nLinesLeft
//		theCopy.uidForDeinit	= self.uidForDeinit
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
//
//	func copyXX(with zone: NSZone?=nil) -> Any {
//		do {		/* Use Codable to make the copy*/ // THIS DOES NOT WORK!!
//		//	panic("copy not implemented")
//			let data = try JSONEncoder().encode(self)
//			let str  = String(data:data, encoding: .utf8)!
//			print("JSON data", str)
//			let copy = try JSONDecoder().decode(Part.self, from: data)
//			return copy
//		}catch let error {
//			print(error)
//			fatalError()
//		}
//	}
	 // MARK: - 3.7 Equitable
//	func varsOfPartEq(_ rhs:Part) -> Bool {
//		var rv  =  name			== rhs.name
//		 	//	&& parent		== rhs.parent			// weak
//			//	&& children		== rhs.children			// DOESN'T SEEM TO WORK
//				&& nLinesLeft	== rhs.nLinesLeft
//			//	&& uidForDeinit	== rhs.uidForDeinit		// allowed to differ
//			//	&& dirty		== rhs.dirty			// allowed to differ
//			//	&& localConfig	== rhs.localConfig		// not Equitable
//			//	&& config		== rhs.config			// not Equitable
//				&& initialExpose == rhs.initialExpose
//				&& flipped		== rhs.flipped
//				&& lat			== rhs.lat
//				&& spin			== rhs.spin
//				&& shrink		== rhs.shrink
//				&& placeSelf	== rhs.placeSelf
//
//		 // Paw through children by hand:
//		rv	   &&= children.count 	== rhs.children.count
//		for i in 0..<children.count {
//			if rv == false {
//				return false
//			}
//			rv 					= children[i].equalsPart(rhs.children[i])
//		}
//		return rv
//	}
//	// https://forums.swift.org/t/implement-equatable-protocol-in-a-class-hierarchy/13844
//	// https://stackoverflow.com/questions/39909805/how-to-properly-implement-the-equatable-protocol-in-a-class-hierarchy
//	// https://jayeshkawli.ghost.io/using-equatable/
//	func isEqual(to part: Part?) -> Bool {
//bug
//		return part == nil ? false : equalsPart(part!)
//	}
////	static func == (lhs:Part, rhs:Part) -> Bool {
////		return lhs.isEqual(part:rhs)
////	}
////	func == (lhs:Part, rhs:Part) -> Bool {
////		return lhs.id == rhs.id
////	}
////
////	static func == (_ part:Part) -> Bool {
////		bug
////	}
//
//	func equalsPart(_ part:Part) -> Bool {
//		return className == part.className && varsOfPartEq(part)
//	}
//	func equalsPart<PP>(_ part: PP) -> Bool where PP : EqualsPart {
//		return false
//	}
//
//	 // MARK: - 4.1 Part Properties
//	 /// Short forms for Spin
//	static let str2spin : [String : Int] = [
//					"s0":0,     "s1":1,     "s2":2,     "s3":3,
//				"spin_0":0, "spin_1":1, "spin_2":2, "spin_3":3,
//								"sR":1, 				"sL":3, ]
//	func apply(propNVal:String) -> Bool {
//		let tokens : [String]	= propNVal.components(separatedBy:":")
//		if tokens.count == 1 {
//			if let opts 		= Part.str2spin[tokens[0]] {
//				return apply(prop:"spin", withVal:opts)	// more parsed form
//			}
//		}
//		 // process key:value
//		else if (tokens.count == 2) {
//			panic()
//			return apply(prop:tokens[0], withVal:tokens[1])
//		}
//		else {
//			panic(" add stuff here ")
//		}
//		return false
//	}
//	static let spinMax			= 16
//	func apply(prop:String, withVal val:FwAny?) -> Bool {
//		guard let val			= val else {		return false				}
//
//		if prop == "n" || prop == "name" || prop == "named",
//		  let n 				= val as? String{ // e.g: "named":"foo"
//			name 				= n
//			return true							// found a flip property
//		}
//		if prop == "f" || prop == "flip" || prop == "flipped",
//		  let flipVal 			= Bool(fwAny:val) { // e.g: "flip:1"
//			flipped 			^^= flipVal
//			return true							// found a flip property
//		}
//		if prop == "s" || prop == "spin" {						// e.g. "spin:3"
//			var spinVal : Int?	= nil				// initiall no spinVal
//			if let valNum 		= val as? Int {
//				spinVal 		= valNum				// carries spin value
//			}
//			else if let valStr 	= val as? String {	// String
//				 // Production: symbolic "r" --> 1
//				let (a, b)		= (Part.spinMax/4, 3*Part.spinMax/4)
//				let lr2int  	= [ "r":a, "R":a, "l":b, "L":b]
//				if let n		= lr2int[valStr] {
//					spinVal 	= n			// symbolic spin --> numeric spin
//				}
//				else if let n 	= Int(valStr) {
//					spinVal		= n
//				}
//			}
//			assert(spinVal != nil, "spin value \(val.pp(.short)) ILLEGAL")
//			assert(spinVal!>=0 && spinVal!<Part.spinMax, "spinVal \(spinVal!) out of range")
//
//			let x				= (Int(spin) - spinVal! + Part.spinMax) % Part.spinMax
//			spin				= UInt8(x)
//			return true						// found a spin property
//		}
//		//if ([prop isEqualToString:"sound"]) {	// e.g. "sound:di-sound" or
//		//	panic("")
//		//	//if (coerceTo(NSString, val)) {
//		//	//	Leaf *leaf			= mustBe(Leaf, self)
//		//	//	Port *genPort		= [leaf port(named:"G")
//		//	//	GenAtom *genAtom 	= mustBe(GenAtom, genPort.atom)
//		//	//	genAtom.sound		= val
//		//	//}
//		//	//else
//		//	//	panic("sound's val must be string")
//		//	//
//		//	//return true							// found a spin property
//		//}
//		return false
//	}



	// MARK: - 4.2 Manage Tree
	/// Add a child part
	/// - Parameters:
	///   - child: child to add
	///   - index: index to added after. >0 is from start, <=0 is from start, nil is at end
	/// dirtyness of child is inhereted by self
	func addChild(_ child:Part?, atIndex index:Int?=nil) {
		guard let child 		= child else {		return						}
		assert(self != child, "can't add self to self")

		 // Find right spot in children
		var doppelganger : Int?	= children.firstIndex(of:child)	// child already in children
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
		child.root				= self.root

		 // Process tree dirtyness:
//		markTree(dirty:.vew)				// ? tree has dirty.vew
//		markTree(dirty:child.dirty)			// ? tree also inherits child's other dirtynesses
	}										// (child is not dirtied any more)
	func removeChildren() {
		children.removeAll()
//		markTree(dirty:.vew)
	}
	/// Groom Part tree after construction.
	/// - Parameters:
	///   - parent_: ---- if known
	///   - root_: ---- set in Part
//	func groomModel(parent parent_:Part?, root root_:RootPart?)  {
//		parent					= parent_
//		let r					=  root_				// from arg
//								?? root					// my root
//								?? self as? RootPart 	// me, if I'm a RootPart
//								?? child0 as? RootPart	// if PolyWrapped
//		root					= r
//		markTree(dirty:.vew)						// set dirty vew
//
//		 // Do whole tree
//		for child in children {						// do children
//			child.groomModel(parent:self, root:root)	// ### RECURSIVE
//		}
//	}
//	func groomModelPostWires(root:RootPart)  {
//		 // Check for duplicate names:
//		var allNames : [String] = []
//		for child in children {
//			assertWarn(allNames.contains(child.name) == false, "contains duplicate name \(name)")
//			allNames.append(child.name)
//		}
//		 // Do whole tree
//		for child in children {
//			child.groomModelPostWires(root:root) 	// ### RECURSIVE
//		}
//	}
//
//	 // Get Part's configuration from localConfig of Part and parents, and model
//	func config(_ name:String) -> FwAny? {
//		 // Look in self and parents:
//		for s in selfNParents {				// s = self, parent?, ..., root, cap, 0
//			if let rv			= s.localConfig[name] {
//				return rv						// return an ancestor's config
//			}
//		}
//		return root?.ansConfig[name] ??		// Look in common places: // 21200301PAK: Review: sometimes ans Config is also dumped into Part.config?
//			   DOC?.fwScene?.config4scene[name]
//	 }
//	  /// Lookup Part's configuration from only this Part
////	 func configLocal(_ name:String) -> FwAny? {
////		 return 			      localConfig[name]		// in our config hash
////	 }
//	 // MARK: - 4.3 Iterate over parts
//	typealias PartOperation 	= (Part) -> ()
//	func forAllParts(_ partOperation : PartOperation)  {
//		partOperation(self)
//		for child in children {
//			child.forAllParts(partOperation)
//		}
//	}
////	func forAllPorts<T>() -> T? 	{		return nil							}
//
//	  // /////////////////////////// Navigation //////////////////////////////////////
//	 // MARK: - 4.4 Navigation
//	var enclosingNet : Net? {
//		for s in parents {
//			if let n 			= s as? Net {
//				return n
//			}
//		}
//		return nil
//	}
//	func ancestorThats(childOf child:Part) -> Part? {
//		for part in selfNParents {
//			if part.parent == child {
//				return part
//			}
//		}
//		return nil		// no ancestor or self is child of anAncestor
//	}
//	func enclosedByClass(fwClassName:String) -> Part {
//		let cl : Part.Type		= classFrom(string:fwClassName)
//		return enclosedByClass(class:cl)!	 // get the appropriate class object
//	}
//	func enclosedByClass(class:AnyClass?) -> Part? {
//		for part in parent?.selfNParents ?? [] {					// Search outward
//			panic()
//			return part
//		}
//		return nil
//	}
//	func hasAsAncestor(ancestor:Part) -> Bool {
//		for part in selfNParents {
//			if part == ancestor {
//				return true
//			}
//		}
//		return false
//	}
//	func smallestNetEnclosing(_ m1:Part, _ m2:Part?=nil) -> Net? {
//		let a1 					= m1.selfNParents					// of Parts
//		 // just 1 Part supplied or both Parts are the same
//		if m2==nil ||  m2 == m1	{
//			for m in a1.reversed() {
//				if let mNet = m as? Net {
//			 	  // the smallest parent that is a Net
//					return mNet
//				}
//			}
//		}
//		 // 2 Parts supplied -- find the smallest Net they have in common
//		else {
//			let a2				= m2!.selfNParents
//			let (am1, am2)		= (a1.count - 1, a2.count - 1)
//			var (n, i)			= (min(am1, am2) + 1, 0)
//			while i < n {
//				if a1[am1 - i] != a2[am2 - i] {    // working backward
//					break
//				}
//				i				+= 1
//			}					// i now at first difference
//			while i > 0 {
//				i				-= 1
//				if let a1Net	= a1[am1 - i] as? Net  {
//					return a1Net
//				}
//			}
//		}
//		return nil          // no Net in any of m1's parents
//	}
																				//	 /// Ancestor array starting with parent
																				//	var parents : [Part] {
																				//		var rv 		 : [Part]	= []
																				//		var ancestor :  Part?	= parent
																				//		while ancestor != nil {
																				//			rv.append(ancestor!)
																				//			ancestor 			= ancestor!.parent
																				//		}
																				//		return rv
																				//	}
																				//	/// Ancestor array starting with self
																				//	var selfNParents : [Part] {
																				//		return selfNParents()
																				//	}
																				//	/// Ancestor array, from self up to but excluding 'inside'
																				//	func selfNParents(upto:Part?=nil) -> [Part] {
																				//		var rv 		 : [Part]	= []
																				//		var ancestor :  Part?	= self
																				//		while ancestor != nil, 			// ancestor exists and
																				//			  ancestor! != upto  {		// not at explicit limit
																				////		  ancestor!.name != "ROOT" {
																				//			rv.append(ancestor!)
																				//			ancestor 			= ancestor!.parent
																				//		}
																				//		return rv
																				//	}
//
//	/// Class Inheritance Ancestor Array, from self up to but excluding 'inside'
//	var inheritedClasses : [String] {
//		var rv 	: [String]		= []
//		var curClass:Part.Type? = type(of:self)
//		repeat {
//			rv.append(String(describing:curClass!))
//			curClass			= curClass?.superclass() as? Part.Type
//		} while curClass != nil
//		return rv
//	}
//	func dagIndex(ancestorOf part:Part) -> Int? {
//		if let p 				= part.ancestorThats(childOf:self) {
//			return children.firstIndex(of:p)
//		}
//		return nil
//	}
//
//
//
//	/// Up has 2 meanings:
//	///	- UPsidedown (as controlled by fliped)
//	///	- Port opens UP
//	var upInWorld : Bool {						// true --> flipped in World
//		var rv 					= false
//		for part in selfNParents {
//			rv 					^^= part.flipped	// rv now applies from self
//		}
//		return rv
//	}
//	 /// self isUp in Part
//	 /// - argument: inPart -- part which is parent of self
//	func upInPart(until endPart:Part) -> Bool {
//
//		 // Trace from self to endPart:
//		let (flip0, end0)		= self   .flipTo(endPart:endPart)
//		if end0 === endPart {		// found endPart
////		if end0 == endPart {		// found endPart
//			return  flip0				// return its flip
//		}
//
//		 // Trace from endPart to self:
//		let (flip1, end1)		= endPart.flipTo(endPart:self   )
//		if end1 === self {			// found self
////		if end1 == self {			// found self
//			return  flip1				// return its flip
//		}
//
//		 // They end at the same root!
//		if end0 === end1 {
////		if end0 == end1 {
//			return flip0 ^^ flip1
//		}
//		fatalError("self:\(fullName) and endPart:\(endPart.fullName) don't share a root")
//	}
//	 /// scan up the tree from self to (but not including) endPart
//	private func flipTo(endPart:Part) -> (Bool, Part) {
//		var flipd				= false
//		var endP : Part			= self
//		while endP != endPart && 				// we are not endpart
//			  endP.parent != nil 				// we have a parent
//		{
//			flipd				^^= endP.flipped
//			endP 				= endP.parent!
//		}
//		return (flipd, endP)
//	}
//	func upInWorldStr()		 	 -> String {
//		return upInWorld ? "up" : "down"
//	}
//
//		 // MARK: - 4.6 Find Children
//	   /// A boolean predicate of a Part
//	typealias Part2PartClosure 	= (Part) -> Part?
//	 /// Find Part with desired name
//	/// - name		-- sought name
//	func find(	name desiredName:String,
//
//				all searchParent :Bool	= false,
//				inMe2 searchSelfToo:Bool=false,
//				maxLevel 		:Int?	= nil,
//				except exception:Part?	= nil) -> Part? { // Search by name:
//		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel, except:exception, firstWith:
//					{	$0.fullName.contains(desiredName) ? $0 : nil			} )
////					{	$0.fullName == desiredName ? $0 : nil					} )
//	}

//	func find(	path				:Path,
//
//				all searchParent :Bool	= false,
//				inMe2 searchSelfToo:Bool = false,
//				maxLevel 		:Int?	= nil,
//				except exception:Part?	= nil) -> Part? { // Search by Path:
//		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel, except:exception, firstWith:
//					{	$0.partMatching(path:path) 								} )
////		{(part:Part) -> Part? in
////			return part.partMatching(path:path)		// part.fullName == "/net0/bun0/c/prev.S"
////		} )
//	}

//	func find(	part				:Part,
//
//				all searchParent :Bool	= false,
//				inMe2 searchSelfToo:Bool = false,
//				maxLevel 		:Int?	= nil,
//				except exception:Part?	= nil) -> Part? { // Search for Part:
//		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel, except:exception, firstWith:
//					{	$0 === part ? $0 : nil	 								} )
////					{	$0 == part ? $0 : nil	 								} )
////		{(aPart:Part) -> Part? in
////			return aPart == part ? aPart : nil
////		} )
//	}
																				//	 /// First where closure is true:
																				//	/// - inMe2		-- search this node as well
																				//	/// - all		-- search parent outward
																				//	/// - maxLevel	-- search children down to this level
																				//	/// - except	-- don't search, already search
																				//	func find(	inMe2	 :Bool	= false, 	all searchParent:Bool=false,
																				//			 	maxLevel :Int?	= nil,   	except exception:Part?=nil,
																				//			  	firstWith validationClosure:ValidationClosure<T>) -> Part? { /// Search by closure:
																				//		 // Check self:
																				//		if inMe2,
																				//		  let cr 				= partClosure(self) {		// Self match?
																				//			return cr
																				//		}
																				//		if (maxLevel ?? 1) > 0 {		// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
																				//			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
																				//			let orderedChildren	= (upInWorld ^^ findWorldUp) ? children.reversed() : children
																				//			 // Check children:
																				//			for child in orderedChildren where child != exception { // don't redo exception
																				//				if let rv 		= child.find(inMe2:true, all:false, maxLevel:mLev1, firstWith:validationClosure) {
																				//					return rv
																				//				}
																				//			}
																				//		}
																				//		if searchParent,						// Check parent
																				//		  let p					= parent,		// Have parent
																				//		  p.name != "ROOT" {					// parent not ROOT
																				//			return parent?.find(inMe2:true, all:true, maxLevel:maxLevel, except:self, firstWith:validationClosure)
																				//		}
																				//		return nil
																				//	}
//	// MARK: - 4.8 Matches Path
//	/// Get a Proxy Part matching path
//	/// # The Path must specify a Part inside self.
//	/// - Parameter path: ---- the path
//	/// - Returns: ---- the part matching the path
//	func partMatching(path:Path) -> Part? {
//
//		 // Does my Path's tokens match Atom:
//		for (index, part) in selfNParents.enumerated() {
//			assert(!(self is Port), "Ports can only be last element of a Path")
//			if index >= path.atomTokens.count {		// Past last token?
//				return self								// .:. match!
//			}
//			if index == path.atomTokens.count-1,	// At the token to the left of the first '/'?
//			  path.atomTokens[index] == "" {		  // "" before --> Absolute Path
//				logd("Absolute Path '\(path.pp(.line))', and at last token: UNTESTED")
//				return self								// .:. match!
//			}
//			if part.name != path.atomTokens[index]{	// name MISMATCH
//				return nil								// .:. nfg
//			}
//		}
//		if parent == nil, 							// no parents and
//		  path.atomTokens.count != 0 {				  //  still more tokens?
//			return nil									// mismatch
//		}
//		return self									// Match
//	}
//
//
//	 // MARK: - 5. Wiring
//	/// Scan self and children for wires to add to model
//	/// - Wires are gathered after model is built, and applied at later phase
//	/// - Parameter wirelist: 		where wires added
//	func gatherLinkUps(into linkUpList:inout [() -> ()]) {    //super gatherWiresInto:wirelist];
//		 // Gather wires from  _children_   into wirelist first:
//		for child in children {
//			if let atom       	= child as? Atom {
//				atom.gatherLinkUps(into:&linkUpList)  // ### RECURSIVE
//			}
//		}
//	}
//
//	   //------------- Reenactment Simulator -- simulation protocol ----
//	  // MARK: - 7. Simulator Messages
//	 // Inject message
////	func sendMessage(fwType:FwType) {
////		atEve(4, log("      all parts ||  sendMessage(\(fwType))."))
////		let fwEvent 			= FwEvent(fwType:fwType)
////		return receiveMessage(event:fwEvent)
////	}
//	 /// Recieve message and broadcast to all children
//	func receiveMessage(event:FwEvent) {
//	//	atEve(4, log("$$$$$$$$ all parts receiveMessage:\(fwTypeDefnNames[fwEvent->fwType])") )))
//		for elt in children {				// do for our parts too
//			elt.receiveMessage(event:event)
//		}
//	}
//	 // MARK: - 8. Reenactment Simulator
//
//	/// Reset all Parts of tree
//	func reset() {
//		for child in children {
//			child.reset()
//		}
//	}
	  /// Perform one micro-step in time simulation
	 /// - up -- direction of scan
//	func simulate(up upLocal:Bool) {
//		 // Step all my parts:
//		let orderedChildren		= upLocal ? children : children.reversed()
//		for child in orderedChildren {
//			let upInEnt 		= child.flipped ^^ upLocal
//			child.simulate(up:upInEnt)		// step all somponents
//		}
//	}
//
//	  // MARK: - 9. 3D Support
//	  // :H: RExxx -- update xxx efficiently
//	 // Views are constructed in 4 phases: reVew, Skins, reSize and place
//	//		9.1 reVew			-- Build/correct Vew's from Part's. Overrides 190924:
//	// 		Net: 				use NetVew; tree height
//	//			Link:				only open Links ??
//	//			Atom:				Views for Ports
//	//			Port:				check not invis or atomic
//	//			Discre	eTime:		Inspec's
//	//		 *) reVewPost		-- Clean up
//	//		9.2 reSize
//	// 		Actor:				Insure order of con, ..., evi
//	//			Net:				gapTerminalBlock
//	//			Atom:				placeOf(portVew
//	//		 *) reSizePost			190924: BBox for Net,FwBundle,Leaf,Atom,Port,Part
//	//			Atom:				port.reSizePost
//	//			Part:				reset PB xform, all children
//	//		9.3 Skins			-- reSkinFull, reSkinAtom, reSkinInvisible
//	//		9.4 place
//	//			Port:				panic
//	//		 *)	placeStacked
//	//		 *) placeByLinks
//
	// MARK: - 9.0 make a Vew for Part
	 /// Make a new Vew for self, and add it to parentVew
	func addNewVew(in parentVew:Vew?) -> Vew? {
		let v					= VewForSelf()//Vew(forPart:self)
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
	func reVew(intoVew vew_:Vew?=nil, parentVew pVew:Vew?=nil) {
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
//
//		switch vew?.expose ?? initialExpose {// (if no vew, use default in part)
//
//		case .open:					// //// Show insides of Part ////////////
			vew					= vew ?? 	// 3. CREATE:
								  addNewVew(in:pVew)
			 // Remove old skins:
	//		vew!.scn.find(name:"s-atomic")?.removeFromParent()
		//	markTree(dirty:.size)

			 // For the moment, we open all Vews
			for childPart in children {
		//		if	childPart.testNReset(dirty:.vew) ||		// 210719PAK do first, so it gets cleared
		//		 	childPart.initialExpose == .open    {
					childPart.reVew(parentVew:vew!)
		//		}
			}
//
//		case .atomic:				// //// "think harder"
//			vew					= vew ?? 	// 3. CREATE:
//								  addNewVew(in:pVew)
//			if vew != nil,
//			  vew!.children.count > 0 {
//				vew!.removeAllChildren()	// might eliminate later
////				markTree(dirty:.size)		// (.vew loops endlessly!)
//			}
//			let _				= reSkin(atomOnto:vew!)	// Put on skin.
//
//		default:					// ////  including .invisible
//			if vew != nil {					// might linger
//				let _			= reSkin(invisibleOnto:vew!)
//			}
//		}
//		vew?.expose				= vew?.expose ?? initialExpose	// for the future
//		vew?.keep				= true
	}
//	   /// - Link:			Position Views (e.g. lookAt)
//	  /// -	Atom:			Mark unused
//	 /// -	Part:			remove Views for unused Parts
//	func reVewPost(vew:Vew) {
//		vew.keep				= false
//		if vew.expose == .open {
//			for childVew in vew.children {				// (Post Recursion)
//				childVew.part.reVewPost(vew:childVew)
//			}
//		}
//	}
//	     // MARK: - 9.2 reSize
//	    /// Re-pack vew and children
//	   /// - May be called multiply, at the start with .zero .bBox, and after packing internal atoms.
//      /// - Parameter vew: -- The Vew to use
//     /// - Returns: nothing
//	func reSize(inVew vew:Vew) {
//
//		 //------ Put on my   Skin   on me.
//		vew.bBox				= .empty			// Set view's bBox EMPTY
//		vew.bBox				= reSkin(onto:vew)	// Put skin on Part
//
//		 //------ reSize all  _CHILD Atoms_
//		var first				= true
//		let orderedChildren		= upInWorld==findWorldUp ? vew.children : vew.children.reversed()
//		for childVew in orderedChildren where// For all Children, except
//		  !(childVew.part is Port) 				// ignore child Ports (Atom handles)
//		{	let childPart		= childVew.part
//
//			 // 1. Repack insides (if dirty size):
//			if childPart.testNReset(dirty:.size) {
//				childPart.reSize(inVew:childVew)	// #### HEAD RECURSIVEptv
//			}
//			  // If our shape was just added recently, it has no parent.
//			 //   That it is "dangling" signals we should swap it in
//			if childVew.scn.parent == nil {
///*bug;*/		vew.scn.removeAllChildren()
//				vew.scn.addChild(node:childVew.scn)
//			}
//
//			 // 2. Reposition:
//			childPart.rePosition(vew:childVew, first:first)
//			childVew.orBBoxIntoParent()			// child.bbox -> bbox
//			childVew.keep		= true
//			first				= false
//		}
//
//		 //------ Part PROPERTIES for new skin:
//		vew.scn.categoryBitMask = FwNodeCategory.picable.rawValue // Make node picable:
//
//		 // ------ color0
//		if let colorStr 		= config("color")?.asString,					//localConfig["color"]?.asString,
//		  let c	 				= NSColor(colorStr),
//		  vew.expose == .open {			// Hack: atomic not colored				//localConfig["color"] = nil
//			vew.scn.color0 		= c			// in SCNNode, material 0's reflective color
//		}
//		markTree(dirty:.paint)
//
//		 //------ Activate Physics:
//		if let physConf			= localConfig["physics"] {
//			physics(vew:vew, setConfiguration:physConf)
//		}
//	}
//	 // MARK: - 9.3 reSkin
//	/// Put full skin onto Sphere
//	/// - chooses full, atomic, or invisible, according to expose
//    /// - Parameter vew: -- The Vew to use
//    /// - Parameter expose_: -- Exposure. If nil, use View's exposure
//    /// - returns: -- The BBox of the part with new skins on. 
//    /// - note: The BBox of the view's SCNNode is INVALID at this point. (This is from a problem with non-zero gaps)
//	func reSkin(_ expose_:Expose?=nil, onto vew:Vew) -> BBox 	{
//		vew.expose				= expose_ ?? vew.expose
//		switch vew.expose {
//		case .invis, .null:
//			return reSkin(invisibleOnto:vew)	// no skin visible
//		case .atomic:
//			return reSkin(atomOnto:vew) 		// atomic skin (sphere/line)
//		case .open:
//			return reSkin(fullOnto:vew)			// skin of Part
//		}
//	}
//	/// Put on full skins onto a Part
//    /// - Parameter vew: -- The Vew to use.
//	/// - Returns: FW Bounding Box of skin
//	/// - vew.bBox contains value bBox SHOULD be
//	/// - Called _ONCE_ to get skin, as Views are constructed:
//	func reSkin(fullOnto vew:Vew) -> BBox  {	// Bare Part
//		 // No Full Skin overrides; make purple
//		let bBox				= reSkin(atomOnto:vew)		// Expedient: uses atomic skins
//		vew.scn.children[0].color0 = .purple
//		return bBox
//	}
//	static let atomicRadius 	= CGFloat(1)
//	func reSkin(atomOnto vew:Vew) -> BBox 	{
//
//		 // Remove most child skins:
//		for childScn in vew.scn.children {
//			if childScn.name != "s-atomic" {
//				childScn.removeFromParent()
//			}
//		}
//		 // Ensure 1 skin exists:
//		var scn4atom : SCNNode
//		if vew.scn.children.count == 0 {		// no children
//			scn4atom 			= SCNNode(geometry:SCNSphere(radius:Part.atomicRadius/2)) //SCNNode(geometry:SCNHemisphere(radius:0.5, slice:0.5, cap:false))
//			scn4atom.name		= "s-atomic"		// Make atomic skin
//			scn4atom.color0		= .black			//systemColor
//			vew.scn.addChild(node:scn4atom, atIndex:0)
//		}
//		scn4atom				= vew.scn.children[0]
//		return scn4atom.bBox() * scn4atom.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
//	}
//	func reSkin(invisibleOnto vew:Vew) -> BBox {
//		vew.scn.removeAllChildren()
////		 // Remove skin named "s-..."
////		if let skin				= vew.scn.find(name:"s-", prefixMatch:true) {
////			skin.removeFromParent()
////		}
////		assert(vew.scn.find(name:"s-", prefixMatch:true)==nil, "Part had more than one skin")
//		return .empty
//	}
//
//	/// Confures a physicsBody for a Vew.
//	/// - Parameters:
//	///    vew: 				specifies scn
//	func foo(vew:Vew, setConfiguration config:FwAny?) {
//	}
//	
//	/// Confures a physicsBody for a Vew.
//	/// - Parameters:
//	///   * vew 				specifies scn
//	///   * config
//	///   - FwConfig	==> recognizes keys: gravity, force, and impulse
//	///   - Bool	         ==> enable gravity
//	///   - nil			==> remove any physicsBody
//	func physics(vew:Vew, setConfiguration config:FwAny?) {
//		guard let config 		= config else {
//			vew.scn.physicsBody	= nil			// remove physicsBody
//			return
//		}
//		assert(!(self is Port) && !(self is Link), "Ports and Links cannot have physics property")
//
//		 // PhysicsBody Shape is   A SPHERE
//		let physicsShape		= SCNNode(geometry:SCNSphere(radius:1.5))	// (acceptable simplification)
//		physicsShape.name		= "q" + name
//		let shape 				= SCNPhysicsShape(node:physicsShape)
//		let pb					= SCNPhysicsBody(type:.dynamic, shape:shape)//kinematic OK
//		vew.scn.physicsBody		= pb
//
//		 // Default PhysicsBody properties
//		pb.contactTestBitMask	= FwNodeCategory.collides.rawValue
//		pb.angularVelocityFactor = .zero
//		pb.rollingFriction		= 0.0	// resistance to rolling motion.
//		pb.restitution			= 1.5	// It determines how much kinetic energy the body loses or gains in collisions.
//		pb.damping				= 0.8	// It reduces the body’s linear velocity.
//		pb.usesDefaultMomentOfInertia = false // does SceneKit automatically calculates the body’s moment of inertia or allows setting a custom value.
//		// not used currently:
//		//	pb.resetTransform()
//		//	pb.mass				= 1 	// The mass of the body, in kilograms.
//		//	pb.charge			= 0 	// electric charge of the body, in coulombs.
//		//	pb.angularDamping	= 1		// It reduces the body’s angular velocity.
//		//	pb.momentOfInertia 	= SCNVector3(1,1,1) // The moment of inertia, expressed in the local coordinate system of the node that contains the body.
//
//		 // Settable PhysicsBody's properties:
//		if let config			= config.asFwConfig {
//			for (key, value) in config {
//				let val			= SCNVector3(from:value) ?? SCNVector3(0,0.1,0)
//				switch key {
//				case "impulse":
//					pb.applyForce(val, at: SCNVector3.zero, asImpulse:true)
//				case "force":
//					pb.applyForce(val, at: SCNVector3.zero, asImpulse:false)
//				case "gravity":
//					let v 			= value.asBool
//					assert(v != nil, "gravity: value (\(value)) is not Bool")
//					pb.isAffectedByGravity = v!
//				default:
//					break
//				}
//			}
//			pb.isAffectedByGravity	= false
//		}
//		else if let doGravity	= config.asBool {
//			pb.isAffectedByGravity	= doGravity
//		}
//	}
//	func reSizePost(vew:Vew) {
//
//		 // Do   CHILDREN   first
//		for childVew in vew.children { //where !(childVew is LinkVew) {
//			childVew.part.reSizePost(vew:childVew)		// #### HEAD RECURSIVE
//		}
//		  // Reset transforms if there's a PHYSICS BODY:
//		 //https://stackoverflow.com/questions/51456876/setting-scnnode-presentation-position/51679718?noredirect=1#comment91086879_51679718
//		if let pb				= vew.scn.physicsBody {
//			pb.resetTransform()			// scn.transform -> scn.presentation.transform
//		}
//		vew.updateWireBox()				// Add/Refresh my wire box scn
//		vew.scn.isHidden		= false	// Include elements hiden for sizing:
//	}
//	 // MARK: - 9.4 rePosition
//	func rePosition(vew:Vew, first:Bool=false) {
//		if vew.parent != nil {
//			 // Get Placement Modep
//			let placeMode		=  localConfig["placeMe"]?.asString ?? // I have place ME
//								parent?.config("placeMy")?.asString ?? // My Parent has placy MY
//											   "linky"				   // default is position by links
//			  // Set NEW's orientation (flip, lat, spin) at origin
//			vew.scn.transform	= SCNMatrix4(.origin,
//									 flip	 : flipped,
//									 latitude: CGFloat(lat.rawValue) * .pi/8,
//									 spin	 : CGFloat(spin)		 * .pi/8)
//			if first {								// First has center at parent's origin
//				let newBip		= vew.bBox * vew.scn.transform //new bBox in parent
//				vew.scn.position = -newBip.center
//			}
//			else if placeMode.hasPrefix("stack") {	// Position Stacked
//				assert(placeStacked(inVew:vew, mode:placeMode), "placeStacked failed")
//			} 
//			else if placeMode.hasPrefix("link")  {	// Position Link or Stacked
//				assert(placeByLinks(inVew:vew, mode:placeMode)	// try link first
//					|| placeStacked(inVew:vew, mode:"stacky"), "placeByLinks and placeStacked failed")
//			} 
//			else {
//				panic("positioning method '\(placeMode)' unknown")
//			}
//		}
//	}
//	  /// STACK selfNode onto side, per PARENT's placeBy:
//	 /// - e.g: "placeMy":"stackX 1 1" stacks on -x axis, aligning corners in +y and +z
//	func placeStacked(inVew vew:Vew, mode:String) -> Bool {
//		if vew.parent != nil {
//			  // :H:		 	   ..BBoxInP -- BoundingBox In Parent coords
//			 // 			 StacKeD objects -- are those already included in parent
//			// 					  NEW object -- being added, (= self)
//			var newBip			= vew.bBox * vew.scn.transform //new bBox in parent
//			var rv				= -newBip.center // center selfNode in parent
//			newBip.center		= .zero
//			atRsi(4, vew.log(">>===== Position \(self.fullName) by:\(mode) (stacked) in \(parent?.fullName ?? "nil") "))
//			let stkBip 			= vew.parent!.bBox
//			rv		 			+= stkBip.center // center of stacked in parent
//			let span			= stkBip.size + newBip.size	// of both parent and self
//			let slop			= stkBip.size - newBip.size	// amount parent is bigger than self
//			atRsi(6, vew.log("   newBip:\(newBip.pp(.phrase)) stkBip:\(stkBip.pp(.phrase))"))
//			atRsi(5, vew.log("   span:\(span.pp(.short)) slop:\(slop.pp(.short))"))	//\(stkBip.size.pp(.phrase)) += \(newBip.size.pp(.phrase)):
//
//			  // e.g. mode = "stackY 0.5 1"
//			 // determine: u0,u1,u2, stackSign, alignU1, alignU2
//			let modeWords:[Substring] = mode.split(separator:" ")
//			let c 				= String(modeWords[0].last!)
//			guard let stackAxis:Int = ["x":0,"y":1,"z":2,"X":3,"Y":4,"Z":5][c] else {
//				panic("No x/y/z axis specifier in  mode:\(mode)")
//				return false
//			}
//			  // Determine which Axis to stack on (u0), and which others to center:
//			let (u0, u1, u2)	= (stackAxis%3, (stackAxis+1)%3, (stackAxis+2)%3)	// 0=x, 1=y, 2=z
//			let stackSign:CGFloat =  stackAxis < 3 ? 0.5 : -0.5
//			 // Align to:	 -1:minusCorners, 0:centers, 1:plusCorners
//			var alignU1 		= Float(0.0)	/// ( stackAxis + 1 ) % 3
//			if modeWords.count > 1,
//			  let a1 			= Float(modeWords[1]) {
//				alignU1			= 0.5 * a1
//			}
//			var alignU2 		= Float(0.0)	/// ( stackAxis + 2 ) % 3
//			if modeWords.count > 2,
//			  let a2 			= Float(modeWords[2]) {
//				alignU2			= 0.5 * a2
//			}
//			let ax				= ["x","y","z"] 
//			atRsi(5, vew.log("   Stack:\(stackSign > 0 ? "+" : "-")\(ax[u0]): Align \(ax[u1])=\(alignU1), \(ax[u2])=\(alignU1)"))
//
//			 // the move (delta) to put self's bBox centered within parent's bBox
//			   // Place next Vew (self) on side of stacked parts   \\\
//			  //   Calculation done in p parent's coord system      \\\
//			 //   assumes self.transform has only 90deg's turns      \\\
//			//( Consider just \[min+---o----------------+max  stk     )))
//			 //\   the X axis:/[  min+-o--+max                new    ///
//			  //\  o = origin/      AABBBBBCCCCCCCCCCCCCC           ///
//			   //\   span: A + 2*B + C,   slop = A + C             ///
//
//			/*==Parent's Coords     	IN MORE DETAIL:
//			||                      0      2        v~---- origin
//			||   stkBBox            +---s--+        o<----------- parent SCNNode
//			||                    +====p===+
//			||   slop:             --            p - s = -1
//			||   span:     +====p===+--s---+     p + s = 3
//			||   newSelfPosition   +===p===+
//			\\   selfBip:          +===p===+         |
//			 >>==                /       /         /position xform
//			//                  +===p===+         o<--------------- self SCNNode
//			\\==My Coords   -.5     .5*/
//
//			 // Stack self in axis u0, onto a side of parent, extending it:
//			rv[u0] 				+= span[u0] * stackSign		// NB: SCNVector3[Int] yields component numbered Int
//			 // Center self on Parent's face: [-1:left, 0:center, 1:right]
//			rv[u1] 				+= slop[u1] * alignU1
//			rv[u2] 				+= slop[u2] * alignU2
//
//			let gap				= config("gapStackingInbetween")?.asCGFloat ?? 0.0
//			rv[u0] 				+= gap * stackSign		/// gap on stacking axis
//				 // H A C K: !!!!
//			rv					+= SCNVector3(newBip.center.x,0,newBip.center.z)
//	//		let delta			= newBip.center - stkBip.center
//	//		rv					+= SCNVector3(delta.x,0,delta.z) /// H A C K !!!!
//			atRsi(4, vew.log("<<===== rv=\(rv.pp(.short))\n"))
//			vew.scn.position	= rv + (vew.jog ?? .zero)
//	//		vew.scn.transform	= SCNMatrix4(rv + (vew.jog ?? .zero))
//		}
//		return true		// Success
//	}
//	  /// Place Atoms by Links
//	 /// - raw parts not positioned by links:
//	func placeByLinks(inVew vew:Vew, mode:String?=nil) -> Bool {
//		return false		 
//	}
//
//	   // MARK: - 9.5: Render Protocol
//	 // MARK: - 9.5.2: didApplyAnimations 		-- Compute spring forces
//	func computeLinkForces(in vew:Vew) {
//		for childVew in vew.children {			// by Vew
//			childVew.part.computeLinkForces(in:childVew) // #### HEAD RECURSIVE
//		}
//	}
//	  // MARK: - 9.5.3: did Simulate Physics 	-- Apply spring forces
//	 /// Distribute Forces
//	func applyLinkForces(in vew:Vew) {
//		for childVew in vew.children {			// repeat over Vew tree
//			childVew.part.applyLinkForces(in:childVew) // #### HEAD RECURSIVE
//		}
//		if let pb 				= vew.scn.physicsBody,
//		  !(vew.force ~== .zero) {					/// to all with Physics Bodies:
//			pb.applyForce(vew.force, asImpulse:false)
//			atRve(9, logd(" Apply \(vew.force.pp(.line)) to    \(vew.pp(.fullName))"))
////			atRve(9, logd(" posn: \(vew.scn.transform.pp(.line))"))
//		}
//		vew.force				= .zero
//	}
//	 // MARK: - 9.5.5: will Render Scene -- Rotate Links toward camera
//	func rotateLinkSkins(in vew:Vew) {
//		for childVew in vew.children {			// by Vew
//			childVew.part.rotateLinkSkins(in:childVew) // #### HEAD RECURSIVE
//		}
//	}
//
//
//	  // MARK: - 9.6: Paint Image:
//	func rePaint(on vew:Vew) 	{		/* prototype */
//		for childVew in vew.children 				// by Vew
//		  where childVew.part.testNReset(dirty:.paint) {
//			childVew.part.rePaint(on:childVew)		// #### HEAD RECURSIVE
//		}
//		assertWarn(!vew.scn.transform.isNan, "vew.scn.transform == nan!")
//	}
//
//	 // MARK: - 13. IBActions
//	 /// Prosses keyboard key
//    /// - Parameter from: ---- NSEvent to process
//    /// - Parameter vew: ---- The 3D scene Vew to use
//	/// - Returns: Key was recognized
//	func processKey(from nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
//		if nsEvent.type == .keyUp || nsEvent.type == .keyDown {
//			let kind			= nsEvent.type == .keyUp ? ".keyUp" : ".keyDown"
//			print("\(pp(.fwClassName)):\(fullName): NSEvent (key(s):'\(nsEvent.characters ?? "-")' \(kind)")
//		}
//		else {			 // Mouse event
//			print("    NSEvent (clicks:\(nsEvent.clickCount)) ==> \(pp(.fullName)) :" 
//											+ "\(pp(.fwClassName))\n\(pp(.tree))")
//			 // SINGLE/FIRST CLICK  -- INSPECT									// from SimNsWc:
//			if nsEvent.clickCount == 1 {			
//				 		// // // 2. Debug switch to select Instantiation:
//				let alt 				= nsEvent.modifierFlags.contains(.option)
//				DOC.showInspecFor(vew:vew!, allowNew:alt)							//false
//				return true
//			}
//						// Double Click: show/hide insides
//			if nsEvent.clickCount > 1 {
//				if vew != nil {
//					DOC.fwScene?.toggelOpen(vew:vew!)
//				}
//										//if vew != nil,
//										//  let scene	= fwScene {
//										//	scene.toggelOpen(vew:vew!)
//										//}
//										//fwScene?.toggelOpen(vew:vew!)
//			}
//			else if nsEvent.clickCount == 2 {		///// DOUBLE CLICK or DOUBLE DRAG   /////
//				
//bug				 // Let fwPart handle it:
//				print("-------- mouseDragged (click \(nsEvent.clickCount))\n")
//
//				 // Process the Event to the picked Part's Vew:
////				let m : Part 	= vew!.part
////				m.sendPicEvent(nsEvent, toModelOf:vew)	// was pickedVew
////				[m sendPickEvent:&fwEvent toModelOf:pickedVew]
////				[self.simNsVc buildRootFwVforBrain:self.brain]	// model may have changed, so remake vew
//			}
//		}
//		return false
//	}
//
//	//------------------------------ Printout -- pretty print ------------------------
//	 // MARK: - 14. Logging
//	let nFullN					= 18//12
////	func logg(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
////		let msg					= String(format:format, arguments:args)
////		let (nls, str2)			= msg.stripLeadingNewLines()
////		let str					= nls + (pp(.uidClass) + ":").field(-nFullN) + str2
////		DOCLOG.log(str, terminator:terminator)
////	}
//	func warning(_ format:String, _ args:CVarArg...) {
//		let fmtWithArgs			= String(format:format, arguments:args)
//		let targName 			= fullName.field(nFullN) + ": "
//		warningLog.append(targName + fmtWithArgs)
//		root != nil ? root!.log.log(banner:"WARNING", targName + fmtWithArgs + "\n")
//					: print("WARNING" + targName + fmtWithArgs  + "\n")
//	}
//	func error(_ format:String, _ args:CVarArg...) {
//		logNErrors 				+= 1
//		let fmtWithArgs			= String(format:format, arguments:args)
//		let targName 			= fullName.field(nFullN) + ": "
//		root != nil ? root!.log.log(banner:"ERROR", targName + fmtWithArgs + "\n")
//					: print("ERROR", targName + fmtWithArgs + "\n")
//	}
//
//	func ppUnusedKeys() -> String {
//		let uid					= ppUid(self, post:":")
//		let approvedConfigKeys	= ["placeMe", "placeMy", "portProp", "l", "len", "length"]
//		let dubiousConfig		= localConfig.filter { key, value in !approvedConfigKeys.contains(key) }
//		var rv 					= dubiousConfig.count == 0 ? "" :	// ignore empty configs
//								  " <<< \(uid)\(fullName.field(30)):\(fwClassName.field(-14)) \(dubiousConfig.pp(.line))\n"
//		for child in children {
//			rv				+= child.ppUnusedKeys()
//		}
//		return rv
//	}
//
//	 //	 MARK: - 15. PrettyPrint
//	// Override: Method does not override any method from its superclass
//	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{		// Why is this not an override
//		var rv					= ""
//		switch mode! {
//		case .name:
//			return name
//		case .fullName:
//			rv					+= fullName
//		case .fullNameUidClass:
//			return "\(name)\(ppUid(pre:"/", self)):\(fwClassName)"
////		case .uidClass:
////			return "\(ppUid(self)):\(fwClassName)"	// e.g: "xxx:Port"
////		case .classUid:
////			return "\(fwClassName)<\(ppUid(self))>"	// e.g: "Port<xxx>"
//		case .phrase, .short:
//			return "\(name):\(pp(.fwClassName, aux)) \(children.count) children"
//		case .line:
//			  //      AaBbbbbbCccDdddddddddddddddddddddddEeeeeeeeeeeee
//			 // e.g: "Ff| | | < 0      prev:Prev  o> 76a8  Prev mode:?
//			rv					= ppUid(self, post:"", aux:aux)
//			rv					+= (upInWorld ? "F" : " ") + (flipped ? "f" : " ")	// Aa
//			rv 					+= root?.log.indentString() ?? "____"				// Bb..
////			rv 					+= root?.log.indentString() ?? "Bb..."				// Bb..
//			let ind				= parent?.children.firstIndex(of:self)
//			rv					+= ind != nil ? fmt("<%2d", Int(ind!)) : "<##"		// Cc..
//				// adds "name;class<unindent><Expose><ramId>":
//			rv					+= ppCenterPart(aux)								// Dd..
//			if config("physics")?.asBool ?? false {
//				rv				+= "physics,"
//			}
//			if aux.bool_("ppParam") {
//				rv 				+= localConfig.pp(.line)
//			}
//																					// Ee..
//		case .tree:
//			let ppDagOrder 		= aux.bool_("ppDagOrder")	// Print Ports early
//			let reverseOrder	= ppDagOrder && (upInWorld ^^ printTopDown) //trueF//falseF//
//
//			if ppDagOrder {				// Dag Order
//				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:true)
//				rv				+= ppSelf	 (aux)
//			}
//			else {
//				rv				+= ppSelf	 (aux)
//				rv				+= ppChildren(aux, reverse:reverseOrder, ppPorts:true)
//			}
//		default:
//			return ppDefault(self:self, mode:mode, aux:aux)// NO return super.pp(mode, aux)
//		}
//		return rv
//	}
//	func ppCenterPart(_ aux:FwConfig) -> String {
//		var rv 			 		=  name.field(10) + ":"					// " net0:"
//		rv 						+= fwClassName.field(-6, dots:false)	// "Net "
//		rv 						+= root?.log.unIndent(previous:rv) ?? "___ "
//		rv						+= initialExpose.pp(.short, aux)		// "o"
//		rv						+= dirty.pp()
////		rv						+= " s:\(spin)"
////		rv						+= " l:\(lat)"
//		return rv + " "
//	}
//	  //	 MARK: - 15.1 pp support
//	 /// Print children
//	func ppSelf(_ aux:FwConfig) -> String {
//		let rv					= mark_line(aux, pp(.line, aux) + "\n")
//		return rv
//	}
//	 /// Print children
//	func ppChildren(_ aux:FwConfig, reverse:Bool, ppPorts:Bool) -> String {
//		var rv					= ""
//		root?.log.nIndent		+= 1
//		let orderedChildren		= reverse ? children.reversed() : children
//		for child in orderedChildren where ppPorts || !(child is Port) {
//			 // Exclude undesireable Links
//			if !(child is Link) || aux["ppLinks"]?.asBool == true {
//				rv				+= mark_line(aux, child.pp(.tree, aux)) // (ppLine has no \n)
//			}
//		}
//		root?.log.nIndent		-= 1
//		return rv
//	}
//	 /// Print Ports
//	func printPorts(_ aux:FwConfig, early:Bool) -> String {
//		var rv 					= ""
//		root?.log.nIndent			+= 1
//		if DOCLOG.ppPorts {		// early ports // !(port.flipped && ppDagOrder)
//			for part in children {
//				if let port 	= part as? Port,
//				  early == port.upInWorld {
//					rv			+=  mark_line(aux, port.pp(.line, aux) + "\n")
//				}
//			}
//		}
//		root?.log.nIndent			-= 1
//		return rv
//	}
//	 /// Marking line with '_'s improves readability
//	func mark_line(_ aux:FwConfig, _ line:String) -> String {
//		var rv					= line
//		if nLinesLeft == 1 {
//			let sta 			= line.index(line.startIndex, offsetBy: 0)
//			let end 			= line.index(line.startIndex, offsetBy: min(line.count, 30))
//			let range			= Range(uncheckedBounds:(lower:sta, upper:end))
//			rv					= line.replacingOccurrences(of:" ", with:"_", range:range)
//		}
//		nLinesLeft				-= nLinesLeft != 0 ? 1 : 0	// decrement if non-zero
//		return rv
//	}
//	 // MARK: - 16. Global Constants
	static let null 			= Part()
//	static let null 			= Part(["n":"null"])	// Any use of this should fail (NOT IMPLEMENTED)
//	 // MARK: - 17. Debugging Aids
//	override var description	  : String 	{	return  "\"\(pp(.short))\""	}
//	override var debugDescription : String	{	return   "'\(pp(.short))'"		}
	override var description	  : String 	{	return  "\(fullName):\(fwClassName)"}
//	override var debugDescription : String	{	return   "Part named \(name)"	}
//	static var summary			  : String	{	return   "-summary-"			}

////	 // MARK: - 19. Inspector SwiftUI.Vew
////	static var body : some Vew {
////		Text("Part.body lives here")
////	}
}
//extension Part: CustomStringConvertible {
//    override var description: String {
//        return "(\(x), \(y))"
//    }
//}

// /// Pretty print an up:Bool as String
//func ppUp(_ up:Bool?=nil) -> String {
//	return up==nil ? "<nil>" : up! ? "up" : "down"
//}
