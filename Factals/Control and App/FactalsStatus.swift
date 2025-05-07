// FwStatus.swift -- Extensions for 1-line description of all System Controllers ©200116PAK
/*
	menu<logState>
	FactalsApp.appState(sender:)	<many> (Lldbinit, FactalsModel(Bar)) macro
					|				  /
			Factals.ppControlElement()
			FactalsStatus.ppControlElement() FACTALSMODEL? to all Classes)
			ppFactalsStateHelper
 */
import SceneKit

  /// Print State of ALL System Controllers in the App, starting with FactalApp:
 /// - Returns: State of all Controllers, one per line
func ppControllers(config:Bool=false) -> String {
	let fm : FactalsStatus?	= false ? FactalsAppDelegate.shared
									: FACTALSMODEL
	return fm?.ppControlElement(config:false) ?? ""
}												//return FACTALSMODEL?.ppControlElement() ?? "FACTALSMODEL is nil uey3r8ypv"
												//return ""
												//let x = factalsApp
												//return self.ppControlElement() ?? "FACTALSMODEL is nil uey3r8ypv"
 /// Print status of Factal Workbench Controllers
protocol FactalsStatus : FwAny {
	func ppControlElement(config:Bool) -> String
}

func ppFactalsStateHelper(_ fwClassName_: String,
							nameTag		: Uid,
							myLine		: String 		= "",	// stuff after ". . ."
							otherLines	: (()->String)?	= nil	// hash generating trailing lines
						 ) -> String
{
	var rv						= ppFwPrefix(nameTag:nameTag, fwClassName_) + myLine + "\n"
		// Other Lines:
	Log.shared.nIndent			+= 1
	rv 							+= otherLines?() ?? ""
	Log.shared.nIndent			-= 1
	return rv
}
 /// Prefix: "1e98 | | <fwClass>   0    . . . . . . . . "
func ppFwPrefix(nameTag:Uid?, _ fwClassName_:String) -> String {
	 // align nameTag printouts for ctl and part to 4 characters
	let log						= Log.shared
	var rv						= ppUid(pre:" ", nameTag, showNil:true).field(-5) + " "
	rv 							+= log.indentString()
	rv							+= fmt("%-12@", fwClassName_)
	rv							=  log.unIndent(rv)
	return rv
}

// //// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  /////
// /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  ///
// // /////  / /////  / /////  / ///// / /////   / /////  / /////  / /////  /
// / //// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  /////
//  //// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  ///
// //// /////  / /////  / /////  / ///// / /////   / /////  / /////  / /////  /

extension FactalsApp : FactalsStatus	{							///FactalsApp
	func ppControlElement(config:Bool=false) -> String {
	//	let documents 			= NSDocumentController.shared.documents		// THIS BREAKS THINGS
		return ppFactalsStateHelper("FactalsApp   ", nameTag:self,
			myLine://(documents.count == 0 ? "No Open Files, " :"") 				+
				"regressScene:\(regressScene), " 								,
			otherLines:{
				 // Menu Creation:
				var rv			=		  Log.shared.ppControlElement()
				rv				+= factalAppDelegate.ppControlElement()
				rv				+= 			 library.ppControlElement()
	//			for document in documents {
	//				rv			+=			document.ppControlElement()
	//			}
				return rv
			})
	}
}
extension FactalsAppDelegate : FactalsStatus	{			  ///FactalsAppDelegate
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("FactalsAppDel", nameTag:self)
	}
}
extension Library : FactalsStatus {										///Library
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("\(self.fileName.field(-13))", nameTag:self,
			myLine:"(\(Library.books.count.asString!.field(4)) Books)",
			otherLines: {
				var rv			= ""
				for book in Library.books {
					rv			+= book.ppControlElement(config:config)
				}
				return rv
			})
	}
}
extension Book : FactalsStatus {								///Book or ///Tests01, ...
	func ppControlElement(config:Bool=false) -> String {
		let myLine				= "?? tests" //"(\(??.asString!.field(4)) tests)"
		return ppFactalsStateHelper("\(self.fileName.field(-13))", nameTag:self, myLine:myLine)
	}
}

// MARK : - DOCUMENT
extension FactalsDocument : FactalsStatus	{				  	 ///FactalsDocument
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("FactalsDocume", nameTag:self,
			myLine: factalsModel == nil ? "factalsModel is nil" : "",
			otherLines:{
				guard let factalsModel else {	return ""						}
				return factalsModel.ppControlElement()
			})
	}
}
 // MARK  - DOCUMENT
