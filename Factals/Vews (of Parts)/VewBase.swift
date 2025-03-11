//  VewBase.swift --  Created by Allen King on 9/19/22.
//
import SceneKit

extension VewBase : Equatable {
	static func == (lhs:VewBase, rhs:VewBase) -> Bool {	// protocol Equatable
		lhs === rhs
	//	if lhs.partBase !== rhs.partBase 	{ 					return false 	}
	//	if lhs.tree != rhs.tree 	{ 							return false 	}
	//	return true
	}
}

class VewBase : /*NSObject,*/ Identifiable, ObservableObject, Codable, Uid {
	var nameTag: UInt16			= getNametag()				// protocol Uid

	static var nVewBase 		= 0
	var title					= "VewBase\(nVewBase)"
	var partBase	  : PartBase
	var tree		  : Vew
	var scnBase: ScnBase				// reference top Master 3D Tree

	 // Instance method 'monitor(onChangeOf:performs:)' requires that
	//   'SelfiePole' conform to 'Publisher'
	@Published							// subscribe to selfiePole.sink for changes
	 var selfiePole 			= SelfiePole()
//	var config		 : FwConfig = [:]
//	var vewBaseConfig: FwConfig = [:]
	weak
	 var factalsModel : FactalsModel!	// Our Owner

	var prefFps		  : Float	= 30.0
	var prefFpsC	  : CGFloat	= 33.0
	var sliderTestVal : Double 	= 0.5

	@Published
	 var inspectedVews : [Vew]	= []	// ... to be Inspected
	func addInspector(forVew:Vew, allowNew:Bool) {//was AnyView
		 // use pre-existing
		if let i				= inspectedVews.firstIndex(where:{$0==forVew}) {		//inspectors.contains(newInspector),
			inspectedVews[i]	= forVew	// Replace existing
			return
		}
		if inspectedVews.count > 2 {		// Limit growth
			inspectedVews.removeFirst()
		}
		inspectedVews.append(forVew)			// Add to end
		print("Now \(title) has \(inspectedVews.count) inspectors")
	//	objectWillChange.send()
	}
	func removeInspector(forVew:Vew){
		guard let i				= inspectedVews.firstIndex(of:forVew) else {
			panic("\(inspectedVews.pp(.tagClass)) does not contain \(forVew.pp(.tagClass))")
			return
		}
		inspectedVews.remove(at:i)
	//	objectWillChange.send()
	}

 	var cameraScn	: SCNNode?	{
 		scnBase.roots?.rootNode.find(name:"*-camera", maxLevel:1)
	}
	var lookAtVew	: Vew!			// Vew we are looking at

	 // Locks
	let semiphore 				= DispatchSemaphore(value:1)
	var curLockOwner: String?	= nil
	var prevOwner	: String? 	= nil
	var verbose 				= false		// (unused)
	 // Sugar
	var slot	 	: Int?		{	factalsModel?.vewBases.firstIndex(of:self)	}
	 var slot_ 		: Int 		{
	 	let s					= slot ?? -1
//		print("######### Fetching slot_for '\(self.title)': returns \(s) ######### ")
		return s
	}

	init(for pb:PartBase, vewConfig:VewConfig) {	 			/// VewBase(for:) ///
		partBase				= pb
		scnBase					= ScnBase()
		tree					= pb.tree.VewForSelf()!			//not Vew(forPart:pb.tree)
		VewBase.nVewBase 		+= 1

		//super.init()			// NSObject  //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		self.tree.vewConfig		= vewConfig
		lookAtVew				= tree			// set default

		scnBase.vewBase			= self			// weak backpointer to owner (vewBase)
		scnBase.monitor(onChangeOf:$selfiePole)
		{ [weak self] in						// scnBase.subscribe()
			if self?.cameraScn == nil {		return 								}
			self!.scnBase.selfiePole2camera()
		}
	}

