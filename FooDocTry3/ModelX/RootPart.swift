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
	var log 			: Log
	var title							= ""
	var ansConfig		: FwConfig		= [:]
	var fwDocument		: FooDocTry3Document? = nil	//FwDocument

	 // MARK: - 2.3 Part Tree Lock
	 // Semaphor to exclude SCNSceneRenderer thread
	let partTreeLock 			= DispatchSemaphore(value:1)					//https://medium.com/@roykronenfeld/semaphores-in-swift-e296ea80f860
	var partTreeOwner : String?	= nil  		// root lock Owner's name
	var partTreeOwnerPrev:String? = nil
	var partTreeVerbose			= true
	var partTrunk : Part?	{	return child0									}

//	// MARK: - 2.4.4 Building
	var indexFor:Dictionary<String,Int>	= ["":0]	// index of named items (<Class>,"wire","WBox","origin","breakAtWire"
//	var wireNumber				= 0			// Used in construction				//	"wire"
//	var originNameIndex			= 1			// Index of origin (of SCNGeometry)	//	"WBox"
//	var wBoxNameIndex			= 1			// Index of wire box for name		//	"origin"
//	var breakAtWireNo			= -1		// default OFF						//	"breakAtWire"

	// MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {		/// WHY IS THIS NEEDED?
		simulator				= Simulator([:])
		log						= Log(params4docLog, title:"RootPart([:])'s Log(params4docLog)")
		super.init(["name":"ROOT"] + config) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		simulator.rootPart		= self
	}

//// START CODABLE ///////////////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum RootPartKeys: String, CodingKey {
		case simulator
		case log
		case title
		case ansConfig
//	//	NO FwDocument,
//	//	case partTreeLock 			// DispatchSemaphore(value:1)					//https://medium.com/@roykronenfeld/semaphores-in-swift-e296ea80f860
		case partTreeOwner 			// String?
		case partTreeOwnerPrev		// String?
//		case partTreeVerbose		// Bool
//		case wireNumber
//		case wBoxNameIndex
//		case originNameIndex
//		case breakAtWireNo
	}
	 // Serialize 					// po container.contains(.name)
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:RootPartKeys.self)

		try container.encode(simulator,			forKey:.simulator				)
		try container.encode(log,				forKey:.log						)
		try container.encode(title,				forKey:.title					)
	//	try container.encode(ansConfig,			forKey:.ansConfig				)		// TODO requires work!
//
//	//	try container.encode(partTreeLock, 		forKey:.partTreeLock 			)
		try container.encode(partTreeOwner,		forKey:.partTreeOwner 			)
		try container.encode(partTreeOwnerPrev,	forKey:.partTreeOwnerPrev		)
//		try container.encode(partTreeVerbose,	forKey:.partTreeVerbose			)
//
//		try container.encode(wireNumber, 		forKey:.wireNumber 				)
//		try container.encode(wBoxNameIndex,		forKey:.wBoxNameIndex			)
//		try container.encode(originNameIndex,	forKey:.originNameIndex			)
//		try container.encode(breakAtWireNo,		forKey:.breakAtWireNo			)
//		atSer(3, logd("Encoded"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:RootPartKeys.self)

		simulator				= try container.decode(Simulator.self, forKey:.simulator	)
		log						= try container.decode(		 Log.self, forKey:.log			)
		title					= try container.decode(   String.self, forKey:.title		)
//		ansConfig				= try container.decode(	FwConfig.self, forKey:.ansConfig	)
//	//	partTreeLock 			= try container.decode(		 Int.self, forKey:.partTreeLock	)
		partTreeOwner			= try container.decode(  String?.self, forKey:.partTreeOwner)
		partTreeOwnerPrev		= try container.decode(	 String?.self, forKey:.partTreeOwnerPrev)
//		partTreeVerbose			= try container.decode(	    Bool.self, forKey:.partTreeVerbose)
//		wireNumber				= try container.decode(		 Int.self, forKey:.wireNumber	)
//		wBoxNameIndex			= try container.decode(		 Int.self, forKey:.wBoxNameIndex)
//		originNameIndex			= try container.decode(		 Int.self, forKey:.originNameIndex)
//		breakAtWireNo			= try container.decode(		 Int.self, forKey:.breakAtWireNo)
//		 // Recreate parts:
//	//	self.config			= [:]
//	//	rootPart.addChild(rootPart)//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//	//	rootPart.groomModel(parent:rootPart)// establish parent, ctl
		try super.init(from:decoder)
//		atSer(3, logd("Decoded  as? RootPart \(ppUid(self))"))
	}
//// END CODABLE /////////////////////////////////////////////////////////////////
//	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : RootPart		= super.copy(with:zone) as! RootPart
//		theCopy.simulator		= self.simulator
//		theCopy.log				= self.log
//		theCopy.title			= self.title
//		theCopy.ansConfig		= self.ansConfig
//	//	theCopy.partTreeLock 	= self.partTreeLock
		theCopy.partTreeOwner	= self.partTreeOwner
		theCopy.partTreeOwnerPrev = self.partTreeOwnerPrev
