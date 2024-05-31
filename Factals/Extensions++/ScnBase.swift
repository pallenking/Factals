//
//  ScnBase.swift
//  Factals
//
//  Created by Allen King on 2/2/23.
//

import Foundation
import SceneKit

class ScnBase : NSObject {
	var scnScene : SCNScene
	var tree	 : SCNNode?
	{	didSet {				setRootNodeChild1(from:tree)					}}
	func setRootNodeChild1 (from:SCNNode?) {
		let scnSceneRootNode 	= self.scnScene.rootNode	// from SCNScene's binding
		scnSceneRootNode.name	= "ROOT"
		scnSceneRootNode.removeAllChildren()
		guard let tree 			else { return	}			// no tree, no children
		scnSceneRootNode.addChildNode(tree)
	}
	var scnView	 : SCNView?					// SCNView  of this ScnBase
	weak
	 var vewBase : VewBase?					// Delegate (of these ScnBase)

	var nextIsAutoRepeat : Bool = false 	// filter out AUTOREPEAT keys
	var mouseWasDragged			= false		// have dragging cancel pic
	var lastPosition : SCNVector3? = nil	// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	 // MARK: - 3.1 init
	init(scnScene s:SCNScene?=nil) {				// ScnBase(tree
		self.scnScene			= s ?? SCNScene()	// get scene
//		atRve(8 vews.factalsModel.logd("/\\/\\/\\/ scnScene=\(scnScene.pp(.uidClass)), rootNode=\(scnScene.rootNode.pp(.line))"))

 		super.init()
		setRootNodeChild1 (from:tree)
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
}

extension ScnBase {		// lights and camera
	 // MARK: - 4.1 Lights
	func checkLights() {
		touchLight("*-omni1",  .omni, position:SCNVector3(0, 0, 15))
		touchLight("*-amb1",.ambient,color:NSColor.darkGray)
		touchLight("*-amb2",.ambient,color:NSColor.white, intensity:500)				//blue//
		touchLight("*-omni2",  .omni,color:NSColor.green, intensity:500)				//blue//

		func touchLight(_ name:String, _ lightType:SCNLight.LightType, color:Any?=nil,
					intensity:CGFloat=100, position:SCNVector3?=nil) {
			guard let tree 		else { return									}
			if tree.find(name:name) == nil {
										 // Light's SCNNode:
				let scn4light 	= SCNNode()
				scn4light.name	= name				// arg 1
				if let position {
					scn4light.position = position	// arg 5
				}
				tree.addChildNode(scn4light)
										 // Light:
				let light		= SCNLight()
				light.type 		= lightType			// arg 2
				if let color	= color {
					light.color = color				// arg 3
				}
				light.intensity = intensity			// arg 4
				scn4light.light	= light
			}
		}
	}
	 // MARK: - 4.2 Camera
/*
	Concepts:  https://learnopengl.com/Getting-started/Coordinate-Systems
	The camera is positioned in the world with the camera transform

				3D MODEL SPACE       camera
	model             v                ^         LOCAL
	 coords:          |                |					getModelViewMatrix()
				\ ∏ Tmodel i/    trans = cameraScn.transform
				 \  Matrix /           |
	world    =====    v   =============*============ WORLD		[x, y, z, 1]
	 coords:          |
			   \ trans.inverse /
				\   Matrix    /
	camera   ======   v    ========================= EYE			[x, y, z, 1]
	 coords:          |
				\ PROJECTION /
				 \  Matrix  /pm
	clip     ======   v    ========================= ?        	[x, y, 1]
	 coords:          |
				\ Perspective/         (not used)
				 \ division /
	device   ======   v    ========================= RETINA:		[x, y, 1]
	 coords:          |								CLIP
				 \ Viewport /  A = | fx 0  cx |  Intrinsic Matrix
				  \ Matrix /       | 0  fy cy |  f = focal length
	window            v			 			   c = center of image
	 coords:          |
			 ====== SCREEN ========================= SCREEN		[x, y]
 */
/*
			View.convert(_:NSPoint, from:NSView?)
- (NSPoint)convertPoint:(NSPoint)point fromView:(nullable NSView *)view;



Vew.swift:
           localPosition   (of:SCNVector3,inSubVew:Vew)          -> SCNVector3			REFACTOR
		   convert		   (bBox:BBox,       from:Vew)	         -> BBox
SceneKit:
		   convertPosition (_:SCNVector3,    from:SCNNode?)      -> SCNVector3		SCNNode.h
FACTALS ->		nil ==> from scene’s WORLD coordinates.	FAILS _/
	       convertVector   (_:SCNVector3,    from:SCNNode?)      -> SCNVector3		SCNNode.h
	       convertTransform(_:SCNMatrix4,    from:SCNNode?)      -> SCNMatrix4		SCNNode.h
NSView:
		   convert         (_:NSPoint,       from:NSView?)       -> NSPoint			<== SwiftFactals (motionFromLastEvent)
SWIFTFACTALS ->	nil ==> from WINDOW coordinates.		WORKS _/
		   convert		   (_:NSSize,        from:NSView?)       -> NSSize
	       convert         (_:NSRect,        from:NSView?)       -> NSRect
Quartzcore Calayer: UIView:
		   convertPoint    (_:CGPoint,	     fromLayer:CALayer?) -> CGPoint
		   convertRect     (_:CGRect, 	     fromLayer:CALayer?) -> CGRect
		   convertTime     (_:CFTimeInterval,fromLayer:CALayer?) -> CFTimeInterval,
SpriteKit:
		   convertPoint    (fromView:CGPoint)			         -> CGPoint
		   convertPoint    (fromScreen:NSPoint) 		         -> NSPoint
UIView:
		   convert         (_:CGPoint,     from:UIView?)         -> CGPoint
		   convert         (_:CGRect,      from:UIView?)         -> CGRect
AppKit:
		   convert         (_:NSFont                          )  -> NSFont

			convertPointFromBacking:

		   convert        (              to: UnitType)							UnitType conforms to Dimension

https://groups.google.com/a/chromium.org/g/chromium-dev/c/BrmJ3Lt56bo?pli=1
- convertPointToBase:
- convertSizeToBase:
- convertSizeFromBase:
- convertRectToBase:
- convertRectFromBase:

 */
	func checkCamera() {
		let name				= "*-camera"
		guard let tree 			else { return									}
		let camNode				= tree.find(name:name, maxLevel:1) ?? { // use old
			 // New camera system:
			let rv				= SCNNode()
			rv.name				= name
			rv.position 		= SCNVector3(0, 0, 55)	// HACK: must agree with updateCameraRotator
			tree.addChildNode(rv)

			 // Just make a whole new camera system from scratch
			let camera			= SCNCamera()
			camera.name			= "SCNCamera"
			rv.camera			= camera

			let perspective		= false
			camera.wantsExposureAdaptation = false				// determines whether SceneKit automatically adjusts the exposure level.
			camera.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
			camera.exposureAdaptationDarkeningSpeedFactor = 1
			camera.automaticallyAdjustsZRange = true			//cam.zNear				= 1
			// Check the condition to determine the camera mode
			camera.zNear 		= 0.1 	// 1    Set the near clipping distance
			camera.zFar 		= 1000	// 100  Set the far clipping distance
			camera.fieldOfView 	= 60	// Set the field of view, in degrees
			if !perspective {
				 // Orthographic (non-perspective) mode
				camera.usesOrthographicProjection = true
				let orthoScale: CGFloat = 10.0 // Adjust this value based on your scene's size
				camera.orthographicScale = orthoScale
			}
			// // Check the condition to determine the camera mode
			//if false {
			//	// Perspective mode
			//	camera.usesOrthographicProjection = false
			//	camera.zNear 	= 0.1 	// 1    Set the near clipping distance
			//	camera.zFar 	= 1000	// 100  Set the far clipping distance
			//	camera.fieldOfView = 60	// Set the field of view, in degrees
			//} else {
			//	// Orthographic mode
//			//	camera.usesOrthographicProjection = true
			//	let orthoScale: CGFloat = 10.0 // Adjust this value based on your scene's size
			//	camera.orthographicScale = orthoScale
			//}
			return rv
		}()
		//	camera.wantsExposureAdaptation = false				// determines whether SceneKit automatically adjusts the exposure level.
		//	camera.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
		//	camera.exposureAdaptationDarkeningSpeedFactor = 1
		//	camera.automaticallyAdjustsZRange = true			//cam.zNear				= 1
	}

