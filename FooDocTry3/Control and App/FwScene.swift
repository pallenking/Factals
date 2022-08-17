//  FwScene.swift -- All the 3D things in a FwView 2D window  C2018PAK

// Supports: Camera, Lights, 3D Cursor,
//   Collisions, Animations (esp for positioning)

import SceneKit

//		Concepts:
//	The camera is positioned in the world with a "camera" matrix.
//
//                3D MODEL SPACE       camera
//    model             v                ^         LOCAL
//     coords:          |                |					getModelViewMatrix()
//                \ ∏ Tmodel i/    trans = cameraNode.transform
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

 // Kinds of Nodes
enum FwNodeCategory : Int {
	case byDefault				= 0x1		// default unpicable (piced by system)
	case picable 				= 0x2		// picable
	case adornment				= 0x4		// unpickable e.g. bounding box
	case collides				= 0x8		// Experimental
}
			//projectPoint(_:)
class FwScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

	  // MARK: - 2. Object Variables:
	 // ///////// Vew Tree:
	var rootVew  : Vew			= Vew(forPart:.null, scn:.null)	// Initially a dummy: no part, no scn
	let rootVewLock 			= DispatchSemaphore(value:1)
	var rootVewOwner : String?	= nil
	var rootVewOwnerPrev:String? = nil
	var rootVewVerbose 			= false
	var trunkVew : Vew? {		 // Get  trunkVew  from reVew:
		let children			= rootVew.children
		return children.count > 0 ? children[0] : nil
	}

	 // ///////// SCNNode Tree:
	var rootScn  : SCNNode	{	return rootNode									}	//scnRoot
	var trunkScn : SCNNode? {
		if let tv				= trunkVew  {
			return tv.scn
		}
		fatalError("trunkVew is nil")
	}
	 // ///////// Part Tree:
	var rootPart : RootPart		{	rootVew.part as! RootPart					}

	var pole					= SCNNode()		// focus of mouse rotator

	var config4scene : FwConfig {
		get			{ 			return config4scene_ 							}
		set(config) {
			config4scene_ 		= config
			if let anim			= config.bool("animatePhysics") {
				animatePhysics 	= anim
			}
			if config.bool("isPaused") ?? false {
				panic("SCNScene.isPaused is now depricated, use 'animatePhysics' instead")
			}
			if let gravAny33:FwAny = config["gravity"] {		// GLOBAL
				if let gravityVect : SCNVector3 = SCNVector3(from:gravAny33) {
					physicsWorld.gravity = gravityVect
				}
				else if let gravityY: Double = gravAny33.asDouble {
					physicsWorld.gravity.y = gravityY
				}
			}
			if let speed		= config.cgFloat("speed") {
				physicsWorld.speed = speed
			}
			physicsWorld.contactDelegate = self	/// Physics Contact Protocol is below
		}
	};private var config4scene_ : FwConfig = [:]

	 /// animatePhysics is defined because as isPaused is a negative concept, and doesn't denote animation
	var animatePhysics : Bool {
		get {			return !super.isPaused									}
		set(v) {		super.isPaused = !v										}
	}

	 // MARK: - 3. Factory
	init(fwConfig:FwConfig) {		//controller ctl:Controller? = nil,
		super.init()

		config4scene		= fwConfig
//		atCon(6, logd("init(fwConfig:\(fwConfig.pp(.line).wrap(min: 30, cur: 44, max: 100))"))

		// TO DO:
		   // 1. Might want to add camera:[s: u: z:] to status bar //cocoahead 4
		  // Docs: Status Bar Programming Topics
		 //https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos

		  //  2. In SCNView show
		 // in Docs/www //  https://github.com/dani-gavrilov/GDPerformanceView-Swift/blob/master/GDPerformanceView-Swift/GDPerformanceMonitoring/GDPerformanceMonitor.swift
		//GDPerformanceMonitor.sharedInstance.configure(configuration: { (textLabel) in
		//	textLabel?.backgroundColor = .black
		//	textLabel?.textColor = .white
		//	textLabel?.layer.borderColor = UIColor.black.cgColor
		//})
		//GDPerformanceMonitor.sharedInstance.startMonitoring()

		 //190707: This HANGS on 2'nd time	//cocoahead 2:
		//fwView?.background		= NSColor("veryLightGray")!
		// https://developer.apple.com/documentation/scenekit/scnview/1523088-backgroundcolor
	}

	// FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {
					// 1. Write SCNScene to file. (older, SCNScene supported serialization)
		write(to:fileURL, options:nil, delegate:nil, progressHandler:nil)
					// 2. Get file to data
		let data				= try? Data(contentsOf:fileURL)
		return data
	}
	 // initialize new SCNScene from Data
	convenience init?(data:Data, encoding:String.Encoding) {
		do {		// 1. Write data to file.
			try data.write(to: fileURL)
		} catch {
			print("error writing file: \(error)")
		}
		do {		// 2. Init self from file
bug
			try self.init(fwConfig:[:])
	//		try super.init(url: fileURL)
		} catch {
			print("error initing from url: \(error)")
			return nil
		}
	}

	 // MARK: - 3.5 Codable
	 // ///////// Serialize
	func encode(to encoder: Encoder) throws  {
		fatalError("FwScene.encode(coder..) unexpectantly called")
	}
	 // ///////// Deserialize
	required init(coder aDecoder: NSCoder) {
		fatalError("FwScene.init(coder..) unexpectantly called")
	}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	 // MARK: - 3.7 Equitable substitute

