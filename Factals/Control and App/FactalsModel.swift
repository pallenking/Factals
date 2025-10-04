//  FactalsModel.swift -- Manage Parts, RootVews and their RootScns

import SceneKit
import SwiftUI

@Observable
 class FactalsModel : Uid {
	let nameTag					= getNametag()
 	var epoch: UInt16			= 1				// to mark dirty
	  // MARK: - 2. Object Variables:
	var fmConfig  : FwConfig
	var partBase  : PartBase
	var simulator : Simulator
	var vewBases  : [VewBase] 	= []

	func aKeyIsDown() -> Bool {			//vewFirstThatReferencesUs?
		for vewBase in vewBases {
			if ((vewBase.gui?.delegate as? ScnBase)?.keyIsDown) != nil { return true 					}
		}
		return false
	}
	 // MARK: - 3. Factory
	init(partBase pb:PartBase, configure c:FwConfig) {	// FactalsModel(partBase:)
		partBase				= pb
		simulator 				= Simulator(configure:c)
		fmConfig				= c				// Save in ourselves   WHY???

		 // self now valid /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		if let fm 				= FACTALSMODEL {
			 print("******** FACTALSMODEL already set by \(fm) ********")	//assert(FACTALSMODEL == nil, "FACTALSMODEL is nil")
		}
		FACTALSMODEL			= self			// set GLOBAL <<<< UGLY >>>>

		partBase .factalsModel	= self			// backpointer
		simulator.factalsModel	= self			// backpointer

		partBase.configure(from:fmConfig)
	}

	func createVews(from config:FwConfig) {
		 // Create new Views from FwConfig
		for (key, value) in config {				// params4all
			if key == "Vews",
			  let vewConfigs 	= value as? [VewConfig] {
				for vewConfig in vewConfigs			// Open one for each elt
				{	NewVewBase(vewConfig:vewConfig, fwConfig:config)			}
			}
			else if key.hasPrefix("Vew") {
				if let vewConfig = value as? VewConfig
				{	NewVewBase(vewConfig:vewConfig, fwConfig:config)			}
				else {	panic("Confused wo38r")									}
			}
		}

		 // Ensure 1 View
		if vewBases.isEmpty 			//false,
		{	NewVewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:config)	}
	}
	func NewVewBase(vewConfig:VewConfig, fwConfig:FwConfig) {
		let vewBase				= VewBase(vewConfig:vewConfig, fwConfig:fwConfig)
		vewBase.partBase		= partBase
		vewBase.factalsModel	= self
		vewBase.gui 			= nil			// A signal of need!
		vewBases.append(vewBase)
		vewBase.updateVSP() 								// DELETE?
	}
	 // MARK: - 3.5 Codable
	 // ///////// Serialize
	func encode(to encoder: Encoder) throws  {
//		try container.encode(simulator,			forKey:.simulator				)
		debugger("FactalsModel.encode(coder..) unexpectantly called")
	}
	 // ///////// Deserialize
	required init(coder aDecoder: NSCoder) {
		debugger("FactalsModel.init(coder..) unexpectantly called")
	}
	 // MARK: - 4.?
	func vewBase(ofVew v:Vew)  -> VewBase? {							//	func vewBase(ofScnScene s:SCNScene) -> VewBase? {
		for vewBase in vewBases {
			if vewBase.tree.find(vew:v, inMe2:true) != nil { return vewBase		}
		}
		return nil
	}
