//
//  RootScn.swiftf
//  Factals
//
//  Created by Allen King on 2/2/23.
//

import Foundation
import SceneKit

class RootScn : NSObject {		// was  : SCNScene
	weak
	 var rootVew	: RootVew?
	weak
	 var fwView		: FwView?
	var scnScene	: SCNScene

	 // Lighting, etc
	var cameraScn	: SCNNode 	{ 	touchCameraScn()							}
	var selfiePole				= SelfiePole()
	var lookAtVew	: Vew?		= nil						// Vew we are looking at

	func pushControllersConfig(to c:FwConfig) {
		assert(c.bool("isPaused") == nil, "SCNScene.isPaused is depricated, use .animatePhysics")
		animatePhysics = c.bool("animatePhysics") ?? false
	
		if let gravityAny		= c["gravity"] {
			if let gravityVect : SCNVector3 = SCNVector3(from:gravityAny) {
				scnScene.physicsWorld.gravity = gravityVect
			}
			else if let gravityY: Double = gravityAny.asDouble {
				scnScene.physicsWorld.gravity.y = gravityY
			}
		}
		if let speed			= c.cgFloat("speed") {
			scnScene.physicsWorld.speed	= speed
		}
		selfiePole.pushControllersConfig(to:c)
/////	assert(scnScene.physicsWorld.contactDelegate === fwGuts.eventCentral, "Paranoia: set in SceneKitHostingView")
	}

	 // MARK: - 3.1 init
	init(scnScene ss:SCNScene?=nil, fwView fv:FwView?=nil, args:SceneKitArgs?=nil) {
		scnScene				= ss ?? SCNScene()
		super.init()	// NSObject

		scnScene.physicsWorld.contactDelegate = self
		scnScene.isPaused		= true				// Pause animations while bulding
		fwView					= fv ?? FwView()	// remember or make a new one
		fwView!.scene			= scnScene			// register 3D-scene with 2D-View:
		fwView!.rootScn 		= self
		fwView!.backgroundColor	= NSColor("veryLightGray")!
		fwView!.antialiasingMode = .multisampling16X
		fwView!.delegate		= self as any SCNSceneRendererDelegate
		if let args	 {
			fwView!.pointOfView 	= args.pointOfView
			fwView!.preferredFramesPerSecond = args.preferredFramesPerSecond
		}
	}
	
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
	
	 /// animatePhysics is a posative quantity (isPaused is a negative)
	var animatePhysics : Bool {
		get {			return !scnScene.isPaused										}
		set(v) {		scnScene.isPaused = !v											}
	}



