// FwStatus.swift -- Extensions for 1-line description of all System Controllers ©200116PAK

import SceneKit

 // External Global interface (misc, lldb)
func printFwcConfig() {		print(ppFwcConfig())								}
func printFwcState()  {
	DOClog.ppIndentCols = 20		// sort of permanent!
	print(ppFwcState())
}

  /// Print System Components' Configuration:
 /// - Returns: Configuration of all Controllers, one per line
func ppFwcConfig() -> String {
	return """
		CONFIGURATIONS:
		 APP.config:  \(w( APP.config.pp(.line)	))
		 DOC.config:  \(w( DOC.config.pp(.line)	))
		 params4aux:  \(w( params4aux.pp(.line) ))
		"""
}
private func w(_ str:String) -> String {	return str.wrap(min:17, cur:28, max:80)}

  /// Print State of ALL System Controllers:
 /// - Returns: State of all Controllers, one per line
func ppFwcState() -> String
{	guard let APP else {	return "FooDocTry3App: APP==nil, No Application registered"}
	var rv : String				 = APP    .ppFwState()
	rv							+= ppDOC()					// current DOCument
	if DOC != nil {
		rv						+= DOC    .ppFwState()		// current DOCument
		rv						+= DOClog .ppFwState()		// DOClog
		rv						+= DOCctlr.ppFwState()		// nsDOCumentConTroLleR
	}
	return rv
}
func ppFwStateHelper(_ fwClassName_	: String,
						uid			: Uid,
						myLine		: String 		= "",
						otherLines	: ((Int)->String)?	= nil,
						deapth		: Int			//= 999
					) -> String
{			// My Lines:
	var rv						= ppFwPrefix(uid:uid, fwClassName_) + myLine + "\n"
			// Other Lines:
	DOClog.nIndent				+= 1
	rv 							+= otherLines?(deapth) ?? ""
	DOClog.nIndent				-= 1
	return rv
}
func ppFwPrefix(uid:Uid?, _ fwClassName_:String) -> String {
	 // align uid printouts for ctl and part to 4 characters
	var rv						= ppUid(pre:" ", uid, showNil:true).field(-5) + " "
	rv 							+= DOClog.indentString()
	rv							+= fmt("%-12@", fwClassName_)
	return DOClog.unIndent(rv)
}

// //// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  /////
// /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  ///
// // /////  / /////  / /////  / ///// / /////   / /////  / /////  / /////  /
// / //// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  /////
//  //// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  ///
// //// /////  / /////  / /////  / ///// / /////   / /////  / /////  / /////  /

 /// Print status of Factal Workbench Controllers
protocol FwStatus {
	func ppFwState(deapth:Int) -> String
}

extension FooDocTry3App : FwStatus	{						  ///FooDocTry3App
	func ppFwState(deapth:Int=999) -> String {
		let emptyEntry			= APP?.config["emptyEntry"] ?? "xr()"
		let regressScene		= APP?.config.int("regressScene") ?? -1
		return ppFwStateHelper("FooDocTry3App", uid:self,
			myLine:" regressScene:\(regressScene), " +
				"emptyEntry:'\(emptyEntry.asString ?? "<emptyEntry not String>")'",
			otherLines:{ deapth in
						// Menu Creation:
				var rv			= self.library.ppFwState()
				for lib in Library.libraryList {
					rv			+= lib					.ppFwState(deapth:deapth-1)
				}
				rv				+= self.log.ppFwState()
			return rv
			},
			deapth:deapth-1)
	}
}
extension Library : FwStatus {								///Library or ///Tests01
	func ppFwState(deapth:Int=999) -> String {
		let myLine				= "(>X<)"
		return ppFwStateHelper("\(self.name.field(-13))", uid:self, myLine:myLine, deapth:deapth-1)
	}
}
func ppDOC() -> String {									///
	let msg						= DOC == nil ? "(not selected)" : "(currently selected)"
	let uid : String			= ppUid(pre:" ", DOC, post:"  DOC \(msg)", showNil:true)
	return uid + "\n"
//	return ppUid(pre:" ", DOC, post:"  DOC \(msg)", showNil:true) + "\n"
}

