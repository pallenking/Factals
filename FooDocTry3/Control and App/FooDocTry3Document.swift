//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

struct DocState {
	var rootPart: RootPart
	var fwScene	: FwScene
	init(rootPart:RootPart?=nil, fwScene:FwScene?=nil) {
		self.rootPart			= rootPart	?? RootPart([:])
		self.fwScene			= fwScene	?? FwScene(fwConfig:[:])//{ fatalError()}()	//SCNNode(
	}
}
//let docStateNull				= DocState()	//

struct FooDocTry3Document: FileDocument, Uid {
	var uid: UInt16				= randomUid()

//	@IBOutlet weak
//	 var fwView		: FwView?	//SCNView?		// IB sets this
//	 var fwView		: SCNView?		{	NSHostingView(rootView: <#T##_#>)}

	 // Model of a FooDocTry3Document:
	var docState : DocState!

	 // No document supplied
	init() {
		// Generate a new docState		//---FUNCTION-----------+-wantName:---wantNumber:
		//let entry				= nil	//	 Blank scene		|	nil			-1
		//let entry				= 34	//	 entry N			|	nil			N *
		let entry				= "xr()"//	 entry with xr()	|	"xr()"		-1
		//let entry				= "name"//	 entry named scene	|	"name" *	-1

		let rootPart			= RootPart(fromLibrary:entry)
		let fwScene				= FwScene(fwConfig:params4scene + rootPart.ansConfig)
		docState	 			= DocState(rootPart:rootPart, fwScene:fwScene)

		DOC						= self				// INSTALL FooDocTry3

		updateDocConfigs(from:rootPart.ansConfig)
		rootPart.wireAndGroom()
	}
	 // Document supplied
	init(docState docState_:DocState) {
		docState			= docState_			// given
		DOC					= self				// INSTALL FooDocTry3
		return
	}

