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


	 // MARK: - Version
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
//var isRunningXcTests : Bool	= ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

	//B: https://wwdcbysundell.com/2020/creating-document-based-apps-in-swiftui/

 // MARK: - SwiftUI
@main
extension FactalsApp : App {
//	@Environment(\.newDocument) private var newDocument		// Flock Extensions must not contain stored properties
	var body: some Scene {
		/*.retainIn($openDocuments)*/
		DocumentGroup(newDocument:FactalsDocument()) { file in
			ContentView(document: file.$document)
			 .environmentObject(factalsGlobals)	// inject in environment
			 .onOpenURL { url in					// Load a document from the given URL
				@Environment(\.newDocument) var newDocument
				newDocument(FactalsDocument(fileURL:url))
//				let _ = FactalsDocument(fileURL:url)/*.retainIn($openDocuments)*/
			 }
			 .onAppear { NSApplication.shared.windows.first?.title = file.document.factalsModel?.partBase.title ?? "<nil>" }
		}
		 .commands {
			CommandMenu("Library") {
				ForEach(factalsGlobals.libraryMenuTree.children) { crux in
					menuView(for:crux)
				}
			}
		}
	}
	 // MARK: - Generate Library Menu View (RECIRSIVE)
	func menuView(for crux:LibraryMenuTree) -> AnyView {
		if crux.children.count == 0 {				// Crux has nominal Button
			return AnyView(
				Button(crux.name) {
					@Environment(\.newDocument) var newDocument
					newDocument(FactalsDocument(fromLibrary:"entry\(crux.tag)"))
				}
			)
		}
		return AnyView(
			Menu(crux.name) {
				ForEach(crux.children) { crux in
					menuView(for:crux)					// ### RECURSIVE ###
				}
			} primaryAction: {
				print("lskjvowijhiv")
			}
		)
	}
}								//
 // MARK: - Globals
extension FactalsApp {		// FactalsGlobals
	class FactalsGlobals : ObservableObject {				// (not @Observable)
		// MARK: -A Configuration
		@Published var factalsConfig : FwConfig

		// MARK: -B Library Menu:
		var libraryMenuTree : LibraryMenuTree = LibraryMenuTree(name: "ROOT")
		init(factalsConfig a:FwConfig, libraryMenuArray lma:[LibraryMenuArray]?=nil) {
			factalsConfig 		= a
			let libraryMenuArray = lma ?? Library.catalog().state.scanCatalog
			let tree 			= LibraryMenuTree(array:libraryMenuArray)	 //LibraryMenuArray
			libraryMenuTree 	= tree
 		}
	}
}
class LibraryMenuTree : Identifiable {		// of a Tree
	let id						= UUID()
	let name: String
	var imageName: String? = nil
	var tag						= -1
	var children = [LibraryMenuTree]()
	init(name n:String, imageName i:String?=nil) {
		name 					= n
		imageName 				= i
		children 				= []
	}
	init(array entries:[LibraryMenuArray]) {
		name					= "ROOT"
		
		for entry in entries { //entries[0...100]//
			let path 			= entry.parentMenu
			guard path.prefix(1) != "-" else  { 	continue 	}	// Do not create library menu
			
			// Make (or find) in the tree  the crux of path
			var crux:LibraryMenuTree = self		// Slide crux from self(root) to spot to insert
			for name in path.split(separator:"/") {
				crux			= crux.children.first(where: {$0.name == name}) ?? {
					let newCrux	= LibraryMenuTree(name:String(name), imageName: "1.circle")
					crux.children.append(newCrux)
					return newCrux
				}()
			}
			
			 // Make new menu entry:
			let newCrux			= LibraryMenuTree(name:entry.title)
			newCrux.tag			= entry.tag
			crux.children.append(newCrux)
		}
	}
}
 // MARK: - FactalsApp base
struct FactalsApp: Uid, FwAny {
	var fwClassName: String		= "FactalsApp"
	var uid: UInt16				= randomUid()

	 // Source of Truth:
	@StateObject var factalsGlobals	= FactalsGlobals(factalsConfig:params4pp)//, libraryMenuArray:Library.catalog().state.scanCatalog)	// not @State

	 // MARK: - 2. Object Variables:
	var log	: Log				= Log.app//(name:"App's  Log", params4all)
	var appStartTime:String 	= dateTime(format:"yyyy-MM-dd HH:mm:ss")