//	func vew(    ofScnNode s:SCNNode) -> Vew? {	bug; return nil}//vewBase(ofScnScene:s)?.tree 		}
//	func vewBase(ofScnNode s:SCNNode)  -> VewBase? {							//	func vewBase(ofScnScene s:SCNScene) -> VewBase? {
//		for vewBase in vewBases {
//			if vewBase.tree.scn.find(firstWith:{ $0 == s }) != nil {
//				return vewBase
//			}
//		}
//		return nil
//	}
	  // MARK: - 9.0 3D Support
	 // mouse may "paw through" parts, using wiggle
	var wiggledPart	  : Part?	= nil
	var wiggleOffset  : SCNVector3? = nil		// when mouse drags an atom

	 // MARK: - 5.1 Make Associated Inspectors:

	 /// Toggel the specified vew, between open and atom
	func toggelOpen(vew:Vew) {
		guard vew.expose != .null else { print("vew.expose == .null  NOT supported");return}
		guard !(vew.part is Link) else { print("cannot toggelOpen a Links");return }

		 // do on only 1 vew!!
		doPartNViewsLocked(onlyVew:vew, workNamed:"toggelOpen", logIf:true) {_ in
			 // Toggel vew.expose: .open <--> .atomic
			vew.expose 			= vew.expose == .open   ? .atomic
								: vew.expose == .atomic ? .open
								: 						  .null
			
			logAni(5, "Changed '\(vew.fullName).expose' to \(vew.expose)")
		}
	}

//		let workName			= "toggelOpen"
//		guard partBase.lock(for:workName, logIf:true) else {
//			debugger("toggelOpen couldn't get PART lock")	}		// or
//		guard  vew.vewBase()?.lock(for:workName, logIf:true) ?? false else {debugger("couldn't get Vew lock") }
//
//bug;	let partBase			= vew.part.partBase
//		let vewBase				= vewBases.first(where: {
//			$0.tree.find(vew:vew, up2:false, inMe2:true, maxLevel: 9999) == vew
//		})
//		guard let vewBase		else {	fatalError()							}
//		let slot_				= vewBase.slot
//
//bug//	vew.scnScene.removeFromParent()
//		vew.removeFromParent()
//


