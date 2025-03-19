// Log.swift -- common support files C2018PAK

// Log must deal with the case that it should handle it's own printing before Log
// lifeCycleLogger

import SceneKit

var logNErrors					= 0

func warning(target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let msg						= fmt(format, args)
	Log.shared.warningLog.append(msg)
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	Log.shared.logd(banner:targName + "WARNING \(Log.shared.warningLog.count) ", msg + "\n")
}
func error(  target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	logNErrors					+= 1
	Log.shared.logd(banner:targName + "ERROR \(logNErrors) ", format, args)
}

	 // Someday: static var osLogger:OSLog? = OSLog(subsystem:Foundation.Bundle.main.bundleIdentifier!, category:"havenwant?")
extension Log {
	 // MARK: - 1. Static Class Variables:
	static let shared			= Log(configure:defaultParams)
	static var defaultParams : FwConfig	= [:]
		+ params4app
		+ params4partPp						//	pp... (20ish keys)
		+ params4logDetail					// "debugOutterLock":f
}
		// elim Uid? Actor?
class Log : Uid {				// Never Equatable, NSCopying, NSObject // CherryPick2023-0520: remove FwAny
	 // MARK: - 2. Object Variables:
	 // Identification of Log
	let nameTag					= getNametag()

	fileprivate(set) var eventNumber		   		= 1			// Current entry number (runs 1...)
	private(set) var breakAtEvent			= 0			// 0:UNDEF, 1... : An Event
	private(set) var detailWanted : [String:Int] = [:] 	// Current logging detail filter to select log messages

	 // MARK: - 2. REALLY UGLY: what if different threads using log?

	var debugOutterLock			= true		// default value (set by config.debugOutterLock)
	var warningLog : [String] 	= []

	fileprivate var simTimeLastLog	:Float? = -1//nil

	// MARK: pp stuff
	var ppIndentCols 	: Int	= 0
	var ppPorts			: Bool	= true
				 /// UID Pseudo-Address Digits for Parts/Vew Tree items
	 /// default uidDigits (0:off, 3:common)
	static let uidDigitsDefailt	= 3
	var ppNUid4Tree	 	: Int	= uidDigitsDefailt
	 /// UID Pseudo-Address Digits for Control items
	var ppNUid4Ctl		: Int	= uidDigitsDefailt
					
	 /// Returns the string " |" to START indentation
	var nIndent			 : Int	= 0		// state for
	func indentString(minus:Int=0) -> String {
		let n					= max(nIndent - minus, 0)
		return  String(repeating: "| ", count:n)
	}
	  /// Returns the string " |" to END indentation
	 // Consider using field()
	func unIndent(_ previous:String) -> String {
		let nUnIndent			= ppIndentCols/2 - nIndent
		if nUnIndent > 0 {
			return previous + String(repeating: ". ", count:abs(nUnIndent))
		}else{
			 // Negative unindents prune previous String. This tightens printouts
			return String(previous.dropLast(-2*nUnIndent))
		}
	}
	 /// e.g. " " + UID + " "
	func pidNindent(for ob:Uid?) -> String {
		return ppUid(pre:" ", ob, post:"  ") + indentString()
	}

