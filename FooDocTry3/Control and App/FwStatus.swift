// FwStatus.swift -- Extensions for 1-line description of all System Controllers ©200116PAK

import SceneKit

 // External Global interface (misc, lldb)
func printFwcConfig() {		print(ppFwcConfig())								}
func printFwcState()  {		print(ppFwcState())									}

  /// Print System Components' Configuration:
 /// - Returns: Configuration of all Controllers, one per line
func ppFwcConfig() -> String {
	return """
		CONFIGURATIONS:
		 APP.config:  \(w( APP.config.pp(.line)	))
		 DOC.config:  \(w( DOC.config.pp(.line)	))
		"""
//	return """
//		CONFIGURATIONS:
//		 APP          .config4app:  \(w( APP	   .config4app		.pp(.line)	))
//		 DOClog       .config4log:  \(w( DOClog	   .config4log		.pp(.line)	))
//		 fwGuts       .config4fwGuts:\(w(DOCfwGuts .config4fwGuts	.pp(.line)	))
//		 rootPart     .ansConfig:   \(w( DOCfwGuts.rootPart.ansConfig.pp(.line)	))
//		 simulator    .config4sim:  \(w( DOCfwGuts.rootPart.simulator.config4sim.pp(.line) ))
//		"""
}
private func w(_ str:String) -> String {	return str.wrap(min:17, cur:28, max:80)}

  /// Print State of ALL System Controllers:
 /// - Returns: State of all Controllers, one per line
func ppFwcState() -> String
{
	guard let APP else {	return "FooDocTry3App: APP==nil, No Application registered"}
	var rv : String				 = APP    .ppFwState()
	rv							+= ppDOC()					// current DOCument
	if DOC != nil {
	//	rv						+= DOC    .ppFwState()		// current DOCument
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

extension FooDocTry3App : FwStatus	{						  /// FooDocTry3App
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
					rv			+= lib					.ppFwState(deapth:deapth)
				}
				rv				+= self.log.ppFwState()
			return rv
			},
			deapth:deapth)
	}
}
extension Library : FwStatus {								/// Library or Tests01
	func ppFwState(deapth:Int=999) -> String {
		let myLine				= "(>X<)"
		return ppFwStateHelper("\(self.name.field(-13))", uid:self, myLine:myLine, deapth:deapth)
	}
}
func ppDOC() -> String {									///
	//let m						= ppUid(DOC)
	let msg						= DOC == nil ? "(not selected)" : "(currently selected)"
	let uid : String			= ppUid(pre:" ", DOC, post:"  DOC \(msg)", showNil:true)
	return uid + "\n"
//	return ppUid(pre:" ", DOC, post:"  DOC \(msg)", showNil:true) + "\n"
}

