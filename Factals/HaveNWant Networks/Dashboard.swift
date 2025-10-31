//  Dashboard.swift -- to Configure Factal Workbench Runs ©2019PAK

import SceneKit

// Notes:
// Default constants, used to configure the 6 sub-system of Factal Workbench:
//		a) Apps, b) App Logs, c) Pretty Print,  d) Doc Log, e) Simulator, f) 3D Scene
// When in XCTest mode, keys with "*" prefix replace their non-star'ed name.
// 20220912PAK: Simplification: all merged into one hash

  // MARK: A: Config App
 /// Parameters globally defined for Application()
var params4app : FwConfig 		= [
	"soundVolume"	 			: 10,//0.1,// 0:quiet, 1:normal, 10:loud
	"menuScene"		 			: 162,//145,137,132,159,132,82,212,21,19,18,12,	// next (first) regression scene
	"regressScene"	 			: 189,//162,145,137,132,159,132,82,212,21,19,18,12,	// next (first) regression scene
]
 // MARK: B: Config which events are logged
let params4logDetail : FwConfig =	// Set events to be logged
	///logAt(app:0,doc:0,bld:0,ser:0,ani:0,dat:0,eve:0,ins:0,men:0,rve:0,rsi:0,rnd:0,tst:0,all:0) +
	//* Nothing								*/	logAt(0) +
	//* App 								*/	logAt(app:8) +
	//* Most Everything 					*/	logAt(8) +
	//* Most Everything except ReVIw 		*/	logAt(8, rve:0) +
	//* Most Everything except + RevewSIze:4 */	logAt(8, rve:0, rsi:4) +
	/* Most, except  review, resize 		*/	logAt(9, rve:0, rsi:0) +

	[							// + +  + +
		"breakAtEvent"				:-33,//-208,//150//-54,//240/3/0:off
								// + +  + +

		"debugOutterLock"			: false, 	//true//false// Helpful logging, quite noisy
	]

 // MARK: C: Config Pretty Print of Parts as text
let params4partPp	 : FwConfig = [	// ///// All prameters controlling printing Parts
				// What:
	"ppLinks"			: false, 	// pp includes Links  //true//
	"ppPorts"			: true, 	// pp includes Ports //false//
	"ppScnMaterial"		: false, 	// pp of SCNNode prints materials (e.g. colors) on separate line
				// Order:
	"ppDagOrder"		: true, 	//true//false//
				// Options:
	"ppParam"			: false,	// pp config info with parts

		// "U":		Show ( V ) Uid		// "E":		Show ( VI) initial expose
		// "F":		Show ( V ) Flipped	// "T":		Show (  I) position transform
		// "V":		Show ( V ) (self)	// "B":		Show (  I) physics Body
		// "S":		Show ( V ) Scn		// "I":		Show (  I) pIvot point
		// "P":		Show ( V ) Part		// "W":		Show (PVI) position in World coordinates
		// "L":		Show ( V ) Leaf height				   '-> :H: Part, View, scN
	"ppViewOptions"	/**/:	"UFV    TB W",	// Compact
					//**/:	"UFVSPLETBIW",	// Everything
					//**/:	"UFV       W",	// WIP
					//**/:	"UFVTWB",		// Tests
					//**/: 	"UFVS   TB W",	//
					//**/:	"UFV PL  B  ",	//
					//**/:	"UFV    TBIW",	//

	"ppScnBBox"			: true, 	// pp SCNNode's bounding box	//false//true
	"ppFwBBox"			: true, 	// pp Factal Workbench's bounding box
				// SCN3Vector shortening:
	"ppXYZWena"  		: "XYZ",  	//"Y"XYZ"	// disable some dimensions //"XYZW"//
				// Column Usage:
	"ppViewTight"		: false, 	// better for ascii text //false//true
	"ppBBoxCols"		: 28,		// columns printout for bounding boxs//32//24
	"ppIndentCols"		: 14,//12/12/8// columns allowed for printout for indentation
	"ppNNameCols"		: 8,		// columns printout for names
	"ppNClassCols"		: 8,		// columns printout for names
	"ppNUid4Tree"		: 4,  //0/3/4/ hex digits of UID identifier for parts 0...4
	"ppNUid4Ctl" 		: 4,  //0//3//4// hex digits of UID identifier for controllers //0
	"ppNCols4VewPosns"	: 20,		// columns printout for position  //20/18/15/14/./
	"ppNCols4ScnPosn"	: 40,		// columns printout for SCN position  //25/20/18/14/./

	// ////// Specify Floating Point Accuracy: fmt("%*.*f", A, B, x) (e.g. %5.2f)
 ///"ppFloatA": 2, "ppFloatB":0,	// good, small
	"ppFloatA": 4, "ppFloatB":1,	// good, .1, tight printout
 ///  "ppFloatA": 5, "ppFloatB":2,	// good, .01 for bug hunting
	///"ppFloatA": 7, "ppFloatB":4,	// BIG,  .0001 ACCURACY
	///"ppFloatA": 4, "ppFloatB":2,
	///"ppFloatA": 5, "ppFloatB":2,
	///"ppFloatA": 3, "ppFloatB":1,
]
let params4defaultPp : FwConfig = [:]	// default if none suppled

 // MARK: D: Config Simulation