extension NSDocumentController : FwStatus {		 		 ///NSDocumentController
	func ppFwState(deapth:Int=999) -> String {
		let ct					= self.documents.count
		return ppFwStateHelper("DOCctlr      ", uid:self,
			myLine:"\(ct) FwDocument" + (ct != 1 ? "s:" : ":"),
			otherLines:{ deapth in
				var rv			= ""
				for document in self.documents {	//NSDocument
					rv			+= document.ppFwState(deapth:deapth-1)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension Logger : FwStatus {											///Logger
	func ppFwState(deapth:Int=999) -> String {
		let msg					= !logEvents ? "disabled" :
			"Logger \(logNo): \"\(title)\": entryNo:\(entryNo), breakAt:\(breakAt), " +
			"verbosity:\(verbosity?.pp(.line) ?? "-"),"// + stk
		let logKind				= (title[0...0] == "A" ? "APPLOG" : "DOClog").field(-13)
		return ppFwStateHelper(logKind, uid:self, myLine:msg, deapth:deapth-1)
	}
}
// MARK: - DOCUMENT
extension FooDocTry3Document : FwStatus	{				   ///FooDocTry3Document
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("FooDocTry3Doc", uid:self,
			myLine:" \(fwGuts.pp(.classUid)) redo:\(redo)",
			otherLines:{ deapth in
				var rv			= fwGuts.ppFwState(deapth:deapth-1)
				 // Inspectors:
				if self.inspecWin4vew.count > 0 {
					rv			+= DOClog.pidNindent(for:self) + "Inspectors:\n"	// deapth:\(deapth)
					DOClog.nIndent += 1
					for inspec in self.inspecWin4vew.keys {					//self.inspecWin4vew.forEach((key:Vew, win:NSWindow) -> Void) {
						let win	= self.inspecWin4vew[inspec]
						rv		+= win?.ppFwState(deapth:0) ?? "----"
					}
					DOClog.nIndent -= 1
				}
				return rv
			},
			deapth:deapth
		)
	}
}
// MARK: - DOCUMENT
extension NSDocument/*FwDocument*/ : FwStatus	{				 ///FwDocument
	func ppFwState(deapth:Int=999) -> String {
	let wcc					= windowControllers.count
		return ppFwStateHelper("NSDocument   ", uid:self,
			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""):   #ADD MORE HERE#",
			//	+ "wc0:\(   ppUid(windowController0, showNil:true)) "
			//	+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
			//	+ "fwView:\(ppUid(fwView,		     showNil:true)) "
			//	+ "paramPrefix:'\(documentParamPrefix.pp())'"
			otherLines:{ deapth in
				var rv			= ""//  self.rootPart.ppFwState(deapth:deapth-1) // Controller:
				 // Window Controllers
				for windowController in self.windowControllers {
					rv		+= windowController.ppFwState(deapth:deapth-1)
				}
//				 // Inspectors:
//				if self.inspecWin4vew.count > 0 {
//					rv			+= DOClog.pidNindent(for:self) + "Inspectors:\n"	// deapth:\(deapth)
//					DOClog.nIndent += 1
////					self.inspecWin4vew.forEach((key:Vew, win:NSWindow) -> Void) {
//					for inspec in self.inspecWin4vew.keys {
//						let win	= self.inspecWin4vew[inspec]
//						rv		+= win?.ppFwState(deapth:0) ?? "----"
//					}
//					DOClog.nIndent -= 1
//				}
				return rv
			},
			deapth:deapth
		)
	}
}
extension FwGuts : FwStatus	{									 		///FwGuts
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("FwGuts       ", uid:self,
			myLine: document.fwGuts === self ? "" : "OWNER:'\(document!)' BAD",
			otherLines:{deapth in
				 // Controller:
				var rv			= ""
				rv				+= self.rootPart.ppFwState()
				for rootVew in self.rootVews {
					rv			+= rootVew.ppFwState(deapth:deapth-1)
				}
				rv				+= self.logger.ppFwState()
				return rv
			},
			deapth:deapth-1)
	}
}
extension RootPart : FwStatus	{									 ///RootPart
	func ppFwState(deapth:Int=999) -> String {
		let myLine				= fwGuts.rootPart === self ? "" : "OWNER:'\(fwGuts!)' BAD "
		let rown				= partTreeOwner==nil ? "UNOWNED" : "OWNER:'\(partTreeOwner!)'"
		return ppFwStateHelper("RootPart     ", uid:self,
			myLine:myLine + "partTrunk:\(ppUid(partTrunk, showNil:true)) " +
					"\(rown) dirty:'\(dirty.pp())' " ,
			otherLines:{ deapth in
				return self.simulator.ppFwState()
			},
			deapth:deapth-1)
	}																			//bug; return "extension RootPart : FwStatus needs HELP"	}
}
extension Simulator : FwStatus	{									///Simulator
	func ppFwState(deapth:Int=999) -> String {
		var myLine				= rootPart.simulator === self ? "" : "OWNER:'\(rootPart!)' BAD"
		if simBuilt {
			var myLine2 			= "built, disabled"
			if simEnabled {
				myLine2			= "enabled, going:\(globalDagDirUp ? "up " : "down ")"
				myLine2			+= "t:\(timeNow) "///
				let x			= rootPart?.fwGuts.document.config.double("simTaskPeriod")
				myLine2			+= "dt=\(x != nil ? String(x!) : "nil") "
				myLine2			+= "\(simTaskRunning ? "" : "no_")" + "taskRunning "
				if isSettled() {
					myLine2		+= "SETTLED "
				}else{
					myLine2		+= "RUNNING("
					if let unPorts = rootPart?.unsettledPorts(),
					  unPorts.count > 0 {
						myLine2	+= "unsettled Ports:["
						myLine2	+= unPorts.map({hash in hash() }).joined(separator:",")				//.joined(separator:"/")
						myLine2	+= "]"
					}
//					let nPortsUn = DOC.rootPart.unsettledPorts().count
//					myLine 		+= nPortsUn 	  <= 0 ? "" : "Ports:\(nPortsUn) "
					myLine2		+= unsettledOwned <= 0 ? "" : "Links:\(unsettledOwned) "
					myLine2		+= kickstart	  <= 0 ? "" : "kickstart:\(kickstart) "
					if myLine2.hasSuffix(" ") {
						myLine2	= String(myLine2.dropLast())
					}
					myLine2		+= ") "
				}
				myLine2			+= kickstart <= 0 ? "" : "kickstart:\(kickstart) "
			}
			myLine				+= myLine2
		}
		return ppFwStateHelper("Simulator    ", uid:self, myLine:myLine, deapth:deapth-1)
	}
}

extension RootVew : FwStatus	{									  ///RootVew
	func ppFwState(deapth:Int=999) -> String {
		let myI					= fwGuts.rootVews.firstIndex { $0 === self 		} ?? -1
		var myLine				= fwGuts.rootVews[myI] === self ? "" : "OWNER:'\(String(describing: fwGuts))' BAD "
		myLine					+= "trunkVew:\(ppUid(trunkVew,  showNil:true)) "
		myLine					+=  rootVewOwner != nil ? "OWNER:\(rootVewOwner!) " : "UNOWNED "
		myLine					+= "pole:\(lastSelfiePole.pp())-"
		myLine					+= "w[\(fwScn.scn.convertPosition(.zero, to:nil).pp(.short))] "
		let myName				= "RootVew \(myI)    "
		return ppFwStateHelper(myName, uid:self,
			myLine:myLine,
			otherLines: { deapth in
				var rv			=  self.fwScn		.ppFwState()
				rv				+= self.eventCentral.ppFwState()
				return rv
			},
			deapth:deapth-1)
	}
}

extension EventCentral : FwStatus	{							 ///EventCentral
	func ppFwState(deapth:Int=999) -> String {
		var myLine				= rootVew.eventCentral === self ? "" : "OWNER:'\(rootVew!)' BAD"
		return ppFwStateHelper("EventCentral ", uid:self,
			myLine:myLine,
			deapth:deapth-1)
	}
}

extension FwScn : FwStatus	{										    ///FwScn
	func ppFwState(deapth:Int=999) -> String {
//var fwGuts	 : FwGuts!		= nil
//var scnView	 : SCNView!		= nil
		var myLine				= rootVew.fwScn === self ? "" : "OWNER:'\(rootVew!)' BAD"
		myLine					+=  scnView?.pp(.classUid) ?? "" + " "
		myLine					+= scnScene.pp(.classUid) + " "
		myLine					+= "animatePhysics:\(animatePhysics)(isPaused:\(scnScene.isPaused))"
		return ppFwStateHelper("FwScn        ", uid:self,
			myLine:myLine,
			otherLines: { deapth in
				var rv			=  self.scnScene.ppFwState()
				rv				+= self.scnView?.ppFwState() ?? "#### fwScn.scnView is nil ####\n"
				return rv
			},
			deapth:deapth-1)
	}
}
extension SCNScene : FwStatus	{									 ///SCNScene
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("SCNScene     ", uid:self,
			otherLines:{ deapth in
				return self.physicsWorld.ppFwState(deapth:deapth-1)
			},
			deapth:deapth-1)
	}
}
extension SCNPhysicsWorld : FwStatus	{					  ///SCNPhysicsWorld
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("SCNPhysicsWor", uid:self,
			myLine:fmt(" gravity:\(gravity.pp(.line)), speed:%.4f, timeStep:%.4f", speed, timeStep),
			deapth:deapth-1)
	}
}
		// ///////////////////////////////////// //

