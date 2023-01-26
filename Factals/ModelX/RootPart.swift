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




	 // MARK: - 2.3 Part Tree Lock
	var partTreeLock 			= DispatchSemaphore(value:1)					//https://medium.com/@roykronenfeld/semaphores-in-swift-e296ea80f860
	var partTreeOwner : String?	= nil  		// root lock Owner's name
	var partTreeOwnerPrev:String? = nil
	var partTreeVerbose			= true
	var partTrunk : Part?	{	return child0									}

//	// MARK: - 2.4.4 Building
//	 // index of named items (<Class>,"wire", "WBox", "origin", "breakAtWire"
//	var indexFor				= Dictionary<String,Int>()

	// MARK: - 3. Part Factory
	init() {
		simulator				= Simulator()
		super.init(["name":"ROOT"]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		simulator.rootPart		= self
	}
	func pushControllersConfig(to c:FwConfig) {
		assert(simulator.rootPart === self, "RootPart.reconfigureWith ERROR with simulator owner rootPart")
		simulator.pushControllersConfig(to:c) 	// CUSTOMER 1
	}
//// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum RootPartKeys: String, CodingKey {
		case simulator
		case log
		case title
		case ansConfig
//		case indexFor
//	//	NO FwDocument,
		case partTreeVerbose		// Bool
	}

	// // // // // // // // // // // // // // // // // // // // // // // // // //
	func makeSelfCodable(_ msg:String?=nil) {		// was readyForEncodable
		guard msg == nil || lock(partTreeAs:msg!) else { fatalError("'\(msg!)' couldn't get PART lock") }
		 // modifies self

		virtualize() 	// ---- 1. Retract weak crossReference .connectedTo in Ports, replace with absolute string
								
		let aux : FwConfig		= ["ppDagOrder":false, "ppIndentCols":20, "ppLinks":true]
		atSer(5, logd(" ========== rootPart to Serialize:\n\(pp(.tree, aux))", terminator:""))
						
		polyWrapChildren()		// ---- 2. INSERT -  PolyWrap's to handls Polymorphic nature of Parts

		atSer(5, logd(" ========== inPolyPart with Poly's Wrapped :\n\(pp(.tree, aux))", terminator:""))
	}

	func makeSelfRunable(_ msg:String?=nil) {		// was recoverFromDecodable
	 			
		polyUnwrapRp()	// ---- 3. REMOVE -  PolyWrap's
						
		realize()		// ---- 4. Replace weak references

		groomModel(parent:nil as Part?, root:self)
		//indexFor	= [:]		// HACK! should store in fwDocument!
		atSer(5, logd(" ========== rootPart unwrapped:\n\(pp(.tree, ["ppDagOrder":false]))", terminator:""))
		
		msg == nil ? nop : unlock(partTreeAs:msg) // ---- 1. Get LOCKS for PartTree
	}
	// // // // // // // // // // // // // // // // // // // // // // // // // //

	 // Serialize 					// po container.contains(.name)
	override func encode(to encoder: Encoder) throws  {

		 // Massage Part Tree, to make it
		makeSelfCodable("writePartTree")		//readyForEncodable

		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:RootPartKeys.self)

		try container.encode(simulator,			forKey:.simulator				)
		try container.encode(title,				forKey:.title					)
	//?	try container.encode(ansConfig,			forKey:.ansConfig				)		// TODO requires work!
//		try container.encode(indexFor, 			forKey:.indexFor 				)
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
//		indexFor				= try container.decode(Dictionary<String,Int>.self, forKey:.indexFor)
		partTreeLock 			= DispatchSemaphore(value:1)	//try container.decode(DispatchSemaphore.self,forKey:.partTreeLock	)
		partTreeVerbose			= try container.decode(	    Bool.self, forKey:.partTreeVerbose)

		try super.init(from:decoder)
		atSer(3, logd("Decoded  as? RootPart \(ppUid(self))"))

		makeSelfRunable()		// (no unlock)
	}


