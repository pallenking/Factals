//  LldbInit.swift -- Pretty Print common FW types, thru ~/.lldbinit C2018PAK

import SceneKit
// See INSTALL.md

/* To do:
	1. NSColor pps		== :NSColorSpaceColor
	2. SCNMaterial
	3. pt pCon2Spot
 */

func breakToDebugger() {
	panic("Break To Debugger")
}
func lldbPrint(_ ob:FwAny, mode:PpMode, _ aux:FwConfig = [:], terminator t:String="\n") {	//["ppDagOrder":true]
	let aux						= params4partPp + aux	// 20250518PAK:
	//debug: print("lldbPrint(\(ob.pp(.nameTagClass)), mode:\(mode), \(aux.pp(.tree))")
	if let part					= ob as? Part {
		print(part.pp(mode, aux), terminator:t)
	}
	else if let vew				= ob as? Vew {
		print(vew.pp(mode, aux), terminator:t)
	}
	else if let scn				= ob as? SCNNode{
		print(scn.pp(mode, aux), terminator:t)
	}
	else {
		print(ob.pp(mode, aux), terminator:t)
	}
}

 // Access to current ////// Part Tree //////return nil }// 
var  LLDBParts : PartBase {	FACTALSMODEL?.partBase ??
							fatalError("FACTALSMODEL is nil") as! PartBase		}
func LLDBParts(_ name:String?=nil) -> Part  {
	guard var rv : Part			= FACTALSMODEL?.partBase.tree
	 else { return Part(["name":"COULD NOT FIND tree"])							}
	if name != nil 				// Search for sought Part	//maxLevel:1,
	{	rv						= rv.find(name:name!, up2:false, inMe2:true) ?? rv }
	return rv
}

 /// Access to current ////// Vew Tree //////
var  LLDBvews0  : VewBase {
	get 		{	return FACTALSMODEL?.vewBases.first ??
						   fatalError("vewBases.first is nil") as! VewBase		}
	set (v)		{		   FACTALSMODEL?.vewBases[0] = v						}
}
var  LLDBvews1  : VewBase {
	get 		{	return FACTALSMODEL!.vewBases.count > 1 ? FACTALSMODEL!.vewBases[1]
						 : fatalError("vewBases.first is nil") as! VewBase		}
	set (v)		{		   FACTALSMODEL?.vewBases[1] = v						}
}
var  LLDBvews2  : VewBase {
	get 		{	return FACTALSMODEL!.vewBases.count > 2 ? FACTALSMODEL!.vewBases[2]
						 : fatalError("vewBases[2] is nil") as! VewBase			}
	set (v)		{		   FACTALSMODEL?.vewBases[2] = v						}
}
func rootVewL(_ name:String?=nil, _ index:Int=0) -> Vew  {
	guard let factalsModel 		= FACTALSMODEL else {
		debugger("FACTALSMODEL returns nil !!!")
	}
	guard index >= 0 && index < factalsModel.vewBases.count else { debugger("rootvew() returns .null !!!")	}
	var vew : Vew				= factalsModel.vewBases[index].tree
	if name != nil {			// Search for named Vew
		vew						= vew.find(name:name!, inMe2:true) ?? vew
	}
	return vew
}

 /// Access to current ////// SCNNode Tree  //////
var LLDBvew0sceneTreeRoot : SCNNode  		{ 	LLDBvewISceneTreeRoot(0) 		}
var LLDBvew1sceneTreeRoot : SCNNode  		{ 	LLDBvewISceneTreeRoot(1) 		}
var LLDBvew2sceneTreeRoot : SCNNode  		{ 	LLDBvewISceneTreeRoot(2) 		}
func LLDBvewISceneTreeRoot(_ index:Int) -> SCNNode {
	guard let vewBases			= FACTALSMODEL?.vewBases,
	  vewBases.count > index,
		  let scn					= vewBases[index].gui?.getScene.rootNode else {
//	  let scn					= vewBases[index].scnBase.scene?.rootNode else {
		debugger("Found ...vewBases[\(index)].scnBase.tree?.rootNode = nil")
	}
	return scn
}

//func LLDBscnNodesTree(_ name:String?=nil, _ index:Int=0) -> SCNScene	{
//	guard let factalsModel 			= FACTALSMODEL else {
//		print("FACTALSMODEL is nil! returning SCNNode.null")
//		debugger("FACTALSMODEL is nil! returning SCNNode.null")
//	}
//	guard index >= 0 && index < factalsModel.vewBases.count else {
//		print("index:\(index) exceeds rootVews=\(factalsModel.vewBases.count)! returning SCNNode.null")
//		debugger("aegqvw")
//	}
//	var scnBase				= factalsModel.vewBases[index].scnBase
//
//	 // Search for named SCN:
//	if name != nil {
//		debugger("aowivw;von")
////		scnBase				= scnBase?.tree.rootNode.find(inMe2:true, all:true, firstWith:
////								  { $0.name == name })  ?? scnBase
//	}
////	guard let scnBase			else {
////		print("scnNode is set to .nil")
////		return .null
////	}
//	guard let rv 					= scnBase.tree else { debugger("ksajvkwvawpijv")}
//	return scnBase.tree!
//}

 // Print SwiftFactal help from lldb
func fwHelp(_ key:String="?", inVew vew:Vew?) {
	sendApp(key:key, inVew:vew)
}
 // Send a key to controller:
