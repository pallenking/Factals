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
	static var hnw: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  		}
	static var vew: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  		}
}

 // MARK: - FactalsDocument
 // Requirement of <<FileDocument>> protocol FileDocumentWriteConfiguration:
extension FactalsDocument {
	static var readableContentTypes: [UTType] { 	[.hnw, .vew] 				}
	static var writableContentTypes: [UTType] { 	[.hnw, .vew] 				}
}
extension FactalsDocument : Logd {
	func logd(_ format:String, _ args:CVarArg..., terminator:String="\n") {		//String?=nil
		log.log("\(pp(.tagClass)): \(format)", args, terminator:terminator)
	}
}

 //class FactalsDocument : ReferenceFileDocument {
struct FactalsDocument : FileDocument {
	let nameTag						= getNametag()
	var factalsModel : FactalsModel! = nil				// content
	var log 	  : Log			= Log.app // Use Apps log
//	var log 	  : Log			= Log(name:"Model's Log", configure:
//		params4partPp			+  	//	pp... (50ish keys)
//		params4logs 			+	// : "debugOutterLock":f, "breakAtLogger":1, "breakAtEvent":50
//		logAt(all:docLogN))
	var foo = 3

	init(fileURL: URL) {
		bug
	}
	// MARK: - 2.4.4 Building
	 // @main uses this to generate a blank document
	init() {	// Build a blank document, so there is a document of record with a Log

		// create Log and Sound here
		self.init(fromLibrary:"xr()")
		log.configure(from:[:])//cfgArg)
	}
//	enum LibrarySelector {				// NEW
//		case empty						//		nil->			Blank scene		 |	nil		  -1
//		case MarkedXr 					//					//	entry with xr()	 |	"xr()"	  -1
//		case Numbered(Int)				//		= "entry120"//	entry 120		 |	nil		  N *
//		case Titled(String)				//		= "name"	//	entry named name |	"name" *  -1
//	}

	init(fromLibrary select:String?=nil) {
//log.log("slkfsljf")
		 // 1. Part
		let select = select ?? {
			 // 	1. Make Parts:			//--FUNCTION--------wantName:--wantNumber:
			/**/	let select:String?=nil	//	Blank scene		 |	nil		  -1
			//**/	let select	= "entry120"//	entry 120		 |	nil		  N *
			//**/	let select	= "xr()"	//	entry with xr()	 |	"xr()"	  -1
			//**/	let select	= "name"	//	entry named name |	"name" *  -1
			//**/	let select	= "- Port Missing"
			return select
		} ()
		let partBase			= PartBase(fromLibrary:select)

		 // 2. FactalModel
		let pmConfig			= params4logs
								+ params4vew
								+ params4partPp
								+ partBase.ansConfig		// from library
		factalsModel			= FactalsModel(partBase:partBase, configure:pmConfig)
		factalsModel.factalsDocument = self																		//factalsModel.configurePart(from:pmConfig)
		 // 3. Groom part
		partBase.wireAndGroom([:])

		 // 3. Vews
								/*		How to configure?
									1.	pt partBase.ansConfig		xrConfig	[selfiePole:[:4 elts], gapLinkFluff:3]
									2.	pt factalsModel.fmConfig	xrConfig	[selfiePole:[:4 elts], gapLinkFluff:3]
									3.	pt params4pp							[ppNCols4VewPosns:20,... ppNNameCols:8, ppLinks:false]
									parms4all
										params4app		:	soundVolume, regressScene, emptyEntry
										params4appLog	:	params4pp + params4logs + logAt(app:appLogN, ...) + logAt(doc:docLogN,...)
										params4pp		:	pp... (50ish keys)
										params4sim		:	enabled, timeStep, ...
										params4vew		:	physical Characterists of object e.g: factalHeight
										params4logs	: "debugOutterLock":f, "breakAtLogger":1, "breakAtEvent":50
										logAt(xxx:dd)
						 */
		let fmConfig			= factalsModel.fmConfig
								+ params4logs //+ logAt(app:appLogN, ...) + logAt(doc:docLogN,...)
								+ params4vew
								+ params4partPp
								+ partBase.ansConfig		// from library
						//		+ logAt(all:8)
		factalsModel.configureVews(from:fmConfig)
		factalsModel.simulator.simBuilt	= true	// maybe before config4log, so loading simEnable works
		factalsModel.docSound.load(name: "di-sound", path:"di-sound")
		factalsModel.docSound.play(sound:"di-sound", onNode:SCNNode())	//GameStarting
	}
	 // Document supplied
	init(factalsModel f:FactalsModel) {
		factalsModel			= f			// girootPart!.ven
	}
	init(configuration: ReadConfiguration) throws {		// async
		//fatalError()
		guard let data : Data 	= configuration.file.regularFileContents else {
			print("\n\n######################\nCORRUPT configuration.file.regularFileContents\n######################\n\n\n")
			throw FwError(kind:".fileReadCorruptFile")						}
		switch configuration.contentType {	// :UTType: The expected uniform type of the file contents.
		case .hnw:
			 // Decode data as a Root Part
			let partsBase		= PartBase.from(data: data, encoding: .utf8)	//Parts(fromLibrary:"xr()")		// DEBUG 20221011

			 // Make the FileDocument
			let factalsModel	= FactalsModel(partBase:partsBase, configure:[:])
bug;		self.init(factalsModel:factalsModel)

//			fmConfig			+= partBase.ansConfig	// from library
		case .vew:
			fatalError()
//			let vewBase			= VewBase.from(data: data, encoding: .utf8)	//Parts(fromLibrary:"xr()")		// DEBUG 20221011
//			le
		default:
				throw FwError(kind:".fileReadCorruptFile")
		}
	//	self.init()		// temporary
	}

//	func configure(config:FwConfig) {		// Everything associated with a FactlsDocument
//		 // Build Vews per Configuration
//		factalsModel.configure(from:config)
//	}										// next comes viewAppearedFor (was didLoadNib(to)
	// MARK: PolyWrap
	 /// Requirement of <<FileDocument>> protocol
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {		// cannot ba async throws
		switch configuration.contentType {
		case .hnw:
			guard let dat		= factalsModel.partBase.data else {	// how is Parts.data worked?
				panic("FactalsDocument.factalsModel.partBase.data is nil")
				let d			= factalsModel.partBase.data		// redo for debug
				let _			= d
				throw FwError(kind:"FactalsDocument.factalsModel.partBase.data is nil")
			}
			return .init(regularFileWithContents:dat)
		case .vew:
			fatalError()
		default:
			throw FwError(kind:".fileWriteUnknown")
		}
	}
		//bug;	throw FwError(kind:".fileWriteUnknown")

	typealias PolyWrap = Part
	class Part : Codable /* PartProtocol*/ {
		func polyWrap() -> PolyWrap {	bug; return polyWrap() }
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

	// MARK: - 14. Building
//	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
//bug//	factalsModel.log.log(banner:banner, format_, args, terminator:terminator)
//	}
	
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .line:
			return "factalsModel.log.indentString()" + " FactalsDocument"				// Can't use fwClassName; FwDocument is not an FwAny
		case .tree:
			return "factalsModel.log.indentString()" + " FactalsDocument" + "\n"
		default:
			return ppFixedDefault(mode, aux)		// NO, try default method
		}
	}
}
