//
//  FactalsApp.swift
//  Factals
//
//  Created by Allen King on 5/18/22.
//	20220822PAK: Imported and Funged from:  AppDelegate.swift -- for SwiftFactals  C2018PAK
//

import Cocoa
import SwiftUI
import SceneKit


	let (majorVersion, minorVersion, nameVersion) = (6, 4, "Factals")		// 240210
  //let (majorVersion, minorVersion, nameVersion) = (6, 3, "Factals")		// 230603
  //let (majorVersion, minorVersion, nameVersion) = (6, 1, "Factals++")		// 220822
  //let (majorVersion, minorVersion, nameVersion) = (6, 0, "Factals re-App")// 220628
  //let (majorVersion, minorVersion, nameVersion) = (5, 1, "After a rest")	// 210710 Post
  //let (majorVersion, minorVersion, dnameVersion) = (5, 0, "Swift Recode")
  //let (majorVersion, minorVersion, nameVersion) = (4, 0, "xxx")			// 180127 FactalWorkbench UNRELEASED

// MARK: - Singleton
var FACTALSMODEL : FactalsModel?=nil

  // https://stackoverflow.com/questions/27500940/how-to-let-the-app-know-if-its-running-unit-tests-in-a-pure-swift-project
var isRunningXcTests : Bool	= ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

class AppGlobals : ObservableObject {
    @Published var appConfig : FwConfig
	init(appConfig g:FwConfig) {
		appConfig = g
	}
}


	//B: https://wwdcbysundell.com/2020/creating-document-based-apps-in-swiftui/
@main
extension FactalsApp : App {
	var body: some Scene {
		DocumentGroup(newDocument:FactalsDocument()) { file in
			ContentView(document: file.$document)
			 .environmentObject(appGlobals)				// inject in environment
			 .onOpenURL { url in
				// Load a document from the given URL
				let document = FactalsDocument(fileURL:url)
				openDocuments.append(document)
			 }
		}
		 .commands {
			CommandMenu("ScnNodes") {
				ForEach(sceneMenus) { item in
					Button {
						let libName = "entry\(item.id)"
						print("======== SceneMenu \(libName):")
bug//					document = FactalsDocument(fromLibrary:libName)
					} label: {
						Text(item.name + ":")
						Image(systemName: item.imageName)
					}
//					switch item {
//					case SceneMenuLeaf(let id, let name, let imageName):
//						Text(name)
//						Image(systemName: imageName)
//						Button {
//							document = FactalsDocument(fromLibrary:"entry\(id)")
//							print("Test")
//						} label: {
//							Text(name)
//							Image(systemName: imageName)
//						}
//					case SceneMenuCrux(let id, let name, let imageName):
//						Button {
//							document = FactalsDocument(fromLibrary:"entry\(id)")
//							print("Test")
//						} label: {
//							Text(name)
//							//Image(systemName: imageName)
//						}
//					}
				}
			}
		}
	}
}
struct FactalsApp: Uid, FwAny {
	var fwClassName: String		= "FactalsApp"
	var uid: UInt16				= randomUid()

	static var shared = FactalsApp() // Singleton instance

	@State private var document: FactalsDocument? = nil
	@State private var openDocuments: [FactalsDocument] = []

	var appConfig : FwConfig

    @StateObject var appGlobals	= AppGlobals(appConfig:params4pp)		// Instantiate appGlobals
	//B	@AppStorage("text") var textFooBar = ""

	 // MARK: - 2. Object Variables:
	var log	: Log				=	Log(title:"App's Log", params4all)
	var appStartTime:String = dateTime(format:"yyyy-MM-dd HH:mm:ss")

	 // Keeps FactalsModel menu in sync with itself:
	var regressScene : Int {				// number of next "^r" regression test
		get			{	return regressScene_										}
		set(v)	 	{
			regressScene_ 		= v
			sceneMenu?.item(at:0)?.title = "   Next scene: \(regressScene)"
		}
	};private var regressScene_ = 0
	var regressSceneXX:Int	= 0	//private?	// number of the next "^r" regression test