	 // MARK: - 13. IBActions
	var nextIsAutoRepeat : Bool = false 	// filter out AUTOREPEAT keys
	var mouseWasDragged			= false		// have dragging cancel pic

	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) {
		let nsTrackPad			= trueF//falseF//
		let duration			= Float(1)
		guard let rootVew else { print("processEvent.rootVew[..] is nil"); return }
		let fwGuts				= rootVew.fwGuts		// why ! ??
		let rootScn				= rootVew.rootScn
		let cam					= rootScn.cameraScn
//		let rootScn				= rootVew.rootScn
//		let cam					= rootScn.cameraScn

		switch nsEvent.type {

		  //  ====== KEYBOARD ======
		 //
		case .keyDown:
			if nsEvent.isARepeat {	return }			// Ignore repeats
			nextIsAutoRepeat 	= true
			guard let char : String	= nsEvent.charactersIgnoringModifiers else { return }
			assert(char.count==1, "multiple keystrokes not supported")

			if fwGuts != nil && fwGuts!.processEvent(nsEvent:nsEvent, inVew:nil) == false,
			  char != "?" {		// okay for "?" to get here
				atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
			}
		case .keyUp:
			assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
			nextIsAutoRepeat 	= false
			let _				= fwGuts != nil && fwGuts!.processEvent(nsEvent:nsEvent, inVew:nil)

		  //  ====== LEFT MOUSE ======
		 //
		case .leftMouseDown:
			motionFromLastEvent(with:nsEvent)
			if !nsTrackPad  {					// 3-button Mouse
				let vew			= fwGuts?.modelPic(with:nsEvent)
			}//
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Left mouseDown")
		case .leftMouseDragged:	// override func mouseDragged(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				mouseWasDragged = true			// drag cancels pic
				spinNUp(with:nsEvent)			// change Spin and Up of camera
				cam.transform 	= rootScn.cameraTransform(reason:"Left mouseDragged")
			}
		case .leftMouseUp:	// override func mouseUp(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				if !mouseWasDragged {			// UnDragged Up
					if let vew	= fwGuts?.modelPic(with:nsEvent) {
						rootScn.lookAtVew = vew			// found a Vew: Look at it!
					}
				}
				mouseWasDragged = false
				cam.transform 	= rootScn.cameraTransform(duration:duration, reason:"Left mouseUp")
			}

		  //  ====== CENTER MOUSE (scroll wheel) ======
		 //
		case .otherMouseDown:	// override func otherMouseDown(with nsEvent:NSEvent)	{
			motionFromLastEvent(with:nsEvent)
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Other mouseDown")
		case .otherMouseDragged:	// override func otherMouseDragged(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			spinNUp(with:nsEvent)
			cam.transform 		= rootScn.cameraTransform(reason:"Other mouseDragged")
		case .otherMouseUp:	// override func otherMouseUp(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Other mouseUp")
			atEve(9, print("\( cam.transform.pp(PpMode.tree))"))

		  //  ====== CENTER SCROLL WHEEL ======
		 //
		case .scrollWheel:
			let d				= nsEvent.deltaY
			let delta : CGFloat	= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
			rootScn.selfiePole.zoom *= delta
			let p				= rootScn.selfiePole
			print("processEvent(type:  .scrollWheel  ) found pole \(p.pp())")
			cam.transform 		= rootScn.cameraTransform(duration:duration, reason:"Scroll Wheel")

		  //  ====== RIGHT MOUSE ======			Right Mouse not used
		 //
		case .rightMouseDown:	bug
		case .rightMouseDragged:bug
		case .rightMouseUp:		bug

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

		case .beginGesture:		// override func touchesBegan(with event:NSEvent) {
			let t 				= nsEvent.touches(matching:.began, in:rootScn.fwView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		case .mouseMoved:		bug
			let t 				= nsEvent.touches(matching:.moved, in:rootScn.fwView)
			for touch in t {
				let prevLoc		= touch.previousLocation(in:nil)
				let loc			= touch.location(in:nil)
				atEve(3, (print("\(prevLoc) \(loc)")))
			}
		case .endGesture:	//override func touchesEnded(with event:NSEvent) {
			let t 				= nsEvent.touches(matching:.ended, in:rootScn.fwView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		default:
			print("processEvent(type:\(nsEvent.type)) NOT PROCESSED by EventCentral")
		}
	}
	 // MARK: - 13.4 Mouse Variables
	func motionFromLastEvent(with nsEvent:NSEvent)	{
		guard let contentNsView	= nsEvent.window?.contentView else {	return	}

		let posn 				= contentNsView.convert(nsEvent.locationInWindow,     from:nil)	// nil -> window
			//	 : NSPoint			     NsView:								: NSPoint :window
			//	 : CGPoint
		let posnV3				= SCNVector3(posn.x, posn.y, 0)		// BAD: unprojectPoint(

		 // Movement since last, 0 if first time and there is none
		deltaPosition			= lastPosition == nil ? SCNVector3.zero : posnV3 - lastPosition!
		lastPosition			= posnV3
										//let prevPosn : SCNVector3 = lastPosition ?? posnV3
										// // "Output"
										//deltaPosition			= posnV3 - prevPosn
										//lastPosition			= posnV3
	}
	func allConversions() {
//		let point				= convert(NSPoint(), from:nil)
//		let size				= convert(NSSize(),  from:nil)
//		let rect				= convert(NSRect(),  from:nil)
//		let cgRect				= convert(CGRect(),  from:nil)
	}
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

	var lastPosition : SCNVector3? = nil				// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	func spinNUp(with nsEvent:NSEvent) {
		let rootScn 			= rootVew!.rootScn
		rootScn.selfiePole.spin -= 		deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
		rootScn.selfiePole.horizonUp -= deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
	}





}

