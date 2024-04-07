 //  HaveNWant.swift -- Define simple HaveNWant Network in code C2018PAK

import SceneKit

 /// Worker function, applied to each x#r() entry to record.
//typealias FilterFunc = (_:Bool, _:String?, _:FwConfig, _:@escaping PartClosure, _:String?, _:Int) -> ()

struct ScanArgs : Codable {
	 // MARK: - 2.4.1 Wanted by Scan ELIM?

			// selectionString+------FUNCTION---------+-argName:---argNumber:
			//	nil			  |	Blank scene			  |	nil			-1
			//	"entry<N>"	  |	entry N				  |	nil			N *
			//	"xr()"		  |	entry labeled as xr() |	"xr()" *	-1
			//	<name>		  |	named scene			  |	<name> *	-1
			// Used by Parts.setup() and Library.registerNetwork()
	var argNumber		: Int			// if select scene by number
	var argName 		: String?		// if select scene by name
	var argOnlyIndex	: Bool			// Used for menu preparation

	init(selectionString:String?, wantOnlyIndex w:Bool) {
		 // --- selectionString -> want****:
		argName				= nil		// Default: no name
		argNumber				= -1		//			no number
		argOnlyIndex			= w
		if let sel 				= selectionString {
			if sel.hasPrefix("entry") {			// E.g: "scene12"
				let index 		= sel.index(sel.startIndex, offsetBy:"entry".count)
				argNumber 		= Int(String(sel[index...]))!
			} else {							// E.g: "xr()" or <name>
				argName		= sel
			}
		}
	}
}
	 // MARK: - 2.4.2 Scan State
class ScanState : Codable {
	var uid			: UInt16	= randomUid()
	var scanTestNum	: Int		= 0			// Number of elements scanned (so far, total)
	var scanSubMenu : String	= ""		// name of current FactalsModel sub-menu
	var scanCatalog	: [LibraryMenuArray] = []	// Catalog of Library
	var scanEOFencountered:Bool = false		// marks scan done
}
struct LibraryMenuArray	: Codable, Identifiable {		// of input array (upstream)
	var id 			= UUID()
//	var id 			: Int { tag	}
	var tag		  	: Int
	var title	  	: String
	var parentMenu	: String				// path scene/decoder/...
}

typealias LibraryMenuTree = FactalsApp.FactalsGlobals.LibraryMenuTree

func libraryMenuArray2tree(catalogs:[LibraryMenuArray]) -> [String:LibraryMenuTree] {
	var bogusLimit		= 20
	var rv				= [String:LibraryMenuTree]()

	for catalog in catalogs {
		if bogusLimit <= 0 {	break 	}; bogusLimit -= 1

		 // Make new menu entry:
		let menuItem		= LibraryMenuTree(name:catalog.title)
		 // find or make the parentMenu it belongs within
		let path 			= catalog.parentMenu
		guard !path.contains(substring: "/") else {fatalError("'/' in not supported scanSubMenu")}
		if rv[path] == nil {	// make parent for path if none exists
			print("-------- tag:\(catalog.tag) title:\(catalog.title.field(-54)) parentMenu:\(catalog.parentMenu)")
			var parent 		= LibraryMenuTree(name:path) // make new parent
			parent.children.append(menuItem)
			rv[path]		= parent 					// remember new element there
		} else {
			rv[path]!.children.append(menuItem)
	//		var parent		= rv[path]
	//		parent!.children.append(menuItem)
	//		rv[path]		= parent
//			rv[catalog.title] = menuItem
		}
	}
	return rv
}

	  // MARK: - 2.4.3 Result of Scan
struct ScanAnswer {		// : Codable
	 // From Chosen Test
	var ansTitle	: String?  	= nil		// Network name from library
	var ansConfig	: FwConfig	= [:]		// [NOT CODABLE]
	 // From Scan:
	var ansTestNum  : Int		= 0
	var ansSubMenu 	: String	= ""		// the scanSubMenu of the test found
	 // Anonymous from Scan
	var ansTrunkClosure:PartClosure? = nil	// [NOT CODABLE] Closure from Library, generates Part
	var ansFile		: String?	= nil
	var ansLineNumber : Int?	= nil
}

