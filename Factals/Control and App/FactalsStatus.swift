// FwStatus.swift -- Extensions for 1-line description of all System Controllers ©200116PAK

import SceneKit

 /// Print status of Factal Workbench Controllers
protocol FactalsStatus : FwAny {
	func ppFactalsState(deapth:Int) -> String
}

  /// Print State of ALL System Controllers:
 /// - Returns: State of all Controllers, one per line
func ppFactalsState(deapth:Int=999/*, config:Bool=false*/) -> String {
	guard let APP else {	return "FactalsApp: No Application registered, APP==nil"}
	var rv						= APP	  .ppFactalsState(deapth:deapth-1)
bug
//	 // display current DOCument
//	let msg						= DOC == nil ? "(none selected)" : "(currently selected)"
//	rv							+= ppUid(pre:" ", DOC, post:" DOC \(msg)", showNil:true) + "\n"
//	rv							+= DOC?.ppFactalsState(deapth:deapth-1) ?? ""	// current DOCument
	return rv
}

func ppFactalsStateHelper(_ fwClassName_	: String,
						uid			: Uid,
						myLine		: String 			= "",
						otherLines	: ((Int)->String)?	= nil,
						deapth		: Int				//= 999
					) -> String
{
	var rv						= ppFwPrefix(uid:uid, fwClassName_) + myLine + "\n"
			// Other Lines:
	DOClog.nIndent				+= 1
	rv 							+= otherLines?(deapth) ?? ""
	DOClog.nIndent				-= 1
	return rv
}
 /// Prefix: "1e98 | | <fwClass>   0    . . . . . . . . "
func ppFwPrefix(uid:Uid?, _ fwClassName_:String) -> String {
	 // align uid printouts for ctl and part to 4 characters
	var rv						= ppUid(pre:" ", uid, showNil:true).field(-5) + " "
	rv 							+= DOClog.indentString()
	rv							+= fmt("%-12@", fwClassName_)
	rv							= DOClog.unIndent(rv)
	return rv
}

// //// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  /////
// /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  ///
// // /////  / /////  / /////  / ///// / /////   / /////  / /////  / /////  /
// / //// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  ///// /  /////
//  //// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  /// ///  ///
// //// /////  / /////  / /////  / ///// / /////   / /////  / /////  / /////  /

