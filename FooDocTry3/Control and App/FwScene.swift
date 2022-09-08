//  FwScene.swift -- All the 3D things in a FwView 2D window  C2018PAK

// Supports: Camera, Lights, 3D Cursor,
//   Collisions, Animations (esp for positioning)

import SceneKit

//		Concepts:
//	The camera is positioned in the world with the camera transform
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
class FwScene : SCNScene, SCNPhysicsContactDelegate {	//, SCNSceneRendererDelegate

	  // MARK: - 2. Object Variables:
	 // ///////// Part Tree:
//	var rootPart : RootPart		{	rootVew.part as! RootPart					}
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
	weak
	 var fwView	 : FwView?		= nil

	func convertToRoot(windowPosition:NSPoint) -> NSPoint {
		let wpV3 : SCNVector3	= SCNVector3(windowPosition.x, windowPosition.y, 0)
		let vpV3 : SCNVector3	= rootVew.scn.convertPosition(wpV3, from:nil)
		return NSPoint(x:vpV3.x, y:vpV3.y)
	}

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
		atCon(6, logd("init(fwConfig:\(fwConfig.pp(.line).wrap(min: 30, cur: 44, max: 100))"))

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
	init?(named name:String) {
		let url					= Bundle.main.url(forResource: "ship", withExtension: "scn", subdirectory: "art.scnassets")

		//	Must call a designated initializer of the superclass 'SCNScene'
// 1.	super.init(named:name) //, inDirectory:"", options:[:])
						//		let y  							= SCNScene(named:name)!
						//		let w0 							= y.scene
						//		let w1 							= y.sceneSource
						//		let w2 : SCNPhysicsWorld		= y.physicsWorld
						//		self.physicsWorld				= w2
						//		let w3 : SCNNode				= y.rootNode
						//		let w4 							= y.layerRootNode
						//		let w5 : SCNMaterialProperty	= y.background
						//		let w6 							= y.environment
						//		let w7 							= y.userAttributes
// 2.	do { try super.init(url:url!)											}
//		catch { fatalError()													}

    	super.init()
		let options 			= [SCNSceneSource.LoadingOption : Any]()
		let sceneSource			= SCNSceneSource(url:url!, options:options)!
		let node				= sceneSource.entryWithIdentifier("ship.scn", withClass: SCNNode.self)!

		//let armature 			= sceneSource.entryWithIdentifier("Armature", withClass: SCNNode.self)!
		//armature.removeAllAnimations()
		//node.addChildNode(armature)
		//loadAnimation("rest", daeNamed: daeNamed)
		//playAnimation("rest")
	}
//	init(modelNamed:String, daeNamed:String){
//		let url					= Bundle.main.url(forResource:"ship", withExtension: "scn", subdirectory: "art.scnassets")
//		let sceneSource 		= SCNSceneSource(url:url!, options: nil)!
//
//		let node				= sceneSource.entryWithIdentifier(modelNamed, withClass: SCNNode.self)!
//
//		//let armature 			= sceneSource.entryWithIdentifier("Armature", withClass: SCNNode.self)!
//
//		//store and trigger the "rest" animation
//
//		node.position 			= SCNVector3(0, 10, 0)
//	}


//	override init() {
//		super.init()
//	}
//
//	required init(coder aDecoder: NSCoder)? {
//		super.init(coder: aDecoder)
//	}

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
	 // MARK: - 9.B Camera
	 // Get camera node from SCNNode
	var cameraNode : CameraNode! = nil
	func addCameraNode(_ config:FwConfig) {

		 // Detect a Straggler
		if let stragglerNode	= rootScn.find(name:"camera") {
			let msg				= stragglerNode == cameraNode ? "" : " and no match to cameraNode"
			warning("Who put this camera here? !!!" + msg)
			stragglerNode.removeFromParentNode()
		}
		cameraNode				= CameraNode(config)
		cameraNode.name			= "camera"
		cameraNode.position 	= SCNVector3(0, 0, 100)	// HACK: must agree with updateCameraRotator
		rootScn.addChildNode(cameraNode!)
	}
	 // MARK: - 9.C Lights
	func addLights() {
		let _ 					= helper("light1",	.omni,	 position:SCNVector3(0, 0, 15))
		let _ 					= helper("ambient1",.ambient,color:NSColor.darkGray)
		let _ 					= helper("ambient2",.ambient,color:NSColor.white, intensity:500)				//blue//
		let _ 					= helper("omni1",	.omni,	 color:NSColor.green, intensity:500)				//blue//
//		let _ 					= helper("omni2",	.omni,	 color:NSColor.red,   intensity:500)				//blue//
//		let spot 				= helper("spot",	.spot,	 position:SCNVector3(1.5, 1.5, 1.5))
//		 spot.light!.spotInnerAngle = 30.0
//		 spot.light!.spotOuterAngle = 80.0
//		 spot.light!.castsShadow = true
//		 let constraint = SCNLookAtConstraint(target:nil)
//		 constraint.isGimbalLockEnabled = true
//		 cameraNode.constraints = [constraint]
//		 spot.constraints = [constraint]

		func helper(_ name:String, _ lightType:SCNLight.LightType, color:Any?=nil,
					position:SCNVector3?=nil, intensity:CGFloat=100) -> SCNNode {
			 // Detect a Straggler
			if let stragglerNode = rootScn.find(name:name) {
				warning("Who put the node named '\(name)' here? !!!")
				stragglerNode.removeFromParentNode()
			}
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
	  // MARK: - 9.D Pole
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
	 // MARK: - 9.E Look AT
	var lookAtPart : Part? 		= nil
	var lookAtVew  : Vew?		= nil
	 // MARK: - 9.C Mouse Rotator
	 // Uses Cylindrical Coordinates
	struct SelfiePole {
		var height		: CGFloat = 0
		var spin  		: CGFloat = 0					// in degrees
		var horizonUp	: CGFloat = 0					// in degrees
		var zoom		: CGFloat = 1.0
		var uid			: UInt16  = randomUid()
//		init() {
//			height				= 0
//			spin				= 0					// in degrees
//			horizonUp		= 0					// in degrees
//			zoom				= 1.0
//		}
	}
	var lastSelfiePole = SelfiePole()						// init to default

	/// Compute Camera Transform from pole config
	/// - Parameters:
	///   - from: defines direction of camera
	///   - message: for logging only
	///   - duration: for animation
	func updateCameraTransform(from:SelfiePole?=nil, for message:String?=nil, overTime duration:Float=0.0) {
		let pole : SelfiePole	= from ?? lastSelfiePole

			// Imagine a camera A on a selfie stick, pointing back to the holder B
		   //
		  // From Origin to Camera, in steps: Pole about Origin
		 //  ---- spun about Y axis
		let spin				= pole.spin * .pi / 180.0
		var poleSpinAboutY		= SCNMatrix4MakeRotation(spin, 0, 1, 0)

		 //  ---- translated above Point of Interest by cameraPoleHeight
		let posn				= lookAtVew?.bBox.center ?? .zero
		let lookAtWorldPosn		= lookAtVew?.scn.convertPosition(posn, to:rootScn) ?? .zero
		 assert(!lookAtWorldPosn.isNan, "About to use a NAN World Position")
		let lap 				= lookAtWorldPosn
		poleSpinAboutY.position	= SCNVector3(lap.x, lap.y+pole.height, lap.z)

		 //  ---- With a boom (crane or derek) raised upward above the horizon:
		let upTilt				= pole.horizonUp * .pi / 180.0
		let riseAboveHoriz		= SCNMatrix4MakeRotation(upTilt, 1, 0, 0)

		 //  ---- move out boom from pole, looking backward:
		let toEndOfBoom			= SCNMatrix4Translate(SCNMatrix4.identity, 0, 0, 50*pole.zoom) //cameraZoom)//10 ad hoc .5

		let newCameraXform		= toEndOfBoom * riseAboveHoriz * poleSpinAboutY
		assert(!newCameraXform.isNan, "newCameraXform is Not a Number")
		assert(newCameraXform.at(3,3) == 1.0, "why?")	// Understand cameraXform.at(3,3). Is it 1.0? is it prudent to change it here


		  // Determine magnification so all parts of the 3D object are seen.
		 //
		let rootVewBbInWorld	= rootVew.bBox			// in world coords
		let world2eye			= SCNMatrix4Invert(cameraNode.transform)		//rootVew.scn.convertTransform(.identity, to:nil)	// to screen coordinates
		let rootVewBbInEye		= rootVewBbInWorld.transformed(by:world2eye)
		let rootVewSizeInEye	= rootVewBbInEye.size
		guard let nsRectSize	= fwView?.frame.size  else  {	fatalError()	}

					// Landscape window ------------------
		var orientation			= "Landscape"
		var orthoScale			= rootVewSizeInEye.x	// 1 ==> unit cube fills screen
		 // Is side going to be clipped off?
		let ratioHigher			= nsRectSize.height / nsRectSize.width
		if rootVewSizeInEye.y > rootVewSizeInEye.x * ratioHigher {
			orthoScale			*= ratioHigher
		}
		if rootVewSizeInEye.x * nsRectSize.height < nsRectSize.width * rootVewSizeInEye.y {
					// Portrait window ------------------
			orientation			= "Portrait"
			orthoScale			= rootVewSizeInEye.y
			 // Is top going to be clipped off?
			if rootVewSizeInEye.x > rootVewSizeInEye.y / ratioHigher {
				orthoScale		/= ratioHigher
			}
		}
		let vanishingPoint 		= config4scene.double("vanishingPoint")
		if (vanishingPoint?.isFinite ?? true) == false {		// Ortho if no vp, or vp=inf
			  // https://blender.stackexchange.com/questions/52500/orthographic-scale-of-camera-in-blender
			 // https://stackoverflow.com/questions/52428397/confused-about-orthographic-projection-of-camera-in-scenekit
			let x = rootNode.pp()
			guard let cam		= cameraNode.camera else { fatalError("cameraNode.camera is nil") 	}
			cam.usesOrthographicProjection = true		// camera’s magnification factor
			cam.orthographicScale = Double(orthoScale * pole.zoom * 0.75)
		}
		print(fmt("\(orientation):\(rootVewBbInEye.pp(.line)), vanishingPoint:%.2f)", orthoScale, vanishingPoint ?? -.infinity))

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

			//print("\(newCameraXform.pp(.tree))")
		}
	}

	 /// Build Vew tree from Part tree
	/// - Parameters:
	///   - rootPart: -- base of model
	///   - lockStr: -- if non-nil, get this lock
	func installRootPart(_ rootPart:RootPart, reason lockStr:String?=nil) { 	// Make the  _VIEW_  from Experiment

		 // 1. Get LOCKS for PartTree
		guard DOCrootPart.lock(partTreeAs:lockStr) else {
			fatalError("\(lockStr ?? "-") couldn't get PART lock")		// or
		}// 2.           and VewTree
		guard lock(rootVewAs:lockStr) else {
			fatalError("\(lockStr ?? "-") couldn't get VIEW lock")
		}
			
		// --------- Link rootVew and rootScn to rootPart
											// // --------- Link rootVew and rootScn to rootPart
											// func checkIt<T : Equatable >(_ tIs:inout T, _ tGood:T) {
											// 	if tIs != tGood {
											// 		print("--- Found \(tIs):\(T.self), should be \(tGood):\(T.self)")
											// 		tIs = tGood
											// 	}
											// }		// current:			// correct:
		rootVew.name		 	= "_ROOT"	// checkIt(&rootVew.name, 		"_ROOT")
		rootVew.part			= rootPart	// checkIt(&rootVew.part, 		rootPart)
		rootVew.part.name		= "ROOT"	// checkIt(&rootVew.part.name,	"ROOT")			// matches
		rootVew.scn				= rootScn	// checkIt(&rootVew.scn, 		rootScn)
		rootScn.name			= "*-ROOT"	// checkIt(&rootScn.name, 		"*-ROOT")

//		doc.fwView?.showsStatistics = true	// MUST BE HERE, DOESN'T WORK in FwView
//		doc.fwView?.window!.backgroundColor = NSColor.yellow // why? cocoahead x: only frame
//		doc.fwView?.isPlaying	= true		// WTF??

		 // 3. Add Camera, Light, and Pole
		addLights()
		addCameraNode(config4scene)
		
		if config4scene.bool_("pole") {
			updatePole()
		}

		 // 4. Look At Node:
		if let lookAtPart		= lookAtPart ?? DOCrootPartQ {
			lookAtVew 			= rootVew.find(part:lookAtPart, inMe2:true)
		}
		let posn				= lookAtVew?.bBox.center ?? .zero
		pole.worldPosition		= lookAtVew?.scn.convertPosition(posn, to:rootScn) ?? .zero
		assert(!pole.worldPosition.isNan, "About to use a NAN World Position")

		updateCameraTransform(for:"installRootPart")

		 // 4. Update Vew Tree
/**/	rootVew.updateVewSizePaint(needsViewLock:nil)
		atRve(6, logd("updateVewSizePaint(needsViewLock:) completed"))

		// 6. UNLOCK PartTree and VewTree:
		unlock(              rootVewAs:lockStr)
		DOCrootPart.unlock(partTreeAs:lockStr)
	}

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
	 // MARK: - 13.1 Keys
	var isAutoRepeat : Bool 	= false // filter out AUTOREPEAT keys

	func receivedEvent(nsEvent:NSEvent) {
		print("--- func received(nsEvent:\(nsEvent))")

		// MARK: - 13.2 Mouse
		//  ====== LEFT MOUSE ======
		let nsTrackPad			= true//false//
		let duration			= Float(1)
		var mouseWasDragged		= false

		switch nsEvent.type {
		case .keyDown:
			if nsEvent.isARepeat {	return }			// Ignore repeats
			guard let char : String	= nsEvent.charactersIgnoringModifiers else { return }
			assert(char.count==1, "multiple keystrokes not supported")
			guard !isAutoRepeat		else { fatalError("the above isARepeat didn't work!")}
			isAutoRepeat 		= true
			if DOC!.processKey(from:nsEvent, inVew:nil) {
				if char != "?" {		// okay for "?" to get here
					atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
				}
			}
		case .keyUp:
			assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
			isAutoRepeat 		= false
			let _				= DOC?.processKey(from:nsEvent, inVew:nil)

		 //  ====== LEFT MOUSE ======
		case .leftMouseDown:
			motionFromLastEvent(with:nsEvent)
			if !nsTrackPad  {					// 3-button Mouse
				modelPic(with:nsEvent)
			}
			updateCameraTransform(for:"Left mouseDown", overTime:duration)
		case .leftMouseDragged:	// override func mouseDragged(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				mouseWasDragged = true		// drag cancels pic
				spinNUp(with:nsEvent)			// change Spin and Up of camera
				updateCameraTransform(for:"Left mouseDragged")
			}
		case .leftMouseUp:	// override func mouseUp(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				if !mouseWasDragged {			// UnDragged Up
					let _		= modelPic(with:nsEvent)
				}
				mouseWasDragged = false
				updateCameraTransform(for:"Left mouseUp", overTime:duration)
			}
		 //  ====== CENTER MOUSE ======
		case .otherMouseDown:	// override func otherMouseDown(with nsEvent:NSEvent)	{
			motionFromLastEvent(with:nsEvent)
			updateCameraTransform(for:"Other mouseDown", overTime:duration)
		case .otherMouseDragged:	// override func otherMouseDragged(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			spinNUp(with:nsEvent)
			mouseWasDragged 	= true		// drag cancels pic
			updateCameraTransform(for:"Other mouseDragged")
		case .otherMouseUp:	// override func otherMouseUp(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			updateCameraTransform(for:"Other mouseUp", overTime:duration)
			print("camera = [\(ppCam())]")
			//at("All", 3, print("camera = [\(fwScene!.ppCam())]"))
			atEve(9, print("\(cameraNode.transform.pp(.tree)))"))
		 //  ====== CENTER SCROLL WHEEL ======
		case .scrollWheel: nop
			let d				= nsEvent.deltaY
			let delta : CGFloat	= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
			let scene			= DOCfwScene
			scene.lastSelfiePole.zoom *= delta
			print("receivedEvent(type:.scrollWheel) found pole\(scene.lastSelfiePole.uid).zoom = \(scene.lastSelfiePole.zoom)")
			scene.updateCameraTransform(for:"Scroll Wheel")
		 //  ====== RIGHT MOUSE ======			Right Mouse not used

