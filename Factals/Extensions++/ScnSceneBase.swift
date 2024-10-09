//
//  ScnSceneBase.swift
//  Factals
//
//  Created by Allen King on 2/2/23.
//

import Foundation
import SceneKit
typealias EventHandler			= (NSEvent) -> Void

class ScnSceneBase : NSObject {

	var tree	 : SCNScene?					//	{ didSet { setRootNodeChild1(from:tree) }}
	var scnView	 : SCNView?						// SCNView  of this ScnSceneBase
	weak
	 var vewBase : VewBase?						// Delegate (of these ScnSceneBase)

	var logRenderLocks			= true			// Overwritten by Configuration
	var eventHandler:EventHandler

	var nextIsAutoRepeat : Bool = false 		// filter out AUTOREPEAT keys
	var mouseWasDragged			= false			// have dragging cancel pic
	var lastPosition : SCNVector3? = nil		// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	 // MARK: - 3.1 init
	init(scnScene:SCNScene=SCNScene(), eventHandler: @escaping EventHandler={_ in }) { //aka ScnSceneBase(scnScene:eventHandler)
		self.tree				= scnScene		// get scene
		self.tree!.rootNode.name = "rootNode"
		self.eventHandler		= eventHandler
 		super.init()
//		setRootNodeChild1 (from:tree)
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
}
extension ScnSceneBase {		// lights and camera
	 // MARK: - 4.1 Lights
	func checkLights() {
		touchLight("*-omni1",  .omni, position:SCNVector3(0, 0, 15))
		touchLight("*-amb1",.ambient,color:NSColor.darkGray)
		touchLight("*-amb2",.ambient,color:NSColor.white, intensity:500)				//blue//
		touchLight("*-omni2",  .omni,color:NSColor.green, intensity:500)				//blue//

		func touchLight(_ name:String, _ lightType:SCNLight.LightType, color:Any?=nil,
					intensity:CGFloat=100, position:SCNVector3?=nil) {
			guard let tree 		else { return									}
			if tree.rootNode.find(name:name) == nil {
										 // Light's SCNNode:
				let scn4light 	= SCNNode()
				scn4light.name	= name				// arg 1
				if let position {
					scn4light.position = position	// arg 5
				}
				tree.rootNode.addChildNode(scn4light)
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
	world    =====    v   =============*============ WORLD			[x, y, z, 1]
	 coords:          |
			   \ trans.inverse /
				\   Matrix    /
	camera   ======   v    ========================= EYE			[x, y, z, 1]
	 coords:          |
				\ PROJECTION /
				 \  Matrix  /pm
	clip     ======   v    ========================= ?        		[x, y, 1]
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
		let camNode				= tree.rootNode.find(name:name, maxLevel:1) ?? { // use old
			 // New camera system:
			let rv				= SCNNode()
			rv.name				= name
			rv.position 		= SCNVector3(0, 0, 55)	// HACK: must agree with updateCameraRotator
			tree.rootNode.addChildNode(rv)

			 // Just make a whole new camera system from scratch
			let camera			= SCNCamera()
			camera.name			= "SCNCamera"
			rv.camera			= camera
			return rv
		}()
		guard let camera 		= camNode.camera else { fatalError("camera node not proper") }

		let perspective		= false
		// Check the condition to determine the camera mode in perspective
		camera.zNear 		= 0.1 	// 1    Set the near clipping distance
		camera.zFar 		= 1000	// 100  Set the far clipping distance
		camera.fieldOfView 	= 60	// Set the field of view, in degrees
		if !perspective {
			 // Orthographic (non-perspective) mode
			camera.usesOrthographicProjection = true
			let orthoScale: CGFloat = 10.0 // Adjust this value based on your scene's size
			camera.orthographicScale = orthoScale
		}
		camera.wantsExposureAdaptation = false				// determines whether SceneKit automatically adjusts the exposure level.
		camera.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
		camera.exposureAdaptationDarkeningSpeedFactor = 1
		camera.automaticallyAdjustsZRange = true			//cam.zNear				= 1
	}

	  // MARK: - 4.3 Axes
	 // ///// Rebuild the Axis Markings
	func touchAxesScn() {			// was updatePole()
		guard let tree			else { return									}
		let name				= "*-axis"

		 // Already exist?
		if tree.rootNode.find(name:name) != nil {
			return
		}
		let axesLen				= SCNVector3(15,15,15)	//SCNVector3(5,15,5)
		let axesScn				= SCNNode()				// New pole
		axesScn.categoryBitMask	= FwNodeCategory.adornment.rawValue
		tree.rootNode.addChild(node:axesScn)
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
//// 		atRve(8, logg("  /#######  SCNTransaction: BEGIN"))
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
bug
		guard let cameraScn		= vewBase?.cameraScn else {		return 			}
								
		vewBase?.selfiePole.zoom = zoom4fullScreen()	//(selfiePole:selfiePole, cameraScn:cameraScn)

		guard let vewBase		= self.vewBase else { fatalError("vews is nil")	}
		guard let factalsModel	= vewBase.factalsModel else {fatalError("")		}

		let animate				= factalsModel.fmConfig.bool("animatePan") ?? false
		if animate && duration > 0.0 {
			SCNTransaction.begin()			// Delay for double click effect
			SCNTransaction.animationDuration = CFTimeInterval(0.5)

			 // 181002 must do something, or there is no delay
			cameraScn.transform	*= 0.999999	// virtually no effect
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()			// Animate Camera Update
				atRve(8, factalsModel.logd("  /#######  animatePan: BEGIN Completion Block"))
				SCNTransaction.animationDuration = CFTimeInterval(duration)

				cameraScn.transform = self.vewBase!.selfiePole.transform()

				atRve(8, factalsModel.logd("  \\#######  animatePan: COMMIT Completion Block"))
				SCNTransaction.commit()
			}
			atRve(8, factalsModel.logd("  \\#######  animatePan: COMMIT All"))
			SCNTransaction.commit()
		}
		else {
			cameraScn.transform	= vewBase.selfiePole.transform()
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
				zoomRv			/= ratioHigher
			}
		}
		return zoomRv
	}
}
//
//	func convertToRoot(windowPosition:NSPoint) -> NSPoint {
//		let windowPositionV3 : SCNVector3 = SCNVector3(windowPosition.x, windowPosition.y, 0)
//											// BUGGY:
//		let   rootPositionV3 : SCNVector3 = scnScene.convertPosition(windowPositionV3, from:nil)
//		return NSPoint(x:rootPositionV3.x, y:rootPositionV3.y)
//		let
//NSView:
//		   convert         (_:NSPoint,       from:NSView?)       -> NSPoint			<== SwiftFactals (motionFromLastEvent)
//SWIFTFACTALS ->	nil ==> from WINDOW coordinates.		WORKS _/