extension RootScn {		// lights and camera
	var scn	: SCNNode			{		return scnScene.rootNode				}
	var trunkScn : SCNNode? 	{
		if let ts				= scn.child0  {
			return ts
		}
		fatalError("trunkVew is nil")
	}
	 // MARK: - 4.1 Lights
	func touchLightScns() -> [SCNNode] {
		let a 					= touchLight("*-omni1",	.omni, position:SCNVector3(0, 0, 15))
		let b 					= touchLight("*-amb1",.ambient,color:NSColor.darkGray)
		let c 					= touchLight("*-amb2",.ambient,color:NSColor.white, intensity:500)				//blue//
		let d 					= touchLight("*-omni2",	.omni, color:NSColor.green, intensity:500)				//blue//
		return [a,b,c,d]
//		let _ 					= helper("omni3",	.omni,	 color:NSColor.red,   intensity:500)				//blue//
//		let spot 				= helper("spot",	.spot,	 position:SCNVector3(1.5, 1.5, 1.5))
//		 spot.light!.spotInnerAngle = 30.0
//		 spot.light!.spotOuterAngle = 80.0
//		 spot.light!.castsShadow = true
//		 let constraint 		= SCNLookAtConstraint(target:nil)
//		 constraint.isGimbalLockEnabled = true
//		 cameraScn.constraints 	= [constraint]
//		 spot.constraints 		= [constraint]
//		for (msg, obj) in [("light1", light1), ("light2", light2), ("camera", cameraScn)] {
//			rv					+= "\(msg) =       \(obj.categoryBitMask)-"
//			rv					+= "\(obj.description.shortenStringDescribing())\n"
//		}
		func touchLight(_ name:String, _ lightType:SCNLight.LightType, color:Any?=nil,
					position:SCNVector3?=nil, intensity:CGFloat=100) -> SCNNode {
						// Complain if Straggler: 		assert(scn.find(name:name) == nil, "helper: \"\(name)\" pre-exists")
			if let rv			= scn.find(name:name) {
				return rv
			} else {
				let light		= SCNLight()
				light.type 		= lightType
				if let color	= color {
					light.color = color
				}
				let rv 			= SCNNode()
				rv.light		= light
				rv.name			= name
				light.intensity = intensity
				if let position	= position {
					rv.position = position
				}
				scn.addChildNode(rv)
				return rv
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
	func touchCameraScn() -> SCNNode {
		let name				= "*-camera"
		if let rv				= scn.find(name:name) {
			return rv			// already exists
		} // Make new camera system:
										class DebugCameraNode: SCNNode {
											override var transform: SCNMatrix4 {
												get {	super.transform							}
												set {	super.transform = newValue				}
											}
										}
		let rv					= DebugCameraNode()
		rv.name					= name
		rv.position 			= SCNVector3(0, 0, 55)	// HACK: must agree with updateCameraRotator
		scn.addChildNode(rv)

		 // Just make a whole new camera system from scratch
		let camera				= SCNCamera()
		camera.name				= "SCNCamera"
	//	camera.wantsExposureAdaptation = false				// determines whether SceneKit automatically adjusts the exposure level.
	//	camera.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
	//	camera.exposureAdaptationDarkeningSpeedFactor = 1
	//	camera.automaticallyAdjustsZRange = true			//cam.zNear				= 1
		camera.zNear			= 1
		camera.zFar				= 100
		rv.camera				= camera
		return rv
	}

	  // MARK: - 4.3 Axes
	 // ///// Rebuild the Axis Markings
	func touchAxesScn() -> SCNNode {			// was updatePole()
		let name				= "*-pole"
		 //
		if let rv 				= scn.find(name:name) {
			return rv
		}
		let axesLen				= SCNVector3(15,15,15)	//SCNVector3(5,15,5)
		let axesScn				= SCNNode()				// New pole
		axesScn.categoryBitMask	= FwNodeCategory.adornment.rawValue
		scn.addChild(node:axesScn)
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
		return axesScn
	}																		//origin.rotation = SCNVector4(x:0, y:1, z:0, w:.pi/4)
	func addAxisTics(toNode:SCNNode, from:CGFloat, to:CGFloat, r:CGFloat) {
		if true || rootVew?.fwGuts?.document.config.bool("axisTics") ?? false {
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

	 // MARK: 4.4 - Look At Updates
	func movePole(toWorldPosition wPosn:SCNVector3) {
		guard let fwGuts		= rootVew?.fwGuts else {		return						}
		let localPoint			= SCNVector3.origin		//falseF ? bBox.center : 		//trueF//falseF//
		let wPosn				= scn.convertPosition(localPoint, to:scn)
//		let wPosn				= scnScene.rootNode.convertPosition(localPoint, to:scn)

///		assert(pole.worldPosition.isNan == false, "Pole has position = NAN")

		let animateIt			= fwGuts.document.config.bool_("animatePole")
		if animateIt {	 // Animate 3D Cursor Pole motion"∫
			SCNTransaction.begin()
//			atRve(8, logg("  /#######  SCNTransaction: BEGIN"))
		}

///		pole.worldPosition		= wPosn

		if animateIt {
			SCNTransaction.animationDuration = CFTimeInterval(1.0/3)
			atRve(8, fwGuts.logd("  \\#######  SCNTransaction: COMMIT"))
			SCNTransaction.commit()
		}
	}
	//
	func cameraTransform(duration:Float=0, reason:String?=nil) -> SCNMatrix4 {
	//	selfiePole.zoom			= zoom4fullScreen()
		let transform			= selfiePole.transform
		return transform
	}
	/// Compute Camera Transform from pole config
	/// - Parameters:
	///   - from: defines direction of camera
	///   - message: for logging only
	///   - duration: for animation
	func updatePole2Camera(duration:Float=0.0, reason:String?=nil) { //updateCameraRotator
//		let cameraScn			= scnScene.cameraScn!
								//
//		let rootVew				= fwGuts.rootVewOf(rootScn:self)
//		let rootVew				= rootVew.fwGuts.rootVewOf(rootScn:self)

		zoom4fullScreen()
//		zoom4fullScreen(selfiePole:selfiePole, cameraScn:cameraScn)

		if duration > 0.0,
//		  rootVew?.config.bool("animatePan") ?? false {
		  rootVew?.fwGuts?.document.config.bool("animatePan") ?? false {
			SCNTransaction.begin()			// Delay for double click effect
			atRve(8, rootVew!.fwGuts.logd("  /#######  animatePan: BEGIN All"))
			SCNTransaction.animationDuration = CFTimeInterval(0.5)
			 // 181002 must do something, or there is no delay
			cameraScn.transform *= 0.999999	// virtually no effect
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()			// Animate Camera Update
				atRve(8, self.rootVew!.rootVew!.fwGuts.logd("  /#######  animatePan: BEGIN Completion Block"))
				SCNTransaction.animationDuration = CFTimeInterval(duration)

				self.cameraScn.transform = self.selfiePole.transform

				atRve(8, self.rootVew!.fwGuts.logd("  \\#######  animatePan: COMMIT Completion Block"))
				SCNTransaction.commit()
			}
			atRve(8, rootVew!.fwGuts.logd("  \\#######  animatePan: COMMIT All"))
			SCNTransaction.commit()
		}
		else {
			cameraScn.transform = selfiePole.transform
		}
	}
		
	/// Determine zoom so that all parts of the scene are seen.
	func zoom4fullScreen() -> Double {		//selfiePole:SelfiePole, cameraScn:SCNNode
		guard let rootVew  else {	fatalError("RootScn.rootVew is nil")}

		 //		(ortho-good, check perspective)
		let rootVewBbInWorld	= rootVew.bBox //BBox(size:3, 3, 3)//			// in world coords
		let world2eye			= SCNMatrix4Invert(cameraScn.transform)		//rootVew.scn.convertTransform(.identity, to:nil)	// to screen coordinates
		let rootVewBbInEye		= rootVewBbInWorld.transformed(by:world2eye)
		let rootVewSizeInEye	= rootVewBbInEye.size
		guard let nsRectSize	= fwView?.frame.size  else  {	fatalError()	}

		 // Orientation is "Height Dominated"
		var zoomRv				= rootVewSizeInEye.x	// 1 ==> unit cube fills screen
		 // Is side going to be clipped off?
		let ratioHigher			= nsRectSize.height / nsRectSize.width
		if rootVewSizeInEye.y > rootVewSizeInEye.x * ratioHigher {
			zoomRv				*= ratioHigher
		}
		if rootVewSizeInEye.x * nsRectSize.height < nsRectSize.width * rootVewSizeInEye.y {
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
	func createVewNScn(sceneIndex:Int, vewConfig:VewConfig? = nil) { 	// Make the  _VIEW_  from Experiment
		guard let rootVew		= rootVew 		 else {	fatalError("RootScn.rootVew is nil")}	//fwGuts.rootVewOf(rootScn:self)
		guard let fwGuts		= rootVew.fwGuts else {	fatalError("RootScn.rootVew.fwGuts is nil")}

		let rootPart			= fwGuts.rootPart
		assert(rootVew.name == "_ROOT", 	"Paranoid check: rootVew.name=\(rootVew.name) !=\"_ROOT\"")
		assert(rootVew.part	=== rootPart,   "Paranoid check, rootVew.part != rootPart")
		assert(rootVew.part.name == "ROOT", "Paranoid check: rootVew.part.name=\(rootVew.part.name) !=\"ROOT\"")
		assert(rootPart.children.count == 1,"Paranoid check: rootPart has \(rootPart.children.count) children, !=1")

		 // 1. 	GET LOCKS					// PartTree
		let lockName			= "createVew[\(sceneIndex)]"
		guard rootPart.lock(partTreeAs:lockName) else {
			fatalError("createVews couldn't get PART lock")		// or
		}		          					// VewTree
		guard rootVew.lock(vewTreeAs:lockName) else {
			fatalError("createVews  couldn't get VIEW lock")
		}

		 // 2. Update Vew and Scn Tree
/**/	rootVew.updateVewSizePaint(vewConfig:vewConfig)		// rootPart -> rootView, rootScn

		 // 3. Add Lights, Camera and SelfiePole
		let _ 					= touchLightScns()			// was updateLights
		let _ 					= touchCameraScn()			// (had fwGuts.document.config)
		let _ 					= touchAxesScn()

		 // 4.  Configure SelfiePole:											//Thread 1: Simultaneous accesses to 0x6000007bc598, but modification requires exclusive access
		if let c 				= fwGuts.document.config.fwConfig("selfiePole") {
			if let at 			= c.scnVector3("at"), !at.isNan {
				selfiePole.at 	= at						// Pole Height
			}
			if let u 			= c.float("u"), !u.isNan {	// Horizon look Up
				selfiePole.horizonUp = -CGFloat(u)				// (in degrees)
			}
			if let s 			= c.float("s"), !s.isNan {	// Spin
				selfiePole.spin = CGFloat(s) 					// (in degrees)
			}
			if let z 			= c.float("z"), !z.isNan {	// Zoom
				selfiePole.zoom = CGFloat(z)
			}
			atRve(2, fwGuts.logd("=== Set camera=\(c.pp(.line))"))
		}

		 // 5.  Configure Initial Camera Target:
		lookAtVew				= rootVew.trunkVew			// default
		if let laStr			= fwGuts.document.config.string("lookAt"), laStr != "",
		  let  laPart 			= rootPart.find(path:Path(withName:laStr), inMe2:true) {		//xyzzy99
			lookAtVew			= rootVew.find(part:laPart)
		}

		 // 6. Set LookAtNode's position
		let posn				= lookAtVew?.bBox.center ?? .zero
		let worldPosition		= lookAtVew?.scn.convertPosition(posn, to:scn) ?? .zero
		assert(!worldPosition.isNan, "About to use a NAN World Position")
		selfiePole.at			= worldPosition

		 // Do one, just for good luck
		cameraScn.transform		= cameraTransform(reason:"to createVewNScn")
//		updatePole2Camera(reason:"to createVewNScn")

		// 7. UNLOCK PartTree and VewTree:
		rootVew.unlock(	 vewTreeAs:lockName)
		rootPart.unlock(partTreeAs:lockName)	//xyzzy99
	}
}

 // Kinds of Nodes
enum FwNodeCategory : Int {
	case byDefault				= 0x1		// default unpicable (piced by system)
	case picable 				= 0x2		// picable
	case adornment				= 0x4		// unpickable e.g. bounding box
	case collides				= 0x8		// Experimental
}


extension RootScn : SCNSceneRendererDelegate {
	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("\n<><><> 9.5.1: Update At Time       -> updateVewSizePaint"))
			let rVew			= self.rootVew!
			rVew.lockBoth("updateAtTime")
			rVew.updateVewSizePaint(needsLock:"renderLoop", logIf:false)		//false//true
			rVew.unlockBoth("updateAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
			let rVew			= self.rootVew!
			rVew .lockBoth("didApplyAnimationsAtTime")
			rVew .part.computeLinkForces(vew:rVew)
			rVew .unlockBoth("didApplyAnimationsAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
			let rVew			= self.rootVew!
			rVew.lockBoth("didSimulatePhysicsAtTime")
			rVew.part.applyLinkForces(vew:rVew)
			rVew.unlockBoth("didSimulatePhysicsAtTime")
		}
	}
	func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
//			atRsi(8, self.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			let rVew			= self.rootVew!
			rVew.lockBoth("willRenderScene")
			rVew.part.rotateLinkSkins(vew:rVew)
			rVew.unlockBoth("willRenderScene")
		}
	}
	   // ODD Timing:
	func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//		atRsi(8, self.logd("<><><> 9.5.@: Scenes Rendered -- NOP"))
	}
	func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
//		atRsi(8, self.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
	}

}
// currently unused
extension RootScn : SCNPhysicsContactDelegate {
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
