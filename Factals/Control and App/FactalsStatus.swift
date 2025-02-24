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

  /// Print State of ALL System Controllers in the App, starting with FactalModel:
 /// - Returns: State of all Controllers, one per line
func ppController(deapth:Int=999, config:Bool/*=false*/) -> String {
	//let x = factalsApp
	//return ""
	return FACTALSMODEL?.ppControlElement(deapth:deapth-1, config:false) ?? ""
}

 /// Print status of Factal Workbench Controllers
protocol FactalsStatus : FwAny {
	func ppControlElement(deapth:Int, config:Bool) -> String
}

func ppFactalsStateHelper(_ fwClassName_: String,
							nameTag		: Uid,
							myLine		: String 			= "",	// stuff after ". . ."
							otherLines	: ((Int)->String)?	= nil,	// hash generating trailing lines
							deapth		: Int						// Infinite loop detection //= 999
						 ) -> String
{
	let log						= Log.ofApp
	var rv						= ppFwPrefix(nameTag:nameTag, fwClassName_) + myLine + "\n"
			// Other Lines:
	if deapth > 0 {
		log.nIndent				+= 1
		rv 						+= otherLines?(deapth) ?? ""
		log.nIndent				-= 1
	}
	return rv
}
 /// Prefix: "1e98 | | <fwClass>   0    . . . . . . . . "
func ppFwPrefix(nameTag:Uid?, _ fwClassName_:String) -> String {
	 // align nameTag printouts for ctl and part to 4 characters
	let log						= Log.ofApp
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
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		let emptyEntry			= "? "//APP?.factalsConfig.string("emptyEntry") ?? "xr()"
		let regressScene		= "? "//APP?.config.int("regressScene") ?? -1
		return ppFactalsStateHelper("FactalsApp   ", nameTag:self,
			myLine:"regressScene:\(regressScene), " +
				"emptyEntry:'\(emptyEntry)' ",
//				"\(config.pp(.tagClass))=\(self.config.count)_elts",
			otherLines:{ deapth in
				 // Menu Creation:
				var rv			= self.library.ppControlElement(deapth:deapth-1, config:false)
				for book in Library.books {
					rv			+= book		  .ppControlElement(deapth:deapth-1, config:false)
				}
				rv				+= self	  .log.ppControlElement(deapth:deapth-1, config:false)
				return rv
			},
			deapth:deapth-1)
	}
}

