//
//  RootScn.swift -- Manages SCNNode Shapes tree, SCNScene and SCNView
//  Factals
//
//  Created by Allen King on 9/19/22.
//

import SceneKit

// https://medium.com/@gabriel_lewis/how-to-debug-scenekit-and-arkit-in-xcode-ebd105ee36c9

//		Concepts:
//	The camera is positioned in the world with the camera transform
//
//                3D MODEL SPACE       camera
//    model             v                ^         LOCAL
//     coords:          |                |					getModelViewMatrix()
//                \ ∏ Tmodel i/    trans = cameraScn.transform
//                 \  Matrix /           |
//    world    =====    v   =============*============ WORLD		[x, y, z, 1]
//     coords:          |
//               \ trans.inverse /
//                \   Matrix    /
//    camera   ======   v    ========================= EYE			[x, y, z, 1]
//     coords:          |
//                \ PROJECTION /
//                 \  Matrix  /pm
//    clip     ======   v    ========================= ?        	[x, y, 1]
//     coords:          |
//                \ Perspective/         (not used)
//                 \ division /
//    device   ======   v    ========================= RETINA:		[x, y, 1]
//     coords:          |								CLIP
//                 \ Viewport /  A = | fx 0  cx |  Intrinsic Matrix
//                  \ Matrix /       | 0  fy cy |  f = focal length
//    window            v			 			   c = center of image
//     coords:          |
//             ====== SCREEN ========================= SCREEN		[x, y]
// https://learnopengl.com/Getting-started/Coordinate-Systems

 /// The root SCN of a SCNScene has associated Factals' values:
class RootScn : SCNNode {		// , Uid

 		 /// Owner:
 	weak var rootVew: RootVew!	= nil
//		 /// For Uid conformance:
//	var uid		 	: UInt16	= randomUid()

//	var scnScene 	: SCNScene!
	var fwScene 	: FwScene!

	var fwView	 	: FwView!	= nil
//	var scnView	 	: SCNView!	= nil

	var lookAtVew	: Vew?		= nil						// Vew we are looking at
	var selfiePole				= SelfiePole()
	var cameraScn	: SCNNode 	{ 	touchCameraScn()							}
		 /// For Log conformance:
	var log 	 	: Log 	{	rootVew.fwGuts.log						}


	/// Convenience Parameters:
	var fwGuts	 : FwGuts		{	rootVew.fwGuts								}
	var rootPart : RootPart		{	rootVew.rootPart							}


	var scn		 : SCNNode		{	self } //scnScene.rootNode	}
	var trunkScn : SCNNode? 	{
		if let ts				= scn.child0  {
			return ts
		}
		fatalError("trunkVew is nil")
	}
//
//	 /// animatePhysics is a posative quantity (isPaused is a negative)
//	var animatePhysics : Bool {
//		get {			return !scnScene.isPaused								}
//		set(v) {		scnScene?.isPaused = !v									}
//	}

	// MARK: - 14. Building
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}

	 // MARK: - 3.1 init
	init(fwScene fs:FwScene, fwView fv:FwView?=nil, args:SceneKitArgs?=nil) {

		super.init()

		fwScene 				= fs				// remember in self.scnScene
		fwScene.isPaused		= true				// Pause animations while bulding
		fwView					= fv ?? FwView()	// remember or make a new one
		fwView.scene			= fwScene			// register 3D-scene with 2D-View:
		fwView.backgroundColor	= NSColor("veryLightGray")!
		fwView.antialiasingMode = .multisampling16X
		guard let args			else {			return							}
		fwView.pointOfView 	= args.pointOfView
		fwView.preferredFramesPerSecond = args.preferredFramesPerSecond
	//	fwView.delegate		=

		fwScene.physicsWorld.contactDelegate = fwScene
//		rootScn.fwScene.physicsWorld.contactDelegate = fwScene
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")	}

	func pushControllersConfig(to c:FwConfig) {
		assert(c.bool("isPaused") == nil, "SCNScene.isPaused is depricated, use .animatePhysics")
bug	//	animatePhysics = c.bool("animatePhysics") ?? false
	//
	//	if let gravityAny		= c["gravity"] {
	//		if let gravityVect : SCNVector3 = SCNVector3(from:gravityAny) {
	//			scnScene.physicsWorld.gravity = gravityVect
	//		}
	//		else if let gravityY: Double = gravityAny.asDouble {
	//			scnScene.physicsWorld.gravity.y = gravityY
	//		}
	//	}
	//	if let speed			= c.cgFloat("speed") {
	//		scnScene.physicsWorld.speed = speed
	//	}
/////	assert(scnScene.physicsWorld.contactDelegate === fwGuts.eventCentral, "Paranoia: set in SceneKitHostingView")
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
											 // Complain if Straggler: 		assert(rootScn.find(name:name) == nil, "helper: \"\(name)\" pre-exists")
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
				scn.addChildNode(rv)											// rootScn.addChild(node:newLight)
				return rv
			}
		}
	}
	 // MARK: - 4.2 Camera
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
		if true || rootVew.fwGuts.document.config.bool("axisTics") ?? false {
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
		guard let fwGuts		= rootVew.fwGuts else {		return				}
		let localPoint			= SCNVector3.origin		//falseF ? bBox.center : 		//trueF//falseF//
		let wPosn				= fwScene.rootNode.convertPosition(localPoint, to:scn)
//		let wPosn				= scnScene.rootNode.convertPosition(localPoint, to:scn)

///		assert(pole.worldPosition.isNan == false, "Pole has position = NAN")

		let animateIt			= fwGuts.document.config.bool_("animatePole")
		if animateIt {	 // Animate 3D Cursor Pole motion"
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
		
	/// Determine zoom so that all parts of the scene are seen.
	func zoom4fullScreen() -> Double {		//selfiePole:SelfiePole, cameraScn:SCNNode
		guard let rootVew		= rootVew  else {	fatalError("RootScn.rootVew is nil")}	//fwGuts.rootVewOf(rootScn:self)

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
	  // MARK: - 16. Global Constants
	static let nullRootScn 		= RootScn(fwScene:FwScene())	/// Any use of this should fail (but currently doesn't)
	 // MARK: - 15. PrettyPrint
//	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
//		switch mode! {
//		case .line:
//			return self.pp(.classUid) + " "
//		default:
//			var rv				= scn.pp(.classUid)
//			rv					+= scnScene.pp(.classUid)
//			rv					+= scnView.pp(.classUid)
//			return rv
//		}
//	}
}

 // Kinds of Nodes
enum FwNodeCategory : Int {
	case byDefault				= 0x1		// default unpicable (piced by system)
	case picable 				= 0x2		// picable
	case adornment				= 0x4		// unpickable e.g. bounding box
	case collides				= 0x8		// Experimental
}
