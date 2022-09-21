// Log.swift -- common support files C2018PAK

// Log must deal with the case that it should handle it's own printing before Log

import SceneKit

class Log : NSObject, Codable, FwAny {								// NOT NSObject

	 // MARK: - 1. Class Variables:
	static var currentLogNo		= -1		// Active now, -1 --> none
	static var maximumLogNo		= 0			// Next Log index to assign. (Now exist 0..<nextLogIndex)
	static let entryNosPlog		= 1000000	// H: EventNUMber, LogNUMber

	 // MARK: - 2. Object Variables:
	 // Identification of Log
	var title 					= "untitled"
	var logNo		   			= -1		// Index number of this log

	 // Each Log has an event number
	var entryNo		   			= 1			// Current entry number (runs 1...)

	 // Breakpoint
	var breakAt					= 0			// Composite: logNo * entryNosPlog + eNum

	var logEvents				= true

	 /// Configure Log facilities
	var config4log : FwConfig = [:] {
		didSet {
			// WARNING: Do not use Log inside here! It's not set up yet!

			 // Unpack frequently used config hash elements to object parameters
			if let pic 			= config4log.int("ppIndentCols")	{
				ppIndentCols 	= pic
			}	
			if let ppp			= config4log.bool("ppPorts") 		{
				ppPorts			= ppp
			}	
			if let uidd4p		= config4log .int("ppNUid4Tree") 	{
				ppNUid4Tree 	= uidd4p
			}	
			if let uidd4c		= config4log .int("ppNUid4Ctl")		{
				ppNUid4Ctl 		= uidd4c
			}	
			if let lo			= config4log.bool("debugOutterLock"){
				debugOutterLock	= lo
			}	
			if let lev			= config4log.bool("logEvents")		{
				logEvents		= lev
			}	
			if let t 			= config4log.bool("logTime")		{
				logTime			= t
			}
			if let ba			= config4log .int("breakAt")		{ // (composite, )
				let curBa		= entryNo<0 ? -1 : entryNo%Log.entryNosPlog
				if ba>0 && ba<curBa { // DON'T USE assert(:), it relies on Log!
					panic("Setting  breakAt = \(ba) TOO LATE. Set it after \(curBa)")
				}
				breakAt 		= ba
			}

			 // Load verbosity filter from keys starting with "logPri4", if there are any.
			let verbosityHash	= verbosityInfoFrom(config4log)
			if  verbosityHash.count > 0 {
				verbosity 	= verbosityHash		// Set verbosity filter
			}										// Otherwise do nothing.
		}
	}
	func ppVerbosityOf(_ config:FwConfig) -> String {
		let verbosityHash		= verbosityInfoFrom(config)
		if verbosityHash.count > 0 {
			var msg				=  "\(logNo)(\(ppUid(self))).verbosity "
			msg				 	+= "=\(verbosityHash.pp(.line)) Cause:"
			msg					+= config.string_("cause")
			return msg
		}
		return ""
	}
	func verbosityInfoFrom(_ config:FwConfig) -> [String:Int] {
		   // Process logPri4*** keys. SEMANTICS:
		  //   If NONE with prefix "logPri4" are found, verbosity is unchanged
		 // 	 if some are found, they replace the old verbosity.
		var rv : [String:Int] = [:]
		for (keyI, valI) in config {		// Scan config being loaded:
			if keyI.hasPrefix("logPri4"),		// that start with "logPri4"
			  let newVal 	= Int(fwAny:valI) {	// have an integer value
				assert(newVal >= 0 && newVal <= 9, "\(keyI):\(valI) not in range 0...9")
				let newKey	= String(keyI.dropFirst("logPri4".count))
				rv[newKey]	= newVal				// save trailing part
			}	// pt: Simultaneous accesses to 0x60000300ca68, but modification requires exclusive access.
		}
		return rv
	}
	var verbosity : [String:Int]? = [:] {	 // Current logging verbosity filter to select log messages
		didSet	{	nop							/* for debug */					}
	}

	 /// REALLY UGLY: what if different threads using log?
	var msgPriority : Int?			= nil		// hack: pass argument to message via global
	var msgFilter   : String?		= nil

	static func pp(filter:String?, priority:Int?) -> String {
		return (filter ?? "f=0") + (priority == nil ? "-" : String(priority!))
	}

