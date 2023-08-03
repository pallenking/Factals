//  RootPart.swift -- Base element of Part tree ©202012PAK

import SceneKit

/*	https://www.toptal.com/developers/gitignore/api/xcode
   SceneKit’s data model is thread-safe in that it ensures that internal data
structures will not be corrupted by concurrent attempts to modify their
contents from multiple threads
https://developer.apple.com/documentation/scenekit/scntransaction/1523078-lock
   If your app modifies the scene graph from multiple threads, use a transaction
lock to ensure that your modifications take effect as intended.
 */
class RootPart : Part {

	 // MARK: - 2.1 Object Variables
	var	simulator		: Simulator
	var title							= ""
	var ansConfig		: FwConfig		= [:]
	var fwGuts			: FwGuts!

	 // MARK: - 2.3 Part Tree Lock
	var partTreeLock 			= DispatchSemaphore(value:1)					//https://medium.com/@roykronenfeld/semaphores-in-swift-e296ea80f860
	var partTreeOwner : String?	= nil  		// root lock Owner's name
	var partTreeOwnerPrev:String? = nil
	var partTreeVerbose			= true

	// MARK: - 3. Part Factory
	init() {
		simulator				= Simulator()
		super.init(["name":"ROOT"]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		simulator.rootPart		= self
	}
	func configure(from config:FwConfig) {
		assert(simulator.rootPart === self, "RootPart.reconfigureWith ERROR with simulator owner rootPart")
		simulator.configure(from:config) 	// CUSTOMER 1
	}

	//// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum RootPartKeys: String, CodingKey {
		case simulator
//		case log
		case title
		case ansConfig
		case partTreeVerbose		// Bool
	}

	 // Serialize 					// po container.contains(.name)
	override func encode(to encoder: Encoder) throws  {
		 // Massage Part Tree, to make it
		makeSelfCodable("writePartTree")		//readyForEncodable

		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:RootPartKeys.self)

		try container.encode(simulator,			forKey:.simulator				)
		try container.encode(title,				forKey:.title					)
	//?	try container.encode(ansConfig,			forKey:.ansConfig				)		// TODO requires work!
		try container.encode(partTreeVerbose,	forKey:.partTreeVerbose			)

		atSer(3, logd("Encoded"))

		 // Massage Part Tree, to make it
		makeSelfRunable("writePartTree")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		 // Needn't lock or makeSelfCodable, it's virginal
		let container 			= try decoder.container(keyedBy:RootPartKeys.self)

		simulator				= try container.decode(Simulator.self, forKey:.simulator	)
		title					= try container.decode(   String.self, forKey:.title		)
		ansConfig				= [:]							//try container.decode(FwConfig.self, forKey:.ansConfig	)
		partTreeLock 			= DispatchSemaphore(value:1)	//try container.decode(DispatchSemaphore.self,forKey:.partTreeLock	)
		partTreeVerbose			= try container.decode(	    Bool.self, forKey:.partTreeVerbose)

		try super.init(from:decoder)
		atSer(3, logd("Decoded  as? RootPart \(ppUid(self))"))

		makeSelfRunable()		// (no unlock)
	}

	 // MARK: Make Codable
	// // // // // // // // // // // // // // // // // // // // // // // // // //
	func makeSelfCodable(_ msg:String?=nil) {		// was readyForEncodable
		guard msg == nil || lock(partTreeAs:msg!) else { fatalError("'\(msg!)' couldn't get PART lock") }

		virtualizeLinks() 		// ---- 1. Retract weak crossReference .connectedTo in Ports, replace with absolute string
								 // (modifies self)
		let aux : FwConfig		= ["ppDagOrder":false, "ppIndentCols":20, "ppLinks":true]
		atSer(5, logd(" ========== rootPart to Serialize:\n\(pp(.tree, aux))", terminator:""))
						
		polyWrapChildren()		// ---- 2. INSERT -  PolyWrap's to handls Polymorphic nature of Parts
		atSer(5, logd(" ========== inPolyPart with Poly's Wrapped :\n\(pp(.tree, aux))", terminator:""))
	}

	func makeSelfRunable(_ msg:String?=nil) {		// was recoverFromDecodable
		polyUnwrapRp()								// ---- 1. REMOVE -  PolyWrap's
		realizeLinks()								// ---- 2. Replace weak references
		groomModel(parent:nil, root:self)		// nil as Part?
		atSer(5, logd(" ========== rootPart unwrapped:\n\(pp(.tree, ["ppDagOrder":false]))", terminator:""))
		
		msg == nil ? nop : unlock(partTreeAs:msg)	// ---- 3. UNLOCK for PartTree
	}


	func polyWrapChildren() {
		 // PolyWrap all Part's children
		for i in 0..<children.count {
			 // might only wrap polymorphic types?, but simpler to wrap all
			children[i]			= children[i].polyWrap()	// RECURSIVE // (C)
			children[i].parent	= self									// (D) backlink
		}
	}
	func polyUnwrapRp() {
		 // Unwrap all children, RECURSIVELY
		for (i, child) in children.enumerated() {
			guard let childPoly = child as? PolyWrap else { fatalError()	}
			 // Replace Wrapped with Unwrapped:
			children[i]			= childPoly.polyUnwrap()
			children[i].parent	= self
		}
	}

	// // // // // // // // // // // // // // // // // // // // // // // // // //
	 // MARK Virtualize Links
	 /// Remove all weak references of Port.connectedTo. Store their absolute path as a string
	func virtualizeLinks() {
		forAllParts( {
			if let pPort		= $0 as? Port {
				pPort.connectedX = .string(pPort.connectedX?.port?.fullName ?? "8383474f")
			}
		} )
	}
	/// Add weak references to Port.connectedTo from their absolute path as a string
	func realizeLinks() {
		forAllParts( {
			if let pPort			= $0 as? Port,
			  let pPort2String		= pPort.connectedX?.string,
			  let pPort2Port		= pPort.find(name:pPort2String, inMe2:true) as? Port {
				pPort.connectedX	= .port(pPort2Port)
			}
		} )
	}

