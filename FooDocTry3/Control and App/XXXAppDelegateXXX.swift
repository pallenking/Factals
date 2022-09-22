////
////  XXXAppDelegateXXX.swift
////  FooDocTry3
////
////  Created by Allen King on 9/15/22.
////
//
////  AppDelegate.swift -- for SwiftFactals  C2018PAK
//
//// Some of the Application base classes have nameing conflicts with SceneKit
////		base		twitteling		App's subclass		comment
////		Document	prepend Fw		FwDocument
//// There are 2 cases:
//// Case 1: base is the generic name.			  e.g: Document.
////				FW's subclass is "Fw" + basename. e.g: FwDocument
//// Case 2: base name starts with NS 	 e.g: NSDocumentController, or isn't generic:
////				FW's subclass strips NS. e.g: DocumentController
//
//import SceneKit
//  //let (majorVersion, minorVersion, nameVersion) = (4, 0, "xxx")				// 180127 FactalWrokbench UNRELEASED
//  //let (majorVersion, minorVersion, nameVersion) = (5, 0, "Swift Recode")
//	let (majorVersion, minorVersion, nameVersion) = (5, 1, "After a rest")		// 210710 Post
//
//var isRunningXcTests : Bool	= ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
//
////	Application Singletons:
//var APPDEL	 : AppDelegate? 		{	NSApp.delegate as? AppDelegate			}
//var APPLOG	 : Logger 					{	APPDEL?.log ?? Logger.null					}
//
//let DOCCTLR						= NSDocumentController.shared
//var DOC   	 : FwDocument!		// (Currently Active) App must insure continuity
//var DOCLOG   : Logger 					{	DOC?.rootPart?.log ?? Logger.null			}
//// A basic tutorial :http://sketchytech.blogspot.com/2016/09/taming-nsdocument-and-understanding.html
//
////@MainActor?
//@NSApplicationMain
//class AppDelegate: NSObject, NSApplicationDelegate {// UIResponder
//
//	 // MARK: - 2. Object Variables:
//	var log	: Logger				= Logger(params4appLog, title:"AppDelegate's Logger(params4appLog)")
//	var appStartTime  : String	= dateTime(format:"yyyy-MM-dd HH:mm:ss")
//	 // https://stackoverflow.com/questions/27500940/how-to-let-the-app-know-if-its-running-unit-tests-in-a-pure-swift-project
//
//	 // Keep regressScene up to date
//	var config4app : FwConfig	= [:] {
//		didSet {
//			if let rsn 			= config4app.int("regressScene") {
//				regressScene	= rsn
//			}
//		}
//	}
// //var config4appX : FwConfig {
// //	get			{	return config4app_ }
// //	set(val)	{
// //		config4app_			= val
// //		if let rsn 			= config4app_.int("regressScene") {
// //			regressScene	= rsn
// //		}
// //	}
// //};private var config4app_ : FwConfig = [:]
//
//	 // Keeps FwScene menue in sync with itself:
//	var regressScene : Int {				// number of next "^r" regression test
//		didSet {
//			sceneMenu?.item(at:0)?.title = "   Next scene: \(regressScene)"
//		}
//	}
//	//var regressScene : Int {				// number of next "^r" regression test
//	//	get			{	return regressScene_										}
//	//	set(v)	 	{
//	//		regressScene_ 		= v
//	//		sceneMenu?.item(at:0)?.title = "   Next scene: \(regressScene)"
//	//	}
//	//};private var regressScene_ = 0
//
//	 // MARK: - 2.2 Private variables used during menu generation: (TO_DO: make automatic variables)
//	var library 				= Library("AppsLib")
//
//	 // MARK: - 3. Factory
//	override init() {
//		atCon(1, print("\(isRunningXcTests ? "IS " : "Is NOT ") Running XcTests"))
//
//		super.init()	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//
//		 // Configure App with defaults:
//		config4app/*active*/	= params4app
//		atCon(3, {
//			print("AppDelegate(\(log.config4log.pp(.line).wrap(min: 13, cur:13, max: 100))), " +
//						  "verbosity:\(log.ppVerbosityOf(params4app).pp(.short))])")
//
//			   // 🇵🇷🇮🇳🔴😎💥🐼🐮🐥🎩 🙏🌈❤️🌻💥💦 τ_0 = "abc";  τ_0 += "!" é 김
//			  // ⌘:apple, ⏎:enter
//			 // Henry King and P. Allen King:
//			print("❤️ ❤️   ❤️ ❤️      ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️      ❤️ ❤️   ❤️ ❤️")
//			print("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ")
//		}() )
//		atCon(1,
//			print("\(appStartTime):🚘🚘🚘   Factal Workbench   🚘🚘🚘 -- Version \(majorVersion).\(minorVersion) (\(nameVersion))")
//		)
//		atCon(3, {
//			print("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ")
//			print("❤️ ❤️   ❤️ ❤️      ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️      ❤️ ❤️   ❤️ ❤️\n")
//			printFwcState()
//		}() )
//		NSApplication.shared.delegate = self		// Go Live in system!
//	}
//
//	  // App Will Finish Launching ///////////////////////////
//	 //
//	// MARK: 4.1 APP Launching
//	let appSounds				= Sounds()
//	func applicationWillFinishLaunching(_ notification:Notification) {
//		atCon(3, log("------------- AppDelegate.applicationWillFinishLaunching --------------"))
//
//		 // Load Sounds
//		appSounds.load(name:"aTest",		path:"BadName.wav")		// BAD, but no error
//		appSounds.load(name:"GameStarting", path:"SpawnGood.wav")
//		appSounds.load(name:"Oooooooo", 	path:"Oooooooo.m4a")
//		appSounds.load(name:"click1",		path:"Sounds/basicSamples/sqr220.wav")
//		appSounds.load(name:"tick1",		path:"Tick_SB.wav")
//		appSounds.load(name:"tock0",		path:"Tock_SB.wav")
//
//		 // Update Menues:
//		atCon(5, log("Build ^R Menu regressScene=(\(regressScene)) and FwScene Menus: "))
//		buildSceneMenus()
//
//		  // Set Apple Event Manager so FactalWorkbench will recieve URL's
//		 //     OS X recieves "factalWorkbench://a/b" --> activates network "a/b"
//		let appleEventManager = NSAppleEventManager.shared()  //AppleEventManager];
//		appleEventManager.setEventHandler(self,
//			andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)),
//			forEventClass:AEEventClass(kInternetEventClass), andEventID:AEEventID(kAEGetURL))
//	}
//	 // MARK: - 4.2 APP Enablers
//	 // Reactivates an already running application because
//	//    someone double-clicked it again or used the dock to activate it.
//	func applicationShouldHandleReopen(_ sender:NSApplication, hasVisibleWindows:Bool) -> Bool {
//		return !hasVisibleWindows// handle windows if none visible
////		return false			// Don't open any windows
//	}
//	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
//		return true 			// final, untested 210710PAK no workey
////		return false 			// conservative, must deal with no-FwDocument situation
//	}
//	 // MARK: - 4.3 APP Menu Bar Items
//	@IBOutlet weak 	var sceneMenu		:NSMenu!
//	@IBAction func appPreferences(_ sender: Any) {		// Show App preferences
//		print("'⌘,': AppDelegate.appPreferences(): PREF WINDOW UNDEF")
//	}													// why not use SwiftUI?
//	@IBAction func appState(_ sender: Any) {
//		print("'c': AppDelegate.appState():")
//		print(ppFwcState())
//	}
//	@IBAction func appConfiguration(_ sender: Any) {
//		print("'C': AppDelegate.appConfiguration():")
//		print(ppFwcConfig())
//	}
//	@IBAction func appHelp(_ sender: Any) {
//		print("'?': AppDelegate.appConfiguration():")
//		fwHelp("?")
//	}
//	 // MARK: - 4.4 FwScene Menu
//	// BUILD SCENE MENUS ////////////////////////////////
//	var menuOfPath : [String:NSMenu] = [:]			// [path : Menu]
//	func buildSceneMenus() {
//		if falseF { return } 						//trueF//falseF// for debugging
//		assert(sceneMenu != nil, "sceneMenu==nil, not filled in by IB (2)")
//
//
//		 // Get all known tests:
//		menuOfPath				= [:] 	// Hash of all experiments from HaveNWant:
//										// Sort by key:
//		var bogusLimit			= 500000//500000//10// adhoc debug limit on scenes
//
//		 // Get a catalog of available experiments
///**/	let lib0				= Library.catalog()  // "entry-1" is non-existant, with no rootClosure
//		 // Create Menu from Library lists.
//		let scanCatalog:[ScanElement] = lib0.state.scanCatalog//(tag:-1, title:"", subMenu:nil)
//		for elt in scanCatalog {
//			if bogusLimit <= 0 {	break 	}; bogusLimit -= 1
//			var menuTree:NSMenu = self.sceneMenu!
//
//			 // Insure NSMenuItem exist for all ancestors:
//			let tokens:[String.SubSequence] = elt.subMenu.split(separator:"/")
//			for i in 0..<tokens.count {		 // From full path to root:
//				assert(i == 0, "/ in sceneMenu, unsupported now")
//
//				 //  Check there are menus for Paths A, A/B, A/B/C, where A,B,C are nameTokens:
//				let path 		= String(tokens[0...i].joined(separator:"/"))
//				menuTree		= menuOfPath[path] ?? 	// exists
//								  addMenuEntry(forPath:path, tag:elt.tag, inMenu:menuTree)
//				menuOfPath[path] = menuTree // remember the nsMenuInTree:
//			}
//			 // Make new entry:
//			let menuItem		= NSMenuItem(title:elt.title,
//											 action:#selector(scheneAction(_:)),
//											 keyEquivalent:"")	//action:#selector(scheneAction(sender:)),
//			menuItem.tag 		= elt.tag// + 1
//			menuTree.addItem(menuItem)	// insert into base (currently)
//			atMen(9, log("Built tag:\(elt.tag)"))		// Build
//		}
//	}
//	func addMenuEntry(forPath path:String, tag:Int, inMenu:NSMenu) -> NSMenu {
//	 	 // Create a NEW MenuItem, with a Menu in it, for path:
//		let nsMenuItem = NSMenuItem(title:path, action:#selector(scheneAction(_:)), keyEquivalent:"")
//		inMenu.addItem(nsMenuItem)// insert into base (currently)
//
//		nsMenuItem.tag = tag + 1		// nsMenuInTree has tag of instigator (??? WHY
//		let rv					= NSMenu(title:path)
//		nsMenuItem.submenu		= rv
//		return rv						// menu has been created
//	}
//
//	 // From DocumentBasedApp:
//	func applicationDidFinishLaunching(_ aNotification: Notification) {
//
//		//coreDataStack.viewContext.automaticallyMergesChangesFromParent = true
//			//https://www.alfianlosari.com/posts/building-expense-tracker-ios-macos-app-with-coredata-cloudkit-syncing/
//
//		//MyDocumentController.init()
////		fwScene.scnRoot.showsStatistics = true	// (Banana.AAPLAppDelegate)
//
//		 // Add entry on system's menu bar: (DOESN'T WORK)
//		let systemMenuBar 		= NSStatusBar.system
//		let statusItem:NSStatusItem	= systemMenuBar.statusItem(withLength:NSStatusItem.variableLength)
//		if let sb : NSStatusBarButton = statusItem.button {	// aka NSButton
//			sb.title			= NSLocalizedString("#FW1#", tableName:"#FW2#", comment:"#FW3#")	// 'title' was deprecated in macOS 10.14: Use the receiver's button.title instead
//			sb.cell?.isHighlighted = true  										// 'highlightMode' was deprecated in macOS 10.14: Use the receiver's button.cell.highlightsBy instead
//		}
//
//		 // Logger program usage instances
//		logRunInfo("\(library.answer.ansTitle ?? "-no title-")")
//		atCon(7, printFwcState())
//		atCon(3, log("------------- AppDelegate: Application Did Finish Launching --------------\n"))
//		appSounds.play(sound:"GameStarting")
//	}
//
//	  // MARK: - 4.5 APP URL Processing
//	 // URL Event from OS
//	@objc func handleGetURLEvent(event:NSAppleEventDescriptor, withReplyEvent replyEvent:NSAppleEventDescriptor) {
//		let name           		= event.paramDescriptor(forKeyword:keyDirectObject)?.stringValue
//		openURL(named:name)
//	}
//	 // Common:
//	func openURL(named:String?) {
//		guard let name			= named,
//		  let url         		= NSURL(string:name) else {
//			fatalError(named == nil ? "named is nil" : "url(\(named!)) is nil")
//		}
//		print("openURL('\(named!)' -> \(url))")
//		var urlStr         		= name//url.absoluteString! //.stringByRemovingPercentEncoding
//		let prefix         		= "SwiftFactal://"		// "SwiftFactal""SwiftFactals"
//		assert(urlStr.lowercased().hasPrefix(prefix), "URL does not have prefix '\(prefix)'")
//		let index     			= urlStr.index(urlStr.startIndex, offsetBy:18)
//		urlStr      			= String(urlStr[index...])
//
//		 ////// BUILD Simulation Part per received URL.
//		//  if (Brain *brain = aBrain_selectedBy(-1, -1, urlStr)) {
//		//Build a window; install brain //  self.simNsWc = [self createASimNsWcFor:brain :"Selected by factalWorkbench:// URL"];
//	}
//	 // MARK: - 4.6 APP Terminate
//	func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
//		return .terminateNow													}
//	func applicationWillTerminate(_ 	 aNotification: Notification) {
//		print("xxxxx xxxxx xxxx applicationWillTerminate xxxxx xxxxx xxxx")
//		print("                   G O O D    B I E  ! !")
//	}
//
//	  // App Did Finish Launching //////////////////////
//	 //							 // 210710PAK NEVER CALLED
//	func applicationShouldTerminateAfterLastWindowClosed(theApplication:NSApplication) -> Bool	{
//		panic()
//		return true
//	}
//
//
//	 // MARK: - MENU / Next / Demo
//	@IBAction func scheneAction(_ sender:NSMenuItem) {
//		print("\n\n" + ("--- - - - - - - AppDelegate.sceneAction(\(sender.className)) tag:\(sender.tag) " +
//			  "regressScene:\(regressScene) - - - - - - - -").field(-80, dots: false) + "---")
//
//		 // Find scene number for Library lookup:
//		let sceneNumber			= sender.tag>=0 ? sender.tag// from menu
//											: regressScene	// from last time
//		regressScene			= sceneNumber + 1			// next regressScene
//
//		 // Make a new DOc	???
//		let doc					= try? FwDocument(fromLibrary_selectedBy:"entry\(sceneNumber)")
//		assert(doc != nil, "Failed to make FwDocument")
//		DOC						= doc!		// redundant
//
//		doc!.makeWindowControllers()
//		doc!.registerWithDocController()	// a new DOc must be registered
//	}
//
//	  ///  Write 1-line summary of this usage
//	func logRunInfo(_ comment:String) {
//		//return
//		 /// BUG: not allowed by sandbox
//		 // Gather Information for 1 line
//		let nextEntry		= wallTime("YYMMDD.HHMMSS: ") + comment + "\n"
//
//		guard let documentDirURL 	= try? FileManager.default.url(
//							for:.applicationDirectory,	// ~/Library/Containers/self.SwiftFactals/Data/Applications/
//			//				for:.documentDirectory,		// ~/Library/Containers/self.SwiftFactals/Data/Documents/
//			//				for:.desktopDirectory,		// ~/Library/Containers/self.SwiftFactals/Data/Desktop/
//			//				for:.userDirectory,			// unexpectedly raised: Foundation._GenericObjCError.nilError
//							in:.userDomainMask,
//							appropriateFor:nil,
//							create:true)
//		else {
//			print("logRunIfo FAILED: \"documentDirURL == nil\"")
//			return
//		}
//		let fileURL 			= documentDirURL.appendingPathComponent("logOfRuns")
//		do {
//			let fileUpdater		= try FileHandle(forUpdating:fileURL)
//
//			 // Write at EOF:
//			fileUpdater.seekToEndOfFile()
//			fileUpdater.write(nextEntry.data(using:.utf8)!)
//			fileUpdater.closeFile()
//		}
//		catch let errorCodeProtocol {
//			print("logRunIfo FAILED: \"\(errorCodeProtocol)\"")
//			// 20201225 Wouldn't create logOfRuns; must do manually
//		}
//	}
//
//	 // MARK: - 17. Debugging Aids
//	override var description	  : String 	{	return  "\"Application\""		}
//	override var debugDescription : String	{	return   "'Application'"		}
////			 var summary		  : String	{	return   "<Application>"		}
//
//	 // MARK: - 20. Logger
//	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
//		let msg					= String(format:format_, arguments:args)
//		log.log(banner:banner, msg, terminator:terminator)
//	}
//}