extension FactalsApp : FactalsStatus	{							///FactalsApp
//	func ppFwConfig() -> String {		config.pp(.short)						}
	func ppFactalsState(deapth:Int=999) -> String {
		let emptyEntry			= "? "//APP?.appConfig.string("emptyEntry") ?? "xr()"
		let regressScene		= "? "//APP?.config.int("regressScene") ?? -1
		return ppFactalsStateHelper("FactalsApp   ", uid:self,
			myLine:"regressScene:\(regressScene), " +
				"emptyEntry:'\(emptyEntry)' ",
//				"\(config.pp(.uidClass))=\(self.config.count)_elts",
			otherLines:{ deapth in
						// Menu Creation:
				var rv			= self.library.ppFactalsState(deapth:deapth-1)
				for lib in Library.libraryList {
					rv			+= lib     .ppFactalsState(deapth:deapth-1)
				}
				rv				+= self.log.ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth-1)
	}
}

// MARK: - DOCUMENT
extension FactalsDocument : FactalsStatus	{				  	 ///FactalsDocument
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("FactalsDocume", uid:self,
			myLine: factalsModel == nil ? "factalsModel is nil" : "",
			otherLines:{ deapth in
				guard let factalsModel else {	return ""						}
				var rv			= factalsModel.ppFactalsState(deapth:deapth-1)
				 // Inspectors:
				rv				+= "---- inspecWin4vew omitted -----"
//				if self.inspecWin4vew.count > 0 {
//					rv			+= DOClog.pidNindent(for:self) + "Inspectors:\n"	// deapth:\(deapth)
//					DOClog.nIndent += 1
//					for inspec in self.inspecWin4vew.keys {					//self.inspecWin4vew.forEach((key:Vew, win:NSWindow) -> Void) {
//						let win	= self.inspecWin4vew[inspec]
//						rv		+= win?.ppFactalsState(deapth:0/*, config:config*/) ?? "----"
//					}
//					DOClog.nIndent -= 1
//				}
				return rv
			},
			deapth:deapth
		)
	}
}
// MARK: - DOCUMENT
extension NSDocument : FactalsStatus	{							///NSDocument
	func ppFactalsState(deapth:Int=999) -> String {
bug; //never used?
		let wcc					= windowControllers.count
		return ppFactalsStateHelper("NSDocument   ", uid:self,
			myLine:"Has \(wcc) wc\(wcc != 1 ? "'s" : ""):   #ADD MORE HERE#",
			//	+ "wc0:\(   ppUid(windowController0, showNil:true)) "
			//	+ "w0:\(    ppUid(window0, 			 showNil:true)) ",
			//	+ "fwView:\(ppUid(fwView,		     showNil:true)) "
			//	+ "paramPrefix:'\(documentParamPrefix.pp())'"
			otherLines:{ deapth in
				var rv			= "truncated"//  self.rootPart.ppFactalsState(deapth:deapth-1) // Controller:
				 // Window Controllers
			//	for windowController in self.windowControllers {
			//		rv		+= windowController.ppFactalsState(deapth:deapth-1)
			//	}
				return rv
			},
			deapth:deapth)
	}
}
extension NSDocumentController : FactalsStatus {		 	 ///NSDocumentController
	func ppFactalsState(deapth:Int=999) -> String {
		let ct					= self.documents.count
		return ppFactalsStateHelper("DOCctlr      ", uid:self,
			myLine:"\(ct) FwDocument" + (ct != 1 ? "s:" : ":"),
			otherLines:{ deapth in
				var rv			= ""
				for document in self.documents {	//NSDocument
					rv			+= document.ppFactalsState(deapth:deapth-1)
				}
				return rv
			},
			deapth:deapth-1)
	}
}
extension Library : FactalsStatus {							///Library or ///Tests01, ...
	func ppFactalsState(deapth:Int=999) -> String {
		let myLine				= "(\(count.asString!.field(4)) tests)"
		return ppFactalsStateHelper("\(self.name.field(-13))", uid:self, myLine:myLine, deapth:deapth-1)
	}
}
extension FactalsModel : FactalsStatus	{
	///FactalsModel
	func ppFactalsState(deapth:Int=999) -> String {
		var myLine				= document.factalsModel === self ? "" : "OWNER:'\(document!)' BAD"
		myLine					+= "\(rootVews.count) RootVews "
		return ppFactalsStateHelper("FactalsModel ", uid:self,
			myLine:myLine,
			otherLines:{deapth in
				 // Controller:
				var rv			= self.rootPart.ppFactalsState(deapth:deapth-1)		//Actor
				rv				+= self.simulator.ppFactalsState(deapth:deapth-1)
				for rootVew in self.rootVews {
					rv			+= rootVew.ppFactalsState(deapth:deapth-1)
				}
				rv				+= self.log.ppFactalsState(deapth:deapth-1)
				rv				+= self.docSound.ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth-1)
	}
}
extension RootPart : FactalsStatus	{								 ///RootPart
	func ppFwConfig() -> String {		partConfig.pp(.line)					}
	func ppFactalsState(deapth:Int=999) -> String {
		let myLine				= ""//factalsModel.rootPartActor.rootPart === self ? "" : "OWNER:'\(factalsModel!)' BAD "
		let rown				= curOwner==nil ? "UNOWNED" : "OWNER:'\(curOwner!)'"
		return ppFactalsStateHelper("RootPart     ", uid:self,
			myLine:myLine + "rootPart:\(ppUid(self, showNil:true)) " +
					"(\(portCount()) Ports) " +
					"\(rown) dirty:'\(dirty.pp())' " ,
			deapth:deapth-1)
	}																			//bug; return "extension RootPart : FwStatus needs HELP"	}
}
extension Simulator : FactalsStatus	{								///Simulator
 	func ppFactalsState(deapth:Int=999) -> String {
		let showPre				= true//false//true//
		let showPost			= true//false//true//
		var rv					= factalsModel == nil 	? "(factalsModel==nil)"
								: factalsModel!.simulator === self ? ""
								:						  "OWNER:'\(factalsModel!)' BAD"
		for _ in 0...0 {
			if !simBuilt {
				rv 				+= "NOT BUILT, "
				if !showPost { break }
			}
			else if showPre {
				rv				+= "simBuilt, "
			}

			if !simEnabled {
				rv				+= "NOT ENABLED, "
				if !showPost { break }
			}
			else if showPre {
				rv				+= "simEnabled, "
			}

			rv					+= "t:\(timeNow) "
			rv					+= "going:\(globalDagDirUp ? "up " : "down ")"
			if let s		 	= factalsModel?.document.docConfig.double("simTaskPeriod") {
				rv				+= "simTaskPeriod=\(String(s)) "
			}
			rv					+= simTaskRunning ? "taskRun; " : "taskHalted; "
///
/// See FactalsModelBar.body
///
			rv					+= isSettled() ? "Sim SETTLED=" : "Run Sim="
			rv					+= "\(portChits)/Ports,"
			//rv				+= "[" + unPorts.map({hash in hash() }).joined(separator:",") + "] "
			rv					+= "\(linkChits)/Links,"
			rv					+= "\(startChits)/start"
		}
		return ppFactalsStateHelper("Simulator    ", uid:self, myLine:rv, deapth:deapth-1)
	}
}

extension RootVew : FactalsStatus	{								  ///RootVew
	func ppFactalsState(deapth:Int=999) -> String {
		guard let rootVew						 else {	return "Vew.rootVew == nil\n"}
		guard let factalsModel 		= rootVew.factalsModel else {	return "Vew.rootVew?.factalsModel == nil\n" }
		guard let slot			= rootVew.slot,
		  slot >= 0 && slot < factalsModel.rootVews.count else { fatalError("Bad slot")}
		let myName				= "RootVew      "

		var myLine				= "\(slot)/\(factalsModel.rootVews.count)] "
		myLine					+= "LockVal:\(semiphore.value ?? -99) "
		myLine					+= factalsModel.rootVews[slot] === self ? "" : "OWNER:'\(String(describing: factalsModel))' BAD "
		myLine					+= curOwner != nil ? "OWNER:\(curOwner!) " : "UNOWNED "
//		myLine					+= "cameraScn:\(cameraScn?.pp(.uid) ?? "nil") "
	//	myLine					+= "(\(nodeCount()) total) "
		myLine					+= "lookAtVew:\(lookAtVew?.pp(.classUid) ?? "nil") "
		myLine					+= self.rootScene.rootNode === self.scn ? "" :
								   "  ERROR .scn !== \(self.rootScene.rootNode.pp(.classUid))"
		return ppFactalsStateHelper(myName, uid:self,
			myLine:myLine,
			otherLines: { deapth in
				var rv			=  self.selfiePole.ppFactalsState(deapth:deapth-1)
				rv 				+= self.cameraScn?.ppFactalsState(deapth:deapth-1) ?? ""
				rv 				+= self.rootScene .ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth-1)
	}
}

extension RootScene : FactalsStatus	{						///RootScene,SCNScene
	func ppFactalsState(deapth:Int=999) -> String {
		var myLine				= rootVew?.rootScene === self ? "" : "OWNER:'\(rootVew!)' is BAD"
		myLine					+= "isPaused:\(isPaused) "
		return ppFactalsStateHelper(fwClassName.field(-13), uid:self,				//"RootScene      "
			myLine:myLine,
			otherLines: { deapth in
				var rv			=  self.rootNode    .ppFactalsState(deapth:deapth-1)
				rv				+= self.physicsWorld.ppFactalsState(deapth:deapth-1)
				return rv
			},
			deapth:deapth-1)
	}
}
extension SCNNode : FactalsStatus	{									///SCNNode
	func ppFactalsState(deapth:Int=999) -> String {
		var myLine				= "'\(fullName)': \(children.count) children, (\(nodeCount()) SCNNodes) "
		myLine					+= camera == nil ? "" : "camera:\(camera!.pp(.classUid)) "
		myLine					+= light  == nil ? "" :  "light:\( light!.pp(.classUid)) "
		return ppFactalsStateHelper("SCNNode      ", uid:self,				//"SCNPhysicsWor"
			myLine:myLine,
			deapth:deapth-1)
	}
}
extension SelfiePole : FactalsStatus	{							///SelfiePole
	func ppFactalsState(deapth:Int=999) -> String {
		let myLine				= self.pp(.line)
		return ppFactalsStateHelper("SelfiePole   ", uid:self,
			myLine:myLine,
			deapth:deapth-1)
	}
}
extension SCNPhysicsWorld : FactalsStatus	{					///SCNPhysicsWorld
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("SCNPhysicsWor", uid:self,
			myLine:fmt("gravity:\(gravity.pp(.phrase)), speed:%.4f, timeStep:%.4f", speed, timeStep),
			deapth:deapth-1)
	}
}
extension Log : FactalsStatus {											  ///Log
	func ppFwConfig() -> String {		""										}
	func ppFactalsState(deapth:Int=999) -> String {
		let msg					= !logEvents ? "disabled" :
			"Log \(logNo): \"\(title)\": entryNo:\(eventNumber), breakAtEvent:\(breakAtEvent) in:\(breakAtLogger), " +
			"verbosity:\(verbosity?.pp(.phrase) ?? "-"),"// + stk
		let logKind				= "log".field(-13)
//		let logKind				= (title[0...0] == "A" ? "APPlog" : "DOClog").field(-13)
		return ppFactalsStateHelper(logKind, uid:self, myLine:msg, deapth:deapth-1)
	}
}
extension Sounds : FactalsStatus {										///Sounds
	func ppFwConfig() -> String {		""										}
	func ppFactalsState(deapth:Int=999) -> String {
		let msg					= ""
		let logKind				= "sounds".field(-13)
		return ppFactalsStateHelper(logKind, uid:self, myLine:msg, deapth:deapth-1)
	}
}
		// ///////////////////////////////////// //

extension NSWindowController : FactalsStatus {				///NSWindowController
	func ppFactalsState(deapth:Int=999) -> String {
		return ppFactalsStateHelper("\("NSWindowCtlr ")", uid:self,
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
		return ppFactalsStateHelper("NSWindow     ", uid:self,
			myLine:
   			       "title:'\(title)' "											+
   			   "contentVC:\(ppUid(contentViewController, showNil:true)) "		+
			 "contentView:\(ppUid(contentView,  		 showNil:true)) "		+
				"delegate:\(ppUid(delegate as? String, 	 showNil:true)) \n"		+
			(!contract ? "" :
				" " + uidStrDashes(nilLike:self) + " " + DOClog.indentString() + "\\ contentVew OMITTED\n"),
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
//		return ppFactalsStateHelper("NSViewCtlr   ", uid:self,
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
		return ppFactalsStateHelper(msg, uid:self,
			myLine:
				"\(subviews.count) children "									+
				"superv:\(ppUid(superview, showNil:true)) "						+
				   "win:\(ppUid(window,    showNil:true)) " 					,
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
		return ppFactalsStateHelper("NSException  ", uid:self,
			myLine:"reason:'\(reason ?? "<nil>")'",
			deapth:deapth-1)
	}
}