	 // MARK: - 2.2 Private variables used during menu generation: (TO_DO: make automatic variables)
	var library 				= Library("APP's Library")
	var appSounds				= Sounds()

	 // MARK: - 3. Factory
	init () {
		self.init(foo:true)
//		APP 					= self				// Register ( V E R Y  HOAKEY)
	}
	private init (foo:Bool) {
		appConfig				= params4all
//		APP 					= self				// Register  (HOAKEY)
		atApp(1, log("\(isRunningXcTests ? "IS " : "Is NOT ") Running XcTests"))

		 // Configure App with its defaults (Ahead of any documents)
//		APP 					= self				// Register ( V E R Y  HOAKEY)
		sceneMenus 				= buildSceneMenus()

		atApp(3, {
			log("FactalsApp(\(appConfig.pp(PpMode.line).wrap(min: 14, cur:25, max: 100))), ")
			log("verbosity:[\(log.ppVerbosityOf(appConfig).pp(.short))])")

			   // 🇵🇷🇮🇳🔴😎💥🐼🐮🐥🎩 🙏🌈❤️🌻💥💦 τ_0 = "abc";  τ_0 += "!" é 김
			  // ⌘:apple, ⏎:enter
			 // Henry King and P. Allen King:
			log("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️")
			log("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ")
		}() )
		atApp(1,
			log("\(appStartTime):🚘🚘   \(nameVersion) \(majorVersion).\(minorVersion)   🚘🚘 ----------------ττττ")
		)
		atApp(3, {
			log("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ")
			log("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️\n")
			// printFwState()	causes "X<> PROBLEM  'bld9' found log 'App's Log' busy doing 'app3'"
		}() )
	}


	// MARK: - 4.1 APP Launching
		//	20230627PAK: applicationWillFinishLaunching NOT CALLED
	//func uncalledFunction() {
	//	  // Set Apple Event Manager so FactalWorkbench will recieve URL's
	//	 //     OS X recieves "factalWorkbench://a/b" --> activates network "a/b"
	//	let appleEventManager = NSAppleEventManager.shared()  //AppleEventManager];
	//	//appleEventManager.setEventHandler(self,
	//	//	andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)),
	//	//	forEventClass:AEEventClass(kInternetEventClass), andEventID:AEEventID(kAEGetURL))
	//}
	 // MARK: - 4.2 APP Enablers
	 // Reactivates an already running application because
	//    someone double-clicked it again or used the dock to activate it.
//	func applicationShouldHandleReopen(_ sender:NSApplication, hasVisibleWindows:Bool) -> Bool {
//		return true
//		//return !hasVisibleWindows	// handle windows if none visible
//		//return false				// Don't open any windows
//	}
//	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
//		return true 				// final, untested 210710PAK no workey
//		//return false 				// conservative, must deal with no-FwDocument situation
//	}
	var sceneMenu:NSMenu!			//	@IBOutlet weak 	var sceneMenu		:NSMenu!

	func appPreferences(_ sender: Any) {		// Show App preferences
		print("'⌘,': AppDelegate.appPreferences(): PREF WINDOW UNDEF")
	}													// why not use SwiftUI?
	func appState(_ sender: Any) {
		print("'c': AppDelegate.appState():")
		print(ppFactalsState())
	}
	func appHelp(_ sender: Any) {
		print("'?': AppDelegate.appConfiguration():")
		fwHelp("?", inVew:nil)
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
bug		//  if (Brain *brain = aBrain_selectedBy(-1, -1, urlStr)) {
		//Build a window; install brain //  self.simNsWc = [self createASimNsWcFor:brain :"Selected by factalWorkbench:// URL"];
	}