extension NSDocumentController : FwStatus {		 		 /// NSDocumentController
	func ppFwState(deapth:Int=999) -> String {
		let ct					= self.documents.count
		return ppFwStateHelper("DOCctlr      ", uid:self,
			myLine:"\(ct) FwDocument" + (ct != 1 ? "s:" : ":"),
			otherLines:{ deapth in
				var rv			= ""
				for document in self.documents {	//NSDocument
					rv			+= document.ppFwState(deapth:deapth)
					if let doc	= document as? FooDocTry3Document { //FwDocument {
						//Cast from 'NSDocument' to unrelated type 'FooDocTry3Document' always fails
						rv		+= doc.ppFwState(deapth:deapth)
					}
				}
				return rv
			},
			deapth:deapth)
	}
}
extension Logger : FwStatus {												/// Logger
	func ppFwState(deapth:Int=999) -> String {
		let msg					= !logEvents ? "disabled" :
			"Logger \(logNo): \"\(title)\": entryNo:\(entryNo), breakAt:\(breakAt), " +
			"verbosity:\(verbosity?.pp(.line) ?? "-"),"// + stk
		let logKind				= (title[0...0] == "A" ? "APPLOG" : "DOClog").field(-13)
		return ppFwStateHelper(logKind, uid:self, myLine:msg, deapth:deapth)
	}
}
// MARK: - DOCUMENT
extension FooDocTry3Document : FwStatus	{				 /// FooDocTry3Document
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("FooDocTry3Doc", uid:self,
			myLine:" \(fwGuts.pp(.classUid)) redo:\(redo)",
			otherLines:{ deapth in
				var rv			= fwGuts.ppFwState(deapth:deapth)
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
extension NSDocument/*FwDocument*/ : FwStatus	{				 /// FwDocument
	func ppFwState(deapth:Int=999) -> String {
	let wcc					= windowControllers.count
		return ppFwStateHelper("NSDocument   ", uid:self,
			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""):   #ADD MORE HERE#",
			//	+ "wc0:\(   ppUid(windowController0, showNil:true)) "
			//	+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
			//	+ "fwView:\(ppUid(fwView,		     showNil:true)) "
			//	+ "paramPrefix:'\(documentParamPrefix.pp())'"
			otherLines:{ deapth in
				var rv			= ""//  self.rootPart.ppFwState(deapth:deapth) // Controller:
				 // Window Controllers
				for windowController in self.windowControllers {
					rv		+= windowController.ppFwState(deapth:deapth)
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
extension FwGuts : FwStatus	{									 /// FwGuts
	func ppFwState(deapth:Int=999) -> String {
		var myLine				= ""
//		myLine					+= rootPart    	.pp(.classUid) + " "
		myLine					+= fwScn       	.pp(.classUid) + " "
		myLine					+= rootVew     	.pp(.classUid) + " "
		myLine					+= eventCentral	.pp(.classUid) + " "
		myLine					+= document		.pp(.classUid)

		return ppFwStateHelper("FwGuts       ", uid:self,
			myLine: myLine,
			otherLines:{deapth in
				 // Controller:
				var rv			= ""
				for i in 0...self.fwScn.count {
					rv			=  self.fwScn[i]!  .ppFwState(deapth:deapth)
					rv			+= self.rootVew[i]!.ppFwState(deapth:deapth)
				}
				rv				+= self.logger.ppFwState()
				return rv
			},
			deapth:deapth)
	}
}
extension RootPart : FwStatus	{								    /// RootPart
	func ppFwState(deapth:Int=999) -> String {
		let rown				= partTreeOwner==nil ? "UNOWNED" : "OWNER:'\(partTreeOwner!)'"
		return ppFwStateHelper("RootPart     ", uid:self,
			myLine:"\(rown) dirty:'\(dirty.pp())' " +
				   "partTrunk:\(ppUid(partTrunk, showNil:true)) ",
//			otherLines:{ deapth in
//				var rv			=  ""//self.simulator.ppFwState()
//				rv				+= self.log.ppFwState()
//				return rv
//			},
			deapth:deapth)
	}																			//bug; return "extension RootPart : FwStatus needs HELP"	}
}
extension Simulator : FwStatus	{								  /// Simulator
	func ppFwState(deapth:Int=999) -> String {
		var myLine 				= "not built "
		if simBuilt {
			myLine 				= "built, disabled"
			if simEnabled {
				myLine			= "enabled, going:\(globalDagDirUp ? "up " : "down ")"
				myLine			+= "t:\(timeNow) "///
				let x			= rootPart?.fwGuts.document.config.double("simTaskPeriod")
				myLine			+= "dt=\(x != nil ? String(x!) : "nil") "
				myLine			+= "\(simTaskRunning ? "" : "no_")" + "taskRunning "
				if isSettled() {
					myLine		+= "SETTLED "
				}else{
					myLine		+= "RUNNING("
					if let unPorts = rootPart?.unsettledPorts(),
					  unPorts.count > 0 {
						myLine	+= "unsettled Ports:["
						myLine	+= unPorts.map({hash in hash() }).joined(separator:",")				//.joined(separator:"/")
						myLine	+= "]"
					}
//					let nPortsUn = DOC.rootPart.unsettledPorts().count
//					myLine 		+= nPortsUn 	  <= 0 ? "" : "Ports:\(nPortsUn) "
					myLine		+= unsettledOwned <= 0 ? "" : "Links:\(unsettledOwned) "
					myLine		+= kickstart	  <= 0 ? "" : "kickstart:\(kickstart) "
					if myLine.hasSuffix(" ") {
						myLine	= String(myLine.dropLast())
					}
					myLine		+= ") "
				}
				myLine			+= kickstart <= 0 ? "" : "kickstart:\(kickstart) "
			}
		}
		return ppFwStateHelper("Simulator    ", uid:self, myLine:myLine, deapth:deapth)
	}
}

extension RootVew : FwStatus	{									 /// RootVew
	func ppFwState(deapth:Int=999) -> String {
		var myLine				= "rootVew:\(ppUid(self.trunkVew,  showNil:true)) "
		myLine					+= self.rootVewOwner != nil ? "OWNER:'\(self.rootVewOwner!)' " : "UNOWNED "
		myLine					+= "pole:w[OPS]"//\(self.fwScn.convertPosition(.zero, to:rootScn).pp(.short)) "
		myLine					+= "animatePhysics:\(self.fwGuts.fwScn[0]!.animatePhysics)(isPaused:\(self.fwGuts.fwScn[0]!.scnScene.isPaused))"
		return ppFwStateHelper("RootVew     ", uid:self,
			myLine:myLine,
			deapth:deapth)
	}
}
extension FwScn : FwStatus	{										   /// FwScn
	func ppFwState(deapth:Int=999) -> String {
//var fwGuts	 : FwGuts!		= nil
//var scnView	 : SCNView!		= nil
		var myLine				= fwGuts != nil ? "fwGuts==nil " : ""
		myLine					=  scnView?.pp(.classUid) ?? "" + " "
		myLine					+= scnScene.pp(.classUid) + " "
		myLine					+= "animatePhysics:\(self.animatePhysics)(isPaused:\(self.scnScene.isPaused))"
		return ppFwStateHelper("FwScn       ", uid:self,
			myLine:myLine,
			deapth:deapth)
	}
}
extension SCNScene : FwStatus	{									/// SCNScene
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("SCNScene     ", uid:self,
			otherLines:{ deapth in
				return self.physicsWorld.ppFwState(deapth:deapth)
			},
			deapth:deapth)
	}
}
extension SCNPhysicsWorld : FwStatus	{					 /// SCNPhysicsWorld
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("SCNPhysicsWor", uid:self,
			myLine:fmt(" gravity:\(gravity.pp(.line)), speed:%.4f, timeStep:%.4f", speed, timeStep),
			deapth:deapth)
	}
}
		// ///////////////////////////////////// //

extension NSWindowController : FwStatus {				  /// NSWindowController
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("\("NSWindowCtlr ")", uid:self,
			myLine:
				ppState() + (windowNibName == nil ? "," : ":\"\(windowNibName!)\" ") +
				ppUid(pre:"doc:",document as? NSDocument,post:" ",showNil:true) +
				ppUid(pre:"win:", 	 window,  			 post:" ",showNil:true) +
				ppUid(pre:"nibOwner:", owner as? Uid,	 post:" ",showNil:true) ,
			otherLines:{ deapth in
				return self.window?.ppFwState(deapth:deapth) ?? ""
			},
			deapth:deapth)
	}
	func ppState() -> String {
		return
			windowNibName == nil ? 	 "nilNameNib" 	:
			window == nil ? 		"awaitingNib"	:
									  "loadedNib"
	}
}
extension NSWindow : FwStatus {									   /// NSWindow
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("NSWindow     ", uid:self,
			myLine:
		//		"deapth:\(deapth) "												+
   			       "title:'\(title)' "											+
   			   "contentVC:\(ppUid(contentViewController, showNil:true)) "		+
			 "contentView:\(ppUid(contentView,  		 showNil:true)) "		+
				"delegate:\(ppUid(delegate as? String, 	 showNil:true)) " 		,
//			otherLines:{ deapth in		//			uidStrDashes(nilLike
//				return self.contentView?.ppFwState(deapth:deapth) ?? ""
//			},
			deapth:deapth)
	}
}
extension NSViewController : FwStatus {					  /// NSViewController
	func ppFwState(deapth:Int=999) -> String {
		let rob					= representedObject as? NSView//FwStatus
		return ppFwStateHelper("NSViewCtlr   ", uid:self,
			myLine: ppState +
				  " view:\(ppUid(view, 		showNil:true))" 					+
				" repObj:\(ppUid(rob, 		showNil:true))" 					+
			   " nibName:\(ppUid(nibName,	showNil:true))" 					+
				 " title:\(ppUid(title,		showNil:true))"						,
			otherLines:{ deapth in
				return self.view.ppFwState(deapth:deapth)
			},
			deapth:deapth)
	}
	var ppState : String {
		return  nibName == nil ? 		"Nib nil"	 	: "Nib loaded"
	}
}
extension NSView : FwStatus	{								 		 /// NSView
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
			deapth:deapth)
	}
}
extension NSException : FwStatus	{							 /// NSException
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("NSException  ", uid:self,
			myLine:"reason:'\(reason ?? "<nil>")'",
			deapth:deapth)
	}
}
