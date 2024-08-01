//
//  Vews.swift
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

class VewBase : NSObject, Identifiable, ObservableObject {	//FwAny, //Codable,
	var partBase	: PartBase
	var tree		: Vew
	var scnBase 	: ScnBase				// Master 3D Tree
	weak
	 var factalsModel :  FactalsModel!		// Owner

	@Published var selfiePole	= SelfiePole()
// 	var cameraScnB	: SCNNode?	{
// 	}
 	var cameraScn	: SCNNode?	{
 		scnBase.tree?.find(name:"*-camera", maxLevel:1)
	}
	var lookAtVew	: Vew?		= nil						// Vew we are looking at

	 // Locks
	let semiphore 				= DispatchSemaphore(value:1)
	var curLockOwner: String?	= nil
	var prevOwner	: String? 	= nil
	var verbose 				= false		// (unused)

	 // Sugar
	var slot	 	: Int?		{	factalsModel?.vewBases.firstIndex(of:self)		}

	 /// generate a new View, returning its index
	init(for p:PartBase) {
		partBase				= p
		scnBase					= ScnBase(eventHandler:eventHandler_null)
		tree					= Vew()			// Start with just trunk Vew

		super.init()			// NSObject

		scnBase.vewBase			= self			// weak backpointer to owner (vewBase)
		scnBase.tree?.name		= self.tree.name
	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}

	func configure(from:FwConfig) {
		self.tree.configureVew(from:from)							// vewConfig = c
		selfiePole.configure(from:from)
		if let lrl				= from.bool("logRenderLocks") {
			scnBase.logRenderLocks = lrl		// unset (not reset) if not present
		}
	}
	// MARK: -
	func setupSceneVisuals() {

		 // 3. Add Lights, Camera and SelfiePole
		scnBase.checkLights()
		scnBase.checkCamera()			// (had factalsModel.document.config)
		let _ /*axesScn*/		= scnBase.touchAxesScn()

		 // 4.  Configure SelfiePole:											//Thread 1: Simultaneous accesses to 0x6000007bc598, but modification requires exclusive access
		selfiePole.configure(from:factalsModel.fmConfig)

		 // 5.  Configure Initial Camera Target:
		lookAtVew				= tree//trunkVew			// default
		if let laStr			= factalsModel.fmConfig.string("lookAt"), laStr != "",
		  let  laPart 			= partBase.tree.find(path:Path(withName:laStr), me2:true) {
			lookAtVew			= tree.find(part:laPart)
		}

		 // 6. Set LookAtNode's position
		let posn				= lookAtVew?.bBox.center ?? .zero
		let worldPosition		= lookAtVew?.scn.convertPosition(posn, to:nil/*scn*/) ?? .zero
		assert(!worldPosition.isNan, "About to use a NAN World Position")
		selfiePole.position		= worldPosition
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

	   /// Update one VewBase's tree from Part Tree
	  /// - Parameter initial:	-- VewConfig for first appearance
	 /// - Parameter log: 		-- log the obtaining of locks.
	func updateVSP(initial:VewConfig?=nil, logIf log:Bool=true) { // VIEWS
		let partsTree			= partBase.tree		// Model

		 // ---- 1.  Create   V i E W s   ----  // and SCNs entry points ("*-...")
		if partsTree.test(dirty:.vew) {		//" _ reVew _   VewBase (per updateVewSizePaint(needsLock:'\\(newOwner2)')") {
			atRve(6, log ? logd("updateVewSizePaint(vewConfig:(initial)") : nop)

			 // if Empty, make new base
			if tree.name == "_null" {
				tree		= partBase.tree.VewForSelf() ?? { fatalError() }()
				scnBase.tree = tree.scn
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
		 // ---- 2.  Adjust   S I Z E s   ---- //
		if partsTree.test(dirty:.size) {		//" _ reSize _  VewBase (per updateVewSizePaint(needsLock:'(newOwner2 ?? \"nil\")')") {
/**/		partsTree.reSize(vew:tree)				// also causes rePosition as necessary
			
			tree.bBox		|= BBox.unity			// insure a 1x1x1 minimum
								
			partsTree.rePosition(vew:tree)				// === only outter vew centered
			tree.orBBoxIntoParent()
			partsTree.reSizePost(vew:tree)				// ===(set link Billboard constraints)
	//		vRoot.bBox			= .empty			// Set view's bBox EMPTY
		}
		 // -----   P A I N T   Skins ----- //
		if partsTree.test(dirty:.paint) {		//" _ rePaint _ VewBase (per updateVewSizePaint(needsLock:'(newOwner2 ?? \"nil\")')") {
	/**/	partsTree.rePaint(vew:tree)				// Ports color, Links position

			 // THESE SEEM IN THE WRONG PLACE!!!
			partsTree.computeLinkForces(vew:tree)	// Compute Forces (.force == 0 initially)
			partsTree  .applyLinkForces(vew:tree)	// Apply   Forces (zero out .force)
			partsTree .rotateLinkSkins (vew:tree)	// Rotate Link Skins

		}
	}

	 // MARK: - 15. PrettyPrint
	/*override*/func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
 							 				// Report any improper linking:
		guard let factalsModel 					  else{return "factalsModel BAD"}
		guard let slot 							  else{return "slot IS NIL"		}
		guard slot < factalsModel.vewBases.count  else{return "slot TOO BIG"	}
		guard factalsModel.vewBases[slot] == self else{return "self inclorectly in rootVews"}
		
		return super.pp(mode, aux)			// superclass does all the work.
	}
	  // MARK: - 16. Global Constants
	static let null : VewBase = VewBase(for:.null)
}
