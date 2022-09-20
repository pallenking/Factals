//// //  FwDocument.swift -- Manage RootPart (creation, simulation, and display)  C2018PAK
////import SceneKit
////import SwiftUI
////
////// This application can have multiple a
////// An FwDocument manages one HNW Network.
////// It contains a HaveNWant network (including both environment and brain)
//////		with one or more perspective visualization as a 3D object,
//////			at a particular instant in its time simulation.
////// open, edit, and view networks as they are forward-simulated in time.
////
////// A basic tutorial (not for bug hunting):
//////	http://sketchytech.blogspot.com/2016/09/taming-nsdocument-and-understanding.html
////
//class FwDocument: NSDocument	{
//
//	 // MARK: - 2.1 Object Variables:
//	// An FwDocument owns two resources:
//	var rootPart	: RootPart!				// to manage
//	@IBOutlet weak
//	 var fwView		: FwView?				// IB sets this
//
//	 /// Filter keys for XCTest alternative
//	var documentParamPrefix : String = isRunningXcTests ? "*" : ""
//	var uidForDeinit			= "uninitialized"		// just logging
//
////	var indexFor			= ["":0]	// index of naming Part
//
//	 // MARK: - 2.2 Sugar
//	var fwGuts    : FwGuts?	{		fwView?.fwGuts							}
//	var windowController0 : NSWindowController? {		// First NSWindowController
//		return windowControllers.count > 0 ? windowControllers[0] : nil			}
//	var window0 : NSWindow? 	{						// First NSWindow
//		return windowController0?.window										}
//
//	   // MARK: - 3. Factory
//	enum MyError : Error {	case libraryFailure, funcky							}
//	  // MARK: - *** A FwDocument()
//	override convenience init() {
//		do {
//			try self.init(type:nil)												}
//		catch {
//			fatalError("override convenience FwDocument.init()")				}
//	}
//	  // MARK: - *** B FwDocument(type:)/
//	 // System comes here to generate a new document, with typeName=="DocumentType"
//	// "DocumentType" (somehow) is bound to the file suffix: "sf" in inof.plist
//	init(type typeName: String?) throws {
//		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//
//		uidForDeinit			= ppUid(self)				// HACK to allow deinit to print UID'sa
//		fileType				= typeName ?? fileType
//
//		DOC						= self			// not kosher!
//
//		assert(APPDEL != nil, "APPDEL == nil")
//		let emptyEntry	= APPDEL?.config4app.string("emptyEntry")
//		assert(emptyEntry != nil, "config4app contains no key 'emptyEntry'")
//
//		rootPart				= RootPart(fromLibrary:emptyEntry!, fwDocument:self)
// Backlinks 20220919PAK:	rootPart.fwGuts			= fwGuts
//		if rootPart == nil {
//			throw MyError.libraryFailure
//		}
//		rootPart.wireAndGroom()
//	}							// next is windowControllerDidLoadNib
//
//	 // MARK: - *** C FwDocument(fromLibrary_selectedBy:)/
//	init(fromLibrary_selectedBy selectionString:String) throws {
//		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		uidForDeinit			= ppUid(self)				// HACK to allow deinit to print UID'sa
//
//		DOC						= self			// not kosher!
//
//		rootPart				= RootPart(fromLibrary:selectionString, fwDocument:self)
// Backlinks 20220919PAK:	rootPart.fwGuts			= fwGuts
//		if rootPart == nil {
//			throw MyError.libraryFailure
//		}
//		rootPart.wireAndGroom()
//	}							// next is windowControllerDidLoadNib
//	 // MARK: - *** D FwDocument(for:withContentsOf:ofType:)
//	init(for url:URL?, withContentsOf contents:URL, ofType type: String) throws {
//		if falseF	{	panic("");	throw MyError.funcky						}
//		rootPart				= RootPart()
// Backlinks 20220919PAK:	rootPart.fwGuts			= fwGuts
//
//		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		fileType				= type			// Document for type:typename is somehow bound to file suffix: "sf" in inof.plist	//typeName == "DocumentType" ? "(for .sf files)" : ""	// AD HOC
//		DOC						= self			// not kosher!
//
//		 // Read RootPart, the only saved attribute of Docuemnt
//		let data 				= try Data(contentsOf:contents)
//		try read(from:data, ofType:type)		// loads fwContoller
//
//bug		 //************//
///*??*/	fwGuts?.updateVews(fromRootPart:rootPart)
//		 //************//
//
////		makeInspectors()
//	}
//
//	deinit {
//		// N.B: Log.log("...") evokes simulteneity lock error
//		Swift.print("#### DEINIT   \(uidForDeinit):FwDocument")			// WORKS
//	//	Swift.print("#### DEINIT   \(uid):FwDocument")					// FAILS
//	//	Swift.print("#### DEINIT   \(ppUid(self):FwDocument)")			// FAILS
//	}
//
					//	 // MARK: - 3.4 NSKeyedArchiver Serialization
					//	// ////////////// NSDocument calls these: /////////////////////////////
					//
					//	   // http://meandmark.com/blog/2016/03/saving-game-data-with-nscoding-in-swift/
					//	  //  https://stackoverflow.com/questions/53097261/how-to-solve-deprecation-of-unarchiveobjectwithfile
					//	 // WRITE to data (e.g. file) from objects		USES NSKeyedArchiver
					//	override func data(ofType typeName: String) throws -> Data {
					//		do {
					//			 // ---- 1. Get LOCKS for PartTree
					//			let lockStr			= "writePartTree"
					//			guard	rootPart.lock(partTreeAs:lockStr) else {
					//				fatalError("\(lockStr) couldn't get PART lock")		// or
					//			}
					//
					//							// PREPARE
					//			atSer(3, logd("Writing data(ofType:\(typeName))"))
					//			 // ---- 2. Retract weak crossReference .connectedTo in Ports, replace with absolute string
					///* */		rootPart.virtualize()
					//
					//			let aux : FwConfig	= ["ppDagOrder":false, "ppIndentCols":20, "ppLinks":true]
					//			atSer(5, logd("========== rootPart to Serialize:\n\(rootPart.pp(.tree, aux))", terminator:""))
					//
					//			 // ---- 3. INSERT -  PolyWrap's to handls Polymorphic nature of Parts
					///* */		let inPolyPart:PolyWrap	= rootPart.polyWrap()	// modifies rootPart
					//			atSer(5, logd("========== inPolyPart with Poly's Wrapped :\n\(inPolyPart.pp(.tree, aux))", terminator:""))
					//
					//							// MAKE ARCHIVE
					//			 // Pretty Print the virtualized, PolyWrap'ed structure, using JSON
					////			let jsonData : Data	= try JSONEncoder().encode(inPolyPart)
					//			if falseF {
					//				let jsonData : Data	= try JSONEncoder().encode(inPolyPart)
					//				guard let jsonString = jsonData.prettyPrintedJSONString else {
					//					fatalError("\n" + "========== JSON: FAILED")	}
					//				atSer(5, logd("========== JSON: " + (jsonString as String)))
					//			}
					//			 // ---- 4. ARCHIVE the virtualized, PolyWrapped structure
					//			let archiver = NSKeyedArchiver(requiringSecureCoding:true)
					//																	// *******:
					//			try archiver.encodeEncodable(inPolyPart, forKey:NSKeyedArchiveRootObjectKey)
					//			archiver.finishEncoding()
					//
					//							// RESTORE
					//			 // ---- 3. REMOVE -  PolyWrap's
					///* */		let rp				= inPolyPart.polyUnwrap() as? RootPart
					//			assert(rp != nil, "inPolyPart.polyUnwrap()")
					//			rootPart			= rp!
					//
					//			 // ---- 2. Replace weak references
					///* */		rootPart.realize()			// put references back	// *******
					//			rootPart.groomModel(parent:nil, root:rootPart)
					//			atSer(5, logd("========== rootPart unwrapped:\n\(rootPart.pp(.tree, ["ppDagOrder":false]))", terminator:""))
					//
					//			 // ---- 1. Get LOCKS for PartTree
					//			rootPart.unlock(partTreeAs:lockStr)
					//
					//			rootPart.indexFor	= [:]			// HACK! should store in fwDocument!
					//
					//			atSer(3, logd("Wrote   rootPart!"))
					//			return archiver.encodedData
					//		}
					//		catch let error {
					//			fatalError("\n" + "encodeEncodable throws error: '\(error)'")
					//		}
					//	}
					//	override func read(from savedData:Data, ofType typeName: String) throws {
					//		logd("\n" + "read(from:Data, ofType:      ''\(typeName.description)''       )")
					//		guard let unarchiver : NSKeyedUnarchiver = try? NSKeyedUnarchiver(forReadingFrom:savedData) else {
					//				fatalError("NSKeyedUnarchiver cannot read data (its nil or throws)")
					//		}
					//		let inPolyPart			= try? unarchiver.decodeTopLevelDecodable(PolyWrap.self, forKey:NSKeyedArchiveRootObjectKey)
					//								?? {	fatalError("decodeTopLevelDecodable(:forKey:) throws")} ()
					//		unarchiver.finishDecoding()
					//		guard let inPolyPart 	= inPolyPart else {	throw MyError.funcky 	}
					//
					//		  // Groom rootPart and whole tree
					//		 // 1. Unwrap PolyParts
					//		rootPart				= inPolyPart.polyUnwrap() as? RootPart
					//		 // 2. Groom .root and .parent in all parts:
					//		rootPart.groomModel(parent:nil, root:rootPart)
					//		 // 3. Groom .fwDocument in rootPart
					//		rootPart.fwDocument 	= self		// Use my FwDocument
					//		 // 4. Remove symbolic links on Ports
					//		rootPart.realize()
					//
					//		logd("read(from:ofType:)  -- SUCCEEDED")
					//	}
					//