	  // MARK: - 4.3 Axes
	 // ///// Rebuild the Axis Markings
	func touchAxesScn() {			// was updatePole()
		guard let tree			else { return									}
		let name				= "*-axis"

		 // Already exist?
		if let rv 				= tree.find(name:name) {
			return
		}
		let axesLen				= SCNVector3(15,15,15)	//SCNVector3(5,15,5)
		let axesScn				= SCNNode()				// New pole
		axesScn.categoryBitMask	= FwNodeCategory.adornment.rawValue
		tree.addChild(node:axesScn)
		axesScn.name				= name

		 // X/Z Poles (thinner)
		let r : CGFloat			= 0.03
		for i in 0..<2 {
			let arm 			= SCNNode(geometry:SCNCylinder(radius:r, height:axesLen.x))
			arm.categoryBitMask = FwNodeCategory.adornment.rawValue
			arm.transform		= SCNMatrix4Rotate(SCNMatrix4.identity, CGFloat.pi/2,
								(i == 0 ? 1 : 0), 0, (i == 1 ? 1 : 0)  )
			arm.name			= "s-Cyl\(i)"
			arm.color0			= .lightGray
			arm.color0(emission:systemColor)
			axesScn.addChild(node:arm)

			let nTics			= [axesLen.x, axesLen.z][i]
			addAxisTics(toNode:arm, from:-nTics/2, to:nTics/2, r:r) // /////////////
		}
		 // Y Pole (thicker)
		let upPole 				= SCNNode(geometry:SCNCylinder(radius:r*2, height:axesLen.y))
		upPole.categoryBitMask	= FwNodeCategory.adornment.rawValue
		upPole.position.y		+= axesLen.y / 2
		upPole.name				= "s-CylT"
		upPole.color0			= .lightGray
		upPole.color0(emission:systemColor)
		addAxisTics(toNode:upPole, from:0, to:axesLen.y, r:2*r) // /////////////////
		axesScn.addChild(node:upPole)


		 // Experimental label
		let geom				= SCNText(string:"Origin", extrusionDepth:1)
		geom.containerFrame		= CGRect(x:-0.5, y:-0.5, width:1, height:1)
		let label		 		= SCNNode(geometry:geom)
		label.name				= "Origin"
		label.color0			= .black
		label.color0(emission:systemColor)
		axesScn.addChild(node:label)


		 // Origin Node is a pyramid
		let origin		 		= SCNNode(geometry:SCNSphere(radius:r*4))
		origin.categoryBitMask	= FwNodeCategory.adornment.rawValue
		origin.name				= "s-Pyr"
		origin.color0			= .black
		origin.color0(emission:systemColor)									//let origin	  = SCNNode(geometry:SCNPyramid(width:0.5, height:0.5, length:0.5))
		axesScn.addChild(node:origin)
	}																		//origin.rotation = SCNVector4(x:0, y:1, z:0, w:.pi/4)
	func addAxisTics(toNode:SCNNode, from:CGFloat, to:CGFloat, r:CGFloat) {
		if true || vewBase?.factalsModel?.fmConfig.bool("axisTics") ?? false {
			let pos				= toNode.position
			for j in Int(from)...Int(to) where j != 0 {
				let tic			= SCNNode(geometry:SCNSphere(radius:2*r))
				tic.categoryBitMask	= FwNodeCategory.adornment.rawValue
				tic.name		= "tic\(j)"
				tic.transform 	= SCNMatrix4MakeRotation(.pi/2, 1, 0, 0)
				tic.position 	= SCNVector3(0, CGFloat(j), 0) - pos
				tic.scale		= SCNVector3(1, 1, 0.5)
				tic.color0		= .black
				tic.color0(emission:systemColor)
				toNode.addChild(node:tic)
			}
		}
	}

//	 // MARK: 4.4 - Look At Updates
//	func movePole(toWorldPosition wPosn:SCNVector3) {
//		guard let factalsModel		= vews?.factalsModel else {		return						}
//		let localPoint			= SCNVector3.origin		//falseF ? bBox.center : 		//trueF//falseF//
//		let wPosn				= rootNode.convertPosition(localPoint, to:rootNode)
//
/////		assert(pole.worldPosition.isNan == false, "Pole has position = NAN")
//
//		let animateIt			= factalsModel.document.config.bool_("animatePole")
//		if animateIt {	 // Animate 3D Cursor Pole motion"∫
//			SCNTransaction.begin()
////			atRve(8, logg("  /#######  SCNTransaction: BEGIN"))
//		}
//
/////		pole.worldPosition		= wPosn
//
//		if animateIt {
//			SCNTransaction.animationDuration = CFTimeInterval(1.0/3)
//			atRve(8, factalsModel.logd("  \\#######  SCNTransaction: COMMIT"))
//			SCNTransaction.commit()
//		}
//	}
	//
//	func commitCameraMotion(duration:Float=0, reason:String?=nil) -> SCNMatrix4 {
//	//	selfiePole.zoom			= zoom4fullScreen()
//		let transform			= selfiePole.transform
//		return transform
//	}
	/// Compute Camera Transform from pole config
	/// - Parameters:
	///   - from: defines direction of camera
	///   - message: for logging only
	///   - duration: for animation
	func updatePole2Camera(duration:Float=0.0, reason:String?=nil) { //updateCameraRotator
bug;
		guard let cameraScn		= vewBase?.cameraScn else {return }

		zoom4fullScreen()
//		zoom4fullScreen(selfiePole:selfiePole, cameraScn:cameraScn)
		guard let vews		= self.vewBase else { fatalError("vews is nil")}

		let animate				= vews.factalsModel?.fmConfig.bool("animatePan") ?? false
		if animate && duration > 0.0 {
			SCNTransaction.begin()			// Delay for double click effect
// TYP		atRve(8, vews.factalsModel.logd("  /#######  animatePan: BEGIN All"))
/*CherryPick2023-0520:*/atRve(8, vews.partBase.logd("  /#######  animatePan: BEGIN All"))

			SCNTransaction.animationDuration = CFTimeInterval(0.5)
			 // 181002 must do something, or there is no delay
			cameraScn.transform	*= 0.999999	// virtually no effect
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()			// Animate Camera Update
bug//			atRve(8, self.vews!.vews!.factalsModel.logd("  /#######  animatePan: BEGIN Completion Block"))
				SCNTransaction.animationDuration = CFTimeInterval(duration)

				cameraScn.transform = self.vewBase!.selfiePole.transform()

bug//			atRve(8, self.vews!.factalsModel.logd("  \\#######  animatePan: COMMIT Completion Block"))
				SCNTransaction.commit()
			}
bug//		atRve(8, vews.factalsModel.logd("  \\#######  animatePan: COMMIT All"))
			SCNTransaction.commit()
		}
		else {
			cameraScn.transform = vews.selfiePole.transform()
		}
	}
		
