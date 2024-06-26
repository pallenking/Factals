//  FactalsModel.swift -- Manage Parts, their simulation and viewing

import SceneKit
import SwiftUI

class FactalsModel : ObservableObject, Codable, Uid {
	var uid: UInt16				= randomUid()

	  // MARK: - 2. Object Variables:
	var fmConfig : FwConfig		= [:]
	var partBase : PartBase
	var vewBases : [VewBase]	= []

	var log 					= Log(name:"Model's Log", params4all)
	var	simulator				= Simulator()
	var docSound	 			= Sounds()

	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}

	 // MARK: - 3. Factory
	init(partBase rp:PartBase?=nil) {											// FactalsModel(fromRootPart rp:PartBase)
		partBase				= rp ?? PartBase(tree:Part())
		// self now valid /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		FACTALSMODEL			= self			// set UGLY GLOBAL
		simulator.factalsModel	= self			// backpointer
		partBase.factalsModel	= self			// backpointer
//		fmConfig				= params4pp	// SHOULD TAKE FROM FactalsApp.FactalsGlobals
//		configure(from:params4pp)
	}

	func configurePart(from config:FwConfig) {
		self.fmConfig			+= partBase.ansConfig	// from library

		log.configure(from:config)
		docSound.configure(from:config)

		partBase.configure(from:config)
		simulator.configure(from:config)
	}
	func configureVews(from config:FwConfig) {
		for (key, value) in config {				// params4all
			if key == "Vews",
			  let vewConfigs 	= value as? [VewConfig] {
				for vewConfig in vewConfigs	{	// Open one for each elt
					addRootVew(vewConfig:vewConfig, fwConfig:config)
				}
			}
			else if key.hasPrefix("Vew") {
				if let vewConfig = value as? VewConfig {
					addRootVew(vewConfig:vewConfig, fwConfig:config)
				}
				else {
					panic("Confused wo38r")
				}
			}
		}

		if vewBases.isEmpty {		// Must have a Vew
			//atBld(3, warning("no Vew... key, artificially adding Vew"))
			addRootVew(vewConfig:.openAllChildren(toDeapth:5), fwConfig:config)
		}
		for vewBase in vewBases {
			vewBase.configure(from:config)
		}

		 //  6. Print Part
//		atBld(2, logd("------- Parts, ready for simulation, simEnabled:\(simulator.simEnabled)):\n" + (pp(.tree, ["ppDagOrder":true]))))
		simulator.simBuilt		= true	// maybe before config4log, so loading simEnable works
//		simulator.simEnabled	= true
	}
	func addRootVew(vewConfig:VewConfig, fwConfig:FwConfig) {
		let vewBase				= VewBase(forPartBase:partBase)	// 1. Make with .null tree
		vewBase.factalsModel	= self						// 2. Backpointer
		vewBases.append(vewBase)							// 3. Install

		vewBase.tree.configureVew(from:fwConfig)			// 4. Configure Vew
		vewBase.tree.openChildren(using:vewConfig)			// 5. Open Vew

//		tree.dirtySubTree(gotLock:true, .vsp)				// 6. Mark dirty
		vewBase.updateVewSizePaint(vewConfig:vewConfig)		// 7. Graphics Pipe		// relax to outter loop stuff
		vewBase.setupLightsCamerasEtc()						// ?move

		let rootVewPp			= vewBase.pp(.tree, ["ppViewOptions":"UFVTWB"])
		atBld(5, log.logd("rootVews[] is complete:\n\(rootVewPp)"))
	}

////////////////////
	var data2 : Data? {
		do {
			return try JSONEncoder().encode(self)
		} catch {
			print("\(error)")
			return nil
		}
	}

	///