	// MARK: - 3. Factory
	// /////////////////////////////////////////////////////////////////////////
	private init(configure c:FwConfig = [:]){			//_ config:FwConfig = [:]
		configure(from:c)
			// Learnings:	1) Cannot use Log here -- we're initting a Log!
			//				2) \(ppUid(self)) uses a Log! (but
	}
	//private init()
	//{
	//}
	 /// Configure Log facilities
	func configure(from c:FwConfig) {

		 // Unpack frequently used config hash elements to object parameters
		if let pic 				= c.int("ppIndentCols")	{
			ppIndentCols 		= pic											}
		if let ppp				= c.bool("ppPorts") 	{
			ppPorts				= ppp											}
		if let uidd4p			= c .int("ppNUid4Tree") {
			ppNUid4Tree 		= uidd4p										}
		if let uidd4c			= c .int("ppNUid4Ctl")	{
			ppNUid4Ctl 			= uidd4c										}
		if let lo				= c.bool("debugOutterLock") {
			debugOutterLock		= lo											}
		if let bae				= c.int("breakAtEvent")	{
			breakAtEvent		= bae											}

		 // Load detail filter from keys starting with "logPri4", if there are any.
		let detail 				= detailInfoFrom(c)
		if detail.count > 0 {
			detailWanted 		= detail
		}
	}
	// MARK: - ?. Program logs events whose detail is selected by Log's detail
	 /// Emit a Log Event:
	/// - parameters:
	///   - eventArea: 	kind of event encountered
	///   - eventDetail:	detail of the event, how geeky is it 0<msgPri<10
	///   - eventAction: 	action to be executed if area/detail matches
	func at(_ eventArea:String, _ eventDetail:Int, format:String, args:CVarArg..., terminator:String?=nil) {
		if eventIs(ofArea:eventArea, detail:eventDetail) {
			let format				= eventArea + String(format:"%1d", eventDetail) + " " + format
			Log.shared.logd(format, args, terminator:terminator ?? "\n", msgFilter:eventArea, msgPriority:eventDetail)
		}
	}
	func eventIs(ofArea eventArea:String, detail eventDetail:Int) -> Bool {
		assert(eventDetail >= 0 && eventDetail < 10, "Message prioritiy \(eventDetail) isn't in range 0...9")
		let detailWanted			= Log.shared.detailWanted
		if let x = detailWanted [eventArea] {	// area definition supercedes
			return x > eventDetail
		}
		if let x = detailWanted ["all"] {		// else default definition?
			return x > eventDetail												}
		return false
	}
	 /// Return a Dictionary of keys starting with "logPri4". They control detailWanted.
	func detailInfoFrom(_ config:FwConfig) -> [String:Int] {
		var rv : [String:Int] 	= [:]
		for (keyI, valI) in config {		// Scan config being loaded:
			if keyI.hasPrefix("logPri4"),		// that start with "logPri4"
			  let newVal 		= Int(fwAny:valI) {	// have an integer value
				assert(newVal >= 0 && newVal <= 9, "\(keyI):\(valI) not in range 0...9")
				let newKey		= String(keyI.dropFirst("logPri4".count))
				rv[newKey]		= newVal				// save trailing part
			}
		}
		return rv
	}
	func ppdetailOf(_ config:FwConfig) -> String {
		let detailHash			= detailInfoFrom(config)
		guard detailHash.count > 0 else {		return "" 						}
		var msg					=  "(\(ppUid(self))).detailWanted "
		msg						+= "=\(detailHash.pp(.line)) Cause:"
		msg						+= config.string_("cause")
		return msg
	}