	 /// Determine zoom so that all parts of the scene are seen.
	func zoom4fullScreen() -> CGFloat {		//selfiePole:SelfiePole, cameraScn:SCNNode
		guard let vewBase  else {	fatalError("RootScn.vews is nil")}

		 //		(ortho-good, check perspective)
		let rootVewBbInWorld	= vewBase.tree.bBox //BBox(size:3, 3, 3)//			// in world coords
		let world2eye			= SCNMatrix4Invert(vewBase.cameraScn?.transform ?? .identity)	//vews.scn.convertTransform(.identity, to:nil)	// to screen coordinates
		let rootVewBbInEye		= rootVewBbInWorld.transformed(by:world2eye)
		let rootVewSizeInEye	= rootVewBbInEye.size
		let nsRect				= scnView?.frame ?? NSRect(x:9,y:9,width:200, height:200)

		 // Orientation is "Height Dominated"
		var zoomRv				= rootVewSizeInEye.x	// 1 ==> unit cube fills screen
		 // Is side going to be clipped off?
		let ratioHigher			= nsRect.height / nsRect.width
		if rootVewSizeInEye.y > rootVewSizeInEye.x * ratioHigher {
			zoomRv				*= ratioHigher
		}
		if rootVewSizeInEye.x * nsRect.height < nsRect.width * rootVewSizeInEye.y {
			 // Orientation is "Width Dominated"
			zoomRv				= rootVewSizeInEye.y
			 // Is top going to be clipped off?
			if rootVewSizeInEye.x > rootVewSizeInEye.y / ratioHigher {
				zoomRv				/= ratioHigher
			}
		}
		return zoomRv
	}
//
//	func convertToRoot(windowPosition:NSPoint) -> NSPoint {
//		let windowPositionV3 : SCNVector3 = SCNVector3(windowPosition.x, windowPosition.y, 0)
//											// BUGGY:
//		let   rootPositionV3 : SCNVector3 = scn.convertPosition(windowPositionV3, from:nil)
//		return NSPoint(x:rootPositionV3.x, y:rootPositionV3.y)
//
//		let
//
//NSView:
//		   convert         (_:NSPoint,       from:NSView?)       -> NSPoint			<== SwiftFactals (motionFromLastEvent)
//SWIFTFACTALS ->	nil ==> from WINDOW coordinates.		WORKS _/
//
//
//	}

