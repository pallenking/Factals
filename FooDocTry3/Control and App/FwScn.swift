//
//  FwScn.swift -- Manages SCNNode Shapes tree, SCNScene and SCNView
//  FooDocTry3
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

class FwScn : Uid {
	var uid		 : UInt16		= randomUid()
	var log		 : Logger 		{	rootVew.fwGuts.logger						}
//	var log		 : Logger 		{	fwGuts.rootPart.logger						}
	var logger 	 : Logger 		{	rootVew.fwGuts.logger						}

//	weak
//	 var fwGuts	 : FwGuts!		= nil
	weak
	 var rootVew : RootVew!		= nil

	var scnView	 : SCNView!		= nil
	var scnScene : SCNScene!

	var scn		 : SCNNode		{	scnScene.rootNode							}
	var rootScn  : SCNNode		{	scnScene.rootNode							}	//scnRoot
	var rootScnFoo = SCNNode()
	var trunkScn : SCNNode? 	{
		if let tv				= rootScn.child0  {
//		if let tv				= fwGuts?.rootVews[0]!.trunkVew  {
			return tv
		}
		fatalError("trunkVew is nil")
	}

	

	 /// animatePhysics is defined because as isPaused is a negative concept, and doesn't denote animation
	var animatePhysics : Bool {
		get {			return !scnScene.isPaused								}
		set(v) {		scnScene?.isPaused = !v									}
	}

