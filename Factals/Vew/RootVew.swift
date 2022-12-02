//
//  RootVew.swift
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

class RootVew : Vew {
	weak
	 var fwGuts : FwGuts!		// Owner

	var rootPart : RootPart		{	return part as! RootPart 					} //?? fatalError("RootVew.part is nil")}
	let rootVewLock 			= DispatchSemaphore(value:1)
	var rootVewOwner : String?	= nil
	var rootVewOwnerPrev:String? = nil
	var rootVewVerbose 			= false
	var trunkVew : Vew? {		 // Get  trunkVew  from reVew:
		return children.count > 0 ? children[0] : nil
	}
	var fwScn : FwScn
	var eventCentral : EventCentral

	 // MARK: x.3.2 Look At Spot
	var lookAtVew	   : Vew?	= nil						// Vew we are looking at
	var lastSelfiePole : SelfiePole!						// init to default

	 /// generate a new View, returning its index
	init() {
		fwScn					= .null
		eventCentral			= .null
		super.init(forPart:.null, scn:fwScn.scnScene.rootNode)
		lastSelfiePole			= SelfiePole(rootVew:self)
	}
	init(forPart rootPart:RootPart, scnScene:SCNScene) {
		fwScn					= FwScn(scnScene:scnScene)
		eventCentral			= EventCentral()
		fwScn.scnScene.physicsWorld.contactDelegate = eventCentral

		super.init(forPart:rootPart, scn:scnScene.rootNode)

		eventCentral.rootVew	= self						// owner
		fwScn.rootVew			= self						// owner

		 // Set the base scn to comply as a Vew
		assert(scn === fwScn.scnScene.rootNode, "set RootVew with new scn root")
		scn 					= fwScn.scnScene.rootNode	// set RootVew with new scn root
		lastSelfiePole			= SelfiePole(rootVew:self)
	}
	required init(from decoder: Decoder) throws {fatalError("init(from:) has not been implemented")	}

	func pushControllersConfig(to c:FwConfig) {
		eventCentral.pushControllersConfig(to:c)
		fwScn		.pushControllersConfig(to:c)
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
//			wait   			? atRve(4, logd("//#######\(msg)")) :
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
	// MARK: -xxxx Camera xform
	/// Compute Camera Transform from pole config
	/// - Parameters:
	///   - from: defines direction of camera
	///   - message: for logging only
	///   - duration: for animation
	func updatePole2Camera(duration:Float=0.0, reason:String?=nil) { //updateCameraRotator
		let rootVew				= self			//rootVew.fwGuts.rootVewOf(fwScn:self)
		let fwScn				= fwScn
		let cameraScn			= fwScn.touchCameraScn()

		fwScn.zoom4fullScreen(selfiePole:rootVew.lastSelfiePole, cameraScn:cameraScn)

		if duration > 0.0,
		  fwGuts.document.config.bool("animatePan") ?? false {
			SCNTransaction.begin()			// Delay for double click effect
			atRve(8, fwGuts.logd("  /#######  animatePan: BEGIN All"))
			SCNTransaction.animationDuration = CFTimeInterval(0.5)
			 // 181002 must do something, or there is no delay
			cameraScn.transform *= 0.999999	// virtually no effect
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()			// Animate Camera Update
				atRve(8, self.fwGuts.logd("  /#######  animatePan: BEGIN Completion Block"))
				SCNTransaction.animationDuration = CFTimeInterval(duration)

				cameraScn.transform = rootVew.lastSelfiePole.transform

				atRve(8, self.fwGuts.logd("  \\#######  animatePan: COMMIT Completion Block"))
				SCNTransaction.commit()
			}
			atRve(8, fwGuts.logd("  \\#######  animatePan: COMMIT All"))
			SCNTransaction.commit()
		}
		else {
			cameraScn.transform = rootVew.lastSelfiePole.transform
			print("cameraScn:\(cameraScn.pp(.uid)) \(reason ?? "no reason"), tramsform:\n\(cameraScn.transform.pp(.tree)))")
		}
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		let rv					= super.pp(mode, aux)
	//	if let fwGuts			= fwGuts {
	//		let i				= fwGuts.rootVews.firstIndex { $0 === self		}
	//		rv					+= !fwGuts.rootVews.contains(self)	? "" :
	//										  ", NOT IN ROOTVEWS!"
	//		rv					+= part !== fwGuts.rootPart			? "" :
	//										  ", BAD ROOTVEW.PART!"
	//	}
	//	else {
	//		rv					+= 			  ", FWGUTS=NIL!"
	//	}
		return rv
	}
	  // MARK: - 16. Global Constants
	static let null3 			= RootVew(forPart: RootPart(), scnScene: SCNScene())
}