	func configure(from:FwConfig) {
//		self.config 			= from			// VewBase.self
	//	self.tree.vewConfig		= from			// Vew.vewConfig = c
		selfiePole.configure(from:from)
		if let lrl				= from.bool("logRenderLocks") {
			scnBase.logRenderLocks = lrl		// unset (not reset) if not present
		}
	}
	// MARK: -
	func setupSceneVisuals(fwConfig:FwConfig) {

		 // 3. Add Lights, Camera and SelfiePole
		scnBase.checkLights()
		scnBase.checkCamera()			// (had factalsModel.document.config)
		let _ /*axesScn*/		= scnBase.touchAxesScn()

		 // 4.  Configure SelfiePole:											//Thread 1: Simultaneous accesses to 0x6000007bc598, but modification requires exclusive access
		selfiePole.configure(from:factalsModel.fmConfig)

		 // 5.  Configure Initial Camera Target:
		lookAtVew				= tree		// default is trunk
		if let laStr			= factalsModel.fmConfig.string("lookAt"),
		  laStr != "",
		  let  laPart 			= partBase.tree.find(path:Path(withName:laStr), inMe2:true),
		  let laVew				= tree.find(part:laPart) {
			lookAtVew			= laVew
		}

		 // 6. Set LookAtNode's position
		let posn				= lookAtVew.bBox.center
		let worldPosition		= lookAtVew.scnRoot.convertPosition(posn, to:nil/*scnScene*/)
		assert(!worldPosition.isNan, "About to use a NAN World Position")
		selfiePole.position		= worldPosition
	}

//	 // MARK: - 3.5 Codable
	enum VewKeys: String, CodingKey {
		case title
		case partBase
		case tree
		case scnBase
		case selfiePole
		case prefFps
//		case sliderTestVal
	}

	 // Serialize 					// po container.contains(.name)
	func encode(to encoder: Encoder) throws  {
		//try super.encode(to: encoder) // Not needed for NSObject
		var container 			= encoder.container(keyedBy:VewKeys.self)

		try container.encode(title,				forKey:.title					)
		try container.encode(partBase,			forKey:.partBase				)
		try container.encode(tree,				forKey:.tree					)
	//	try container.encode(scnBase,		forKey:.scnBase			)
//		try container.encode(sliderTestVal,		forKey:.sliderTestVal			)
		try container.encode(prefFps,			forKey:.prefFps					)
		logSer(3, "Encoded")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:VewKeys.self)

		title					= try container.decode(   String.self, forKey:.title		)
		partBase				= try container.decode( PartBase.self, forKey:.partBase		)
		tree					= try container.decode(   	 Vew.self, forKey:.tree			)
//		scnBase			= try container.decode(ScnBase.self, forKey:.scnBase	)
		scnBase			= ScnBase()
bug	//	sliderTestVal			= try container.decode(   Double.self, forKey:.sliderTestVal)
		prefFps					= try container.decode(    Float.self, forKey:.prefFps		)

		//super.init() // NSObject
		logSer(3, "Decoded  as? Vew \(ppUid(self))")
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
	static func from(data:Data, encoding:String.Encoding) -> VewBase {
		do {
			return try JSONDecoder().decode(VewBase.self, from:data)
		} catch {
			debugger("Parts.from(data:encoding:) ERROR:'\(error)'")
		}
	}

	// MARK: - 4. Factory
	// MARK: - 4? Locks
	/// Optain DispatchSemaphor for Vew Tree
	/// - Parameters:
	///   - for owner: get lock for this name. nil --> don't lock
	///   - logIf: log the description
	/// - Returns: Operation Succeeded
	func lock(for lockName:String, logIf:Bool) -> Bool {

		let ownerNId		= ppUid(self) + " '\(lockName)'".field(-20)
		if logIf && Log.shared.debugOutterLock {
			logRve(3, "//#######\(ownerNId):     GET Vew  LOCK: v:\(semiphore.value ?? -99)")
		}

		 // === Get trunkVew DispatchSemaphore:
		while semiphore.wait(timeout:.now() + .seconds(10)) != .success {		//.distantFuture
			 // === Failed to get lock:
			let val0		= semiphore.value ?? -99
			var msg			= "\(ownerNId):     FAILED Part LOCK: v:\(val0)"
			msg				+= "curOwner=\(curLockOwner ?? "<nil>"), prevOwner=\(prevOwner ?? "<nil>")"
			fatalError(msg)	// for debug only
		}

		 // === Succeeded:
		assert(curLockOwner==nil, "'\(lockName)' attempting to lock, but '\(curLockOwner!)' still holds lock ")
		curLockOwner 		= lockName
		if logIf  {						/// AFTER GETTING:
			logRve(3, "//#######" + ownerNId + "      GOT Vew  LOCK: v:\(semiphore.value ?? -99)")
		}
		return true
	}
	/// Release DispatchSemaphor for Vew Tree
	/// - Parameters:
	///   - lockName: get lock under this name. nil --> don't lock
	///   - logIf: log the description
	func unlock(for neededLockName:String, logIf:Bool) {
		assert(curLockOwner != nil, "releasing VewTreeLock but 'rootVewOwner' is nil")
		assert(curLockOwner == neededLockName, "Releasing (as '\(neededLockName)') Vew lock owned by '\(curLockOwner!)'")
		let u_name			= ppUid(self) + " '\(curLockOwner!)'".field(-20)
		if logIf {
			logRve(3, "\\\\#######\(u_name)  RELEASE Vew  LOCK: v:\(semiphore.value ?? -99)")
		}

		 // update name/state BEFORE signals
		prevOwner 			= curLockOwner
		curLockOwner 		= nil

		semiphore.signal()				 // Unlock View's DispatchSemaphore:

		if Log.shared.debugOutterLock && logIf {
			let val0		= semiphore.value ?? -99
			logRve(3, "\\\\#######" + u_name + " RELEASED Vew  LOCK: v:\(val0)")
		}
	}