extension NSDocument : FactalsStatus	{							///NSDocument
	func ppControlElement(config:Bool=false) -> String {
bug; //never used?
		let wcc					= windowControllers.count
		return ppFactalsStateHelper("NSDocument   ", nameTag:self,
			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""):   #ADD MORE HERE#",
			//	+ "wc0:\(   ppUid(windowController0, showNil:true)) "
			//	+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
			//	+ "scnView:\(ppUid(scnView,		     showNil:true)) "
			//	+ "paramPrefix:'\(documentParamPrefix.pp())'"
			otherLines:{
				var rv			= "truncated"//  self.partBase.ppControlElement() // Controller:
				 // Window Controllers
			//	for windowController in self.windowControllers {
			//		rv		+= windowController.ppControlElement()
			//	}
				return rv
			})
	}
}
//extension NSDocumentController : FactalsStatus {		  ///NSDocumentController
//	func ppControlElement(config:Bool=false) -> String {
//		let ct					= self.documents.count
//		return ppFactalsStateHelper("DOCctlr      ", nameTag:self,
//			myLine:"\(ct) FwDocument" + (ct != 1 ? "s:" : ":"),
//			otherLines:{
//				var rv			= ""
//				for document in self.documents {	//NSDocument
//					rv			+= document.ppControlElement()
//				}
//				return rv
//			},
//	}
//}
extension FactalsModel : FactalsStatus	{							///FactalsModel
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("FactalsModel ", nameTag:self,
			myLine : "\(vewBases.count) vewBases ",
			otherLines:{

				 // Controller:
				var rv			=  self.partBase .ppControlElement(config:config)
				rv				+= self.simulator.ppControlElement(config:config)
				for vewBase in self.vewBases {
					rv			+= vewBase       .ppControlElement(config:config)
				}
				return rv
			}
		)
	}
}
extension PartBase : FactalsStatus	{								 ///PartBase
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("PartBase     ", nameTag:self,
			myLine: "tree:\(tree.pp(.tagClass)) "		 			+
					"(\(portCount()) Ports) " 						+
					"lock=\(semiphore.value ?? -98) " 				+
					(curOwner==nil ? "UNOWNED," : "OWNER:'\(curOwner!)',") +
					" dirty:'\(tree.dirty.pp())' "					)
	}																			//bug; return "extension Parts : FwStatus needs HELP"	}
}
extension TimingChain : FactalsStatus {								///TimingChain
	func ppControlElement(config:Bool=false) -> String {
		var myline			= "'\(pp(.fullName))':"
		myline 				+= event != nil ? "event:\(event!.pp()) " : ""
		myline				+= "  state:.\(state) "
//		myline				+= eventDownPause ? " eventDownPause": ""
		myline				+= animateChain   ? " animateChain"  : ""
		myline				+= asyncData 	  ? " asyncData" 	 : ""
		return ppFactalsStateHelper("TimingChain  ", nameTag:self, myLine:myline)
	}
}

extension Simulator : FactalsStatus	{								///Simulator
 	func ppControlElement(config:Bool=false) -> String {
		guard simBuilt else
		{	return "Simulator not built "										}
		var myline				= factalsModel == nil 	? "(factalsModel==nil)"
								: factalsModel!.simulator === self ? "" : "OWNER:'\(factalsModel!)' BAD"
		myline 					+= "simBuilt"
		myline					+= simRun ? " simRun" : " simHalt"
		myline					+= ", timeNow:\(timeNow,decimals:3)"
		myline					+= " going:\(globalDagDirUp ? "up" : "down")"
		myline					+= ", timeStep:\(timeStep)"
		myline					+= !simTaskRunning ? " taskHalt" : " taskPeriod=\(String(simTaskPeriod)) "

		myline					+= isSettled() ? " settled" : " running"
		myline					+= " \(linkChits)/L"
		myline					+= " \(startChits)/S)"
		return ppFactalsStateHelper(
			"Simulator    ", nameTag:self, myLine:myline)
			{	guard let fm	= self.factalsModel else { return "factalsModel in nil"}
				var rv			= ""
				let _ 			= fm.partBase.tree.findCommon() {
					if let tc	= $0 as? TimingChain {
						rv		= tc.ppControlElement(config:config)
					}
					return nil		// search whole tree (never find)
				}
				return rv
			}
	}
}