//	 // MARK: - 3.4 NSKeyedArchiver Serialization
//	// ////////////// NSDocument calls these: /////////////////////////////
//
//	   // http://meandmark.com/blog/2016/03/saving-game-data-with-nscoding-in-swift/
//	  //  https://stackoverflow.com/questions/53097261/how-to-solve-deprecation-of-unarchiveobjectwithfile
//	 // WRITE to data (e.g. file) from objects		USES NSKeyedArchiver
//	/*override*/ func data(ofType typeName: String) throws -> Data {
									//		do {
									//			 // ---- 1. Get LOCKS for PartTree
									//			let lockStr			= "writePartTree"
									//			guard	rootPart.lock(partTreeAs:lockStr) else {
									//				fatalError("\(lockStr) couldn't get PART lock")		// or
									//			}
									//
									//							// PREPARE
									//			atSer(3, logd("Writing data(ofType:\(typeName))"))
									//			 // ---- 2. Retract weak crossReference .connectedTo in Ports, replace with absolute string
									///* */		rootPart.virtualize()
									//
									//			let aux : FwConfig	= ["ppDagOrder":false, "ppIndentCols":20, "ppLinks":true]
									//			atSer(5, logd(" ========== rootPart to Serialize:\n\(rootPart.pp(.tree, aux))", terminator:""))
									//
									//			 // ---- 3. INSERT -  PolyWrap's to handls Polymorphic nature of Parts
									///* */		let inPolyPart:PolyWrap	= rootPart.polyWrap()	// modifies rootPart
									//			atSer(5, logd(" ========== inPolyPart with Poly's Wrapped :\n\(inPolyPart.pp(.tree, aux))", terminator:""))
									//
									//							// MAKE ARCHIVE
									//			 // Pretty Print the virtualized, PolyWrap'ed structure, using JSON
									////			let jsonData : Data	= try JSONEncoder().encode(inPolyPart)
									//			if falseF {
									//				let jsonData : Data	= try JSONEncoder().encode(inPolyPart)
									//				guard let jsonString = jsonData.prettyPrintedJSONString else {
									//					fatalError("\n" + " ========== JSON: FAILED")	}
									//				atSer(5, logd(" ========== JSON: " + (jsonString as String)))
									//			}
									//			 // ---- 4. ARCHIVE the virtualized, PolyWrapped structure
									//			let archiver = NSKeyedArchiver(requiringSecureCoding:true)
									//																	// *******:
									//			try archiver.encodeEncodable(inPolyPart, forKey:NSKeyedArchiveRootObjectKey)
									//			archiver.finishEncoding()
									//
									//							// RESTORE
									//			 // ---- 3. REMOVE -  PolyWrap's
									///* */		let rp				= inPolyPart.polyUnwrap() as? RootPart
									//			assert(rp != nil, "inPolyPart.polyUnwrap()")
									//			rootPart			= rp!
									//
									//			 // ---- 2. Replace weak references
									///* */		rootPart.realize()			// put references back	// *******
									//			rootPart.groomModel(parent:nil, root:rootPart)
									//			atSer(5, logd(" ========== rootPart unwrapped:\n\(rootPart.pp(.tree, ["ppDagOrder":false]))", terminator:""))
									//
									//			 // ---- 1. Get LOCKS for PartTree
									//			rootPart.unlock(partTreeAs:lockStr)
									//
									//			rootPart.indexFor	= [:]			// HACK! should store in fwDocument!
									//
									//			atSer(3, logd("Wrote   rootPart!"))
									//			return archiver.encodedData
									//		}
									//		catch let error {
									//			fatalError("\n" + "encodeEncodable throws error: '\(error)'")
									//		}