extension NSWindowController : FwStatus {				  ///NSWindowController
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("\("NSWindowCtlr ")", uid:self,
			myLine:
				ppState() + (windowNibName == nil ? "," : ":\"\(windowNibName!)\" ") +
				ppUid(pre:"doc:",document as? NSDocument,post:" ",showNil:true) +
				ppUid(pre:"win:", 	 window,  			 post:" ",showNil:true) +
				ppUid(pre:"nibOwner:", owner as? Uid,	 post:" ",showNil:true) ,
			otherLines:{ deapth in
				return self.window?.ppFwState(deapth:deapth-1) ?? ""
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
extension NSWindow : FwStatus {										 ///NSWindow
	func ppFwState(deapth:Int=999) -> String {
								//
		let contract 			= trueF
		return ppFwStateHelper("NSWindow     ", uid:self,
			myLine:
   			       "title:'\(title)' "											+
   			   "contentVC:\(ppUid(contentViewController, showNil:true)) "		+
			 "contentView:\(ppUid(contentView,  		 showNil:true)) "		+
				"delegate:\(ppUid(delegate as? String, 	 showNil:true)) \n"		+
			(!contract ? "" :
				" " + uidStrDashes(nilLike:self) + "  " + DOClog.indentString() + "\\ contentVew OMITTED\n"),
			otherLines:{ deapth in		//			uidStrDashes(nilLike
				return contract ? "" :
					 self.contentView?.ppFwState(deapth:deapth-1) ?? ""
			},
			deapth:deapth-1)
	}
}
extension NSViewController : FwStatus {						 ///NSViewController
	func ppFwState(deapth:Int=999) -> String {
		let rob					= representedObject as? NSView//FwStatus
		return ppFwStateHelper("NSViewCtlr   ", uid:self,
			myLine: ppState +
				  " view:\(ppUid(view, 		showNil:true))" 					+
				" repObj:\(ppUid(rob, 		showNil:true))" 					+
			   " nibName:\(ppUid(nibName,	showNil:true))" 					+
				 " title:\(ppUid(title,		showNil:true))"						,
			otherLines:{ deapth in
				return self.view.ppFwState(deapth:deapth-1)
			},
			deapth:deapth-1)
	}
	var ppState : String {
		return  nibName == nil ? 		"Nib nil"	 	: "Nib loaded"
	}
}
extension NSView : FwStatus	{								 		  ///NSView
	func ppFwState(deapth:Int=999) -> String {
		let msg					= fwClassName.field(-13)
		return ppFwStateHelper(msg, uid:self,
			myLine:
				"\(subviews.count) children "									+
				"superview:\(ppUid(superview, showNil:true)) "					+
				   "window:\(ppUid(window,    showNil:true)) " 					+
				(self.needsDisplay ? "needsDisplay " : "noRedisplay ") 			,//+
			otherLines:{ deapth in
				var rv			= ""
				if deapth > 0 {
					for view in self.subviews {
						rv			+= view.ppFwState(deapth:deapth-1)
					}
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension NSException : FwStatus	{							 ///NSException
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("NSException  ", uid:self,
			myLine:"reason:'\(reason ?? "<nil>")'",
			deapth:deapth-1)
	}
}
