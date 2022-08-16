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
	init(rootPart:RootPart?, fwScene:FwScene?=nil) {
		self.rootPart				= rootPart	?? RootPart([:])
		self.fwScene				= fwScene	?? { fatalError()}()	//SCNNode(
	}
}

struct FooDocTry3Document: FileDocument {			// not NSDocument!!

//	@IBOutlet weak
	 var fwView		: FwView?	//SCNView?		// IB sets this

	 // Model of a FooDocTry3Document:
	var state : DocState

	init(state state_:DocState?=nil) {
		state	 				= state_ ?? { 		// state given
			let fwScene			= FwScene(fwConfig:params4scene)				// A Part Tree

			// Generate a new document.
			
			// Several Ways: selectionString+---FUNCTION--------+-wantName:---wantNumber:
		//	let entry			= nil	//	 Blank scene		|	nil			-1
		//	let entry			= 34	//	 entry N			|	nil			N *
			let entry			= "xr()"//	 entry with xr()	|	"xr()"		-1
		//	let entry			= "name"//	 entry named scene	|	"name" *	-1
			let rootPart_		= RootPart(fromLibrary:entry)

			rootPart_.wireAndGroom()
			return DocState(rootPart:rootPart_, fwScene:fwScene)
		} ()

		 // KNOWN EARLY
		DOC						= self				// INSTALL FooDocTry3
	}	// --> SceneView --> didLoadNib()

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
			self.init(state:docState)			// -> FooDocTry3Document
		case .sceneKitScene:
			let scene:FwScene?	= FwScene(data: data, encoding: .utf8)
			let state0 			= DocState(rootPart:RootPart(), fwScene:scene!)
			self.init(state:state0)				// -> FooDocTry3Document
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
			return .init(regularFileWithContents:state.rootPart.data!)
		case .sceneKitScene:
			return .init(regularFileWithContents:state.fwScene.data!)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}





	 // MARK: - 5 Groom
	func registerWithDocController() {
bug//	if !DOCCTLR.documents.contains(self) {
//			DOCCTLR.addDocument(self)	// we install ourselves!!!				//makeWindowControllers() /// VERY SUSPECT -- 210507PAK:makes 2'nd window
//			showWindows()				// The nib should be loaded by here
//		}
	}																			//	override func makeWindowControllers() {
																				//		atDoc(3, logg( "== == == == FwDocument.makeWindowControllers()"))
																				//		super.makeWindowControllers()
																				//	}
																				//	func windowControllerDidLoadNib(_ windowController:NSWindowController) {
																				//bug;	atDoc(3, logd("==== ==== FwDocument.windowControllerDidLoadNib()"))
																				////		assert(DOC! === self, "sanity check failed")
																				////		assert(self == windowController.document as? FwDocument, "windowControllerDidLoadNib with wrong DOC")
																				////		assert(DOCCTLR.documents.contains(self), "self not in DOCCTLR.documents!")
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
	func didLoadNib() {			// after init(state,...)

		 // Spread configuration information
		updateDocConfigs(from:state.rootPart.ansConfig)

		 // Generate Vew tree
		let rVew				= Vew(forPart:state.rootPart, scn:rootScn)//.scene!.rootNode)
		let scene				= state.fwScene
		scene.rootVew			= rVew				// INSTALL vew
		rVew.updateVewSizePaint()					// rootPart -> rootView, rootScn

		scene.addLights()														//scene.addLightsAndCamera()

				// Build Vews after nib loading:
/*x*/	state.fwScene.installRootPart(state.rootPart, reason:"InstallRootPart")

		atBld(1, Swift.print("\n" + ppBuildErrorsNWarnings(title:state.rootPart.title) ))

//		displayName				= state.rootPart.title
//		window0?.title			= displayName									//makeInspectors()
		makeInspectors()

				// Start Up Simulation:
		state.rootPart.simulator.simBuilt = true	// maybe before config4log, so loading simEnable works
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
				toParams4docLog[name] = value		// affect our DOCLOG
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
			let scene			= state.fwScene
			atCon(2, logd("\t -> config4scene:            \(toParams4scene.pp(.line))"))
			scene.config4scene += toParams4scene
		}
		 // Simulator
		if toParams4sim.count > 0 {
			atCon(2, logd("\t -> doc.simulator.config4sim:\(toParams4sim.pp(.line))"))
			DOC?.state.rootPart.simulator.config4sim += toParams4sim
		}
		 // Log:
		if toParams4docLog.count > 0 {
			atCon(2, logd("\t -> doc.log.config4log:      \(toParams4docLog.pp(.line).wrap(min: 36, cur: 62, max: 100))"))
			DOC?.state.rootPart.log.config4log	+= toParams4docLog
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
		if let part	= state.rootPart.find(name:name),
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
//		win!.makeKeyAndOrderFront(self)
		win!.setFrameTopLeftPoint(CGPoint(x:300, y:1000))	// AD-HOC solution -- needs improvement

bug//			// Remember window for next creation
//		inspecWin4vew[vew]		= win
//		inspecLastVew			= vew
	}

	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
		Swift.print("modelDispatch(fwEvent: to:")
	}
	  /// Manage Inspec's:
	var inspecWin4vew :[Vew : NSWindow] = [:]									//[Vew : [weak NSWindow]]
	var inspecLastVew : Vew? = nil
	
	 // MARK: - 14. Logging
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		let msg					= String(format:format_, arguments:args)
		DOCLOG.log(banner:banner, msg, terminator:terminator)
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
bug;	return "fixMe"
//		switch mode! {
//		case .line:
//			return DOCLOG.indentString() /*?? " "*/ + " " + fwClassName.field(-6, dots:false)	// Can't use fwClassName; FwDocument is not an FwAny
//		case .tree:
//			return DOCLOG.indentString() /*?? " "*/ + " " + fwClassName.field(-6, dots:false) + "\n"
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
