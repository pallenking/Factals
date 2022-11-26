//
//  FactalsApp.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//	20220822PAK: Imported and Funged from:  AppDelegate.swift -- for SwiftFactals  C2018PAK
//

	 // 	File Naming Notes:
	// Some of the Application-base classes have nameing conflicts with SceneKit
	//		base		twitteling		App's subclass		comment
	//		Document	prepend Fw		FwDocument
	// There are 2 cases:
	// Case 1: base is the generic name.			  e.g: Document.
	//				FW's subclass is "Fw" + basename. e.g: FwDocument
	// Case 2: base name starts with NS 	 e.g: NSDocumentController, or isn't generic:
	//				FW's subclass strips NS. e.g: DocumentController

// // https://stackoverflow.com/questions/27500940/how-to-let-the-app-know-if-its-running-unit-tests-in-a-pure-swift-project
//var isRunningXcTests : Bool	= ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
var zeroIndex = 0								// Used 37 times

// 20220926PAK: Occasionally (e.g. pp) can't get here. use global
let params4aux : FwConfig 	=	[:]//params4all_

import Cocoa
import SwiftUI
import SceneKit

var fooBar:Int = 42

  //let (majorVersion, minorVersion, nameVersion) = (4, 0, "xxx")			// 180127 FactalWorkbench UNRELEASED
  //let (majorVersion, minorVersion, nameVersion) = (5, 0, "Swift Recode")
  //let (majorVersion, minorVersion, nameVersion) = (5, 1, "After a rest")	// 210710 Post
  //let (majorVersion, minorVersion, nameVersion) = (6, 0, "Factals re-App")// 220628
  //let (majorVersion, minorVersion, nameVersion) = (6, 1, "Factals++")		// 220822
	let (majorVersion, minorVersion, nameVersion) = (6, 2, "Factals")		// 221024

////	Application Singletons:
var APP				: FactalsApp!		// NEVER CHANGES (after inz)

// * * *
var DOC				: FactalsDocument!	// CHANGES:	App must insure continuity) Right now: Punt!
// * * *

 // Shugar on DOC
var DOCfwGuts		: FwGuts	{	DOC?.fwGuts ?? {
	panic(""); return FwGuts()
} ()								}
var DOCfwGutsQ		: FwGuts?	{	DOC?.fwGuts			}	// optionality is needed			//  9

var DOCloggerQ  	: Logger? 	{	DOCfwGutsQ?.logger							}				//  2
var DOClogger  		: Logger 	{	DOCfwGutsQ?.logger ?? .help					}	//.first	// 50
let DOCctlr						= NSDocumentController.shared

@main										// calls AppDelegateFoo.swift
struct FactalsApp: App, Uid, FwAny {
//	let p4a						= params4all

	var uid: UInt16				= randomUid()
	var fwClassName: String		= "FactalsApp"
						//collections of data - view
						//	viewsModel at root view {
						//		data.bidirect
						//		properties
	//A	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	//B: https://wwdcbysundell.com/2020/creating-document-based-apps-in-swiftui/
	//B	@AppStorage("text") var textFooBar = ""

	var body: some Scene {
		DocumentGroup(newDocument: FactalsDocument()) { file in
			ContentView(document: file.$document)
		}
						// ORPHANS: PW_ need tutorial
						//B	WindowGroup {
						//B		TextEditor(text: $text).padding()
						//B	}
							 //	WindowGroup {	//https://stackoverflow.com/questions/65379307/swiftui-macos-nswindow-instance
							//		ContentView(document:file.$document)
							//		ListView()	.environmentObject(dataModel)
							//		Text("Hello, World!").padding()
							//	}
							 // Window modifiers from Zev.Helge:
							//		 .windowStyle(TitleBarWindowStyle())
							//		 .windowToolbarStyle(UnifiedWindowToolbarStyle())
							//		 .commands {
							//			TextFormattingCommands()
							//			SidebarCommands()
							//		//?	AboutCommands()
							//		//?	SparkleCommands()
							//		//?	ExampleSVGsMenu()
							//		 .handlesExternalEvents(matching: [])
							//		}
							//	}
							 // 20220913: This causes funnies
							//		Settings {
							//			//SettingsView(model: model) // Passed as an observed object.
							//		}
							//		// https://khorbushko.github.io/article/2021/04/25/window-group.html

	}
	 // MARK: - 2. Object Variables:
	var log	: Logger			=	{
		return Logger(title:"App's Logger", params4all)							}()

