//
//  Book.swift
//  Factals
//
//  Created by Allen King on 6/24/24.
//

import SceneKit

extension Book : Logd {
}

class Book {			// NEVER NSCopying, Equatable : NSObject// CherryPick2023-0520: add :FwAny
	 // MARK: - 2. Register all Libraries HERE!
	let nameTag					= getNametag()
	var fileName : String

	 // MARK: - 3. Factory
	init(_ fileName:String) {
		self.fileName			= fileName
	}
	var args  : ScanForKey?		= nil
	var state : ScanState		= ScanState()		// class
	var answer: HnwMachine		= HnwMachine()		// struc

	 // Each Library file loads an answer if it is selected
	func loadTest(args:ScanForKey, state:inout ScanState) {
		self.args				= args
		self.state				= state
		self.answer				= HnwMachine()
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

		if args!.argOnlyIndex {				// Generate Library menus
//			guard testName?.first == "+" else {	return	} // skip testName not starting with +
			let title			= "\(state.scanTestNum)  \(fileName):\(lineNumber):  " + (testName ?? "-")
			let elt				= LibraryMenuArray(tag:state.scanTestNum, title:title, parentMenu:state.scanSubMenu)
			state.scanCatalog.append(elt)
			return
		}

		 // ///////////// Wants Test ///////////////////////////////
		let title				= testName != nil ? "\(testName!)" : "unnamed_\(state.scanTestNum)"
		var matchCause : String? =
			args!.argName != nil &&				// Search by name
			args!.argName == testName ?			//   and it matches
				"testName  ''\(testName!)''" :	// yes, name matchs
				args!.argNumber == state.scanTestNum ?// no, numbers match?
					" ''scene #\(state.scanTestNum)''" :// yes, match
					nil
		matchCause				= matchCause ??
			(!markedXr ?							// is this marked xr?
				nil :									// no, just r(), ignore
				args!.argName == "xr()" &&			// yes, is name xr() and
				 args!.argNumber < 0 ?				//   no wanted number?
					"Network marked with xr()" :	// yes
					nil)									// no, ignore

		if matchCause != nil {						// Save in ANSWER
			assert(answer.trunkClosure==nil, "Two Closures found:\n"
			  +	"\t Previous = \(answer.testNum):\(answer.fileName ?? "lf823").\(answer.lineNumber!) "
			  +		"'\(answer.title ?? "none")' <-- IGNORING\n"
			  +	"\t Current  = \(state.scanTestNum):\(fileName).\(       lineNumber ) '\(         title)'")

			 // CAPTURE: Copy current to exp
			 // from Chosen Test
			answer.sourceOfTest	= "\(args!.argName):'\(args!.argNumber)"
			answer.title		= title
//			answer.postTitle	= ""
			answer.config 		= config
			answer.trunkClosure = rootClosure
			 // From Scan
			answer.testNum		= state.scanTestNum
			answer.subMenu		= state.scanSubMenu
			 // Anonymous from Scan
			answer.fileName		= fileName
			answer.lineNumber 	= lineNumber
			atBld(7, Log.ofApp.log("=== Matched Because: \(matchCause!) ===\n" +
								 "=========<<< \(answer.ppr()) >>>=========\n" +
								 "========================================================================\n"))
		}
	}
	var fwClassName		 : String	{	"Book"									}

         // MARK: - 17. Debugging Aids
	var description		 : String 	{	return  "d'\(fwClassName) \(fileName)'"	}
	var debugDescription : String	{	return "dd'\(fwClassName) \(fileName)'"	}
	var summary			 : String	{	return  "s'\(fwClassName) \(fileName)'"	}
}
 // ================ User Sugar, for prettier networks: ========================
extension Book {

	 // 1. Root configuration:
	  /// Set the link velocity
	 /// - Parameter vel:  log2 of links/sec
	func vel(_  vel:Float) -> FwConfig 	{	return ["linkVelocityLog2":vel] 	}
	 /// Does NOTHING, except easily convertable to vel()
	func velX(_ vel:Float) -> FwConfig 	{	return [:] 							}

	// 2. Used in tests to set initial camera
	func selfiePole(h:Float?=nil, s:Float?=nil, u:Float?=nil, z:Float?=nil, o:Float?=nil) -> FwConfig {//xyzzy15.1
		var rv : FwConfig 		= [:]
		if let h {	rv["h"] 	= h												}
		if let s {	rv["s"] 	= s												}
		if let u {	rv["u"] 	= u												}
		if let z {	rv["z"]		= z												}
		if let o {	rv["o"]		= o												}
		return ["selfiePole":rv]
	}
	 /// 2b. Neutered Camera Parameters:
	func cameraX(h:Float?=nil, s:Float?=nil, u:Float?=nil, z:Float?=nil) -> FwConfig {
		return [:]
	}
}

struct ScanForKey : Codable {
  	 //selectionString+------FUNCTION---------+-argName:---argNumber:
	 //	nil			  |	Blank scene			  |	nil			-1
	 //	"entry<N>"	  |	entry N				  |	nil			N *
	 //	"xr()"		  |	entry labeled as xr() |	"xr()" *	-1
	 //	<name>		  |	named scene			  |	<name> *	-1
	init(selectionString:String?, wantOnlyIndex w:Bool) {
		 // --- selectionString -> want****:
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
	var argNumber		: Int = -1		// if select scene by number
	var argName 		: String?=nil	// if select scene by name
	var argOnlyIndex	: Bool			// Used for menu preparation
}
	  // MARK: - 2.4.3 Machine resulting from Scan
struct HnwMachine {		// : Codable
	 // From Chosen Test
	var sourceOfTest: String  	= "HnwMachine"		// Reason for Fetching String
	var title		: String?  	= nil				// Network name from library
	var postTitle	: String  	= "HnwMachine.post"	// Number of Ports String
	func titlePlus() -> String 	{ sourceOfTest + (title ?? "<???>") + postTitle}

	var config		: FwConfig	= [:]		// [NOT CODABLE]

	 // From Scan:
	var testNum  	: Int		= 0
	var subMenu 	: String	= ""		// the scanSubMenu of the test found
	 // Anonymous from Scan
	var trunkClosure:PartClosure? = nil		// [NOT CODABLE] Closure from Library, generates Part
	var fileName	: String?	= nil
	var lineNumber	:Int?		= nil
	func ppr() -> String {
		"test \(testNum.asString_.field(4))\t source:\(fileName!.field(20))::\(lineNumber!)\t title:'\(title ?? "?")'"
	}
}

	 // MARK: - 2.4.2 Scan State
class ScanState : Codable {
	var nameTag					= getNametag()
	var scanTestNum	: Int		= 0			// Number of elements scanned (so far, total)
	var scanSubMenu : String	= ""		// name of current FactalsModel sub-menu
	var scanCatalog	: [LibraryMenuArray]=[]	// Catalog of Library
	var scanEOFencountered:Bool = false		// marks scan done
}
struct LibraryMenuArray	: Codable, Identifiable {		// of input array (upstream)
	var id 			= UUID()													// var id : Int { tag	}
	var tag		  	: Int
	var title	  	: String
	var parentMenu	: String				// path scene/decoder/...
}
