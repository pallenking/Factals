//
//  FwScene.swift
//  Factals
//
//  Created by Allen King on 2/2/23.
//

import Foundation
import SceneKit

class FwScene : SCNScene {

	 /// animatePhysics is a posative quantity (isPaused is a negative)
	var animatePhysics : Bool {
		get {			return !isPaused										}
		set(v) {		isPaused = !v											}
	}
}
extension FwScene : SCNSceneRendererDelegate {
	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("\n<><><> 9.5.1: Update At Time       -> updateVewSizePaint"))
			let rVew			= (self.rootNode as! RootScn).rootVew!
			rVew.lockBoth("updateAtTime")
			rVew.updateVewSizePaint(needsLock:"renderLoop", logIf:false)		//false//true
			rVew.unlockBoth("updateAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
			let rVew			= (self.rootNode as! RootScn).rootVew!
			rVew .lockBoth("didApplyAnimationsAtTime")
			rVew .part.computeLinkForces(vew:rVew)
			rVew .unlockBoth("didApplyAnimationsAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
			let rVew			= (self.rootNode as! RootScn).rootVew!
			rVew.lockBoth("didSimulatePhysicsAtTime")
			rVew.part.applyLinkForces(vew:rVew)
			rVew.unlockBoth("didSimulatePhysicsAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			let rVew			= (self.rootNode as! RootScn).rootVew!
			rVew.lockBoth("willRenderScene")
			rVew.part.rotateLinkSkins(vew:rVew)
			rVew.unlockBoth("willRenderScene")
		}
	}
	   // ODD Timing:
	func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.@: Scenes Rendered -- NOP"))
	}
	func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
	}

}
// currently unused
extension FwScene : SCNPhysicsContactDelegate {
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		bug
	}
	func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
		bug
	}
	func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
		bug
	}
}