	var appStartTime  : String	= dateTime(format:"yyyy-MM-dd HH:mm:ss")
	var regressScene : Int = 0	//private?	// number of the next "^r" regression test
															 // Keeps FwGuts menue in sync with itself:
															//	var regressScene : Int {				// number of next "^r" regression test
															//		get			{	return regressScene_										}
															//		set(v)	 	{
															//			regressScene_ 		= v
															//			sceneMenu?.item(at:0)?.title = "   Next scene: \(regressScene)"
															//		}
															//	};private var regressScene_ = 0
	 // Keep regressScene up to date						//var config4app : FwConfig {
	var config : FwConfig		= [:]						//	get			{	return config4app_ }
	mutating func pushControllersConfig(to c:FwConfig) {		//	set(val)	{
		config					= c							//		config4app_			= val
		if let rsn 				= c.int("regressScene") {	//		if let rsn 			= config4app_.int("regressScene") {
			regressScene		= rsn						//			regressScene	= rsn
			sceneMenu?.item(at:0)?.title = "   Next scene: \(regressScene)"
		}													//		}
	}														//	}
															//};private var config4app_ : FwConfig = [:]
	 // MARK: - 2.2 Private variables used during menu generation: (TO_DO: make automatic variables)
	var library 				= Library("APP's Library")

	 // MARK: - 3. Factory

	init () {
		APP 					= self				// Register  (HOAKEY)
		let _					= Logger.help		// create here, ahead of action

		 // Configure App with defaults:
		let c					= config + params4all
		pushControllersConfig(to:c)
		
		//atCon(1, print("\(isRunningXcTests ? "IS " : "Is NOT ") Running XcTests"))
		
		atCon(3, {
			print("AppDelegate(\(c.pp(PpMode.line).wrap(min: 13, cur:13, max: 100))), " +
						  "verbosity:[\(log.ppVerbosityOf(c).pp(.short))])")

			   // 🇵🇷🇮🇳🔴😎💥🐼🐮🐥🎩 🙏🌈❤️🌻💥💦 τ_0 = "abc";  τ_0 += "!" é 김
			  // ⌘:apple, ⏎:enter
			 // Henry King and P. Allen King:
			print("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️")
			print("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ")
		}() )
		atCon(1,
			print("\(appStartTime):🚘🚘   Factals \(majorVersion).\(minorVersion) (\(nameVersion))  🚘🚘 ----------------ττττ")
		)
		atCon(3, {
			print("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ")
			print("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️\n")
			printFwcState()
		}() )
	}

	  // App Will Finish Launching ///////////////////////////
	 //
	// MARK: 4.1 APP Launching
	var appSounds				= Sounds()
	mutating func applicationWillFinishLaunching(_ notification:Notification) {
		atCon(3, log("------------- AppDelegate.applicationWillFinishLaunching --------------"))

		 // Load Sounds
		appSounds.load(name:"aTest",		path:"BadName.wav")		// BAD, but no error
		appSounds.load(name:"GameStarting", path:"SpawnGood.wav")
		appSounds.load(name:"Oooooooo", 	path:"Oooooooo.m4a")
		appSounds.load(name:"click1",		path:"Sounds/basicSamples/sqr220.wav")
		appSounds.load(name:"tick1",		path:"Tick_SB.wav")
		appSounds.load(name:"tock0",		path:"Tock_SB.wav")

		 // Update Menues:
		atCon(5, log("Build ^R Menu regressScene=(\(regressScene)) and FwGuts Menus: "))
		buildSceneMenus()

		 // but self is struct!
		//	  // Set Apple Event Manager so FactalWorkbench will recieve URL's
		//	 //     OS X recieves "factalWorkbench://a/b" --> activates network "a/b"
		//	let appleEventManager = NSAppleEventManager.shared()  //AppleEventManager];
		//	appleEventManager.setEventHandler(self,
		//		andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)),
		//		forEventClass:AEEventClass(kInternetEventClass), andEventID:AEEventID(kAEGetURL))
	}//

