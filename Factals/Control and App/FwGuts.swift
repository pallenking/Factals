//  FwGuts.swift -- All the 3D things in a FwView 2D window  C2018PAK

// Coordinates Operation of root, vew, and scn

import SceneKit
// CherryPick2023-0520: remove NSObject
class FwGuts : NSObject, ObservableObject {

	  // MARK: - 2. Object Variables:
	@Published var rootPart 	:  RootPart?													//{	rootVew.part as! RootPart}
	var document : FactalsDocument!					// Owner

	var rootVews : [RootVew]	= []
	var rootVew0 :  RootVew?	{ rootVews.count<=0 ? nil : rootVews[0]			}
	var log 	 : Log

	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}

	func configureDocument(from c:FwConfig) { // *****
		log.configureDocument(from:c)

		guard let rootPart else { fatalError("WARNING configureDocument: fwGuts.rootPart=nil") }
		rootPart.configureDocument(from:c)
//		if let rootPart {
//			rootPart.configureDocument(from:c)
//		} else {
//			print("WARNING configureDocument: fwGuts.rootPart=nil")
//		}

		guard rootVews.count != 0 else {
			print("STRANGE, configureDocument: fwGuts.rootVews.count == 0")
			return
		}
		for rootVew in rootVews {
			rootVew.configureDocument(from:c)
		}
	}
	 // MARK: - 3. Factory
	 //PAK: Could remove this.
	init(rootPart r:RootPart?=nil) {
		rootPart				= r
		log						= Log(title:"FwGut's Log", params4all)
							
		super.init()
		rootPart?.fwGuts		= self		// Owner? is self

//		let xx					= self.pp(.classUid)
//		atBld(5, log("Created \(self.pp(.classUid))"))
	}

