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
 // Define a new UTType for factals:
extension UTType {
	static var factals: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  	}	// com.example.fooTry3
}

 // MARK: - FactalsDocument
 // Requirement of <<FileDocument>> protocol FileDocumentWriteConfiguration:
extension FactalsDocument {
	static var readableContentTypes: [UTType] { [.factals] }					//{ [.exampleText, .text] }
	static var writableContentTypes: [UTType] { [.factals] }
}

extension FactalsDocument : Uid {
	func logd(_ format:String, _ args:CVarArg..., terminator:String?=nil) {
		let log					= self.factalsModel.log
		log.log("\(pp(.uidClass)): \(format)", args, terminator:terminator)
	}
}
struct FactalsDocument : FileDocument {
	let uid:UInt16				= randomUid()

	var factalsModel : FactalsModel! = nil				// content
							
	func retainIn(_ docs:Binding<[FactalsDocument]>) -> FactalsDocument {
		docs.wrappedValue.append(self)
		print("======== retainIn nibName:'\(windowNibName ?? "nil")' Now \(docs.wrappedValue.count) documents")
		return self
	}
//	func retainIn() -> FactalsDocument {
//		return self
//	}

//	init(openDocuments:Binding<[FactalsDocument]>) {
//		self.init(fromLibrary:"xr()")
//		openDocuments.wrappedValue.append(self)
//	}
	init(fileURL: URL) {
		bug
	}
	// MARK: - 2.4.4 Building
	 // @main uses this to generate a blank document
	init() {	// Build a blank document, so there is a document of record with a Log
		self.init(fromLibrary:"xr()")
	}
	enum LibrarySelector {				// NEW
		case MarkedXr 					//					//	entry with xr()	 |	"xr()"	  -1
		case Numbered(Int)				//		= "entry120"//	entry 120		 |	nil		  N *
		case Titled(String)				//		= "name"	//	entry named name |	"name" *  -1
	}		 							//		nil->			Blank scene		 |	nil		  -1

	init(fromLibrary:String) {

		 // 	1. Make Parts:				//--FUNCTION--------wantName:--wantNumber:
		//**/	let select :String?	= nil	//	Blank scene		 |	nil		  -1
		//**/	let select		= "entry120"//	entry 120		 |	nil		  N *
		/**/	let select		= "xr()"	//	entry with xr()	 |	"xr()"	  -1
		//**/	let select		= "name"	//	entry named name |	"name" *  -1
		//**/	let select		= "- Port Missing"
		let partBase			= PartBase(fromLibrary:select)
		factalsModel			= FactalsModel(partBase:partBase)
		partBase.wireAndGroom([:])
		configure(config:factalsModel.fmConfig + partBase.ansConfig)
	}

	 // Document supplied
	init(factalsModel f:FactalsModel) {
		factalsModel			= f			// girootPart!.ven
//		factalsModel.document	= self		// owner back-link
//		DOC						= self		// INSTALL Factals
	}
	init(configuration: ReadConfiguration) throws {		// async
		//fatalError()
		guard let data : Data 	= configuration.file.regularFileContents else {
			print("\n\n######################\nCORRUPT configuration.file.regularFileContents\n######################\n\n\n")
			throw FwError(kind:".fileReadCorruptFile")						}
		switch configuration.contentType {	// :UTType: The expected uniform type of the file contents.
		case .factals:
			 // Decode data as a Root Part
			let parts		= PartBase.from(data: data, encoding: .utf8)	//Parts(fromLibrary:"xr()")		// DEBUG 20221011

			 // Make the FileDocument
			let factalsModel	= FactalsModel(partBase:parts)
bug;		self.init(factalsModel:factalsModel)

//			fmConfig				+= partBase.ansConfig	// from library
		default:
				throw FwError(kind:".fileReadCorruptFile")
		}
	//	self.init()		// temporary
	}

	func configure(config:FwConfig) {
		 // Build Vews per Configuration
		let rp					= factalsModel.partBase
		for (key, value) in config {				//params4all
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
	// MARK: PolyWrap
	 /// Requirement of <<FileDocument>> protocol
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {		// cannot ba async throws
bug;//	throw FwError(kind:".fileWriteUnknown")
		switch configuration.contentType {
	//	case .factals:
	//		guard let dat		= factalsModel.rootPartActor.data else {	// how is Parts.data worked?
	//			panic("FactalsDocument.factalsModel.partBase.data is nil")
	//			let d			= factalsModel.rootPartActor.data		// redo for debug
	//			throw FwError(kind:"FactalsDocument.factalsModel.partBase.data is nil")
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
			let jsonData 		= try JSONEncoder().encode(inPolyPart)

				print(String(data:jsonData, encoding:.utf8) ?? "")

			 //  - DECODE -  PolyWrap from JSON
			let outPoly:PolyWrap = try JSONDecoder().decode(PolyWrap.self, from:jsonData)
									
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

//	func modelDispatch(with event:NSEvent, to pickedVew:Vew) {
//		print("modelDispatch(fwEvent: to:")
//	}

//	func windowControllerDidLoadNib(_ windowController:NSWindowController) {
//	//	updateDocConfigs(from:partBase.ansConfig)	// This time including rootScn
//	//			// Build Views:
//		rootScn.updateVews(fromRootPart:parts, reason:"InstallRootPart")
//		displayName				= partBase.title
//		window0?.title			= displayName									//makeInspectors()
//		makeInspectors()
//		parts.simulator.simBuilt = true	// maybe before config4log, so loading simEnable works
//	}

	// MARK: - 14. Building
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
bug//	factalsModel.log.log(banner:banner, format_, args, terminator:terminator)
	}
	
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .line:
			return "factalsModel.log.indentString()" + " FactalsDocument"				// Can't use fwClassName; FwDocument is not an FwAny
		case .tree:
			return "factalsModel.log.indentString()" + " FactalsDocument" + "\n"
		default:
			return "ppStopGap(mode, aux)"		// NO, try default method
		}
	}
}