//	// FileDocument requires these interfaces:
	 // Data in the SCNScene
	var data : Data? {
		do {		// 1. Write SCNScene to file. (older, SCNScene supported serialization)
			return try JSONEncoder().encode(self)
										//	try self.write(to: fileURL)
										//	try self.document.write(to: fileURL)
		} catch {
			print("error writing file: \(error)")
			return nil
		}
										//	let data				= try? Data(contentsOf:fileURL)
										//	return data//Cannot convert value of type '() -> ()' to expected argument type 'Int'
	}
	 // initialize new SCNScene from Data
	convenience init?(data:Data, encoding:String.Encoding) {
		fatalError("FactalsModel.init?(data:Data")
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
//		try container.encode(simulator,			forKey:.simulator				)
		fatalError("FactalsModel.encode(coder..) unexpectantly called")
	}
	 // ///////// Deserialize
	required init(from decoder: any Decoder) throws {
		fatalError("FactalsModel.init(from decoder..) unexpectantly called")
	}
	required init(coder aDecoder: NSCoder) {
		fatalError("FactalsModel.init(coder..) unexpectantly called")
	}

	 // MARK: - 4.?
	func vew(ofScnNode  s:SCNNode) -> Vew? {	vewBase(ofScnNode:s)?.tree 		}
	func vewBase(ofScnNode s:SCNNode) -> VewBase? {
		for vews in vewBases {
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
		guard let partBase : PartBase = vew.part.partBase else { return false }	// vew.partBase.part
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
			print(partBase.pp(.tree, aux), terminator:"")
		case "M":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'M': === Parts and Ports:")
			print(partBase.pp(.tree, aux), terminator:"")
		case "l":
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'l': === Parts, Links:")
			print(partBase.pp(.tree, aux), terminator:"")
		case "L":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			print("\n******************** 'L': === Parts, Ports, Links:")
			print(partBase.pp(.tree, aux), terminator:"")

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
			for vews in vewBases {
				vews.scnBase.tree?.play(sound:"Oooooooo")		//GameStarting
			}
		case "v":
			print("\n******************** 'v': ==== Views:")
			for vews in vewBases {
				print("-------- ptv0   rootVews[++]:\(ppUid(vews)):")
				print("\(vews.pp(.tree))", terminator:"")
			}
		case "n":
			print("\n******************** 'n': ==== SCNNodes:")
			log.ppIndentCols = 3
			for vews in vewBases {
				print("-------- ptn   rootVews(\(ppUid(vews))).rootScn(\(ppUid(vews.scnBase)))" +
					  ".scn(\(ppUid(vews.scnBase))):")
				print(vews.scnBase.pp(.tree), terminator:"")
			}
		case "#":				// OUTPUT MODEL
			let documentDirURL	= try! FileManager.default.url(
											for:.documentDirectory,
											in:.userDomainMask,
											appropriateFor:nil,
											create:true)
			let suffix			= alt ? ".dae" : ".scn"
			let fileURL 		= documentDirURL.appendingPathComponent("dumpSCN" + suffix)//.dae//scn//
			print("\n******************** '#': ==== Write out SCNNode to \(documentDirURL)dumpSCN\(suffix):\n")
			let rootVews0scene	= vewBases.first?.scnBase.scnScene ?? {	fatalError("") } ()
			guard rootVews0scene.write(to:fileURL, options:[:], delegate:nil)
						else { fatalError("writing dumpSCN.\(suffix) failed")	}
		case "V":
			print("\n******************** 'V': Build the Model's Views:\n")
			for vews in vewBases {
				partBase.tree.forAllParts({	$0.markTree(dirty:.vew)			})
				vews.updateVewSizePaint(for:"FactalsModel 'V'iew key")
			}
		case "Z":
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			for vews in vewBases {
				partBase.tree.forAllParts({	$0.markTree(dirty:.size)		})
				vews.updateVewSizePaint(for:"FactalsModel si'Z'e key")
			}
		case "P":
			print("\n******************** 'P': Paint the skins of Views:\n")
			for vews in vewBases {
				partBase.tree.forAllParts({	$0.markTree(dirty:.paint)		})
				vews.updateVewSizePaint(for:"FactalsModel 'P'aint key")
			}
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
			return false
		}
		return true					// comes here if recognized
	}
	 // MARK: - 5.1 Make Associated Inspectors:
	  /// Manage Inspec's:
	var lastInspecVew:Vew?		= nil		// Last Vew may be needed again
	var lastInspecWindow :NSWindow? = nil		//
	var inspecWindow4vew:[Vew:NSWindow] = [:]									//[Vew : [weak NSWindow]]

	func makeInspectors() {
		atIns(7, print("code makeInspectors"))
			// TODO: should move ansConfig stuff into wireAndGroom
bug
		if let vew2inspec		= fmConfig["inspec"] {
			if let name			= vew2inspec as? String {	// Single String
				showInspec(for:name)
			}
			else if let names 	= vew2inspec as? [String] {	// Array of Strings
				for name in names {								// make one for each
					showInspec(for:name)
				}
			} else {
				panic("Illegal type for inspector:\(vew2inspec.pp(.line))")	}
		}
	}
	func showInspec(for name:String) {
		bug
		if let part	= partBase.tree.find(name:name) {
	
			 // Open inspectors for all RootVews:
			for vewBase in vewBases {
		 		if let vew = vewBase.tree.find(part:part) {
					showInspecFor(vew:vew, allowNew:true)
				}
			}
		}
		else {
			atIns(4, warning("Inspector for '\(name)' could not be opened"))
		}
	}
		 /// Show an Inspec for a vew.
		/// - Parameters:
	   ///  - vew: vew to inspec
	  ///   - allowNew: window, else use existing
	 func showInspecFor(vew:Vew, allowNew:Bool) {
		let vewsInspec			= Inspec(vew:vew)
		var window : NSWindow?	= nil

		if let iw				= lastInspecWindow {		// New, less functional manner
			iw.close()
			self.lastInspecWindow	= nil
		} else {										// Old broken way
			 // Find an existing NSWindow for the inspec
			window 				= inspecWindow4vew[vew]	// Does one Exist?
			if window == nil,								// no,
			  !allowNew,									// Shouldn't create
			  let lv			= lastInspecVew {
				window			= inspecWindow4vew[lv]				// try LAST
			}
		}

		// PW+4: How do I access MainMenu from inside SwiftUI
		// PW3: What is the right way to display vewsInspec? as popup?, window?, WindowGroup?...
		if window == nil {								// must make NEW
			let hostCtlr		= NSHostingController(rootView:vewsInspec)		// hostCtlr.view.frame = NSRect()
			 // Create Inspector Window (Note: NOT SwiftUI !!)
			window				= NSWindow(contentViewController:hostCtlr)	// create window
			// Picker: the selection "-1" is invalid and does not have an associated tag, this will give undefined results.
			window!.contentViewController = hostCtlr		// if successful
		}
		guard let window 		else { fatalError("Unable to fine NSWindow")	}

				// Title window
		window.title			= vew.part.fullName
		window.subtitle			= "Slot\(vew.vewBase()?.slot ?? -1)"

				// Position on screen: Quite AD HOC!!
		window.orderFront(self)				// Doesn't work -- not front when done!
		window.makeKeyAndOrderFront(self)
		window.setFrameTopLeftPoint(CGPoint(x:300, y:1000))	// AD-HOC solution -- needs improvement

			// Remember window for next creation
		lastInspecVew			= vew			// activate Old way
		lastInspecWindow		= window		// activate New way
		inspecWindow4vew[vew]	= window		// activate Old way
	}

	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
		print("modelDispatch(fwEvent: to:")
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
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{// CherryPick2023-0520:
		switch mode {
		case .line:
			var rv				=  partBase.pp(.classUid, aux) + " "		//""//(rootPartActor.parts?.pp(.classUid, aux) ?? "parts=nil") + " "
			rv					+= vewBases.pp(.classUid, aux) + " "
			return rv
		default:
			return ppFixedDefault(mode, aux)		// NO, try default method
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
