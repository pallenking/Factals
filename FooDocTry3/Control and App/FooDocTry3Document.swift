//
//  FooDocTry3Document.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

struct FooDocTry3Document: FileDocument, Equatable, Uid {
	
	let uid:UInt16				= randomUid()
	var redo:UInt8				= 0

	var fwGuts : FwGuts!				// content

	var config : FwConfig		= [:]
	mutating func pushToCtlrs(config c:FwConfig) {
		config					= c
		fwGuts?.pushToCtlrs(config:c)	// COMPONENT 1
		assert(fwGuts.document == self, "FooDocTry3.reconfigureWith ERROR with log (or func == ERROR")
	}
	static func == (lhs: FooDocTry3Document, rhs: FooDocTry3Document) -> Bool {
		lhs.uid == rhs.uid				// almost good enough 2^-16			//&& lhs.config == rhs.config	// slow? broken
	}

	init() {	// Build an EMPTY document						 //    INTERNAL:
		//			Make RootPart:		//---FUNCTION-----------+-wantName:---wantNumber:
		//**/	let select		= nil	//	 Blank scene		|	nil			-1
		//**/	let select		= 34	//	 entry N			|	nil			N *
		/**/	let select		= "xr()"//	 entry with xr()	|	"xr()"		-1
		//**/	let select		= "name"//	 entry named scene	|	"name" *	-1
		let rootPart			= RootPart(fromLibrary:select)

		 //		Makes new FGuts
		fwGuts					= FwGuts(rootPart:rootPart)	// and RootPart and EventCentral
		let i 					= fwGuts.newViewIndex()		// add RootVew  and FwScn

		fwGuts.document 		= self			// delegate
		rootPart.fwGuts			= fwGuts		// delegate

		config					+= rootPart.ansConfig
		pushToCtlrs(config:config)

		DOC						= self	// INSTALL self:FooDocTry3 as current DOC

		rootPart.wireAndGroom()
	}											// next comes  didLoadNib(to
	 // Document supplied
	init(fwGuts fwGuts_:FwGuts) {
		fwGuts				= fwGuts_			// given
		DOC					= self				// INSTALL FooDocTry3
		return
	}

