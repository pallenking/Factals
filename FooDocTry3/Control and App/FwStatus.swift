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
		 APP          .config4app:  \(w( APP	   .config4app		.pp(.line)	))
		 DOClog       .config4log:  \(w( DOClog	   .config4log		.pp(.line)	))
		 fwScene      .config4scene:\(w( DOCfwScene.config4scene	.pp(.line)	))
		 rootPart     .ansConfig:   \(w( DOCfwScene.rootPart.ansConfig.pp(.line)	))
		 simulator    .config4sim:  \(w( DOCfwScene.rootPart.simulator.config4sim.pp(.line) ))
		"""
}
func w(_ str:String) -> String {	return str.wrap(min:17, cur:28, max:80)		}

  /// Print State of ALL System Controllers:
 /// - Returns: State of all Controllers, one per line
func ppFwcState() -> String
{//Value of type 'FooDocTry3App' has no member 'ppFwState'
	var rv : String				 = APP?.ppFwState() ?? ""// APPlication DELegate
	rv							+= ppDOC()					// current DOCument
	rv							+= DOClog .ppFwState()		// DOClog
	rv							+= DOCctlr.ppFwState()		// nsDOCumentConTroLleR
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

 /// Print status of Factal Workbench Controllers
protocol FwStatus {
	func ppFwState(deapth:Int) -> String
}

extension FooDocTry3App : FwStatus	{							/// AppDelegate
	func ppFwState(deapth:Int=999) -> String {
		let emptyEntry			= APP?.config4app["emptyEntry"] ?? "xr()"
		return ppFwStateHelper("APP          ", uid:self,
			myLine:"regressScene:\(regressScene), " +
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
func ppDOC() -> String {									///
	//let m						= ppUid(DOC)
	let msg						= DOC == nil ? "(not selected)" : "(currently selected)"
	let uid : String			= ppUid(pre:" ", DOC as! Uid, post:"  DOC \(msg)", showNil:true)
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
extension Log : FwStatus {												/// Log
	func ppFwState(deapth:Int=999) -> String {
		let msg					= !logEvents ? "disabled" :
			"Log \(logNo): \"\(title)\": entryNo:\(entryNo), breakAt:\(breakAt), " +
			"verbosity:\(verbosity?.pp(.line) ?? "-"),"// + stk
		let logKind				= (title[0...0] == "A" ? "APPLOG" : "DOClog").field(-13)
		return ppFwStateHelper(logKind, uid:self, myLine:msg, deapth:deapth)
	}
}
// MARK: - DOCUMENT
extension NSDocument/*FwDocument*/ : FwStatus	{				 /// FwDocument
	func ppFwState(deapth:Int=999) -> String {
		let wcc					= windowControllers.count
		let cn					= (self is FooDocTry3Document) 	? "FooDocTry3Doc"
								: (self is NSDocument) 			? "NSDocument   "
							//	: (self is FwDocument) 			? "FwDocument   "
								:								"??Doc Kind??"
		return ppFwStateHelper(cn, uid:self,
			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""): ",
		//.		+ "wc0:\(   ppUid(windowController0, showNil:true)) "
		//.		+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
		//.		+ "fwView:\(ppUid(fwView,		     showNil:true)) "
		//.		+ "paramPrefix:'\(documentParamPrefix.pp())'",
			otherLines:{ deapth in
//
//				 // Controller:
//		//.		var rv			=  self.rootPart.ppFwState(deapth:deapth)
				var rv = ""

				 // Window Controllers
				for windowController in self.windowControllers {
					rv		+= windowController.ppFwState(deapth:deapth)
				}
//				var rv = ""
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
//extension FooDocTry3Document : FwStatus	{			  /// FooDocTry3Document, PlatformDocument_1
//	func ppFwState(deapth:Int) -> String {										// func ppFwState(deapth:Int=999) -> String {
//		return "------- NSDocument\n"
//	}
//}
extension FooDocTry3Document : FwStatus	{				  /// FooDocTry3Document
	func ppFwState(deapth:Int=999) -> String {
		let wcc					= 12345//windowControllers.count
		return ppFwStateHelper("FwDocument   ", uid:self,
			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""): "
				+ "wc0:\(   ppUid(windowController0, showNil:true)) "
				+ "w0:\(    ppUid(window0, 		   showNil:true)) ",
		//.		+ "fwView:\(ppUid(fwView,		       showNil:true)) "
		//.		+ "paramPrefix:'\(documentParamPrefix.pp())'",
			otherLines:{ deapth in

				 // Controller:
		//.		var rv			=  self.rootPart.ppFwState(deapth:deapth)

		//.		 // Window Controllers
		//.		for windowController in self.windowControllers {
		//.			rv		+= windowController.ppFwState(deapth:deapth)
		//.		}
				var rv = ""
				 // Inspectors:
				if self.inspecWin4vew.count > 0 {
					rv			+= DOClog.pidNindent(for:self) + "Inspectors:\n"	// deapth:\(deapth)
					DOClog.nIndent += 1
//					self.inspecWin4vew.forEach((key:Vew, win:NSWindow) -> Void) {
					for inspec in self.inspecWin4vew.keys {
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
extension RootPart : FwStatus	{								    /// RootPart
	func ppFwState(deapth:Int=999) -> String {
		let rown				= partTreeOwner==nil ? "UNOWNED" : "OWNER:'\(partTreeOwner!)'"
		return ppFwStateHelper("RootPart     ", uid:self,
			myLine:"\(rown) dirty:'\(dirty.pp())' " +
				   "partTrunk:\(ppUid(partTrunk, showNil:true)) ",
			otherLines:{ deapth in
				var rv			=  ""//self.simulator.ppFwState()
				rv				+= self.log.ppFwState()
				return rv
			},
			deapth:deapth)
	}
//bug; return "extension RootPart : FwStatus needs HELP"	}
}
extension Simulator : FwStatus	{								  /// Simulator
	func ppFwState(deapth:Int=999) -> String {
		var myLine 				= "not built "
		if simBuilt {
			myLine 				= "built, disabled"
			if simEnabled {
				myLine			= "enabled, going:\(globalDagDirUp ? "up " : "down ")"
				myLine			+= "t:\(timeNow) "///
				let x			= config4sim.double("simTaskPeriod")
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

extension Library : FwStatus {								/// Library or Tests01
	func ppFwState(deapth:Int=999) -> String {
		let myLine				= "(>X<)"
		return ppFwStateHelper("\(self.name.field(-13))", uid:self, myLine:myLine, deapth:deapth)
	}
}
extension FwScene : FwStatus	{									 /// FwScene
	func ppFwState(deapth:Int=999) -> String {
		var myLine				= "rootVew:\(ppUid(self.rootVew,  showNil:true)) "
		myLine					+= self.rootVewOwner != nil ? "OWNER:'\(self.rootVewOwner!)' " : "UNOWNED "
		myLine					+= "pole:w\(self.pole.convertPosition(.zero, to:rootScn).pp(.short)) "
		myLine					+= "animatePhysics:\(self.animatePhysics)(isPaused:\(self.scnScene.isPaused))"
		return ppFwStateHelper("FwScene      ", uid:self,
			myLine: myLine,
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

// MARK: - WINDOWS
//extension FwWindowController {
//	//Overriding non-@objc declarations from extensions is not supported:
//	//override func ppFwState() -> String {}
//}
extension NSWindowController : FwStatus {				  /// NSWindowController
	func ppFwState(deapth:Int=999) -> String {
		return ppFwStateHelper("\("NSWindowCtlr ")", uid:self,
			myLine:
				ppState() + (windowNibName == nil ? "," : ":\"\(windowNibName!)\" ") +
//?				ppUid(pre:"doc:",document as? FwDocument,post:" ",showNil:true) +
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
		return ppFwStateHelper("FwViewCtlr   ", uid:self,
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
