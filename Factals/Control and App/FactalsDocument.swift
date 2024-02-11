//
//  FactalsDocument.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

   //	Uniform Type Identifiers Overview:		https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html
  // Defining file and data types for your app:	https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
 //	System-declared uniform type identifiers:	https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
import UniformTypeIdentifiers

class DocGlobals : ObservableObject {
    @Published var docConfig : FwConfig
	init(docConfig d:FwConfig) {
		docConfig = d
	}
}

 // Define a new UTType for factals:
extension UTType {
	static var factals: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  	}	// com.example.fooTry3
}
 // Requirement of <<FileDocument>> protocol FileDocumentWriteConfiguration:
extension FactalsDocument {
	static var readableContentTypes: [UTType] { [.factals] }//{ [.exampleText, .text] }
	static var writableContentTypes: [UTType] { [.factals] }
}

extension FactalsDocument : Uid {
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
		DOClog.log("\(pp(.uidClass)): \(format)", args, terminator:terminator)
	}
}
struct FactalsDocument : FileDocument {
	let uid:UInt16				= randomUid()
    @StateObject var docGlobals	= DocGlobals(docConfig:params4pp)

	 // hold index of named items (<Class>, "wire", "WBox", "origin", "breakAtWire", etc)
	var indexFor				= Dictionary<String,Int>()

	var factalsModel : FactalsModel! = nil				// content
	var docConfig : FwConfig	= [:]

	init (fileURL: URL) {
		bug
	}
	// MARK: - 2.4.4 Building
	 // @main uses this to generate a blank document
	init() {	// Build a blank document, so there is a document of record with a Log
		DOC						= self			// INSTALL as current DOC, quick!

		 // 	1. Make RootPart:			//--FUNCTION--------wantName:--wantNumber:
		//**/	let select :String?	= nil	//	Blank scene		 |	nil		  -1
		//**/	let select		= "entry120"//	entry 120		 |	nil		  N *
		/**/	let select		= "xr()"	//	entry with xr()	 |	"xr()"	  -1
		//**/	let select		= "name"	//	entry named name |	"name" *  -1
		//**/	let select		= "- Port Missing"
		let rootPart			= RootPart(fromLibrary:select)
		factalsModel			= FactalsModel(fromRootPart:rootPart)

		 // BUT THESE ARE STRUCTS
		factalsModel.document 	= self			// DELEGATE
		DOC						= self			// INSTALL as current DOC, quick!

		configure(config:docConfig + rootPart.ansConfig)
	}
	func configure(config:FwConfig) {
		 // Build Vews per Configuration
		let rp					= factalsModel.rootPart//Actor
		for (key, value) in config {
//		for (key, value) in params4all {
			if key == "Vews",
			  let vewConfigs 	= value as? [VewConfig] {
				for vewConfig in vewConfigs	{	// Open one for each elt
					rp.addRootVew(vewConfig:vewConfig, fwConfig:config)
				}
			}
			else if key.hasPrefix("Vew") {
				if let vewConfig = value as? VewConfig {
					rp.addRootVew(vewConfig:vewConfig, fwConfig:config)
				}
				else {
					panic("Confused wo38r")
				}
			}
		}
		rp.ensureAVew(fwConfig:config)
		factalsModel.configure(from:config)
	}										// next comes viewAppearedFor (was didLoadNib(to)
	 // Document supplied
	init(factalsModel f:FactalsModel) {
		factalsModel			= f			// girootPart!.ven
		factalsModel.document	= self		// owner back-link
		DOC						= self		// INSTALL Factals
	}
	init(configuration: ReadConfiguration) throws {		// async
		//fatalError()
		guard let data : Data 	= configuration.file.regularFileContents else {
			print("\n\n######################\nCORRUPT configuration.file.regularFileContents\n######################\n\n\n")
			throw FwError(kind:".fileReadCorruptFile")						}
		switch configuration.contentType {	// :UTType: The expected uniform type of the file contents.
		case .factals:
			 // Decode data as a Root Part
			let rootPart		= RootPart.from(data: data, encoding: .utf8)	//RootPart(fromLibrary:"xr()")		// DEBUG 20221011

			 // Make the FileDocument
			let factalsModel	= FactalsModel(fromRootPart:rootPart)
bug;		self.init(factalsModel:factalsModel)

			docConfig				+= rootPart.ansConfig	// from library
		default:
				throw FwError(kind:".fileReadCorruptFile")
		}
	//	self.init()		// temporary
	}

