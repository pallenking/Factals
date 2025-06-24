//
//  FactalsDocument.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI
import SceneKit

import UniformTypeIdentifiers
   // Uniform Type Identifiers Overview:		https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis.tasks/understand_utis_tasks.html
  //  Defining file and data types for your app:https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app
 //	  System-declared uniform type identifiers:	https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers
extension UTType {				// Define a new UTType for factals:
	static var hnw: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  		}
	static var vew: UTType 	{ UTType(exportedAs: "us.a-king.havenwant")  		}
}

 // MARK: - FactalsDocument
 // Requirement of <<FileDocument>> protocol FileDocumentWriteConfiguration:
extension FactalsDocument {
	static var readableContentTypes: [UTType] { 	[.hnw, .vew] 				}
	static var writableContentTypes: [UTType] { 	[.hnw, .vew] 				}
}

 //class FactalsDocument : ReferenceFileDocument {
struct FactalsDocument : FileDocument, Uid {

	let nameTag					= getNametag()			// for Logd
	var factalsModel : FactalsModel! = nil				// content

	// 4 OLD Enablers
	var windowNibName:NSNib.Name? 	{		bug;return "Document"				}// The  nib file  name of the document:
	var autosavesInPlace: Bool 		{		bug;return false					}// Enable Auto Savea:
	func canAsynchronouslyWrite(to:URL, ofType:String, for:NSDocument.SaveOperationType) -> Bool // Enable Asynchronous Writing:
	{	bug;return false	}		// Enable Asynchronous Reading:
	func canConcurrentlyReadDocuments(ofType:String) -> Bool
	{	bug;return false 	} // ofType == "public.plain-text"

	// MARK: - 2.4.4 Building
	init(fileURL : URL) {
		bug
	}
	 // @main uses this to generate a blank document
	init() {
		self.init(fromLibrary:"xr()")	// machine selected in Library Book.
	}
	init(fromLibrary select:String?=nil) {

		 // 1. Part ******
		let select = select ?? {
			 // 	1. Make Parts:			//--FUNCTION--------wantName:--wantNumber:
			/**/	let select:String?=nil	//	Blank scene		 |	nil		  -1
			//**/	let select	= "entry120"//	entry 120		 |	nil		  N *
			//**/	let select	= "xr()"	//	entry with xr()	 |	"xr()"	  -1
			//**/	let select	= "name"	//	entry named name |	"name" *  -1
			//**/	let select	= "- Port Missing"
			return select
			//	enum LibrarySelector {		// Someday ADD
			//		case empty				//		nil->			Blank scene		 |	nil		  -1
			//		case MarkedXr 			//					//	entry with xr()	 |	"xr()"	  -1
			//		case Numbered(Int)		//		= "entry120"//	entry 120		 |	nil		  N *
			//		case Titled(String)		//		= "name"	//	entry named name |	"name" *  -1
			//	}
		} ()
		let partBase			= PartBase(fromLibrary:select)

		 // 2. FactalModel first
		let fmConfig			= params4partVew + params4partPp
		factalsModel			= FactalsModel(partBase:partBase, configure:fmConfig)	//PartBase()
								//		factalsModel.partBase	= partBase		// Backpointer
								//		partBase.factalsModel	= factalsModel
		let c					= partBase.hnwMachine.config	// from library
		partBase.configure(from:c)

		 // 3. Groom part ******
		partBase.wireAndGroom([:])

		 // 4. Vews ******
		let c2					= fmConfig + c
		factalsModel.configureVews(from:c2)

		factalsModel.simulator.simBuilt	= true	// maybe before config4log, so loading simEnable works
	}
	 // Document supplied
	init(factalsModel f:FactalsModel) {
		factalsModel			= f			// girootPart!.ven
	}
	init(configuration: ReadConfiguration) throws {		// async
		guard let data : Data 	= configuration.file.regularFileContents
			else {	throw FwError(kind:".fileReadCorruptFile")					}
		switch configuration.contentType {	// :UTType: The expected uniform type of the file contents.
		case .hnw:
			 // Decode data as a Root Part
			let partsBase		= PartBase.from(data:data, encoding:.utf8)	//Parts(fromLibrary:"xr()")		// DEBUG 20221011

			 // Make the FileDocument
											//		let fmConfig			= params4logs
											//								+ params4vew		//
											//								+ params4partPp
											//								+ partBase.ansConfig		// from library
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
	// MARK: PolyWrap
	 /// Requirement of <<FileDocument>> protocol
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {		// cannot ba async throws
		switch configuration.contentType {
		case .hnw:
			do {
				let dat			= try factalsModel.partBase.data()
				return .init(regularFileWithContents:dat)
			} catch {
				let d			= try factalsModel.partBase.data()		// redo for debug
				throw FwError(kind:"FactalsDocument.factalsModel.partBase.data is nil")
			}
//			guard let dat		= factalsModel.partBase.data() else {	// how is Parts.data worked?
//				panic("FactalsDocument.factalsModel.partBase.data is nil")
//				let d			= factalsModel.partBase.data()		// redo for debug
//				throw FwError(kind:"FactalsDocument.factalsModel.partBase.data is nil")
//			}
		case .vew:
			fatalError()
		default:
			throw FwError(kind:".fileWriteUnknown")
		}
	}

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
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
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
