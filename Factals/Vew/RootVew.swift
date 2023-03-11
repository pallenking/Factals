//
//  RootVew.swift
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

class RootVew : Vew, Identifiable {			// inherits ObservableObject
	weak var fwGuts : FwGuts!			// Owner

	 // 3D APPEARANCE
	var rootScn 	:  RootScn			// Master tree
	 // Lighting, etc						// (in rootScn)
	var cameraScn	:  SCNNode?	= nil
	var lightsScn	: [SCNNode]	= []
	var axesScn		:  SCNNode?	= nil

	@Published var selfiePole	= SelfiePole()	// PW2 had to move to superclass
/* Had to move to superclass for ?XXXBAD?
RootVew:_______________
|	@Published var selfiePole
|
|	Vew:___________________ ObservableObject
|	|	(@Published var selfiePole)
|	|
 */
	var lookAtVew	: Vew?		= nil						// Vew we are looking at

	 // Locks
	let rootVewLock 			= DispatchSemaphore(value:1)
	var rootVewOwner : String?	= nil
	var rootVewOwnerPrev:String? = nil
	var rootVewVerbose 			= false

	 // Sugar
	var rootPart 	: RootPart	{	return part as! RootPart 					} //?? fatalError("RootVew.part is nil")}
	var slot	 	: Int?		{	fwGuts?.rootVews.firstIndex(of: self)		}
	var trunkVew 	: Vew? 		{
		return children.count > 0 ? children[0] : nil
	}