extension Library : Uid {
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
		Log.shared.log("\(pp(.uidClass)): \(format)", args, terminator:terminator)
		//let log				= FACTALSMODEL!.log
	}
}
class Library {			// NEVER NSCopying, Equatable : NSObject// CherryPick2023-0520: add :FwAny

	 // MARK: - 1. Register all Libraries HERE!
	static let libraryList = [		// In order of evaluation
		  // Search for a definition in these files, in order, stopping at first
		 //  (Within a file, test specification must be weak.)
		// Proto(	"Proto"		),				// Prototype Tests - used to create new
		 // Special regiemes:
		TestsFoo(	"TestsFoo"	),				// New Regression Tests for Factals
		TivoRemote(	"TivoRemote"),				// Operation of Tivo Remote
		LangDeser(	"LangDeser"	),				// Language Deserializer
		 // Default testing:
		Tests01(	"Tests01"	),				// Standard Regression Tests
	]
	 // MARK: - 2. Register all Libraries HERE!
	var uid						= randomUid()
	var name : String

	 // MARK: - 3. Factory
	init(_ name:String) {
		self.name				= name
		//super.init()
	}
	//enum IntParsingError: Error {
	//	case overflow
	//	case invalidInput(Character)
	//}
	var args  : ScanArgs?		= nil
	var state : ScanState		= ScanState()		// class
	var answer: ScanAnswer		= ScanAnswer()		// struc

	var count : Int				{
		var state				= ScanState()
		let args				= ScanArgs(selectionString:"", wantOnlyIndex:true)
		loadTest(args:args, state:&state)
		return state.scanTestNum
	}

	 // Each Library file loads an answer if it is selected
	func loadTest(args:ScanArgs, state:inout ScanState) {
		self.args				= args
		self.state				= state
		self.answer				= ScanAnswer()
	}

	static func library(fromSelector s:String?) -> Library? {
		guard let s 			= s else { return nil } // no selector, no lib
		var rv : Library?		= nil					// search value for desired string
		let args				= ScanArgs(selectionString:s, wantOnlyIndex:false)

		 // 1. look in all libraries
		var state				= ScanState()
		for lib in Library.libraryList {
	/**/	lib.loadTest(args:args, state:&state)		// state persists across library probes
			 // Return selected test if valid:
			if lib.answer.ansTrunkClosure != nil {
				 // REMOVED to allow greedy xr()
				//assert(rv == nil, """
				//	Two entries for selector: '\(s)'
				//			\(rv!.name.field(12)):\(rv!.answer.ansTestNum)\t line:\(rv!.answer.ansLineNumber!)
				//			\(lib.name.field(12)):\(lib.answer.ansTestNum)\t line:\(lib.answer.ansLineNumber!)
				//	""")
				rv				= lib
			}
		}								// no, loop for another
		return rv
	}
	static func catalog() -> Library {
		let args				= ScanArgs(selectionString:"", wantOnlyIndex:true)
		let rv					= Library("catalog")

		 // Scan through all Library swift source file, stop at first
		for lib in Library.libraryList {
	/**/	lib.loadTest(args:args, state:&rv.state)	// state persists across library probes
		}		// Hack: Stop after first found.  Ignore multi-source xr('s.

		 // Return list of titles in a master catalog.
		return rv
	}

