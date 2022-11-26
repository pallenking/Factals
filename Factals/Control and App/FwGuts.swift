//  FwGuts.swift -- All the 3D things in a FwView 2D window  C2018PAK

// Coordinates Operation of root, vew, and scn

import SceneKit

class FwGuts : NSObject {	//, SCNSceneRendererDelegate

	  // MARK: - 2. Object Variables:
	var rootPart :  RootPart													//{	rootVew.part as! RootPart}
	var rootVews : [Int:RootVew] = [:]
//	var rootVews : [RootVew]	= [RootVew(), RootVew(), RootVew(), RootVew()]
	var document 	 : FactalsDocument!
									//	{	get		{	return docPrivate!											}
									//		set(v)	{	docPrivate = v												}
									//	};var docPrivate : FactalsDocument? = nil
	var logger 		 : Logger
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		logger.log(banner:banner, format_, args, terminator:terminator)
	}

	func pushControllersConfig(to c:FwConfig) { // *****
		rootPart       .pushControllersConfig(to:c)
		for i in rootVews.keys.sorted() { //}, fwScn) {
//		for i in 0..<rootVews.count { //}, fwScn) {
			rootVews[i]!.pushControllersConfig(to:c)// ?? log("fwGuts: rootVew nil")
		}
	}
	 // MARK: - 3. Factory
	convenience override init() {
		self.init(rootPart:RootPart())
	}
	init(rootPart r:RootPart) {
		rootPart				= r
		logger					= Logger(title:"FwGut's Logger", params4all)

		super.init()

		log("Created \(self.pp(.classUid))")
		rootPart.fwGuts			= self 		 // owner (Back Link)
		 // Make FwGuts without any RootVews!
	}
	func viewAppearedFor(sceneKitArgs:SceneKitArgs) {	 /// was FactalsDocument.didLoadNib()
		atRnd(4, DOClogger.log("=== Slot \(sceneKitArgs.sceneIndex): ============> viewAppearedFor title:'\(sceneKitArgs.title)'"))
//logd	atRnd(4, DOClogger.log("=== Slot \(args.sceneIndex): ========== makeNSView         title:'\(args.title)'"))

		 // Access rootVews for sceneKitArgs.sceneIndex:
		guard let rootVew		= rootVews[sceneKitArgs.sceneIndex] else {
			fatalError("no rootVews[\(sceneKitArgs.sceneIndex)")
		}
		let fwScn				= rootVew.fwScn
		fwScn.createVewNScn(sceneIndex:sceneKitArgs.sceneIndex, vewConfig:sceneKitArgs.vewConfig)

		 // Configure baseView
		guard let baseView		= fwScn.scnView else { fatalError("fwScn.scnView == nil") }
		baseView.isPlaying		= true			// does nothing
		baseView.showsStatistics = true			// works fine
		baseView.debugOptions 	= [				// enable display of:
	//		SCNDebugOptions.showBoundingBoxes,	// bounding boxes for nodes with content.
			SCNDebugOptions.showWireframe,		// geometries as wireframe.
			SCNDebugOptions.renderAsWireframe,	// only wireframe of geometry
	// 		SCNDebugOptions.showSkeletons,		//?EH? skeletal animation parameters
	//		SCNDebugOptions.showCreases,		//?EH? nonsmoothed crease regions affected by subdivisions.
	//		SCNDebugOptions.showConstraints,	//?EH? constraint objects acting on nodes.
				// Cameras and Lighting
	//		SCNDebugOptions.showCameras,		//?EH? Display visualizations for nodes in the scene with attached cameras and their fields of view.
	//		SCNDebugOptions.showLightInfluences,//?EH? locations of each SCNLight object
	//		SCNDebugOptions.showLightExtents,	//?EH? regions affected by each SCNLight
				// Debugging Physics
		//	SCNDebugOptions.showPhysicsShapes,	// physics shapes for nodes with SCNPhysicsBody.
			SCNDebugOptions.showPhysicsFields,	//?EH?  regions affected by each SCNPhysicsField object
		]
		 //	view.allowsCameraControl = false		// dare to turn it on?
		 //	view.autoenablesDefaultLighting = false	// dare to turn it on?

//!		makeInspectors()
				// Start Up Simulation:
		rootPart.simulator.simBuilt = false//true		// maybe before config4log, so loading simEnable works
	}
	// FileDocument requires these interfaces:
	 // Data in the SCNScene
