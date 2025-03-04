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
//import AVFoundation

	 // MARK: - Version
	let (majorVersion, minorVersion, nameVersion) = (6, 4, "Factals")		// 240210
  //let (majorVersion, minorVersion, nameVersion) = (6, 3, "Factals")		// 230603
  //let (majorVersion, minorVersion, nameVersion) = (6, 1, "Factals++")		// 220822
  //let (majorVersion, minorVersion, nameVersion) = (6, 0, "Factals re-App")// 220628
  //let (majorVersion, minorVersion, nameVersion) = (5, 1, "After a rest")	// 210710 Post
  //let (majorVersion, minorVersion, dnameVersion) = (5, 0, "Swift Recode")
  //let (majorVersion, minorVersion, nameVersion) = (4, 0, "xxx")			// 180127 FactalWorkbench UNRELEASED
 // MARK: - SwiftUI
@main
extension FactalsApp : App {
	var body: some Scene {
		DocumentGroup(newDocument:FactalsDocument(/*file name??*/)) { file in
			ContentView(document: file.$document)
			 .id(/*file.fileURL?.absoluteString ??*/ UUID().uuidString) // Ensure uniqueness
			 .environmentObject(factalsGlobals)				// inject in environment
			 .onOpenURL { url in							// UNTESTED: Load a document from the given URL
				@Environment(\.newDocument) var newDocument
				newDocument(FactalsDocument(fileURL:url))
			 }
			 .navigationTitle("DOES NOTHING sldfjsdlfk")
			 .onAppear {
				if let window = NSApplication.shared.windows.first(where: {
						$0.windowController?.document?.fileURL == file.fileURL 	})
				{	window.title = (file.document.factalsModel?.partBase.title ?? "<nil>") + "   (from App.onAppear)"
					logRunInfo("Library: \(library.answer.titlePlus())")		// still no answer
				}
				else { print("no window found")}
			 }
		}
		 .commands {
			CommandMenu("Library") {
				ForEach(factalsGlobals.libraryMenuTree.children) { crux in
					menuView(for:crux)
				}
			}
		}
	}
//	func xxxx() {
//		let logger = OSLog(subsystem:Bundle.main.bundleIdentifier!, category:"havenwant?")
//		
//		os_log("This is a default log message", log:logger, type:.default)
//		os_log("This is an info log message",   log:logger, type:.info)
//		os_log("This is a debug log message",   log:logger, type:.debug)
//		os_log("This is an error log message",  log:logger, type:.error)
//		os_log("This is a fault log message",   log:logger, type:.fault)
//		let userName = "John"
//		let loginStatus = true
//		os_log("User %{public}@ logged in: %{public}@", log:logger, type:.info, userName, String(loginStatus))
//	}

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
}

 // MARK: - Singleton
var FACTALSMODEL : FactalsModel?=nil

  // https://stackoverflow.com/questions/27500940/how-to-let-the-app-know-if-its-running-unit-tests-in-a-pure-swift-project
//var isRunningXcTests : Bool	= ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

	//B: https://wwdcbysundell.com/2020/creating-document-based-apps-in-swiftui/

 // MARK: - 4.5 Event from OS
class AppDelegate: NSObject, NSApplicationDelegate {

	 // MARK: - 4.2 APP Enablers
	 // Reactivates an already running application because
	//    someone double-clicked it again or used the dock to activate it.
//	func applicationShouldHandleReopen(_ sender:NSApplication, hasVisibleWindows:Bool) -> Bool
//	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool
	func applicationDidFinishLaunching(_ notification: Notification) {

		 // Set Apple Event Manager so Factals recieve URL's
		NSAppleEventManager.shared().setEventHandler(self,
			andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)),
			forEventClass:AEEventClass(kInternetEventClass), andEventID:AEEventID(kAEGetURL))

	//	sounds.play(sound:"GameStarting")
		atApp(7, print(ppController(config:false)))
		atApp(3, print("------------- AppDelegate: Application Did Finish Launching --------------\n"))
	}
//	func appPreferences(_ sender: Any)		// Show App preferences
//	func appState(_ sender: Any)
//	func appConfig(_ sender: Any)
//	func appHelp(_ sender: Any)
	
	 // MARK: - 4.6 APP Terminate
	func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
bug;	return .terminateNow													}
	func applicationWillTerminate(_ 	 aNotification: Notification) {
bug;	print("xxxxx xxxxx xxxx applicationWillTerminate xxxxx xxxxx xxxx")
		print("                   G O O D    B I E  ! !")						}
	func applicationShouldTerminateAfterLastWindowClosed(theApplication:NSApplication) -> Bool	{
bug;	return false															}

	@objc func handleGetURLEvent(event:NSAppleEventDescriptor, withReplyEvent replyEvent:NSAppleEventDescriptor) {
		openURL(named:event.paramDescriptor(forKeyword:keyDirectObject)?.stringValue)
	}
	func openURL(named:String?) {					 // Common:
		guard let name			= named, let url = NSURL(string:name) else
		{	fatalError(named == nil ? "named is nil" : "url(\(named!)) is nil") }
		print("openURL('\(named!)' -> \(url))")
		var urlStr         		= url.absoluteString! //.stringByRemovingPercentEncoding//name//
		let prefix         		= "SwiftFactal://"		// "SwiftFactal""SwiftFactals"
		assert(urlStr.lowercased().hasPrefix(prefix), "URL does not have prefix '\(prefix)'")
		let index     			= urlStr.index(urlStr.startIndex, offsetBy:18)
bug;	urlStr      			= String(urlStr[index...])
	}
}
 // MARK: - Globals