//	  // MARK: - 9.0 3D Support
//	 // mouse may "paw through" parts, using wiggle
//	var wiggledPart	  : Part?	= nil
//	var wiggleOffset  : SCNVector3? = nil		// when mouse drags an atom
//
	 // MARK: - 9.A Locks
	 /// Optain DispatchSemaphor for Vew Tree
	func lock(rootVewAs lockName:String?=nil, logIf:Bool=true) -> Bool {
		guard lockName != nil else {	return true		/* no lock needed */	}

		let u_name			= ppUid(self) + " '\(lockName!)'".field(-20)
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
		assert(rootVewOwner==nil, "\(lockName!) Locking, but \(rootVewOwner!) lingers ")
		rootVewOwner 		= lockName
		atRve(3, {						/// AFTER GETTING:
			let val0		= rootVewLock.value ?? -99
			!logIf ? nop : logd("//#######" + u_name + "      GOT Vew  LOCK: v:\(val0)")
		}())
		return true
	}
	func unlock(rootVewAs lockName:String?=nil, logIf:Bool=true) {
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
	 // MARK: - 9.B Lights, Axis, Camera
	 //		or autoenablesDefaultLighting = true?
	func updateLights() {
		 // ///// Light 4: Ambient white
		let light4 				= SCNNode()			//https://www.raywenderlich.com/2243-scene-kit-tutorial-getting-started
		light4.name				= "light4"
		light4.light 			= SCNLight()
		light4.light!.type 		= SCNLight.LightType.ambient
		light4.light!.color 	= NSColor.white//blue//
		light4.light!.intensity	= 500
		rootScn.addChildNode(light4)

		 // ///// Light 5: Omni white
		let light5				= SCNNode()
		light5.name				= "light5"
		light5.light 			= SCNLight()
		light5.light!.type 		= SCNLight.LightType.omni
		light5.light!.color 	= NSColor.green//white
		light5.position 		= SCNVector3Make(0, 50, 50)
		light5.light!.intensity	= 500				// 1000 is nominal
		rootScn.addChildNode(light5)

		 // ///// Light 6: Omni white
		let light6				= SCNNode()
		light6.name				= "light6"
		light6.light 			= SCNLight()
		light6.light!.type 		= SCNLight.LightType.omni
		light6.light!.color 	= NSColor.red//white
		light6.position 		= SCNVector3Make(0, -50, -50)
		light6.light!.intensity	= 100
		rootScn.addChildNode(light6)
									//let light = SCNLight()
									//light.type = SCNLightTypeSpot
									//light.spotInnerAngle = 30.0
									//light.spotOuterAngle = 80.0
									//light.castsShadow = true
									//let lightNode = SCNNode()
									//lightNode.light = light
									//lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
									//...
									//let constraint = SCNLookAtConstraint(target: cubeNode)
									//constraint.gimbalLockEnabled = true
									//cameraNode.constraints = [constraint]
									//lightNode.constraints = [constraint]
		  // ///////////////////////////////////////////////////////////////////
	}

	  // ///////////////////////////////////////////////////////////////////////
	 // ///// Rebuild the Rotator Pole afresh
	func updatePole() {
		let axesLen				= SCNVector3(15,15,15)	//SCNVector3(5,15,5)
		pole					= SCNNode()				// New pole
		pole.categoryBitMask	= FwNodeCategory.adornment.rawValue
		rootScn.addChild(node:pole)
		pole.name				= "*-pole"

		 // X/Z Poles (thinner)
		let r : CGFloat			= 0.03
		for i in 0..<2 {
			let arm 			= SCNNode(geometry:SCNCylinder(radius:r, height:axesLen.x))
			arm.categoryBitMask = FwNodeCategory.adornment.rawValue
			pole.addChild(node:arm)
			arm.transform		= SCNMatrix4Rotate(SCNMatrix4.identity, CGFloat.pi/2,
								(i == 0 ? 1 : 0), 0, (i == 1 ? 1 : 0)  )
			arm.name			= "s-Cyl\(i)"
			arm.color0			= .lightGray
			arm.color0(emission:systemColor)

			let nTics			= [axesLen.x, axesLen.z][i]
			addTics(toNode:arm, from:-nTics/2, to:nTics/2, r:r) // /////////////
		}
		 // Y Pole (thicker) 
		let upPole 				= SCNNode(geometry:SCNCylinder(radius:r*2, height:axesLen.y))
		upPole.categoryBitMask	= FwNodeCategory.adornment.rawValue
		pole.addChild(node:upPole)
		upPole.position.y		+= axesLen.y / 2
		upPole.name				= "s-CylT"
		upPole.color0			= .lightGray
		upPole.color0(emission:systemColor)
		addTics(toNode:upPole, from:0, to:axesLen.y, r:2*r) // /////////////////


		 // Experimental label
		let geom				= SCNText(string:"Origin", extrusionDepth:1)
		geom.containerFrame		= CGRect(x:-0.5, y:-0.5, width:1, height:1)
		let label		 		= SCNNode(geometry:geom)
		pole.addChild(node:label)
		label.name				= "Origin"
		label.color0			= .black
		label.color0(emission:systemColor)


		 // Origin Node is a pyramid
		let origin		 		= SCNNode(geometry:SCNSphere(radius:r*4))
		origin.categoryBitMask	= FwNodeCategory.adornment.rawValue
		pole.addChild(node:origin)
		origin.name				= "s-Pyr"
		origin.color0			= .black
		origin.color0(emission:systemColor)									//let origin	  = SCNNode(geometry:SCNPyramid(width:0.5, height:0.5, length:0.5))
	}																		//origin.rotation = SCNVector4(x:0, y:1, z:0, w:.pi/4)
	func addTics(toNode:SCNNode, from:CGFloat, to:CGFloat, r:CGFloat) {
		if config4scene.bool("poleTics") ?? false {
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

	func movePole(toWorldPosition wPosn:SCNVector3) {
//		let doc					= DOC
//		let fwScene				= doc.fwScene!
//		let localPoint			= falseF ? bBox.center : .origin				//trueF//falseF//
//		let wPosn				= scn.convertPosition(localPoint, to:fwScene.rootScn)

		assert(pole.worldPosition.isNan == false, "Pole has position = NAN")

		let animateIt			= config4scene.bool_("animatePole")
		if animateIt {	 // Animate 3D Cursor Pole motion"
			SCNTransaction.begin()
bug;//		atRve(8, logg("  /#######  SCNTransaction: BEGIN"))
		}

		pole.worldPosition		= wPosn

		if animateIt {
bug//		SCNTransaction.animationDuration = CFTimeInterval((doc?.fwView!.duration ?? 1.0)/3)
			atRve(8, logd("  \\#######  SCNTransaction: COMMIT"))
			SCNTransaction.commit()
		}
	}

	var lookAtPart : Part? 		= nil
	var lookAtVew  : Vew?		= nil
	 /// Update camera formation, configuration, and pointing
	func insureCameraNode() -> SCNNode {
		guard let rootScn		= DOC?.state.fwScene.rootScn else {		fatalError("insureCameraNode() found DOC==nil") 	}

		let camera				= rootScn.find(name:"camera")
								?? addCameraNode(config:config4scene)
		return camera
	}
	func addCameraNode(config:FwConfig) -> SCNNode {
		 // ///// Camera:
		let camNode 			= SCNNode()
		camNode.name			= "camera"
		camNode.position 		= SCNVector3(0, 0, 100)	// HACK: must agree with updateCameraRotator
		DOC?.fwView?.pointOfView = camNode
		DOC?.fwView?.audioListener = camNode

		let camera				= SCNCamera()
		camera.wantsExposureAdaptation = false				//A Boolean value that determines whether SceneKit automatically adjusts the exposure level.
		camera.exposureAdaptationBrighteningSpeedFactor = 1// The relative duration of automatically animated exposure transitions from dark to bright areas.
		camera.exposureAdaptationDarkeningSpeedFactor = 1
		camera.automaticallyAdjustsZRange = true			//cam.zNear				= 1
															//cam.zFar				= 100
		camNode.camera		= camera
		rootScn.addChild(node:camNode)

		 // Configure Camera from Source Code:
//		if let c 				= config.fwConfig("camera") {
//			var lastSelfiePole:SelfiePole
//			if let h 			= c.float("h"), !h.isNan {	// Pole Height
//				lastSelfiePole.cameraPoleHeight = CGFloat(h)
//			}
//			if let u 			= c.float("u"), !u.isNan {	// Horizon look Up
//				lastSelfiePole.cameraHorizonUp = -CGFloat(u)		/* in degrees */
//			}
//			if let s 			= c.float("s"), !s.isNan {	// Spin
//				lastSelfiePole.cameraPoleSpin 	= CGFloat(s) 		/* in degrees */
//			}
//			if let z 			= c.float("z"), !z.isNan {	// Zoom
//				lastSelfiePole.cameraZoom 		= CGFloat(z)
//			}
//			atRve(2, logd("=== Set camera=\(c.pp(.line))"))		// add printout of lastSelfiePole
//		}

		 // Camera looks at target:
		if let state			= DOC?.state,
		 let laStr				= config4scene.string("lookAt"),
		  laStr != ""
		{
			let laPart 			= state.rootPart.find(path:Path(withName:laStr), inMe2:true)
			assertWarn(laPart != nil, "lookAt: '\(laStr)' failed to find part")
			lookAtPart			= laPart ?? 				// from configure
								  rootVew.child0?.part ??	// from rootVew child[0]
								  state.rootPart			// from doc
		}
		return camNode
	}
	 // MARK: - 9.C Mouse Rotator
	 // Uses Cylindrical Coordinates
	struct SelfiePole {
		var cameraPoleHeight: CGFloat // = 0
		var cameraPoleSpin	: CGFloat // = 0					// in degrees
		var cameraHorizonUp	: CGFloat // = 0					// in degrees
		var cameraZoom		: CGFloat // = 1.0
		init() {
			cameraPoleHeight	= 0
			cameraPoleSpin		= 0					// in degrees
			cameraHorizonUp		= 0					// in degrees
			cameraZoom			= 1.0
		}
	}
	var lastSelfiePole = SelfiePole()						// init to default

//	func spinNUp(delta:CGPoint) {
//		cameraPoleSpin			-= delta.x  * 0.5		// / deg2rad * 4/*fudge*/
//		cameraHorizonUp			+= delta.y  * 0.2		// * self.cameraZoom/10.0
//	}

	 // Compute Camera Transform from pole config
	func updateCameraTransform(to:SelfiePole?=nil, for message:String?=nil, overTime duration:Float=0.0) {
		let cam					= to ?? lastSelfiePole

			// Imagine a camera A on a selfie stick, pointing back to the holder B
		   //
		  // From Origin to Camera, in steps: Pole about Origin
		 //  ---- spun about Y axis
		let spin				= cam.cameraPoleSpin * .pi / 180.0
		var poleSpinAboutY		= SCNMatrix4MakeRotation(spin, 0, 1, 0)

		 //  ---- translated above Point of Interest by cameraPoleHeight
		let posn				= lookAtVew?.bBox.center ?? .zero
		let lookAtWorldPosn		= lookAtVew?.scn.convertPosition(posn, to:rootScn) ?? .zero
		 assert(!lookAtWorldPosn.isNan, "About to use a NAN World Position")
		let lap 				= lookAtWorldPosn
		poleSpinAboutY.position	= SCNVector3(lap.x, lap.y+cam.cameraPoleHeight, lap.z)

		 //  ---- With a boom (crane or derek) raised upward above the horizon:
		let upTilt				= cam.cameraHorizonUp * .pi / 180.0
		let riseAboveHoriz		= SCNMatrix4MakeRotation(upTilt, 1, 0, 0)

		 //  ---- move out boom from pole, looking backward:
		let toEndOfBoom			= SCNMatrix4Translate(SCNMatrix4.identity, 0, 0, 10*cam.cameraZoom) //cameraZoom)//10 ad hoc .5

		let newCameraXform		= toEndOfBoom * riseAboveHoriz * poleSpinAboutY
		assert(!newCameraXform.isNan, "newCameraXform is Not a Number")
		assert(newCameraXform.at(3,3) == 1.0, "why?")	// Understand cameraXform.at(3,3). Is it 1.0? is it prudent to change it here


		 // OLD WAY -- SORTA WORKS:  Transform root bbox into camera:
		let bBox				= rootVew.bBox			// in world coords
		let transform2eye		= SCNMatrix4Invert(cameraNode.transform)		//rootVew.scn.convertTransform(.identity, to:nil)	// to screen coordinates
//		let x					= cameraNode.camera?.projectionTransform
		let bBoxScreen			= bBox.transformed(by:transform2eye)
		let bSize				= bBoxScreen.size

		 // Set zoom per horiz/vert:
		var zoomSize			= bSize.y	// default when height dominates
		//var orientation		= "Portrait "
		if let nsRectSize		= DOC?.fwView?.frame.size {
			if bSize.x * nsRectSize.height > nsRectSize.width * bSize.y {
				zoomSize		= bSize.x	// when width dominates
				//orientation	= "Landscape"
			}
		}
		if let vanishingPoint 	= config4scene.double("vanishingPoint"),
		  vanishingPoint.isFinite {			// Perspective
			//print(fmt("\(orientation):\(bBoxScreen.pp(.line)), vanishingPoint:%.2f)", vanishingPoint))
		}	 								// Orthographic
		else if let c			= cameraNode.camera {
			//print(fmt("\(orientation):\(bBoxScreen.pp(.line)), zoomSize:%.2f)", zoomSize))
			c.usesOrthographicProjection = true		// camera’s magnification factor
			c.orthographicScale = Double(zoomSize * cam.cameraZoom * 0.75)
		}

//		 // NEW WAY -- BROKEN: Transform root bbox into camera:
//		let rootBbInWorld		= rootVew.bBox			// in world coords
//		let world2eye			= SCNMatrix4Invert(cameraNode.transform)		//rootVew.scn.convertTransform(.identity, to:nil)	// to screen coordinates
//		let rootBbInEye			= rootBbInWorld.transformed(by:world2eye)
//		let rootSize			= rootBbInEye.size
//		guard let nsRectSize	= Fw.view?.frame.size  else  {	fatalError()	}
//
//		 // Determine magnification so all parts of the 3D object are seen.
//		var orthoScale :CGFloat	= 1.0		// A 1 unit size cube just fills entire screen
//											//  e.g. image in extremes of smaller dimension are offscreen
//		 // https://blender.stackexchange.com/questions/52500/orthographic-scale-of-camera-in-blender
//		// https://stackoverflow.com/questions/52428397/confused-about-orthographic-projection-of-camera-in-scenekit
//		if nsRectSize.width > nsRectSize.height {	// Landscape window
//			orthoScale			= rootSize.x			// scale is image width
//	//		 // Is top or side going to be clipped off?
//	//		let ratio			= nsRectSize.height / nsRectSize.width
//	//		let maxVisY			= ratio * rootSize.x
//	//		if rootSize.y > maxVisY {
//	//			orthoScale		*= ratio
//	//		}
//		}else{										// Portrait window
//			orthoScale			= rootSize.y			// scale is image height 
//	//		 // Is left or right going to be clipped off?
//	//		let ratio			= nsRectSize.width / nsRectSize.height
//	//		let maxVisX			= ratio * rootSize.y
//	//		if rootSize.x > maxVisX {
//	//			orthoScale		*= ratio
//	//		}
//		}
//		print(fmt("upCam: rbie:\(rootBbInEye.pp(.line)), ortho:%.2f)",orthoScale))
//		if true {		// Orthographica
//			let cam				= cameraNode.camera!
//			cam.usesOrthographicProjection = true		// camera’s magnification factor
//			cam.orthographicScale = Double(orthoScale * cameraZoom * 1.1)
//		}

		if duration > 0.0,
		  config4scene.bool("animatePan") ?? false
		{
			SCNTransaction.begin()			// Delay for double click
			atRve(8, logd("  /#######  SCNTransaction: BEGIN All"))
			SCNTransaction.animationDuration 	= CFTimeInterval(0.5)
			 // 181002 must do something, or there is no delay
			cameraNode.transform *= 0.999999	// virtually no effect
			SCNTransaction.completionBlock 		= {
				SCNTransaction.begin()			// Animate Camera Update
				atRve(8, self.logd("  /#######  SCNTransaction: BEGIN Completion Block"))
				SCNTransaction.animationDuration = CFTimeInterval(duration)
				self.cameraNode.transform = newCameraXform
				atRve(8, self.logd("  \\#######  SCNTransaction: COMMIT Completion Block"))
				SCNTransaction.commit()
			}
			atRve(8, logd("  \\#######  SCNTransaction: COMMIT All"))
			SCNTransaction.commit()
		}
		else {
			cameraNode.transform = newCameraXform
		}
	}

	 /// Build Vew tree from Part tree
	/// - Parameters:
	///   - rootPart: -- base of model
	///   - lockStr: -- if non-nil, get this lock
	func installRootPart(_ rootPart:RootPart, reason lockStr:String?=nil) { 	// Make the  _VIEW_  from Experiment
		guard let doc			= DOC else {	panic("DOC is nil"); return		}

		 // 1. Get LOCKS for PartTree and VewTree
		guard	doc.state.rootPart.lock(partTreeAs:lockStr) else {
			fatalError("\(lockStr ?? "-") couldn't get PART lock")		// or
		}
		guard lock(rootVewAs:lockStr) else {
			fatalError("\(lockStr ?? "-") couldn't get VIEW lock")
		}
			
		// --------- Link rootVew and rootScn to rootPart
		assert(rootVew.name == "_ROOT", 	"Root improperly set")		//		rootVew.name			= "_ROOT"			// do we really want to do this?
		assert(rootVew.part == rootPart, 	"Root improperly set")		//		rootVew.part			= rootPart
		assert(rootVew.part.name == "ROOT", "Root improperly set")		//		rootVew.part.name		= "ROOT"
		assert(rootVew.scn == rootScn, 		"Root improperly set")		//		rootVew.scn				= rootScn
		assert(rootScn.name == "*-ROOT", 	"Root improperly set")		//		rootScn.name			= "*-ROOT"

		doc.fwView?.showsStatistics = true	// MUST BE HERE, DOESN'T WORK in FwView
		doc.fwView?.window!.backgroundColor = NSColor.yellow // why? cocoahead x: only frame
		doc.fwView?.isPlaying	= true		// WTF??

		 // 3. Add supporting Actors to scene
		let _ 					= insureCameraNode()
		updateLights()
		if config4scene.bool_("pole") {
			updatePole()
		}

		 // 4. Update Vew Tree
/**/	rootVew.updateVewSizePaint(needsViewLock:nil)
		atRve(6, logd("updateVewSizePaint(needsViewLock:) completed"))

		 // 5. Look At Node:
/*x*/	lookAtPart				= lookAtPart ?? doc.state.rootPart//rootPart
		if lookAtPart != nil {
			lookAtVew 			= rootVew.find(part:lookAtPart!, inMe2:true)
		}
		let posn				= lookAtVew?.bBox.center ?? .zero
		pole.worldPosition		= lookAtVew?.scn.convertPosition(posn, to:rootScn) ?? .zero
		assert(!pole.worldPosition.isNan, "About to use a NAN World Position")

		updateCameraTransform(for:"installRootPart")

		// 6. UNLOCK PartTree and VewTree:
		unlock(              rootVewAs:lockStr)
		doc.state.rootPart.unlock(partTreeAs:lockStr)
	}

// /////////////////////////////////////////////////////////////////////////////
// ///////////////////  SCNSceneRendererDelegate:  /////////////////////////////
// /////////////////////////////////////////////////////////////////////////////

	// SCNSceneRenderer SCNDebugOptions
//https://iosdevelopers.slack.com/archives/CKA5E2RRC/p1608840518199300?thread_ts=1608775058.167600&cid=CKA5E2RRC
	enum SCNSceneRendererMode { case OFF, onMainThread}	//, normal
	var scnSceneRendererMode : SCNSceneRendererMode = .OFF
	var logRenderDelegate		= false		//false//true
	// Running on CVDisplayLink(8) Queue:
	//	com.apple.scenekit.renderingQueue.SwiftFactals.FwView0x7fe3c00067a0 (serial)
	func dispatchSomewhere(_ closure:DispatchWorkItem) {
		switch scnSceneRendererMode {
		case .OFF:	nop
//		case .normal: closure
		case .onMainThread: DispatchQueue.main.async(execute: closure)
		}
	}

	  // MARK: - 9.5.1: Update At Time					-- Update Vew and Scn from Part
	func renderer(_ r:SCNSceneRenderer, updateAtTime t: TimeInterval) {
		DispatchQueue.main.async {
			r.isPlaying			= true
			atRsi(8, self.logd("\n<><><> 9.5.1: Update At Time       -> updateVewSizePaint"))
			self.rootVew.updateVewSizePaint(needsViewLock:"renderLoop", logIf:false)		//false//true
		}
	}
	  // MARK: - 9.5.2: Did Apply Animations At Time	-- Compute Spring force L+P*
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
			self.rootPart.computeLinkForces(vew:self.rootVew)
		}
	}
	  // MARK: - 9.5.3: Did Simulate Physics At Time	-- Apply spring forces	  P*
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
			self.rootPart.applyLinkForces(vew:self.rootVew)
		}
	}
	  // MARK: - 9.5.4: Will Render Scene				-- Rotate Links to cam	L+P*
	public func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			self.rootPart.rotateLinkSkins(vew:self.rootVew)
		}
	}