	 // MARK: - 4.6 APP Terminate
	 // From DocumentBasedApp:
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		bug
//		 // Add entry on system's menu bar: (DOESN'T WORK)
//		let systemMenuBar 		= NSStatusBar.system
//		let statusItem:NSStatusItem	= systemMenuBar.statusItem(withLength:NSStatusItem.variableLength)
//		if let sb : NSStatusBarButton = statusItem.button {	// aka NSButton
//			sb.title			= NSLocalizedString("#FW1#", tableName:"#FW2#", comment:"#FW3#")	// 'title' was deprecated in macOS 10.14: Use the receiver's button.title instead
//			sb.cell?.isHighlighted = true  										// 'highlightMode' was deprecated in macOS 10.14: Use the receiver's button.cell.highlightsBy instead
//		}
//
//		 // Log program usage instances
//		logRunInfo("\(library.answer.ansTitle ?? "-no title-")")
//		atApp(7, printFwState())
////.		atApp(3, log("------------- AppDelegate: Application Did Finish Launching --------------\n"))
//		appSounds.play(sound:"GameStarting")
	}

	func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
bug;	return .terminateNow													}
	func applicationWillTerminate(_ 	 aNotification: Notification) {
bug;	print("xxxxx xxxxx xxxx applicationWillTerminate xxxxx xxxxx xxxx")
		print("                   G O O D    B I E  ! !")
	}

	  // App Did Finish Launching //////////////////////
	 //							 // 210710PAK Never CALLED
	func applicationShouldTerminateAfterLastWindowClosed(theApplication:NSApplication) -> Bool	{
		panic()
		return true
	}

	 // MARK: - 4.7 Make Scene Menu
	struct SceneMenuElement : Identifiable {
		let id: Int
		let name: String
		let imageName: String
//		let action: (String) -> Void
	}
	var sceneMenus: [SceneMenuElement] = []		//getMenuItems()	//=//NSMenuItem //	[	SceneMenuElement(id: 1, name: "Option 1", imageName: "1.circle", action: { print("Option 1 selected") }),

	struct SceneMenuLeaf : Identifiable {
		let id: Int
		let name: String
		let imageName: String? = nil
	}
	struct SceneMenuCrux : Identifiable {
		let id: Int
		let name: String
		let imageName: String? = nil		//"1.circle"
	}