let params4sim : FwConfig = [
	"simRun"				: false,
	"simTaskPeriod" 			: 0.01,//5 1 .05// Simulation task retry delay nil->no Task
	"timeStep"					: 0.01,			// Time between UP and DOWN scan (or vice versa)
	"logSimLocks"				: false,//true//false// Log simulation lock activity
]
 // MARK: E: Config APPEARANCE of Parts on screen
let params4partVew : FwConfig = [
//	"initialDisplayMode"		: "invisible"	// mostly expunged
//	"physics"					: ??
/**/"linkVelocityLog2"			: Float(-8.0),	// link velocity = 2^n units/sec //slow:-6.0

/**/"placeMe"					:"linky",		// place me (self)	//"stackY"
/**/"placeMy"					:"linky",		// place my parts	//"stackY"
//**/"placeMe"					:"stacky",		// place me (self)	//"stackY"
//**/"placeMy"					:"stacky",		// place my parts	//"stackY"
// 	"skinAlpha"					: 0.3,			// nil -> 1		// BROKEN
	"bitHeight"					: Float(1.0),	// radius of Port
/**/"bitRadius"					: Float(1.0),	// radius of Port
	"atomRadius"				: Float(1.0),	// radius of Atom
	"factalHeight"				: Float(3.0),	// factal scnScene height
	"factalWidth"				: Float(4.0),	// factal scnScene height xx factal scnScene width/depth/bigRadius
	"factalTorusSmallRad"		: Float(0.5),	// factalTorusSmallRad
//	"bundleHeight"				: Float(4.0),	// length of tunnel taper			*/
//	"bundleRadius"				: Float(1.0),	// radius of post

	  // ///  Gap_: USER DEFINITIONS ////////////////////////////////////////////
	 // indent for each layer of FwBundle terminal block:
	"gapTerminalBlock"			: CGFloat([0, 0.04, 0.2, 0.5]	[3]),// !=0 --> ^P broken
	 // gap around atom to disambiguate bounding boxes:
	"gapAroundAtom"				: CGFloat([0, 0.01, 0.2]		[0]),// !=0 --> ^P broken
	 // linear between successive Atoms:
	"gapStackingInbetween"		: CGFloat([0, 0.1,  0.2]		[0]),// OK
	 // between boss & worker if no link:
	"gapLinkDirect"				: CGFloat(0.1),
	 // min gap between boss and worker, if link:
	"gapLinkFluff"				: CGFloat(1.234321),

//	"linkRadius"				: Float(0.25),	// radius of link (<0.2? 1pix line: <0? ainvis
//	"linkEventRadius"			: Float(-1),	// radius of link (<0.2? 1pix line: <0? ainvis
//	"linkDisplayInvisible"		: false,		// Ignore link invisibility
//	"displayAsNonatomic"		: false,		// Ignore initiallyAsAtom marking
	 //////// Ports
//	"signalSize"				: Float(1.0),	// size of bands that display

	 // Animate actions:
//	"animatePhysics"			: true,			// Animate SCNNode physics
	"animateChain"				: true, 		// Animate Timing Chain state
//	"animateBirth"				: true,			// when OFF, new elt is in final place immediately
	"animateFlash"				: false, 		//false//
	"animatePan"				: true,			//false//
	"animatePole"				: true,			//false//
	"animateOpen"				: true,			//false//
	"animateVBdelay"			: 0.6,			//3.0//0.6
	"lookAt"					: "",
	"vanishingPoint"			: Double.infinity,
	//"render3DMode"			: render3Dcartoon,
	"picPan"					: false,		// picking object pans it to center

	"showAxis"					: true,			//false//true//
	"axisTics"					: true,			//false//true//

	"camera"					: "",			// HACK Define so ansConfig overrites

	 // 11. 3D Display ******** 3D Display
	"displayPortNames"			: true,
	"displayLinkNames"			: true,
	"displayAtomNames"			: true,
	"displayLeafNames"			: false,
	"displayLeafFont"			: false,		// default 0 is no leaf names
	"displayNetNames"			: true,
	"displayLabels"				: true,
	"fontNumber"				: 6,			// default font index; 0 small, 6 big
//	"rotRate"					: Float(0.0003/(2*Float.pi)),
	 // bounding Boxes: default is unneeded

	"wBox"						: "gray", //"colors",		// "none", "gray", "white", "black", "colors"

	 // For debugging:
	"logRenderLocks"			: false,//true//false// Log simulation lock activity
]

let wBoxColorOf:[String:NSColor] = [
	"Part"			:NSColor.red,
	 "Port"			:NSColor.red,
	  "MultiPort"	:NSColor.red,
	  "Share"		:NSColor.red,
	 "Atom"			:NSColor.orange,
	  "Net"			:NSColor.purple,
//??   "FwBundle"	:NSColor("darkgreen")!,
	    "Tunnel"	:NSColor.green,
	    "Leaf"		:NSColor.red,
	   "Generator"	:NSColor.red,
	  "DiscreteTime":NSColor.red,
	  "TimingChain"	:NSColor.red,
	  "WorldModel"	:NSColor.red,
]
