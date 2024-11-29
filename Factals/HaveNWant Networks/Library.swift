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
	var nameTag					= getNametag()
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
/**/		book.loadTest(args:args, state:&rv.state)	// state persists across library probes
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
extension Library : Logd {
	func logd(_ format:String, _ args:CVarArg..., terminator:String="\n") {
		Log.app.log("\(pp(.tagClass)): \(format)", args, terminator:terminator)
	}
}