	 // MARK: - 4.2 APP Enablers
	 // Reactivates an already running application because
	//    someone double-clicked it again or used the dock to activate it.
	func applicationShouldHandleReopen(_ sender:NSApplication, hasVisibleWindows:Bool) -> Bool {
		return true
		//return !hasVisibleWindows	// handle windows if none visible
		//return false				// Don't open any windows
	}
	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
		return true 				// final, untested 210710PAK no workey
		//return false 				// conservative, must deal with no-FwDocument situation
	}
	 // MARK: - 4.3 APP Menu Bar Items
	weak var sceneMenu:NSMenu!		//	@IBOutlet weak 	var sceneMenu		:NSMenu!

	func appPreferences(_ sender: Any) {		// Show App preferences
		print("'⌘,': AppDelegate.appPreferences(): PREF WINDOW UNDEF")
	}													// why not use SwiftUI?
	func appState(_ sender: Any) {
		print("'c': AppDelegate.appState():")
		print(ppFwcState())
	}
	func appConfiguration(_ sender: Any) {
		print("'C': AppDelegate.appConfiguration():")
		print(ppFwcConfig())
	}
	func appHelp(_ sender: Any) {
		print("'?': AppDelegate.appConfiguration():")
		fwHelp("?")
	}
	 // MARK: - 4.4 FwGuts Menu
	// BUILD SCENE MENUS ////////////////////////////////
	var menuOfPath : [String:NSMenu] = [:]			// [path : Menu]
	mutating func buildSceneMenus() {
		if falseF { return } 						//trueF//falseF// for debugging
		assert(sceneMenu != nil, "sceneMenu==nil, not filled in by IB (2)")


		 // Get all known tests:
		menuOfPath				= [:] 	// Hash of all experiments from HaveNWant:	.removeAll()
										// Sort by key:
		var bogusLimit			= 500000//500000//10// adhoc debug limit on scenes

		 // Get a catalog of available experiments
/**/	let lib0				= Library.catalog()  // "entry-1" is non-existant, with no rootClosure
		 // Create Menu from Library lists.
		let scanCatalog:[ScanElement] = lib0.state.scanCatalog//(tag:-1, title:"", subMenu:nil)
		for elt in scanCatalog {
			if bogusLimit <= 0 {	break 	}; bogusLimit -= 1
			var menuTree:NSMenu = self.sceneMenu!

			 // Insure NSMenuItem exist for all ancestors:
			let tokens:[String.SubSequence] = elt.subMenu.split(separator:"/")
			for i in 0..<tokens.count {		 // From full path to root:
				assert(i == 0, "/ in sceneMenu, unsupported now")

				 //  Check there are menus for Paths A, A/B, A/B/C, where A,B,C are nameTokens:
				let path 		= String(tokens[0...i].joined(separator:"/"))
				menuTree		= menuOfPath[path] ?? 	// exists
								  addMenuEntry(forPath:path, tag:elt.tag, inMenu:menuTree)
				menuOfPath[path] = menuTree // remember the nsMenuInTree:
			}
			 // Make new menu entry:
			// let menuItem		= NSMenuItem(title:elt.title,
			// 								 action:#selector(scheneAction(_:)),
			// 								 keyEquivalent:"")	//action:#selector(scheneAction(sender:)),
			// menuItem.tag 		= elt.tag// + 1
			// menuTree.addItem(menuItem)	// insert into base (currently)
			atMen(9, log("Built tag:\(elt.tag)"))		// Build
		}
	}
	func addMenuEntry(forPath path:String, tag:Int, inMenu:NSMenu) -> NSMenu {
	 	 // Create a NEW MenuItem, with a Menu in it, for path:
//		let nsMenuItem = NSMenuItem(title:path, action:#selector(scheneAction(_:)), keyEquivalent:"")
//		inMenu.addItem(nsMenuItem)// insert into base (currently)
//
//		nsMenuItem.tag = tag + 1		// nsMenuInTree has tag of instigator (??? WHY
bug;	let rv					= NSMenu(title:path)
//		nsMenuItem.submenu		= rv
		return rv						// menu has been created
	}

	 // From DocumentBasedApp:
	func applicationDidFinishLaunching(_ aNotification: Notification) {

		 // Add entry on system's menu bar: (DOESN'T WORK)
		let systemMenuBar 		= NSStatusBar.system
		let statusItem:NSStatusItem	= systemMenuBar.statusItem(withLength:NSStatusItem.variableLength)
		if let sb : NSStatusBarButton = statusItem.button {	// aka NSButton
			sb.title			= NSLocalizedString("#FW1#", tableName:"#FW2#", comment:"#FW3#")	// 'title' was deprecated in macOS 10.14: Use the receiver's button.title instead
			sb.cell?.isHighlighted = true  										// 'highlightMode' was deprecated in macOS 10.14: Use the receiver's button.cell.highlightsBy instead
		}

		 // Logger program usage instances
		logRunInfo("\(library.answer.ansTitle ?? "-no title-")")
		atCon(7, printFwcState())
//.		atCon(3, log("------------- AppDelegate: Application Did Finish Launching --------------\n"))
		appSounds.play(sound:"GameStarting")
	}

	  // MARK: - 4.5 APP URL Processing
	 // URL Event from OS
	func handleGetURLEvent(event:NSAppleEventDescriptor, withReplyEvent replyEvent:NSAppleEventDescriptor) {
		let name           		= event.paramDescriptor(forKeyword:keyDirectObject)?.stringValue
		openURL(named:name)
	}
	 // Common:
	func openURL(named:String?) {
		guard let name			= named,
		  let url         		= NSURL(string:name) else {
			fatalError(named == nil ? "named is nil" : "url(\(named!)) is nil")
		}
		print("openURL('\(named!)' -> \(url))")
		var urlStr         		= name//url.absoluteString! //.stringByRemovingPercentEncoding
		let prefix         		= "SwiftFactal://"		// "SwiftFactal""SwiftFactals"
		assert(urlStr.lowercased().hasPrefix(prefix), "URL does not have prefix '\(prefix)'")
		let index     			= urlStr.index(urlStr.startIndex, offsetBy:18)
		urlStr      			= String(urlStr[index...])

		 ////// BUILD Simulation Part per received URL.
		//  if (Brain *brain = aBrain_selectedBy(-1, -1, urlStr)) {
		//Build a window; install brain //  self.simNsWc = [self createASimNsWcFor:brain :"Selected by factalWorkbench:// URL"];
	}
	 // MARK: - 4.6 APP Terminate
	func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
		return .terminateNow													}
	func applicationWillTerminate(_ 	 aNotification: Notification) {
		print("xxxxx xxxxx xxxx applicationWillTerminate xxxxx xxxxx xxxx")
		print("                   G O O D    B I E  ! !")
	}

	  // App Did Finish Launching //////////////////////
	 //							 // 210710PAK Never CALLED
	func applicationShouldTerminateAfterLastWindowClosed(theApplication:NSApplication) -> Bool	{
		panic()
		return true
	}


	 // MARK: - MENU / Next / Demo
	//. @IBAction
	mutating func scheneAction(_ sender:NSMenuItem) {
		print("\n\n" + ("--- - - - - - - AppDelegate.sceneAction(\(sender.className)) tag:\(sender.tag) " +
			  "regressScene:\(regressScene) - - - - - - - -").field(-80, dots: false) + "---")

		 // Find scene number for Library lookup:
		let sceneNumber			= sender.tag>=0 ? sender.tag// from menu
											: regressScene	// from last time
		regressScene			= sceneNumber + 1			// next regressScene

		 // Make new Document
		let rootPart			= RootPart(fromLibrary:"entry\(regressScene)")

		let fwGuts				= FwGuts(rootPart:rootPart)

bug		 // --------------- A: Get BASIC Component Part (owned and used here)
		let scnScene			= SCNScene()									//named:"art.scnassets/ship.scn") ?? SCNScene()
		scnScene.isPaused		= true						// Pause animations while bulding

		 // --------------- B: RootVew ((rootPart, A))
		let newRootVew			= RootVew(forPart:fwGuts.rootPart, scnScene:scnScene)
		let i					= fwGuts.rootVews.count - 1
		fwGuts.rootVews[i]		= newRootVew									//		fwGuts.rootVews.append(newRootVew)
		newRootVew.fwGuts		= fwGuts			// Set Owner
		
		var doc					= FactalsDocument(fwGuts:fwGuts)
		DOC						= doc		// register (UGLY!!!)
		doc.pushControllersConfig(to:doc.config + rootPart.ansConfig)

		rootPart.fwGuts			= fwGuts
		fwGuts.document 		= doc
		doc.makeWindowControllers()
		doc.registerWithDocController()	// a new DOc must be registered
	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
		switch mode {
		case .tree:
			return ""
		default:
			return ppDefault(self:self, mode:mode, aux:aux)
		}
//		return "FwGuts: scnTrunk:'\(scnRoot.name ?? "<unnamed>")',  trunkVew:'\(trunkVew?.name ?? "<unnamed>")'"
//		return "FwGuts: scnRoot=\(scnRoot.name ?? "<unnamed>")"
	}

	 // MARK: - 17. Debugging Aids
	var description	  	 : String 	{	return  "\"FactalsApp\""				}
	var debugDescription : String	{	return   "'FactalsApp'"				}
	var summary			 : String	{	return   "<FactalsApp>"				}

	 // MARK: - 20. Logger
	  ///  Write 1-line summary of this usage
	func logRunInfo(_ comment:String) {
		//return
		 /// BUG: not allowed by sandbox
		 // Gather Information for 1 line
		let nextEntry		= wallTime("YYMMDD.HHMMSS: ") + comment + "\n"

		guard let documentDirURL 	= try? FileManager.default.url(
							for:.applicationDirectory,	// ~/Library/Containers/self.SwiftFactals/Data/Applications/
			//				for:.documentDirectory,		// ~/Library/Containers/self.SwiftFactals/Data/Documents/
			//				for:.desktopDirectory,		// ~/Library/Containers/self.SwiftFactals/Data/Desktop/
			//				for:.userDirectory,			// unexpectedly raised: Foundation._GenericObjCError.nilError
							in:.userDomainMask,
							appropriateFor:nil,
							create:true)
		else {
			print("logRunIfo FAILED: \"documentDirURL == nil\"")
			return
		}
		let fileURL 			= documentDirURL.appendingPathComponent("logOfRuns")
		do {
			let fileUpdater		= try FileHandle(forUpdating:fileURL)

			 // Write at EOF:
			fileUpdater.seekToEndOfFile()
			fileUpdater.write(nextEntry.data(using:.utf8)!)
			fileUpdater.closeFile()
		}
		catch let errorCodeProtocol {
			print("logRunIfo FAILED: \"\(errorCodeProtocol)\"")
			// 20201225 Wouldn't create logOfRuns; must do manually
		}
	}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		let msg					= String(format:format_, arguments:args)
		log.log(banner:banner, msg, terminator:terminator)
	}
}