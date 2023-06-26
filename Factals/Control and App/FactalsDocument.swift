//
//  FactalsDocument.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

//	Uniform Type Identifiers Overview:
//		https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html
//	Defining file and data types for your app:
//		https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
//	System-declared uniform type identifiers:
//		https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers

 // Define new UTType
extension UTType {
	static var factals: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  	}	// com.example.fooTry3
}
extension FactalsDocument : Uid {
//	let uid:UInt16				= randomUid()			// defined in struct FactalsDocument
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
		print("[[XXXXFactalsDocumentXXXX\(ppUid(self)): \(format)")
	}
}

struct FactalsDocument: FileDocument {
	let uid:UInt16				= randomUid()

	var fwGuts : FwGuts!				// content

	var config : FwConfig		= [:]

	// MARK: - 2.4.4 Building
	 // index of named items (<Class>, "wire", "WBox", "origin", "breakAtWire", etc
	var indexFor				= Dictionary<String,Int>()

	func configure(from config:FwConfig) {
		fwGuts?.configure(from:config)
	}

	 // @main uses this to generate a blank document
	init() {	// Build a blank document, so there is a document of record with a Log
		fwGuts					= FwGuts()	// MAKE first, so leaners can function //po type(of: fwGuts)
		DOC						= self		// INSTALL as current DOC, quick!
		fwGuts.document 		= self		// DELEGATE

		 // 	1. Make RootPart:			//--FUNCTION--------wantName:--wantNumber:
		//**/	let select		= nil		//	Blank scene		 |	nil		  -1
		//**/	let select		= "entry120"//	entry 120		 |	nil		  N *
		/**/	let select		= "xr()"	//	entry with xr()	 |	"xr()"	  -1
		//**/	let select		= "name"	//	entry named name |	"name" *  -1
		//**/	let select		= "- Port Missing"
		let rootPart			= RootPart(fromLibrary:select)

		 // 	2. Install
		assert(fwGuts.rootPart == nil, "paranoia: Should be empty, just made it")
		fwGuts.rootPart			= rootPart
		rootPart.fwGuts			= fwGuts	// set delegate

		 //		3. Update document configuration from Library entry
		let c					= params4all + rootPart.ansConfig
		configure(from:c)

		 //		4. Wire and Groom Part
		rootPart.wireAndGroom(c)
		configure(from:c)

		 //		5. Build Vews per Configuration
		for (key, value) in c {
			if key == "Vews",				// "Vews":[VewConfig]
			  let values 		= value as? [VewConfig] {
				for value in values	{		// Open one for each elt
					fwGuts.addRootVew(vewConfig:value, fwConfig:c)
				}
			}
			else if key.hasPrefix("Vew") {	// "Vew":VewConfig
				guard let value = value as? VewConfig else { fatalError("Confused wo38r") }
				fwGuts.addRootVew(vewConfig:value, fwConfig:c)
			}
		}
		if fwGuts.rootVews.isEmpty {		// Must have a Vew
			warning("no Vew... key")
			fwGuts.addRootVew(vewConfig:.openAllChildren(toDeapth:5), fwConfig:c)
		}
		configure(from:c)
	}										// next comes viewAppearedFor (was didLoadNib(to)
	 // Document supplied
	init(fwGuts f:FwGuts) {
		fwGuts					= f			// given
		fwGuts.document			= self		// owner back-link
		DOC						= self		// INSTALL Factals
		return
	}

	init(fromLibrary:String?) {													//	func xxx(_ selectit:String) -> FactalsDocument {
		 // Make new Document
		let rootPart			= RootPart(fromLibrary:fromLibrary)
		let fwGuts				= FwGuts(rootPart:rootPart)
		rootPart.fwGuts			= fwGuts

		 // --------------- A: Get BASIC Component Part (owned and used here)
		let rootScn				= RootScn()
		rootScn.scnScene.isPaused = true			// Pause animations while bulding

		 // --------------- B: RootVew ((rootPart, A))
		let newRootVew			= RootVew(forPart:fwGuts.rootPart!, rootScn:rootScn)
		newRootVew.fwGuts		= fwGuts			// Set Owner
		fwGuts.rootVews.append(newRootVew)

		 // --------------- C: FactalsDocument
		var doc					= FactalsDocument(fwGuts:fwGuts)
		fwGuts.document 		= doc
		DOC						= doc				// register (UGLY!!!)
		let c					= doc.config + rootPart.ansConfig
		doc.configure(from:c)
	}