	var simTimeLastLog	:Float? = -1//nil
	var logTime			: Bool	= true

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
			return previous +  String(repeating: ". ", count:abs(nUnIndent))
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
	init(_ config:FwConfig = [:], title:String) {			//_ config:FwConfig=[:]
		super.init()

		Log.maximumLogNo		+= 1
		logNo					= Log.maximumLogNo				// Logs have unique number
		self.title				= title

		config4log/*active*/	= config + ["cause":"Log" + "([\(config.count) elts], title:\"\(title)\")"]
	}		// N.B: during init context, loading config4log does not trigger its 'didSet'

// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum LogKeys: String, CodingKey {
		case title
		case logNo
		case entryNo
		case breakAt
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
		try container.encode(title,				forKey:.title					)
		try container.encode(logNo,				forKey:.logNo					)
		try container.encode(entryNo,			forKey:.entryNo					)
		try container.encode(breakAt,			forKey:.breakAt					)
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
		super.init()
		let container 	= try decoder.container(keyedBy:LogKeys.self)
		title			= try container.decode(		   String.self, forKey:.title		)
		logNo			= try container.decode(			  Int.self, forKey:.logNo		)
		entryNo			= try container.decode(			  Int.self, forKey:.entryNo		)
		breakAt			= try container.decode(			  Int.self, forKey:.breakAt		)
		logEvents		= try container.decode(			 Bool.self, forKey:.logEvents	)
		verbosity		= try container.decode( [String:Int]?.self, forKey:.verbosity	)
		msgPriority		= try container.decode(			  Int.self, forKey:.msgPriority	)
		msgFilter		= try container.decode(  	  String?.self, forKey:.msgFilter	)
		simTimeLastLog	= try container.decode(		   Float?.self, forKey:.simTimeLastLog)
		logTime			= try container.decode(			 Bool.self, forKey:.logTime		)
		ppIndentCols	= try container.decode(			  Int.self, forKey:.ppIndentCols)
		ppPorts			= try container.decode(			 Bool.self, forKey:.ppPorts		)
		ppNUid4Tree		= try container.decode(			  Int.self, forKey:.ppNUid4Tree	)
		ppNUid4Ctl		= try container.decode(			  Int.self, forKey:.ppNUid4Ctl	)
		nIndent			= try container.decode(			  Int.self, forKey:.nIndent		)
		atSer(3, logd("Decoded  as? RootPart \(ppUid(self))"))
	}