extension VewBase : FactalsStatus	{								  ///VewBase
	func ppControlElement(config:Bool=false) -> String {
		guard let factalsModel	else {	return "Vew.vews?.factalsModel == nil\n" }
		guard let slot			= slot, slot >= 0, slot < factalsModel.vewBases.count
								else { 	return("Error Illegal slot: \(slot ?? -1)")			}
//		guard factalsModel.vewBases[slot] === self else {
//			return "\t\t\t\t vewBases[] mismatch\n" }
		let myName				= "VewBase[\(slot)]:  "

		guard let vewTreeScnParent = self.tree.scn.parent else { return "ERROR: vewTreeScnParent == nil"}
		let scnTreeRoot			= self.scnBase.roots?.rootNode
		var myLine				= vewTreeScnParent===scnTreeRoot ? "" : ("ERROR< "
								+	"vewTreeScnParent(\(vewTreeScnParent.pp(.nameTag)))  "
								+	"!==  scnTreeRoot=\(scnTreeRoot?.pp(.nameTag) ?? "nil") >ERROR\n\t\t\t\t")
		myLine					+= "vewBase.tree:\(tree.pp(.tagClass)) "
		myLine					+= "Lock=\(semiphore.value ?? -99) "
		myLine					+= curLockOwner==nil ? "UNOWNED, " : "OWNER:'\(curLockOwner!)', "		// dirty:'\(tree.dirty.pp())'
		myLine					+= "lookAtVew:\(lookAtVew?.pp(.classTag) ?? "nil") "
		myLine					+= "\(inspectedVews.count) inspectedVews"
		return ppFactalsStateHelper(myName, nameTag:self, myLine:myLine,
			otherLines: {
				var rv			=  self.scnBase   .ppControlElement(config:config)
				rv				+= self.selfiePole.ppControlElement(config:config)
				rv 				+= self.cameraScn?.ppControlElement(config:config)
									?? "\t\t\t\t cameraScn is nil\n"
				for vew in self.inspectedVews {
					rv 			+= vew	   		  .ppControlElement(config:config)		//deapth:0,
				}
				return rv
			})
	}
}

extension Vew : FactalsStatus	{										  ///Vew
	func ppControlElement(config:Bool=false) -> String {
		var rv					= ""
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self,
			myLine:"'\(fullName)'",
			otherLines: {
				for child in self.children {
					rv			+= child.ppControlElement(config:config)
				}
				return rv
			})
	}
}
extension SelfiePole : FactalsStatus	{							///SelfiePole
	func ppControlElement(config:Bool=false) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", nameTag:self,
			myLine:myLine)
	}
}
extension Inspec : FactalsStatus	{									///Inspec
	func ppControlElement(config:Bool=false) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", nameTag:self,
			myLine:myLine)
	}
}

extension ScnBase : FactalsStatus	{						  ///ScnBase
	func ppControlElement(config:Bool=false) -> String {
		var myLine				= vewBase?.scnBase === self ? "" : "OWNER:'\(vewBase!)' is BAD"
		myLine					+= "tree:\(roots?.rootNode.pp(.tagClass) ?? "<nil>")=rootNode "
		myLine					+= "\(roots?			  .pp(.tagClass) ?? "<nil>") "			//classUid
		myLine					+= "scnView:\(	  scnView?.pp(.tagClass) ?? "<nil>") "			//classUid
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self, myLine:myLine)//,
//			otherLines: {
//				return self.tree!   .ppControlElement()
//					+ (self.scnView?.ppControlElement() ?? "")
//			},
	}
}
extension SCNScene : FactalsStatus {								 ///SCNScene
	func ppControlElement(config:Bool=false) -> String {
		let myLine				= rootNode.name == "rootNode" ? "" : "rootNode.name=\(rootNode .name ?? "?") -- BAD!!"
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self,
			myLine:myLine,
			otherLines: {
				return self.rootNode    .ppControlElement(config:config)
					+  self.physicsWorld.ppControlElement(config:config)
					+  self.lightingEnvironment.ppControlElement(config:config)
					+  self.background  .ppControlElement(config:config)
 			})
	}
}
extension SCNNode : FactalsStatus	{								  ///SCNNode
	func ppControlElement(config:Bool=false) -> String {
		var myLine				= "'\(fullName)': \(children.count) children, (\(nodeCount()) SCNNodes) "
		myLine					+= camera == nil ? "" : "camera:(camera!.pp(.classTag)) "
		myLine					+= light  == nil ? "" :  "light:( light!.pp(.classTag)) "
		return ppFactalsStateHelper("SCNNode      ", nameTag:self,				//"SCNPhysicsWor"
			myLine:myLine)
	}
}
extension SCNPhysicsWorld : FactalsStatus	{					///SCNPhysicsWorld
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("SCNPhysicsWor", nameTag:self,
			myLine:fmt("gravity:\(gravity.pp(.phrase)), speed:%.4f, timeStep:%.4f", speed, timeStep))
	}
}
extension SCNMaterialProperty : FactalsStatus	{			  ///SCNMaterialProperty
	func ppControlElement(config:Bool=false) -> String {
		// borderColor
		// contents
		// mappingChannel
		// minificationFilter	__C.SCNFilterMode
		//	magnificationFilter, mipFilter
		// wrapS. wrapS			__C.SCNWrapMode
		// textureComponents
		// intensity
		// maxAnisotropy		3.4028234663852886e+38
		return ppFactalsStateHelper("SCNMaterialPr", nameTag:self, myLine:"--")
	}
}
extension Log : FactalsStatus {											  ///Log
	func ppControlElement(config:Bool=false) -> String {
		let msg					= "event:\(eventNumber), breakAt:\(breakAtEvent), " +
			"detailWanted:\(detailWanted.pp(.line)),"
		return ppFactalsStateHelper("Log".field(-13), nameTag:self, myLine:msg)
	}
}
//extension Sound : FactalsStatus {										///Sound
//	func ppControlElement() -> String {
//		let msg					= ""
//		let logKind				= "sounds".field(-13)
//		return ppFactalsStateHelper(logKind, nameTag:self, myLine:msg)
//	}
//}
		// ///////////////////////////////////// //

