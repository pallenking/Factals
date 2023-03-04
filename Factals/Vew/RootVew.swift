//
//  RootVew.swift
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

class RootVew : Vew {			// inherits ObservableObject
	weak var fwGuts : FwGuts!			// Owner
	var slot	 	: Int?		= nil	// Owner's slot for me.

	 // 3D APPEARANCE
	var rootScn 	: RootScn			// Master tree
	 // Lighting, etc						// (in rootScn)
	var cameraScn	: SCNNode?	= nil
	var lightsScn	: [SCNNode]	= []
	var axesScn		: SCNNode?	= nil

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
	var trunkVew 	: Vew? 		{		 // Get  trunkVew  from reVew:
		return children.count > 0 ? children[0] : nil
	}

	 /// generate a new View, returning its index
	init() {
		rootScn					= RootScn()
		slot					= nil
		super.init(forPart:.null, scn:.null)
	}
	init(forPart rp:RootPart, rootScn rs:RootScn) {
		rootScn					= rs
		super.init(forPart:rp, scn:rs.scn)
		rootScn.rootVew			= self				// owner

		 // Set the base scn to comply as a Vew
		assert(scn === rootScn.scn, "set RootVew with new scn root")
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
		while rootVewLock.wait(timeout:.distantFuture) != .success {		//.distantFuture//.now() + waitSec		//let waitSec			= 2.0
			 // === Failed to get lock:
			let val0		= rootVewLock.value ?? -99
			let msg			= "\(u_name)      FAILED Part LOCK: v:\(val0)"
			rootVewVerbose	? atRve(4, logd("//#######\(msg)")) :
							  nop
			panic(msg)	// for debug only
			return false
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
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		let rv					= super.pp(mode, aux)

		 // Report improper linking
		guard let fwGuts 					else {	return rv + "fwGuts BAD"	}
		guard let slot 						else {	return rv + "slot IS NIL"	}
		guard slot < fwGuts.rootVews.count 	else {	return rv + "slot TOO BIG"	}
		guard fwGuts.rootVews[slot] == self else {	return rv + "self inclorectly in rootVews"}

		return rv
	}
	  // MARK: - 16. Global Constants
	static let nullRoot			= RootVew()			/// Any use of this should fail
}
