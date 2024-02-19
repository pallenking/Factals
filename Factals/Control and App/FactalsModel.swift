//  FactalsModel.swift -- Manage Parts, RootVews and their RootScns

import SceneKit
import SwiftUI

class FactalsModel : ObservableObject, Uid {
	var uid: UInt16				= randomUid()

	  // MARK: - 2. Object Variables:
	var fmConfig : FwConfig	= [:]

	 // hold index of named items (<Class>, "wire", "WBox", "origin", "breakAtWire", etc)
	var indexFor				= Dictionary<String,Int>()

	var parts :  PartBase
	var vewss : [VewBase]	= []			// VewBase of rootPartActor.parts
	var vews0 :  VewBase?			{	vewss.first									}// Sugar

	var	simulator: Simulator
	var log 	 : Log
	var docSound	 			= Sounds()

	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}

	 // MARK: - 3. Factory
	init(fromRootPart rp:PartBase) {											// FactalsModel(fromRootPart rp:PartBase)
		parts				= rp
		simulator				= Simulator()
		log						= Log(title:"FactalsModel's Log", params4all)
		// self now valid /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		FACTALSMODEL			= self
		simulator.factalsModel	= self
		parts.factalsModel		= self

		//configure(from:document.fmConfig)
	}

	func configure(from config:FwConfig) {
		fmConfig				+= parts.ansConfig	// from library
		simulator.configure(from:config)
		parts.configure(from:config)
		for vews in vewss {
			vews.configureRootVew(from:config)
		}
		log.configure(from:config)
		docSound.configure(from:config)

		 //  5. Print Errors
//		atBld(3, log.logd(rootPartActor.parts?.ppRootPartErrors() ?? ""))

		 //  6. Print Part
//		atBld(2, logd("------- Parts, ready for simulation, simEnabled:\(simulator.simEnabled)):\n" + (pp(.tree, ["ppDagOrder":true]))))

		simulator.simBuilt		= true	// maybe before config4log, so loading simEnable works
//		simulator.simEnabled	= true
	}
					//	//	// FileDocument requires these interfaces:
					//		 // Data in the SCNScene
					//		var data : Data? {
					//	bug;return nil
					//	//		do {		// 1. Write SCNScene to file. (older, SCNScene supported serialization)
					//	//			try self.document.write(to: fileURL)
					//	//		} catch {
					//	//			print("error writing file: \(error)")
					//	//		}
					//	//					// 2. Get file to data
					//	//		let data				= try? Data(contentsOf:fileURL)
					//	//		return data//Cannot convert value of type '() -> ()' to expected argument type 'Int'
					//		}
					//		 // initialize new SCNScene from Data
					//		convenience init?(data:Data, encoding:String.Encoding) {
					//			fatalError("FactalsModel.init?(data:Data")
					//		//	do {		// 1. Write data to file.
					//		//		try data.write(to: fileURL)
					//		//	} catch {
					//		//		print("error writing file: \(error)")
					//		//	}
					//		//	self.init()
					//	//		do {		// 2. Init self from file
					//	//			try self.init(fwConfig:[:])
					//	//	//		try super.init(url: fileURL)
					//	//		} catch {
					//	//			print("error initing from url: \(error)")
					//	//			return nil
					//	//		}
					//		}
	 // MARK: - 3.5 Codable
	 // ///////// Serialize
	func encode(to encoder: Encoder) throws  {
//		try container.encode(simulator,			forKey:.simulator				)
		fatalError("FactalsModel.encode(coder..) unexpectantly called")
	}
	 // ///////// Deserialize
	required init(coder aDecoder: NSCoder) {
		fatalError("FactalsModel.init(coder..) unexpectantly called")
	}

	 // MARK: - 4.?
	func vew(ofScnNode  s:SCNNode) -> Vew? {	vewBase(ofScnNode:s)?.tree 		}
	func vewBase(ofScnNode s:SCNNode) -> VewBase? {
		for vews in vewss {
			if vews.tree.scn.find(firstWith:{ $0 == s }) != nil {
				return vews
			}
		}
		return nil
	}

	  // MARK: - 9.0 3D Support
	 // mouse may "paw through" parts, using wiggle
	var wiggledPart	  : Part?	= nil
	var wiggleOffset  : SCNVector3? = nil		// when mouse drags an atom

	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: The key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {return false}
		guard let parts : PartBase = vew.part.root else {return false }	// vew.root.part
		var found				= true

		 // Check Simulator:
/**/	if simulator.processEvent(nsEvent:nsEvent, inVew:vew)  {
			return true 					// handled by simulator
		}

		 // Check Controller:
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						/* FwDocument has no key-ups */
		}
		 // Sim EVENTS						// /// Key DOWN ///////
		let cmd 				= nsEvent.modifierFlags.contains(.command)
		let alt 				= nsEvent.modifierFlags.contains(.option)
		var aux : FwConfig		= fmConfig	// gets us params4pp
		aux["ppParam"]			= alt		// Alternate means print parameters

		switch character {
		case "u": // + cmd
			if cmd {
				panic("Press 'cmd u'   A G A I N    to retest")	// break to debugger
			}
		case Character("\u{1b}"):				// Escape
			print("\n******************** 'esc':  === EXIT PROGRAM\n")
			NSSound.beep()
			exit(0)								// exit program (hack: brute force)
		case "b":
			print("\n******************** 'b': ======== keyboard break to debugger")
			panic("'?' for debugger hints")
//		case "d":
//			print("\n******************** 'd': ======== ")
//			let l1v 			= rootVewL("_l1")
//			print(l1v.scn.transform.pp(.tree))

		 // print out parts, views
		 // Command Syntax:
		 // mM/lL 		normal  /  normal + links	L	 ==> Links
		 // ml/ML		normal  /  normal + ports	ROOT ==> Ports
		 //
		case "m":
			aux["ppDagOrder"]	= true
			print("\n******************** 'm': === Parts:")
			print(parts.pp(.tree, aux), terminator:"")
		case "M":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'M': === Parts and Ports:")
			print(parts.pp(.tree, aux), terminator:"")
		case "l":
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'l': === Parts, Links:")
			print(parts.pp(.tree, aux), terminator:"")
		case "L":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			print("\n******************** 'L': === Parts, Ports, Links:")
			print(parts.pp(.tree, aux), terminator:"")

		 // N.B: The following are preempted by AppDelegate keyboard shortcuts in Menu.xib
		case "c":
			printFwState()				// Current controller state
//		case "?":
//			printDebuggerHints()
//			return false				// anonymous printout



		case "r": // (+ cmd)
			if cmd {
				panic("Press 'cmd r'   A G A I N    to rerun")	// break to debugger
				return true 									// continue
			}
	  //case "r" alone:				// Sound Test
			print("\n******************** 'r': === play(sound(\"GameStarting\")\n")
			for vews in vewss {
				vews.scnNodes.tree.play(sound:"Oooooooo")		//GameStarting
			}
		case "v":
			print("\n******************** 'v': ==== Views:")
			for vews in vewss {
				print("-------- ptv0   rootVews[++]:\(ppUid(vews)):")
				print("\(vews.pp(.tree))", terminator:"")
			}
		case "n":
			print("\n******************** 'n': ==== SCNNodes:")
			log.ppIndentCols = 3
			for vews in vewss {
				print("-------- ptn   rootVews(\(ppUid(vews))).rootScn(\(ppUid(vews.scnNodes)))" +
					  ".scn(\(ppUid(vews.scnNodes))):")
				print(vews.scnNodes.pp(.tree), terminator:"")
			}
		case "#":
			let documentDirURL	= try! FileManager.default.url(
											for:.documentDirectory,
											in:.userDomainMask,
											appropriateFor:nil,
											create:true)
			let suffix			= alt ? ".dae" : ".scn"
//			let fileURL 		= documentDirURL.appendingPathComponent("dumpSCN" + suffix)//.dae//scn//
			print("\n******************** '#': ==== Write out SCNNode to \(documentDirURL)dumpSCN\(suffix):\n")
bug;		let rootVews0scene	= vewss.first?.scnNodes.scnScene ?? {	fatalError("") } ()
//			guard rootVews0scene.write(to:fileURL, options:[:], delegate:nil)
//						else { fatalError("writing dumpSCN.\(suffix) failed")	}
		case "V":
			print("\n******************** 'V': Build the Model's Views:\n")
bug
//			for vews in rootVews {
//				parts!.forAllParts({	$0.markTree(dirty:.vew)			})
//				vews.updateVewSizePaint(for:"FactalsModel 'V'iew key")
//			}
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
bug
//			for vews in rootVews {
//				parts!.forAllParts({	$0.markTree(dirty:.size)		})
//				vews.updateVewSizePaint(for:"FactalsModel si'Z'e key")
//			}
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
bug
//			for vews in rootVews {
//				parts!.forAllParts({	$0.markTree(dirty:.paint)		})
//				vews.updateVewSizePaint(for:"FactalsModel 'P'aint key")
//			}
		case "w":
			print("\n******************** 'w': ==== FactalsModel = [\(pp())]\n")
		case "x":
			print("\n******************** 'x':   === FactalsModel: --> parts")
bug
//			if parts!.processEvent(nsEvent:nsEvent, inVew:vew) {
//				print("ERROR: factalsModel.Process('x') failed")
//			}
			return true								// recognize both
//		case "f": 					// // f // //
//			var msg					= ""
//			for vews in rootVews {
//				msg 				+= vews.rootScn.animatePhysics ? "Run   " : "Freeze"
//			}
//			print("\n******************** 'f':   === FactalsModel: animatePhysics <-- \(msg)")
//			return true								// recognize both
		case "?":
			printDebuggerHints()
			print ("\n=== FactalsModel   commands:",
				"\t'r'             -- r sound test",
				"\t'r'+cmd         -- go to lldb for rerun",
				"\t'v'             -- print Vew tree",
				"\t'n'             -- print User's SCNNode tree",
				"\t'#'             -- write out SCNNode tree as .scn",
				"\t'#'+alt         -- write out SCNNode tree as .dae",
				"\t'V'             -- build the Model's Views",
				"\t'T'             -- Size and pack the Model's Views",
				"\t'P'             -- Paint the skins of Views",
				"\t'w'             -- print FactalsModel camera",
				"\t'x'             -- send to model",
//				"\t'f'             -- Freeze SceneKit Animations",
				separator:"\n")
			found			= false
		default:					// // NOT RECOGNIZED // //
			found			= false
		}
		if found == false {

			 // Check Simulator:
	/**/	if simulator.processEvent(nsEvent:nsEvent, inVew:vew)  {
				return true 		// handled by simulator
			}

//			 // Check Document:
//			if document.processEvent(nsEvent:nsEvent, inVew:vew) {
//				return true			// handled by doc
//			}

			return false
		}
		return true					// comes here if recognized
	}

					  // ///////////////////////// //////////// //
					 // ///                   /// //
					// ///		 PIC         /// //
				   // ///                   /// //
	 // //////////// ///////////////////////// //
	
	/// Choose the Vew of v containing mouse point
	/// - Parameter n: an NSEvent (else current NSEvent)
	/// - Parameter v: specific base Vew (else check all rootVews)
	/// - Returns: The Vew of the part pressed
	func modelPic(with nsEvent:NSEvent, inVews v:VewBase?=nil) -> Vew? {
		let vewss2check : [VewBase]		= v==nil ? vewss : [v!]
		for vews in vewss2check {
			if let picdVew			= findVew(nsEvent:nsEvent, inVews:vews) {
				 // PART pic'ed, DISPATCH to it!
				if picdVew.part.processEvent(nsEvent:nsEvent, inVew:picdVew) {
					return picdVew
				}
			}
		}
		atEve(3, print("\t\t" + "** No Part FOUND\n"))
		return nil
	}

	func findVew(nsEvent:NSEvent, inVews vews:VewBase) -> Vew? {
		 // Find vews of NSEvent
//		guard let vews			= inVews				else { return nil		}
		guard let slot 			= vews.slot				else { return nil		}
//		let scenes:ScnNodes = vews.scenes			// SCNScene
//		let rv:VewBase?			= scenes.vews
//		let rn:SCNNode			= scenes.rootNode

		guard let nsView 		= NSApp.keyWindow?.contentView else { return nil}
		var msg					= "******************************************\n Slot\(slot): find "
		let locationInRoot		= nsView.convert(nsEvent.locationInWindow, from:nil)	// nil => from window coordinates //view
//
//		// There is in NSView: func hitTest(_ point: NSPoint) -> NSView?
//		// SCNSceneRenderer: hitTest(_ point: CGPoint, options: [SCNHitTestOption : Any]? = nil) -> [SCNHitTestResult]
//
//		 // Find the SCNView hit, somewhere in NSEvent's nsView			// SCNView holds a SCNScene
// 		var scnView : SCNView?	= nsView.hitTest(locationInRoot) as? SCNView	// in sub-View // nsView as? SCNView ?? 	// OLD WAY
//		guard let scnView else { fatalError("Couldn't find sceneView")			}
//
//		 // Find the 3D Vew for the Part under the mouse:
//		guard let rootNode		= scnView.scene?.rootNode else { fatalError("sceneView.scene is nil") }

		let vew					= vews.tree

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
			.rootNode:vew				// The root of the node hierarchy to be searched.
		]