	 /// Requirement of <<FileDocument>> protocol
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {		// cannot ba async throws
bug;//	throw FwError(kind:".fileWriteUnknown")
		switch configuration.contentType {
	//	case .factals:
	//		guard let dat		= factalsModel.rootPartActor.data else {	// how is RootPart.data worked?
	//			panic("FactalsDocument.factalsModel.rootPart.data is nil")
	//			let d			= factalsModel.rootPartActor.data		// redo for debug
	//			throw FwError(kind:"FactalsDocument.factalsModel.rootPart.data is nil")
	//		}
	//		return .init(regularFileWithContents:dat)
		default:
			throw FwError(kind:".fileWriteUnknown")
		}
	}

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
	let outPart					= outPoly.polyUnwrap()
	 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
	let _						= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()

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
		if let vew2inspec		= docConfig["inspec"] {
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
		bug
//		if let part	= factalsModel.rootPart?.find(name:name) {
//
//			 // Open inspectors for all RootVews:
//			for rootVew in factalsModel.rootVews {
//		 		if let vew = rootVew.find(part:part) {
//					showInspecFor(vew:vew, allowNew:true)
//				}
//			}
//		}
//		else {
//			atIns(4, warning("Inspector for '\(name)' could not be opened"))
//		}
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
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {return false}
		guard let rootPart : RootPart = vew.part.root else {return false }	// vew.root.part

		 // Check registered TimingChains
		for timingChain in factalsModel.simulator.timingChains {
/**/		if timingChain.processEvent(nsEvent:nsEvent, inVew:vew) {
				return true 				/* handled by timingChain */
			}
		}

		 // Check Simulator:
/**/	if factalsModel.simulator.processEvent(nsEvent:nsEvent, inVew:vew)  {
			return true 					// handled by simulator
		}

		 // Check Controller:
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						/* FwDocument has no key-ups */
		}
		 // Sim EVENTS						// /// Key DOWN ///////
		let cmd 				= nsEvent.modifierFlags.contains(.command)
		let alt 				= nsEvent.modifierFlags.contains(.option)
		var aux : FwConfig		= docConfig	// gets us params4pp
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
			print(rootPart.pp(.tree, aux), terminator:"")
		case "M":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'M': === Parts and Ports:")
			print(rootPart.pp(.tree, aux), terminator:"")
		case "l":
			aux["ppLinks"]		= true
			aux["ppDagOrder"]	= true
			print("\n******************** 'l': === Parts, Links:")
			print(rootPart.pp(.tree, aux), terminator:"")
		case "L":
			aux["ppPorts"]		= true
			aux["ppDagOrder"]	= true
			aux["ppLinks"]		= true
			print("\n******************** 'L': === Parts, Ports, Links:")
			print(rootPart.pp(.tree, aux), terminator:"")

		 // N.B: The following are preempted by AppDelegate keyboard shortcuts in Menu.xib
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
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		factalsModel.log.log(banner:banner, format_, args, terminator:terminator)
	}
	
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .line:
			return factalsModel.log.indentString() + " FactalsDocument"				// Can't use fwClassName; FwDocument is not an FwAny
		case .tree:
			return factalsModel.log.indentString() + " FactalsDocument" + "\n"
		default:
			return ppStopGap(mode, aux)		// NO, try default method
		}
	}
}