//	typealias SceneMenuElement = SceneMenuLeaf
	enum SceneMenuElementX : Identifiable {
		case SceneMenuLeaf(Int, String, String?)
		case SceneMenuCrux(Int, String, String?)

		var id: Int {
			switch self {
			case .SceneMenuLeaf(let i, _, _), .SceneMenuCrux(let i, _, _):		// .SceneMenuLeaf or SceneMenuLeaf
				return i
			}
		}
		//var id : Int { 0 }//{ //
	}
								//struct MyStruct1: Identifiable {	// TRIAL CODE
								//	let id: Int64
								//	let name:String															}
								//struct MyStruct2: Identifiable {
								//	let id: Int64
								//	let value:Double														}
								//enum MyEnum: Identifiable {
								//	case case1(MyStruct1)
								//	case case2(MyStruct2)
								//	var id: Int64 {
								//		switch self {
								//		case .case1(let struct1):
								//			return struct1.id
								//		case .case2(let struct2):
								//			return struct2.id
								//		}
								//	}
								//}
								//	struct MenuItem : Identifiable {
								//		let id: Int
								//		let name: String
								//		let imageName: String
								//		let action: () -> Void
								//	}
								//	let menuItems = [
								//		MenuItem(id: 1, name: "Option 1", imageName: "1.circle", action: { print("Option 1 selected") }),
								//		MenuItem(id: 2, name: "Option 2", imageName: "2.circle", action: { print("Option 2 selected") }),
								//	]
	func buildSceneMenus() -> [SceneMenuElement] {
		var bogusLimit			= 30000//10//5//10// adhoc debug limit on scenes
		var menuOfPath : [String:SceneMenuElement] = [:]		// [path : MenuItem]
		if falseF { return [] } 						//trueF//falseF// for debugging

		 // Get a catalog of available experiments
/**/	let lib0				= Library.catalog()
//		let scanElements:[ScanElement] = lib0.state.scanElements
		let scanCatalog:[ScanElement] = lib0.state.scanCatalog//(tag:-1, title:"", subMenu:nil)
		
	//	return scanCatalog[0..<bogusLimit].map { element in
	//		.init(id: element.tag,
	//		name: element.title,
	//		imageName:"star")							//"1.circle")
	//	}
		var rv : [SceneMenuElement]	= []
		for scanElement in scanCatalog[0..<min(bogusLimit, scanCatalog.count)] {						// return scanElements[0..<bogusLimit].map { scanElement in
//			var menuTree		= self.sceneMenu!

			 // Insure a SceneMenuElement exist for all ancestors:
			let tokens:[String.SubSequence] = scanElement.subMenu.split(separator:"/")
			for i in 0..<tokens.count {			 //  Check there are menus for Paths A, A/B, A/B/C
				let path 		= String(tokens[0...i].joined(separator:"/"))
				if menuOfPath[path] == nil {
					let newMenuEntry = SceneMenuElement(id:-rv.count, name:String(tokens[i]), imageName:"1.circle")
					//let newMenuEntry = SceneMenuElement(id:-rv.count, name:String(tokens[i]))
					menuOfPath[path] = newMenuEntry
					rv.append(newMenuEntry)
				}
			}
			rv.append(SceneMenuElement(id:scanElement.tag, name:scanElement.title, imageName:"star"))
		}
		return rv
		 // now have [ScanElement]
//		for elt in scanElements {
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
//			 // Make new menu entry:
//			// let menuItem		= NSMenuItem(title:elt.title,
//			// 								 action:#selector(scheneAction(_:)),
//			// 								 keyEquivalent:"")	//action:#selector(scheneAction(sender:)),
//			// menuItem.tag 	= elt.tag// + 1
//			// menuTree.addItem(menuItem)	// insert into base (currently)
//			atMen(9, log("Built tag:\(elt.tag)"))		// Build
//		}
//		return []
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

	 // MARK: Access Scene MENU
	mutating func scheneAction(_ sender:NSMenuItem) {
bug
		print("\n\n" + ("--- - - - - - - AppDelegate.sceneAction(\(sender.className)) tag:\(sender.tag) " +
			  "regressScene:\(regressScene) - - - - - - - -").field(-80, dots: false) + "---")

		 // Find scene number for Library lookup:
		let sceneNumber			= sender.tag>=0 ? sender.tag// from menu //.tag was .id
											: regressScene	// from last time
		regressScene			= sceneNumber + 1			// next regressScene
		let scanKey				= "entry\(regressScene)"

		bug
//		if (trueF) {		 	// Make new window:
//			let x = FactalsDocument()//fmConfig:scanKey) // who holds onto this
//		}
//		else {			 		// Install new parts in current window
//			guard let doc = DOC else { fatalError("no DOC")}
//			guard let factalsModel = doc.factalsModel else {	return	}
//
//			let parts		= Parts(fromLibrary:scanKey)
//			factalsModel.setRootPart(parts:parts)
//
//			 // Make a default window
//			factalsModel.addRootVew(vewConfig:.openAllChildren(toDeapth:5), fwConfig: ["oops":"help"])
//	
//			 // --------------- C: FactalsDocument
//bug;			let c				= /*doc.config +*/ parts.ansConfig
//			factalsModel.configure(from:c)
//			//newRootVew.configure(from: ?FwConfig)
//			//let newDoc		= FactalsDocument(fromLibrary:"entry\(regressScene)")
//			factalsModel.document = doc
//			doc.makeWindowControllers()
//			doc.registerWithDocController()	// a new DOc must be registered
//		}
	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = [:]) -> String	{
		switch mode {
		case .tree:
			return ""
		default:
			return ppStopGap(mode, aux)		// NO, try default method
		}
	}

	 // MARK: - 17. Debugging Aids
	var description	  	 : String 	{	return  "d'FactalsApp'"					}
	var debugDescription : String	{	return "dd'FactalsApp'"					}
	var summary			 : String	{	return  "s'FactalsApp'"					}

	 // MARK: - 20. Log
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
