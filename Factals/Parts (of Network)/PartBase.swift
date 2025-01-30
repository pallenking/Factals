//  Parts.swift -- Base element of Part tree ©202012PAK

import SceneKit

/*	https://www.toptal.com/developers/gitignore/api/xcode
 *    SceneKit’s data model is thread-safe in that it ensures that internal data
 * structures will not be corrupted by concurrent attempts to modify their
 * contents from multiple threads
 */
/*	https://developer.apple.com/documentation/scenekit/scntransaction/1523078-lock
 *    If your app modifies the scene graph from multiple threads, use a transaction
 * lock to ensure that your modifications take effect as intended.
 */
extension PartBase : Equatable {
	static func == (lhs: PartBase, rhs: PartBase) -> Bool {
		lhs.nameTag				== rhs.nameTag &&
		lhs.tree				== rhs.tree &&
		lhs.factalsModel		=== rhs.factalsModel
	}
}

class PartBase : Codable, ObservableObject, Uid, Logd {
	
	let nameTag			 		= getNametag()
	var tree : Part

	 // hold index of named items (<Class>, "wire", "WBox", "origin", "breakAtWire", etc)
	var indexFor				= Dictionary<String,Int>()

	 // MARK: - 2.1 Object Variables
	var testFrom				= ""			// source(arg)
	var title					= ""			// Test Name or Status
	var postTitle				= ""

	var ansConfig : FwConfig 	= [:]

	weak
	 var factalsModel : FactalsModel? = nil			// OWNER

	 // MARK: - 2.3 Part Tree Lock
	var semiphore 				= DispatchSemaphore(value:1)	// be ware of structured concurency.
	var curOwner  : String?		= nil							//	https://medium.com/@roykronenfeld/semaphores-in-swift-e296ea80f860
	var prevOnwer : String?		= nil
	var verboseLocks			= true//false//

	 // MARK: - 3. Part Factory
	init(tree t:Part=Part()) {
		tree					= t
	}
	init(fromLibrary selector:String?) {			// Part(fromLibrary...
		self.testFrom			= "'\(selector ?? "nil")' -> "
		self.title 				= " Not in Library"

		 // Get HaveNWant Machine (a Network)
		if let hnwMachine		= Library.hnwMachine(fromSelector:selector) {
			self.title			= hnwMachine.title!
			self.testFrom		= "\(hnwMachine.testNum) "
								+ "\(hnwMachine.fileName ?? "??"):\(hnwMachine.lineNumber!)"
			self.ansConfig		= hnwMachine.config
/* */		self.tree			= hnwMachine.trunkClosure?() ?? Part()	// EXPAND Closure from Lib
		} else {
			tree				= Part()
		}
		checkTree()
	}
	func checkTree() {
		let changed 			= tree.checkTreeThat(parent:nil, partBase:self)
		atBld(4, logd("***** checkTree returned \(changed)"))
	}
	func wireAndGroom(_ c:FwConfig) {
		checkTree()
		atBld(4, logd("Raw Network:" + "\n" + pp(.tree, ["ppDagOrder":true])))

		 //  1. GATHER LINKS as wirelist:
		atBld(4, logd("------- GATHERING potential Links:"))
		var linkUps : [()->()]	= []
		tree.gatherLinkUps(into:&linkUps, partBase:self)

		 //  2. ADD LINKS:
		atBld(4, logd("------- WIRING \(linkUps.count) Links to Network:"))
		linkUps.forEach { 	addLink in 		addLink() 							}

		checkTree()

		 //  3. Grooom post wires:
		atBld(4, logd("------- Grooming Parts..."))
		tree.groomModelPostWires(partBase:self)				// + +  + +
		tree.dirtySubTree()															//dirty.turnOn(.vew) 	// Mark parts dirty after installing new trunk
																				//markTree(dirty:.vew) 	// Mark parts dirty after installing new trunk
																				//dirty.turnOn(.vew)
		 //  4. Reset
		atBld(4, logd("------- Reset..."))
		tree.reset()

		 // must be done after reset
		tree.forAllParts { part in
			if let p = part as? Splitter {
				p.setDistributions(total:0.0)
			}
		}

		 //  5. Print Errors
 		atBld(3, logd(ppRootPartErrors()))

		 //  6. Print Part
		atBld(2, logd("------- Parts, ready for simulation, simRun:\(factalsModel?.simulator.simRun ?? false)):\n" + (pp(.tree, ["ppDagOrder":true]))))

		factalsModel?.simulator.simBuilt		= true	// maybe before config4log, so loading simEnable works

		 //  7. TITLE of window: 			//e.g: "'<title>' 33:142 (3 Ports)"
//		select				= "aaa"
//		postTitle				= " (\(portCount()) Ports)"

		//dirtySubTree(.vew)		// NOT NEEDED
		//dirtySubTree(.vew)		// IS THIS SUFFICIENT, so early?
		//self.dirty.turnOn(.vew)
		//markTree(dirty:.vew)

	}

	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}

	 // Configuration for Part Tree's
	func configure(from:FwConfig) {
		tree.partConfig			= from		// save in base of tree's config
	}

	//// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum PartsKeys: String, CodingKey {
		case tree
		case simulator