//		vewBase.updateVSP()
//
//		// ===== Release Locks for two resources, in reverse order: =========
//		vewBase  .unlock(for:workName, logIf:true)		//ctl.experiment.unlock(partTreeAs:"toggelOpen")
//		partBase!.unlock(for:workName, logIf:true)
//
//		let scenes				= vewBase.scenes
//		scenes.(reason:"toggelOpen")
//		scenes.updatePole2Camera(reason:"toggelOpen")
//		logAni(4, "expose = << \(vew.expose) >>")
//		logAni(4, parts!.pp(.tree))
//
//		if document.fmConfig.bool_("animateOpen") {	//$	/// Works iff no PhysicsBody //true ||
//
//			 // Mark old SCNNode as Morphing
//			let oldScn			= vew.scnScene
//			vew  .name			= "M" + vew   .name		// move old vew out of the way
//			oldScn.name!		= "M" + oldScn.name!	// move old scnScene out of the way
//			oldScn.scale		= .unity * 0.5			// debug
//			vew.part.markTreeDirty(bit:.vew)				// mark Part as needing reVew
//
//			 //*******// Imprint animation parameters JUST BEFORE start:
//			vews.updateVewSizePaint()				// Update SCN's at START of animation
//			 //*******//
//
//			 // Animate Vew morph, from self to newVew:
//			guard let newScn	= vew.parent?.find(name:"_" + part.name)?.scnScene else {
//				debugger("updateVew didn't creat a new '_<name>' vew!!")
//			}
//			newScn.scale		= .unity * 0.3 //0.1, 0.0 	// New before Fade-in	-- zero size
//			oldScn.scale		= .unity * 0.7 //0.9, 1.0	// Old before Fade-out	-- full size
//
//			SCNTransaction.begin()
////			logRve??(8, logg("  /#######  SCNTransaction: BEGIN"))
//			SCNTransaction.animationDuration = CFTimeInterval(3)//3//0.3//10//
//			 // Imprint parameters AFTER "togelOpen" ends:
//			newScn.scale		= SCNVector3(0.7, 0.7, 0.7)	//.unity						// After Fade-in
//			oldScn.scale 		= SCNVector3(0.3, 0.3, 0.3) //.zero							// After Fade-out
//
//			SCNTransaction.completionBlock 	= {
//				 // Imprint JUST AFTER end, with OLD removed (Note: OLD == self):
//				assert(vew.scnScene == oldScn, "oops")
////				part.logg("Removed old Vew '\(vew.fullName)' and its SCNNode")
//				newScn.scale	= .unity
//				oldScn.scale 	= .unity	// ?? reset for next time (Elim's BUG?)
//				oldScn.removeFromParent()
//				vew.removeFromParent()
//				//*******//
//				vews.updateVewSizePaint()	// Imprint AFTER animation
//				//*******//	// //// wants a third animatio	qn (someday):
//			}
////			logRve??(8, logg("  \\#######  SCNTransaction: COMMIT"))
//			SCNTransaction.commit()
//		}
//	//	else {			/// just TEST CODE:
//	//		let x				= CGFloat(0.2)
//	//		let xPct			= SCNVector3(x, x, x)
//	//		 /// Imprint Initial Vew, before newScn has non-zero size
//	//		viewNew.scnScene.scale 	= xPct//.zero
//	//		self   .scnScene.scale 	= .unity
//	//		fws.updateVewSizePaint(needsLock:"toggelOpen5")	//\\//\\//\\//\\ To beginning of animation
//	//		 /// Imprint Final Vew
//	//		viewNew.scnScene.scale 	= .unity
//	//		self   .scnScene.scale 	= .zero//xPct//
//	//		fws.updateVewSizePaint(needsLock:"toggelOpen6")	//\\//\\//\\//\\ To end of animation
//	//
//	//		 /// Remove old vew and its SCNNode
//	//		logAni(4, log("Removed old Vew '\(fullName)' and its SCNNode"))
//	//		scnScene.scale			= .unity
//	//		scnScene.removeFromParent()
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
	// MARK: - 9 Update Vew: -
	 /// Do  work in all VewBases, unless onlyView!=nil
	func doPartNViewsLocked(onlyVew:Vew?=nil, workNamed:String, logIf:Bool, work:(_:VewBase)->Void) {
		guard partBase  .lock  (for:workNamed, logIf:logIf)
								else {debugger(" couldn't get PART lock")		}
								
		 // Do change work to ALL Views:
		for (i, vewBase) in vewBases.enumerated() {
			let ovb					= onlyVew?.vewBase()
			if ovb==nil || ovb == vewBase {			// all if onlyVew==nilvvvvvvv
				guard vewBase  .lock  (for:"\(workNamed)[\(i)]", logIf:logIf)
									else {debugger(" couldn't get VEW lock")	}

				work(vewBase)			// Do desired changes

				vewBase.updateVSP()		// Update Vews and their Scns

				vewBase      .unlock  (for:"\(workNamed)[\(i)]", logIf:logIf)
			}
		}

		 // Clear all change bits:
		partBase.tree.forAllParts { $0.dirty = .clean 							}
		partBase  .unlock  (for:workNamed, logIf:logIf)
	}

	   /// Update the Vew Tree from Part Tree
	  /// - Parameter as:		-- name of lock owner. Obtain no lock if nil.
	 /// - Parameter log: 		-- log the obtaining of locks.
	func updateVews(initial:VewConfig?=nil, logIf log:Bool=true) { // VIEWS
		let workName				= "updateVew"
		SCNTransaction.begin()
		SCNTransaction.animationDuration = CFTimeInterval(0.15)	//0.3//0.6//

		assert(partBase.curOwner==nil, "shouldn't be")
		guard  partBase.lock(for:workName, logIf:log) else {		// don't use assert
			debugger("failed to get lock")
		}																		//assert(partBase  .lock  (for:workName, logIf:log), "failed to get lock")
		doPartNViewsLocked(workNamed:workName, logIf:log) { vewBase in

			vewBase.updateVSP()		//##
		}

		partBase  .unlock  (for:workName, logIf:log)
		SCNTransaction.commit()
	}
	 // MARK: - 13. IBActions
		/// Prosses keyboard key
       /// - Parameter from: -- NSEvent to process
      /// - Parameter vew: -- The Vew to use
	 /// - Returns: The key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {return false}
		guard let partBase		= vew?.part.partBase else { return false 		}

		 // Check Simulator:
/**/	if simulator.processEvent(nsEvent:nsEvent, inVew:vew!)  {
			return true 					// handled by simulator
		}
		guard nsEvent.type == .keyDown else { return false}// /// Key UP ///////
														   // /// Key DOWN /////
		 // Check FactalsModel:
		let cmd 				= nsEvent.modifierFlags.contains(.command)
		let alt 				= nsEvent.modifierFlags.contains(.option)
		var aux : FwConfig		= fmConfig	// gets us params4pp
		aux["ppParam"]			= alt		// Alternate means print parameters

		var found				= true
		switch character {
		case "u": // + cmd						// misplaced ^u
			if cmd {
				panic("Press 'cmd u'   A G A I N    to retest")	// break to debugger
			}
		case Character("\u{1b}"):				// Escape -- exit program
			print("\n******************** 'esc':  === EXIT PROGRAM\n")
			NSSound.beep()
			exit(0)								// exit program (hack: brute force)
		case "b":								// to debugger
			print("\n******************** 'b': ======== keyboard break to debugger")
			panic("'?' for debugger hints")
		case "m":								// print Model
			aux["ppDagOrder"]	= true
			print("\n******************** 'm': === Parts:")
			print(partBase.pp(.tree, aux), terminator:"")
		case "M":								// print Model and Ports
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'M': === Parts and Ports:")
			print(partBase.pp(.tree, aux), terminator:"")
		case "l":								// print Model and Links
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'l': === Parts, Links:")
			print(partBase.pp(.tree, aux), terminator:"")
		case "L":								// print Model Ports and Links""
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			print("\n******************** 'L': === Parts, Ports, Links:")
			print(partBase.pp(.tree, aux), terminator:"")

		 // N.B: The following are preempted by AppDelegate keyboard shortcuts in Menu.xib
		case "c":								// print Controller State
			print(ppControlElement())
		case "C":								// print Controller Config
			print(ppControlElement(config:true))

		case "r": // (+ cmd)					// go to lldb for rerun
			if cmd {
				panic("Press 'cmd r'   A G A I N    to rerun")	// break to debugger
				return true 									// continue
			}
	  //case "r" alone:							// Sound Test
			print("\n******************** 'r': === reset model\n")
			partBase.tree.reset()
			partBase.tree.dirtySubTree(.vsp)
//			print("\n******************** 'r': === play(sound(\"GameStarting\")\n")
//			for vews in vewBases {
//				vews.scnBase.scene?.rootNode.play(sound:"Oooooooo")		//GameStarting
//			}
		case "v":								// print Vew tree
			print("\n******************** 'v': ==== Views:")
			for vews in vewBases {
				print("-------- ptv0   rootVews[++]:\(ppUid(vews)):")
				print("\(vews.pp(.tree))", terminator:"")
			}
		case "n":								// print SCNNode tree
			print("\n******************** 'n': ==== SCNNodes:")
//			log.ppIndentCols = 3
			for vewBase in vewBases {
				print("-------- ptn   rootVews(\(ppUid(vewBase))).rootScn(\(ppUid(vewBase.gui)))" +//scnBase
					  ".scnScene(\(ppUid(vewBase.gui))):")	//scnBase
				print(vewBase.gui?.pp(.tree) ?? "gui=nil", terminator:"")//scnBase
			}
		case "#":								// write out SCNNode tree as .scnScene
			let documentDirURL	= try! FileManager.default.url(
											for:.documentDirectory,
											in:.userDomainMask,
											appropriateFor:nil,
											create:true)
			let suffix			= alt ? ".dae" : ".scnScene"
			let fileURL 		= documentDirURL.appendingPathComponent("dumpSCN" + suffix)//.dae//scn//
			print("\n******************** '#': ==== Write out SCNNode to \(documentDirURL)dumpSCN\(suffix):\n")
			let rootVews0scene	= vewBases.first?.gui?.getScene ?? {debugger("")}()	//scnBase
			guard rootVews0scene.write(to:fileURL, options:[:], delegate:nil)
						else { debugger("writing dumpSCN.\(suffix) failed")	}
		case "V":								// Update Views
			print("\n******************** 'V': Update Views:\n")
			partBase.tree.forAllParts({		$0.markTreeDirty(bit:.vew)				})
			updateVews()		//(key instgated)
		case "Z":								// Update siZe
			print("\n******************** 'Z': siZe ('s' is step) and pack the Model's Views:\n")
			partBase.tree.forAllParts({		$0.markTreeDirty(bit:.size)			})
			updateVews()
		case "P":								// Paint the skins of Views
			print("\n******************** 'P': Paint the skins of Views:\n")
			partBase.tree.forAllParts({	$0.markTreeDirty(bit:.paint)			})
			updateVews()
		case "w": bug
			print("\n******************** 'w': ==== FactalsModel = [\(pp())]\n")
		case "x":
			print("\n******************** 'x':   === FactalsModel: --> parts")
	bug	//	if parts!.processEvent(nsEvent:nsEvent, inVew:vew) {
			return true								// recognize both
		case "f": 						// // f // //
			var msg					= "\n"
			for vewBase in vewBases {
				guard let gui		= vewBase.gui else {	continue		}
				gui.animatePhysics ^^= true
				msg 				+= "\(vewBase.pp(.fullNameUidClass)) " +
									(gui.animatePhysics ? "Run   " : "Freeze")
			}
			print("\n******************** 'f':   === FactalsModel: animatePhysics <-- \(msg)")
			return true								// recognize both
		case "?":
			printDebuggerHints()
			print ("\n=== FactalsModel   commands:",
				"\t'u'+cmd         -- misplaced ^u should go to xcode",
				"\t'esc'           -- exit program",
				"\t'b'             -- break to debugger",
//				"\t'd'             -- ",
				"\t'm'             -- print Model",
				"\t'M'             -- print Model and Ports",
				"\t'l'             -- print Model and Links",
				"\t'L'             -- print Model Ports and Links",
				"\t'c'             -- print Controller State",
				"\t'C'             -- print Controller Config",
				"\t'?'             -- print help",
				"\t'r'+cmd         -- go to lldb for rerun",
				"\t'r'             -- reset model",
//				"\t'r'             -- r sound test",
				"\t'v'             -- print Vew tree",
				"\t'n'             -- print SCNNode tree",
				"\t'#'             -- write out SCNNode tree as .scnScene",
				"\t'#'+alt         -- write out SCNNode tree as .dae",
				"\t'V'             -- Update Views",
				"\t'Z'             -- Update siZe",
				"\t'T'             -- Size and pack the Model's Views",
										//
				"\t'P'             -- Paint the skins of Views",
				"\t'w'             -- print FactalsModel",
			//	"\t'x'             -- send to model",
			//	"\t'f'             -- Freeze SceneKit Animations",
				separator:"\n")
			found			= false	// '?' special case, to show all
		default:					// // NOT RECOGNIZED // //
			found			= false
		}
		return found															//|| simulator.processEvent(nsEvent:nsEvent, inVew:vew!)
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig=params4defaultPp) -> String	{// CherryPick2023-0520:
		switch mode {
		case .line:
			var rv				= "\(partBase.tree.pp(.classTag, aux)) "
			rv					+= "\(vewBases.count) VewBases "
			return rv
		default:
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
	}
	 // MARK: - 17. Debugging Aids
	var description	  			  : String {	return "'\(pp(.short))'"		}
	var debugDescription 		  : String {	return "'\(pp(.short))'"		}
	var summary					  : String {	return "'\(pp(.short))'"		}
}