func sendApp(key:String="?", inVew vew:Vew?) {
	if let fm				= vew?.vewBase()?.factalsModel,
	   let ginnedUpEvent	= NSEvent.keyEvent(
			with			: .keyDown, //NSEvent.EventType(rawValue: 10)!,//keyDown,
			location		: NSZeroPoint,
			modifierFlags	: NSEvent.ModifierFlags(rawValue: 0),
			timestamp		: 0.0,
			windowNumber	: 0,
			context			: nil,
			characters		: key,
			charactersIgnoringModifiers: key,
			isARepeat		: false,
			keyCode			: 0)
	{
		let _			 	= fm.processEvent(nsEvent:ginnedUpEvent, inVew:vew)
	}
	else {
		print("#### #### No current Controller; not using sendApp(key:\(key)) ########")
		switch key {
		case "c":
			print(ppControllers())
		case "?":
			printDebuggerHints()
		default:
			debugger("sendApp finds nil Controller.current")
		}
	}
}

 // External Global interface (misc, lldb)
//func printFwConfig()  {
//	print("######## printFwConfig UNIMPLEMENTED ######")
//}

func printDebuggerHints() {
	print ("=== Controller   commands:",
	//	"\t" + "<esc>           -- exit program",
		"\t'u'+cmd         -- go to lldb for retest",
		"\t"+"esc             -- beep and exit",  /*Character("\u{1b}")*/
		"\t'N'+alt         -- write out SCNNode tree as .dae",
		"\t'?'             -- display this help message",
		"\t'b'             -- BREAK to debugger in SimNsWc",
		"\t'd'             -- run debugging code",
		"\t'm'             -- print Model Parts",
		"\t'M'             -- print Model Parts and Ports",
		"\t'l'             -- print Model Parts, Links",
		"\t'L'             -- print Model Parts, Links, Ports",
		"\t'C'             -- print System Configuration (1-line of each hash)",
		"\t'c'             -- print System Controllers State (1-line state of each)",
		separator:"\n")
	print("===== Debugger Hints: =================",
		"\t" + "pc <expr>       -- print fwClassName of <expr>",
		"\t" + "pn <expr>       -- print name of <expr>",
		"\t" + "pf <expr>       -- print full name of <expr>",
		"\t" + "pt <expr>       -- print the tree with <expr> as root",
		"\t" + "pi <expr>       -- print id (name:fwClassName) of <expr>",
		"\t\t e.g. pts, ptm, ptv, pt foo",
		"\t" + "<expr> might be rootpart(\"<name>\"), or rootvew(\"<name>\") to find a part in tree",
		"\t" + "Common Commands: ptm, plv, ppn, pfs, ptPm, plLm",
		"\t\t" + "Char 1:   p- -: Pretty Print",
		"\t\t" + "Char 2:   -p -:.phrase; -l -:.line,     -t -:.tree,",
		"\t\t" + "Char 2:   -c -: classF; -n -:name,      -f -:fullName,  -i -:.id,",
		"\t\t" + "Char 2.5: --L-:ppLinks; --P-:ppParameters",
		"\t\t" + "Char 3:   -- s: self;   -- m:root Model -- v:root Vew  --n:root SCNNode",
		"\t" + "use rootpart(\"<name>\") and rootvew(\"<name>\") to find a part in tree",
		"\t" + "pFwState:  -- ('C') print System Controllers State (1-line state of each)",
		"\t" + "pFwConfig: -- ('c') print System Configuration     (1-line of each hash)",
		separator:"\n")
	print("=== Configuration:",
		"\t" + " reload with  lldbinit  = '  command source ~/src/SwiftFactals/.lldbinit  '",
/**/	"\t" + "    N.B: must have symbolic link ~/.lldbinit ->  ~/src/SwiftFactals/.lldbinit  ",
		separator:"\n")
}







	/// Understand/move the following:
/** CONFIGURATION SUBSYSTEM: 20190124 *//*
0. ======== Ahead of Time, load config in HaveNWant: ==========================

1. ======== LOADING: ===========================================================
		xr() ->	addUserPrefs		-> HaveNWant.config ...  --> *** ctl.config

2. ======== USES: ==============================================================
	2A. ================ Pretty Print
	pp(["opt":val])					                    --> String
			\				 /
		[[[ Pretty Print, parameterized ]]] --> String
				   \>      >'
		   aux.string_("ppXYZWena") 					--> *** FwConfig Access
-- print SCNNode tree
	2B. ================ Operational Configuration
	//		e.g:  doc.config.int_("breakAt")
	doc["breakAt"].asInt_   DEPRICATED
	Log.current.breakAt

	2C. ================ Printing Data
				<Part>.getConfig(name)?.asString       	--> String
				   \>		>'
				specific part, and then its parents
				controller[key] as? Int					<-- **doc.config


3. ======== HELPERS ============================================================
	3A. ================ *** FwConfig Access: Named, Typed access to _ANY_  hash:
		1. supports special "super" key
		2. defaults to app doc.config
		3.
			 <FwConfig>.int(name)   .int_(name)	("ppXYZWena")
				 .float(name) .float_(name)	("ppFloatA" )
			.string(name).string_(name)     ("ppFloatB" )
				  \>             >'
				self.lookup(key) as? Int ??
		 	     controller[key] as? Int   				<-- ***doc.config
	3B. ================ *** Casting FwAny to known Class
		<FwAny> .asString   ?? "" 		.asString_
				.asBool     ?? false	.asBool_
				.asInt      ?? 0		.asInt_
				.asFloat    ?? 0.0		.asFloat_
				.asCGFloat  ?? 0.0		.asCGFloat_
				.asColor    ?? .purple	.asColor_
				.asFwConfig ?? [:]		.asFwConfig_
				 as? [String]													*/