	static var readableContentTypes: [UTType] { [.fooDocTry3, .sceneKitScene] }
	static var writableContentTypes: [UTType] { [.fooDocTry3] }
	//private static let onlyScene = true
																				//	static var readableContentTypes: [UTType] { [.exampleText] }
	init(configuration: ReadConfiguration) throws {
			//	struct FileDocumentReadConfiguration (FileDocument: typealias ReadConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the document content.
		guard let data : Data 	= configuration.file.regularFileContents else {
			print("\n\n######################\nCORRUPT configuration.file.regularFileContents\n######################\n\n\n")
			throw CocoaError(.fileReadCorruptFile)								}
		switch configuration.contentType {
		case .fooDocTry3:
			let rootPart		= RootPart.from(data: data, encoding: .utf8)
			let fwGuts			= FwGuts(rootPart:rootPart)

			self.init(fwGuts:fwGuts)			// -> FooDocTry3Document

			config				+= rootPart.ansConfig	// from library
			fwGuts.document 	= self
		case .sceneKitScene:
			guard let fwGuts	= FwGuts(data: data, encoding: .utf8) else {
				fatalError("FwGuts(data:) failed")								}
			self.init(fwGuts:fwGuts)				// -> FooDocTry3Document
			fwGuts.document = self
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	enum DocError : Error {
		case text(String)
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
			//	struct FileDocumentWriteConfiguration (FileDocument: typealias WriteConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the current document content. nil if the document is unsaved.
		switch configuration.contentType {
		case .fooDocTry3:
			guard let dat		= fwGuts.rootPart.data else {
				panic("FooDocTry3Document.fwGuts.rootPart.data is nil")
				let d			= fwGuts.rootPart.data						// for debugger ss 
				panic("FooDocTry3Document.fwGuts.rootPart.data is nil")
				throw DocError.text("FooDocTry3Document.fwGuts.rootPart.data is nil")
			}
			return .init(regularFileWithContents:dat)
		case .sceneKitScene:
			return .init(regularFileWithContents:fwGuts.data!)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	 // MARK: - 2.2 Sugar
	var windowController0 : NSWindowController? {		// First NSWindowController
bug;	return nil}//windowControllers.count > 0 ? self.windowControllers[0] : nil			}
	var window0 : NSWindow? 	{						// First NSWindow
		return windowController0?.window										}




// //// -- WORTHY GEMS: -- ///// //
//
//	typealias PolyWrap = Part
//	class Part : Codable /* PartProtocol*/ {
//		func polyWrap() -> PolyWrap {	polyWrap() }
//		func polyUnwrap() -> Part 	{	Part()		}
//	}
//	//protocol PartProtocol {
//	//	func polyWrap() -> PolyWrap
//	//}
//
//func serializeDeserialize(_ inPart:Part) throws -> Part? {
//
//	 //  - INSERT -  PolyWrap's
//	let inPolyPart:PolyWrap	= inPart.polyWrap()	// modifies inPart
//
//		 //  - ENCODE -  PolyWrap as JSON
//		let jsonData 			= try JSONEncoder().encode(inPolyPart)
//
//			print(String(data:jsonData, encoding:.utf8) ?? "")
//
//		 //  - DECODE -  PolyWrap from JSON
//		let outPoly:PolyWrap	= try JSONDecoder().decode(PolyWrap.self, from:jsonData)
//
//	 //  - REMOVE -  PolyWrap's
//	let outPart				= outPoly.polyUnwrap()
//	 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
//	let _					= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()
//
//	return outPart
//}



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
																//		fwView!.delegate		= fwGuts		// delegate
																//		fwView!.fwGuts			= fwGuts		// delegate		220815PAK: Needed only for rotator
																//bug;	fwView!.scene			= fwGuts		// delegate		// somebody elses responsibility! (but who)
	mutating func didLoadNib(to view:Any) {
	  for i in 0...fwGuts.fwScn.count {
				// Build Vews after View is loaded:
/**/	fwGuts.fwScn[i]!.createVewNScn()

		guard let view			= fwGuts.fwScn[i]!.scnView else {fatalError("fwGuts.scnView == nil")}
		view.isPlaying			= true			// does nothing
		view.showsStatistics 	= true			// works fine
		view.debugOptions 		= [			// enable display of:
//	//		SCNDebugOptions.showBoundingBoxes,	// bounding boxes for nodes with content.
		//	SCNDebugOptions.showWireframe,		// geometries as wireframe.
	 	//	SCNDebugOptions.renderAsWireframe,	// only wireframe of geometry
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
//	 //	view.allowsCameraControl = false			// dare to turn it on?
//	 //	view.autoenablesDefaultLighting = false		// dare to turn it on?

	  }
	  atBld(1, Swift.print("\n" + ppBuildErrorsNWarnings(title:fwGuts.rootPart.title) ))

	  makeInspectors()
				// Start Up Simulation:
	  fwGuts.rootPart.simulator.simBuilt = true		// maybe before config4log, so loading simEnable works
	}
	func logd(_ x:String) {		print("[[XXXXFooDocTry3DocumentXXXX: \(x)") }

	 // MARK: - 5.1 Make Associated Inspectors:
	  /// Manage Inspec's:
	var inspecWin4vew :[Vew : NSWindow] = [:]									//[Vew : [weak NSWindow]]
	var inspecLastVew : Vew? 	= nil
	var inspecWindow  : NSWindow? = nil
	mutating func makeInspectors() {
		atIns(7, print("code makeInspectors"))
			// TODO: should move ansConfig stuff into wireAndGroom
		if let vew2inspec		= config["inspec"] {
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
	mutating func showInspec(for name:String) {
		if let part	= fwGuts.rootPart.find(name:name),
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
	mutating func showInspecFor(vew:Vew, allowNew:Bool) { // PW what is going on here?
		let inspec				= Inspec(vew:vew)
		var window : NSWindow?	= nil

		if let iw				= inspecWindow {		// New, less functional manner
			iw.close()
			inspecWindow		= nil
		} else {										// Old broken way
			 // Find an existing NSWindow for the inspec
			window 					= inspecWin4vew[vew]	// EXISTING?
			if window == nil, !allowNew,
			  let lv				= inspecLastVew {
				window				= inspecWin4vew[lv]		// try LAST
			}
		}
		if window == nil {								// make NEW
			let hostCtlr		= NSHostingController(rootView:inspec)
			hostCtlr.view.frame	= NSRect(x:0, y:0, width:400, height:0)	// questionable use
			 // Create Inspector Window (Note: NOT SwiftUI !!)
			window				= NSWindow(contentViewController:hostCtlr)	// create
			// Picker: the selection "-1" is invalid and does not have an associated tag, this will give undefined results.
			window!.contentViewController = hostCtlr		// if successful
		}
		guard let window = window else { fatalError("Unable to fine NSWindow")	}

				// Title window
		window.title			= vew.part.fullName
		window.subtitle			= "subtitle for Inspec"

				// Position on screen: Quite AD HOC!!
		window.orderFront(self)				// Doesn't work -- not front when done!
		window.makeKeyAndOrderFront(self)
		window.setFrameTopLeftPoint(CGPoint(x:300, y:1000))	// AD-HOC solution -- needs improvement

			// Remember window for next creation
		inspecWindow			= window		// activate New way
//		inspecWin4vew[vew]		= window		// activate Old way
//		inspecLastVew			= vew			// activate Old way
	}

	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
		Swift.print("modelDispatch(fwEvent: to:")
	}

	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: The key was recognized
	func processKey(from nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {
			return false
		}
		let rootPart2 : RootPart! = vew?.part.root// ?? .null
		 // Check registered TimingChains
		for timingChain in rootPart2.simulator.timingChains {
			guard timingChain.processKey(from:nsEvent, inVew:vew) == false else {
				return true 				/* handled by timingChain */		}
		}
		 // Check fwGuts:
		guard fwGuts.processKey(from:nsEvent, inVew:vew) == false else {
			return true 					/* handled by fwGuts */
		}
		 // Check Simulator:
		guard rootPart2?.simulator.processKey(from:nsEvent, inVew:vew) == false else  {
			return true 					// handled by simulator
		}

		 // Check Controller:
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						/* FwDocument has no key-ups */
		}
		 // Sim EVENTS						// /// Key DOWN ///////
		let cmd 				= nsEvent.modifierFlags.contains(.command)
		let alt 				= nsEvent.modifierFlags.contains(.option)
		var aux : FwConfig		= config //gets us params4pp					// DOClog.params4aux Logger.params4aux
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
			Swift.print(rootPart2?.pp(.tree, aux), terminator:"")
		case "M":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			Swift.print("\n******************** 'M': === Parts and Ports:")
			Swift.print(rootPart2?.pp(.tree, aux), terminator:"")
		case "l":
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			Swift.print("\n******************** 'l': === Parts, Links:")
			Swift.print(rootPart2?.pp(.tree, aux), terminator:"")
		case "L":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			Swift.print("\n******************** 'L': === Parts, Ports, Links:")
			Swift.print(rootPart2?.pp(.tree, aux), terminator:"")

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

	// MARK: - 14. Building
	var logger : Logger { fwGuts.logger											}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		logger.log(banner:banner, format_, args, terminator:terminator)
	}
	
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig=DOClog.params4aux) -> String	{
//		var log : Logger			= fwGuts.rootPart.log
		switch mode! {
		case .line:
			return logger.indentString() + " FooDocTry3Document"				// Can't use fwClassName; FwDocument is not an FwAny
		case .tree:
			return logger.indentString() + " FooDocTry3Document" + "\n"
		default:
			return ppDefault(self:self, mode:mode, aux:aux)						// NO: return super.pp(mode, aux)
		}
	}
}

//https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
//https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
//https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html

 // Define new UTType
extension UTType {
	static var fooDocTry3: UTType 	{ UTType(exportedAs: "com.example.footry3") 	}
}