// MARK : - DOCUMENT
extension FactalsDocument : FactalsStatus	{				  	 ///FactalsDocument
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("FactalsDocume", nameTag:self,
			myLine: factalsModel == nil ? "factalsModel is nil" : "",
			otherLines:{ deapth in
				guard let factalsModel else {	return ""						}
				var rv			= factalsModel.ppControlElement(deapth:deapth-1, config:false)
//				rv				+= self.log   .ppControlElement(deapth:deapth-1, config:false)
				return rv
			},
			deapth:deapth
		)
	}
}
extension FactalsModel : FactalsStatus	{							///FactalsModel
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("FactalsModel ", nameTag:self,
			myLine : "\(vewBases.count) vewBases ",
			otherLines:{deapth in

				 // Controller:
				var rv			= self.partBase  .ppControlElement(deapth:deapth-1, config:config)
				rv				+= self.simulator.ppControlElement(deapth:deapth-1, config:config)
				rv				+= self.log      .ppControlElement(deapth:deapth-1, config:false)
				for vewBase in self.vewBases {
					rv			+= vewBase       .ppControlElement(deapth:deapth-1, config:config)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
// MARK  - DOCUMENT
//extension NSDocument : FactalsStatus	{							///NSDocument
//	func ppControlElement(deapth:Int=999, config:Bool) -> String {
//bug; //never used?
//		let wcc					= windowControllers.count
//		return ppFactalsStateHelper("NSDocument   ", nameTag:self,
//			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""):   #ADD MORE HERE#",
//			//	+ "wc0:\(   ppUid(windowController0, showNil:true)) "
//			//	+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
//			//	+ "scnView:\(ppUid(scnView,		     showNil:true)) "
//			//	+ "paramPrefix:'\(documentParamPrefix.pp())'"
//			otherLines:{ deapth in
//				var rv			= "truncated"//  self.partBase.ppControlElement(deapth:deapth-1) // Controller:
//				 // Window Controllers
//			//	for windowController in self.windowControllers {
//			//		rv		+= windowController.ppControlElement(deapth:deapth-1)
//			//	}
//				return rv
//			},
//			deapth:deapth)
//	}
//}
//extension NSDocumentController : FactalsStatus {		  ///NSDocumentController
//	func ppControlElement(deapth:Int=999, config:Bool) -> String {
//		let ct					= self.documents.count
//		return ppFactalsStateHelper("DOCctlr      ", nameTag:self,
//			myLine:"\(ct) FwDocument" + (ct != 1 ? "s:" : ":"),
//			otherLines:{ deapth in
//				var rv			= ""
//				for document in self.documents {	//NSDocument
//					rv			+= document.ppControlElement(deapth:deapth-1)
//				}
//				return rv
//			},
//			deapth:deapth-1)
//	}
//}
extension Library : FactalsStatus {										///Library
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("\(self.fileName.field(-13))", nameTag:self,
			myLine:"(\(Library.books.count.asString!.field(4)) Books)",
			otherLines: { deapth in
				var rv			= ""
				for book in Library.books {
					rv			+= book.ppControlElement(deapth:deapth-1, config:config)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension Book : FactalsStatus {								///Book or ///Tests01, ...
	func ppControlElement(deapth:Int=999, config:Bool) -> String {  "oops"
//		let myLine				= "(\(count.asString!.field(4)) tests)"
//		return ppFactalsStateHelper("\(self.fileName.field(-13))", nameTag:self, myLine:myLine, deapth:deapth-1)
	}
}

extension PartBase : FactalsStatus	{								 ///PartBase
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("PartBase     ", nameTag:self,
			myLine: "tree:\(tree.pp(.tagClass)) "		 			+
					"(\(portCount()) Ports) " 						+
					"lock=\(semiphore.value ?? -98) " 				+
					(curOwner==nil ? "UNOWNED," : "OWNER:'\(curOwner!)',") +
					" dirty:'\(tree.dirty.pp())' "			,
			deapth:deapth-1)
	}																			//bug; return "extension Parts : FwStatus needs HELP"	}
}
extension Simulator : FactalsStatus	{								///Simulator
 	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		var rv					= factalsModel == nil 	? "(factalsModel==nil) "
								: factalsModel!.simulator === self ? ""
								:						  "OWNER:'\(factalsModel!)' BAD "
		for _ in 0...0 {
			rv 					+= simBuilt ? "simBuilt," : "no simulator"
			guard simBuilt 		else {	break									}
			rv					+= simRun ? " simRun" : " simHalt"
			rv					+= ", timeNow:\(timeNow)"
			rv					+= " going:\(globalDagDirUp ? "up " : "down ")"
			rv					+= ", timeStep:\(timeStep)"
			rv					+= !simTaskRunning ? " taskHalted" : " taskPeriod=\(String(simTaskPeriod)) "
		//	rv					+= isSettled() ? " simSETTLED=" : " Run Sim="
		//	rv					+= " \(portChits)/Ports,"
		//	//rv				+= " [" + unPorts.map({hash in hash() }).joined(separator:",") + "]"
		//	rv					+= " \(linkChits)/Links,"
		//	rv					+= " \(startChits)/start"
		}
		return ppFactalsStateHelper("Simulator    ", nameTag:self, myLine:rv, deapth:deapth-1)
	}
}

extension VewBase : FactalsStatus	{								  ///VewBase
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
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
			otherLines: { deapth in
				var rv			=  self.scnBase   .ppControlElement(deapth:deapth-1, config:config)
				rv				+= self.selfiePole.ppControlElement(deapth:deapth-1, config:config)
				rv 				+= self.cameraScn?.ppControlElement(deapth:deapth-1, config:config)
									?? "\t\t\t\t cameraScn is nil\n"
				for vew in self.inspectedVews {
					rv 			+= vew	   		  .ppControlElement(deapth:0, config:config)
				}
				return rv
			},
			deapth:deapth-1)
	}
}

extension Vew : FactalsStatus	{										  ///Vew
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		var rv					= ""
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self,
			myLine:"'\(fullName)'",
			otherLines: { deapth in
				for child in self.children {
					rv			+= child.ppControlElement(deapth:deapth-1, config:config)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension SelfiePole : FactalsStatus	{							///SelfiePole
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", nameTag:self,
			myLine:myLine,
			deapth:deapth-1)
	}
}
extension Inspec : FactalsStatus	{									///Inspec
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", nameTag:self,
			myLine:myLine,
			deapth:deapth-1)
	}
}

extension ScnBase : FactalsStatus	{						  ///ScnBase
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		var myLine				= vewBase?.scnBase === self ? "" : "OWNER:'\(vewBase!)' is BAD"
		myLine					+= "tree:\(roots?.rootNode.pp(.tagClass) ?? "<nil>")=rootNode "
		myLine					+= "\(roots?				 .pp(.tagClass) ?? "<nil>") "			//classUid
		myLine					+= "scnView:\(	 scnView?.pp(.tagClass) ?? "<nil>") "			//classUid
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self, myLine:myLine,
//			otherLines: { deapth in
//				return self.tree!   .ppControlElement(deapth:deapth-1)
//					+ (self.scnView?.ppControlElement(deapth:deapth-1) ?? "")
//			},
			deapth:deapth-1)
	}
}
extension SCNScene : FactalsStatus {								 ///SCNScene
	func ppControlElement(deapth:Int, config:Bool) -> String {
		let myLine				= rootNode.name == "rootNode" ? "" : "rootNode.name=\(rootNode .name ?? "?") -- BAD!!"
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self,
			myLine:myLine,
			otherLines: { deapth in
				return self.rootNode    .ppControlElement(deapth:deapth-1, config:config)
					+  self.physicsWorld.ppControlElement(deapth:deapth-1, config:config)
					+  self.lightingEnvironment.ppControlElement(deapth:deapth-1, config:config)
					+  self.background  .ppControlElement(deapth:deapth-1, config:config)
 			},
			deapth:deapth-1)
	}
}
extension SCNNode : FactalsStatus	{								  ///SCNNode
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		var myLine				= "'\(fullName)': \(children.count) children, (\(nodeCount()) SCNNodes) "
		myLine					+= camera == nil ? "" : "camera:\(camera!.pp(.classTag)) "
		myLine					+= light  == nil ? "" :  "light:\( light!.pp(.classTag)) "
		return ppFactalsStateHelper("SCNNode      ", nameTag:self,				//"SCNPhysicsWor"
			myLine:myLine,
			deapth:deapth-1)
	}
}
extension SCNPhysicsWorld : FactalsStatus	{					///SCNPhysicsWorld
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("SCNPhysicsWor", nameTag:self,
			myLine:fmt("gravity:\(gravity.pp(.phrase)), speed:%.4f, timeStep:%.4f", speed, timeStep),
			deapth:deapth-1)
	}
}
extension SCNMaterialProperty : FactalsStatus	{			  ///SCNMaterialProperty
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		// borderColor
		// contents
		// mappingChannel
		// minificationFilter	__C.SCNFilterMode
		//	magnificationFilter, mipFilter
		// wrapS. wrapS			__C.SCNWrapMode
		// textureComponents
		// intensity
		// maxAnisotropy		3.4028234663852886e+38
		return ppFactalsStateHelper("SCNMaterialPr", nameTag:self, myLine:"--", deapth:deapth-1)
	}
}
extension Log : FactalsStatus {											  ///Log
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		let msg					= !logEvents ? "disabled" :
			"Log \(logNo): \"\(name)\": entryNo:\(eventNumber), breakAtEvent:\(breakAtEvent) in:\(breakAtLogger), " +
			"verbosity:\(verbosity?.pp(.phrase) ?? "-"),"// + stk
		let logKind				= "log".field(-13)
//		let logKind				= (title[0...0] == "A" ? "APPlog" : "DOClog").field(-13)
		return ppFactalsStateHelper(logKind, nameTag:self, myLine:msg, deapth:deapth-1)
	}
}
//extension Sound : FactalsStatus {										///Sound
//	func ppControlElement(deapth:Int=999) -> String {
//		let msg					= ""
//		let logKind				= "sounds".field(-13)
//		return ppFactalsStateHelper(logKind, nameTag:self, myLine:msg, deapth:deapth-1)
//	}
//}
		// ///////////////////////////////////// //