//		case log
		case title
		case ansConfig
		case partTreeVerbose		// Bool
	}

	 // Serialize 					// po container.contains(.name)
	/*override*/ func encode(to encoder: Encoder) throws  {
		 // Massage Part Tree, to make it
//		makeSelfCodable(neededLock:"writePartTree")		//readyForEncodable

		//try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:PartsKeys.self)

		try container.encode(title,				forKey:.title					)
	//?	try container.encode(ansConfig,			forKey:.ansConfig				)		// TODO requires work!
		try container.encode(verboseLocks,	forKey:.partTreeVerbose			)

		atSer(3, logd("Encoded"))

		 // Massage Part Tree, to make it
		makeSelfRunable("writePartTree")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		 // Needn't lock or makeSelfCodable, it's virginal
		let container 			= try decoder.container(keyedBy:PartsKeys.self)

		title					= try container.decode(   String.self, forKey:.title		)
//		ansConfig				= [:]							//try container.decode(FwConfig.self, forKey:.ansConfig	)
		semiphore 				= DispatchSemaphore(value:1)	//try container.decode(DispatchSemaphore.self,forKey:.partTreeLock	)
		verboseLocks			= try container.decode(	    Bool.self, forKey:.partTreeVerbose)
		tree					= try container.decode(	    Part.self, forKey:.partTreeVerbose)

		atSer(3, logd("Decoded  as? Parts \(ppUid(self))"))

//		makeSelfRunable("help")		// (no unlock)
	}
	 // MARK: - 3.5.1 Data
	var data : Data? {
		do {
			let enc 			= JSONEncoder()
			enc.outputFormatting = .prettyPrinted
			let dataRv 			= try enc.encode(self)							//Thread 4: EXC_BAD_ACCESS (code=2, address=0x16d91bfd8)
			//print(String(data: data, encoding: .utf8)!)
			return dataRv
		} catch {
			print("\(error)")
			return nil
		}
	}
	static func from(data:Data, encoding:String.Encoding) -> PartBase {
		do {
			return try JSONDecoder().decode(PartBase.self, from:data)
		} catch {
			debugger("Parts.from(data:encoding:) ERROR:'\(error)'")
		}
	}