//	var data : Data? {
//
//		do {		// 1. Write SCNScene to file. (older, SCNScene supported serialization)
//			try self.document.write(to: fileURL)
//		} catch {
//			print("error writing file: \(error)")
//		}
//					// 2. Get file to data
//		let data				= try? Data(contentsOf:fileURL)
//		return data//Cannot convert value of type '() -> ()' to expected argument type 'Int'
//	}
	 // initialize new SCNScene from Data
	convenience init?(data:Data, encoding:String.Encoding) {
		fatalError("FwGuts.init?(data:Data")
	//	do {		// 1. Write data to file.
	//		try data.write(to: fileURL)
	//	} catch {
	//		print("error writing file: \(error)")
	//	}
	//	self.init()
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
//	 // MARK: - 3.6 NSCopying
//	 // MARK: - 3.7 Equatable
	 // MARK: - 4.?
	func rootVew(ofScnNode:SCNNode) -> RootVew? {
		for key in rootVews.keys {
			let rootVew			= rootVews[key]!
			if rootVew.scn.find(firstWith:{ $0 == ofScnNode }) != nil {
				return rootVew
			}
		}
		return nil
	}

	  // MARK: - 9.0 3D Support
	 // mouse may "paw through" parts, using wiggle
	var wiggledPart	  : Part?	= nil
	var wiggleOffset  : SCNVector3? = nil		// when mouse drags an atom

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

	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
 		let character			= nsEvent.charactersIgnoringModifiers!.first!
		if nsEvent.type == .keyUp {			// ///// Key UP ////// //
			return false
		}
		let modifierKeys		= nsEvent.modifierFlags
		let cmd 				= modifierKeys.contains(.command)
		let alt 				= modifierKeys.contains(.option)
		let doc					= document!

		switch character {
		case "r": // (+ cmd)
			if cmd {
				panic("Press 'cmd r'   A G A I N    to rerun")	// break to debugger
				return true 									// continue
			}
	  //case "r" alone:				// Sound Test
			print("\n******************** 'r': === play(sound(\"GameStarting\")\n")
			for key in rootVews.keys {
				rootVews[key]!.fwScn.rootScn.play(sound:"Oooooooo")		//GameStarting
			}
		case "v":
			print("\n******************** 'v': ==== Views:")
			for key in rootVews.keys {
				let rootVew		= rootVews[key]!
				print("-------- ptv   rootVews(\(ppUid(rootVew))):")
				print("\(rootVew.pp(.tree))", terminator:"")
			}
		case "n":
			print("\n******************** 'n': ==== SCNNodes:")
			logger.ppIndentCols = 3
			for key in rootVews.keys {
				let rootVew		= rootVews[key]!
				print("-------- ptn   rootVews(\(ppUid(rootVew))).fwScn(\(ppUid(rootVew.fwScn)))" +
					  ".rootScn(\(ppUid(rootVew.fwScn.rootScn))):")
				print(rootVew.fwScn.rootScn.pp(.tree), terminator:"")
			}
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
			rootPart.forAllParts({	$0.markTree(dirty:.vew)			})
//			for rootVew in rootVews {
			for key in rootVews.keys {
				let rootVew		= rootVews[key]!
				rootVew.updateVewSizePaint()
			}
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			rootPart.forAllParts({	$0.markTree(dirty:.size)		})
//			for rootVew in rootVews {
			for key in rootVews.keys {
				let rootVew		= rootVews[key]!
				rootVew.updateVewSizePaint()
			}
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
			rootPart.forAllParts({	$0.markTree(dirty:.paint)		})
//			for rootVew in rootVews {
			for key in rootVews.keys {
				let rootVew		= rootVews[key]!
				rootVew.updateVewSizePaint()
			}
		case "w":
			print("\n******************** 'w': ==== FwGuts = [\(pp())]\n")
		case "x":
			print("\n******************** 'x':   === FwGuts: --> rootPart")
			if rootPart.processEvent(nsEvent:nsEvent, inVew:vew!) {
				print("ERROR: fwGuts.Process('x') failed")
			}
			return true								// recognize both
		case "f": 					// // f // //
			var msg					= ""
			for key in rootVews.keys {
				let rootVew		= rootVews[key]!
				rootVew.fwScn.animatePhysics = !rootVew.fwScn.animatePhysics
				msg 				+= rootVew.fwScn.animatePhysics ? "Run   " : "Freeze"
			}
			print("\n******************** 'f':   === FwGuts: animatePhysics <-- \(msg)")
			return true								// recognize both
		case "?":
			print ("\n=== FwGuts   commands:",
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
			if picdVew.part.processEvent(nsEvent:nsEvent, inVew:picdVew) {
				return picdVew
			}
		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}

	func findVew(nsEvent:NSEvent) -> Vew? {
		guard let rootVewOfEv	= nsEvent.rootVew else {	return nil 			}
		let rootScnOfEv 		= rootVewOfEv.fwScn

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
			.rootNode:rootVewOfEv.fwScn.rootScn,// The root of the node hierarchy to be searched.
//			.rootNode:rootScn, 			// The root of the node hierarchy to be searched.
		]
		 // CONVERT to window coordinates
		let pt 	  	: NSPoint	= nsEvent.locationInWindow
		let mouse 	: NSPoint	= rootScnOfEv.convertToRoot(windowPosition:pt)
		var msg					= "******************************************\n findVew(nsEvent:)\t"

								//		 + +   + +
		let hits:[SCNHitTestResult]	= rootScnOfEv.scnView!.hitTest(mouse, options:configHitTest)
								//		 + +   + +

//		let hits 				= scnView.hitTest(mouse, options:configHitTest)
//		if let tappednode 	= hits.first?.node

let key = 0

		 // SELECT HIT; prefer any child to its parents:
		var rv : Vew			= rootVewOfEv			// default
		var pickedScn			= rootScnOfEv.rootScn 	// default
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
			if let cv		= rootVews[key]?.trunkVew,
			  let vew 		= cv.find(scnNode:pickedScn, inMe2:true)
			{
				rv			= vew
				msg			+= "      ===>    ####  \(vew.part.pp(.fullNameUidClass))  ####"
			}else{
				panic(msg + "\n" + "couldn't find vew for scn:\(pickedScn.fullName)")
				if let cv	= rootVews[key]!.trunkVew,			// for debug only
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
		let key 				= 0			// only element 0 for now
		guard let rootVew		= vew.rootVew else {	fatalError("toggelOpen without RootVew")}

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
		guard  rootVews[key]!.lock(vewTreeAs:"toggelOpen") else {fatalError("couldn't get lock") }

		assert(!(part is Link), "cannot toggelOpen a Link")
		atAni(5, log("Removed old Vew '\(vew.fullName)' and its SCNNode"))
		vew.scn.removeFromParent()
		vew.removeFromParent()
		vew.updateVewSizePaint(needsLock:"toggelOpen4")

		// ===== Release Locks for two resources, in reverse order: =========
		rootVews[key]!.unlock( vewTreeAs:"toggelOpen")										//		ctl.experiment.unlock(partTreeAs:"toggelOpen")
		rootPart	  .unlock(partTreeAs:"toggelOpen")

		rootVew.updatePole2Camera(reason:"toggelOpen")
		atAni(4, part.logd("expose = << \(vew.expose) >>"))
		atAni(4, part.logd(rootPart.pp(.tree)))

		if document.config.bool_("animateOpen") {	//$	/// Works iff no PhysicsBody //true ||

			 // Mark old SCNNode as Morphing
			let oldScn			= vew.scn
			vew  .name			= "M" + vew   .name		// move old vew out of the way
			oldScn.name!		= "M" + oldScn.name!	// move old scn out of the way
			oldScn.scale		= .unity * 0.5			// debug
			vew.part.markTree(dirty:.vew)				// mark Part as needing reVew

			 //*******// Imprint animation parameters JUST BEFORE start:
			rootVews[key]!.updateVewSizePaint()			// Update SCN's at START of animation
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
				self.rootVews[key]!.updateVewSizePaint()	// Imprint AFTER animation
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
		case .line:
			var rv				=  rootPart.pp(.classUid) + " "	//for (msg, obj) in [("light1", light1), ("light2", light2), ("camera", cameraNode)] {
			rv					+= rootVews.pp(.classUid) + " "	//	rv				+= "\(msg) =       \(obj.categoryBitMask)-"
			if let document {rv	+= document.pp(.classUid)					}
bug;		rv					+= " SelfiePole:" + rootVews[0]!.lastSelfiePole.pp()
			return rv
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}

 // ORPHAN, WAS IN defunct FwView
	 // MARK: - 17. Debugging Aids
	override var description	  : String {	return  "\"\(pp(.short))\""	}
	override var debugDescription : String {	return   "'\(pp(.short))'" 	}
	var summary					  : String {	return   "<\(pp(.short))>" 	}
}