	func logd(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String="\n",
									msgFilter:String?=nil, msgPriority:Int?=nil) {
		let sh	 					= Log.shared	// There should be only one Log in the system

		 // Time Change in Similator?
		if let fm					= FACTALSMODEL {
			let sim					= fm.simulator
			let deltaTime 			= sim.timeNow  - (sh.simTimeLastLog ?? 0)
			if deltaTime > 0 || sh.simTimeLastLog == nil {
				let globalUp		= sim.globalDagDirUp ? "UP  " : "DOWN"
				let delta 			= (sh.simTimeLastLog==nil) ? "": fmt("+%.3f", deltaTime)
				let dashes			= deltaTime <= sim.timeStep ? "        | "
																: "- - - - + "
				let chits			= "p\(fm.partBase.tree.portChitArray().count) l\(sim.linkChits) s\(sim.startChits) "
				print(fmt("\t" + "T=%.3f \(globalUp): - - - \(chits)\(dashes)\(delta)", sim.timeNow))
			}
			sh.simTimeLastLog		= sim.timeNow
		}
		 // Strip leading \n's:
		let (newLines, format)		= format_.stripLeadingNewLines()

		 // Formatted arguments:
		var rv						= " "
		rv 							+= msgFilter ?? "<?>"	 			//e.g: "app"
		let mp : Int?				=  msgPriority	// avoids concurrency problem!!!
		rv							+= mp != nil ? "\(mp!)" : "?"		//e.g: "4"
		rv							= rv.field(-9, dots:false, grow:true)
		rv							+= " "
		var eventStr 				= " "//sh.procAreaPriorityStr()
		eventStr					+= String(format:format, arguments:args)


		var aaa					= pp(.fullName)
//		if let selfIsPart		= self as? Part {
//			aaa					= selfIsPart.pp(.fullName)
//		}
//		let bbb					= aaa.field(-25)



		 // Banner Line
		if let ban 					= banner {
			print("\n" + "***** " + ban + " *****")
		}
		print(newLines + fmt("%03d%@", sh.eventNumber, eventStr), terminator:terminator )

		if sh.breakAtEvent == sh.eventNumber {
			panic("Encountered Break at Event \(sh.breakAtEvent).")
		}
		sh.eventNumber				+= 1		// go on to next log number
	}

     // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp/*[:]*/) -> String {
		return ppFixedDefault(mode, aux)		// NO, try default method
	}
	 /// Character to represent Transaction ID:
	var ppCurLock : String {
		if let curLockStr		= FACTALSMODEL?.partBase.curOwner {
			return Log.shortNames[curLockStr] ?? "<<\(curLockStr)>>"
		}
		return ".,."
	}
	static let shortNames		= [
		 // Name in code			/// Name returned / printed
		"buildSceneMenus"				: "mnu",	// was "men"
		"updateVewNScn"					: "ins",
		"scheneAction"					: "sa ",
		"buildVew"						: "bv ",	 // Short Thread Name
		"renderLoop"					: "ren",
		"simulationTask"				: "sim",
		"animatePole"					: "pol",
		"toggelOpen"					: "opn",
		"toggelOpen4"					: "op4",
		"toggelOpen5"					: "op5",
		"toggelOpen6"					: "op6",
	]
	 // N.B: Sometimes it is hard to get to this w/o using DOC. Then use global params4defaultPp
//	var params4defaultPp : FwConfig	{	DOC?.fmConfig ?? [:]		}

	var description		 : String {		 "d'Log'"				}
	var debugDescription : String {		"dd'Log'"				}
	var summary			 : String {		 "s'Log'"				}
}
    //import SwiftLog  https://swiftpackageindex.com/apple/swift-log
//import OSLog
//extension Log {
//	func makeDummyLogEntries() {
//		guard let logger		= Log.osLogger else { fatalError()				}
//		os_log("This is a default log message", log:logger, type:.default)
//		os_log("This is an info log message",   log:logger, type:.info)
//		os_log("This is a debug log message",   log:logger, type:.debug)
//		os_log("This is an error log message",  log:logger, type:.error)
//		os_log("This is a fault log message",   log:logger, type:.fault)
//		let userName = "John"
//		let loginStatus = true
//		os_log("U:%{public}@ I: %{public}@", 	log:logger, type:.info, userName, String(loginStatus))
//func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String="\n") {
//		 // Initial simple cutting in OSLog:
//		if false, let logger = Log.osLogger {
//			let formattedBanner = banner != nil ? "\(banner!): " : ""
//			let formatStr = formattedBanner + format_
//
//			os_log("%{public}@%{public}@", log: logger, type: .default, formatStr, terminator)
//	//		os_log(formatStr, log:logger, type:.default, args)
////			os_log("This is a default log message", log:logger, type:.default)
////			os_log("U:%{public}@ I: %{public}@", 	log:logger, type:.info, userName, String(loginStatus))
//			return