//	   // ODD Timing:
//	  // MARK: - 9.5.@: did Render Scene
//	public func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//		atRsi(8, self.logd("<><><> 9.5.@: Scenes Rendered -- NOP"))
//	}
//	  // MARK: - 9.5.*: Did Apply Constraints At Time
//	public func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
//		atRsi(8, self.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
//	}

	 // MARK: - 9.E Physics Contact Protocol
	   // //////////////////////////////////////////////////////////////////////
	  //
	func physicsWorld(_ world:SCNPhysicsWorld, didBegin  contact:SCNPhysicsContact) {
		panic("physicsWorld(_, didBegin:contact")
	}
    func physicsWorld(_ world:SCNPhysicsWorld, didUpdate contact:SCNPhysicsContact) {
		panic("physicsWorld(_, didUpdate:contact")
	}
    func physicsWorld(_ world:SCNPhysicsWorld, didEnd    contact:SCNPhysicsContact) {
		panic("physicsWorld(_, didEnd:contact")
	}
	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: Key was recognized
	func processKey(from nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
 		let character			= nsEvent.charactersIgnoringModifiers!.first!
		if nsEvent.type == .keyUp {			// ///// Key UP ////// //
			return false
		}
		let modifierKeys		= nsEvent.modifierFlags
		let cmd 				= modifierKeys.contains(.command)
		let alt 				= modifierKeys.contains(.option)
		let doc					= DOC!

		switch character {
		case "r": // (+ cmd)
			if cmd {
				panic("Press 'cmd r'   A G A I N    to rerun")	// break to debugger
				return true 									// continue
			}
	  //case "r" alone:
			print("\n******************** 'r': === play(sound(\"GameStarting\")\n")
			rootScn.play(sound:"Oooooooo")		//GameStarting
		case "v":	
			print("\n******************** 'v': ==== Views:")
			print("\(rootVew.pp(.tree))", terminator:"")
		case "n":	
			print("\n******************** 'n': ==== SCNNodes:")
			DOCLOG.ppIndentCols = 3
			let x				= rootScn.pp(.tree)
//			let x				= rootScn.pp(.tree, ["ppIndentCols":3] )
			print(x, terminator:"")
//			print("\(rootScn.pp(a.tree, ["ppIndentCols":14] ))", terminator:"")
		case "#":
			let documentDirURL	= try! FileManager.default.url(
											for:.documentDirectory,
											in:.userDomainMask,
											appropriateFor:nil,
											create:true)
			let suffix			= alt ? ".dae" : ".scn"
			let fileURL 		= documentDirURL.appendingPathComponent("dumpSCN" + suffix)//.dae//scn//
			print("\n******************** '#': ==== Write out SCNNode to \(documentDirURL)dumpSCN\(suffix):\n")
			guard write(to:fileURL, delegate:nil) == false else {
				fatalError("writing dumpSCN.\(suffix) failed")
			}
			nop
		case "V":
			print("\n******************** 'V': Build the Model's Views:\n")
			doc.state.rootPart.forAllParts({	$0.markTree(dirty:.vew)		})
			rootVew.updateVewSizePaint()
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			doc.state.rootPart.forAllParts({	$0.markTree(dirty:.size)		})
			rootVew.updateVewSizePaint()
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
			doc.state.rootPart.forAllParts({	$0.markTree(dirty:.paint)		})
			rootVew.updateVewSizePaint()
		case "w":
			print("\n******************** 'w': ==== FwScene Camera = [\(ppCam())]\n")
		case "x":
			print("\n******************** 'x':   === FwScene: --> rootPart")
			if doc.state.rootPart.processKey(from:nsEvent, inVew:vew) {
				print("ERROR: fwScene.Process('x') failed")
			}
			return true								// recognize both
		case "f": 					// // f // //
			animatePhysics 		= !animatePhysics
			let msg 			= animatePhysics ? "Run   " : "Freeze"
			print("\n******************** 'f':   === FwScene: animatePhysics <-- \(msg)")
			return true								// recognize both
		case "?":
			Swift.print ("\n=== FwScene      commands:",
				"\t'r'             -- r sound test",
				"\t'r'+cmd         -- go to lldb for rerun",
				"\t'v'             -- print Vew tree",
				"\t'n'             -- print User's SCNNode tree",
				"\t'#'             -- write out SCNNode tree as .scn",
				"\t'#'+alt         -- write out SCNNode tree as .dae",
				"\t'V'             -- build the Model's Views",
				"\t'T'             -- Size and pack the Model's Views",
				"\t'P'             -- Paint the skins of Views",
				"\t'w'             -- print FwScene camera",
				"\t'x'             -- send to model",
				"\t'f'             -- Freeze SceneKit Animations",
				separator:"\n")
			return false
		default:					// // NOT RECOGNIZED // //
			return false
		}
		return true					// comes here if recognized
	}