//		theCopy.partTreeVerbose	= self.partTreeVerbose
//		theCopy.wireNumber		= self.wireNumber
//		theCopy.wBoxNameIndex	= self.wBoxNameIndex
//		theCopy.originNameIndex	= self.originNameIndex
//		theCopy.breakAtWireNo	= self.breakAtWireNo
//		atSer(3, logd("copy(with as? RootPart       '\(fullName)'"))
//		return theCopy
bug;	return ""
	}
//	 // MARK: - 3.7 Equitable
	func varsOfRootPartEq(_ rhs:Part) -> Bool {
bug;	guard let rhsAsRootPart	= rhs as? RootPart else {	return false		}
		return true
//			&&	simulator		== rhsAsRootPart.simulator
//			&& log				== rhsAsRootPart.log
//			&& title			== rhsAsRootPart.title
//		//	&& ansConfig		== rhsAsRootPart.ansConfig				//Protocol 'FwAny' as a type cannot conform to 'Equatable'
//			&& partaTreeLock 	== rhsAsRootPart.partTreeLock
			&& partTreeOwner	== rhsAsRootPart.partTreeOwner
			&& partTreeOwnerPrev == rhsAsRootPart.partTreeOwnerPrev
//			&& partTreeVerbose  == rhsAsRootPart.partTreeVerbose
//			&& wireNumber		== rhsAsRootPart.wireNumber
//			&& wBoxNameIndex	== rhsAsRootPart.wBoxNameIndex
//			&& originNameIndex	== rhsAsRootPart.originNameIndex
//			&& breakAtWireNo	== rhsAsRootPart.breakAtWireNo
	}
//	override func equalsPart(_ part:Part) -> Bool {
//		return	super.equalsPart(part) && varsOfRootPartEq(part)
//	}


	// FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {
					// 1. Write SCNScene to file. (older, SCNScene supported serialization)

// func write(_ __fd: Int32, _ __buf: UnsafeRawPointer!, _ __nbyte: Int) -> Int
//fatalError()
	//	let j					= JSONEncoder() as! Encoder
		do {


			struct GroceryProduct: Codable {
				var name: String
				var points: Int
				var description: String?
			}
			let pear = GroceryProduct(name: "Pear", points: 250, description: "A ripe pear.")

			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			let data = try encoder.encode(self)
			print(String(data: data, encoding: .utf8)!)



			let je 				= JSONEncoder()
			je.outputFormatting = .prettyPrinted
			let data2 			= try je.encode(self)
			//Thread 4: EXC_BAD_ACCESS (code=2, address=0x16d91bfd8)
			print(String(data: data2, encoding: .utf8)!)


	//		let data			= try JSONEncoder().encode(self)
//			let data			= try self.encode(to:j)
	//		let data			= try self.encode(to:JSONEncoder())
			return data2
		} catch {
			print("\(error)")
			return nil
		}

		//open func encode<T>(_ value: T) throws -> Data where T : Encodable

//		write(to:fileURL, options:0, delegate:nil, progressHandler:nil)
					// 2. Get file to data
//		let data				= try? Data(contentsOf:fileURL)
	}
	 // initialize new SCNScene from Data
//		let jsonData = jsonString.data(using: .utf8)!
//		let user = try! JSONDecoder().decode(User.self, from: jsonData)
//		print(user.last_name)
	convenience init?(data:Data, encoding:String.Encoding) {
		let p					= try! JSONDecoder().decode(RootPart.self, from:data)
	//	self.init(from:p)
		self.init(data:data, encoding:encoding)

//		do {		// 1. Write data to file.
//			try data.write(to: fileURL)
//		} catch {
//			print("error writing file: \(error)")
//		}
//		do {		// 2. Init self from file
//			try self.init(url: fileURL)
//		} catch {
//			print("error initing from url: \(error)")
//			return nil
//		}
	}


//
//	 /// Remove all weak references of Port.connectedTo. Store their absolute path as a string
//	func virtualize() {
//		forAllParts(
//		{ part in
//			if let partAsPort		= part as? Port {
//				assert(partAsPort.con2asStr == nil, "partAsPort.con2asStr should be empty before Virtualize")
//				partAsPort.con2asStr = partAsPort.connectedTo == nil ? ""
//									 : partAsPort.connectedTo!.fullName
//				partAsPort.connectedTo = nil		// disconnect
//			}
//		})
//	}
//	/// Add weak references to Port.connectedTo from their absolute path as a string
//	func realize() {
//		forAllParts(
//		{ part in
//			if let partAsPort		= part as? Port {			// is Port
//				assert(partAsPort.connectedTo == nil, "partAsPort.connectedTo should be empty before Embed")
//				if let name			= partAsPort.con2asStr {		// Has absolute toName
//					if let toPort	= rootPart.find(name:name, inMe2:true) as? Port {
//						partAsPort.connectedTo = toPort					// Port found
//					}
//				}
//				partAsPort.con2asStr = nil			// virtual name removed
//			}
//		})
//	}
	convenience init(fromLibrary selectionString:String) {	//, fwDocument:FooDocTry3Document?

		 // Make tree's root (a RootPart):
		self.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		self.root				= self				// Every Part, including rootPart, points to rootPart
		self.fwDocument			= fwDocument		// RootPart's backpointer, if there is one
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
		markTree(dirty:.vew)
//		atBld(5, APPLOG.log("<< << <<  RootPart(fromLibraryEntry:\(selectionString)) " +
//									"found:\(title), returns:\n\(pp(.tree))"))
	}