	  /// Build  Vew and SCN  tree from  Part  tree for the first time.
	 ///   (This assures updateVewNScn work)
	func createVewNScn(slot:Int, vewConfig:VewConfig? = nil) { 	// Make the  _VIEW_  from Experiment
		guard let vewBase			 		 else {	fatalError("scnBase.vews is nil")}	//factalsModel.rootVewOf(rootScn:self)
		let partBase		= 				vewBase.partBase

		 // Paranoia
		assert(vewBase.tree.name == "_ROOT","Paranoid check: vewBase.name=\(vewBase.tree.name) !=\"_ROOT\"")
		assert(partBase.tree.name == "ROOT","Paranoid check: vews.part.name=\(partBase.tree.name) !=\"ROOT\"")
//		assert(tree.children.count == 1, "Paranoid check: parts has \(tree .children.count) children, !=1")

		 // 1. 	GET LOCKS					// PartTree
		let lockName			= "createVew[\(slot)]"
		guard partBase.lock(for:lockName) else {
			fatalError("createVews couldn't get PART lock")		// or
		}		          					// VewTree
		guard vewBase.lock(for:lockName) else {
			fatalError("createVews  couldn't get VIEW lock")
		}



bug;//	partBase.tree.dirtySubTree(gotLock:true, .vsp)		// DEBUG ONLY

		 // 2. Update Vew and Scn Tree
/**/	vewBase.updateVewSizePaint(vewConfig:vewConfig)		// tree(Part) -> tree(Vew)+tree(Scn)
		vewBase.setupLightsCamerasEtc()

		 // Do one, just for good luck
//bug;	commitCameraMotion(reason:"to createVewNScn")
//		updatePole2Camera(reason:"to createVewNScn")

		// 7. RELEASE LOCKS for PartTree and VewTree:
		vewBase.unlock(	for:lockName)
		partBase.unlock(for:lockName)
	}
}

 // Kinds of Nodes