//	// FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {
bug;return nil
//		do {		// 1. Write SCNScene to file. (older, SCNScene supported serialization)
//			try self.document.write(to: fileURL)
//		} catch {
//			print("error writing file: \(error)")
//		}
//					// 2. Get file to data
//		let data				= try? Data(contentsOf:fileURL)
//		return data//Cannot convert value of type '() -> ()' to expected argument type 'Int'
	}
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
	func addRootVew(vewConfig:VewConfig, fwConfig:FwConfig) {
		guard let rootPart else {	fatalError("addRootVew: rootPart=nil")		}
		let rootVew				= RootVew(forPart:rootPart)		//, rootScn:rootScn
		rootVew.fwGuts			= self
		rootVews.append(rootVew)		// register now, so OK for following:

		rootVew.configureVew(from:fwConfig)

		 // Build out Vew and Scn Trees:
		rootVew.openChildren(using:vewConfig)

		rootPart.dirtySubTree(gotLock: true, .vsp)			// DEBUG hack, till locks better
		rootVew.updateVewSizePaint(vewConfig:vewConfig)		// tree(Part) -> tree(Vew)+tree(Scn)
		
		rootVew.setupLightsCamerasEtc()
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
		for rootVew in rootVews {
			if rootVew.scn.find(firstWith:{ $0 == ofScnNode }) != nil {
				return rootVew
			}
		}
		return nil
	}

	  // MARK: - 9.0 3D Support
	 // mouse may "paw through" parts, using wiggle
	var wigdsfgledPart	  : Part?	= nil
	var wiggleOffset  : SCNVector3? = nil		// when mouse drags an atom

	  // MARK: -
	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
 		let character			= nsEvent.charactersIgnoringModifiers!.first!
		if nsEvent.type == .keyUp {			// ///// Key UP ////// //
			return false
		}
		let modifierKeys		= nsEvent.modifierFlags
		let cmd 				= modifierKeys.contains(.command)
		let alt 				= modifierKeys.contains(.option)
	//	let doc					= document!

		switch character {
		case "r": // (+ cmd)
			if cmd {
				panic("Press 'cmd r'   A G A I N    to rerun")	// break to debugger
				return true 									// continue
			}
	  //case "r" alone:				// Sound Test
			print("\n******************** 'r': === play(sound(\"GameStarting\")\n")
			for rootVew in rootVews {
				rootVew.scn.play(sound:"Oooooooo")		//GameStarting
			}
		case "v":
			print("\n******************** 'v': ==== Views:")
			for rootVew in rootVews {
				print("-------- ptv0   rootVews[++]:\(ppUid(rootVew)):")
				print("\(rootVew.pp(.tree))", terminator:"")
			}
		case "n":
			print("\n******************** 'n': ==== SCNNodes:")
			log.ppIndentCols = 3
			for rootVew in rootVews {
				print("-------- ptn   rootVews(\(ppUid(rootVew))).rootScn(\(ppUid(rootVew.rootScn)))" +
					  ".scn(\(ppUid(rootVew.scn))):")
				print(rootVew.scn.pp(.tree), terminator:"")
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
			let rootVews0scene	= rootVews.first?.rootScn.scnScene ?? {	fatalError("") } ()
			guard rootVews0scene.write(to:fileURL, options:[:], delegate:nil)
						else { fatalError("writing dumpSCN.\(suffix) failed")	}
		case "V":
			print("\n******************** 'V': Build the Model's Views:\n")
			for rootVew in rootVews {
				rootPart!.forAllParts({	$0.markTree(dirty:.vew)			})
				rootVew.updateVewSizePaint(needsLock:"FwGuts 'V'iew key")
			}
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			for rootVew in rootVews {
				rootPart!.forAllParts({	$0.markTree(dirty:.size)		})
				rootVew.updateVewSizePaint(needsLock:"FwGuts si'Z'e key")
			}
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
			for rootVew in rootVews {
				rootPart!.forAllParts({	$0.markTree(dirty:.paint)		})
				rootVew.updateVewSizePaint(needsLock:"FwGuts 'P'aint key")
			}
		case "w":
			print("\n******************** 'w': ==== FwGuts = [\(pp())]\n")
		case "x":
			print("\n******************** 'x':   === FwGuts: --> rootPart")
			if rootPart!.processEvent(nsEvent:nsEvent, inVew:vew) {
				print("ERROR: fwGuts.Process('x') failed")
			}
			return true								// recognize both
		case "f": 					// // f // //
			var msg					= ""
			for rootVew in rootVews {
				msg 				+= rootVew.rootScn.animatePhysics ? "Run   " : "Freeze"
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
	func modelPic(with nsEvent:NSEvent, inVew vew:Vew) -> Vew? {
		if let picdVew			= findVew(nsEvent:nsEvent, inVew:vew) {
			 // DISPATCH to PART that was pic'ed
			if picdVew.part.processEvent(nsEvent:nsEvent, inVew:picdVew) {
				return picdVew
			}
		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}

	func findVew(nsEvent:NSEvent, inVew:Vew) -> Vew? {
		 // Find rootVew of NSEvent
		guard let rootVew		= inVew.rootVew else { return nil				}
		let rootScn				= rootVew.rootScn
		guard let fwView		= rootScn.fwView else { fatalError("rootScn has fwView=nil")}

		 // Find the 3D Vew for the Part under the mouse:
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
			.rootNode:rootScn.scn, 		// The root of the node hierarchy to be searched.
		]
		let locationInRoot		= fwView.convert(nsEvent.locationInWindow, from:nil)	// nil => from window coordinates //view

								//		 + +   + +
		let hits				= fwView.hitTest(locationInRoot, options:configHitTest)
								//		 + +   + +
		// There is in NSView: func hitTest(_ point: NSPoint) -> NSView?
		// SCNSceneRenderer: hitTest(_ point: CGPoint, options: [SCNHitTestOption : Any]? = nil) -> [SCNHitTestResult]

		 // SELECT HIT; prefer any child to its parents:
		var rv : Vew			= rootVew			// default Vew
		var msg					= "******************************************\n" +
								  "Slot\(rootVew.slot ?? -1): find "
		var pickedScn			= rootVew.scn 		// default SCNNode
		if hits.count > 0 {
			 // There is a HIT on a 3D object:
			let sortedHits		= hits.sorted {	$0.node.position.z > $1.node.position.z }
			let hit				= sortedHits[0]
			pickedScn			= hit.node // pic node with lowest deapth
			msg 				+= "\(pickedScn.pp(.classUid))'\(pickedScn.fullName)':"	// SCNNode<3433>'/*-ROOT'

			 // If Node not picable, try parent
			while pickedScn.categoryBitMask & FwNodeCategory.picable.rawValue == 0,
			  let parent 		= pickedScn.parent 		// try its parent:
			{
				msg				+= fmt(" --> category %02x (Ignore)", pickedScn.categoryBitMask)
				pickedScn 		= parent				// use parent
				msg 			+= "\n\t " + "parent " + "\(pickedScn.pp(.classUid))'\(pickedScn.fullName)': "
			}

			 // Got SCN, get its Vew
			if let vew 			= rootVew.find(scnNode:pickedScn, inMe2:true) {
				rv				= vew
				msg				+= "      ===>    ####  \(vew.part.pp(.fullNameUidClass))  ####"
			} else {
				if trueF { return nil }
				panic(msg+"\n"+"couldn't find it in vew's \(rootVew.scn.pp(.classUid))")
				if let cv		= rootVew.trunkVew,			// for debug only
				  let vew 		= cv.find(scnNode:pickedScn, inMe2:true) {
					let _		= vew
				}
			}
		} else {		// Background hit
			msg					+= "background -> trunkVew"
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
		guard rootPart!.lock(partTreeAs:"toggelOpen") else {
			fatalError("toggelOpen couldn't get PART lock")	}		// or
		guard  rootVew.lock(vewTreeAs:"toggelOpen") else {fatalError("couldn't get Vew lock") }

		assert(!(part is Link), "cannot toggelOpen a Link")
		atAni(5, log("Removed old Vew '\(vew.fullName)' and its SCNNode"))
		vew.scn.removeFromParent()
		vew.removeFromParent()

		rootVew.updateVewSizePaint(needsLock:"toggelOpen4")

		// ===== Release Locks for two resources, in reverse order: =========
		rootVew  .unlock( vewTreeAs:"toggelOpen")										//		ctl.experiment.unlock(partTreeAs:"toggelOpen")
		rootPart?.unlock(partTreeAs:"toggelOpen")

//		cam.transform 			= rootScn.commitCameraMotion(reason:"Other mouseDown")
	//	let rScn				= rootVew.scn
		let rootScn				= rootVew.rootScn
bug;	rootScn.commitCameraMotion(reason:"toggelOpen")
//bug;	rootScn.cameraScn?.transform = rootScn.commitCameraMotion(reason:"toggelOpen")
		rootScn.updatePole2Camera(reason:"toggelOpen")
		atAni(4, part.logd("expose = << \(vew.expose) >>"))
		atAni(4, part.logd(rootPart!.pp(.tree)))

		if document.config.bool_("animateOpen") {	//$	/// Works iff no PhysicsBody //true ||

			 // Mark old SCNNode as Morphing
			let oldScn			= vew.scn
			vew  .name			= "M" + vew   .name		// move old vew out of the way
			oldScn.name!		= "M" + oldScn.name!	// move old scn out of the way
			oldScn.scale		= .unity * 0.5			// debug
			vew.part.markTree(dirty:.vew)				// mark Part as needing reVew

			 //*******// Imprint animation parameters JUST BEFORE start:
			rootVew.updateVewSizePaint()				// Update SCN's at START of animation
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
				rootVew.updateVewSizePaint()	// Imprint AFTER animation
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
//	func pp(_ mode:PpMode = .tree, _ aux:FwConfig) -> String	{
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{// CherryPick2023-0520:
		switch mode {
		case .line:
			var rv				= (rootPart?.pp(.classUid) ?? "rootPart=nil") + " "
			rv					+= rootVews.pp(.classUid) + " "
			if let document {
				rv				+= document.pp(.classUid)
			}
			return rv
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
	}


	func pq(_ mode:PpMode = .tree, _ aux:FwConfig) -> String	{
		pp(mode,aux)
	}


	 // MARK: - 17. Debugging Aids
	override var description	  : String {	return  "d'\(pp(.short))'"		}
	override var debugDescription : String {	return "dd'\(pp(.short))'"		}
	var summary					  : String {	return  "s'\(pp(.short))'"		}
}