	/* ============== BEGIN FileDocument protocol: */
	static var readableContentTypes: [UTType] { [.fooDocTry3, .sceneKitScene] }
	static var writableContentTypes: [UTType] { [.fooDocTry3] }
	//private static let onlyScene = true
																				//	static var readableContentTypes: [UTType] { [.exampleText] }
	init(configuration: ReadConfiguration) throws {
			//	struct FileDocumentReadConfiguration (FileDocument: typealias ReadConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the document content.
		guard let data : Data 	= configuration.file.regularFileContents else {
								  throw CocoaError(.fileReadCorruptFile)		}
		switch configuration.contentType {
		case .fooDocTry3:
			let rootPart: RootPart!	= RootPart(data: data, encoding: .utf8)!
			let docState 		= DocState(rootPart:rootPart, fwScene:FwScene(fwConfig:[:]))
			self.init(docState:docState)			// -> FooDocTry3Document
		case .sceneKitScene:
			let scene:FwScene?	= FwScene(data: data, encoding: .utf8)
			let docState 		= DocState(rootPart:RootPart(), fwScene:scene!)
			self.init(docState:docState)				// -> FooDocTry3Document
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
			//	struct FileDocumentWriteConfiguration (FileDocument: typealias WriteConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the current document content. nil if the document is unsaved.
		switch configuration.contentType {
		case .fooDocTry3:
			return .init(regularFileWithContents:docState.rootPart.data!)
		case .sceneKitScene:
			return .init(regularFileWithContents:docState.fwScene.data!)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}

	 // MARK: - 2.2 Sugar
	var windowController0 : NSWindowController? {		// First NSWindowController
bug;	return nil}//windowControllers.count > 0 ? self.windowControllers[0] : nil			}
	var window0 : NSWindow? 	{						// First NSWindow
		return windowController0?.window										}
	// MARK: - 4 Enablers
			// The  nib file  name of the document:
	var windowNibName:NSNib.Name? 	{		return "Document"					}
			// Enable Auto Savea:
	var autosavesInPlace: Bool 		{		return false						}
			// Enable Asynchronous Writing:
	func canAsynchronouslyWrite(to:URL, ofType:String, for:NSDocument.SaveOperationType) -> Bool {
		return false
	}		// Enable Asynchronous Reading:
	func canConcurrentlyReadDocuments(ofType:String) -> Bool {
		return false // ofType == "public.plain-text"
	}

	 // MARK: - 5 Groom
	//https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit
	func registerWithDocController() { bug
//		if !DOCctlr.documents.contains(self) {
//			DOCctlr.addDocument(self)	// we install ourselves!!!				//makeWindowControllers() /// VERY SUSPECT -- 210507PAK:makes 2'nd window
//			showWindows()				// The nib should be loaded by here
//		}
	}
	func makeWindowControllers() { bug
//.		atDoc(3, logg( "== == == == FwDocument.makeWindowControllers()"))
//		super.makeWindowControllers()
	}
																				//	func windowControllerDidLoadNib(_ windowController:NSWindowController) {
																				//bug;	atDoc(3, logd("==== ==== FwDocument.windowControllerDidLoadNib()"))
																				////		assert(DOC! === self, "sanity check failed")
																				////		assert(self == windowController.document as? FwDocument, "windowControllerDidLoadNib with wrong DOC")
																				////		assert(DOCctlr.documents.contains(self), "self not in DOCctlr.documents!")
																				//
																				//		let fwScene				= FwScene(fwConfig:params4scene)	// 3D visualization
																				//		 		// Link it in:
																				//		assert(fwView != nil, "nib loaded, but fwView not set by IB")
																				//		fwView!.delegate		= fwScene		// delegate
																				//		fwView!.fwScene			= fwScene		// delegate		220815PAK: Needed only for rotator
																				//bug;	fwView!.scene			= fwScene		// delegate		// somebody elses responsibility! (but who)
																				//		//fwView!.autoenablesDefaultLighting = true
																				//		//fwView!.allowsCameraControl = true
																				//
																				//		didLoadNib()
																				//	}
	func didLoadNib(to view:Any) {			// after init(state,...)
		// view:Any is bogus													 // Spread configuration information
																				//		updateDocConfigs(from:docState.rootPart.ansConfig)
		 // Generate Vew tree
		let rVew				= Vew(forPart:docState.rootPart, scn:rootScn)//.scene!.rootNode)
		let scene				= docState.fwScene
		scene.rootVew			= rVew				// INSTALL vew
		rVew.updateVewSizePaint()					// rootPart -> rootView, rootScn

//		scene.addLights()														//scene.addLightsAndCamera()

				// Build Vews after nib loading:
/*x*/	docState.fwScene.installRootPart(docState.rootPart, reason:"InstallRootPart")

		atBld(1, Swift.print("\n" + ppBuildErrorsNWarnings(title:docState.rootPart.title) ))
																				// displayName				= state.rootPart.title
		makeInspectors()														// window0?.title			= displayName									//makeInspectors()

				// Start Up Simulation:
		docState.rootPart.simulator.simBuilt = true	// maybe before config4log, so loading simEnable works
	}
	   /// Called after a new experiment is loaded.
	  /// Spreads a new configuration from the selected experiment into various hashes.
	 /// This is a catch-all and somewhat ad-hoc and HAIRY!!!
	func updateDocConfigs(from config:FwConfig) {
		if config.count == 0 				{	return							}

		 // Buckets to sort config into:
		var toParams4scene : FwConfig = [:]
		var toParams4sim   : FwConfig = [:]
		var toParams4docLog: FwConfig = [:]
		var unused		   : FwConfig = [:]

		 // Sort configuration into buckets:
		for (name, value) in config {		// Paw through give configuration:
			var used			= false

			 // --------- To Scene:
			if params4scene[name] != nil {
				toParams4scene[name] = value	// 2a: Entry with pre-existing key
				used			= true
			}
			 // Dump val:FwConfig of "scene" into fwScene.config4scene
			if let scene		= config.fwConfig("scene") {
				toParams4scene	+= scene 		// 2b. all entries in "scene"
				used			= true
			}
			if let ppViewOptions = config.string("ppViewOptions") {
				toParams4scene["ppViewOptions"] = ppViewOptions
				used			= true			// 2c. Entry ppViewOptions
			}

			 // --------- To Simulator:
			if params4sim[name] != nil {
				toParams4sim[name] = value		// 3. Entry with pre-existing key
				used			= true
			}
			 // --------- To Log:
			if name.hasPrefix("pp") ||			// 1a:      pp... entry
			   name.hasPrefix("logPri4") {		// 1b: logPri4... entry
				toParams4docLog[name] = value		// affect our DOClog
				used			= true
			}
			if !used {
				unused[name]	= value
			}
		}

		  // Output buckets to component configurations
		 // Q: scattering via = or += paradigm?
		atCon(2, logd( "==== updateDocConfigs. ansConfig\(config.pp(.phrase)) ->"))
		 // Scene:
		if toParams4scene.count > 0 {
			let scene			= docState.fwScene
			atCon(2, logd("\t -> config4scene:            \(toParams4scene.pp(.line))"))
			scene.config4scene += toParams4scene
			nop
		}
		 // Simulator
		if toParams4sim.count > 0 {
			atCon(2, logd("\t -> doc.simulator.config4sim:\(toParams4sim.pp(.line))"))
			docState.rootPart.simulator.config4sim += toParams4sim
		}
		 // Log:
		if toParams4docLog.count > 0 {
			atCon(2, logd("\t -> doc.log.config4log:      \(toParams4docLog.pp(.line).wrap(min: 36, cur: 62, max: 100))"))
			docState.rootPart.log.config4log += toParams4docLog
		}
		 // Unaccounted for
		if unused.count > 0 {
			atCon(2, logd("\t -> UNACCOUNTED FOR:         \(unused.pp(.line))"))
		}
	}
	func logd(_ x:String) {		print("[[XXXXFooDocTry3DocumentXXXX: \(x)") }

	 // MARK: - 5.1 Make Associated Inspectors:
	func makeInspectors() {
		print("code makeInspectors")
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
//			} else {
//				panic("Illegal type for inspector:\(vew2inspec.pp(.line))")	}
//		}
	}
	func showInspec(for name:String) {
		if let part	= docState.rootPart.find(name:name),
		  let vew	= rootVew.find(part:part) {
			showInspecFor(vew:vew, allowNew:true)
		}
		else {
			warning("Inspector for '\(name)' could not be opened")
		}
	}
		/// Show an Inspec for a vew.
	   /// - Parameters:
	  ///   - vew: vew to inspec
	 ///   - allowNew: window, else use existing
	func showInspecFor(vew:Vew, allowNew:Bool) { //
		let inspec				= Inspec(vew:vew)
		let hc					= NSHostingController(rootView:inspec)
		 hc.view.frame			= NSRect(x:0, y:0, width:400, height:0)	// questionable use

				// Find window to use
		var win : NSWindow?		= inspecWin4vew[vew]	// EXISTING window
		if win == nil && allowNew {	// Not found, and window creation allowed
			win					= NSWindow(contentViewController:hc)	// new
		}
		if win == nil && inspecLastVew != nil {	// Not found, and window creation not allowed
			win					= inspecWin4vew[inspecLastVew!]
		}
		if win == nil {				// Not found, despirately create one
			win					= NSWindow(contentViewController:hc)	// new
		}
		assert(win != nil, "Unable to fine NSWindow")
		win!.contentViewController = hc		// if successful

				// Title window
		win!.title				= vew.part.fullName

				// Position on screen: Quite AD HOC!!
		win!.orderFront(self)				// Doesn't work -- not front when done!
		win!.makeKeyAndOrderFront(self)
		win!.setFrameTopLeftPoint(CGPoint(x:300, y:1000))	// AD-HOC solution -- needs improvement

			// Remember window for next creation
//		inspecWin4vew[vew]		= win
//		inspecLastVew			= vew
	}

	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
		Swift.print("modelDispatch(fwEvent: to:")
	}
	  /// Manage Inspec's:
	var inspecWin4vew :[Vew : NSWindow] = [:]									//[Vew : [weak NSWindow]]
	var inspecLastVew : Vew? = nil

	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: The key was recognized
	func processKey(from nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {
			return false
		}

		 // First, all registered TimingChains:
		for timingChain in rootPart.simulator.timingChains {
			if timingChain.processKey(from:nsEvent, inVew:vew) {
				return true 				// handled by timingChain
			}
		}

		 // Second, check fwScene:												// assert(docState.fwScene != nil, "fwDocument(\(pp(.uid, [:])).fwScene=nil")
		if docState.fwScene.processKey(from:nsEvent, inVew:vew) {
			return true 					// handled by fwScene
		}

		 // Simulator:
		if rootPart.simulator.processKey(from:nsEvent, inVew:vew) {
			return true 					// handled by simulator
		}

		 // Controller:
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						/* FwDocument has no key-ups */
		}
		 // Sim EVENTS						// /// Key DOWN ///////
		let cmd 				= nsEvent.modifierFlags.contains(.command)
		let alt 				= nsEvent.modifierFlags.contains(.option)
		var aux : FwConfig		= DOClog.params4aux //gets us params4pp
//		var aux : FwConfig		= Log.params4aux 	//gets us params4pp
		aux["ppParam"]			= alt		// Alternate means print parameters

		switch character {
		case "u": // + cmd
			if cmd {
				panic("Press 'cmd u'   A G A I N    to retest")	// break to debugger
			}
		case Character("\u{1b}"):				// Escape
			Swift.print("\n******************** 'esc':  === EXIT PROGRAM\n")
			NSSound.beep()
			exit(0)								// exit program (hack: brute force)
		case "b":
			Swift.print("\n******************** 'b': ======== ('?' for debugger hints)")
			panic("keyboard break to debugger")
		case "d":
			Swift.print("\n******************** 'd': ======== ('?' for debugger hints)")
			let l1v 			= rootvew("_l1")
			Swift.print(l1v.scn.transform.pp(.tree))
//			l1v.part.rotateLinkSkins(vew:l1v)
		// //////////////////////////// //
		// ////// Part / Vew   //////// //
		// //////////////////////////// //
		 // print out parts, views
		 // Command Syntax:
		 // mM/lL 		normal  /  normal + links	L	 ==> Links
		 // ml/ML		normal  /  normal + ports	ROOT ==> Ports
		 //
		case "m":
			aux["ppDagOrder"]	= true
			Swift.print("\n******************** 'm': === Parts:")
			Swift.print(rootPart.pp(.tree, aux), terminator:"")
		case "M":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			Swift.print("\n******************** 'M': === Parts and Ports:")
			Swift.print(rootPart.pp(.tree, aux), terminator:"")
		case "l":
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			Swift.print("\n******************** 'l': === Parts, Links:")
			Swift.print(rootPart.pp(.tree, aux), terminator:"")
		case "L":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			Swift.print("\n******************** 'L': === Parts, Ports, Links:")
			Swift.print(rootPart.pp(.tree, aux), terminator:"")

		 // N.B: The following are preempted by AppDelegate keyboard shortcuts in Menu.xib
		case "C":
			printFwcConfig()			// Controller Configuration
		case "c":
			printFwcState()				// Current controller state
		case "?":
			printDebuggerHints()
			return false				// anonymous printout

		default:
			return false				// nobody decoded
		}
		return true						// someone decoded
	}

	 // MARK: - 14. Logging
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		let msg					= String(format:format_, arguments:args)
		DOClog.log(banner:banner, msg, terminator:terminator)
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
bug;	return "fixMe"
//		switch mode! {
//		case .line:
//			return DOClog.indentString() /*?? " "*/ + " " + fwClassName.field(-6, dots:false)	// Can't use fwClassName; FwDocument is not an FwAny
//		case .tree:
//			return DOClog.indentString() /*?? " "*/ + " " + fwClassName.field(-6, dots:false) + "\n"
//		default:
//			return ppDefault(self:self as! FwAny, mode:mode, aux:aux)	// NO: return super.pp(mode, aux)
//		}
	}



}

//https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
//https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
//https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html

 // Define new UTType
extension UTType {
	static var fooDocTry3: UTType 	{ UTType(exportedAs: "com.example.footry3") 	}
}

/* ============== END FileDocument protocol: */