//// START CODABLE ///////////////////////////////////////////////////////////////
////	 // MARK: - 3.5 Codable
////	enum DocumentKeys: String, CodingKey {
////		case controller
////	}
////	public required init(from decoder: Decoder) throws {
////		panic()
////		log /*oops*/			= Log(params4docLog, title:"FwDocument(from:)'s Log(params4docLog)")
////	xxx	DOCLOG?.config4log/*active*/= params4docLog + params4pp //+["cause":"FwDocument(from:)"]
////		let container 			= try decoder.container(keyedBy:DocumentKeys.self)
////
////		controller				= try container.decode(Controller.self, forKey:.controller)
////
////		super.init()//from:container.superDecoder())
////	//	logg("Decoded  FwDocument ")
////	xxx	DOCLOG.log("Decoded  FwDocument ")
////    }
////    func encode(to encoder: Encoder) throws {
////		panic()
////		var container 			= encoder.container(keyedBy:DocumentKeys.self)
////	//	try super.encode(to: container.superEncoder())
////
////		try container.encode(controller, forKey:.controller)
////		Swift.print(fmt("Encoded FwDocument   %x", uid))
////    }
//// END CODABLE /////////////////////////////////////////////////////////////////
//
//	// MARK: - 4 Enablers
//			// The  nib file  name of the document:
//	override var windowNibName:NSNib.Name? {		return "Document"			}
//			// Enable Auto Savea:
//	override class var autosavesInPlace: Bool {		return false				}
//			// Enable Asynchronous Writing:
//	override func canAsynchronouslyWrite(to:URL, ofType:String, for:NSDocument.SaveOperationType) -> Bool {
//		return false															}
//			// Enable Asynchronous Reading:
//	override class func canConcurrentlyReadDocuments(ofType:String) -> Bool {
//		return false // ofType == "public.plain-text"
//	}
////	func setDisplayName(name:String?) {
////		displayName				= name ?? {
////			rootPart.children.count == 0 ? "Empty Root" : "unnamed, suspect"
////		}()
////		window0?.title			= displayName		// window0 may not exist
////	}
//
//	 // MARK: - 5 Groom
//	func registerWithDocController() {
//		if !DOCCTLR.documents.contains(self) {
//			DOCCTLR.addDocument(self)	// we install ourselves!!!				//makeWindowControllers() /// VERY SUSPECT -- 210507PAK:makes 2'nd window
//			showWindows()				// The nib should be loaded by here
//		}
//	}
////	override func makeWindowControllers() {
////		atDoc(3, logg( "== == == == FwDocument.makeWindowControllers()"))
////		super.makeWindowControllers()
////	}
//	override func windowControllerDidLoadNib(_ windowController:NSWindowController) {
//		atDoc(3, logd("==== ==== FwDocument.windowControllerDidLoadNib()"))
//		assert(DOC == self, "sanity check failed")
//		assert(self == windowController.document as? FwDocument, "windowControllerDidLoadNib with wrong DOC")
//		assert(DOCCTLR.documents.contains(self), "self not in DOCCTLR.documents!")
//
//		 		// Create FwGuts programatically:
//		let fwGuts				= FwGuts(fwConfig:params4scene)	// 3D visualization
//		fwGuts.fooDocTry3Doc	= self	// added 20220918
//		 		// Link it in:
//		assert(fwView != nil, "nib loaded, but fwView not set by IB")
//		fwView!.delegate		= fwGuts		//\\ delegate
//		fwView!.fwGuts			= fwGuts		  // same		210712PAK: why so many?
//		fwView!.scene			= fwGuts		 //  same
//		//fwView!.autoenablesDefaultLighting = true
//		//fwView!.allowsCameraControl = true
//		assert(rootPart.dirty.isOn(.vew), "sanity: newly loaded root should have dirty Vew")
//		updateDocConfigs(from:rootPart.ansConfig)	// This time including fwGuts
//
//				// Build Views:
///*x*/	fwGuts.updateVews(fromRootPart:rootPart, reason:"Install RootPart")
//
//		atBld(1, Swift.print("\n" + ppBuildErrorsNWarnings(title:rootPart.title) ))
//
//		displayName				= rootPart.title
//		window0?.title			= displayName									//makeInspectors()
//		makeInspectors()
//
//				// Start Up Simulation:
//		rootPart.simulator.simBuilt = true	// maybe before config4log, so loading simEnable works
//	}
//	   /// Called after a new experiment is loaded.
//	  /// Spreads a new configuration from the selected experiment into various hashes.
//	 /// This is a catch-all and somewhat ad-hoc and HAIRY!!!
//	func updateDocConfigs(from config:FwConfig) {
//		if config.count == 0 				{	return							}
//
//		 // Buckets to sort config into:
//		var toParams4guts : FwConfig = [:]
//		var toParams4sim   : FwConfig = [:]
//		var toParams4docLog: FwConfig = [:]
//		var unused		   : FwConfig = [:]
//
//		 // Sort configuration into buckets:
//		for (name, value) in config {		// Paw through give configuration:
//			var used			= false
//
//			 // --------- To Scene:
//			if params4scene[name] != nil {
//				toParams4guts[name] = value	// 2a: Entry with pre-existing key
//				used			= true 											}
//			 // Dump val:FwConfig of "scene" into fwGuts.config4fwGuts
//			if let scene		= config.fwConfig("scene") {
//				toParams4guts	+= scene 		// 2b. all entries in "scene"
//				used			= true 											}
//			if let ppViewOptions = config.string("ppViewOptions") {
//				toParams4guts["ppViewOptions"] = ppViewOptions
//				used			= true		}	// 2c. Entry ppViewOptions
//
//			 // --------- To Simulator:
//			if params4sim[name] != nil {
//				toParams4sim[name] = value		// 3. Entry with pre-existing key
//				used			= true 											}
//
//			 // --------- To Log:
//			if name.hasPrefix("pp") ||			// 1a:      pp... entry
//			   name.hasPrefix("logPri4") {		// 1b: logPri4... entry
//				toParams4docLog[name] = value		// affect our DOCLOG
//				used			= true											}
//
//			if !used {
//				unused[name]	= value
//			}
//		}
//
//		  // Output buckets to component configurations
//		 // Q: scattering via = or += paradigm?
//		atCon(2, logd( "==== updateDocConfigs. ansConfig\(config.pp(.phrase)) ->"))
//		 // Scene:
//		if toParams4guts.count > 0 {
//			if fwGuts != nil {
//				atCon(2, logd("\t -> config4fwGuts:            \(toParams4guts.pp(.line))"))
//				fwGuts!.config4fwGuts += toParams4guts
//			}else{
//				atCon(2, logd("\t -> IGNORING fwGuts==nil: \(toParams4guts.pp(.line))"))
//			}
//		}
//		 // Simulator
//		if toParams4sim.count > 0 {
//			atCon(2, logd("\t -> doc.simulator.config4sim:\(toParams4sim.pp(.line))"))
//			rootPart.simulator.config4sim += toParams4sim
//		}
//		 // Log:
//		if toParams4docLog.count > 0 {
//			atCon(2, logd("\t -> doc.log.config4log:      \(toParams4docLog.pp(.line).wrap(min: 36, cur: 62, max: 100))"))
//			rootPart.log.config4log	+= toParams4docLog
//		}
//		 // Unaccounted for
//		if unused.count > 0 {
//			atCon(2, logd("\t -> UNACCOUNTED FOR:         \(unused.pp(.line))"))
//		}
//	}
//
//	 // MARK: - 5.1 Make Associated Inspectors:
//	func makeInspectors() {
//return
//		let library				= APPDEL!.library
//		let config2				= params4scene + library.answer.ansConfig
//			// TODO: should move ansConfig stuff into wireAndGroom
//		if let vew2inspec		= config2["inspec"] {
//			if let name			= vew2inspec as? String {	// Single String
//				showInspec(for:name)
//			}
//			else if let names 	= vew2inspec as? [String] {	// Array of Strings
//				for name in names {								// make one for each
//					showInspec(for:name)
//				}
//			}
//			else { panic("Illegal type for inspector:\(vew2inspec.pp(.line))")	}
//		}
//	}
//	func showInspec(for name:String) {
//		if let part	= rootPart.find(name:name),
//		  let vew	= rootVew.find(part:part) {
//			showInspecFor(vew:vew, allowNew:true)
//		}
//		else {
//			warning("Inspector for '\(name)' could not be opened")
//		}
//	}
//		/// Show an Inspec for a vew.
//	   /// - Parameters:
//	  ///   - vew: vew to inspec
//	 ///   - allowNew: window, else use existing
//	func showInspecFor(vew:Vew, allowNew:Bool) { //
//		let inspec				= Inspec(vew:vew)
//		let hc					= NSHostingController(rootView:inspec)
//		 hc.view.frame			= NSRect(x:0, y:0, width:400, height:0)	// questionable use
//
//				// Find window to use
//		var win : NSWindow?		= inspecWin4vew[vew]	// EXISTING window
//		if win == nil && allowNew {	// Not found, and window creation allowed
//			win					= NSWindow(contentViewController:hc)	// new
//		}
//		if win == nil && inspecLastVew != nil {	// Not found, and window creation not allowed
//			win					= inspecWin4vew[inspecLastVew!]
//		}
//		if win == nil {				// Not found, despirately create one
//			win					= NSWindow(contentViewController:hc)	// new
//		}
//		assert(win != nil, "Unable to fine NSWindow")
//		win!.contentViewController = hc		// if successful
//
//				// Title window
//		win!.title				= vew.part.fullName
//
//				// Position on screen: Quite AD HOC!!
//		win!.orderFront(self)				// Doesn't work -- not front when done!
////		win!.makeKeyAndOrderFront(self)
//		win!.setFrameTopLeftPoint(CGPoint(x:300, y:1000))	// AD-HOC solution -- needs improvement
//
//				// Remember window for next creation
//		inspecWin4vew[vew]		= win
//		inspecLastVew			= vew
//	}
//
//	 // MARK: - 13. IBActions
//	 /// Prosses keyboard key
//    /// - Parameter from: -- NSEvent to process
//    /// - Parameter vew: -- The Vew to use
//	/// - Returns: The key was recognized
//	func processKey(from nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
//		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {
//			return false
//		}
//
//		 // First, all registered TimingChains:
//		for timingChain in rootPart.simulator.timingChains {
//			if timingChain.processKey(from:nsEvent, inVew:vew) {
//				return true 						// timingChain handled it
//			}
//		}
//
//		 // Second, check fwGuts:
//		if fwGuts == nil {
//			Swift.print("fwDocument(\(pp(.uid, [:])).fwGuts=nil")
//		}
//		else if fwGuts!.processKey(from:nsEvent, inVew:vew) {
//				return true 					// fwGuts handled
//		}
//
//		 // Simulator:
//		if rootPart.simulator.processKey(from:nsEvent, inVew:vew) {
//			return true 						// simulator handled it
//		}
//
//		 // Controller:
//		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
//			return false						/* FwDocument has no key-ups */
//		}
//		 // Sim EVENTS						// /// Key DOWN ///////
//		let cmd 				= nsEvent.modifierFlags.contains(.command)
//		let alt 				= nsEvent.modifierFlags.contains(.option)
//		var aux : FwConfig		= DOCLOG.params4aux //gets us params4pp
////		var aux : FwConfig		= Log.params4aux 	//gets us params4pp
//		aux["ppParam"]			= alt		// Alternate means print parameters
//
//		switch character {
//		case "u": // + cmd
//			if cmd {
//				panic("Press 'cmd u'   A G A I N    to retest")	// break to debugger
//			}
//		case Character("\u{1b}"):				// Escape
//			Swift.print("\n******************** 'esc':  === EXIT PROGRAM\n")
//			NSSound.beep()
//			exit(0)								// exit program (hack: brute force)
//		case "b":
//			Swift.print("\n******************** 'b': ======== ('?' for debugger hints)")
//			panic("keyboard break to debugger")
//		case "d":
//			Swift.print("\n******************** 'd': ======== ('?' for debugger hints)")
//			let l1v 			= rootvew("_l1")
//			Swift.print(l1v.scn.transform.pp(.tree))
////			l1v.part.rotateLinkSkins(vew:l1v)
//		// //////////////////////////// //
//		// ////// Part / Vew   //////// //
//		// //////////////////////////// //
//		 // print out parts, views
//		 // Command Syntax:
//		 // mM/lL 		normal  /  normal + links	L	 ==> Links
//		 // ml/ML		normal  /  normal + ports	ROOT ==> Ports
//		 //
//		case "m":
//			aux["ppDagOrder"]	= true
//			Swift.print("\n******************** 'm': === Parts:")
//			Swift.print(rootPart.pp(.tree, aux), terminator:"")
//		case "M":
//			aux["ppPorts"]		= true
//			aux["ppDagOrder"]	= true
//			Swift.print("\n******************** 'M': === Parts and Ports:")
//			Swift.print(rootPart.pp(.tree, aux), terminator:"")
//		case "l":
//			aux["ppLinks"]		= true
//			aux["ppDagOrder"]	= true
//			Swift.print("\n******************** 'l': === Parts, Links:")
//			Swift.print(rootPart.pp(.tree, aux), terminator:"")
//		case "L":
//			aux["ppPorts"]		= true
//			aux["ppDagOrder"]	= true
//			aux["ppLinks"]		= true
//			Swift.print("\n******************** 'L': === Parts, Ports, Links:")
//			Swift.print(rootPart.pp(.tree, aux), terminator:"")
//
//		 // N.B: The following are preempted by AppDelegate keyboard shortcuts in Menu.xib
//		case "C":
//			printFwcConfig()			// Controller Configuration
//		case "c":
//			printFwcState()				// Current controller state
//		case "?":
//			printDebuggerHints()
//			return false				// anonymous printout
//
//		default:
//			return false				// nobody decoded
//		}
//		return true						// someone decoded
//	}
//
//	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
//		Swift.print("modelDispatch(fwEvent: to:")
//	}
//	  /// Manage Inspec's:
//	var inspecWin4vew :[Vew : NSWindow] = [:]									//[Vew : [weak NSWindow]]
//	var inspecLastVew : Vew? = nil
//	
//	 // MARK: - 14. Logging
//	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
//		let msg					= String(format:format_, arguments:args)
//		DOCLOG.log(banner:banner, msg, terminator:terminator)
//	}
//
//	 // MARK: - 15. PrettyPrint
//	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
//		switch mode! {
//		case .line:
//			return DOCLOG.indentString() /*?? " "*/ + " " + fwClassName.field(-6, dots:false)	// Can't use fwClassName; FwDocument is not an FwAny
//		case .tree:
//			return DOCLOG.indentString() /*?? " "*/ + " " + fwClassName.field(-6, dots:false) + "\n"
//		default:
//			return ppDefault(self:self as! FwAny, mode:mode, aux:aux)	// NO: return super.pp(mode, aux)
//		}
//	}
//}