extension NSWindowController : FactalsStatus {				///NSWindowController
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("\("NSWindowCtlr ")", nameTag:self,
			myLine:
				ppState() + (windowNibName == nil ? ";;" : ":\"\(windowNibName!)\" ") +
				ppUid(pre:"doc:",document as? NSDocument,post:" ",showNil:true) +
				ppUid(pre:"win:", 	 window,  			 post:" ",showNil:true) +
				ppUid(pre:"nibOwner:", owner as? Uid,	 post:" ",showNil:true) ,
			otherLines:{
				return self.window?.ppControlElement(config:config) ?? ""
			})
	}
	func ppState() -> String {
		return
			windowNibName == nil ? 	 "nilNameNib" 	:
			window == nil ? 		"awaitingNib"	:
									  "loadedNib"
	}
}
extension NSWindow : FactalsStatus {								 ///NSWindow
	func ppControlElement(config:Bool=false) -> String {
								//
		let contract 			= trueF
		let log					= Log.shared
		return ppFactalsStateHelper("NSWindow     ", nameTag:self,
			myLine:
   			       "title:'\(title)' "											+
   			   "contentVC:\(ppUid(contentViewController, showNil:true)) "		+
			 "contentView:\(ppUid(contentView,  		 showNil:true)) "		+
				"delegate:\(ppUid(delegate as? String, 	 showNil:true)) \n"		+
			(!contract ? "" :
				" " + uidStrDashes(nilLike:self) + " " + log.indentString() + "\\ contentVew OMITTED\n"),
			otherLines:{ 		//			uidStrDashes(nilLike
				return contract ? "" :
					 self.contentView?.ppControlElement(config:config) ?? ""
			})
	}
}
//extension NSViewController : FwStatus {						 ///NSViewController
//	func ppControlElement(deapth:Int=999, config:Bool) -> String {
//bug;	let rob					= representedObject as? NSView		//FwStatus
//		return ppFactalsStateHelper("NSViewCtlr   ", nameTag:self,
//			myLine: ppState +
//				  " view:\(ppUid(view, 		showNil:true))" 					+
//				" repObj:\(ppUid(rob, 		showNil:true))" 					+	// ??
//			   " nibName:\(ppUid(nibName,	showNil:true))" 					+	// ??
//				 " title:\(ppUid(title,		showNil:true))"						,
//			otherLines:{ deapth in
//				return self.view.ppControlElement(deapth:deapth-1)
//			},
//			deapth:deapth-1)
//	}
//	var ppState : String {
//		return  nibName == nil ? 		"Nib nil"	 	: "Nib loaded"
//	}
//}
extension NSView : FactalsStatus	{								   ///NSView
	func ppControlElement(config:Bool=false) -> String {
		let msg					= fwClassName.field(-13)
		return ppFactalsStateHelper(msg, nameTag:self,
			myLine:
				"\(subviews.count) children "									+
				"superv:\(superview?.pp(.classTag) ?? "nil") "					+
				   "win:\(window?   .pp(.classTag) ?? "nil") " 					,
//				"superv:\(ppUid(superview, showNil:true)) "						+
//				   "win:\(ppUid(window,    showNil:true)) " 					,
			otherLines:{
				var rv			= ""
	//			rv				+= self.subviews.map { $0.ppControlElement(deapth:deapth-1)			}
				for view in self.subviews {
					rv			+= view.ppControlElement(config:config)
				}
				return rv
			})
	}
}

extension NSException : FactalsStatus	{						  ///NSException
	func ppControlElement(config:Bool=false) -> String {
		return ppFactalsStateHelper("NSException  ", nameTag:self,
			myLine:"reason:'\(reason ?? "<nil>")'")
	}
}