extension FactalsApp {		// FactalsGlobals
	class FactalsGlobals : ObservableObject {				// (not @Observable)
		// MARK: -A Configuration
		var factalsConfig : FwConfig

		// MARK: -B Library Menu:
		init(factalsConfig a:FwConfig, libraryMenuArray lma:[LibraryMenuArray]?=nil) {	// FactalsApp(factalsConfig:libraryMenuArray:)
			factalsConfig 		= a
			let libraryMenuArray = lma ?? Library.catalog().state.scanCatalog
			let tree 			= LibraryMenuTree(array:libraryMenuArray)
			libraryMenuTree 	= tree
 		}
		var libraryMenuTree : LibraryMenuTree// = LibraryMenuTree(name: "ROOT")
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
struct FactalsApp: FwAny, Uid {
	let nameTag					= getNametag()
	let fwClassName: String		= "FactalsApp"
	@NSApplicationDelegateAdaptor(AppDelegate.self)// private
	 var appDelegate: AppDelegate

	 // Source of Truth:
	@StateObject var factalsGlobals	= FactalsGlobals(factalsConfig:params4partPp)//, libraryMenuArray:Library.catalog().state.scanCatalog)	// not @State

	 // MARK: - 2. Object Variables:
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
//	var sound					= Sound(configure:[:])

	 // MARK: - 3. Factory
	init () {
		self.init(foo:true)
	}
	private init (foo:Bool) {
		  // 🇵🇷🇮🇳🔴😎💥🐼🐮🐥🎩 🙏🌈❤️🌻💥💦 τ_0 = "abc";  τ_0 += "!" é 김 ⌘:apple, ⏎:enter
		 // Henry A. King and P. Allen King:
		let appConfig 			= params4partPp
		atApp(3, logd("FactalsApp(\(appConfig.pp(PpMode.line).wrap(min: 14, cur:25, max: 100)))"))
//		atApp(3, logd("verbosity:[\(log.verbosity?.pp() ?? "nil")]"))//, XcTests is\(isRunningXcTests ? "" : "n't") running"))
		atApp(3, logd("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️"))
		atApp(3, logd("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ"))
		atApp(1, logd("\(appStartTime):🚘🚘   \(nameVersion) \(majorVersion).\(minorVersion)   🚘🚘 ----------------ττττ"))
		atApp(3, logd("\(appStartTime):🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘🚘 ----------------ττττ"))
		atApp(3, logd("❤️ ❤️   ❤️ ❤️         ❤️ ❤️   ❤️ ❤️   ❤️ ❤️        ❤️ ❤️   ❤️ ❤️\n"))
		print(ppController(config:false))	//causes "X<> PROBLEM  'bld9' found log 'App's Log' busy doing 'app3'"
//		logRunInfo("\(library.answer.titlePlus())")

//		sounds.load(name:"di-sound", path:"di-sound")
//		sounds.play(sound:"di-sound", onNode:SCNNode())	//GameStarting
	}

	//@IBOutlet weak
	 var sceneMenu:NSMenu!

	 // MARK: Access Scene MENU
	mutating func scheneAction(_ sender:NSMenuItem) {
		print("\n\n" + ("--- - - - - - - AppDelegate.sceneAction(\(sender.className)) tag:\(sender.tag) " +
			  "regressScene:\(regressScene) - - - - - - - -").field(-80, dots: false) + "---")

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
//			guard let doc = DOC else { debugger("no DOC")}
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
		do {
			let newEntry		= wallTime() + comment + "\n"		//"YYMMDD.HHMMSS: "
			let homeDirectory 	= FileManager.default.homeDirectoryForCurrentUser
			let fileURL 		= homeDirectory.appendingPathComponent("Documents/logOfRuns")// FileManager.default.url(for:.applicationDirectory,	// ~/Library/Containers/self.SwiftFactals/Data/Applications/
			let fileUpdater		= try FileHandle(forUpdating:fileURL)

			 // Write at EOF:
			fileUpdater.seekToEndOfFile()
			fileUpdater.write(newEntry.data(using:.utf8)!)
			fileUpdater.closeFile()
		}
		catch let errorCodeProtocol {
			print("logRunIfo FAILED: \n\"\(errorCodeProtocol)\"")
			//  BUG: 20201225 Wouldn't create logOfRuns; must do manually
		}
	}
//	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String="\n") { //String?=nil
//		let msg					= String(format:format_, arguments:args)
//		Log.shared.log(banner:banner, msg, terminator:terminator)
//	}
}


