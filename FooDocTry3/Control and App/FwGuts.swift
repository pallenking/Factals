//  FwGuts.swift -- All the 3D things in a FwView 2D window  C2018PAK

// Coordinates Operation of root, vew, and scn

import SceneKit
//
// // Kinds of Nodes
//enum FwNodeCategory : Int {
//	case byDefault				= 0x1		// default unpicable (piced by system)
//	case picable 				= 0x2		// picable
//	case adornment				= 0x4		// unpickable e.g. bounding box
//	case collides				= 0x8		// Experimental
//}
			//projectPoint(_:)
class FwGuts : NSObject, SCNSceneRendererDelegate, SCNPhysicsContactDelegate /*SCNScene */ {	//,

	  // MARK: - 2. Object Variables:
	var rootPart : RootPart														//{	rootVew.part as! RootPart}
	var rootVew  : RootVew
	var fwScn	 : FwScn
	var fooDocTry3Document : FooDocTry3Document!

	var config4fwGuts : FwConfig = [:] {
		didSet {	//if config4fwGuts != oldValue {

			let x				= config4fwGuts.bool("animatePhysics") ?? false
			fwScn.animatePhysics = x

			assert(config4fwGuts.bool("isPaused") == nil, "SCNScene.isPaused is now depricated, use 'animatePhysics' instead")
			if let gravityAny	= config4fwGuts["gravity"] {
				if let gravityVect : SCNVector3 = SCNVector3(from:gravityAny) {
					fwScn.scnScene.physicsWorld.gravity = gravityVect
				}
				else if let gravityY: Double = gravityAny.asDouble {
					fwScn.scnScene.physicsWorld.gravity.y = gravityY
				}
			}
			if let speed		= config4fwGuts.cgFloat("speed") {
				fwScn.scnScene.physicsWorld.speed = speed
			}
			//scnScene.physicsWorld.contactDelegate = nil//scnScene	/// Physics Contact Protocol is below
		}
	}
		//scnScene.physicsWorld.contactDelegate = nil//scnScene	/// Physics Contact Protocol is below
	 // MARK: - 3. Factory
	convenience init(rootPart:RootPart?=nil, fwConfig:FwConfig) {		//controller ctl:Controller? = nil,
		guard rootPart != nil else {	fatalError("FwGuts(rootPart is nil")	}

		self.init(scene:SCNScene(), rootPart:rootPart!, named:"")

		config4fwGuts			= fwConfig
		atCon(6, logd("init(fwConfig:\(fwConfig.pp(.line).wrap(min: 30, cur: 44, max: 100))"))
	}
	init(scene scene_:SCNScene?=nil, rootPart:RootPart, named name:String) {
		self.rootPart			= rootPart
		assert(scene_ != nil, "FwGuts(scene is nil")
		self.rootVew			= RootVew(forPart:rootPart, scn:scene_!.rootNode)
		self.fwScn				= FwScn(scnScene:scene_!)

		super.init()

		 // Back Links
		fwScn.fwGuts			= self
		rootVew.fwGuts			= self
	}

	// FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {

		do {		// 1. Write SCNScene to file. (older, SCNScene supported serialization)
bug//		try self.write(to: fileURL)
		} catch {
			print("error writing file: \(error)")
		}
					// 2. Get file to data
		let data				= try? Data(contentsOf:fileURL)
		return data//Cannot convert value of type '() -> ()' to expected argument type 'Int'
	}
	 // initialize new SCNScene from Data
	convenience init?(data:Data, encoding:String.Encoding) {
		do {		// 1. Write data to file.
			try data.write(to: fileURL)
		} catch {
			print("error writing file: \(error)")
		}
		self.init(fwConfig:[:])
bug
//		do {		// 2. Init self from file
//			try self.init(fwConfig:[:])
//	//		try super.init(url: fileURL)
//		} catch {
//			print("error initing from url: \(error)")
//			return nil
//		}
	}

	 // MARK: - 3.5 Codable
	 // ///////// Serialize
	func encode(to encoder: Encoder) throws  {
		fatalError("FwGuts.encode(coder..) unexpectantly called")
	}
	 // ///////// Deserialize
	required init(coder aDecoder: NSCoder) {
		fatalError("FwGuts.init(coder..) unexpectantly called")
	}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	 // MARK: - 3.7 Equitable substitute

	  // MARK: - 9.0 3D Support
	 // mouse may "paw through" parts, using wiggle
	var wiggledPart	  : Part?	= nil
	var wiggleOffset  : SCNVector3? = nil		// when mouse drags an atom

