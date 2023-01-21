# TO_DO.md -- Factals



20221005: Imported froms SwiftFactals:TO_DO.md

20220225 
	1. pruned Xyzzy*
+		38	Xyzzy44: reSkin returns: vew.scn.bBox(); scn.bBox() * scn.transform
+		2	Xyzzy18.x: Bulb
+		7	Xyzzy19e: Link
+		1	Xyzzy87: markTree
	3. Zev: “SwiftFactals” would like to access files in your Documents folder.
20220222 Common Problems
+		1. animations seem to need overlapping stacking
+		3. Eliminate the concept of "first" in stacking
+		4. Increase Net gaps >0
  ---------------------------------------------------------------
	All Model variables have to list all their properties, for
	 // MARK: - 3.4 NSKeyedArchiver			// 2## PolyWrap(rootPart)
		1.	NSKeyedArchiver	data(ofType:)	// 1## Generic PolyWrap, for Part, Port
							read(from:ofType:) 	//		((These only FwDocument)))
+	 // MARK: - 3.5 Codable 				// ## Double Check 3 dozen variables
+		1a.	Encodable: 		encode(to:)
+		1b.	Decodable:		init(from:)						//

	  Other Protocols, 						// ## IMPLEMENT in Part:
		5.	Hashable:		hash(into:)		// To be used as a key in a hash

DECISION: need Comparable for Json testing
  ---------------------------------------------------------------
	Problematic Constructs
		A.	Array<Element>
		B.	Dictionary<Value>
		C.	NSColor, SCNMatrix4, Vew: Extension outside of file declaring class prevents automatic synthesis of 'encode(to:)' for protocol 'Encodable'
		D.	SCNNodes are not Codable
		5.  Optional<int>.
	UN-Codable's
		A: FwBundle:!!	struc:FwAny?							FwConfig A
		B: CPort:c	NSColor									NSColor
		C: Atom:	c	bandColor:NSColor, proxyColor			NSColor
					do	Ports -- redundant info					-code-
		D: RootPart:!!	ansConfig:FwConfig						FwConfig MUCH
					**	root:RootPart							-code-
					**	weak var fwDocument:FwDocument?			-code-
					?	partTreeLock, partTreeOwner, 			-code-
					?	partTreeOwnerPrev, partTreeVerbose,		-code-
		E: Part:	**	weak var parent:Part?					-code-
					**	weak var root							-code-
					!!	localConfig:FwConfig = [:]				FWConfig

20221105:
	  NONEXISTANT
		6.	Identical:		same UUID?	// ## IMPLEMENT in Part
	  Punt:
+	2. Zev: "SwiftFactal://", 	"SwiftFactal","SwiftFactals"...
+	 // MARK: - 3.6 NSCopying				// WON'T' IMPLEMENTED
+	 // MARK: - 3.7 Equatable
+		3a.	Equatable: static func ==(lhs, rhs) -> Bool		// 3## no super.==(lhs:lhs, rhs:rhs) !?!
+			//https://forums.swift.org/t/implement-equatable-protocol-in-a-class-hierarchy/13844/3
+					Tupples:	func ==<A>    ((A),     (A))     -> Bool
+								func ==<A,B>  ((A,B),   (A,B))   -> Bool
+								func ==<A,B,C>((A,B,C), (A,B,C)) -> Bool
+		4.	Comparable: (extends Equatable)
+							static func < (Self, Self) -> Bool
+							static func <= (Self, Self) -> Bool


aaaaaaaaaaa
20211027 DONE
		2. Net/Box is overlapping
		1. Spacing on Net skins; gapTerminalBlock1=0

unity v.s scenekit
20211015
	thread sanitizer https://www.raywenderlich.com/books/concurrency-by-tutorials/v2.0/chapters/12-thread-sanitizer#:~:text=To%20do%20so%2C%20first%20click%20on%20the%20Concurrency,window%20and%20then%20build%20and%20run%20your%20app.
	make FwAny Codable			*****
	views backed by CA layer
	set needs layout update
20211003: 
	1. SceneKit EXC_BAD_ADDR: https://izziswift.com/how-to-solve-scenekit-renderer-exc_bad_access-code1-address0xf000000010a10c10/
		It's my experience that those kind of errors occur when you attempt to 
	modify SceneKit's scene graph (add/remove nodes, etc) outside the 
	SCNSceneRendererDelegate delegate methods.