//	override func read(from savedData:Data, ofType typeName: String) throws {
//		logd("\n" + "read(from:Data, ofType:      ''\(typeName.description)''       )")
//		guard let unarchiver : NSKeyedUnarchiver = try? NSKeyedUnarchiver(forReadingFrom:savedData) else {
//				fatalError("NSKeyedUnarchiver cannot read data (its nil or throws)")
//		}
//		let inPolyPart			= try? unarchiver.decodeTopLevelDecodable(PolyWrap.self, forKey:NSKeyedArchiveRootObjectKey)
//								?? {	fatalError("decodeTopLevelDecodable(:forKey:) throws")} ()
//		unarchiver.finishDecoding()
//		guard let inPolyPart 	= inPolyPart else {	throw MyError.funcky 	}
//
//		  // Groom rootPart and whole tree
//		 // 1. Unwrap PolyParts
//		rootPart				= inPolyPart.polyUnwrap() as? RootPart
//		 // 2. Groom .root and .parent in all parts:
//		rootPart.groomModel(parent:nil, root:rootPart)
//		 // 3. Groom .fwDocument in rootPart
//		rootPart.fwDocument 	= self		// Use my FwDocument
//		 // 4. Remove symbolic links on Ports
//		rootPart.realizeLinks()
//
//		logd("read(from:ofType:)  -- SUCCEEDED")
//	}
//
//// END CODABLE /////////////////////////////////////////////////////////////////