bug;	let hits:[SCNHitTestResult] = []//vews.scenes.rootNode.hitTest(locationInRoot, options:configHitTest)//[SCNHitTestResult]() //
		//		 + +   + +		// hitTest in protocol SCNSceneRenderer

		 // SELECT HIT; prefer any child to its parents:
		var pickedScn :SCNNode	= vews.scnNodes.tree		// default is root
		if hits.count > 0 {
			// There is a HIT on a 3D object:
			let sortedHits		= hits.sorted {	$0.node.position.z > $1.node.position.z }
			let hit				= sortedHits[0]
			pickedScn			= hit.node // pic node with lowest deapth
		}
		msg 					+= "\(pickedScn.pp(.classUid))'\(pickedScn.fullName)':"	// SCNNode<3433>'/*-ROOT'
			
		// If Node not picable, try parent
		while pickedScn.categoryBitMask & FwNodeCategory.picable.rawValue == 0,
			  let parent 		= pickedScn.parent		// try its parent:
		{
			msg					+= fmt(" --> category %02x (Ignore)", pickedScn.categoryBitMask)
			pickedScn 			= parent				// use parent
			msg 				+= "\n\t " + "parent " + "\(pickedScn.pp(.classUid))'\(pickedScn.fullName)': "
		}

		// Get Vew from SCNNode
		guard let vew 				= vews.tree.find(scnNode:pickedScn, me2:true) else {
			if trueF 				{ return nil 		}		// Ignore missing vew
			panic(msg + "\n"+"couldn't find it in vew's ...") //\(vews.scn.pp(.classUid))")
			let vew 				= vews.tree.find(scnNode:pickedScn, me2:true) // for debug only
			return nil
		}
		msg							+= "      ===>    ####  ..."//\(vew.part.pp(.fullNameUidClass))  ####"
	//	msg							+= "background -> trunkVew"
		atEve(3, print("\n" + msg))
		return vew
	}

	 /// Toggel the specified vew, between open and atom
	func toggelOpen(vew:Vew) {
bug
//		let key 				= 0			// only element 0 for now
//		guard let vews		= vew.vews else {	fatalError("toggelOpen without VewBase")}
//
//		 // Toggel vew.expose: .open <--> .atomic
//		vew.expose 				= vew.expose == .open   ? .atomic :
//								  vew.expose == .atomic ? .open :
//								  						  .null
//	//	SCNTransaction.begin()
//		assert(vew.expose != .null, "")
//		let part				= vew.part
//
//		 // ========= Get Locks for two resources, in order: =============
//		guard parts!.lock(for:"toggelOpen") else {
//			fatalError("toggelOpen couldn't get PART lock")	}		// or
//		guard  vews.lock(for:"toggelOpen") else {fatalError("couldn't get Vew lock") }
//
//		assert(!(part is Link), "cannot toggelOpen a Link")
//		atAni(5, log("Removed old Vew '\(vew.fullName)' and its SCNNode"))
//		vew.scn.removeFromParent()
//		vew.removeFromParent()
//
//		vews.updateVewSizePaint(for:"toggelOpen4")
//
//		// ===== Release Locks for two resources, in reverse order: =========
//		vews  .unlock( for:"toggelOpen")										//		ctl.experiment.unlock(partTreeAs:"toggelOpen")
//		parts?.unlock(for:"toggelOpen")
//
//		let scenes			= vews.scenes
//bug;	scenes.commitCameraMotion(reason:"toggelOpen")
//		scenes.updatePole2Camera(reason:"toggelOpen")
//		atAni(4, part.logd("expose = << \(vew.expose) >>"))
//		atAni(4, part.logd(parts!.pp(.tree)))
//
//		if document.fmConfig.bool_("animateOpen") {	//$	/// Works iff no PhysicsBody //true ||
//
//			 // Mark old SCNNode as Morphing
//			let oldScn			= vew.scn
//			vew  .name			= "M" + vew   .name		// move old vew out of the way
//			oldScn.name!		= "M" + oldScn.name!	// move old scn out of the way
//			oldScn.scale		= .unity * 0.5			// debug
//			vew.part.markTree(dirty:.vew)				// mark Part as needing reVew
//
//			 //*******// Imprint animation parameters JUST BEFORE start:
//			vews.updateVewSizePaint()				// Update SCN's at START of animation
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
////			atRve??(8, logg("  /#######  SCNTransaction: BEGIN"))
//			SCNTransaction.animationDuration = CFTimeInterval(3)//3//0.3//10//
//			 // Imprint parameters AFTER "togelOpen" ends:
//			newScn.scale		= SCNVector3(0.7, 0.7, 0.7)	//.unity						// After Fade-in
//			oldScn.scale 		= SCNVector3(0.3, 0.3, 0.3) //.zero							// After Fade-out
//
//			SCNTransaction.completionBlock 	= {
//				 // Imprint JUST AFTER end, with OLD removed (Note: OLD == self):
//				assert(vew.scn == oldScn, "oops")
////				part.logg("Removed old Vew '\(vew.fullName)' and its SCNNode")
//				newScn.scale	= .unity
//				oldScn.scale 	= .unity	// ?? reset for next time (Elim's BUG?)
//				oldScn.removeFromParent()
//				vew.removeFromParent()
//				//*******//
//				vews.updateVewSizePaint()	// Imprint AFTER animation
//				//*******//	// //// wants a third animatio	qn (someday):
//			}
////			atRve??(8, logg("  \\#######  SCNTransaction: COMMIT"))
//			SCNTransaction.commit()
//		}
//	//	else {			/// just TEST CODE:
//	//		let x				= CGFloat(0.2)
//	//		let xPct			= SCNVector3(x, x, x)
//	//		 /// Imprint Initial Vew, before newScn has non-zero size
//	//		viewNew.scn.scale 	= xPct//.zero
//	//		self   .scn.scale 	= .unity
//	//		fws.updateVewSizePaint(needsLock:"toggelOpen5")	//\\//\\//\\//\\ To beginning of animation
//	//		 /// Imprint Final Vew
//	//		viewNew.scn.scale 	= .unity
//	//		self   .scn.scale 	= .zero//xPct//
//	//		fws.updateVewSizePaint(needsLock:"toggelOpen6")	//\\//\\//\\//\\ To end of animation
//	//
//	//		 /// Remove old vew and its SCNNode
//	//		atAni(4, log("Removed old Vew '\(fullName)' and its SCNNode"))
//	//		scn.scale			= .unity
//	//		scn.removeFromParent()
//	//		removeFromParent()
//	//	}
//	//https://forums.developer.apple.com/thread/111572
//	//			let morpher 		= SCNMorpher()
//	//			morpher.targets 	= [scn.geometry!]  	/// our old geometry will morph to 0
//	//		let node = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 5, chamferRadius: 0))
//	//		Controller.current?.factalsModel.rootNode.addChildNode(node)
//	//		node.morpher = morpher
//	//		let anim = CABasicAnimation(keyPath: "morpher.weights[0]")
//	//		anim.fromValue = 0.0
//	//		anim.toValue = 1.0
//	//		anim.autoreverses = true
//	//		anim.duration = 1
//	//		node.addAnimation(anim, forKey: nil)
	}
	 // MARK: - 15. PrettyPrint
//	func pp(_ mode:PpMode = .tree, _ aux:FwConfig) -> String	{
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{// CherryPick2023-0520:
		switch mode {
		case .line:
bug;		var rv				= ""//(rootPartActor.parts?.pp(.classUid, aux) ?? "parts=nil") + " "
//			var rv				= (parts?.pp(.classUid, aux) ?? "parts=nil") + " "
			rv					+= vewss.pp(.classUid, aux) + " "
//			if let document {
//				rv				+= document.pp(.classUid, aux)
//			}
			return rv
		default:
			return ppStopGap(mode, aux)		// NO, try default method
		}
	}


	func pq(_ mode:PpMode = .tree, _ aux:FwConfig) -> String	{
		pp(mode,aux)
	}


	 // MARK: - 17. Debugging Aids
	var description	  			  : String {	return  "d'\(pp(.short))'"		}
	var debugDescription 		  : String {	return "dd'\(pp(.short))'"		}
	var summary					  : String {	return  "s'\(pp(.short))'"		}
}