		//case 8:	// override func touchesBegan(with event:NSEvent) {
		//	let t 				= event.touches(matching:.began, in:self)
		//	for touch in t {
		//		let _:CGPoint	= touch.location(in:nil)
		//	}
		//case 9:	//override func touchesMoved(with event:NSEvent) {
		//	let t 				= event.touches(matching:.began, in:self)
		//	for touch in t {
		//		let prevLoc		= touch.previousLocation(in:nil)
		//		let loc			= touch.location(in:nil)
		//		atEve(3, (print("\(prevLoc) \(loc)")))
		//	//	let prevKey		= soloKeyboard?.keyAt(point:prevLoc)
		//	//	let key			= soloKeyboard?.keyAt(point:loc)
		//	//	key?.curPoint	= loc
		//	}
		//case 10:	//override func touchesEnded(with event:NSEvent) {
		//	let t 				= event.touches(matching:.began, in:self)
		//	for touch in t {
		//		let _:CGPoint	= touch.location(in:nil)
		//	}
		default:
			print("33333333 receivedEvent(type:\(nsEvent.type)) EEEEEEE")
		}
	}
	 // MARK: - 13.4 Mouse Variables
	func motionFromLastEvent(with nsEvent:NSEvent) {
		if let view				= nsEvent.window?.contentView {
			let delt2d :CGPoint	= view.convert(nsEvent.locationInWindow, from: nil)//nil=screen
			// convert(_ point: NSPoint, from view: NSView?) -> NSPoint

			let eventPosn		= SCNVector3(delt2d.x, delt2d.y, 0)		// BAD: unprojectPoint(
			 // Movement since last
			let prevPosn : SCNVector3 = lastPosition ?? eventPosn
			deltaPosition		= eventPosn - prevPosn
			lastPosition		= eventPosn
		}
	}
	var lastPosition : SCNVector3? = nil				// spot cursor hit
	var deltaPosition			= SCNVector3.zero

	func spinNUp(with nsEvent:NSEvent) {
		lastSelfiePole.spin		 -= deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
		lastSelfiePole.horizonUp -= deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
	}

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
			DOClog.ppIndentCols = 3
			print(rootScn.pp(.tree), terminator:"")
			//aprint(rootScn.pp(.tree, ["ppIndentCols":3]), terminator:"") )
			//aprint("\(rootScn.pp(a.tree, ["ppIndentCols":14] ))", terminator:"")
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
			doc.docState.rootPart.forAllParts({	$0.markTree(dirty:.vew)		})
			rootVew.updateVewSizePaint()
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			doc.docState.rootPart.forAllParts({	$0.markTree(dirty:.size)		})
			rootVew.updateVewSizePaint()
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
			doc.docState.rootPart.forAllParts({	$0.markTree(dirty:.paint)		})
			rootVew.updateVewSizePaint()
		case "w":
			print("\n******************** 'w': ==== FwScene Camera = [\(ppCam())]\n")
		case "x":
			print("\n******************** 'x':   === FwScene: --> rootPart")
			if doc.docState.rootPart.processKey(from:nsEvent, inVew:vew!) {
				print("ERROR: fwScene.Process('x') failed")
			}
			return true								// recognize both
		case "f": 					// // f // //
			animatePhysics 		= !animatePhysics
			let msg 			= animatePhysics ? "Run   " : "Freeze"
			print("\n******************** 'f':   === FwScene: animatePhysics <-- \(msg)")
			return true								// recognize both
		case "?":
			Swift.print ("\n=== FwScene   commands:",
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

					  // ///////////////////////// //////////// //
					 // ///                   /// //
					// ///		 PIC         /// //
				   // ///                   /// //
	 // //////////// ///////////////////////// //
	
	/// Mouse Down NSEvent becomes a FwEvent to open the selected vew
	/// - Parameter nsEvent: mouse down
	/// - Returns: The Vew of the part pressed
	func modelPic(with nsEvent:NSEvent) -> Vew? {

		if let picdVew			= findVew(nsEvent:nsEvent) {
			 // DISPATCH to PART that was pic'ed
			if picdVew.part.processKey(from:nsEvent, inVew:picdVew) == false {
				atEve(3, print("\t\t" + "\(picdVew.part.pp(.fullName)).processKey('') ignored\n"))
				return nil
			}
			return picdVew
		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}

	func hitTest(_ point:CGPoint, options:[SCNHitTestOption:Any]?=nil) -> [SCNHitTestResult] {
//		return super.hitTest(point, options:options)//Value of type 'SCNScene' has no member 'hitTest'
		return [SCNHitTestResult()]
	}
//		let w = FwScene(fwConfig:[:])
//		let x					= w.hitTest(mouse, options:configHitTest)// ?? [SCNHitTestResult]()

	func findVew(nsEvent:NSEvent) -> Vew? {
		 // Find the 3D Vew for the Part under the mouse:
		let configHitTest : [SCNHitTestOption:Any]? = [
			.backFaceCulling	:true,	// ++ ignore faces not oriented toward the camera.
			.boundingBoxOnly	:false,	// search for objects by bounding box only.
			.categoryBitMask	:		// ++ search only for objects with value overlapping this bitmask
					FwNodeCategory.picable  .rawValue  |// 3:works ??, f:all drop together
					FwNodeCategory.byDefault.rawValue  ,
			.clipToZRange		:true,	// search for objects only within the depth range zNear and zFar
		  //.ignoreChildNodes	:true,	// BAD ignore child nodes when searching
		  //.ignoreHiddenNodes	:true 	// ignore hidden nodes not rendered when searching.
			.searchMode:1,				// ++ any:2, all:1. closest:0, //SCNHitTestSearchMode.closest
		  //.sortResults:1, 			// (implied)
			.rootNode:rootScn, 			// The root of the node hierarchy to be searched.
		]
		 // CONVERT to window coordinates
		let pt 	  	: NSPoint	= nsEvent.locationInWindow
		let mouse 	: NSPoint	= DOC!.docState.fwScene.convertToRoot(windowPosition:pt)
		var msg					= "******************************************\n findVew(nsEvent:)\t"

								//		 + +   + +
		var hits:[SCNHitTestResult]	= hitTest(mouse, options:configHitTest)
								//		 + +   + +

		 // SELECT HIT; prefer any child to its parents:
		var rv					= rootVew			// return root by default
		if var pickedScn		= trunkVew?.scn {	// pic trunkVew
			if hits.count > 0 {
				 // There is a HIT on a 3D object:
				let sortedHits	= hits.sorted { (a : SCNHitTestResult, b : SCNHitTestResult)  in
					a.node.position.z > b.node.position.z
				}
				pickedScn		= sortedHits[0].node // pic node with lowest deapth
				msg 			+= "SCNNode: \((pickedScn.name ?? "8r23").field(-10)): "

				 // If Node not picable,
				while pickedScn.categoryBitMask & FwNodeCategory.picable.rawValue == 0,
				  let parent 	= pickedScn.parent 	// try its parent:
				{
					msg			+= fmt("--> Ignore mask %02x", pickedScn.categoryBitMask)
					pickedScn 	= parent				// use parent
					msg 		+= "\n\t" + "parent:\t" + "SCNNode: \(pickedScn.fullName): "
				}
				 // Got SCN, get its Vew
				if let cv		= trunkVew,
				  let vew 		= cv.find(scnNode:pickedScn, inMe2:true)
				{
					rv			= vew
					msg			+= "      ===>    ####  \(vew.part.pp(.fullNameUidClass))  ####"
				}else{
					panic(msg + "\n" + "couldn't find vew for scn:\(pickedScn.fullName)")
					if let cv	= trunkVew,				// for debug only
					  let vew 	= cv.find(scnNode:pickedScn, inMe2:true) {
						let _	= vew
					}
				}
			}else{
				 // Background hit
				msg				+= "background -> trunkVew"
			}
		}
		atEve(3, print("\n" + msg))
		return rv
	}
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
			rv += fmt("\t\t\t\t[h:%.2f, s:%.0f, u:%.0f, z:%.4f]", c.height,
					c.spin, c.horizonUp, c.zoom) // in degrees
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
				c.height, c.spin, c.horizonUp, c.zoom)
	}
}