//
//														  // ///////////////////////// //////////// //
//														 // ///                   /// //
//														// ///		 PIC         /// //
//													   // ///                   /// //
//										 // //////////// ///////////////////////// //
//										
//										/// Mouse Down NSEvent becomes a FwEvent to open the selected vew
//										/// - Parameter nsEvent: mouse down
//										/// - Returns: The Vew of the part pressed
//										func modelPic(with nsEvent:NSEvent) -> Vew?
//										{
//											 // CONVERT to window coordinates
//									bug//	let view				= DOC?.fwView
//									//		if let mouse 			= view?.convert(nsEvent.locationInWindow, from:view),
//									//		   // SELECT 3D point from 2D position
//									//		  let picdVew			= findVew(at:mouse)
//									//		{
//									//			 // DISPATCH to PART that was pic'ed
//									//			if picdVew.part.processKey(from:nsEvent, inVew:picdVew) == false {
//									//				atEve(3, print("\t\t" + "\(picdVew.part.pp(.fullName)).processKey('') ignored\n"))
//									//				return nil
//									//			}
//									//			return picdVew
//									//		}
//											atEve(3, print("\t\t" + "** No Part FOUND\n"))
//											return nil
//										}
//										func findVew(at mouse:CGPoint) -> Vew? {
//											var msg					= "******************************************\n modelPic:\t"
//
//											 // Find the 3D Vew for the Part under the mouse:
//											let configHitTest : [SCNHitTestOption:Any]? = [
//												.backFaceCulling	:true,	// ++ ignore faces not oriented toward the camera.
//												.boundingBoxOnly	:false,	// search for objects by bounding box only.
//												.categoryBitMask	:		// ++ search only for objects with value overlapping this bitmask
//														FwNodeCategory.picable  .rawValue  |// 3:works ??, f:all drop together
//														FwNodeCategory.byDefault.rawValue  ,		
//												.clipToZRange		:true,	// search for objects only within the depth range zNear and zFar
//											  //.ignoreChildNodes	:true,	// BAD ignore child nodes when searching
//											  //.ignoreHiddenNodes	:true 	// ignore hidden nodes not rendered when searching.
//												.searchMode:1,				// ++ any:2, all:1. closest:0, //SCNHitTestSearchMode.closest
//											  //.sortResults:1, 			// (implied)
//												.rootNode:rootScn, 			// The root of the node hierarchy to be searched.
//											]
//									bug;	return nil
//									//		//						 + +   + +
//									//		let hits				= DOC.fwView?.hitTest(mouse, options:configHitTest) ?? []
//									//		//						 + +   + +
//									//
//									//		 // SELECT HIT; prefer any child to its parents:
//									//		var rv					= rootVew			// Nothing hit -> root
//									//		if var pickedScn		= trunkVew?.scn {	// pic trunkVew
//									//			if hits.count > 0 {
//									//				 // There is a HIT on a 3D object:
//									//				let sortedHits	= hits.sorted { $0.node.deapth > $1.node.deapth }
//									//				pickedScn		= sortedHits[0].node // pic node with lowest deapth
//									//				msg 			+= "SCNNode: \((pickedScn.name ?? "8r23").field(-10)): "
//									//
//									//				 // If Node not picable,
//									//				while pickedScn.categoryBitMask & FwNodeCategory.picable.rawValue == 0,
//									//				  let parent 	= pickedScn.parent 	// try its parent:
//									//				{
//									//					msg			+= fmt("--> Ignore mask %02x", pickedScn.categoryBitMask)
//									//					pickedScn 	= parent				// use parent
//									//					msg 		+= "\n\t" + "parent:\t" + "SCNNode: \(pickedScn.fullName): "
//									//				}
//									//				 // Got SCN, get its Vew
//									//				if let cv		= trunkVew,
//									//				  let vew 		= cv.find(scnNode:pickedScn, inMe2:true)
//									//				{
//									//					rv			= vew
//									//					msg			+= "      ===>    ####  \(vew.part.pp(.fullNameUidClass))  ####"
//									//				}else{
//									//					panic(msg + "\n" + "couldn't find vew for scn:\(pickedScn.fullName)")
//									//					if let cv	= trunkVew,				// for debug only
//									//					  let vew 	= cv.find(scnNode:pickedScn, inMe2:true) {
//									//						let _	= vew
//									//					}
//									//				}
//									//			}else{
//									//				 // Background hit
//									//				msg				+= "background -> trunkVew"
//									//			}
//									//		}else{
//									//			print("trunkVew.scn nil")
//									//		}
//									//		atEve(3, print("\n" + msg))
//									//		return rv
//										}
	
	 /// Toggel the specified vew, between open and atom
	func toggelOpen(vew:Vew) {

		 // Toggel vew.expose: .open <--> .atomic
		vew.expose 				= vew.expose == .open   ? .atomic :
								  vew.expose == .atomic ? .open :
								  						  .null
	//	SCNTransaction.begin()
		assert(vew.expose != .null, "")
		let part				= vew.part

//		 // ========= Get Locks for two resources, in order: =============
//		guard experiment!.lock(partTreeAs:"toggelOpen") else {
//			fatalError("toggelOpen couldn't get PART lock")	}		// or
//		guard lock(rootVewAs:"toggelOpen") else {fatalError("couldn't get lock") }
//
//		assert(!(part is Link), "cannot toggelOpen a Link")
//		atAni(5, part.logg("Removed old Vew '\(vew.fullName)' and its SCNNode"))
//		vew.scn.removeFromParent()
//		vew.removeFromParent()
//		updateVewSizePaint(needsLock:"toggelOpen4")
//
//		// ===== Release Locks for two resources, in reverse order: =========
//		unlock(            rootVewAs:"toggelOpen")										//		ctl.experiment.unlock(partTreeAs:"toggelOpen")
//		experiment!.unlock(partTreeAs:"toggelOpen")

		updateCameraTransform(for:"toggelOpen")
		atAni(4, part.logd("expose = << \(vew.expose) >>"))
		atAni(4, part.logd(rootPart.pp(.tree)))
	}