	  // MARK: - 5.1 Linkages from Library
	   // //////////// linkages for library entries ////////////////
	  // Tests are wrapped in closures, so they are not evaluated if not needed
	 /// An Unmarked experiment (e.g. r()) might still be selected by name or sought number.
	func r(	_ config:FwConfig, _ rootClosure:@escaping PartClosure,
			_ file:String?=#file, _ lineNumber:Int=#line)
	{	registerNetwork(markedXr:false, testName:nil,
						config:config, rootClosure:rootClosure,
						file:file, lineNumber:lineNumber)
	}
	func r( _ testName:String?=nil,
			_ config:FwConfig, _ rootClosure:@escaping PartClosure,
			_ file:String?=#file, _ lineNumber:Int=#line)
	{	registerNetwork(markedXr:false, testName:testName,
						config:config, rootClosure:rootClosure,
						file:file, lineNumber:lineNumber)
	}

	 /// The one test is marked xr() will be run.
	func xr(_ config:FwConfig, _ rootClosure:@escaping PartClosure,
			_ file:String?=#file, _ lineNumber:Int=#line)
	{	registerNetwork(markedXr:true, testName:nil,
						config:config, rootClosure:rootClosure,
						file:file, lineNumber:lineNumber)
	}
	func xr(_ testName:String?=nil,
			_ config:FwConfig, _ rootClosure:@escaping PartClosure,
			_ file:String?=#file, _ lineNumber:Int=#line)
	{	registerNetwork(markedXr:true, testName:testName,
						config:config, rootClosure:rootClosure,
						file:file, lineNumber:lineNumber)
	}

	 /// Texts marked xxr() are ignored as are the r(), but easily searchable by "xr"
	func xxr(_ config:FwConfig, _ rootClosure:@escaping PartClosure,
			 _ file:String?=#file, _ lineNumber:Int=#line)
	{	registerNetwork(markedXr:false, testName:nil,
						config:config, rootClosure:rootClosure,
						file:file, lineNumber:lineNumber)
	}
	func xxr(_ testName:String?=nil,
			 _ config:FwConfig, _ rootClosure:@escaping PartClosure,
			 _ file:String?=#file, _ lineNumber:Int=#line)
	{	registerNetwork(markedXr:false, testName:testName,
						config:config, rootClosure:rootClosure,
						file:file, lineNumber:lineNumber)
	}
	
	 /// Definition of a particular test, to exp
	func registerNetwork(markedXr	 	:Bool,
						 testName	 	:String?,
						 config 	 	:FwConfig,
						 rootClosure 	:@escaping PartClosure,
						 file			:String?,
						 lineNumber		:Int)
	{									// ALIASES for parts:
		state.scanTestNum 		+= 1		// count every test
		if args!.argOnlyIndex {				// Wants Index
			 // //// Display only those entries starting with a "+" ////////////
			if trueF {//testName?.hasPrefix("+") ?? false {	// 'trueF {//' trueF/falseF//
	//why?		assert(state.scanTestNum == state.titleList.count, "dropped title while creating scene menu index")
				let title		= "\(state.scanTestNum)  \(name):\(lineNumber):  " + (testName ?? "-")
				let elt			= LibraryMenuArray(tag:state.scanTestNum, title:title, parentMenu:state.scanSubMenu)
				state.scanCatalog.append(elt)
//				state.scanElements.append(elt)
			}
			return
		}
		 // ///////////// Wants Test ///////////////////////////////
		let title				= testName != nil ? "\(testName!)" : "unnamed_\(state.scanTestNum)"
		let matchReason0 : String? =
			args!.argName != nil &&				// Name exists
			args!.argName == testName ?			//   and matches?
				"Building testName  ''\(testName!)''" :	// yes, name matchs
				args!.argNumber == state.scanTestNum ?// no, numbers match?
					"Building  ''scene #\(state.scanTestNum)''" :// yes, match
					nil
		let matchReason			= matchReason0 ??
			(!markedXr ?							// is this marked xr?
				nil :									// no, just r(), ignore
				args!.argName == "xr()" &&			// yes, is name xr() and
				 args!.argNumber < 0 ?				//   no wanted number?
					"Building Network marked with xr()" :	// yes
					nil)									// no, ignore
		if matchReason != nil {						// BUILD
			atBld(7, logd("=== \(matchReason!) ==="))
			assert(answer.ansTrunkClosure==nil, "Two Closures found marked xr():\n" +
				"\t Previous = \(answer.ansTestNum):\(answer.ansFile ?? "lf823").\(answer.ansLineNumber!) '\(answer.ansTitle ?? "none")' <-- IGNORING\n" +
				"\t Current  = \(state.scanTestNum):\(name).\(       lineNumber ) '\(         title)'")

			 // CAPTURE: Copy current to exp
			 // from Chosen Test
								
			answer.ansTitle		= title
			answer.ansConfig 	= config
			answer.ansTrunkClosure = rootClosure
			 // From Scan
			answer.ansTestNum	= state.scanTestNum
			answer.ansSubMenu	= state.scanSubMenu
			 // Anonymous from Scan
			answer.ansFile		= name
//			answer.ansFile		= file
			answer.ansLineNumber = lineNumber
		}
	}
	var fwClassName		 : String	{	"Library"								}

         // MARK: - 17. Debugging Aids
	var description		 : String 	{	return  "d'\(fwClassName) \(name)'"		}
	var debugDescription : String	{	return "dd'\(fwClassName) \(name)'"		}
	var summary			 : String	{	return  "s'\(fwClassName) \(name)'"		}
}

 // ================ User Sugar, for prettier networks: ========================
extension Library {

	 // 1. Root configuration:
	  /// Set the link velocity
	 /// - Parameter vel:  log2 of links/sec
	func vel(_  vel:Float) -> FwConfig 	{	return ["linkVelocityLog2":vel] 	}
	 /// Does NOTHING, except easily convertable to vel()
	func velX(_ vel:Float) -> FwConfig 	{	return [:] 							}

	// 2. Camera Parameters:
	func selfiePole(h:Float?=nil, s:Float?=nil, u:Float?=nil, z:Float?=nil) -> FwConfig {
		var rv : FwConfig 		= [:]
		if let h {	rv["h"] 	= h												}
		if let s {	rv["s"] 	= s												}
		if let u {	rv["u"] 	= u												}
		if let z {	rv["z"]		= z												}
		return ["selfiePole":rv]
	}
	 /// 2b. Neutered Camera Parameters:
	func cameraX(h:Float?=nil, s:Float?=nil, u:Float?=nil, z:Float?=nil) -> FwConfig {
		return [:]
	}
}
	/// Create FwConfig for Logging 
   /// - Parameters:
  ///   - prefix: Set to "*" for XCTests
 /// - Returns: Hash for logPri4 verbosity
//func log(prefix:String="",
/*app */
/*doc */
/*bld */
/*ser */
/*ani */
/*dat */
/*eve */
/*ins */
/*men */
/*rve */
/*rsi */
/*rnd */
/*tst */
/*all*/

func log(
		app:Int=0,
		doc:Int=0,
		bld:Int=0,
		ser:Int=0,
		ani:Int=0,
		dat:Int=0,
		eve:Int=0,
		ins:Int=0,
		men:Int=0,
		rve:Int=0,
		rsi:Int=0,
		rnd:Int=0,
		tst:Int=0,
 		all:Int=0		// con gone
		) -> FwConfig {	[:] }

func log33(
		app:Int=0,
		doc:Int=0,
		bld:Int=0,
		ser:Int=0,
		ani:Int=0,
		dat:Int=0,
		eve:Int=0,
		ins:Int=0,
		men:Int=0,
		rve:Int=0,
		rsi:Int=0,
		rnd:Int=0,
		tst:Int=0,
 		all:Int=0		// con gone
		) -> FwConfig {
	var rv : FwConfig		= [:]//"logPri4all"  : 0]	// default OFF

	if app > 0 		{		rv["logPri4app"] = app								}
	if doc > 0 		{		rv["logPri4doc"] = doc								}
	if bld > 0 		{		rv["logPri4bld"] = bld								}
	if ser > 0 		{		rv["logPri4ser"] = ser								}
	if ani > 0 		{		rv["logPri4ani"] = ani								}
	if dat > 0 		{		rv["logPri4dat"] = dat								}
	if eve > 0 		{		rv["logPri4eve"] = eve								}
	if ins > 0 		{		rv["logPri4ins"] = ins								}
	if men > 0 		{		rv["logPri4men"] = men								}
	if rve > 0 		{		rv["logPri4rve"] = rve								}
	if rsi > 0 		{		rv["logPri4rsi"] = rsi								}
	if rnd > 0 		{		rv["logPri4rnd"] = rnd								}
	if tst > 0 		{		rv["logPri4tst"] = ins								}
	if all > 0 		{		rv["logPri4all"] = all								}
	return rv
}
/*
func at(app:Int?=nil, doc:Int?=nil, bld:Int?=nil, ser:Int?=nil,
		ani:Int?=nil, dat:Int?=nil, eve:Int?=nil, ins:Int?=nil,
		men:Int?=nil, rve:Int?=nil, rnd:Int?=nil, tst:Int?=nil, all:Int?=nil,
*/
 /// 3b. Neutered (with suffix X) returns an empty hash
func logX(prefix:String="",
		  con:Int=0, men:Int=0, doc:Int=0, bld:Int=0, ser:Int=0, eve:Int=0, dat:Int=0,
		  rve:Int=0, rsi:Int=0, rnd:Int=0, ani:Int=0, ins:Int=0, tst:Int=0, all:Int=0)
		  -> FwConfig { return [:] }
