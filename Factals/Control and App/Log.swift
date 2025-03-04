// Log.swift -- common support files C2018PAK

// Log must deal with the case that it should handle it's own printing before Log
// lifeCycleLogger

//import SwiftLog  https://swiftpackageindex.com/apple/swift-log

import SceneKit

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
//	}
//}

	 // Someday: static var osLogger:OSLog? = OSLog(subsystem:Foundation.Bundle.main.bundleIdentifier!, category:"havenwant?")
extension Log {
	 // MARK: - 1. Static Class Variables:
	static var currentLogNo		= -1		// Active now, -1 --> none
	static var maximumLogNo		= 0			// Next Log index to assign. (Now exist 0..<nextLogIndex)

	static var defaultParams : FwConfig	{
		params4app				+
		params4partPp			+			//	pp... (20ish keys)
		params4logs							// "debugOutterLock":f, "breakAtLogger":1, "breakAtEvent":50
	}
	static let  shared			= Log(name:"Shared Log", configure:logAt(all:appLogN)+defaultParams)
}
extension Log : Logd {
	func logd(_ format:String, _ args:CVarArg..., terminator:String="\n") {
		let (nls, msg)			= String(format:format, arguments:args).stripLeadingNewLines()
		Log.shared.log(nls + msg, terminator:terminator)
	}
}

class Log : Codable, FwAny {	// Never Equatable, NSCopying, NSObject // CherryPick2023-0520: remove FwAny
	 // MARK: - 2. Object Variables:
	 // Identification of Log
	let nameTag					= getNametag()
	var name 					= "untitled"
	var logNo		   			= -1		// Index number of this log

	 // Each Log has an event number
	var eventNumber		   		= 1			// Current entry number (runs 1...)

	 // Breakpoint
	var breakAtEvent			= 0			// 0:UNDEF, 1... : An Event
	var breakAtLogger			= 0			// 0:UNDEF, 1... : The Hot Log

	var logEvents				= true

	var verbosity   : [String:Int]? = [:] 	 // Current logging verbosity filter to select log messages

	 /// REALLY UGLY: what if different threads using log?
	var msgPriority : Int?		= nil		// hack: pass argument to message via global
	var msgFilter   : String?	= nil
	var simTimeLastLog	:Float? = -1//nil
	var logTime			: Bool	= true

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
		Log.maximumLogNo		+= 1
		logNo					= Log.maximumLogNo				// Logs have unique number
		self.name				= name
		print("----- ALLOCATED Log\(logNo): '\(name)',   verbosity:\(verbosity?.pp(.line) ?? "nil")")				// ppUid or pp(.line) breaks this
			// Learnings:	1) Cannot use Log here -- we're initting a Log!
			//				2) \(ppUid(self)) uses a Log! (but

//		makeDummyLogEntries()
//		print("ALLOCATED Log\(logNo)(\(ppUid(self)))  '\(title)',   verbosity:\(verbosity?.pp(.line) ?? "nil")")
	}
//	private init()
//	{
//	}
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
		if let lev				= c.bool("logEvents")	{
			logEvents			= lev											}
		if let t 				= c.bool("logTime")		{
			logTime				= t												}
		if let bae				= c.int("breakAtEvent")	{
			breakAtEvent		= bae											}
		if let bal				= c.int("breakAtLogger"){
			breakAtLogger		= bal											}

		 // Load verbosity filter from keys starting with "logPri4", if there are any.
		let verb 				= verbosityInfoFrom(c)
		if verb.count > 0 {
			verbosity 			= verb
		}
	}
	 /// Return a Dictionary of keys starting with "logPri4". They control verbosity.
	func verbosityInfoFrom(_ config:FwConfig) -> [String:Int] {
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
	func ppVerbosityOf(_ config:FwConfig) -> String {
		let verbosityHash		= verbosityInfoFrom(config)
		if verbosityHash.count > 0 {
			var msg				=  "\(logNo)(\(ppUid(self))).verbosity "
			msg					+= "=\(verbosityHash.pp(.line)) Cause:"
			msg					+= config.string_("cause")
			return msg
		}
		return ""
	}


// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum LogKeys: String, CodingKey {
		case name
		case logNo
		case entryNo
		case breakAtEvent, breakAtLogger
		case logEvents
		case verbosity
		case msgPriority
		case msgFilter
		case simTimeLastLog
		case logTime
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
		try container.encode(logNo,				forKey:.logNo					)
		try container.encode(eventNumber,		forKey:.entryNo					)
		try container.encode(breakAtEvent,		forKey:.breakAtEvent			)
		try container.encode(breakAtEvent,		forKey:.breakAtEvent			)
		try container.encode(logEvents,			forKey:.logEvents				)
		try container.encode(verbosity,			forKey:.verbosity				)
		try container.encode(msgPriority,		forKey:.msgPriority				)
		try container.encode(msgFilter,			forKey:.msgFilter				)
		try container.encode(simTimeLastLog,	forKey:.simTimeLastLog			)
		try container.encode(logTime,			forKey:.logTime					)
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
		logNo					= try container.decode(			  Int.self, forKey:.logNo		)
		eventNumber				= try container.decode(			  Int.self, forKey:.entryNo		)
		breakAtEvent			= try container.decode(			  Int.self, forKey:.breakAtEvent)
		breakAtLogger			= try container.decode(			  Int.self, forKey:.breakAtLogger)
		logEvents				= try container.decode(			 Bool.self, forKey:.logEvents	)
		verbosity				= try container.decode( [String:Int]?.self, forKey:.verbosity	)
		msgPriority				= try container.decode(			  Int.self, forKey:.msgPriority	)
		msgFilter				= try container.decode(  	  String?.self, forKey:.msgFilter	)
		simTimeLastLog			= try container.decode(		   Float?.self, forKey:.simTimeLastLog)
		logTime					= try container.decode(			 Bool.self, forKey:.logTime		)
		ppIndentCols			= try container.decode(			  Int.self, forKey:.ppIndentCols)
		ppPorts					= try container.decode(			 Bool.self, forKey:.ppPorts		)
		ppNUid4Tree				= try container.decode(			  Int.self, forKey:.ppNUid4Tree	)
		ppNUid4Ctl				= try container.decode(			  Int.self, forKey:.ppNUid4Ctl	)
		nIndent					= try container.decode(			  Int.self, forKey:.nIndent		)
		atSer(3, logd("Decoded  as? Parts \(ppUid(self))"))
	}