//	convenience init?(data:Data, encoding:String.Encoding) {
//		bug							// PW: need Parts(data, encoding)
//	//	let parts 				= try! JSONDecoder().decode(Parts.self, from:data)
//	//	self.init(data:data, encoding:encoding)		// INFINITE
//		do {		// 1. Write data to file. (Make this a loopback)
//			let fileUrlDir		= FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//			let fileURL			= fileUrlDir.appendingPathComponent("logOfRuns")
//			try data.write(to:fileURL)
//bug			//self.init(url: fileURL)
//			//self.init()				//try self.init(url: fileURL)
//		} catch {
//			print("error using file: \(error)")									}
//		return nil
//	}

	 // MARK: - 3.5.2 Codable <--> Simulatable
	// // // // // // // // // // // // // // // // // // // // // // // // // //
	func makeSelfCodable(neededLock:String) {		// was readyForEncodable
bug;	guard lock(for:neededLock, logIf:true) else { debugger("'\(neededLock)' couldn't get PART lock") }

		virtualizeLinks() 		// ---- 1. Retract weak crossReference .connectedTo in Ports, replace with absolute string
								 // (modifies self)
		let aux : FwConfig		= ["ppDagOrder":false, "ppIndentCols":20, "ppLinks":true]
		atSer(5, logd(" ========== parts to Serialize:\n\(pp(.tree, aux))", terminator:""))
						
		polyWrapChildren()		// ---- 2. INSERT -  PolyWrap's to handls Polymorphic nature of Parts
		atSer(5, logd(" ========== inPolyPart with Poly's Wrapped :\n\(pp(.tree, aux))", terminator:""))
	}
	func makeSelfRunable(_ releaseLock:String) {		// was recoverFromDecodable
		polyUnwrapRp()								// ---- 1. REMOVE -  PolyWrap's
		realizeLinks()								// ---- 2. Replace weak references
		//groomModel(parent:nil)		// nil as Part?
		atSer(5, logd(" ========== parts unwrapped:\n\(pp(.tree, ["ppDagOrder":false]))", terminator:""))
		
		unlock(for:releaseLock, logIf:true)
	}
	func polyWrapChildren() {
bug
//		tree.polyWrapChildren()
//		 // PolyWrap all Part's children
//		for i in 0..<children.count {
//			 // might only wrap polymorphic types?, but simpler to wrap all
//			children[i]			= children[i].polyWrap()	// RECURSIVE // (C)
//			children[i].parent	= self									// (D) backlink
//		}
	}
	func polyUnwrapRp() {
//		 // Unwrap all children, RECURSIVELY
//		for (i, child) in children.enumerated() {
//			guard let childPoly = child as? PolyWrap else { fatalError()	}
//			 // Replace Wrapped with Unwrapped:
//			children[i]			= childPoly.polyUnwrap()
//			children[i].parent	= self
//		}
	}

	// // // // // // // // // // // // // // // // // // // // // // // // // //
	 // MARK Virtualize Links
	 /// Remove all weak references of Port.connectedTo. Store their absolute path as a string
	func virtualizeLinks() {
		tree.forAllParts( {
			if let pPort		= $0 as? Port {
				pPort.con2 = .string(pPort.con2?.port?.fullName ?? "8383474f")
			}
		} )
	}
	/// Add weak references to Port.connectedTo from their absolute path as a string
	func realizeLinks() {
		tree.forAllParts( {
			if let pPort			= $0 as? Port,
			  let pPort2String		= pPort.con2?.string,
			  let pPort2Port		= pPort.find(name:pPort2String, inMe2:true) as? Port {
				pPort.con2	= .port(pPort2Port)
			}
		} )
	}

//	override func read(from savedData:Data, ofType typeName: String) throws {
//		logd("\n" + "read(from:Data, ofType:      ''\(typeName.description)''       )")
//		guard let unarchiver : NSKeyedUnarchiver = try? NSKeyedUnarchiver(forReadingFrom:savedData) else {
//				debugger("NSKeyedUnarchiver cannot read data (its nil or throws)")
//		}
//		let inPolyPart			= try? unarchiver.decodeTopLevelDecodable(PolyWrap.self, forKey:NSKeyedArchiveRootObjectKey)
//								?? {	debugger("decodeTopLevelDecodable(:forKey:) throws")} ()
//		unarchiver.finishDecoding()
//		guard let inPolyPart 	= inPolyPart else {	throw MyError.funcky 	}
//
//		  // Groom parts and whole tree
//		 // 1. Unwrap PolyParts
//		parts				= inPolyPart.polyUnwrap() as? Parts
//		 // 2. Groom .partBase and .parent in all parts:
//		parts.groomModel??(parent:nil, //root:parts)
//		 // 3. Groom .fwDocument in parts
//		parts.fwDocument 	= self		// Use my FwDocument
//		 // 4. Remove symbolic links on Ports
//		parts.realizeLinks()
//
//		logd("read(from:ofType:)  -- SUCCEEDED")
//	}
//
//// END CODABLE /////////////////////////////////////////////////////////////////

