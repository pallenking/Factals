// FwStatus.swift -- Extensions for 1-line description of all System Controllers ©200116PAK

import SceneKit

  /// Print State of ALL System Controllers in the App:
 /// - Returns: State of all Controllers, one per line
func ppFactalsState(deapth:Int=999/*, config:Bool=false*/) -> String {
	return FACTALSMODEL?.ppFactalsState(deapth:deapth-1) ?? ""
}

// DEBUG: insert ppFactalsState() in code

 /// Print status of Factal Workbench Controllers
protocol FactalsStatus : FwAny {
	func ppFactalsState(deapth:Int) -> String
}

func ppFactalsStateHelper(_ fwClassName_	: String,
						nameTag			: Uid,
						myLine		: String 			= "",
						otherLines	: ((Int)->String)?	= nil,
						deapth		: Int				//= 999
					) -> String
{
	let log						= Log.app
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
	let log						= Log.app
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
	func ppFactalsState(deapth:Int=999) -> String {
		let emptyEntry			= "? "//APP?.factalsConfig.string("emptyEntry") ?? "xr()"
		let regressScene		= "? "//APP?.config.int("regressScene") ?? -1
		return ppFactalsStateHelper("FactalsApp   ", nameTag:self,
			myLine:"regressScene:\(regressScene), " +
				"emptyEntry:'\(emptyEntry)' ",
//				"\(config.pp(.tagClass))=\(self.config.count)_elts",
			otherLines:{ deapth in
						// Menu Creation:
				var rv			= self.library.ppFactalsState(deapth:deapth-1)
				for book in Library.books {
					rv			+= book		  .ppFactalsState(deapth:deapth-1)
				}
				rv				+= self	  .log.ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth-1)
	}
}

// MARK : - DOCUMENT
extension FactalsDocument : FactalsStatus	{				  	 ///FactalsDocument
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("FactalsDocume", nameTag:self,
			myLine: factalsModel == nil ? "factalsModel is nil" : "",
			otherLines:{ deapth in
				guard let factalsModel else {	return ""						}
				var rv			= factalsModel.ppFactalsState(deapth:deapth-1)
				rv				+= self.log.ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth
		)
	}
}
// MARK  - DOCUMENT
//extension NSDocument : FactalsStatus	{							///NSDocument
//	func ppFactalsState(deapth:Int=999) -> String {
//bug; //never used?
//		let wcc					= windowControllers.count
//		return ppFactalsStateHelper("NSDocument   ", nameTag:self,
//			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""):   #ADD MORE HERE#",
//			//	+ "wc0:\(   ppUid(windowController0, showNil:true)) "
//			//	+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
//			//	+ "scnView:\(ppUid(scnView,		     showNil:true)) "
//			//	+ "paramPrefix:'\(documentParamPrefix.pp())'"
//			otherLines:{ deapth in
//				var rv			= "truncated"//  self.partBase.ppFactalsState(deapth:deapth-1) // Controller:
//				 // Window Controllers
//			//	for windowController in self.windowControllers {
//			//		rv		+= windowController.ppFactalsState(deapth:deapth-1)
//			//	}
//				return rv
//			},
//			deapth:deapth)
//	}
//}
//extension NSDocumentController : FactalsStatus {		  ///NSDocumentController
//	func ppFactalsState(deapth:Int=999) -> String {
//		let ct					= self.documents.count
//		return ppFactalsStateHelper("DOCctlr      ", nameTag:self,
//			myLine:"\(ct) FwDocument" + (ct != 1 ? "s:" : ":"),
//			otherLines:{ deapth in
//				var rv			= ""
//				for document in self.documents {	//NSDocument
//					rv			+= document.ppFactalsState(deapth:deapth-1)
//				}
//				return rv
//			},
//			deapth:deapth-1)
//	}
//}
extension Library : FactalsStatus {										///Library
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("\(self.fileName.field(-13))", nameTag:self,
			myLine:"(\(Library.books.count.asString!.field(4)) Books)",
			otherLines: { deapth in
				var rv			= ""
				for book in Library.books {
					rv			+= book.ppFactalsState(deapth:deapth-1)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension Book : FactalsStatus {								///Book or ///Tests01, ...
	func ppFactalsState(deapth:Int=999) -> String {
"oops"
//		let myLine				= "(\(count.asString!.field(4)) tests)"
//		return ppFactalsStateHelper("\(self.fileName.field(-13))", nameTag:self, myLine:myLine, deapth:deapth-1)
	}
}

extension FactalsModel : FactalsStatus	{							///FactalsModel
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("FactalsModel ", nameTag:self,
			myLine : "\(vewBases.count) vewBases ",
			otherLines:{deapth in

				 // Controller:
				var rv			= self.partBase  .ppFactalsState(deapth:deapth-1)
				rv				+= self.simulator.ppFactalsState(deapth:deapth-1)
				for vewBase in self.vewBases {
					rv			+= vewBase       .ppFactalsState(deapth:deapth-1)
				}
//				rv				+= self.docSound .ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth-1)
	}
}
extension PartBase : FactalsStatus	{								 ///PartBase
	func ppFactalsState(deapth:Int=999) -> String {
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
 	func ppFactalsState(deapth:Int=999) -> String {
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
	func ppFactalsState(deapth:Int=999) -> String {
		guard let factalsModel	else {	return "Vew.vews?.factalsModel == nil\n" }
		guard let slot			= slot, slot >= 0,
		   slot < factalsModel.vewBases.count
								else { 	return("Slot \(slot ?? -1)")			}
		guard factalsModel.vewBases[slot] === self else { return "\t\t\t\t vewBases[] mismatch\n" }
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
				var rv			=  self.scnBase.ppFactalsState(deapth:deapth-1)
				rv				+= self.selfiePole  .ppFactalsState(deapth:deapth-1)
				rv 				+= self.cameraScn?  .ppFactalsState(deapth:deapth-1)
									?? "\t\t\t\t cameraScn is nil\n"
				for vew in self.inspectedVews {
					rv 			+= vew	   			.ppFactalsState(deapth:0)
				}
				return rv
			},
			deapth:deapth-1)
	}
}

extension Vew : FactalsStatus	{										  ///Vew
	func ppFactalsState(deapth:Int=999) -> String {
		var rv					= ""
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self,
			myLine:"'\(fullName)'",
			otherLines: { deapth in
				for child in self.children {
					rv			+= child.ppFactalsState(deapth: deapth-1)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension SelfiePole : FactalsStatus	{							///SelfiePole
	func ppFactalsState(deapth:Int=999) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", nameTag:self,
			myLine:myLine,
			deapth:deapth-1)
	}
}
extension Inspec : FactalsStatus	{									///Inspec
	func ppFactalsState(deapth:Int=999) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", nameTag:self,
			myLine:myLine,
			deapth:deapth-1)
	}
}

extension ScnBase : FactalsStatus	{						  ///ScnBase
	func ppFactalsState(deapth:Int=999) -> String {
		var myLine				= vewBase?.scnBase === self ? "" : "OWNER:'\(vewBase!)' is BAD"
		myLine					+= "tree:\(roots?.rootNode.pp(.tagClass) ?? "<nil>")=rootNode "
		myLine					+= "\(roots?				 .pp(.tagClass) ?? "<nil>") "			//classUid
		myLine					+= "scnView:\(	 scnView?.pp(.tagClass) ?? "<nil>") "			//classUid
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self, myLine:myLine,
//			otherLines: { deapth in
//				return self.tree!   .ppFactalsState(deapth:deapth-1)
//					+ (self.scnView?.ppFactalsState(deapth:deapth-1) ?? "")
//			},
			deapth:deapth-1)
	}
}
extension SCNScene : FactalsStatus {								 ///SCNScene
	func ppFactalsState(deapth: Int) -> String {
		let myLine				= rootNode.name == "rootNode" ? "" : "rootNode.name=\(rootNode .name ?? "?") -- BAD!!"
		return ppFactalsStateHelper(fwClassName.field(-13), nameTag:self,
			myLine:myLine,
			otherLines: { deapth in
				return self.rootNode    .ppFactalsState(deapth:deapth-1)
					+  self.physicsWorld.ppFactalsState(deapth:deapth-1)
					+  self.lightingEnvironment.ppFactalsState(deapth:deapth-1)
					+  self.background  .ppFactalsState(deapth:deapth-1)
 			},
			deapth:deapth-1)
	}
}
extension SCNNode : FactalsStatus	{								  ///SCNNode
	func ppFactalsState(deapth:Int=999) -> String {
		var myLine				= "'\(fullName)': \(children.count) children, (\(nodeCount()) SCNNodes) "
		myLine					+= camera == nil ? "" : "camera:\(camera!.pp(.classTag)) "
		myLine					+= light  == nil ? "" :  "light:\( light!.pp(.classTag)) "
		return ppFactalsStateHelper("SCNNode      ", nameTag:self,				//"SCNPhysicsWor"
			myLine:myLine,
			deapth:deapth-1)
	}
}
extension SCNPhysicsWorld : FactalsStatus	{					///SCNPhysicsWorld
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("SCNPhysicsWor", nameTag:self,
			myLine:fmt("gravity:\(gravity.pp(.phrase)), speed:%.4f, timeStep:%.4f", speed, timeStep),
			deapth:deapth-1)
	}
}
extension SCNMaterialProperty : FactalsStatus	{			  ///SCNMaterialProperty
	func ppFactalsState(deapth:Int=999) -> String {
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
	func ppFactalsState(deapth:Int=999) -> String {
		let msg					= !logEvents ? "disabled" :
			"Log \(logNo): \"\(name)\": entryNo:\(eventNumber), breakAtEvent:\(breakAtEvent) in:\(breakAtLogger), " +
			"verbosity:\(verbosity?.pp(.phrase) ?? "-"),"// + stk
		let logKind				= "log".field(-13)
//		let logKind				= (title[0...0] == "A" ? "APPlog" : "DOClog").field(-13)
		return ppFactalsStateHelper(logKind, nameTag:self, myLine:msg, deapth:deapth-1)
	}
}
//extension Sound : FactalsStatus {										///Sound
//	func ppFactalsState(deapth:Int=999) -> String {
//		let msg					= ""
//		let logKind				= "sounds".field(-13)
//		return ppFactalsStateHelper(logKind, nameTag:self, myLine:msg, deapth:deapth-1)
//	}
//}
		// ///////////////////////////////////// //

extension NSWindowController : FactalsStatus {				///NSWindowController
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("\("NSWindowCtlr ")", nameTag:self,
			myLine:
				ppState() + (windowNibName == nil ? ";;" : ":\"\(windowNibName!)\" ") +
				ppUid(pre:"doc:",document as? NSDocument,post:" ",showNil:true) +
				ppUid(pre:"win:", 	 window,  			 post:" ",showNil:true) +
				ppUid(pre:"nibOwner:", owner as? Uid,	 post:" ",showNil:true) ,
			otherLines:{ deapth in
				return self.window?.ppFactalsState(deapth:deapth-1) ?? ""
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
	func ppFactalsState(deapth:Int=999) -> String {
								//
		let contract 			= trueF
		let log					= Log.app
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
					 self.contentView?.ppFactalsState(deapth:deapth-1) ?? ""
			},
			deapth:deapth-1)
	}
}
//extension NSViewController : FwStatus {						 ///NSViewController
//	func ppFactalsState(deapth:Int=999) -> String {
//bug;	let rob					= representedObject as? NSView		//FwStatus
//		return ppFactalsStateHelper("NSViewCtlr   ", nameTag:self,
//			myLine: ppState +
//				  " view:\(ppUid(view, 		showNil:true))" 					+
//				" repObj:\(ppUid(rob, 		showNil:true))" 					+	// ??
//			   " nibName:\(ppUid(nibName,	showNil:true))" 					+	// ??
//				 " title:\(ppUid(title,		showNil:true))"						,
//			otherLines:{ deapth in
//				return self.view.ppFactalsState(deapth:deapth-1)
//			},
//			deapth:deapth-1)
//	}
//	var ppState : String {
//		return  nibName == nil ? 		"Nib nil"	 	: "Nib loaded"
//	}
//}
extension NSView : FactalsStatus	{								   ///NSView
	func ppFactalsState(deapth:Int=999) -> String {
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
	//				rv				+= self.subviews.map { $0.ppFactalsState(deapth:deapth-1)			}
					for view in self.subviews {
						rv			+= view.ppFactalsState(deapth:deapth-1)
					}
				}
				return rv
			},
			deapth:deapth-1)
	}
}

extension NSException : FactalsStatus	{						  ///NSException
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("NSException  ", nameTag:self,
			myLine:"reason:'\(reason ?? "<nil>")'",
			deapth:deapth-1)
	}
}