	// MARK: - 14. Building
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		logger.log(banner:banner, format_, args, terminator:terminator)
	}

	 // MARK: - 3.1 init
	init(scnScene ss:SCNScene, scnView sv:SCNView?=nil) {
				// get Scene and View:
		scnScene 				= ss				// remember
		scnScene.isPaused		= true				// Pause animations while bulding
		scnView					= sv ?? SCNView()	// remember
		scnView.scene			= scnScene			// register 3D-scene with 2D-View:
		scnView.backgroundColor	= NSColor("veryLightGray")!
		//scnView.pointOfView 	= args.pointOfView
		//scnView.preferredFramesPerSecond = args.preferredFramesPerSecond
		//scnView.antialiasingMode = args.antialiasingMode
		//scnView.delegate		= ??args.delegate	// nil --> rv's delegate is rv!
	}
	func setControllers(config:FwConfig) {
		assert(config.bool("isPaused") == nil, "SCNScene.isPaused is depricated, use .animatePhysics")
		animatePhysics = config.bool("animatePhysics") ?? false

		if let gravityAny		= config["gravity"] {
			if let gravityVect : SCNVector3 = SCNVector3(from:gravityAny) {
				scnScene.physicsWorld.gravity = gravityVect
			}
			else if let gravityY: Double = gravityAny.asDouble {
				scnScene.physicsWorld.gravity.y = gravityY
			}
		}
		if let speed			= config.cgFloat("speed") {
			scnScene.physicsWorld.speed = speed
		}
/////	assert(scnScene.physicsWorld.contactDelegate === fwGuts.eventCentral, "Paranoia: set in SceneKitHostingView")
	}
	
	 // MARK: - 4.1 Lights
	func addLightsToScn() {
		let _ 					= helper("omni1",	.omni,	 position:SCNVector3(0, 0, 15))
		let _ 					= helper("ambient1",.ambient,color:NSColor.darkGray)
		let _ 					= helper("ambient2",.ambient,color:NSColor.white, intensity:500)				//blue//
		let _ 					= helper("omni2",	.omni,	 color:NSColor.green, intensity:500)				//blue//
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
		func helper(_ name:String, _ lightType:SCNLight.LightType, color:Any?=nil,
					position:SCNVector3?=nil, intensity:CGFloat=100) -> SCNNode {
			 // Complain Straggler
			assert(rootScn.find(name:name) == nil, "Who put the node named '\(name)' here? !!!")

			let light			= SCNLight()
			light.type 			= lightType
			if let color		= color {
				light.color = color
			}
			let rv 				= SCNNode()
			rv.light			= light
			rv.name				= name
			light.intensity 	= intensity
			if let position		= position {
				rv.position 	= position
			}
			rootScn.addChildNode(rv)											// rootScn.addChild(node:newLight)
			return rv
		}
	}
	 // MARK: - 4.2 Camera
	func addCameraToScn(_ config:FwConfig) {
		assert(rootScn.find(name:"camera") == nil, "Who put the node named '\("camera")' here? !!!")

		 // Just make a whole new camera system from scratch
		let camera				= SCNCamera()
		camera.name				= "SCNCamera"
		camera.wantsExposureAdaptation = false				// determines whether SceneKit automatically adjusts the exposure level.
		camera.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
		camera.exposureAdaptationDarkeningSpeedFactor = 1
		camera.automaticallyAdjustsZRange = true			//cam.zNear				= 1
		//camera.zNear			= 1
		//camera.zFar			= 100
														// NOOO	addChildNode(camera!)
		let newCameraScn		= SCNNode()
		newCameraScn.camera		= camera
		newCameraScn.name		= "camera"
		newCameraScn.position 	= SCNVector3(0, 0, 100)	// HACK: must agree with updateCameraRotator
		rootScn.addChildNode(newCameraScn)
	}
	 // Get camera node from SCNNode
	var cameraScn : SCNNode? {
		let rootNode			= scnScene.rootNode
		let rv					= rootNode.find(name:"camera")
		return rv
	}
	  // MARK: - 4.3 Axes
	 // ///// Rebuild the Axis Markings
	func addAxesScn() {			// was updatePole()
		guard rootVew.fwGuts.document.config.bool_("showAxis") else {	return					}

		let name				= "*-pole"
		 // Delete any Straggler
		assert(rootScn.find(name:name) == nil, "Who put the node named '\(name)' here? !!!")
		let axesLen				= SCNVector3(15,15,15)	//SCNVector3(5,15,5)
		var pole				= SCNNode()				// New pole
		pole.categoryBitMask	= FwNodeCategory.adornment.rawValue
		rootScn.addChild(node:pole)
		pole.name				= name

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
			pole.addChild(node:arm)

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
		pole.addChild(node:upPole)


		 // Experimental label
		let geom				= SCNText(string:"Origin", extrusionDepth:1)
		geom.containerFrame		= CGRect(x:-0.5, y:-0.5, width:1, height:1)
		let label		 		= SCNNode(geometry:geom)
		label.name				= "Origin"
		label.color0			= .black
		label.color0(emission:systemColor)
		pole.addChild(node:label)


		 // Origin Node is a pyramid
		let origin		 		= SCNNode(geometry:SCNSphere(radius:r*4))
		origin.categoryBitMask	= FwNodeCategory.adornment.rawValue
		origin.name				= "s-Pyr"
		origin.color0			= .black
		origin.color0(emission:systemColor)									//let origin	  = SCNNode(geometry:SCNPyramid(width:0.5, height:0.5, length:0.5))
		pole.addChild(node:origin)
	}																		//origin.rotation = SCNVector4(x:0, y:1, z:0, w:.pi/4)
	func addAxisTics(toNode:SCNNode, from:CGFloat, to:CGFloat, r:CGFloat) {
		if rootVew.fwGuts.document.config.bool("axisTics") ?? false {
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
		let wPosn				= scnScene.rootNode.convertPosition(localPoint, to:rootScn)

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
//	/// Compute Camera Transform from pole config
//	/// - Parameters:
//	///   - from: defines direction of camera
//	///   - message: for logging only
//	///   - duration: for animation
//	func updatePole2Camera(duration:Float=0.0, reason:String?=nil) { //updateCameraRotator
//		let cameraScn			= scnScene.cameraScn!
//								//
////		let rootVew				= fwGuts.rootVewOf(fwScn:self)
//		let rootVew				= rootVew.fwGuts.rootVewOf(fwScn:self)
//		zoom4fullScreen(selfiePole:rootVew.lastSelfiePole, cameraScn:cameraScn)
//
//		if duration > 0.0,
//		  fwGuts.document.config.bool("animatePan") ?? false {
//			SCNTransaction.begin()			// Delay for double click effect
//			atRve(8, fwGuts.logd("  /#######  animatePan: BEGIN All"))
//			SCNTransaction.animationDuration = CFTimeInterval(0.5)
//			 // 181002 must do something, or there is no delay
//			cameraScn.transform *= 0.999999	// virtually no effect
//			SCNTransaction.completionBlock = {
//				SCNTransaction.begin()			// Animate Camera Update
//				atRve(8, self.fwGuts.logd("  /#######  animatePan: BEGIN Completion Block"))
//				SCNTransaction.animationDuration = CFTimeInterval(duration)
//
//				cameraScn.transform = rootVew.lastSelfiePole.transform
//
//				atRve(8, self.fwGuts.logd("  \\#######  animatePan: COMMIT Completion Block"))
//				SCNTransaction.commit()
//			}
//			atRve(8, fwGuts.logd("  \\#######  animatePan: COMMIT All"))
//			SCNTransaction.commit()
//		}
//		else {
//			cameraScn.transform = rootVew.lastSelfiePole.transform
//		}
//	}
		
	/// Set Camera's transform so that all parts of the scene are seen.
	/// - Parameters:
	///   - selfiePole: look points looking at it's origin
	///   - camScn: camera
	func zoom4fullScreen(selfiePole:SelfiePole, cameraScn camScn:SCNNode) {
		guard let rootVew		= rootVew 		 else {	fatalError("FwScn.rootVew is nil")}	//fwGuts.rootVewOf(fwScn:self)
		guard let fwGuts		= rootVew.fwGuts else {	fatalError("FwScn.fwGuts is nil")}

		 //		(ortho-good, check perspective)
		let rootVewBbInWorld	= rootVew.bBox//BBox(size:3, 3, 3)//			// in world coords
		let world2eye			= SCNMatrix4Invert(camScn.transform)		//rootVew.scn.convertTransform(.identity, to:nil)	// to screen coordinates
		let rootVewBbInEye		= rootVewBbInWorld.transformed(by:world2eye)
		let rootVewSizeInEye	= rootVewBbInEye.size
		guard let nsRectSize	= scnView?.frame.size  else  {	fatalError()	}

		var orientation			= "Height Dominated"
		var zoomSize			= rootVewSizeInEye.x	// 1 ==> unit cube fills screen
		 // Is side going to be clipped off?
		let ratioHigher			= nsRectSize.height / nsRectSize.width
		if rootVewSizeInEye.y > rootVewSizeInEye.x * ratioHigher {
			zoomSize			*= ratioHigher
		}
		if rootVewSizeInEye.x * nsRectSize.height < nsRectSize.width * rootVewSizeInEye.y {
			orientation			= "Width Dominated"
			zoomSize			= rootVewSizeInEye.y
			 // Is top going to be clipped off?
			if rootVewSizeInEye.x > rootVewSizeInEye.y / ratioHigher {
				zoomSize		/= ratioHigher
			}
		}
		let vanishingPoint 		= rootVew.fwGuts.document.config.double("vanishingPoint")
		if (vanishingPoint?.isFinite ?? true) == false {		// Ortho if no vp, or vp=inf
			  // https://blender.stackexchange.com/questions/52500/orthographic-scale-of-camera-in-blender
			 // https://stackoverflow.com/questions/52428397/confused-about-orthographic-projection-of-camera-in-scenekit
			guard let c:SCNCamera = camScn.camera else { fatalError("cameraScn.camera is nil") 	}
			c.usesOrthographicProjection = true		// camera’s magnification factor
			c.orthographicScale = Double(zoomSize * selfiePole.zoom * 0.75)
		}
		camScn.transform	= selfiePole.transform
		atRsi(7, fwGuts.logd("fillScreen \(rootVewBbInEye.pp(.line))  \(orientation)  zoom:%.2f)", zoomSize))
	}

	func convertToRoot(windowPosition:NSPoint) -> NSPoint {
//		let rootVew				= fwGuts.rootVewOf(fwScn:self)
		let wpV3 : SCNVector3	= SCNVector3(windowPosition.x, windowPosition.y, 0)
		let vpV3 : SCNVector3	= rootScn.convertPosition(wpV3, from:nil)
		return NSPoint(x:vpV3.x, y:vpV3.y)
	}

	 /// Build  Vew and SCN  tree from  Part  tree for the first time.
	///   (This assures updateVewNScn work)
	func createVewNScn() { 	// Make the  _VIEW_  from Experiment
		guard let rootVew		= rootVew 		 else {	fatalError("FwScn.rootVew is nil")}	//fwGuts.rootVewOf(fwScn:self)
		guard let fwGuts		= rootVew.fwGuts else {	fatalError("FwScn.fwGuts is nil")}

		let rootPart			= fwGuts.rootPart
		assert(rootVew.name 	== "_ROOT", "Paranoid check: rootVew.name=\(rootVew.name) !=\"_ROOT\"")
		assert(rootVew.part		== rootPart,"Paranoid check, rootVew.part != rootPart")
		assert(rootVew.part.name == "ROOT", "Paranoid check: rootVew.part.name=\(rootVew.part.name) !=\"ROOT\"")
		assert(rootPart.children.count == 1,"Paranoid check: rootPart has \(rootPart.children.count) children, !=1")

		 // 1. 	GET LOCKS				// PartTree
		guard rootPart.lock(partTreeAs:"createVews") else {
			fatalError("createVews couldn't get PART lock")		// or
		}		          				// VewTree
		guard rootVew.lock(vewTreeAs:"createVews") else {
			fatalError("createVews  couldn't get VIEW lock")
		}

		 // 2. Update Vew and Scn Tree
/**/	rootVew.updateVewSizePaint()		// rootPart -> rootView, rootScn

		 // 6. Add Lights, Camera and SelfiePole
		addLightsToScn()							// was updateLights
		addCameraToScn(fwGuts.document.config)
		addAxesScn()

		 // 3.  Configure SelfiePole:
		if let c 				= fwGuts.document.config.fwConfig("selfiePole") {
			if let at 			= c.scnVector3("at"), !at.isNan {	// Pole Height
				rootVew.lastSelfiePole.at = at
			}
			if let u 			= c.float("u"), !u.isNan {	// Horizon look Up
				rootVew.lastSelfiePole.horizonUp = -CGFloat(u)		/* in degrees */
			}
			if let s 			= c.float("s"), !s.isNan {	// Spin
				rootVew.lastSelfiePole.spin = CGFloat(s) 		/* in degrees */
			}
			if let z 			= c.float("z"), !z.isNan {	// Zoom
				rootVew.lastSelfiePole.zoom = CGFloat(z)
			}
			atRve(2, fwGuts.logd("=== Set camera=\(c.pp(.line))"))
		}

		 // 4.  Configure Initial Camera Target:
		rootVew.lookAtVew		= rootVew.trunkVew				// default
		if let laStr			= fwGuts.document.config.string("lookAt"), laStr != "",
		  let  laPart 			= rootPart.find(path:Path(withName:laStr), inMe2:true) {		//xyzzy99
			rootVew.lookAtVew	= rootVew.find(part:laPart)
		}

		 // 5. Set LookAtNode's position
		let posn				= rootVew.lookAtVew?.bBox.center ?? .zero
		let worldPosition		= rootVew.lookAtVew?.scn.convertPosition(posn, to:rootScn) ?? .zero
		assert(!worldPosition.isNan, "About to use a NAN World Position")
		rootVew.lastSelfiePole.at = worldPosition
//		let posn				= fwGuts.lookAtVew?.bBox.center ?? .zero
//bug;	fwGuts.pole.worldPosition = fwGuts.lookAtVew?.scn.convertPosition(posn, to:rootScn) ?? .zero
//		assert(!fwGuts.pole.worldPosition.isNan, "About to use a NAN World Position")

		 // Do one, just for good luck
		rootVew.updatePole2Camera(reason:"install RootPart")

		// 7. UNLOCK PartTree and VewTree:
		rootVew.unlock(	 vewTreeAs:"createVews")
		rootPart.unlock(partTreeAs:"createVews")	//xyzzy99
	}
	
//	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
//		return "FwScn:\(ppUid(self))"
//	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv 					= self.pp(.classUid) + " "//"FwScn:\(ppUid(self))"
		switch mode! {
		case .line: nop
bug//		rv					+= eventCentral	.pp(.classUid) + " "
  //		rv					+= fwScn		.pp(.classUid) + " "		//}
		default:
			rv 					+= "RootVew:\(ppUid(self))"
		}
		return rv
	}
}


 // Kinds of Nodes
enum FwNodeCategory : Int {
	case byDefault				= 0x1		// default unpicable (piced by system)
	case picable 				= 0x2		// picable
	case adornment				= 0x4		// unpickable e.g. bounding box
	case collides				= 0x8		// Experimental
}