//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : Parts	= super.copy(with:zone) as! Parts
//								
//		theCopy.simulator		= self.simulator
//		theCopy.title			= self.title
//		theCopy.ansConfig		= self.ansConfig
//	//x	theCopy.partTreeLock 	= self.partTreeLock
//	//x	theCopy.partTreeOwner	= self.partTreeOwner
//	//x	theCopy.prevOnwer = self.prevOnwer
//		theCopy.partTreeVerbose	= self.partTreeVerbose
//		atSer(3, logd("copy(with as? Parts       '\(fullName)'"))
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	override func equalsFW(_ rhs:Part) -> Bool {
//		guard self !== rhs 						   else {	return true			}
//		guard let rhs			= rhs as? Parts else {	return false 		}
//		let rv					= super.equalsFW(rhs)
//								&& simulator		 == rhs.simulator
//								&& title			 == rhs.title
////								&& ansConfig		 == rhs.ansConfig				//Protocol 'FwAny' as a type cannot conform to 'Equatable'
//		//x						&& partTreeLock 	 == rhs.partTreeLock
//		//x						&& partTreeOwner	 == rhs.partTreeOwner
//		//x						&& prevOnwer == rhs.prevOnwer
//								&& partTreeVerbose   == rhs.partTreeVerbose
//		return rv
//	}
	  // MARK: - 5. Lock
	 // ///////////////// LOCK Parts Tree /////////////
	// https://stackoverflow.com/questions/31700071/scenekit-threads-what-to-do-on-which-thread

	/// Lock the Part Tree:
	/// - Parameters:
	///   - newOwner: of the lock. nil->don't get lock
	///   - wait: logs if wait
	///   - logIf: allows logging
	/// - Returns: lock obtained
 	func lock(for owner:String, logIf:Bool) -> Bool {
		let ownerNId			= ppUid(self) + " '\(owner)'".field(-20)
								
		if logIf && debugOutterLock { 		 		// less verbose
			atBld(4, {					// === ///// BEFORE GETTING, Log:
				let msg			= " //######\(ownerNId)      GET Part LOCK: v:\(semiphore.value ?? -99)"
				if semiphore.value ?? -99 <= 0 {	// Blocked, always print if verb
					logd(msg +  ", OWNED BY:'\(curOwner ?? "-")', PROBABLE WAIT...")
				}
				else if verboseLocks {
			 		logd(msg)
				}
			}())
		}
		 /// === Get partTree lock:
/**/	while semiphore.wait(timeout:.now() + .seconds(10)) != .success {
			logd(" //######\(ownerNId)   FAILED Part LOCK v:\(semiphore.value ?? -99)")
			panic("\(ownerNId): Lock Timeout FAILURE.  PartBase BLOCKED by currenly owned:\(curOwner ?? "nil")")
			return false
		}

		 // === SUCCEEDED in getting lock:
		assert(curOwner==nil, "'\(owner)' attempting to lock, but '\(curOwner!)' still holds lock ")
		curOwner				= owner
		if logIf && (verboseLocks || curOwner != "renderScene") {
			atBld(4, logd(" //######\(ownerNId)      GOT Part LOCK: v:\(semiphore.value ?? -99)"))
		}
 		return true
 	}
	
	/// Unlock the Part tree
	/// - Parameters:
	///   - lockName:  of the lock. nil->don't get lock
	///   - logIf: allows logging
 	func unlock(for owner:String, logIf:Bool) {
		assert(curOwner != nil, "Attempting to unlock ownerless lock")
		assert(curOwner == owner, "Releasing (as '\(owner)') Part lock owned by '\(curOwner!)'")
		let ownerNId		= ppUid(self) + " '\(curOwner!)'".field(-20)
		if logIf && (curOwner != "renderScene" || verboseLocks) {
			atBld(3, logd(" \\\\######\(ownerNId)  RELEASE Part LOCK: v:\(semiphore.value ?? -99)"))
		}

		 // update name/state BEFORE signals
		prevOnwer			= curOwner
		curOwner 			= nil

/**/	semiphore.signal()			 // Unlock Part's DispatchSemaphore:

		if debugOutterLock && logIf && (verboseLocks || prevOnwer != "renderScene") {
			atBld(3, logd(" \\\\######\(ownerNId) RELEASED Part LOCK v:\(semiphore.value ?? -99)"))
		}
	}

	 // MARK: - 8. Reenactment Simulator
	  /// Count of all Ports in root
	 /// - Returns: Number of Ports
	func portCount() -> Int {
		var rv  				= 0
		let _ 					= tree.findCommon(firstWith:
		{(part:Part) -> Part? in		// Count Ports:
			if part is Port {
				rv				+= 1	// Count Ports in tree
			}
			return nil		// nil -> not found -> look at all in self
		})
		return rv
	}

	 // MARK: - 9.3 reSkin
	 func reSkin(_ expose:Expose?=nil, vew:Vew) -> BBox 	{
bug		// invisible?
		return .empty						// Root Part is invisible
	}

	// MARK: - 14. Building
	 // Part.log comes here to stop  -- else infinite loop
	var log : Log {
		let fm : FactalsModel?	= factalsModel ?? FACTALSMODEL
		let log					= fm?.factalsDocument.log ?? Log.app //FactalsApp.main().log ?? { debugger("factalsModel nil in PartBase")}().log("=
		return log
	}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String="\n") {
		log.log(banner:banner, format_, args, terminator:terminator)
	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		//var rv 				= super.pp(mode, aux)	// Use Part's pp()
		var rv					= tree.pp(mode, aux)
		if mode == .line {
			rv					+= " \"\(title)\""
		}
		return rv
	}
	func ppRootPartErrors() -> String {
		let errors 				= logNErrors	   == 0 ? "no errors"
								: logNErrors	   == 1 ? "1 error"
										  : "\(logNErrors) errors"
		let warnings 			= warningLog.count == 0 ? "no warnings"
								: warningLog.count == 1 ? "1 warning"
								: "\(warningLog.count) warnings"
		let titleWidth			= title.count
		let width				= titleWidth + "######                ######".count
		let errWarnWidth		= errors.count + warnings.count + 2
		let count				= width - "#################### ".count - errWarnWidth - 2
		let trailing1			= count <= 0 ? "" : String(repeating:"#", count:count)
		let trailing2			= String(repeating:"#", count:width)
		let blanks				= String(repeating:" ", count:title.count)
		var rv 					= "BUILT PART!\n"
		rv 						+= """
			######        \(blanks   )        ######
			######        \(blanks   )        ######
			##################### \(errors), \(warnings) \(trailing1)
			######        \(blanks   )        ######
			######     \"\" \(title) \"\"     ######
			######        \(blanks   )        ######
			\(trailing2)\n
			"""
		for (i, msg) in warningLog.enumerated() {
			rv						+= "###### WARNING \(i+1)): " + msg.wrap(min:5,cur:5,max:80) + "\n"
		}
		rv							+= tree.ppUnusedKeys()
		rv							+= """
			######        \(blanks   )        ######
			######        \(blanks   )        ######\n
			"""
		return "\n" + rv
	}
}