//	}
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
//		rootPart.realize()
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
//		theCopy.indexFor		= self.indexFor
//	//x	theCopy.partTreeLock 	= self.partTreeLock
//	//x	theCopy.partTreeOwner	= self.partTreeOwner
//	//x	theCopy.partTreeOwnerPrev = self.partTreeOwnerPrev
//		theCopy.partTreeVerbose	= self.partTreeVerbose
//		atSer(3, logd("copy(with as? RootPart       '\(fullName)'"))
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	override func equals(_ rhs:Part) -> Bool {
//		guard self !== rhs 						   else {	return true			}
//		guard let rhs			= rhs as? RootPart else {	return false 		}
//		let rv					= super.equals(rhs)
//								&& simulator		 == rhs.simulator
//								&& title			 == rhs.title
////								&& ansConfig		 == rhs.ansConfig				//Protocol 'FwAny' as a type cannot conform to 'Equatable'
//								&& indexFor		 	 == rhs.indexFor
//		//x						&& partTreeLock 	 == rhs.partTreeLock
//		//x						&& partTreeOwner	 == rhs.partTreeOwner
//		//x						&& partTreeOwnerPrev == rhs.partTreeOwnerPrev
//								&& partTreeVerbose   == rhs.partTreeVerbose
//		return rv
//	}
																				//	1. Write SCNScene to file. (older, SCNScene supported serialization)
																				//	func write(_ __fd: Int32, _ __buf: UnsafeRawPointer!, _ __nbyte: Int) -> Int
																				//	write(to:fileURL, options:0, delegate:nil, progressHandler:nil)
	  // FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {
		do {
			let je 				= JSONEncoder()
			je.outputFormatting = .prettyPrinted
			let dataRv 			= try je.encode(self)							//Thread 4: EXC_BAD_ACCESS (code=2, address=0x16d91bfd8)
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

		bug
	//	let rootPart 			= try! JSONDecoder().decode(RootPart.self, from:data)
	//	self.init(data:data, encoding:encoding)		// INFINITE
		do {		// 1. Write data to file. (Make this a loopback)
			try data.write(to:fileURL)
			//self.init(url: fileURL)
			bug;self.init()		//try self.init(url: fileURL)
		} catch {
			print("error using file: \(error)")									}
		return nil
	}

	 /// Remove all weak references of Port.connectedTo. Store their absolute path as a string
	func virtualize() {
		forAllParts(
		{ part in
			if let partAsPort		= part as? Port {
				assert(partAsPort.connectedToString == nil, "partAsPort.connectedToString should be empty before Virtualize")
				partAsPort.connectedToString = partAsPort.connectedTo == nil ? ""
									 : partAsPort.connectedTo!.fullName
				partAsPort.connectedTo = nil		// disconnect
			}
		})
	}
	/// Add weak references to Port.connectedTo from their absolute path as a string
	func realize() {
		forAllParts(
		{ part in
			if let partAsPort		= part as? Port {			// is Port
				assert(partAsPort.connectedTo == nil, "partAsPort.connectedTo should be empty before Embed")
				if let name			= partAsPort.connectedToString {		// Has absolute toName
					if let toPort	= partAsPort.find(name:name, inMe2:true) as? Port {
//					if let toPort	= rootPart.find(name:name, inMe2:true) as? Port {
						partAsPort.connectedTo = toPort					// Port found
					}
				}
				partAsPort.connectedToString = nil			// virtual name removed
			}
		})
	}
	convenience init(fromLibrary selectionString:String) {

		 // Make tree's root (a RootPart):
		self.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

//		self.root				= self				// Every Part, including rootPart, points to rootPart
		title					= "'\(selectionString)' not found"

		 // Find the Library that contains the trunk for self, the root.
		if let lib				= Library.library(fromSelector:selectionString) {
			let ans :ScanAnswer	= lib.answer		// found
			title				= "'\(selectionString)' -> \(ans.ansTestNum):\(lib.name).\(ans.ansLineNumber!)"
			ansConfig			= ans.ansConfig

/* */		let ansTrunk:Part?	= ans.ansTrunkClosure!()

			addChild(ansTrunk)
			setTree(root:self, parent:nil)
		}else{
			fatalError("RootPart(fromLibrary) -- no RootPart generated")
		}
		dirtySubTree(.vew)		// IS THIS SUFFICIENT, so early?
//		self.dirty.turnOn(.vew)
//		markTree(dirty:.vew)
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

	// MARK: - 4. Build
	func wireAndGroom() {
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
let x = pp(.tree)

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
				######
				######
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
				######
				######\n
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
/**/	while partTreeLock.wait(timeout:.distantFuture) != .success {//.distantFuture//.now() + waitSec		//let waitSec			= 2.0
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
			 : partTreeOwnerPrev != "renderScene" ? atCon(4, logd(" \\\\######\(msg)"))
			 :				     partTreeVerbose  ? atCon(4, logd(" \\\\######\(msg)"))
			 :	 		    					    nop
		}())
	}

	 // MARK: - 8. Reenactment Simulator
	  /// Count of all Ports in root
	 /// - Returns: Number of Ports
	func portCount() -> Int {
		var rv  				= 0
		let _ 					= find(firstWith:
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
	override var log : Log 	{ 	fwGuts?.log ?? .help					}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv 				= super.pp(mode, aux)
		if mode! == .line {
			rv					+= " \"\(title)\""
		}
		return rv
	}
}