extension NSWindowController : FactalsStatus {				///NSWindowController
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("\("NSWindowCtlr ")", nameTag:self,
			myLine:
				ppState() + (windowNibName == nil ? ";;" : ":\"\(windowNibName!)\" ") +
				ppUid(pre:"doc:",document as? NSDocument,post:" ",showNil:true) +
				ppUid(pre:"win:", 	 window,  			 post:" ",showNil:true) +
				ppUid(pre:"nibOwner:", owner as? Uid,	 post:" ",showNil:true) ,
			otherLines:{ deapth in
				return self.window?.ppControlElement(deapth:deapth-1, config:config) ?? ""
			},
			deapth:deapth-1)
	}
	func ppState() -> String {
		return
			windowNibName == nil ? 	 "nilNameNib" 	:
			window == nil ? 		"awaitingNib"	:
									  "loadedNib"
	}
}
extension NSWindow : FactalsStatus {								 ///NSWindow
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
								//
		let contract 			= trueF
		let log					= Log.ofApp
		return ppFactalsStateHelper("NSWindow     ", nameTag:self,
			myLine:
   			       "title:'\(title)' "											+
   			   "contentVC:\(ppUid(contentViewController, showNil:true)) "		+
			 "contentView:\(ppUid(contentView,  		 showNil:true)) "		+
				"delegate:\(ppUid(delegate as? String, 	 showNil:true)) \n"		+
			(!contract ? "" :
				" " + uidStrDashes(nilLike:self) + " " + log.indentString() + "\\ contentVew OMITTED\n"),
			otherLines:{ deapth in		//			uidStrDashes(nilLike
				return contract ? "" :
					 self.contentView?.ppControlElement(deapth:deapth-1, config:config) ?? ""
			},
			deapth:deapth-1)
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
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		let msg					= fwClassName.field(-13)
		return ppFactalsStateHelper(msg, nameTag:self,
			myLine:
				"\(subviews.count) children "									+
				"superv:\(superview?.pp(.classTag) ?? "nil") "					+
				   "win:\(window?   .pp(.classTag) ?? "nil") " 					,
//				"superv:\(ppUid(superview, showNil:true)) "						+
//				   "win:\(ppUid(window,    showNil:true)) " 					,
			otherLines:{ deapth in
				var rv			= ""
				if deapth > 0 {
	//				rv				+= self.subviews.map { $0.ppControlElement(deapth:deapth-1)			}
					for view in self.subviews {
						rv			+= view.ppControlElement(deapth:deapth-1, config:config)
					}
				}
				return rv
			},
			deapth:deapth-1)
	}
}

extension NSException : FactalsStatus	{						  ///NSException
	func ppControlElement(deapth:Int=999, config:Bool) -> String {
		return ppFactalsStateHelper("NSException  ", nameTag:self,
			myLine:"reason:'\(reason ?? "<nil>")'",
			deapth:deapth-1)
	}
}