	 /// Requirement of <<FileDocument>> protocol
	static var readableContentTypes: [UTType] { [.factals] }//{ [.exampleText, .sceneKitScene, .text] }
	static var writableContentTypes: [UTType] { [.factals] }
			//	struct FileDocumentWriteConfiguration (FileDocument: typealias WriteConfiguration = ~)
			//		let contentType : UTType		// The expected uniform type of the file contents.
			//		let existingFile: FileWrapper?	// The file wrapper containing the current document content. nil if the document is unsaved.

	init(configuration: ReadConfiguration) throws {
		guard let data : Data 	= configuration.file.regularFileContents else {
			print("\n\n######################\nCORRUPT configuration.file.regularFileContents\n######################\n\n\n")
			throw CocoaError(.fileReadCorruptFile)								}
		switch configuration.contentType {	// :UTType: The expected uniform type of the file contents.
		case .factals:
			throw CocoaError(.fileWriteUnknown)
			 // Decode data as a Root Part
bug;		let rootPart		= RootPart.from(data: data, encoding: .utf8)	//RootPart(fromLibrary:"xr()")		// DEBUG 20221011

			 // Make the FileDocument
			let fwGuts			= FwGuts(rootPart:rootPart)
			self.init(fwGuts:fwGuts)

			config				+= rootPart.ansConfig	// from library
		case .sceneKitScene:
			guard let fwGuts	= FwGuts(data: data, encoding: .utf8) else {
				fatalError("FwGuts(data:) failed")								}
			self.init(fwGuts:fwGuts)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	enum DocError : Error {
		case text(String)
	}

	 /// Requirement of <<FileDocument>> protocol
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		switch configuration.contentType {
		case .factals:
bug;		guard let dat		= fwGuts.rootPart?.data else {				// PW+: ???
				panic("FactalsDocument.fwGuts.rootPart.data is nil")
				let d			= fwGuts.rootPart?.data		// debug
				throw DocError.text("FactalsDocument.fwGuts.rootPart.data is nil")
			}
			return .init(regularFileWithContents:dat)
		default:
			throw CocoaError(.fileWriteUnknown)
		}
	}
	 // MARK: - 2.2 Sugar
	var windowController0 : NSWindowController? {		// First NSWindowController
bug;	return nil}//windowControllers.count > 0 ? self.windowControllers[0] : nil			}
	var window0 : NSWindow? 	{						// First NSWindow
		return windowController0?.window										}




 //// -- WORTHY GEMS: -- ///// //

	typealias PolyWrap = Part
	class Part : Codable /* PartProtocol*/ {
		func polyWrap() -> PolyWrap {	polyWrap() }
		func polyUnwrap() -> Part 	{	Part()		}
	}
	//protocol PartProtocol {
	//	func polyWrap() -> PolyWrap
	//}

func serializeDeserialize(_ inPart:Part) throws -> Part? {

	 //  - INSERT -  PolyWrap's
	let inPolyPart:PolyWrap	= inPart.polyWrap()	// modifies inPart

		 //  - ENCODE -  PolyWrap as JSON
		let jsonData 			= try JSONEncoder().encode(inPolyPart)

			print(String(data:jsonData, encoding:.utf8) ?? "")

		 //  - DECODE -  PolyWrap from JSON
		let outPoly:PolyWrap	= try JSONDecoder().decode(PolyWrap.self, from:jsonData)

	 //  - REMOVE -  PolyWrap's
	let outPart				= outPoly.polyUnwrap()
	 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
	let _					= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()

	return outPart
}



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
	func makeWindowControllers() 		{	 bug								}
	 // MARK: - 5.1 Make Associated Inspectors:
	  /// Manage Inspec's:
	var inspecWin4vew:[Vew:NSWindow] = [:]									//[Vew : [weak NSWindow]]
	var inspecLastVew:Vew?		= nil
	var inspecWindow :NSWindow? = nil

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
		if let part	= fwGuts.rootPart?.find(name:name) {

			 // Open inspectors for all RootVews:
			for rootVew in fwGuts.rootVews {
		 		if let vew = rootVew.find(part:part) {
					showInspecFor(vew:vew, allowNew:true)
				}
			}
		}
		else {
			warning("Inspector for '\(name)' could not be opened")
		}
	}
		 /// Show an Inspec for a vew.
		/// - Parameters:
	   ///  - vew: vew to inspec
	  ///   - allowNew: window, else use existing
	 mutating func showInspecFor(vew:Vew, allowNew:Bool) {
		let vewsInspec			= Inspec(vew:vew)
		var window : NSWindow?	= nil

		if let iw				= inspecWindow {		// New, less functional manner
			iw.close()
			self.inspecWindow	= nil
		} else {										// Old broken way
			 // Find an existing NSWindow for the inspec
			window 				= inspecWin4vew[vew]	// Does one Exist?
			if window == nil,								// no,
			  !allowNew,									// Shouldn't create
			  let lv			= inspecLastVew {
				window			= inspecWin4vew[lv]				// try LAST
			}
		}

		// PW+4: How do I access MainMenu from inside SwiftUI
		// PW3: What is the right way to display vewsInspec? as popup?, window?, WindowGroup?...
		// restructure with
		if window == nil {								// must make NEW
			let hostCtlr		= NSHostingController(rootView:vewsInspec)		// hostCtlr.view.frame	= NSRect()
			 // Create Inspector Window (Note: NOT SwiftUI !!)
			window				= NSWindow(contentViewController:hostCtlr)	// create window
			// Picker: the selection "-1" is invalid and does not have an associated tag, this will give undefined results.
			window!.contentViewController = hostCtlr		// if successful
		}
		guard let window = window else { fatalError("Unable to fine NSWindow")	}

				// Title window
		window.title			= vew.part.fullName
		window.subtitle			= "Slot\(vew.rootVew?.slot ?? -1)"

				// Position on screen: Quite AD HOC!!
		window.orderFront(self)				// Doesn't work -- not front when done!
		window.makeKeyAndOrderFront(self)
		window.setFrameTopLeftPoint(CGPoint(x:300, y:1000))	// AD-HOC solution -- needs improvement

			// Remember window for next creation
		inspecWindow			= window		// activate New way
		inspecWin4vew[vew]		= window		// activate Old way
		inspecLastVew			= vew			// activate Old way
	}

	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
		print("modelDispatch(fwEvent: to:")
	}

	func windowControllerDidLoadNib(_ windowController:NSWindowController) {
bug
	//	updateDocConfigs(from:rootPart.ansConfig)	// This time including rootScn

//	//			// Build Views:
///*x*/	rootScn.updateVews(fromRootPart:rootPart, reason:"InstallRootPart")
	
//		displayName				= rootPart.title
//		window0?.title			= displayName									//makeInspectors()
//		makeInspectors()
//
//		//			// Start Up Simulation:
//		rootPart.simulator.simBuilt = true	// maybe before config4log, so loading simEnable works
	}


	 // MARK: - 13. IBActions
	 /// Prosses keyboard key
    /// - Parameter from: -- NSEvent to process
    /// - Parameter vew: -- The Vew to use
	/// - Returns: The key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {
			return false
		}
		let rootPart2 : RootPart! = vew.part.root// ?? .null
		 // Check registered TimingChains
		for timingChain in rootPart2.simulator.timingChains {
			guard timingChain.processEvent(nsEvent:nsEvent, inVew:vew) == false else {
				return true 				/* handled by timingChain */		}
		}
		 // Check fwGuts:
		guard fwGuts.processEvent(nsEvent:nsEvent, inVew:vew) == false else {
			return true 					/* handled by fwGuts */
		}
		 // Check Simulator:
		guard rootPart2?.simulator.processEvent(nsEvent:nsEvent, inVew:vew) == false else  {
			return true 					// handled by simulator
		}

		 // Check Controller:
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						/* FwDocument has no key-ups */
		}
		 // Sim EVENTS						// /// Key DOWN ///////
		let cmd 				= nsEvent.modifierFlags.contains(.command)
		let alt 				= nsEvent.modifierFlags.contains(.option)
		var aux : FwConfig		= config	// gets us params4pp
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
			print(rootPart2.pp(.tree, aux), terminator:"")
		case "M":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'M': === Parts and Ports:")
			print(rootPart2.pp(.tree, aux), terminator:"")
		case "l":
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'l': === Parts, Links:")
			print(rootPart2.pp(.tree, aux), terminator:"")
		case "L":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			print("\n******************** 'L': === Parts, Ports, Links:")
			print(rootPart2.pp(.tree, aux), terminator:"")

		 // N.B: The following are preempted by AppDelegate keyboard shortcuts in Menu.xib
		case "C":
			printFwConfig()				// Controller Configuration
		case "c":
			printFwState()				// Current controller state
		case "?":
			printDebuggerHints()
			return false				// anonymous printout

		default:
			return false				// nobody decoded
		}
		return true						// someone decoded
	}

	// MARK: - 14. Building
	var log : Log { fwGuts.log											}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}
	
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .line:
			return log.indentString() + " FactalsDocument"				// Can't use fwClassName; FwDocument is not an FwAny
		case .tree:
			return log.indentString() + " FactalsDocument" + "\n"
		default:
			return ppDefault(mode:mode, aux:aux)						// NO: return super.pp(mode, aux)
		}
	}
}
