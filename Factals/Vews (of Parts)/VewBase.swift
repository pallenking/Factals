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
 	var cameraScn	: SCNNode?	{ scnBase.tree?.find(name:"*-camera", maxLevel:1) }
	var lookAtVew	: Vew?		= nil						// Vew we are looking at

	 // Locks
	let semiphore 				= DispatchSemaphore(value:1)
	var curOwner 	: String?	= nil
	var prevOwner	: String? 	= nil
	var verbose 				= false		// (unused)

	 // Sugar
	var slot	 	: Int?		{	factalsModel?.vewBases.firstIndex(of:self)		}

	 /// generate a new View, returning its index
	init(for p:PartBase) {
		partBase				= p
		scnBase					= ScnBase()
		tree					= Vew()			// Start with just trunk Vew

		super.init()			// NSObject

		scnBase.vewBase			= self			// weak backpointer to owner (vewBase)
		scnBase.tree?.name		= self.tree.name
	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}

	func configure(from:FwConfig) {
		self.tree.configureVew(from:from)							// vewConfig = c
		selfiePole.configure(from:from)
	}
	// MARK: -
	func setupLightsCamerasEtc() {

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
	// MARK: - 4? locks
//	func lockBoth(for owner:String) {
//		guard partBase.lock(for:owner, logIf:false) else {fatalError(owner+" couldn't get PART lock")}
//		guard          lock(for:owner, logIf:false) else {fatalError(owner+" couldn't get VEW lock")}
//	}
//	func unlockBoth(for owner:String) {
//		unlock(for:          owner, logIf:false)
//		partBase.unlock(for:owner, logIf:false)
//	}
	/// Optain DispatchSemaphor for Vew Tree
	/// - Parameters:
	///   - for owner: get lock for this name. nil --> don't lock
	///   - logIf: log the description
	/// - Returns: Operation Succeeded
	func lock(for owner:String?=nil, logIf:Bool=true) -> Bool {
		guard let owner else	{	return true		/* no lock needed */		}

		let ownerNId		= ppUid(self) + " '\(owner)'".field(-20)
		atRve(3, {
			let val0		= semiphore.value ?? -99	/// (wait if <=0)
			if logIf && debugOutterLock {
				logd("//#######\(ownerNId):     GET Vew  LOCK: v:\(val0)" )
			}
		}() )

		 // === Get trunkVew DispatchSemaphore:
		while semiphore.wait(timeout:.now() + .seconds(10)) != .success {		//.distantFuture
			 // === Failed to get lock:
			let val0		= semiphore.value ?? -99
			var msg			= "\(ownerNId):     FAILED Part LOCK: v:\(val0)"
			msg				+= "curOwner=\(curOwner ?? "<nil>"), prevOwner=\(prevOwner ?? "<nil>")"
			fatalError(msg)	// for debug only
		}

		 // === Succeeded:
		assert(curOwner==nil, "'\(owner)' attempting to lock, but '\(curOwner!)' still holds lock ")
		curOwner 		= owner
		atRve(3, {						/// AFTER GETTING:
			let val0		= semiphore.value ?? -99
			!logIf ? nop : logd("//#######" + ownerNId + "      GOT Vew  LOCK: v:\(val0)")
		}())
		return true
	}
	/// Release DispatchSemaphor for Vew Tree
	/// - Parameters:
	///   - lockName: get lock under this name. nil --> don't lock
	///   - logIf: log the description
	func unlock(for owner:String?=nil, logIf:Bool=true) {
		guard let owner else {	return 			/* no lock to return */			}
		assert(curOwner != nil, "releasing VewTreeLock but 'rootVewOwner' is nil")
		assert(curOwner == owner, "Releasing (as '\(owner)') Vew lock owned by '\(curOwner!)'")
		let u_name			= ppUid(self) + " '\(curOwner!)'".field(-20)
		atRve(3, {
			let val0		= semiphore.value ?? -99
			let msg			= "\(u_name)  RELEASE Vew  LOCK: v:\(val0)"
			!logIf ? nop	: logd("\\\\#######\(msg)")
		}())

		 // update name/state BEFORE signals
		prevOwner 			= curOwner
		curOwner 			= nil

		 // Unlock View's DispatchSemaphore:
		semiphore.signal()

		if debugOutterLock && logIf {
			let val0		= semiphore.value ?? -99
			atRve(3, logd("\\\\#######" + u_name + " RELEASED Vew  LOCK: v:\(val0)"))
		}
	}

	// MARK: - 9 Update Vew: -
	   /// Update the Vew Tree from Part Tree
	  /// - Parameter as:		-- name of lock owner. Obtain no lock if nil.
	 /// - Parameter log: 		-- log the obtaining of locks.
	func updateVewSizePaint(initial:VewConfig?=nil, for newOwner:String?=nil, logIf log:Bool=true) { // VIEWS
		guard let factalsModel	 else { 	fatalError("Paranoia 29872") 		}
		let partsTree			= partBase.tree		// Model

/**/	SCNTransaction.begin()
		SCNTransaction.animationDuration = CFTimeInterval(0.15)	//0.3//0.6//

				 /// Is Part Tree dirty? If so, obtain lock
				 /// - Parameters:
				 ///   - dirty: kind of dirty (.vew, .size, or .paint) to check
				 ///    - viewLockName: Owner of lock; nil -> no lock needed
				 ///     - log: log the message
				 ///      - message: massage to log
				 ///      - Returns: Work
				func hasDirty(_ dirty:DirtyBits, log:Bool, _ message:String) -> Bool {
					if partsTree.test(dirty:dirty) {			// DIRTY? Get VIEW LOCK:
						guard lock(for:nil/*owner*/, logIf:log) else {
							fatalError("updateVewSizePaint(needsViewLock:'(owner )') FAILED to get it")
						}
			//			logd("updateVewSizePaint: setting  dirty.\(dirty.pp()) = true  at \(pp(.name))")
						return true
					}
			//		logd("updateVewSizePaint: setting  dirty.\(dirty.pp()) = false at \(pp(.fullName))")
					return false
				}

		 // ---- 1.  Create   V i E W s   ---- // and SCNs entry points ("*-...")
		if hasDirty(.vew, log:log, " _ reVew _   VewBase (per updateVewSizePaint(needsLock:'\\(newOwner2)')") {
			for vewBase in factalsModel.vewBases { // Part.dirty.vew is for all Vews

			

				atRve(6, log ? logd("updateVewSizePaint(vewConfig:(initial)") : nop)
				if let initial {					// Vew Configuration specifies open stuffss

					// if Empty, make new base
					if tree.name == "_null" {
						tree		= partBase.tree.VewForSelf() ?? { fatalError() }()
						scnBase.tree = tree.scn
					}

					tree.openChildren(using:initial)
				}
			}

			  // Update Vew tree objects from Part tree
			 // (Also build a sparse SCN "entry point" tree for Vew tree)
/**/		partsTree.reVew(vew:tree, parentVew:nil)

			// should have created all Vews and one *-<name> in ptn tree
			partsTree.reVewPost(vew:tree)
		}
		 // ---- 2.  Adjust   S I Z E s   ---- //
		if hasDirty(.size, log:log,
			" _ reSize _  VewBase (per updateVewSizePaint(needsLock:'(newOwner2 ?? \"nil\")')") {

/**/		partsTree.reSize(vew:tree)				// also causes rePosition as necessary
			
			tree.bBox		|= BBox.unity			// insure a 1x1x1 minimum
								
			partsTree.rePosition(vew:tree)				// === only outter vew centered
			tree.orBBoxIntoParent()
			partsTree.reSizePost(vew:tree)				// ===(set link Billboard constraints)
	//		vRoot.bBox			= .empty			// Set view's bBox EMPTY
		}
		 // -----   P A I N T   Skins ----- //
		if hasDirty(.paint, log:log,
			" _ rePaint _ VewBase (per updateVewSizePaint(needsLock:'(newOwner2 ?? \"nil\")')") {

	/**/	partsTree.rePaint(vew:tree)				// Ports color, Links position

			 // THESE SEEM IN THE WRONG PLACE!!!
			//pRoot.computeLinkForces(vew:vRoot)	// Compute Forces (.force == 0 initially)
			//pRoot  .applyLinkForces(vew:vRoot)	// Apply   Forces (zero out .force)
			partsTree .rotateLinkSkins (vew:tree)		// Rotate Link Skins
		}
		let unlockName:String?	= newOwner == nil ? nil :			// no lock wanted
//								  newOwner2 == nil ? newOwner :// we locked it!
								  nil							// we locked nothing
/**/	SCNTransaction.commit()

		unlock(for:unlockName, logIf:log)			// Release this VEW LOCK
	}

	 // MARK: - 15. PrettyPrint
	/*override*/func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
 							 				// Report any improper linking:
		guard let factalsModel 					else{return "factalsModel BAD"	}
		guard let slot 							else{return "slot IS NIL"		}
		guard slot < factalsModel.vewBases.count  else{return "slot TOO BIG"	}
		guard factalsModel.vewBases[slot] == self else{return "self inclorectly in rootVews"}
		
		return super.pp(mode, aux)			// superclass does all the work.
	}
	  // MARK: - 16. Global Constants
	static let null : VewBase = VewBase(for:.null)
//	static let null : VewBase = {
//		let rv					= Vews(for:.null)
//		//rv.name					= "null"
//		return rv
//	}()
}