CVDisplayLink (23) Queue : com.apple.scenekit.renderingQueue.SwiftFactals.FwView0x7b5c00009300 (serial)

	3. Sort printing of Dictionaries
	2. Things to prune
		Library
		all subclasses of Part, just Generators, 
		simulator task
		lights/camera/pole/lookAtView
	4. 211:1508: portConSpot(inVew bug()

20210922 ZEV Questions
	1. DENOUMENT: default lldb init file is $(SRCROOT)/LLDBInitFile, and this works. 		FILE?
		However if you type those exact characters into the field, it doesn't.  
		Neither "$" nor does "~"
	2. I wonder if I have signing set up correctly. Running xcode over cell data is slow.
	3. allenM1SwiftFactals % git status
		objc[19272]: Class AMSupportURLConnectionDelegate is implemented in both 
			/usr/lib/libauthinstall.dylib (0x208eb3ad8) and 
			/System/Library/PrivateFrameworks/MobileDevice.framework/Versions/A/MobileDevice (0x1145c02b8). 
		One of the two will be used. Which one is undefined.
	5. PolyWrap: Make new copy of tree. 
		Every reference to a Part wraps that Part in a PolyWrap
			Before Wrap:		(ID   name:Classname)
			 655  <##    net0:Net
			 289  | < 0       a:Broadcast
			 cef  | |\          P:Port
			After Wrap:
			 22e  <##     ---:PolyWrap
			=655  | < 0    net0:Net  
			 e92  | | < 0     ---:PolyWrap
			=289  | | | < 0       a:Broadcast
			 e0d  | | | | < 0     ---:PolyWrap
			=cef  | | | | |\           P:Port
		.
		try newPartType.init(from:polyWrapsContainer)a
		marry into Keyed Archiver: "read(from" and "data(ofType"
.
	6. Start up only part of my application during test (faster)

20211015 --------------------- DONE --------------
	4. transfor over equalsPart --> ==(lhs:rhs:) find out where Part:== and === ...
		NOTE 2023-0121PAK: Part.Equatable abandoned

20210908 --------------------- DONE --------------
	0. SCNMatrix4Mult on Apple M1  (only on M1)
	0. SCNNode .boundingBox faults (OFTEN on M1, at 134 on x86)


20210724 BUGS
	1. Keyboard shortcut for  '?' key  (shift /)
	2. Application preferences panel (⌘,)
	3. intelligent defaults

SSS
	2. bug: next-scene(^r): wc but no w.
	3. Save inspector positions in core data (learn core data)
	4. Atomize (many things have decayed here)
	5. want to define operator ??= , which eval's rhs only if lhs is nil


Study:
	1. Color Schemes
	2. Review of CURlog! implementation. Suggestions
	3. Correct way to make windows? How to position inspectors? (use of core data?) How to make popup windows? tile inspectors
	4. Redo core with Combine
		configuration: config4xx -> components
		keystrokes: generators, spawn events, epochs, ?, ...
		data generation: <incremental>, again, defaultStart, ?, ...
		simulation events: e.g. birth
		output patterns:
	5. Separate project into 2 parts to reduce compile time
	6. fwClassName -> className
	7. Split FW/factals into separate namespace and/or project
		a. Bundle is used in Cocoa as a collection of assets, and in HaveNWant as a structure of factals. 
		How can I separate their namespaces.

DESIGN ISSUES:
	gits: 
	2020-10-23 11:10:18.151 xcodebuild[5507:99501] [MT] PluginLoading: Required plug-in compatibility UUID 6C8909A0-F208-4C21-9224-504F9A70056E for plug-in at path '~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/VVDocumenter-Xcode.xcplugin' not present in DVTPlugInCompatibilityUUIDs
	------------------------ 20201017:
	2. Access events in AppDelegate, to get keystrokes before any windows are open?
	3. Labels on objects SCNNodes for view on billboard
	4. status bar for SCNView (e.g. add camera status, testing directions)
	1. Reduce compile time from 1 minute, perhaps into modules?
		https://medium.com/@joshgare/8-tips-to-speed-up-your-swift-build-and-compile-times-in-xcode-73081e1d84ba
			defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
			rm -rf ~/Library/Developer/Xcode/DerivedData
	2. Automate Sequence "run to log==42 with break off, durn on breaks, run till break" from code within app.



------------------------ 20210226 DONE
	1. Play sound on SCNNode
------------------------ 20210110 DONE
	k. define helper functions only in all libraries, not just Test01
x	3. Debug *param
x	1. why can't testBindingTypes.xib be in SwiftFactalTests
x		b. place TestBindingTypes.xib into SwiftFactalTest group
?	1. button up if_objcException, post on stackExchange			-> exploring SwiftTryCatch

x	5. xcode preferences crashes:								-> Zev -> developer forum	https://feedbackassistant.apple.com/feedback/8922377
x	4. when I restart xocde and as of 12.?, all my tabs go away.	-> (With pref crash)
	2. XCTest exc_bad_addr, post on SO						-> SO
		https://stackoverflow.com/questions/65056961/xctest-hangs-after-nsobject-deinit

	----- Xcode Bugs
	a. Some windows navigator divider won't go wide`					-> monitor
	c. Actions to a window block in the event que. Switching tabs fixes	-> monitor
	b. Keepout area around Apple logo on desktop						-> monitor

	----- ignoring
		a. get testBindingTypes() and BindingTypesVc.swift working	-> ++
	----- using SwiftUI instead:
	trying to get about 50 .xib's from objc, working in Swift with minimal changes.	I have some bindings working, but many (esp bool, float) not.


------------------------ 20200924:
cocoa heads 	      -- 2 presentations, + talks, dinner.
      http://cocoaheadsboston.org
swift coders
learn swift boston    -- beginners  Zev/Matt
mac tech group
------------------------

20190708 Help:
2. Cocoa
Things we might try to do tonight:
	a. server, where URL received pops it in window.
	c. Move In-App testing (e.g: xr() ) to test infrastructure. Problem: test(n)
	d. review FwAny construction   Fw++'s .asString and friends. Should be using NSValue-ish


1. The "testing" task involves getting the testing infrastructure to do what I drive the app 
through with keystrokes to validate it. 
2. The "Fw++.asString" is the first thing I've done, before I knew anything. I grew my own 
set of any2any. It could use some skilled review. 
3. The "SCNNode labels" involves view layers, and SceneKit/OGL billboards. 

======================================================================
1. NSDocumentController shouldn't make window on startup, but
		 NSAppleEventManager   dispatchRawAppleEvent
	calls NSPersistentUIManager  restoreAllPersistentStateWithCompletionHandler
	calls NSDocumentController   restoreWindowWithIdentifier:state:completionHandler:
	calls NSDocumentController   makeUntitledDocumentAndDisplay:error:
	calls 

5. LLDB integration
+++	integrate with description, debugDescription, and summary., popularize .pt and friends
		https://www.raywenderlich.com/2325-supercharging-your-xcode-efficiency#toc-anchor-011

x	j. Use of //*! for documentation.  Where is jazzy's output?
x		https://nshipster.com/swift-documentation/
x		https://github.com/realm/jazzy/blob/master/README.md
x		https://www.markdownguide.org/basic-syntax/
x		jazzy --min-acl private
x	k. get helper definitions in HaveNWantEnvironment.swift for ONLY Tests01.swift
x	l. When stack in NSObject+MachineTrap.m, my swift symbols (e.g. rootpart() ) aren't available!

3. Taming NSDocument
	http://sketchytech.blogspot.com/2016/09/taming-nsdocument-and-understanding.html
+	b. Sometimes App stalls and I have to click on the Dock's App Icon to get first doc
+	a. get Codable working, swap objects
		see ~/src/CodablePoly/README

x	b. loading complex FwScene
x	b. camera initially centered on bounding box
x	b. setting one SCNNode.physicsBody.gravity??? seems to set them all REF?-- BOIL DOWN!!!

1. Swift Language/Xcode:
+	c. pointer to <Part>nil: 	Part()?
		let y:Part?     = nil 		-->		let y     = xxx nil xxx
+	a. want Swift equivalent for:  printf3(const char *fmt, ...) __attribute__ ((format (printf, 1, 2))) cocoahead 7
		//int	 fprintf(FILE * __restrict, const char * __restrict, ...) __printflike(2, 3);
		//#define __printflike(a,b) __attribute__((format(printf, a, b)))
+	b. auto indent
+	f. using regular expressions for debug: 
		https://www.rexegg.com/regex-quickstart.html, 
		https://jayeshkawli.ghost.io/search-and-replace-in-xcode-with-regular-expressions/


6.  CocoaHeads 20190807
// john, mitch, mark
// flight school codable  mattt
// json4swift.com
// sharedPlaygroundData
// rx-swift

6. compile time
	https://medium.com/@joshgare/8-tips-to-speed-up-your-swift-build-and-compile-times-in-xcode-73081e1d84ba
		defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
		rm -rf ~/Library/Developer/Xcode/DerivedData
20200310 1654 39.7s, 43.4s, 48.9 build

Project (not target)→Build settings → Swift Compiler → Custom flags → Other swift flags 
build settings | other Swift Flags
	-Xfrontend -warn-long-function-bodies=100
	-Xfrontend -warn-long-expression-type-checking=100


20200816 scan:



DONE
20201118
1. On scene-kit objet pic, open an object InspecVc window from from nibs.

	a. tesselation (normals) on Hemisphere

