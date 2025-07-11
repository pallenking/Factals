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

class PartBase : Codable, ObservableObject, Uid {
	 // MARK: - 2.1 Object Variables
	var nameTag			 		= getNametag()
	var tree 	   : Part
	var hnwMachine : HnwMachine = HnwMachine()
	 // Construction for <Class>, "wire", "WBox", "origin", "breakAtWire", etc:
	var indexFor				= Dictionary<String,Int>()
	 // MARK: - 2.3 Part Tree Lock
	var semiphore 				= DispatchSemaphore(value:1)	// be ware of structured concurency.
	var curOwner   : String?	= nil							//	https://medium.com/@roykronenfeld/semaphores-in-swift-e296ea80f860
	var prevOnwer  : String?	= nil
	var verboseLocks			= true//false//

	weak
	 var factalsModel: FactalsModel? = nil			// OWNER

	 // MARK: - 3. Part Factory
	init(tree t:Part=Part()) {
		tree					= t
		hnwMachine				= HnwMachine()
		hnwMachine.sourceOfTest	= "PartBase(tree:\(t.pp(.line))) "
	}
	init(fromLibrary selector:String?) {			// PartBase(fromLibrary...
		 // Get HaveNWant Machine (a Network)
		if let hnwm:HnwMachine  = Library.hnwMachine(fromSelector:selector) {
			logBld(6, "Create Parts:")
			if let newTree		= hnwm.trunkClosure?()	//  <<=======
			{
				hnwMachine		= hnwm
				hnwMachine.sourceOfTest	= "\(hnwMachine.testNum) \(hnwMachine.fileName ?? "<unnamed>"):" +
									  "\(hnwMachine.lineNumber ?? -99)"
				tree			= newTree
			}
			else {
				hnwMachine		= HnwMachine()		// default, runt
				hnwMachine.sourceOfTest	= "Test '\(selector ?? "<nil>")' not in library"
				tree			= Part()
			}
			checkTree()
		}
		else {		fatalError("library selector '\(selector ?? "<nil>)' not found")'}") }
	}
	func checkTree() {
		let changed 			= tree.checkTreeThat(parent:nil, partBase:self)
		logBld(4, "***** checkTree() returned \(changed)")
	}
	func wireAndGroom(_ c:FwConfig) {
		checkTree()
		logBld(4, "Raw Network:" + "\n" + pp(.tree, ["ppParam":true, "ppDagOrder":false]))

		 //  1. GATHER LINKS as wirelist:
		logBld(4, "------- GATHERING potential Links:")
		var linkUps : [()->()]	= []
		tree.gatherLinkUps(into:&linkUps, partBase:self)

		 //  2. ADD LINKS:
		logBld(4, "------- WIRING \(linkUps.count) Links to Network:")
		linkUps.forEach
		{ 	addLink in 		addLink() 											}

		 //  3. Grooom post wires:
		checkTree()
		logBld(4, "------- Grooming Parts...")
		tree.groomModelPostWires(partBase:self)				// + +  + +
		tree.dirtySubTree()		//dirty.turnOn(.vew) 	// Mark parts dirty after installing new trunk
								//markTree(argBit:.vew) // Mark parts dirty after installing new trunk
								//dirty.turnOn(.vew)
		 //  4. Reset
		logBld(4, "------- Reset...")
		tree.reset()

		 // must be done after reset
		tree.forAllParts { part in
			if let p = part as? Splitter {
				p.setDistributions(total:0.0)
			}
		}

		 //  5. Print Errors
 		logBld(3, ppRootPartErrors())

		 //  6. Print Part
		let sim					= factalsModel?.simulator
		logBld(2, "------- Parts, ready for simulation, simRun:\(sim?.simRun ?? false)):\n" + (pp(.tree, ["ppDagOrder":false])))
		sim?.simBuilt 			= true		// maybe before config4log, so loading simEnable works

		 //  7. TITLE of window: 			//e.g: "'<title>' 33:142 (3 Ports)"
		hnwMachine.postTitle	= " (\(portCount()) Ports)"

		//dirtySubTree(.vew)		// NOT NEEDED
		//dirtySubTree(.vew)		// IS THIS SUFFICIENT, so early?
		//self.dirty.turnOn(.vew)
		//markTree(argBit:.vew)

	}

	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}

	 // Configuration for Part Tree's
	func configure(from:FwConfig) {
		tree.partConfig			= from + tree.partConfig	// dont call twice
//		tree.partConfig			= from		// save in base of tree's config
	}

	//// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum PartsKeys: String, CodingKey {