	 // Keeps FactalsModel menu in sync with itself:
	var regressScene : Int {				// number of next "^r" regression test
		get			{	return regressScene_										}
		set(v)	 	{
			regressScene_ 		= v
			sceneMenu?.item(at:0)?.title = "   Next scene: \(regressScene)"
		}
	};private var regressScene_ = 0

	 // MARK: - 2.2 Private variables used during menu generation: (TO_DO: make automatic variables)
	var library 				= Library("APP's Library")
	var appSounds				= Sounds()

	 // MARK: - 3. Factory
	init () {
		self.init(foo:true)
	}
	private init (foo:Bool) {
		  // 🇵🇷🇮🇳🔴😎💥🐼🐮🐥🎩 🙏🌈❤️🌻💥💦 τ_0 = "abc";  τ_0 += "!" é 김 ⌘:apple, ⏎:enter
		 // Henry A. King and P. Allen King:
		let appConfig = params4pp
		atApp(3, log("FactalsApp(\(appConfig.pp(PpMode.line).wrap(min: 14, cur:25, max: 100))), "))
		atApp(3, log("verbosity:[\(log.ppVerbosityOf(appConfig).pp(.short))])"))
		atApp(3, log("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️"))
		atApp(3, log("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ"))
		atApp(1, log("\(appStartTime):🚘🚘   \(nameVersion) \(majorVersion).\(minorVersion)   🚘🚘 ----------------ττττ"))
		atApp(3, log("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ"))
		atApp(3, log("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️\n"))
		// printFwState()	causes "X<> PROBLEM  'bld9' found log 'App's Log' busy doing 'app3'"
		//atApp(1, log("\(isRunningXcTests ? "IS " : "Is NOT ") Running XcTests"))
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
	var sceneMenu:NSMenu!			// @IBOutlet weak 	var sceneMenu:NSMenu!

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

	 // MARK: Access Scene MENU
	mutating func scheneAction(_ sender:NSMenuItem) {
bug;	print("\n\n" + ("--- - - - - - - AppDelegate.sceneAction(\(sender.className)) tag:\(sender.tag) " +
			  "regressScene:\(regressScene) - - - - - - - -").field(-80, dots: false) + "---")
bug
		 // Find scene number for Library lookup:
		let sceneNumber			= sender.tag>=0 ? sender.tag// from menu //.tag was .id
											: regressScene	// from last time
		regressScene			= sceneNumber + 1			// next regressScene
		let scanKey				= "entry\(regressScene)"

		if (trueF) {		 	// Make new window:
			@Environment(\.newDocument) var newDocument
			newDocument(FactalsDocument(fromLibrary:scanKey))
//			let x = FactalsDocument()//fmConfig:scanKey) // who holds onto this
		}
//		else {			 		// Install new parts in current window
//			guard let doc = DOC else { fatalError("no DOC")}
//			guard let factalsModel = doc.factalsModel else {	return	}
//
//			let partBase		= Parts(fromLibrary:scanKey)
//			factalsModel.setRootPart(partBase:partBase)
//
//			 // Make a default window
//			factalsModel.anotherVewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig: ["oops":"help"])
//	
//			 // --------------- C: FactalsDocument
//bug;			let c				= /*doc.config +*/ partBase.ansConfig
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
			return ppFixedDefault(mode, aux)		// NO, try default method
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





//					switch item {	//default: nop
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




			//	if menu4Path[path] == nil {	// make NSMenu for path if none exists
			//		// Create a NEW MenuItem, with a Menu in it, for path:
			//		let newNsMenuItem = NSMenuItem(title:path,
			//									   action:nil,
			//									   keyEquivalent:""
			//		)
			//		newNsMenuItem.tag = catalog.tag + 1		// nsMenuInTree has tag of instigator (??? WHY
			//		newNsMenuItem.submenu = NSMenu(title:path)
	//**/	//		outNsMenu.addItem(newNsMenuItem)// insert into base (currently)
			//
			//		menu4Path[path] = outNsMenu // remember the nsMenuInTree:
			//	}

				// Make new menu entry:
//				let menuItem		= NSMenuItem(title:catalog.title,
//												 action:#selector(DummyApp.scheneAction(_:)),
//												 keyEquivalent:""
//				)	//action:#selector(scheneAction(sender:)),
//				menuItem.tag 		= catalog.tag// + 1
//				/**/		outNsMenu.addItem(menuItem)	// insert into base (currently)
//				
//				atMen(9, log("Built tag:\(catalog.tag)"))		// Build