enum FwNodeCategory : Int {
	case byDefault				= 0x1		// default unpicable (piced by system)
	case picable 				= 0x2		// picable
	case adornment				= 0x4		// unpickable e.g. bounding box
	case collides				= 0x8		// Experimental
}

//
extension ScnBase : SCNSceneRendererDelegate {			// Set in contentView SceneView
	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async {
			guard let tree		= self.tree	else { return						}
			atRsi(8, tree.logd("\n<><><> 9.5.1: STARTING Update At Time       -> updateVewSizePaint"))
			let vewBase			= self.vewBase!
			vewBase.lockBoth(for: "updateAtTime")
			vewBase.updateVewSizePaint(logIf:true)		//false//true
//			rVew.updateVewSizePaint(needsLock:"renderLoop", logIf:true)		//false//true
			vewBase.unlockBoth(for: "updateAtTime")
			atRsi(8, tree.logd("<><><> 9.5.1: ENDING   Update At Time       -> updateVewSizePaint"))
		}
	}
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
//		DispatchQueue.main.async {
//			guard let tree		= self.tree	else { return						}
//			atRsi(8, self.tree.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
//			let rVew			= self.vews!
//			rVew .lockBoth("didApplyAnimationsAtTime")
////			rVew .part.computeLinkForces(vew:rVew)
//			rVew .unlockBoth("didApplyAnimationsAtTime")
//		}
	}
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
//		DispatchQueue.main.async {
//			guard let tree		= self.tree	else { return						}
//			atRsi(8, self.tree.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
//			let rVew			= self.vews!
//			rVew.lockBoth("didSimulatePhysicsAtTime")
////			rVew.part.applyLinkForces(vew:rVew)
//			rVew.unlockBoth("didSimulatePhysicsAtTime")
//		}
	}
	func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
			guard let tree		= self.tree	else { return						}
			atRsi(8, tree.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			let vewBase			= self.vewBase!
			vewBase.lockBoth(for: "willRenderScene")
			vewBase.partBase.tree.rotateLinkSkins(vew:vewBase.tree)
			vewBase.unlockBoth(for: "willRenderScene")
		}
	}
	   // ODD Timing:
//	func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//		atRsi(8, self.tree.logd("<><><> 9.5.@: ScnBase Rendered -- NOP"))
//	}
//	func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
//		atRsi(8, self.tree.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
//	}
	 // MARK: - 13. IBActions
	func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
		let duration			= Float(1)
		guard let vewBase 		= vewBase else { print("processEvent.rootVews[?] is nil"); return false}
		let slot				= vewBase.slot ?? -1
		let factalsModel		= vewBase.factalsModel		// why ! ??

		switch nsEvent.type {

		  //  ====== KEYBOARD ======
		 //
		case .keyDown:
			if nsEvent.isARepeat {	return false }		// Ignore repeats
			nextIsAutoRepeat 	= true
			guard let char : String	= nsEvent.charactersIgnoringModifiers else { return false}
			assert(char.count==1, "Slot\(slot): multiple keystrokes not supported")

/**/		if vewBase.processEvent(nsEvent:nsEvent, inVew:vew) == false,
			  char != "?"  {		// okay for "?" to get here
				atEve(3, print("Slot\(slot):   ==== nsEvent not processed\n\(nsEvent)"))
			}
		case .keyUp:
			assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
			nextIsAutoRepeat 	= false
			let _				= factalsModel != nil && factalsModel!.processEvent(nsEvent:nsEvent, inVew:vew)

		  //  ====== LEFT MOUSE ======
		 //
		case .leftMouseDown:
			beginCameraMotion(with:nsEvent)
			if let v		= modelPic(with:nsEvent) {
				print("leftMouseDown pic's Vew:\(v.pp(.short))")
			}
			commitCameraMotion(duration:duration, reason:"Left mouseDown")
		case .leftMouseDragged:	// override func mouseDragged(with nsEvent:NSEvent) {
			beginCameraMotion(with:nsEvent)
			mouseWasDragged 	= true			// drag cancels pic
			spinNUp(with:nsEvent)			// change Spin and Up of camera
			commitCameraMotion(reason:"Left mouseDragged")
		case .leftMouseUp:	// override func mouseUp(with nsEvent:NSEvent) {
			beginCameraMotion(with:nsEvent)
			if !mouseWasDragged {			// UnDragged Up -> pic
				if let vew		= modelPic(with:nsEvent) {
					vewBase.lookAtVew = vew			// found a Vew: Look at it!
				}
			}
			mouseWasDragged = false
			commitCameraMotion(duration:duration, reason:"Left mouseUp")

		  //  ====== CENTER MOUSE (scroll wheel) ======
		 //
		case .otherMouseDown:	// override func otherMouseDown(with nsEvent:NSEvent)	{
			beginCameraMotion(with:nsEvent)
			commitCameraMotion(duration:duration, reason:"Slot\(slot): Other mouseDown")
		case .otherMouseDragged:	// override func otherMouseDragged(with nsEvent:NSEvent) {
			beginCameraMotion(with:nsEvent)
			spinNUp(with:nsEvent)
			commitCameraMotion(reason:"Slot\(slot): Other mouseDragged")
		case .otherMouseUp:	// override func otherMouseUp(with nsEvent:NSEvent) {
			beginCameraMotion(with:nsEvent)
			atEve(9, print("\( vewBase.cameraScn?.transform.pp(PpMode.tree) ?? " cam=nil! ")"))
			commitCameraMotion(duration:duration, reason:"Slot\(slot): Other mouseUp")

		  //  ====== CENTER SCROLL WHEEL ======
		 //
		case .scrollWheel:
			beginCameraMotion(with:nsEvent)
			let d				= nsEvent.deltaY
			let delta : CGFloat	= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
			vewBase.selfiePole.zoom *= delta
			//let s				= vews.selfiePole
			//print("Slot\(slot): processEvent(type:  .scrollWheel  ) found pole:\(s.pp(.uid))=\(s.pp())")
			commitCameraMotion(duration:duration, reason:"Scroll Wheel")

		  //  ====== RIGHT MOUSE ======			Right Mouse not used
		 //
		case .rightMouseDown:
			 // 2023-0305: nop, but it calls commitCameraMotion to update picture
			beginCameraMotion(with:nsEvent)
			commitCameraMotion(duration:duration, reason:"Left mouseDown")
		case .rightMouseDragged:	nop
		case .rightMouseUp:
			beginCameraMotion(with:nsEvent)
			commitCameraMotion(duration:duration, reason:"Left mouseDown")

		  //  ====== TOUCH PAD ======(no touchesBegan, touchesMoved, touchesEnded)
		case .magnify:			bug
		case .smartMagnify:		bug
		case .swipe:			bug
		case .rotate:			bug
		case .gesture:			bug
		case .directTouch:		bug
		case .tabletPoint:		bug
		case .tabletProximity:	bug
		case .pressure:			bug
		case .changeMode:		bug

		case .beginGesture:	bug	// override func touchesBegan(with event:NSEvent) {
//			let touchs			= nsEvent.touches(matching:.began, in:scnView)
//			for touch in touchs {
//				let _:CGPoint	= touch.location(in:nil)
//			}
		case .mouseMoved: bug
//			let touchs			= nsEvent.touches(matching:.moved, in:scnView)
//			for touch in touchs {
//				let prevLoc		= touch.previousLocation(in:nil)
//				let loc			= touch.location(in:nil)
//				atEve(3, (print("\(prevLoc) \(loc)")))
//			}
		case .endGesture: bug	//override func touchesEnded(with event:NSEvent) {
//			let touchs			= nsEvent.touches(matching:.ended, in:scnView)
//			for touch in touchs {
//				let _:CGPoint	= touch.location(in:nil)
//			}
		default:
			print("Slot\(slot): processEvent(type:\(nsEvent.type)) NOT PROCESSED by RootScn")
			return false
		}
		return true
	}
	// MARK: - PIC
	
					  // ///////////////////////// //////////// //
					 // ///                   /// //
					// ///		 PIC         /// //
				   // ///                   /// //
	 // //////////// ///////////////////////// //
	
	/// Choose the Vew of v containing mouse point
	/// - Parameter n: an NSEvent (else current NSEvent)
	/// - Parameter v: specific base Vew (else check all rootVews)
	/// - Returns: The Vew of the part pressed
	func modelPic(with nsEvent:NSEvent, inVewBase vb:VewBase? = nil) -> Vew? {
		let vewBases2check : [VewBase] = vb != nil ? [vb!] :			// use ARG
										 vewBase!.factalsModel.vewBases	// check all
		for vewBase in vewBases2check {
			if let picdVew		= findVew(nsEvent:nsEvent, inVewBase:vewBase) {
				 // PART pic'ed, DISPATCH to it!
				if picdVew.part.processEvent(nsEvent:nsEvent, inVew:picdVew) {
					return picdVew		// Successfully Completed
				}
			}
		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}

	func f2(_ p:NSPoint) -> String { String(format:"(%.1f, %.1f)", p.x, p.y) }

	func findVew(nsEvent:NSEvent, inVewBase vewBase:VewBase) -> Vew? {
		 // Find vews of NSEvent
		guard let contentView 	= NSApp.keyWindow?.contentView else { return nil}
		let locationInRoot		= contentView.convert(nsEvent.locationInWindow, from:nil)	// nil => from window coordinates //view

		guard let tree			= vewBase.scnBase.tree   else { return nil		}
		guard let scnView		= vewBase.scnBase.scnView else { fatalError("vewBase.scnBase.scnView is nil")	}
		guard let slot 			= vewBase.slot			 else { return nil		}

		let configHitTest : [SCNHitTestOption:Any]? = [
			.backFaceCulling	:true,	// ++ ignore faces not oriented toward the camera.
			.boundingBoxOnly	:false,	// search for objects by bounding box only.
			.categoryBitMask	:		// ++ search only for objects with value overlapping this bitmask
				FwNodeCategory.picable  .rawValue | // 3:works ??, f:all drop together
				FwNodeCategory.byDefault.rawValue ,
			.clipToZRange		:true,	// search for objects only within the depth range zNear and zFar
		  //.ignoreChildNodes	:true,	// BAD ignore child nodes when searching
		  //.ignoreHiddenNodes	:true 	// ignore hidden nodes not rendered when searching.
			.searchMode:1,				// ++ any:2, all:1. closest:0, //SCNHitTestSearchMode.closest
		  //.sortResults:1, 			// (implied)
			.rootNode:tree				// The root of the node hierarchy to be searched.
		]
										//		 // Find the SCNView hit, somewhere in NSEvent's nsView			// SCNView holds a SCNScene
										// 		var scnView : SCNView?	= nsView.hitTest(locationInRoot) as? SCNView	// in sub-View // nsView as? SCNView ?? 	// OLD WAY
										//		guard let scnView else { fatalError("Couldn't find sceneView")			}
										//		 // Find the 3D Vew for the Part under the mouse:
										//		guard let rootNode		= scnView.scene?.rootNode else { fatalError("sceneView.scene is nil") }
		 // scnView is SCNSceneRenderer:
		let hits 				= scnView.hitTest(locationInRoot, options:configHitTest)
		atDoc(5, print("\n---nsEvent loc \(f2(nsEvent.locationInWindow)) -> \(f2(locationInRoot)) in View.frame \(contentView.frame.size), \(hits.count) hits."))
		//		 + +   + +		// hitTest in protocol SCNSceneRenderer

		 // SELECT HIT; prefer any child to its parents:
		let sortedHits			= hits.sorted {	$0.node.position.z > $1.node.position.z }
		var pickedScn			= sortedHits.count==0 ? tree : sortedHits[0].node

		var msg					= "******************************************\n Slot\(slot): find "
		msg 					+= "\(pickedScn.pp(.classUid))'\(pickedScn.fullName)':"	// SCNNode<3433>'/*-ROOT'
			
		 // If Node not picable and has parent
		while pickedScn.categoryBitMask & FwNodeCategory.picable.rawValue == 0,
			  let parent 		= pickedScn.parent
		{
			msg					+= fmt(" --> category %02x (Ignore)", pickedScn.categoryBitMask)
			pickedScn 			= parent				// use parent
			msg 				+= "\n\t " + "parent " + "\(pickedScn.pp(.classUid))'\(pickedScn.fullName)': "
		}

		 // Get Vew from SCNNode
		guard let vew 				= vewBase.tree.find(scnNode:pickedScn, me2:true) else {
			if trueF 				{ return nil 		}		// Ignore missing vew
			panic(msg + "\n"+"couldn't find it in vew's ...") //\(vews.scn.pp(.classUid))")
			let vew 				= vewBase.tree.find(scnNode:pickedScn, me2:true) // for debug only
			return nil
		}
		msg							+= "      ===>    ####  ..."//\(vew.part.pp(.fullNameUidClass))  ####"
	//	msg							+= "background -> trunkVew"
		atEve(3, print("\n" + msg))
		return vew
	}

	 // MARK: - 13.4 Mouse Variables
	 /// Common update: deltaPosition and lastPosition
	func beginCameraMotion(with nsEvent:NSEvent)	{
		guard let contentNsView	= nsEvent.window?.contentView else {	return	}

		let hitPosn 			= contentNsView.convert(nsEvent.locationInWindow, from:nil)	// nil -> window
			//	 : NSPoint			     NsView:								: NSPoint :window
			//	 : CGPoint
		let hitPosnV3			= SCNVector3(hitPosn.x, hitPosn.y, 0)		// BAD: unprojectPoint(

		 // Movement since last, 0 if first time and there is none
		deltaPosition			= lastPosition == nil ? SCNVector3.zero : hitPosnV3 - lastPosition!
		//print("beginCameraMotion:deltaPosition=\(deltaPosition)")
		lastPosition			= hitPosnV3
	}

	func spinNUp(with nsEvent:NSEvent) {
		vewBase!.selfiePole.spin -=  deltaPosition.x * 0.5	// / deg2rad * 4/*fudge*/
		vewBase!.selfiePole.gaze -= deltaPosition.y * 0.2	// * self.cameraZoom/10.0
	}
	func commitCameraMotion(duration:Float=0, reason:String?=nil) {
		var selfiePole			= vewBase!.selfiePole
	//	selfiePole.zoom			= zoom4fullScreen()		// BUG HERE

		let transform			= selfiePole.transform()
		guard let cameraScn		= vewBase?.cameraScn else {fatalError("RootScn.cameraScn in nil")}
		//print("commitCameraMotion(:reason:'\(reason ?? "nil")')\n\(transform.pp(.line)) -> cameraScn:\(cameraScn.pp(.uid))")
		//print("SelfiePole:\(selfiePole.pp(.uid)) = \(selfiePole.pp(.line))\n")
		cameraScn.transform 	= transform		//SCNMatrix4.identity // does nothing
			// add ortho magnification.
		cameraScn.camera?.orthographicScale = selfiePole.zoom * 20
	}
	 // MARK: - 15. PrettyPrint
	func ppSuperHack(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
		var rv					= super.pp(mode, aux)
		if mode == .line {
			rv					+= vewBase?.scnBase === self ? "" : "OWNER:'\(vewBase!)' BAD"
			guard let tree		= self.tree	else { return "tree==nil!! "		}
			rv					+= "scn:\(ppUid(self, showNil:true)) (\(tree.nodeCount()) SCNNodes total) "
		//	rv					+= "animatePhysics:\(animatePhysics) "
		//	rv					+= "\(self.scnScene.pp(.uidClass, aux)) "
//			rv					+= "\(self.scnView?.pp(.uidClass, aux) ?? "BAD: scnView=nil") "
		}
		return rv
	}
	static let null 			= {
		let null				= ScnBase()	// Any use of this should fail (NOT IMPLEMENTED)
		null.tree?.name			= "nullScnBase"
		return null
	}()
}
// currently unused
extension ScnBase : SCNPhysicsContactDelegate {
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