// END CODABLE /////////////////////////////////////////////////////////////////
	// MARK: - 5. Log
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String="\n") {	//String?=nil

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
//		}

		 // Print new Log, if it has changed:
 		if logNo != Log.currentLogNo {						// different than last time
			let lastLogNo		= Log.currentLogNo
			Log.currentLogNo	= logNo							// switch to new
			let x				= lastLogNo >= 0 ? "from Log\(lastLogNo) " : ""
			print("-- SWITCHING \(x)to Log\(logNo): '\(name)',   verbosity:\(verbosity?.pp(.line) ?? "nil")")
		}
		// DO SOME OTHER WAY: sim state shouldn't be actor isolated, but Actors died in HNW
		if let fm				= FACTALSMODEL {
			let sim				= fm.simulator
			let deltaTime 		= sim.timeNow  - (simTimeLastLog ?? 0)
			if logEvents, deltaTime > 0 || simTimeLastLog == nil {
				let globalUp	= sim.globalDagDirUp ? "UP  " : "DOWN"
				let delta 		= (simTimeLastLog==nil) ? "": fmt("+%.3f", deltaTime)
				let dashes		= deltaTime <= sim.timeStep ? "                                  "
															: "- - - - - - - - - - - - - - - - - "
				let chits		= "p\(fm.partBase.tree.portChitArray().count) l\(sim.linkChits) s\(sim.startChits) "
				print(fmt("\t" + "T=%.3f \(globalUp): - - - \(chits)\(dashes)\(delta)", sim.timeNow))
			}
			simTimeLastLog		= sim.timeNow
		}
		 // Strip leading \n's:
		let (newLines, format)	= format_.stripLeadingNewLines()

		 // Formatted arguments:
		var rv 					= ppProcAreaPriority()
		rv						+= String(format:format, arguments:args)

		 // Banner Line
		if let ban 				= banner {
			print("\n" + "***** " + ban + " *****")
		}
		print(newLines + fmt("%d.%03d%@", logNo, eventNumber, rv), terminator:terminator )

		 // Breakpoint Stop?			// p (breakAtLogger, logNo, breakAtEvent, eventNumber)
		if breakAtLogger == logNo,
		   breakAtEvent == eventNumber {
			panic("Encountered Break at Event \(breakAtEvent) in Log \(breakAtLogger).")
		}
		eventNumber				+= 1		// go on to next log number
	}
     // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux/*[:]*/) -> String {
		return ppFixedDefault(mode, aux)		// NO, try default method
	}
	 /// Character to represent current Thread ID:
	var ppCurThread : String {
		let threadName			= Thread.current.name ?? "??349"
		guard let n				= threadNameCache.firstIndex(of:threadName) else {
			threadNameCache.append(threadName)		/// add to cache
			return self.ppCurThread					/// try again
		}
		assert(n < 26, "more than 26 threads not supported")
		let nInt 				= Int(("A" as UnicodeScalar).value) + n
		let nChar				= Character(UnicodeScalar(nInt)!)
		return String(nChar)	// n as Character
	}
	var threadNameCache : [String] = []

	 /// get a token identifying Filter and current Lock owner
	func ppProcAreaPriority() -> String {			// " Acon4 " or " A<?>? "
		var rv					= " "
		rv						+= ppCurThread 	// Thread identifier: e.g: "A"
		rv 						+= msgFilter ?? "<?>"	 			//e.g: "app"
		let mp : Int?			=  msgPriority	// avoids concurrency problem!!!
		rv						+= mp != nil ? "\(mp!)" : "?"		//e.g: "4"
		rv						= rv.field(-9, dots:false, grow:true)
		rv						+= " "
		return rv
	}
//	static var ppLogFromBlank : String {
//		let nLog				= 3				// a quick approximation
//		return  String(repeating: " ", count:Log.shared.ppProcAreaPriority().count + nLog)
//	}

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

	var description		 : String {		 "d'Log\(logNo) \(name)'"				}
	var debugDescription : String {		"dd'Log\(logNo) \(name)'"				}
	var summary			 : String {		 "s'Log\(logNo) \(name)'"				}
}
var debugOutterLock				= true		// default value (set by config.debugOutterLock)

var warningLog : [String] 		= []
var logNErrors					= 0

func warning(target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let msg						= fmt(format, args)
	warningLog.append(msg)
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	Log.shared.log(banner:targName + "WARNING \(warningLog.count) ", msg + "\n")
}
func error(  target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	logNErrors					+= 1
	Log.shared.log(banner:targName + "ERROR \(logNErrors) ", format, args)
}