//		if config4scene.bool_("animateOpen") {	//$	/// Works iff no PhysicsBody //true ||
//
//			 // Mark old SCNNode as Morphing
//			let oldScn			= vew.scn
//			vew  .name			= "M" + vew   .name		// move old vew out of the way
//			oldScn.name!		= "M" + oldScn.name!	// move old scn out of the way
//			oldScn.scale		= .unity * 0.5			// debug
//			vew.part.markTree(dirty:.vew)				// mark Part as needing reVew
//
//			 //*******// Imprint animation parameters JUST BEFORE start:
//			updateVewSizePaint()				// Update SCN's at START of animation
//			 //*******//
//
//			 // Animate Vew morph, from self to newVew:
//			guard let newScn	= vew.parent?.find(name:"_" + part.name)?.scn else {
//				fatalError("updateVew didn't creat a new '_<name>' vew!!")
//			}
//			newScn.scale		= .unity * 0.3 //0.1, 0.0 	// New before Fade-in	-- zero size
//			oldScn.scale		= .unity * 0.7 //0.9, 1.0	// Old before Fade-out	-- full size
//
//			SCNTransaction.begin()
//			atRve??(8, logg("  /#######  SCNTransaction: BEGIN"))
//			SCNTransaction.animationDuration = CFTimeInterval(3)//3//0.3//10//
//			 // Imprint parameters AFTER "togelOpen" ends:
//			newScn.scale		= SCNVector3(0.7, 0.7, 0.7)	//.unity						// After Fade-in
//			oldScn.scale 		= SCNVector3(0.3, 0.3, 0.3) //.zero							// After Fade-out
//
//			SCNTransaction.completionBlock 	= {
//				 // Imprint JUST AFTER end, with OLD removed (Note: OLD == self):
//				assert(vew.scn == oldScn, "oops")
//				part.logg("Removed old Vew '\(vew.fullName)' and its SCNNode")
//				newScn.scale	= .unity
//				oldScn.scale 	= .unity	// ?? reset for next time (Elim's BUG?)
//				oldScn.removeFromParent()
//				vew.removeFromParent()
//				//*******//
//				self.updateVewSizePaint()	// Imprint AFTER animation
//				//*******//	// //// wants a third animatio	qn (someday):
//			}
//			atRve??(8, logg("  \\#######  SCNTransaction: COMMIT"))
//			SCNTransaction.commit()
//		}

	//https://forums.developer.apple.com/thread/111572
	//			let morpher 		= SCNMorpher()  
	//			morpher.targets 	= [scn.geometry!]  	/// our old geometry will morph to 0
	//		let node = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 5, chamferRadius: 0))  
	//		Controller.current?.fwScene.rootNode.addChildNode(node)  
	//		node.morpher = morpher  
	//		let anim = CABasicAnimation(keyPath: "morpher.weights[0]")  
	//		anim.fromValue = 0.0  
	//		anim.toValue = 1.0 
	//		anim.autoreverses = true
	//		anim.duration = 1  
	//		node.addAnimation(anim, forKey: nil)  

	//	else {			/// just TEST CODE:
	//		let x				= CGFloat(0.2)
	//		let xPct			= SCNVector3(x, x, x)
	//		 /// Imprint Initial Vew, before newScn has non-zero size
	//		viewNew.scn.scale 	= xPct//.zero
	//		self   .scn.scale 	= .unity
	//		fws.updateVewSizePaint(needsLock:"toggelOpen5")	//\\//\\//\\//\\ To beginning of animation
	//		 /// Imprint Final Vew
	//		viewNew.scn.scale 	= .unity
	//		self   .scn.scale 	= .zero//xPct//
	//		fws.updateVewSizePaint(needsLock:"toggelOpen6")	//\\//\\//\\//\\ To end of animation
	//
	//		 /// Remove old vew and its SCNNode
	//		atAni(4, log("Removed old Vew '\(fullName)' and its SCNNode"))
	//		scn.scale			= .unity
	//		scn.removeFromParent()
	//		removeFromParent()
	//	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
		switch mode {
		case .tree:
			var rv = ""
//			for (msg, obj) in [("light1", light1), ("light2", light2), ("camera", cameraNode)] {
//				rv				+= "\(msg) =       \(obj.categoryBitMask)-"
//				rv				+= "\(obj.description.shortenStringDescribing())\n"
//			}
			let c = lastSelfiePole
			rv += fmt("\t\t\t\t[h:%.2f, s:%.0f, u:%.0f, z:%.4f]", c.cameraPoleHeight,
					c.cameraPoleSpin, c.cameraHorizonUp, c.cameraZoom) // in degrees
			return rv
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
//		return "FwScene: scnTrunk:'\(scnRoot.name ?? "<unnamed>")',  trunkVew:'\(trunkVew?.name ?? "<unnamed>")'"
//		return "FwScene: scnRoot=\(scnRoot.name ?? "<unnamed>")"
	}
	func ppCam() -> String {
		let c = lastSelfiePole
		return fmt("h:%.0f, s:%.0f, u:%.0f, z:%.3f",
				c.cameraPoleHeight, c.cameraPoleSpin, c.cameraHorizonUp, c.cameraZoom)
	}
}