 // Kinds of Nodes
enum FwNodeCategory : Int {
	case byDefault				= 0x1		// default unpicable (piced by system)
	case picable 				= 0x2		// picable
	case adornment				= 0x4		// unpickable e.g. bounding box
	case collides				= 0x8		// Experimental
}

extension ScnSceneBase : SCNSceneRendererDelegate {
	func facMod() -> FactalsModel? {	vewBase?.factalsModel					}

	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async { [self] in
			facMod()?.doPartNViewsLocked(workNamed:"A_updateVSP", logIf:self.logRenderLocks) {
				$0.updateVSP()
			}
		}
	}
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async { [self] in
			facMod()?.doPartNViewsLocked(workNamed:"B_computeLinkForces", logIf:self.logRenderLocks) {
				$0.factalsModel.partBase.tree.computeLinkForces(vew:$0.tree)
			}
		}
	}
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async { [self] in
			facMod()?.doPartNViewsLocked(workNamed: "C_applyLinkForces", logIf:self.logRenderLocks) {
				$0.factalsModel.partBase.tree.applyLinkForces(vew:$0.tree)
			}
		}
	}
	func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async { [self] in
			facMod()?.doPartNViewsLocked(workNamed:"D_xx", logIf:self.logRenderLocks) {
				$0.factalsModel.partBase.tree.computeLinkForces(vew:$0.tree)
			}
		}
	}
	 // MARK: - 13. IBActions
	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		let duration			= Float(1)
		guard let vewBase 		= vewBase else { print("processEvent.rootVews[?] is nil"); return false}
		let slot				= vewBase.slot ?? -1
		let factalsModel		= vewBase.factalsModel		// why ! ??

		switch nsEvent.type {

		  //  ====== KEYBOARD ======
		 //
		case .keyDown:
			if nsEvent.isARepeat {		return false  /* Ignore repeats */		}
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
		case .rightMouseDragged:
			nop
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
		let possibleVewBases 	= vb != nil ? [vb!] : vewBase!.factalsModel.vewBases // check all
		for vewBase in possibleVewBases {
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

										//		 // Find the SCNView hit, somewhere in NSEvent's nsView			// SCNView holds a SCNScene
										// 		var scnView : SCNView?	= nsView.hitTest(locationInRoot) as? SCNView	// in sub-View // nsView as? SCNView ?? 	// OLD WAY
										//		guard let scnView else { fatalError("Couldn't find sceneView")			}
										//		 // Find the 3D Vew for the Part under the mouse:
										//		guard let rootNode		= scnView.scene?.rootNode else { fatalError("sceneView.scene is nil") }

//	 .map {	NSApp.keyWindow?.contentView?.convert($0, to: nil)	}
//	 .map { point in SceneView.pointOfView?.hitTest(rayFromScreen: point)?.node }

//	func handleMouseEvent(_ event: NSEvent) {
//		if let view = NSApplication.shared.keyWindow?.contentView {
//			let location = view.convert(event.locationInWindow, from: nil)
//bug;		if let hitNsView = view.hitTest(location) {//,
//				bug
//			//let sceneView = hitNsView.node.scene?.view {//as? SCNView {
//			//	sceneView.mouseDown(with: event)
//			}
//		}
//	}
//		let locationInRoot		= contentView.convert(nsEvent.locationInWindow, from:nil)	// nil => from window coordinates //view
//		let view2 = NSApplication.shared.keyWindow?.contentView
//		let locationInRoot		= contentView.convert(nsEvent.locationInWindow, from:nil)	// nil => from window coordinates //view
	func findVew(nsEvent:NSEvent, inVewBase vewBase:VewBase) -> Vew? {
		 // Find vews of NSEvent

//		guard let contentView 	= NSApp.keyWindow?.contentView else { return nil}
		guard let tree			= vewBase.scnSceneBase.tree    else { return nil}
		guard let scnView		= scnView 					   else { fatal("vewBase.scnSceneBase.scnView is nil") }
//		guard let scnView		= vewBase.scnSceneBase.scnView else { fatal("vewBase.scnSceneBase.scnView is nil") }
		guard let slot 			= vewBase.slot			 	   else { return nil}

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

		let locationInRoot		= scnView.convert(nsEvent.locationInWindow, from:nil)
		let hits 				= scnView.hitTest(locationInRoot, options:configHitTest)
		//		 + +   + +		// hitTest in protocol SCNSceneRenderer

		 // SELECT HIT; prefer any child to its parents:
		let sortedHits			= hits.sorted {	$0.node.position.z > $1.node.position.z }
		var pickedScn			= sortedHits.first?.node ?? tree.rootNode
//		var pickedScn			= (sortedHits.count==0 ? tree : sortedHits[0].node)// as! SCNNode

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
			panic(msg + "\n"+"couldn't find it in vew's ...") //\(vews.scnScene.pp(.classUid))")
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
		print("Start position=\(hitPosnV3.pp(.phrase)) in frame of \(contentNsView.frame)")

		 // Movement since last, 0 if first time and there is none
		deltaPosition			= lastPosition == nil ? SCNVector3.zero : hitPosnV3 - lastPosition!
		print("beginCameraMotion: deltaPosition=\(deltaPosition.pp(.phrase))")
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
		guard let cameraScn		= vewBase?.cameraScn else {fatalError("vewBase.cameraScn is nil")}
		//print("commitCameraMotion(:reason:'\(reason ?? "nil")')\n\(transform.pp(.line)) -> cameraScn:\(cameraScn.pp(.uid))")
		//print("selfiePole:\(selfiePole.pp(.uid)) = \(selfiePole.pp(.line))\n")
		cameraScn.transform 	= transform		//SCNMatrix4.identity // does nothing
			// add ortho magnification.
cameraScn.camera?.orthographicScale = selfiePole.zoom * 10
	}
	 // MARK: - 15. PrettyPrint
	func ppSuperHack(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String {
		var rv					= super.pp(mode, aux)
		if mode == .line {
			rv					+= vewBase?.scnSceneBase === self ? "" : "OWNER:'\(vewBase!)' BAD"
			guard let tree		= self.tree	else { return "tree==nil!! "		}
			rv					+= "scnScene:\(ppUid(self, showNil:true)) ((tree.nodeCount()) SCNNodes total) "
		//	rv					+= "animatePhysics:\(animatePhysics) "
		//	rv					+= "\(self.scnScene.pp(.uidClass, aux)) "
//			rv					+= "\(self.scnView?.pp(.uidClass, aux) ?? "BAD: scnView=nil") "
		}
		return rv
	}
}

// currently unused
extension ScnSceneBase : SCNPhysicsContactDelegate {
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

extension SCNView {		//
	var handler : EventHandler {
		get { return	(delegate as! ScnSceneBase).eventHandler}
		set(val) { }
	}
/*
	override var linkSkinType		: LinkSkinType	{	
		get {			return .ray 	}
		set(v) {		panic("MultiLink linkSkinType HELP!!")}
	}


		get {			return .ray 	}
		set(v) {		panic("MultiLink linkSkinType HELP!!")}


{
		get {
			return viewAsAtom_
		}
		set(val) {
			viewAsAtom_		= val
			markTree(dirty:.vew)
		}
	}(	get:{ "" }, set:{x in 		// Always out of range
//					let factalsModel = self.partBase?.factalsModel
					let port	= atom.ports[x]!
//					for vewBase in factalsModel.vewBases {
//						let newVew = vewBase.tree.find(part:port, inMe2:true) ?? vew
//						if var fwDocument = atom.partBase?.factalsModel.document {
//							fwDocument.showInspecFor(vew:newVew, allowNew:false)
//						}
//					}
				} )
 */

	 // MARK: - 13.1 Keys
	open override func keyDown(with 	event:NSEvent) 		{	handler(event)	}
	open override func keyUp(with 		event:NSEvent) 		{	handler(event)	}
//	 // MARK: - 13.2 Mouse
//	 //  ====== LEFT MOUSE ======
//	override func mouseDown(with 		event:NSEvent)		{	handler(event)	}
//	override func mouseDragged(with 	event:NSEvent)		{	handler(event)	}
//	override func mouseUp(with 			event:NSEvent)		{	handler(event)	}
//	override func mouseDown(with event: NSEvent) {
//		print("SCNView.mouseDown")
//	}
//	 //  ====== CENTER MOUSE ======
//	override func otherMouseDown(with 	event:NSEvent)		{	handler(event)	}
//	override func otherMouseDragged(with event:NSEvent)		{	handler(event)	}
//	override func otherMouseUp(with 	event:NSEvent)		{	handler(event)	}
//	 //  ====== CENTER SCROLL WHEEL ======
//	override func scrollWheel(with 		event:NSEvent) 		{	handler(event)	}
//	 //  ====== RIGHT MOUSE ======			Right Mouse not used
//	override func rightMouseDown(with 	event:NSEvent) 		{	handler(event)	}
//	override func rightMouseDragged(with event:NSEvent) 	{	handler(event)	}
//	override func rightMouseUp(with 	event:NSEvent) 		{	handler(event)	}
//	 // MARK: - 13.3 TOUCHPAD Enters
//	override func touchesBegan(with 	event:NSEvent)		{	handler(event)	}
//	override func touchesMoved(with 	event:NSEvent)		{	handler(event)	}
//	override func touchesEnded(with 	event:NSEvent)		{	handler(event)	}
}
