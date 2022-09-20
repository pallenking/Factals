//
//  RootVew.swift
//  FooDocTry3
//
//  Created by Allen King on 9/19/22.
//

import SceneKit
class RootVew : Vew {
	weak
	 var fwGuts : FwGuts!
	let rootVewLock 			= DispatchSemaphore(value:1)
	var rootVewOwner : String?	= nil
	var rootVewOwnerPrev:String? = nil
	var rootVewVerbose 			= false
	var trunkVew : Vew? {		 // Get  trunkVew  from reVew:
		let children			= rootVew.children
		return children.count > 0 ? children[0] : nil
	}
	init(forPart part:Part?=nil, scn:SCNNode?=nil) {
			//RootVew
		super.init(forPart:part, scn:scn)
	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}

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
//			wait   			? atRve(4, logd("//#######\(msg)")) :
			rootVewVerbose	? atRve(4, logd("//#######\(msg)")) :
							  nop
			panic(msg)	// for debug only
			return false
		}

		 // === Succeeded:
		assert(rootVewOwner==nil, "\(lockName) Locking, but previous owner '\(rootVewOwner!)' lingers ")
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
	 // MARK: 9.3.2 Look At Spot
	var lookAtVew  : Vew?		= nil					// Vew we are looking at
//	var pole					= SCNNode()				// focus of mouse rotator
	var lastSelfiePole 			= SelfiePole()			// init to default

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv					= ""
		switch mode! {
		case .phrase:
			rv 					+= "FwScn:\(ppUid(self))"
		case .short:
			rv					+= "\(pp(.phrase)) scnView:\(scnView.pp(.phrase)) scnScene:\(scnScene.pp(.phrase))"
		case .line:
			rv 					+= "\(pp(.short)) rootScn:\(rootScn.pp(.phrase))"
									// missing uid,	fwGuts, and animatePhysics
		default:
bug//		return FwAny.pp(mode, aux)
// /// This extension provides uniform default values.
//extension FwAny  {
//	 // Default implementation, with default values:
//	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig=DOClog.params4aux) -> String {
//		return pp(mode, aux)
//	}
//	 // N.B: If this loops forever, check self's class .pp protocol
//}
		}
		return rv
	}

}
