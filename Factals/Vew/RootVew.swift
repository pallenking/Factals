//
//  RootVew.swift
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

class RootVew : Vew {
	weak var fwGuts : FwGuts!		// Owner

	var rootPart : RootPart		{	return part as! RootPart 					} //?? fatalError("RootVew.part is nil")}
	let rootVewLock 			= DispatchSemaphore(value:1)
	var rootVewOwner : String?	= nil
	var rootVewOwnerPrev:String? = nil
	var rootVewVerbose 			= false
	var trunkVew : Vew? {		 // Get  trunkVew  from reVew:
		return children.count > 0 ? children[0] : nil
	}
	var rootScn : RootScn

	 /// generate a new View, returning its index
	init() {
		rootScn					= RootScn()
		super.init(forPart:.null, scn:.null)
	}
	init(forPart rootPart:RootPart, rootScn f:RootScn) {
		rootScn					= f

		super.init(forPart:rootPart, scn:rootScn.scn)

		rootScn.rootVew			= self				// owner

		 // Set the base scn to comply as a Vew
		assert(scn === rootScn.scn, "set RootVew with new scn root")
		scn 					= rootScn.scn		// set RootVew with new scn root
	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}

	func pushControllersConfig(to c:FwConfig) {
		rootScn		.pushControllersConfig(to:c)
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
	//	if let fwGuts {
	//		let i				= fwGuts.rootVews.firstIndex { $0 === self		}
	//		rv					+= !fwGuts.rootVews.contains(self)	? "" :
	//										  ", NOT IN ROOTVEWS!"
	//		rv					+= part !== fwGuts.rootPart			? "" :
	//										  ", BAD ROOTVEW.PART!"
	//	}
	//	else {
	//		rv					+= 			  ", FWGUTS=NIL!"
	//	}
		return rv + "WTF LWHVW"
	}
}