	 /// generate a new View, returning its index
//	init() {
//		rootScn					= RootScn()
//		super.init(forPart:.null, scn:.null)
//		rootScn.rootVew			= self				// owner
//	}
//	init(forPart rp:RootPart = .nullRoot, rootScn rs:RootScn = .nullRoot) {
//		rootScn					= rs
//		super.init(forPart:rp, scn:rs.scn)
//		rootScn.rootVew			= self				// owner
//
//		 // Set the base scn to comply as a Vew
//		assert(scn === rootScn.scn, "paranoia: set RootVew with new scn root")
//		scn 					= rootScn.scn		// set RootVew with new scn root
//	}
	init() {
		rootScn					= RootScn()
		super.init(forPart:.null, scn:.null)
		rootScn.rootVew			= self				// owner
	}
	init(forPart rp:RootPart, rootScn rs:RootScn=RootScn()) {
		rootScn					= rs
		super.init(forPart:rp, scn:rs.scn)
		rootScn.rootVew			= self				// owner

		 // Set the base scn to comply as a Vew
		assert(scn === rootScn.scn, "paranoia: set RootVew with new scn root")
		scn 					= rootScn.scn		// set RootVew with new scn root
	}

	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}

	func configureDocument(from c:FwConfig) {
		selfiePole.configureDocument(from:c)
		rootScn	  .configureDocument(from:c)
	}
	// MARK: -
	func setupLightsCamerasEtc() {

		 // 3. Add Lights, Camera and SelfiePole
		lightsScn				= rootScn.touchLightScns()			// was updateLights
		cameraScn				= rootScn.touchCameraScn()			// (had fwGuts.document.config)
		axesScn 				= rootScn.touchAxesScn()

		 // 4.  Configure SelfiePole:											//Thread 1: Simultaneous accesses to 0x6000007bc598, but modification requires exclusive access
		selfiePole.configureDocument(from:fwGuts.document.config)

		 // 5.  Configure Initial Camera Target:
		lookAtVew				= trunkVew			// default
		if let laStr			= fwGuts.document.config.string("lookAt"), laStr != "",
		  let  laPart 			= rootPart.find(path:Path(withName:laStr), inMe2:true) {		//xyzzy99
			lookAtVew			= find(part:laPart)
		}

		 // 6. Set LookAtNode's position
		let posn				= lookAtVew?.bBox.center ?? .zero
		let worldPosition		= lookAtVew?.scn.convertPosition(posn, to:scn) ?? .zero
		assert(!worldPosition.isNan, "About to use a NAN World Position")
		selfiePole.position			= worldPosition
	}

	 // MARK: - 4? locks
	func lockBoth(_ msg:String) {
		guard rootPart.lock(partTreeAs:msg, logIf:false) else {fatalError(msg+" couldn't get PART lock")}
		guard lock(vewTreeAs: msg, logIf:false) else {fatalError(msg+" couldn't get VIEW lock")}
	}
	func unlockBoth(_ msg:String) {
		unlock(vewTreeAs: msg, logIf:false)
		rootPart.unlock(partTreeAs:msg, logIf:false)
	}
	 // MARK: - 4.? Vew Locks
	/// Optain DispatchSemaphor for Vew Tree
	/// - Parameters:
	///   - lockName: get lock under this name. nil --> don't lock
	///   - logIf: log the description
	/// - Returns: Operation Succeeded
	func lock(vewTreeAs lockName:String?=nil, logIf:Bool=true) -> Bool {
		guard let lockName else {	return true		/* no lock needed */		}

		let u_name			= ppUid(self) + " '\(lockName)'".field(-20)
		atRve(3, {
			let val0		= rootVewLock.value ?? -99	/// (wait if <=0)
			if logIf && debugOutterLock {
				logd("//#######\(u_name)      GET Vew  LOCK: v:\(val0)" )
			}
		}() )

		 // === Get trunkVew DispatchSemaphore:
		while rootVewLock.wait(timeout:.now() + .seconds(10)) != .success {
//		while rootVewLock.wait(timeout:.distantFuture) != .success {
			 // === Failed to get lock:
			let val0		= rootVewLock.value ?? -99
			let msg			= "\(u_name)      FAILED Part LOCK: v:\(val0)"
			rootVewVerbose	? atRve(4, logd("//#######\(msg)")) :
							  nop
			fatalError(msg)	// for debug only
//			panic(msg)	// for debug only
//			return false
		}

		 // === Succeeded:
		assert(rootVewOwner==nil, "'\(lockName)' attempting to lock, but '\(rootVewOwner!)' still holds lock ")
		rootVewOwner 		= lockName
		atRve(3, {						/// AFTER GETTING:
			let val0		= rootVewLock.value ?? -99
			!logIf ? nop : logd("//#######" + u_name + "      GOT Vew  LOCK: v:\(val0)")
		}())
		return true
	}
	/// Release DispatchSemaphor for Vew Tree
	/// - Parameters:
	///   - lockName: get lock under this name. nil --> don't lock
	///   - logIf: log the description
	func unlock(vewTreeAs lockName:String?=nil, logIf:Bool=true) {
		guard lockName != nil else {	return 			/* no lock to return */	}
		assert(rootVewOwner != nil, "releasing VewTreeLock but 'rootVewOwner' is nil")
		assert(rootVewOwner == lockName!, "Releasing (as '\(lockName!)') Vew lock owned by '\(rootVewOwner!)'")
		let u_name			= ppUid(self) + " '\(rootVewOwner!)'".field(-20)
		atRve(3, {
			let val0		= rootVewLock.value ?? -99
			let msg			= "\(u_name)  RELEASE Vew  LOCK: v:\(val0)"
			!logIf ? nop	: logd("\\\\#######\(msg)")
		}())

		 // update name/state BEFORE signals
		rootVewOwnerPrev 	= rootVewOwner
		rootVewOwner 		= nil

		 // Unlock View's DispatchSemaphore:
		rootVewLock.signal()

		if debugOutterLock && logIf {
			let val0		= rootVewLock.value ?? -99
			atRve(3, logd("\\\\#######" + u_name + " RELEASED Vew  LOCK: v:\(val0)"))
		}
	}

	// MARK: - 9 Update Vew + :
	   /// Update the Vew Tree from Part Tree
	  /// - Parameter as:		-- name of lock owner. Obtain no lock if nil.
	 /// - Parameter log: 		-- log the obtaining of locks.
	func updateVewSizePaint(vewConfig:VewConfig?=nil, needsLock named:String?=nil, logIf log:Bool=true) { // VIEWS
		guard let fwGuts		= part.root?.fwGuts else {	fatalError("Paranoia 29872") }
		guard let fwGuts2		= rootVew?  .fwGuts else {	fatalError("Paranoia 23872") }
		assert(fwGuts === fwGuts2, "Paranoia i5205")
		var needsViewLock		= named		// nil if lock obtained
		let vRoot				= self
		let pRoot				= part.root!

/**/	SCNTransaction.begin()
		SCNTransaction.animationDuration = CFTimeInterval(0.15)	//0.3//0.6//

				 /// Is Part Tree dirty? If so, obtain lock
				 /// - Parameters:
				 ///   - dirty: kind of dirty (.vew, .size, or .paint) to check
				 ///    - viewLockName: Owner of lock; nil -> no lock needed
				 ///     - log: log the message
				 ///      - message: massage to log
				 ///      - Returns: Work
				func hasDirty(_ dirty:DirtyBits, needsViewLock viewLockName:inout String?, log:Bool, _ message:String) -> Bool {
					if pRoot.testNReset(dirty:dirty) {		// DIRTY? Get VIEW LOCK:
						guard let fwGuts = part.root?.fwGuts else {	fatalError("### part.root?.fwGuts is nil ###")		}

						 // Lock  _ALL_  root Vews:
						for rootVew in fwGuts.rootVews {
							guard rootVew.lock(vewTreeAs:viewLockName, logIf:log) else {
								fatalError("updateVewSizePaint(needsViewLock:'\(viewLockName ?? "nil")') FAILED to get \(viewLockName ?? "<nil> name")")
							}
						}
						viewLockName = nil		// mark gotten
						return true
					}
					return false
				}

		 // ----   Create   V I E W s   ---- // and SCN that don't ever change
		if hasDirty(.vew, needsViewLock:&needsViewLock, log:log,
			" _ reVew _   Vews (per updateVewSizePaint(needsLock:'\(needsViewLock ?? "nil")')") {

			if let vewConfig {					// Vew Configuration specifies open stuffss

				//let m1 = MaxOr()
				//let m2 = m1.pp(.uidClass)
				//let n1 = Vew()
				//let n3 = n1.fwClassName
				//let n2 = n1.pp(.uidClass)
				//let o1 = RootVew()
				//let o2 = o1.pp(.uidClass)
				//
				//let x = self.pp(.uidClass)
				//logd("abcdefg")

				atRve(6, log ? logd("updateVewSizePaint(vewConfig:\(vewConfig):....)") : nop)
				vRoot.openChildren(using:vewConfig)
			}
			atRve(6, log ? logd("updateVewSizePaint(vewConfig:nil:....)") : nop)
			  // Update Vew tree objects from Part tree
			 // (Also build a sparse SCN "entry point" tree for Vew tree)
/**/		pRoot.reVew(vew:vRoot, parentVew:nil)

			// should have created all Vews and one *-<name> in ptn tree
			pRoot.reVewPost(vew:vRoot)
		}
		 // ----   Adjust   S I Z E s   ---- //
		if hasDirty(.size, needsViewLock:&needsViewLock, log:log,
			" _ reSize _  Vews (per updateVewSizePaint(needsLock:'\(needsViewLock ?? "nil")')") {
			atRsi(6, log ? logd("rootPart.reSize():............................") : nop)

/**/		pRoot.reSize(vew:vRoot)				// also causes rePosition as necessary
			
			vRoot.bBox			|= BBox.unity		// insure a 1x1x1 minimum
								
			pRoot.rePosition(vew:vRoot)				// === only outter vew centered
			vRoot.orBBoxIntoParent()
			pRoot.reSizePost(vew:vRoot)				// ===(set link Billboard constraints)
	//		vRoot.bBox			= .empty			// Set view's bBox EMPTY
			atRsi(6, log ? logd("..............................................") : nop)
		}
		 // -----   P A I N T   Skins ----- //
		if hasDirty(.paint, needsViewLock:&needsViewLock, log:log,
			" _ rePaint _ Vews (per updateVewSizePaint(needsLock:'\(needsViewLock ?? "nil")')") {

/**/		pRoot.rePaint(vew:vRoot)				// Ports color, Links position

			 // THESE SEEM IN THE WRONG PLACE!!!
	//		pRoot.computeLinkForces(vew:vRoot) 		// Compute Forces (.force == 0 initially)
	//		pRoot  .applyLinkForces(vew:vRoot)		// Apply   Forces (zero out .force)
			pRoot .rotateLinkSkins (vew:vRoot)		// Rotate Link Skins
		}
		let unlockName			= named == nil ? nil :	// no lock wanted
								  needsViewLock == nil ? named :// we locked it!
								  nil							// we locked nothing
/**/	SCNTransaction.commit()
		for rootVew in fwGuts.rootVews {
			rootVew.unlock(vewTreeAs:unlockName, logIf:log)	// Release VIEW LOCK
		}
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig=params4aux) -> String {
//	override func pp(_ mode:PpMode, _ aux:FwConfig) -> String	{

		 // Report improper linking
		guard let fwGuts 					else {	return "fwGuts BAD"			}
		guard let slot 						else {	return "slot IS NIL"		}
		guard slot < fwGuts.rootVews.count 	else {	return "slot TOO BIG"		}
		guard fwGuts.rootVews[slot] == self else {	return "self inclorectly in rootVews"}

		return "<<<RootVew.pp(mode:\(mode), aux:[..\(aux.count)..])>>>"

		return ppDefault(self:self, mode:mode, aux:aux)// NO return super.pp(mode, aux)
	}
	  // MARK: - 16. Global Constants
	static let nullRoot			= {
		let rv					= RootVew()			/// Any use of this should fail
		rv.name					= "nullRoot"
		return rv
	}()
}