// /////////////////////////////////////////////////////////////////////////////
// ///////////////////  SCNSceneRendererDelegate:  /////////////////////////////
// /////////////////////////////////////////////////////////////////////////////
  // called by SCNSceneRenderer

		// MARK: - SCNSceneRendererDelegate
	  // MARK: - 9.5.1: Update At Time					-- Update Vew and Scn from Part
	func renderer(_ r:SCNSceneRenderer, updateAtTime t:TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("\n<><><> 9.5.1: Update At Time       -> updateVewSizePaint"))
			let v				= "updateAtTime"
			guard self.rootPart.lock(partTreeAs:v, logIf:false) else {fatalError(v+" couldn't get PART lock")}
			guard self.rootVew .lock(vewTreeAs: v, logIf:false) else {fatalError(v+" couldn't get VIEW lock")}

			DOCfwGuts.rootVew.updateVewSizePaint(needsLock:"renderLoop", logIf:false)		//false//true

			self    .rootPart.unlock(partTreeAs:v, logIf:false)
			self    .rootVew .unlock(vewTreeAs: v, logIf:false)
		}
	}
	  // MARK: 9.5.2: Did Apply Animations At Time	-- Compute Spring force L+P*
	func renderer(_ r:SCNSceneRenderer, didApplyAnimationsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("<><><> 9.5.2: Did Apply Animations -> computeLinkForces"))
			let v				= "didApplyAnimationsAtTime"
			guard self.rootPart.lock(partTreeAs:v, logIf:false) else {fatalError(v+" couldn't get PART lock")}
			guard self.rootVew .lock(vewTreeAs: v, logIf:false) else {fatalError(v+" couldn't get VIEW lock")}

			DOCrootPart.computeLinkForces(vew:DOCfwGuts.rootVew)

			self    .rootPart.unlock(partTreeAs:v, logIf:false)
			self    .rootVew .unlock(vewTreeAs: v, logIf:false)
		}
	}
	  // MARK: 9.5.3: Did Simulate Physics At Time	-- Apply spring forces	  P*
	func renderer(_ r:SCNSceneRenderer, didSimulatePhysicsAtTime atTime: TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("<><><> 9.5.3: Did Simulate Physics -> applyLinkForces"))
			let v				= "didSimulatePhysicsAtTime"
			guard self.rootPart.lock(partTreeAs:v, logIf:false) else {fatalError(v+" couldn't get PART lock")}
			guard self.rootVew .lock(vewTreeAs: v, logIf:false) else {fatalError(v+" couldn't get VIEW lock")}

			DOCrootPart.applyLinkForces(vew:DOCfwGuts.rootVew)

			self    .rootPart.unlock(partTreeAs:v, logIf:false)
			self    .rootVew .unlock(vewTreeAs: v, logIf:false)
		}
	}
	  // MARK: 9.5.4: Will Render Scene				-- Rotate Links to cam	L+P*
	public func renderer(_ r:SCNSceneRenderer, willRenderScene scene:SCNScene, atTime:TimeInterval) {
		DispatchQueue.main.async {
			atRsi(8, self.logd("<><><> 9.5.4: Will Render Scene    -> rotateLinkSkins"))
			let v				= "willRenderScene"
			guard self.rootPart.lock(partTreeAs:v, logIf:false) else {fatalError(v)}
			guard self.rootVew .lock(vewTreeAs: v, logIf:false) else {fatalError(v)}

			DOCrootPart.rotateLinkSkins(vew:DOCfwGuts.rootVew)

			self      .rootPart.unlock(partTreeAs:v, logIf:false)
			self      .rootVew .unlock(vewTreeAs: v, logIf:false)
		}
	}
	   // ODD Timing:
	  // MARK: 9.5.5: did Render Scene
	public func renderer(_ r:SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.@: Scenes Rendered -- NOP"))
	}
	  // MARK: 9.5.6: Did Apply Constraints At Time
	public func renderer(_ r:SCNSceneRenderer, didApplyConstraintsAtTime atTime: TimeInterval) {
		atRsi(8, self.logd("<><><> 9.5.*: Constraints Applied -- NOP"))
	}

	 // MARK: - 9.7 Physics Contact Protocol
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
	  // MARK: -

	 // MARK: - 13. IBActions
	var nextIsAutoRepeat : Bool 	= false 	// filter out AUTOREPEAT keys
	var mouseWasDragged			= false		// have dragging cancel pic

	func receivedEvent(nsEvent:NSEvent) {
		print("--- func received(nsEvent:\(nsEvent))")
		let nsTrackPad			= true//false//
		let duration			= Float(1)

		switch nsEvent.type {

		  //  ====== KEYBOARD ======
		 //
		case .keyDown:
			if nsEvent.isARepeat {	return }			// Ignore repeats
			guard let char : String	= nsEvent.charactersIgnoringModifiers else { return }
			assert(char.count==1, "multiple keystrokes not supported")
			nextIsAutoRepeat 	= true
			if fooDocTry3Document.processKey(from:nsEvent, inVew:nil) == false {
				if char != "?" {		// okay for "?" to get here
					atEve(3, print("    ==== nsEvent not processed\n\(nsEvent)"))
				}
			}
		case .keyUp:
			assert(nsEvent.charactersIgnoringModifiers?.count == 1, "1 key at a time")
			nextIsAutoRepeat 	= false
			let _				= fooDocTry3Document.processKey(from:nsEvent, inVew:nil)

		  //  ====== LEFT MOUSE ======
		 //
		case .leftMouseDown:
			motionFromLastEvent(with:nsEvent)
			if !nsTrackPad  {					// 3-button Mouse
				modelPic(with:nsEvent)
			}
			fwScn.updatePole2Camera(duration:duration, reason:"Left mouseDown")
		case .leftMouseDragged:	// override func mouseDragged(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				mouseWasDragged = true		// drag cancels pic
				spinNUp(with:nsEvent)			// change Spin and Up of camera
				fwScn.updatePole2Camera(reason:"Left mouseDragged")
			}
		case .leftMouseUp:	// override func mouseUp(with nsEvent:NSEvent) {
			if nsTrackPad  {					// Trackpad
				motionFromLastEvent(with:nsEvent)
				if !mouseWasDragged {			// UnDragged Up
					if let vew	= modelPic(with:nsEvent) {
						rootVew.lookAtVew	= vew			// found a Vew: Look at it!
					}
				}
				mouseWasDragged = false
				fwScn.updatePole2Camera(duration:duration, reason:"Left mouseUp")
			}

		  //  ====== CENTER MOUSE (scroll wheel) ======
		 //
		case .otherMouseDown:	// override func otherMouseDown(with nsEvent:NSEvent)	{
			motionFromLastEvent(with:nsEvent)
			fwScn.updatePole2Camera(duration:duration, reason:"Other mouseDown")
		case .otherMouseDragged:	// override func otherMouseDragged(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			spinNUp(with:nsEvent)
			fwScn.updatePole2Camera(reason:"Other mouseDragged")
		case .otherMouseUp:	// override func otherMouseUp(with nsEvent:NSEvent) {
			motionFromLastEvent(with:nsEvent)
			fwScn.updatePole2Camera(duration:duration, reason:"Other mouseUp")
//			print("camera = [\(ppCam())]")
			atEve(9, print("\(fwScn.scnScene.cameraScn?.transform.pp(.tree) ?? "cameraScn is nil")"))

		  //  ====== CENTER SCROLL WHEEL ======
		 //
		case .scrollWheel:
			let d				= nsEvent.deltaY
			let delta : CGFloat	= d>0 ? 0.95 : d==0 ? 1.0 : 1.05
			rootVew.lastSelfiePole.zoom *= delta
//			let scene			= DOCfwGuts
//			scene.lastSelfiePole.zoom *= delta
			print("receivedEvent(type:.scrollWheel) found pole\(rootVew.lastSelfiePole.uid).zoom = \(rootVew.lastSelfiePole.zoom)")
			fwScn.updatePole2Camera(reason:"Scroll Wheel")

		  //  ====== RIGHT MOUSE ======			Right Mouse not used
		 //

//	override func touchesBegan(with 	event:NSEvent)		{	handler(event)	}
//	override func touchesMoved(with 	event:NSEvent)		{	handler(event)	}
//	override func touchesEnded(with 	event:NSEvent)		{	handler(event)	}

		  //  ====== TOUCH PAD ======
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
			let t 				= nsEvent.touches(matching:.began, in:fwScn.scnView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
		case .mouseMoved:		bug
			let t 				= nsEvent.touches(matching:.moved, in:fwScn.scnView)
			for touch in t {
				let prevLoc		= touch.previousLocation(in:nil)
				let loc			= touch.location(in:nil)
				atEve(3, (print("\(prevLoc) \(loc)")))
			}
		case .endGesture:	//override func touchesEnded(with event:NSEvent) {
			let t 				= nsEvent.touches(matching:.ended, in:fwScn.scnView)
			for touch in t {
				let _:CGPoint	= touch.location(in:nil)
			}
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
		rootVew.lastSelfiePole.spin		 -= deltaPosition.x  * 0.5	// / deg2rad * 4/*fudge*/
		rootVew.lastSelfiePole.horizonUp -= deltaPosition.y  * 0.2	// * self.cameraZoom/10.0
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
		let doc					= fooDocTry3Document!

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
bug//		guard self.write(to:fileURL, options:[]) == false else {
//	//		guard self.write(to:fileURL, delegate:nil) == false else {
	 //			fatalError("writing dumpSCN.\(suffix) failed")					}
		case "V":
			print("\n******************** 'V': Build the Model's Views:\n")
			doc.fwGuts.rootPart.forAllParts({	$0.markTree(dirty:.vew)			})
			rootVew.updateVewSizePaint()
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			doc.fwGuts.rootPart.forAllParts({	$0.markTree(dirty:.size)		})
			rootVew.updateVewSizePaint()
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
			doc.fwGuts.rootPart.forAllParts({	$0.markTree(dirty:.paint)		})
			rootVew.updateVewSizePaint()
		case "w":
			print("\n******************** 'w': ==== FwGuts = [\(pp())]\n")
		case "x":
			print("\n******************** 'x':   === FwGuts: --> rootPart")
			if doc.fwGuts.rootPart.processKey(from:nsEvent, inVew:vew!) {
				print("ERROR: fwGuts.Process('x') failed")
			}
			return true								// recognize both
		case "f": 					// // f // //
			fwScn.animatePhysics = !fwScn.animatePhysics
			let msg 			= fwScn.animatePhysics ? "Run   " : "Freeze"
			print("\n******************** 'f':   === FwGuts: animatePhysics <-- \(msg)")
			return true								// recognize both
		case "?":
			Swift.print ("\n=== FwGuts   commands:",
				"\t'r'             -- r sound test",
				"\t'r'+cmd         -- go to lldb for rerun",
				"\t'v'             -- print Vew tree",
				"\t'n'             -- print User's SCNNode tree",
				"\t'#'             -- write out SCNNode tree as .scn",
				"\t'#'+alt         -- write out SCNNode tree as .dae",
				"\t'V'             -- build the Model's Views",
				"\t'T'             -- Size and pack the Model's Views",
				"\t'P'             -- Paint the skins of Views",
				"\t'w'             -- print FwGuts camera",
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
			if picdVew.part.processKey(from:nsEvent, inVew:picdVew) {
				return picdVew
			}
		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}

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
		let mouse 	: NSPoint	= fwScn.convertToRoot(windowPosition:pt)
		var msg					= "******************************************\n findVew(nsEvent:)\t"

								//		 + +   + +
		let hits:[SCNHitTestResult]	= fwScn.scnView!.hitTest(mouse, options:configHitTest)
								//		 + +   + +

//        let hits 				= scnView.hitTest(mouse, options:configHitTest)
//        if let tappednode = hits.first?.node

		 // SELECT HIT; prefer any child to its parents:
		var rv : Vew			= rootVew			// default
		var pickedScn			= fwScn.rootScn 	// default
		if hits.count > 0 {
			 // There is a HIT on a 3D object:
			let sortedHits	= hits.sorted {	$0.node.position.z > $1.node.position.z }
			let hit			= sortedHits[0]
			pickedScn		= hit.node // pic node with lowest deapth
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
			if let cv		= rootVew.trunkVew,
			  let vew 		= cv.find(scnNode:pickedScn, inMe2:true)
			{
				rv			= vew
bug	//				msg			+= "      ===>    ####  \(vew.part.pp(.fullNameUidClass))  ####"
			}else{
				panic(msg + "\n" + "couldn't find vew for scn:\(pickedScn.fullName)")
				if let cv	= rootVew.trunkVew,			// for debug only
				  let vew 	= cv.find(scnNode:pickedScn, inMe2:true) {
					let _	= vew
				}
			}
		} else {		// Background hit
			msg				+= "background -> trunkVew"
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

		 // ========= Get Locks for two resources, in order: =============
		guard rootPart.lock(partTreeAs:"toggelOpen") else {
			fatalError("toggelOpen couldn't get PART lock")	}		// or
		guard  rootVew.lock(vewTreeAs:"toggelOpen") else {fatalError("couldn't get lock") }

		assert(!(part is Link), "cannot toggelOpen a Link")
		atAni(5, part.root!.log.log("Removed old Vew '\(vew.fullName)' and its SCNNode"))
		vew.scn.removeFromParent()
		vew.removeFromParent()
		vew.updateVewSizePaint(needsLock:"toggelOpen4")

		// ===== Release Locks for two resources, in reverse order: =========
		rootVew .unlock( vewTreeAs:"toggelOpen")										//		ctl.experiment.unlock(partTreeAs:"toggelOpen")
		rootPart.unlock(partTreeAs:"toggelOpen")

		fwScn.updatePole2Camera(reason:"toggelOpen")
		atAni(4, part.logd("expose = << \(vew.expose) >>"))
		atAni(4, part.logd(rootPart.pp(.tree)))

		if config4fwGuts.bool_("animateOpen") {	//$	/// Works iff no PhysicsBody //true ||

			 // Mark old SCNNode as Morphing
			let oldScn			= vew.scn
			vew  .name			= "M" + vew   .name		// move old vew out of the way
			oldScn.name!		= "M" + oldScn.name!	// move old scn out of the way
			oldScn.scale		= .unity * 0.5			// debug
			vew.part.markTree(dirty:.vew)				// mark Part as needing reVew

			 //*******// Imprint animation parameters JUST BEFORE start:
			DOCfwGuts.rootVew.updateVewSizePaint()				// Update SCN's at START of animation
			 //*******//

			 // Animate Vew morph, from self to newVew:
			guard let newScn	= vew.parent?.find(name:"_" + part.name)?.scn else {
				fatalError("updateVew didn't creat a new '_<name>' vew!!")
			}
			newScn.scale		= .unity * 0.3 //0.1, 0.0 	// New before Fade-in	-- zero size
			oldScn.scale		= .unity * 0.7 //0.9, 1.0	// Old before Fade-out	-- full size

			SCNTransaction.begin()
//			atRve??(8, logg("  /#######  SCNTransaction: BEGIN"))
			SCNTransaction.animationDuration = CFTimeInterval(3)//3//0.3//10//
			 // Imprint parameters AFTER "togelOpen" ends:
			newScn.scale		= SCNVector3(0.7, 0.7, 0.7)	//.unity						// After Fade-in
			oldScn.scale 		= SCNVector3(0.3, 0.3, 0.3) //.zero							// After Fade-out

			SCNTransaction.completionBlock 	= {
				 // Imprint JUST AFTER end, with OLD removed (Note: OLD == self):
				assert(vew.scn == oldScn, "oops")
//				part.logg("Removed old Vew '\(vew.fullName)' and its SCNNode")
				newScn.scale	= .unity
				oldScn.scale 	= .unity	// ?? reset for next time (Elim's BUG?)
				oldScn.removeFromParent()
				vew.removeFromParent()
				//*******//
				self.rootVew.updateVewSizePaint()	// Imprint AFTER animation
				//*******//	// //// wants a third animatio	qn (someday):
			}
//			atRve??(8, logg("  \\#######  SCNTransaction: COMMIT"))
			SCNTransaction.commit()
		}
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
	//https://forums.developer.apple.com/thread/111572
	//			let morpher 		= SCNMorpher()
	//			morpher.targets 	= [scn.geometry!]  	/// our old geometry will morph to 0
	//		let node = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 5, chamferRadius: 0))
	//		Controller.current?.fwGuts.rootNode.addChildNode(node)
	//		node.morpher = morpher
	//		let anim = CABasicAnimation(keyPath: "morpher.weights[0]")
	//		anim.fromValue = 0.0
	//		anim.toValue = 1.0
	//		anim.autoreverses = true
	//		anim.duration = 1
	//		node.addAnimation(anim, forKey: nil)
	}


	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
		switch mode {
		case .tree:
bug
//	var rootPart 				: RootPart														//{	rootVew.part as! RootPart}
//	var rootVew  				: Vew				//			= .null
//	var rootVewOwner 			: String?	= nil
//	var rootVewOwnerPrev		:String? = nil
//	var rootVewVerbose 			= false
//	var scnView	 				: SCNView?		= nil
//	var scnScene				: SCNScene
//	var rootScn  				: SCNNode	{	scnScene.rootNode									}	//scnRoot
//	var fooDocTry3Document : FooDocTry3Document!
			return rootVew.lastSelfiePole.pp()
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
//	func ppCam() -> String {
//		let c = lastSelfiePole
//		return fmt("h:%s, s:%.0f, u:%.0f, z:%.3f", c.at.pp(.short), c.spin, c.horizonUp, c.zoom)
//	}
}


 // ORPHAN, WAS IN defunct FwView
//	 // MARK: - 17. Debugging Aids
//	override func  becomeFirstResponder()	-> Bool	{	return true				}
//	override func validateProposedFirstResponder(_ responder: NSResponder,
//					   for event: NSEvent?) -> Bool {	return true				}
//	override func resignFirstResponder()	-> Bool	{	return true				}

 //https://openbase.com/swift/GDPerformanceView
//GDPerformanceMonitor.sharedInstance.configure(configuration: { (textLabel) in
//	textLabel?.backgroundColor = .black
//	textLabel?.textColor = .white
//	textLabel?.layer.borderColor = UIColor.black.cgColor
//})
//GDPerformanceMonitor.sharedInstance.startMonitoring()