// END CODABLE /////////////////////////////////////////////////////////////////
	 // MARK: - 3.6 NSCopying
	func copy(with zone: NSZone?=nil) -> Any {
		let theCopy 			= Log(title:"theCopyFoo")//: Log		= super.copy(with:zone) as! Log
		theCopy.title			= self.title
		theCopy.logNo			= self.logNo
		theCopy.entryNo			= self.entryNo
		theCopy.breakAt			= self.breakAt
		theCopy.logEvents		= self.logEvents
		theCopy.verbosity		= self.verbosity
		theCopy.msgPriority		= self.msgPriority
		theCopy.msgFilter		= self.msgFilter
		theCopy.simTimeLastLog	= self.simTimeLastLog
		theCopy.logTime			= self.logTime
		theCopy.ppIndentCols	= self.ppIndentCols
		theCopy.ppPorts			= self.ppPorts
		theCopy.ppNUid4Tree		= self.ppNUid4Tree
		theCopy.ppNUid4Ctl		= self.ppNUid4Ctl
		theCopy.nIndent			= self.nIndent
		atSer(3, logd("copy(with as? Log       ''"))
		return theCopy
	}

	 // MARK: - 3.7 Equitable
	func varsOfLogEq(_ rhs:Log) -> Bool {
		return title			== rhs.title
			&& logNo			== rhs.logNo
			&& entryNo			== rhs.entryNo
			&& breakAt			== rhs.breakAt
			&& logEvents		== rhs.logEvents
			&& verbosity		== rhs.verbosity
			&& msgPriority		== rhs.msgPriority
			&& msgFilter		== rhs.msgFilter
			&& simTimeLastLog	== rhs.simTimeLastLog
			&& logTime			== rhs.logTime
			&& ppIndentCols		== rhs.ppIndentCols
			&& ppPorts			== rhs.ppPorts
			&& ppNUid4Tree		== rhs.ppNUid4Tree
			&& ppNUid4Ctl		== rhs.ppNUid4Ctl
			&& nIndent			== rhs.nIndent
	}
	func equalsPart(_ log:Log) -> Bool {
		return	varsOfLogEq(log)
	}


	// MARK: - 5. Log
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {

		 // Print new Log, if it has changed:
 		if logNo != Log.currentLogNo {						// Same as last time
			Log.currentLogNo	= logNo							// switch to new
			// THERE IS A BUG HERE		//		var x				= [1].pp(.line) ?? "nil" // BAD, ["a"] too
										//	//	var x				= "33".pp(.line) ?? "nil"// GOOD
			var x				= "\(logNo). ######## Switching to Log \(logNo)(\(ppUid(self)))   '\(title)',   verbosity:(verbosity?.pp(.line))"
//			var x				= "\(logNo). ######## Switching to Log \(logNo)(\(ppUid(self)))   '\(title)',   verbosity:\(verbosity?.pp(.line) ?? "nil")"
			print(x)
			let evNo			= breakAt % Log.entryNosPlog
			if evNo != 0 && (breakAt/Log.entryNosPlog == logNo) {
				print("                                   breakpoint at EVent N(O)umber \(evNo)")
			}
		}
		 // Print Simulator's time, if it has changed:
		if let sim				= DOCfwGutsQ?.rootPart.simulator,
//		  msgPriority == nil || msgPriority! > 2,	// hack: argument passed to message via global
		  simTimeLastLog != nil
		{
			let deltaTime 		= sim.timeNow  - (simTimeLastLog ?? 0)
			if logEvents,
			 deltaTime > 0 || simTimeLastLog==nil {
				let globalUp 	= sim.globalDagDirUp ? "UP  " : "DOWN"
				let delta 		= (simTimeLastLog==nil) ? "": fmt("+%.3f", deltaTime)
				let dashes		= deltaTime <= sim.simTimeStep ? "" : "- - - - - - - - - - - - - - - - - \(delta)"
				print(fmt("\t" + "T=%.3f \(globalUp): - - - \(dashes)", sim.timeNow))
			}
			simTimeLastLog	= sim.timeNow
		}
		 // Strip leading \n's:
		let (newLines, format)	= format_.stripLeadingNewLines()

		 // Formatted arguments:
		var rv 					= ppLogFromString()
		rv						+= String(format:format, arguments:args)

		 // Banner Line
		if let ban 				= banner {
			print("\n" + "***** " + ban + " *****")
		}
		print(newLines + fmt("%d.%03d%@", logNo, entryNo, rv), terminator:terminator ?? "\n" )

		 // Breakpoint Stop?
		let ba					= breakAt % Log.entryNosPlog
		if entryNo == ba && logNo == breakAt / Log.entryNosPlog {
			let baStr			= fmt("%03d", ba)
			panic("Break at \(breakAt/Log.entryNosPlog).\(baStr) encountered.  (idIndex.entryNo)")
		}
		entryNo					+= 1		// go on to next log number
	}
     // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux: FwConfig) -> String {
		return ppDefault(self:self, mode:mode, aux:aux)
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
		return String(nChar)
	}
	var threadNameCache : [String] = []
	 /// get a token identifying Filter and current Lock owner
	func ppLogFromString() -> String {				// " Acon4 "
		var rv					= " "
		rv						+= ppCurThread 	// Thread identifier: e.g: "A"
		rv 						+= msgFilter ?? "flt"	 			//e.g: "con"
		let mp : Int?			= msgPriority	// avoids concurrency problem!!!
		rv						+= mp != nil ? "\(mp!)" : "-"		//e.g: "4"
		rv						= rv.field(-9, dots:false, grow:true)
		rv						+= " "
		return rv
	}
	static var ppLogFromBlank : String {
		let nLog				= 3		// a quick approximation
		return  String(repeating: " ", count:DOClog.ppLogFromString().count + nLog)
	}

	 /// Character to represent Transaction ID:
	var ppCurLock : String {
//		if let curLockStr		= DOC?.state.rootPart.rootVewOwner {
//bug	if let curLockStr		= DOC?.fwGuts?.rootVewOwner {
////		if let curLockStr		= DOC?.fwGuts?.rootVewOwner {
//			return Log.shortNames[curLockStr] ?? "<<\(curLockStr)>>"
//		}
		return ".,."
	}
	static let shortNames		= [
		 // Name in code			/// Name returned / printed
		"buildSceneMenus"				: "men",
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
	var params4aux : FwConfig	{	config4log									}
	static let null : Log		= {
		let params				= params4appLog
		let rv					= Log(params, title:".null = Log(params4app)")
		return rv
	}()

	override var description	  : String { return  "Log\(logNo) \"\(title)\""	}
	override var debugDescription : String { return "'Log\(logNo) \"\(title)\"'"}
	var summary					  : String { return "<Log\(logNo) \"\(title)\">"}
}
var debugOutterLock				= false		// default value

// MARK: - PreLog
func preLog(_ item:String) {
	if DOClog.config4log.bool_("debugPreLog") {
		print("######### " + item)
	}
}


var warningLog : [String] 		= []
var logNErrors					= 0

func warning(target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let msg						= fmt(format, args)
	warningLog.append(msg)
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	DOClog.log(banner:targName + "WARNING \(warningLog.count) ", msg + "\n")
}
func error(  target:Part?=nil, _ format:String, _ args:CVarArg...) {
	let targName 				= target != nil ? target!.fullName.field(12) + ": " : ""
	logNErrors					+= 1
	DOClog.log(banner:targName + "ERROR \(logNErrors) ", 		format, args)
}

func ppBuildErrorsNWarnings(title:String) -> String {
	if logNErrors == 0 && warningLog.count == 0 {
		return "\"\(title)\": No compilation errors or warnings"
	}
	let errors 					= logNErrors	   == 1 ? "error"   : "errors"
	let warnings 				= warningLog.count == 1 ? "warning" : "warnings"
	var rv 						= """
		######
		######
		##################### WARNINGS ##########################################
		###### \"\(title)\":  Compillation has \(logNErrors) \(errors), \(warningLog.count) \(warnings):\n
		"""
	for (i, msg) in warningLog.enumerated() {
		rv						+= "\(i+1)) WARNING: " + msg.wrap(min:5,cur:5,max:80) + "\n"
	}
	rv							+= """
		#########################################################################\n
		######
		######
		"""
	return rv
}


