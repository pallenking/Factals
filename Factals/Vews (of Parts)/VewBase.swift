//  VewBase.swift --  Created by Allen King on 9/19/22.
//

import SceneKit
//import SwiftUI

class VewBase : NSObject, Identifiable, ObservableObject, Codable {				 //FwAny, //,
	static var nVewBase 		= 0
	var title					= "VewBase\(nVewBase)"
	var partBase	: PartBase
	var tree		: Vew
	var scnSceneBase: ScnSceneBase			// reference top Master 3D Tree
	@Published								// subscribe to selfiePole.synk for changes	//xyzzy14
	 var selfiePole 			= SelfiePole()
	var prefFps	: Float			= 30.0
	var prefFpsC: CGFloat		= 33.0
	var sliderTestVal: Double 	= 0.5
	weak
	 var factalsModel : FactalsModel!		// Owner

	@Published
	 var inspectorVews : [Vew]	= []
	func addInspectorVew(_ newInspectorVew:Vew, allowNew:Bool) {		//was AnyView
		 // use pre-existing
		if let i				= inspectorVews.firstIndex(where:{$0==newInspectorVew}) {		//inspectors.contains(newInspector),
			inspectorVews[i]	= newInspectorVew		// Replace existing
			return
		}
		if inspectorVews.count > 2 {
			inspectorVews.removeFirst()
		}
		inspectorVews.append(newInspectorVew)			// Add to end
		print("Now \(title) has \(inspectorVews.count) inspectors")
	//	objectWillChange.send()
	}
	func removeInspectorVew(_ inspectorVew:Vew){
		if inspectorVews.contains(inspectorVew) == false {
			print("\(inspectorVews.pp(.tagClass)) does not contain \\(inspectorVew.pp(.tagClass))")
		}
	//	inspectorVews.remove(inspectorVew)
//		assert(inspectorVew.parent == inspectorVews, "")
//		inspectorVew.removeFromParent()
//		objectWillChange.send()
	}

 	var cameraScn	: SCNNode?	{
 		scnSceneBase.tree?.rootNode.find(name:"*-camera", maxLevel:1)
	}
	var lookAtVew	: Vew!			// Vew we are looking at

	 // Locks
	let semiphore 				= DispatchSemaphore(value:1)
	var curLockOwner: String?	= nil
	var prevOwner	: String? 	= nil
	var verbose 				= false		// (unused)
	 // Sugar
	var slot	 	: Int?		{	factalsModel?.vewBases.firstIndex(of:self)	}
	 var slot_ 		: Int 		{	slot ?? -1 									}

	init(for pb:PartBase) {	 			/// VewBase(for:)
		partBase				= pb
		scnSceneBase			= ScnSceneBase()
		tree					= pb.tree.VewForSelf()!			//not Vew(forPart:pb.tree)

		VewBase.nVewBase 		+= 1

		super.init()			// NSObject  //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		scnSceneBase.vewBase	= self			// weak backpointer to owner (vewBase)

		lookAtVew				= tree			// set default
		scnSceneBase.monitor(onChangeOf:$selfiePole, performs:{ [weak self] in	// scnSceneBase.subscribe()
			guard self?.cameraScn != nil else {	return 							}
			self?.scnSceneBase.selfiePole2camera()
		})
	}

