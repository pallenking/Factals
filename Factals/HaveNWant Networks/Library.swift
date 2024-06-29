 //  Library.swift -- Define simple HaveNWant Network in code C2018PAK
// The Library has many Books. Each book has a number of HnwMachines in it.

import SceneKit

class Library {			// NEVER NSCopying, Equatable : NSObject// CherryPick2023-0520: add :FwAny

	 // MARK: - 1. Register all Libraries HERE!
	static let books : [Book] = [		// In order of evaluation
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
	var fileName : String

	 // MARK: - 3. Factory
	init(_ fileName:String) {
		self.fileName			= fileName
	}
	var args  : ScanForKey?		= nil
	var state : ScanState		= ScanState()		// class
	var answer: HnwMachine		= HnwMachine()		// struc

	var count : Int				{
		var state				= ScanState()
		let args				= ScanForKey(selectionString:"", wantOnlyIndex:true)
		loadTest(args:args, state:&state)
		return state.scanTestNum
	}

	 // Each Library file loads an answer if it is selected
	func loadTest(args:ScanForKey, state:inout ScanState) {
		self.args				= args
		self.state				= state
		self.answer				= HnwMachine()
	}

	static func hnwMachine(fromSelector s:String?) -> HnwMachine? {	//LibraryLibrary
		guard let s 			= s else { return nil } // no selector, no lib
		var rv : HnwMachine?	= nil					// search value for desired string
		let args				= ScanForKey(selectionString:s, wantOnlyIndex:false)

		 // 1. look in all libraries
		var state				= ScanState()
		for book in Library.books {
	/**/	book.loadTest(args:args, state:&state)		// state persists across library probes
			 // Return selected test if valid:
			if book.answer.trunkClosure != nil {
				 // REMOVED to allow greedy xr()
				assert(rv == nil, """
					Two entries for selector: '\(s)'
							\((rv!.title ?? "?").field(12)):(rv!.ansTestNum)\t line:(rv!.ansLineNumber!)
							(book.name.field(12)):(book.answer.ansTestNum)\t line:(book.answer.ansLineNumber!)
					""")
				rv				= book.answer
			}
		}								// no, loop for another
		return rv
	}
	static func catalog() -> Library {
		let args				= ScanForKey(selectionString:"", wantOnlyIndex:true)
		let rv					= Library("catalog")

		 // Scan through all Library swift source file, stop at first
		for book in Library.books {
	/**/	book.loadTest(args:args, state:&rv.state)	// state persists across library probes
		}		// Hack: Stop after first found.  Ignore multi-source xr('s.
		 // Return list of titles in a master catalog.
		return rv
	}
	var fwClassName		 : String	{	"Library"								}

         // MARK: - 17. Debugging Aids
	var description		 : String 	{	return  "d'\(fwClassName) \(fileName)'"	}
	var debugDescription : String	{	return "dd'\(fwClassName) \(fileName)'"	}
	var summary			 : String	{	return  "s'\(fwClassName) \(fileName)'"	}
}
extension Library : Uid {
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
		Log.app.log("\(pp(.uidClass)): \(format)", args, terminator:terminator)
		//let log				= FACTALSMODEL!.log
	}
}

	/// Create FwConfig for Logging
   /// - Parameters:
  ///   - prefix: Set to "*" for XCTests
 /// - Returns: Hash for logPri4 verbosity
func logAt(
		app:Int = -1,
		doc:Int = -1,
		bld:Int = -1,
		ser:Int = -1,
		ani:Int = -1,
		dat:Int = -1,
		eve:Int = -1,
		ins:Int = -1,
		men:Int = -1,
		rve:Int = -1,
		rsi:Int = -1,
		rnd:Int = -1,
		tst:Int = -1,
 		all:Int = -1
		) -> FwConfig {
	var rv : FwConfig		= [:]		// default = log (logAt) nothing

	if app >= 0 	{		rv["logPri4app"] = app								}
	if doc >= 0 	{		rv["logPri4doc"] = doc								}
	if bld >= 0 	{		rv["logPri4bld"] = bld								}
	if ser >= 0 	{		rv["logPri4ser"] = ser								}
	if ani >= 0 	{		rv["logPri4ani"] = ani								}
	if dat >= 0 	{		rv["logPri4dat"] = dat								}
	if eve >= 0 	{		rv["logPri4eve"] = eve								}
	if ins >= 0 	{		rv["logPri4ins"] = ins								}
	if men >= 0 	{		rv["logPri4men"] = men								}
	if rve >= 0 	{		rv["logPri4rve"] = rve								}
	if rsi >= 0 	{		rv["logPri4rsi"] = rsi								}
	if rnd >= 0 	{		rv["logPri4rnd"] = rnd								}
	if tst >= 0 	{		rv["logPri4tst"] = ins								}
	if all >= 0 	{		rv["logPri4all"] = all								}
	return rv
}

// synchronize with 'func at(app ...'

 /// 3b. Neutered (with suffix X) returns an empty hash
func logX(prefix:String="",
		  con:Int=0, men:Int=0, doc:Int=0, bld:Int=0, ser:Int=0, eve:Int=0, dat:Int=0,
		  rve:Int=0, rsi:Int=0, rnd:Int=0, ani:Int=0, ins:Int=0, tst:Int=0, all:Int=0)
		  -> FwConfig { return [:] }