//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy : RootPart	= super.copy(with:zone) as! RootPart
//								
//		theCopy.simulator		= self.simulator
//		theCopy.title			= self.title
//		theCopy.ansConfig		= self.ansConfig
//	//x	theCopy.partTreeLock 	= self.partTreeLock
//	//x	theCopy.partTreeOwner	= self.partTreeOwner
//	//x	theCopy.partTreeOwnerPrev = self.partTreeOwnerPrev
//		theCopy.partTreeVerbose	= self.partTreeVerbose
//		atSer(3, logd("copy(with as? RootPart       '\(fullName)'"))
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	override func equalsFW(_ rhs:Part) -> Bool {
//		guard self !== rhs 						   else {	return true			}
//		guard let rhs			= rhs as? RootPart else {	return false 		}
//		let rv					= super.equalsFW(rhs)
//								&& simulator		 == rhs.simulator
//								&& title			 == rhs.title
////								&& ansConfig		 == rhs.ansConfig				//Protocol 'FwAny' as a type cannot conform to 'Equatable'
//		//x						&& partTreeLock 	 == rhs.partTreeLock
//		//x						&& partTreeOwner	 == rhs.partTreeOwner
//		//x						&& partTreeOwnerPrev == rhs.partTreeOwnerPrev
//								&& partTreeVerbose   == rhs.partTreeVerbose
//		return rv
//	}
	// MARK 4.
	  // FileDocument requires these interfaces:
	 // Data representation of the RootPart

	 // MARK: - 3.8 Data
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
	static func from(data:Data, encoding:String.Encoding) -> RootPart {
		do {
			let rv	: RootPart	= try JSONDecoder().decode(RootPart.self, from:data)
			return rv
		} catch {
			fatalError("RootPart.from(data:encoding:) ERROR:'\(error)'")
		}
	}
	convenience init?(data:Data, encoding:String.Encoding) {

		bug							// PW: need RootPart(data, encoding)
	//	let rootPart 			= try! JSONDecoder().decode(RootPart.self, from:data)
	//	self.init(data:data, encoding:encoding)		// INFINITE
		do {		// 1. Write data to file. (Make this a loopback)
			let fileUrlDir		= FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			let fileURL			= fileUrlDir.appendingPathComponent("logOfRuns")
			try data.write(to:fileURL)
bug			//self.init(url: fileURL)
			self.init()		//try self.init(url: fileURL)
		} catch {
			print("error using file: \(error)")									}
		return nil
	}

	convenience init(fromLibrary selectionString:String?) {

		 // Make tree's root (a RootPart):
		self.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		title					= "'\(selectionString ?? "nil")' not found"

		 // Find the Library that contains the trunk for self, the root.
		if let lib				= Library.library(fromSelector:selectionString) {
			let ans :ScanAnswer	= lib.answer		// found
			title				= "'\(selectionString ?? "nil")' -> \(ans.ansTestNum):\(lib.name).\(ans.ansLineNumber!)"
			ansConfig			= ans.ansConfig

/* */		let ansTrunk:Part?	= ans.ansTrunkClosure!()

			addChild(ansTrunk)
			setTree(root:self, parent:nil)
		}else{
			fatalError("RootPart(fromLibrary:\(selectionString ?? "nil") -- no RootPart generated")
		}
		dirtySubTree(.vew)		// IS THIS SUFFICIENT, so early?
//		self.dirty.turnOn(.vew)
//		markTree(dirty:.vew)
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

	// MARK: - 4. Build
	func wireAndGroom(_ c:FwConfig) {
		atBld(4, logd("Raw Network:" + "\n" + pp(.tree)))

		 //  1. GATHER LINKS as wirelist:
		atBld(4, logd("------- GATHERING potential Links:"))
		var linkUps : [()->()]	= []
		gatherLinkUps(into:&linkUps)

		 //  2. ADD LINKS:
		atBld(4, logd("------- WIRING \(linkUps.count) Links to Part:"))
		linkUps.forEach { 	addLink in 		addLink() 							}
		setTree(root:self, parent:nil)

		 //  3. Grooom post wires:
		atBld(4, logd("------- Grooming Parts..."))
		groomModelPostWires(root:self)				// + +  + +
		dirtySubTree()															//dirty.turnOn(.vew) 	// Mark rootPart dirty after installing new trunk
																				//markTree(dirty:.vew) 	// Mark rootPart dirty after installing new trunk
																				//dirty.turnOn(.vew)
		//let x = pp(.tree)

		 //  4. Reset
		atBld(4, logd("------- Reset..."))
		reset()

		 //  5. TITLE of window: 			//e.g: "'<title>' 33:142 (3 Ports)"
		title					+= " (\(portCount()) Ports)"

		 //  6. Print
		atBld(2, logd("------- Parts, ready for simulation, simEnabled:\(simulator.simEnabled)):\n" + (pp(.tree))))

		//dirtySubTree(.vew)		// NOT NEEDED

		 //  8. Done, release partTree Lock
		atBld(3, logd({
			let errors 				= logNErrors	   == 0 ? "no errors"
									: logNErrors	   == 1 ? "1 error"
											  : "\(logNErrors) errors"
			let warnings 			= warningLog.count == 0 ? "no warnings"
									: warningLog.count == 1 ? "1 warning"
									: "\(warningLog.count) warnings"
			let titleWidth			= title.count
			let width				= titleWidth + "######                ######".count
			let errWarnWidth		= errors.count + warnings.count + 2
			let trailing1			= String(repeating:"#", count:width - "#################### ".count - errWarnWidth - 2)
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
			rv							+= ppUnusedKeys()
			rv							+= """
				######        \(blanks   )        ######
				######        \(blanks   )        ######\n
				"""
			return "\n" + rv
			} ( ) ) )
	}

	  // MARK: - 5. Lock
	 // ///////////////// LOCK Parts Tree /////////////
	// https://stackoverflow.com/questions/31700071/scenekit-threads-what-to-do-on-which-thread

	/// Lock the Part Tree:
	/// - Parameters:
	///   - newOwner: of the lock. nil->don't get lock
	///   - wait: logs if wait
	///   - logIf: allows logging
	/// - Returns: lock obtained
 	func lock(partTreeAs newOwner:String?, wait:Bool=true, logIf:Bool=true) -> Bool {
		guard let newOwner else {	return true 								}
		let u_name				= ppUid(self) + " '\(newOwner)'".field(-20)
								
		atBld(3, {					// === ///// BEFORE GETTING:
			let val0			= partTreeLock.value ?? -99
			let msg				= " //######\(u_name)      GET Part LOCK: v:\(val0)"
			 // Log:
			!logIf || !debugOutterLock ? nop 		 		// less verbose
			 :				 val0 <= 0 ? atBld(4, logd(msg +  ", OWNER:'\(partTreeOwner ?? "-")', PROBABLE WAIT..."))
			 : 		   partTreeVerbose ? atBld(4, logd(msg))// normal
			 : 		   					 nop			 	// silent
		}())

		 /// === Get partTree lock:
/**/	while partTreeLock.wait(timeout:.now() + .seconds(10)) != .success {
//**/	while partTreeLock.wait(timeout:.distantFuture) != .success {
			 // === ///// FAILED to get lock:
			let val0		= partTreeLock.value ?? -99
			let msg			= "\(u_name)      FAILED Part LOCK v:\(val0)"
			wait  			? atBld(4, logd(" //######\(msg)")) :
			partTreeVerbose ? atBld(4, logd(" //######\(msg)")) :
							  nop
			panic(msg)	// for debug only
			return false
		}

		 // === SUCCEEDED in getting lock:
		assert(partTreeOwner==nil, "'\(newOwner)' attempting to lock, but '\(partTreeOwner!)' still holds lock ")
		partTreeOwner		= newOwner
		atBld(3, {						// === /////  AFTER GETTING:
			let msg			= "\(u_name)      GOT Part LOCK: v:\(partTreeLock.value ?? -99)"
			!logIf ? nop
				: partTreeOwner != "renderScene" ? logd(" //######\(msg)")
				:				 partTreeVerbose ? logd(" //######\(msg)")
				:							 	   nop 		// print nothing
		}())
 		return true
 	}
	
	/// Unlock the Part tree
	/// - Parameters:
	///   - lockName:  of the lock. nil->don't get lock
	///   - logIf: allows logging
 	func unlock(partTreeAs newOwner:String?, logIf:Bool=true) {
		guard let newOwner else {	return 	 									}
		assert(partTreeOwner != nil, "Attempting to unlock ownerless lock")
		assert(partTreeOwner == newOwner, "Releasing (as '\(newOwner)') Part lock owned by '\(partTreeOwner!)'")
		let u_name			= ppUid(self) + " '\(partTreeOwner!)'".field(-20)
		atBld(3, {
			let val0		= partTreeLock.value ?? -99
			let msg			= "\(u_name)  RELEASE Part LOCK: v:\(val0)"
			!logIf ? nop
				: partTreeOwner != "renderScene" ? logd(" \\\\######\(msg)")
				:				 partTreeVerbose ? logd(" \\\\######\(msg)")
				:								   nop
		}())

		 // update name/state BEFORE signals
		partTreeOwnerPrev	= partTreeOwner
		partTreeOwner 		= nil
		 // Unlock Part's DispatchSemaphore:
		partTreeLock.signal()

		atBld(3, {
			let val0		= partTreeLock.value ?? -99
			let msg			= "\(u_name) RELEASED Part LOCK v:\(val0)"
			!debugOutterLock || !logIf 			  ? nop		// less verbose
			 : partTreeOwnerPrev != "renderScene" ? atApp(4, logd(" \\\\######\(msg)"))
			 :				     partTreeVerbose  ? atApp(4, logd(" \\\\######\(msg)"))
			 :	 		    					    nop
		}())
	}

	 // MARK: - 8. Reenactment Simulator
	  /// Count of all Ports in root
	 /// - Returns: Number of Ports
	func portCount() -> Int {
		var rv  				= 0
		let _ 					= findX(firstWith:
		{(part:Part) -> Part? in		// Count Ports:
			if part is Port {
				rv				+= 1	// Count Ports in tree
			}
			return nil		// nil -> not found -> look at all in self
		})
		return rv
	}

	 // MARK: - 9.3 reSkin
	override func reSkin(_ expose:Expose?=nil, vew:Vew) -> BBox 	{
		// invisible?
		return .empty						// Root Part is invisible
	}

	// MARK: - 14. Building
	 // Part.log comes here to stop  -- else infinite loop
	override var log : Log 	{ 	fwGuts?.log ?? .reliable					}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 				= super.pp(mode, aux)	// Use Part's pp()
		if mode == .line {
			rv					+= " \"\(title)\""
		}
		return rv
	}
	 // MARK: - 16. Global Constants
	static let nullRoot 		= {
		let rp					= RootPart()	// Any use of this should fail (NOT IMPLEMENTED)
		rp.name					= "nullRoot"
		return rp
	}()
}