	func configure(from:FwConfig) {
		self.tree.configureVew(from:from)							// vewConfig = c
		selfiePole.configure(from:from)
		if let lrl				= from.bool("logRenderLocks") {
			scnSceneBase.logRenderLocks = lrl		// unset (not reset) if not present
		}
	}
	// MARK: -
	func setupSceneVisuals() {

		 // 3. Add Lights, Camera and SelfiePole
		scnSceneBase.checkLights()
		scnSceneBase.checkCamera()			// (had factalsModel.document.config)
		let _ /*axesScn*/		= scnSceneBase.touchAxesScn()

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
		case scnSceneBase
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
	//	try container.encode(scnSceneBase,		forKey:.scnSceneBase			)
//		try container.encode(sliderTestVal,		forKey:.sliderTestVal			)
		try container.encode(prefFps,			forKey:.prefFps					)
		atSer(3, logd("Encoded"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:VewKeys.self)

		title					= try container.decode(   String.self, forKey:.title		)
		partBase				= try container.decode( PartBase.self, forKey:.partBase		)
		tree					= try container.decode(   	 Vew.self, forKey:.tree			)
//		scnSceneBase			= try container.decode(ScnSceneBase.self, forKey:.scnSceneBase	)
		scnSceneBase			= ScnSceneBase()
bug	//	sliderTestVal			= try container.decode(   Double.self, forKey:.sliderTestVal)
		prefFps					= try container.decode(    Float.self, forKey:.prefFps		)

		super.init() // NSObject
		atSer(3, logd("Decoded  as? Vew \(ppUid(self))"))
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
			fatalError("Parts.from(data:encoding:) ERROR:'\(error)'")
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
		if logIf && debugOutterLock {
			atRve(3, logd("//#######\(ownerNId):     GET Vew  LOCK: v:\(semiphore.value ?? -99)" ))
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
			atRve(3, logd("//#######" + ownerNId + "      GOT Vew  LOCK: v:\(semiphore.value ?? -99)"))
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
			atRve(3, logd("\\\\#######\(u_name)  RELEASE Vew  LOCK: v:\(semiphore.value ?? -99)"))
		}

		 // update name/state BEFORE signals
		prevOwner 			= curLockOwner
		curLockOwner 		= nil

		semiphore.signal()				 // Unlock View's DispatchSemaphore:

		if debugOutterLock && logIf {
			let val0		= semiphore.value ?? -99
			atRve(3, logd("\\\\#######" + u_name + " RELEASED Vew  LOCK: v:\(val0)"))
		}
	}

		 // MARK: - 4.? Update from PartBase of my Vews and SCNScenes
		/// Update one VewBase from changes marked in Part.Tree.dirty.
	   ///		Part.Tree.dirty is not changed here, only when all VewBases are updated
	  /// - Parameter initial:	-- VewConfig for first appearance
	 ///  - Parameter log: 		-- controlls logging
	func updateVSP(initial:VewConfig?=nil, logIf log:Bool=true) { // VIEWS
		SCNTransaction.begin()
		SCNTransaction.animationDuration = CFTimeInterval(0.6)	//0.15//0.3//0.6//

		let partsTree			= partBase.tree		// Model

		 // ---- 1.  Create   V i E W s   ----  // and SCNs entry points ("*-...")
		if partsTree.test(dirty:.vew) {				//" _ reVew _   VewBase (per updateVSP()" {
			atRve(6, log ? logd("updateVSP(vewConfig:(initial)") : nop)
								
			 // change from viewing null
			if tree.name == "_null" {
bug;			tree			= partBase.tree.VewForSelf() ?? {fatalError()}()
				tree.scnRoot.name = "*-" + partBase.tree.name
			}
			 // Vew Configuration specifies open stuffss
			if let initial {
				tree.openChildren(using:initial)
			}

			  // Update Vew tree objects from Part tree
			 // (Also build a sparse SCN "entry point" tree for Vew tree)
/**/		partsTree.reVew(vew:tree, parentVew:nil)

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
	/*override*/func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
 							 				// Report any improper linking:
		guard let factalsModel 					  else{return "slot factalsModel BAD"}
		guard let slot 							  else{return "slot IS NIL"		}
		guard slot < factalsModel.vewBases.count  else{return "slot TOO BIG"	}
		guard factalsModel.vewBases[slot] == self else{return "slot inclorectly in rootVews"}
		
		return super.pp(mode, aux)			// superclass does all the work.
	}
//	  // MARK: - 16. Global Constants
//	static let null : VewBase = VewBase(for:.null)
}
