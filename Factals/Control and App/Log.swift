// Log.swift -- common support files C2018PAK

// Log must deal with the case that it should handle it's own printing before Log
// lifeCycleLogger

import SceneKit

func logd(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String="\n") {
	let sh	 					= Log.shared	// There should be only one Log in the system

	 // Time Change in Similator?
	if let fm					= FACTALSMODEL {
		let sim					= fm.simulator
		let deltaTime 			= sim.timeNow  - (sh.simTimeLastLog ?? 0)
		if deltaTime > 0 || sh.simTimeLastLog == nil {
			let globalUp		= sim.globalDagDirUp ? "UP  " : "DOWN"
			let delta 			= (sh.simTimeLastLog==nil) ? "": fmt("+%.3f", deltaTime)
			let dashes			= deltaTime <= sim.timeStep ? "                                  "
														: "- - - - - - - - - - - - - - - - - "
			let chits			= "p\(fm.partBase.tree.portChitArray().count) l\(sim.linkChits) s\(sim.startChits) "
			print(fmt("\t" + "T=%.3f \(globalUp): - - - \(chits)\(dashes)\(delta)", sim.timeNow))
		}
		sh.simTimeLastLog		= sim.timeNow
	}
	 // Strip leading \n's:
	let (newLines, format)		= format_.stripLeadingNewLines()

	 // Formatted arguments:
	var eventStr 				= sh.procAreaPriorityStr()
	eventStr					+= String(format:format, arguments:args)
								
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

	 // Someday: static var osLogger:OSLog? = OSLog(subsystem:Foundation.Bundle.main.bundleIdentifier!, category:"havenwant?")
extension Log {
	 // MARK: - 1. Static Class Variables:
	static let  shared			= Log(name:"Shared Log", configure:defaultParams)
	static var defaultParams : FwConfig	= [:]
		+ params4app
		+ params4partPp						//	pp... (20ish keys)
		+ params4logDetail						// "debugOutterLock":f
}

class Log : Codable, FwAny, Uid {	// Never Equatable, NSCopying, NSObject // CherryPick2023-0520: remove FwAny
	 // MARK: - 2. Object Variables:
	 // Identification of Log
	let nameTag					= getNametag()
	var name 					= "untitled"

	 // Each Log has an event number
	var eventNumber		   		= 1			// Current entry number (runs 1...)

	 // Breakpoint
	var breakAtEvent			= 0			// 0:UNDEF, 1... : An Event

	var detailWanted : [String:Int] = [:] 	 // Current logging detail filter to select log messages

	 // MARK: - 2. REALLY UGLY: what if different threads using log?
	var msgPriority : Int?		= nil		// hack: pass argument to message via global
	var msgFilter   : String?	= nil
	var simTimeLastLog	:Float? = -1//nil

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
	init(name:String, configure c:FwConfig = [:])	{			//_ config:FwConfig = [:]
		configure(from:c)
		self.name				= name
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
		if let lo				= c.bool("debugOutterLock"){
			debugOutterLock		= lo											}
		if let bae				= c.int("breakAtEvent")	{
			breakAtEvent		= bae											}

		 // Load detail filter from keys starting with "logPri4", if there are any.
		let detail 				= detailInfoFrom(c)
		if detail.count > 0 {
			detailWanted 		= detail
		}
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


// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum LogKeys: String, CodingKey {
		case name
		case entryNo
		case breakAtEvent
		case detail
		case msgPriority
		case msgFilter
		case simTimeLastLog
		case ppIndentCols
		case ppPorts
		case ppNUid4Tree
		case ppNUid4Ctl
		case nIndent
	}
	 // Serialize 					// po container.contains(.name)
	func encode(to encoder: Encoder) throws  {
		var container 			= encoder.container(keyedBy:LogKeys.self)
		try container.encode(name,				forKey:.name					)
		try container.encode(eventNumber,		forKey:.entryNo					)
		try container.encode(breakAtEvent,		forKey:.breakAtEvent			)
		try container.encode(breakAtEvent,		forKey:.breakAtEvent			)
		try container.encode(detailWanted,		forKey:.detail					)
		try container.encode(msgPriority,		forKey:.msgPriority				)
		try container.encode(msgFilter,			forKey:.msgFilter				)
		try container.encode(simTimeLastLog,	forKey:.simTimeLastLog			)
		try container.encode(ppIndentCols,		forKey:.ppIndentCols			)
		try container.encode(ppPorts,			forKey:.ppPorts					)
		try container.encode(ppNUid4Tree,		forKey:.ppNUid4Tree				)
		try container.encode(ppNUid4Ctl,		forKey:.ppNUid4Ctl				)
		try container.encode(nIndent,			forKey:.nIndent					)
		atSer(3, logd("Encoded"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		//super.init()

		let container 			= try decoder.container(keyedBy:LogKeys.self)
		name					= try container.decode(		   String.self, forKey:.name		)
		eventNumber				= try container.decode(			  Int.self, forKey:.entryNo		)
		breakAtEvent			= try container.decode(			  Int.self, forKey:.breakAtEvent)
		detailWanted			= try container.decode(  [String:Int].self, forKey:.detail		)
		msgPriority				= try container.decode(			  Int.self, forKey:.msgPriority	)
		msgFilter				= try container.decode(  	  String?.self, forKey:.msgFilter	)
		simTimeLastLog			= try container.decode(		   Float?.self, forKey:.simTimeLastLog)
		ppIndentCols			= try container.decode(			  Int.self, forKey:.ppIndentCols)
		ppPorts					= try container.decode(			 Bool.self, forKey:.ppPorts		)
		ppNUid4Tree				= try container.decode(			  Int.self, forKey:.ppNUid4Tree	)
		ppNUid4Ctl				= try container.decode(			  Int.self, forKey:.ppNUid4Ctl	)
		nIndent					= try container.decode(			  Int.self, forKey:.nIndent		)
		atSer(3, logd("Decoded  as? Parts \(ppUid(self))"))
	}
// END CODABLE /////////////////////////////////////////////////////////////////
     // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux/*[:]*/) -> String {
		return ppFixedDefault(mode, aux)		// NO, try default method
	}
	 /// Character to represent current Thread ID:
	var threadNameCache : [String] = []
	var ppCurThread 	: String {
		let threadName			= Thread.current.name ?? "??349"
		guard let n				= threadNameCache.firstIndex(of:threadName) else {
			threadNameCache.append(threadName)		// new, add
			return self.ppCurThread					// try again
		}
		assert(n < 26, "more than 26 threads not supported")
		let nInt 				= Int(("A" as UnicodeScalar).value) + n
		let nChar				= Character(UnicodeScalar(nInt)!)
		return String(nChar)	// n as Character
	}

	 /// get a token identifying Filter and current Lock owner
	func procAreaPriorityStr() -> String {			// " Acon4 " or " A<?>? "
		var rv					= " "
		rv						+= ppCurThread 	// Thread identifier: e.g: "A"
		rv 						+= msgFilter ?? "<?>"	 			//e.g: "app"
		let mp : Int?			=  msgPriority	// avoids concurrency problem!!!
		rv						+= mp != nil ? "\(mp!)" : "?"		//e.g: "4"
		rv						= rv.field(-9, dots:false, grow:true)
		rv						+= " "
		return rv
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
	 // N.B: Sometimes it is hard to get to this w/o using DOC. Then use global params4aux
//	var params4aux : FwConfig	{	DOC?.fmConfig ?? [:]		}

	var description		 : String {		 "d'Log \"\(name)\""				}
	var debugDescription : String {		"dd'Log \"\(name)\""				}
	var summary			 : String {		 "s'Log \"\(name)\""				}
}
var debugOutterLock				= true		// default value (set by config.debugOutterLock)

var warningLog : [String] 		= []
var logNErrors					= 0

func warning(target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let msg						= fmt(format, args)
	warningLog.append(msg)
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	logd(banner:targName + "WARNING \(warningLog.count) ", msg + "\n")
}
func error(  target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	logNErrors					+= 1
	logd(banner:targName + "ERROR \(logNErrors) ", format, args)
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