		 // MARK: - 4.? Update from PartBase of my Vews and SCNScenes
		/// Update one VewBase from changes marked in Part.Tree.dirty.
	   ///		Part.Tree.dirty is not changed here, only when all VewBases are updated
	  /// - Parameter initial:	-- VewConfig for first appearance
	 ///  - Parameter log: 		-- controlls logging
	func updateVSP(logIf log:Bool=true) { // VIEWS
		SCNTransaction.begin()
		SCNTransaction.animationDuration = CFTimeInterval(0.6)	//0.15//0.3//0.6//

		let partsTree			= partBase.tree		// Model

		 // ---- 1.  Create   V i E W s   ----  // and SCNs entry points ("*-...")
		if partsTree.test(dirty:.vew) {				//" _ reVew _   VewBase (per updateVSP()" {
			if log {
				logRve(6, "updateVSP(vewConfig:(initial)")
			}
			 // change from viewing null
			if tree.name == "_null" {
bug;			tree			= partBase.tree.VewForSelf() ?? {fatalError()}()
				tree.scnRoot.name = "*-" + partBase.tree.name
			}
										//	 // Vew Configuration specifies open stuffss
										//	if let initial {
										//		tree.openChildren(using:initial)
										//	}
			  // Update Vew tree objects from Part tree
			 // (Also build a sparse SCN "entry point" tree for Vew tree)
/**/		partsTree.reVew(vew:tree, parentVew:nil)

			  // LinkVew's [sp]Con2Vew endpoints and constraints:
			 // should have created all Vews and one *-<name> in ptn tree
			partsTree.reVewPost(vew:tree)
		}
		 // ---- 2.  Adjust   S I Z E s   ----- //
		if partsTree.test(dirty:.size) {		//" _ reSize _  VewBase (per updateVSP()" {
/**/		partsTree.reSize(vew:tree)				// also causes rePosition as necessary
			
			tree.bBox		|= BBox.unity			// insure a 1x1x1 minimum
								
			partsTree.rePosition(vew:tree)				// === only outter vew centered
			tree.orBBoxIntoParent()
			partsTree.reSizePost(vew:tree)				// ===(set link Billboard constraints)
	//		vRoot.bBox			= .empty			// Set view's bBox EMPTY
		}
		 // --- 3.  Re  P A I N T   Skins ----- //
		if partsTree.test(dirty:.paint) {		//" _ rePaint _ VewBase (per updateVSP()" {
	/**/	partsTree.rePaint(vew:tree)				// Ports color, Links position

			 // THESE SEEM IN THE WRONG PLACE!!!
			partsTree.computeLinkForces(vew:tree)	// Compute Forces (.force == 0 initially)
			partsTree  .applyLinkForces(vew:tree)	// Apply   Forces (zero out .force)
			partsTree .rotateLinkSkins (vew:tree)	// Rotate Link Skins
		}
		SCNTransaction.commit()
	}
								
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String {
 							 	// Report any improper linking:
		var rv					= ""
		if slot == nil || factalsModel?.vewBases[slot!] != self {
			rv					+= "not placed in a VewBase slot properly\n"
		}
		rv						+= tree.pp(mode, aux)
		if mode == .line {
			rv					+= " \"\(title)\""
			rv					+= "\(nameTag) "
			rv					+= "\(partBase.pp(.nameTagClass)) "
			rv					+= "\(scnBase .pp(.nameTagClass)) "
		}
		return rv
	}
}