//
//	// MARK: - 4. Build
//	func wireAndGroom() {
//		atBld(4, logd("Raw Network:" + "\n" + pp(.tree)))
//
//		 //  1. GATHER LINKS as wirelist:
//		atBld(4, logd("------- GATHERING potential Links:"))
//		var linkUps : [()->()]	= []
//		gatherLinkUps(into:&linkUps)
//
//		 //  2. ADD LINKS:
//		atBld(4, logd("------- WIRING \(linkUps.count) Links to Part:"))
//		linkUps.forEach { 	addLink in 		addLink() 							}
//		setTree(root:self, parent:nil)
//
//		 //  3. Grooom post wires:
//		atBld(4, logd("------- Grooming Parts..."))
//		groomModelPostWires(root:self)				// + +  + +
//		dirtySubTree()															//dirty.turnOn(.vew) 	// Mark rootPart dirty after installing new trunk
//																				//markTree(dirty:.vew) 	// Mark rootPart dirty after installing new trunk
//																				//dirty.turnOn(.vew)
//		 //  4. Reset
//		atBld(4, logd("------- Reset..."))
//		reset()
//
//		 //  5. TITLE of window: 			//e.g: "'<title>' 33:142 (3 Ports)"
//		title					+= " (\(portCount()) Ports)"
//
//		 //  6. Print
//		atBld(2, logd("------- Parts, ready for simulation, simEnabled:\(simulator.simEnabled)):\n" + (pp(.tree))))
//
//		 //  7. Report UNUSED Keys:
//		let unused				= ppUnusedKeys()
//		atBld(3, logd(unused.count == 0 ? "<<<<<<<<   All keys properly used >>>>>>>>"
//			: " \n <<<<<<<<<<<<<<<<<<<<<<<<   Danger. Unused keys:\n" + unused + " <<<<<<<<<<<<<<<<<<<<<<<<\n" ))
//
//		 //  8. Done, release partTree Lock
//		atBld(3, logd("DONE BUILDING PART \"\(title)\""))
//	}

	  // MARK: - 5. Lock
	 // ///////////////// LOCK Parts Tree /////////////
	// https://stackoverflow.com/questions/31700071/scenekit-threads-what-to-do-on-which-thread

	/// Get the lock for the partTree:
	/// - Parameters:
	///   - lockName: description of Lock
	///   - wait: logs if wait
	///   - logIf: allows logging
	/// - Returns: lock obtained
 	func lock(partTreeAs lockName:String?, wait:Bool=true, logIf:Bool=true) -> Bool {
		guard lockName != nil 		else {	return true 						}
		let u_name			= ppUid(self) + " '\(lockName!)'".field(-20)

		atBld(3, {					// === ///// BEFORE GETTING:
			let val0		= partTreeLock.value ?? -99
			let msg			= " //######\(u_name)      GET Part LOCK: v:\(val0)"
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

		 // === SUCCEEDED to get lock:
		assert(partTreeOwner==nil, "\(lockName!) Locking, but \(partTreeOwner!) lingers ")
		partTreeOwner		= lockName
		atBld(3, {						// === /////  AFTER GETTING:
			let msg			= "\(u_name)      GOT Part LOCK: v:\(partTreeLock.value ?? -99)"
			!logIf ? nop
				: partTreeOwner != "renderScene" ? logd(" //######\(msg)")
				:				 partTreeVerbose ? logd(" //######\(msg)")
				:							 	   nop 		// print nothing
		}())
 		return true
 	}
 	func unlock(partTreeAs lockName:String?, logIf:Bool=true) {
		guard lockName != nil 		else {	return 	 						}
		assert(partTreeOwner != nil, "Attempting to unlock ownerless lock")
		assert(partTreeOwner == lockName, "Releasing (as '\(lockName!)') Part lock owned by '\(partTreeOwner!)'")
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
	 // Inject message
	func sendMessage(fwType:FwType) {
		atEve(9, logd("      all parts ||  sendMessage(\(fwType))."))
		let fwEvent 			= FwEvent(fwType:fwType)
		return rootPart.receiveMessage(event:fwEvent)
	}

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

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		switch mode! {
		case .line:
			var rv 				= super.pp(mode, aux)
			rv					+= " \"\(title)\""
			return rv
		default:
			return super.pp(mode, aux)
		}
	}
}