//		case tree
//		case simulator
////		case log
//		case title
//		case partTreeVerbose		// Bool
		case nameTag
		case tree
		case hnwMachine
		case indexFor

		case semiphore
		case curOwner
		case prevOnwer
		case verboseLocks
	}



	 // Serialize 					// po container.contains(.name)
	/*override*/
	func encode(to encoder: Encoder) throws  {
		 // Massage Part Tree, to make it
		makeSelfCodable(neededLock:"writePartTree")		//readyForEncodable

		//try super.encode (to: encoder), (to: container.superEncoder())
		var container 			= encoder.container(keyedBy:PartsKeys.self)
		try container.encode(nameTag,	   forKey:.nameTag						)
		try container.encode(tree,		   forKey:.tree							)
//		try container.encode(hnwMachine,   forKey:.hnwMachine					)
		try container.encode(indexFor,	   forKey:.indexFor						)
//		try container.encode(semiphore,	   forKey:.semiphore					)
		try container.encode(curOwner,	   forKey:.curOwner						)
		try container.encode(prevOnwer,	   forKey:.prevOnwer					)
		try container.encode(verboseLocks, forKey:.verboseLocks					)
		logSer(3, "Encoded")

		 // Massage Part Tree, to make it
		makeSelfRunable("writePartTree")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {	//fatalError("sdfwovnaw;ofhw")}
		 // Needn't lock or makeSelfCodable, it's virginal
		let container 			= try decoder.container(keyedBy:PartsKeys.self)
		nameTag	 				= try container.decode( 	NameTag.self, forKey:.nameTag						)
		tree		 			= try container.decode(		   Part.self, forKey:.tree							)
//		hnwMachine  			= try container.decode(  HnwMachine.self, forKey:.hnwMachine					)
		indexFor	 			= try container.decode([String:Int].self, forKey:.indexFor						)
//		semiphore	 			= try container.decode(DispatchSemaphore.self, forKey:.semiphore					)
		curOwner	 			= try container.decode(     String?.self, forKey:.curOwner						)
		prevOnwer	 			= try container.decode(		String?.self, forKey:.prevOnwer					)
		verboseLocks			= try container.decode( 	   Bool.self, forKey:.verboseLocks					)
		logSer(3, "Decoded  as? Parts \(ppUid(self))")

//		makeSelfRunable("help")		// (no unlock)
	}
	 // MARK: - 3.5.1 Data
	func data() throws -> Data {	// )Used by FactalsDocument)
		do {
			let enc 			= JSONEncoder()
			enc.outputFormatting = .prettyPrinted
			let dataRv 			= try enc.encode(self)							//Thread 4: EXC_BAD_ACCESS (code=2, address=0x16d91bfd8)
			return dataRv
		}
		catch { 	throw FwError(kind:"error")									}
	}
	static func from(data:Data, encoding:String.Encoding) throws -> PartBase {
//		do {
			return try JSONDecoder().decode(PartBase.self, from:data)
//		} catch {
//			debugger("Parts.from(data:encoding:) ERROR:'\(error)'")
//		}
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
bug
		guard lock(for:neededLock, logIf:true) else { debugger("'\(neededLock)' couldn't get PART lock") }

		virtualizeLinks() 		// ---- 1. Retract weak crossReference .connectedTo in Ports, replace with absolute string
								 // (modifies self)
		let aux : FwConfig		= ["ppDagOrder":false, "ppIndentCols":20, "ppLinks":true]
		logSer(5, " ========== parts to Serialize:\n\(pp(.tree, aux))", terminator:"")
						
		polyWrapChildren()		// ---- 2. INSERT -  PolyWrap's to handls Polymorphic nature of Parts
		logSer(5, " ========== inPolyPart with Poly's Wrapped :\n\(pp(.tree, aux))", terminator:"")
	}
	func makeSelfRunable(_ releaseLock:String) {		// was recoverFromDecodable
bug
		polyUnwrapRp()								// ---- 1. REMOVE -  PolyWrap's
		realizeLinks()								// ---- 2. Replace weak references
		//groomModel(parent:nil)		// nil as Part?
		logSer(5, " ========== parts unwrapped:\n\(pp(.tree, ["ppDagOrder":false]))", terminator:"")
		
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
//		logSer(1, "\n" + "read(from:Data, ofType:      ''\(typeName.description)''       )")
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
//		logSer(3, "read(from:ofType:)  -- SUCCEEDED")
//	}
//
//// END CODABLE /////////////////////////////////////////////////////////////////

//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : Parts	= super.copy(with:zone) as! Parts
//								
//		theCopy.simulator		= self.simulator
//		theCopy.title			= self.title
//	//x	theCopy.partTreeLock 	= self.partTreeLock
//	//x	theCopy.partTreeOwner	= self.partTreeOwner
//	//x	theCopy.prevOnwer = self.prevOnwer
//		theCopy.partTreeVerbose	= self.partTreeVerbose
//		logSer(3, "copy(with as? Parts       '\(fullName)'")
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	override func equalsFW(_ rhs:Part) -> Bool {
//		guard self !== rhs 						   else {	return true			}
//		guard let rhs			= rhs as? Parts else {	return false 		}
//		let rv					= super.equalsFW(rhs)
//								&& simulator		 == rhs.simulator
//								&& title			 == rhs.title
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
		if logIf && Log.shared.debugOutterLock { 		 		// less verbose
				let msg			= " //######\(ownerNId)      GET Part LOCK: v:\(semiphore.value ?? -99)"
				if semiphore.value ?? -99 <= 0 {	// Blocked, always print if verb
					logBld(4, msg +  ", OWNED BY:'\(curOwner ?? "-")', PROBABLE WAIT...")
				}
				else if verboseLocks {
			 		logBld(4, msg)
				}
		}
		 /// === Get partTree lock:
/**/	while semiphore.wait(timeout:.now() + .seconds(10)) != .success {
			logRve(4, " //######\(ownerNId)   FAILED Part LOCK v:\(semiphore.value ?? -99)")
			panic("\(ownerNId): Lock Timeout FAILURE.  PartBase BLOCKED by currenly owned:\(curOwner ?? "nil")")
			return false
		}
		 // === SUCCEEDED in getting lock:
		assert(curOwner==nil, "'\(owner)' attempting to lock, but '\(curOwner!)' still holds lock ")
		curOwner				= owner
		if logIf && (verboseLocks || curOwner != "renderScene") {
			logRve(4, " //######\(ownerNId)      GOT Part LOCK: v:\(semiphore.value ?? -99)")
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
			logRve(3, " \\\\######\(ownerNId)  RELEASE Part LOCK: v:\(semiphore.value ?? -99)")
		}

		 // update name/state BEFORE signals
		prevOnwer			= curOwner
		curOwner 			= nil

/**/	semiphore.signal()			 // Unlock Part's DispatchSemaphore:

		if Log.shared.debugOutterLock && logIf && (verboseLocks || prevOnwer != "renderScene") {
			logBld(3, " \\\\######\(ownerNId) RELEASED Part LOCK v:\(semiphore.value ?? -99)")
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

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		//var rv 				= super.pp(mode, aux)	// Use Part's pp()
		var rv					= tree.pp(mode, aux)
		if mode == .line {
			rv					+= " \"\(hnwMachine.title)\""
		}
		return rv
	}
	func ppRootPartErrors() -> String {
		var rv 					= ":\n\nBUILT PART  \(hnwMachine.titlePlus())\n"
		let errors 				= logNErrors	   == 0 ? "no errors"
								: logNErrors	   == 1 ? "1 error"
										  : "\(logNErrors) errors"
//		let warnings 			= Log.shared.warningLog.count == 0 ? "no warnings"
//								: Log.shared.warningLog.count == 1 ? "1 warning"
//								: "\(Log.shared.warningLog.count) warnings"
		rv						+= "\t######## \(errors) ########\n"		//\(warnings) 
		for (i, msg) in Log.shared.warningLog.enumerated() {
			rv						+= "###### WARNING \(i+1)): " + msg.wrap(min:5,cur:5,max:80) + "\n"
		}
		return rv
	}
}
