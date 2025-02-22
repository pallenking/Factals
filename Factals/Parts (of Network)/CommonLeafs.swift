//  CommonLeafs.swift -- Common Leafs which Bundles can have C181013PAK

import SceneKit

 // use either bMain or bPrev, depending on whether extra ups
let bMain			= ["":"main",   "+":"main"									]
let bMainPM			= ["":"main+",  "+":"main+",  "-":"main-"					]
let bPrev			= ["":"prev.S", "+":"prev.S"								]
let bPrevPM			= ["":"prev.S", "+":"prev.S", "-":"prev.T"					]

extension LeafKind : Equatable {
	static func == (lhs: LeafKind, rhs: LeafKind) -> Bool {
		lhs.equalsFW(rhs)
	}
	
	func equalsFW(_ rhs: LeafKind) -> Bool {
	//	guard self !== rhs 					  else {	return true				}
bug;	return self == rhs
	}
}
enum LeafKindx: Codable {
    case nil_
    case cylinder
    case closureCase(() -> Int) // Case with a closure returning an Int
	init(from:Decoder) throws		{ fatalError()}
	func encode(to:Encoder) throws {}
}

enum LeafKind : Codable, FwAny {
	init(from	  :Decoder) throws	{ 	fatalError()							}
	func encode(to:Encoder) throws	{ 	fatalError()							}
//	init?(rawValue: String) {
//		<#code#>
//	}
//	typealias RawValue = String
	case leafClosure(() -> Part) // Case with a closure returns a Part
//	case leaf(kind:Leaf)					// Only children on path are effected
	case nil_			//	= "nil_" // (FwConfig?, FwConfig?, FwConfig?, FwConfig?, FwConfig?) -> Leaf
	case cylinder		//	= "cylinder" // for gap size testing
	case genAtom		//	= "genAtom"
	case genMirror		//	= "genMirror"
	case bcast			//	= "bcast"
	case genBcast		//	= "genBcast"
	case genMax			//	= "genMax"
	case genMaxSq		//	= "genMaxSq"
	case bayes			//	= "bayes"
	case genBayes		//	= "genBayes"
	case mod			//	= "mod"
	case rot			//	= "rot"
	case branch			//	= "branch"
	case bulb			//	= "bulb"
	case genBulb		//	= "genBulb"
	case genPrev		//	= "genPrev"
	case flipPrev		//	= "flipPrev"
	case prev			//	= "prev"
	case ago			//	= "ago"
	case genAgo			//	= "genAgo"
	case agoMax			//	= "agoMax"
}

extension Leaf {	/// Generate Common Leafs
	convenience init(_ leafKind:LeafKind, _ etc1:FwConfig=[:], _ etc2:FwConfig=[:],
					 _ etc3:FwConfig=[:], _ etc4:FwConfig=[:], _ etc5:FwConfig=[:]) {
		switch leafKind {
		case .leafClosure(let closure):
			let b 				= ["":"gen", "G":"gen.P", "R":"gen.P"]
			let p				= closure()		//might get e.g. [GenAtom(["n":"gen", "f":1] + etc2)]
			self.init(of:leafKind, bindings:b, parts:[p], leafConfig:etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .`nil_`:
			self.init(of:leafKind, bindings:[:], parts:[], leafConfig:["minSize":"0.5 0.5 0.5"] + etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])	// etc2: WTF?
		case .cylinder:
			self.init(of:leafKind, bindings:[:],
				parts:[
					Cylinder(								etc2),//"size":"1 1 1" +
				],
				leafConfig: 								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genAtom:
			let b 				= ["":"gen", "G":"gen.P", "R":"gen.P"]
			let p				= [GenAtom(["n":"gen", "f":1]/* + etc2*/)]	//etc2=[struc:[1 elts], n:evi, placeMy:stackz 0 -1]
			self.init(of:leafKind, bindings:b, parts:p, leafConfig:etc1)	//etc1=[placeMy:linky]
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genMirror:
			self.init(of:leafKind,
				bindings:bMain + ["G":"gen.P", "R":"gen.P"],
				parts:[
		 			Mirror(["n":"gen", "f":1] 			+ etc2),		//[placeMy:stackx -1 1, struc:[3 elts]]
			], leafConfig:								  etc1)			//[gain:-1, f:1, offset:1, placeMy:linky]
			unusedConfigsMustBeNil([etc3, etc4, etc5])

		 // -------- Broadcast -------------------------------------------------------
		case .bcast:
			self.init(of:leafKind, 
				bindings:bMain + ["G":"P", "R":"P"],
				parts:[
					Broadcast(["n":"main"]  			+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genBcast:					// elim?
			self.init(of:leafKind,
				bindings:bMain + ["G":"gen.P", "R":"gen.P"],
				parts:[
					Broadcast(["n":"main", "P":"gen="]	+ etc3),
		 			GenAtom([  "n":"gen", "f":1] 		+ etc2),
				],
				leafConfig:				 				  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

		case .genMax:
			self.init(of:leafKind, 
				bindings:bMain + ["G":"gen.P", "R":"gen.P"],
				parts:[		// R:NO STATE
					MaxOr([  "n":"main",  "P":"gen="]	+ etc3),
		 			GenAtom(["n":"gen",   "f":1]		+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

		////////// DEFAULT CONTEXT #######################
		case .genMaxSq:
			self.init(of:leafKind, 
				bindings:bMain + ["G":"gen.P", "R":"gen.P"],
				parts:[	// R:NO STATE
					Hamming(["P":"main,l:1",  "jog":"0 0 4"]),		// no sec:main "0, -6, 3" "0, -5, 4"
					MaxOr([	 "n":"main", "P":"gen="]	+ etc3),
					GenAtom(["n":"gen", "f":1]			+ etc2),
				],
				leafConfig:				 				  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
 		 // -------- Bayes -------------------------------------------------------
		case .bayes:
			self.init(of:leafKind, bindings:bMain,
				parts:[
					Bayes(["n":"main"]					+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genBayes:
			self.init(of:leafKind, 
				bindings:bMain + ["G":"gen.P", "R":"gen.P"],
				parts:[
					Bayes([  "n":"main", "P":"gen="]	+ etc3),
		 			GenAtom(["n":"gen", "f":1]			+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

 		// -------- Mod -------------------------------------------------------
		case .mod:
			self.init(of:leafKind, bindings:bMain,
				parts:[
					Modulator(["n":"main"] 				+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		 // -------- Rotator -------------------------------------------------------
		case .rot:
			self.init(of:leafKind, bindings:bMain,
				parts:[
					Rotator(["n":"main"]				+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		 // -------- Branch -------------------------------------------------------
		case .branch:
			self.init(of:leafKind, bindings:bMain,
				parts:[
//					Branch(["n":"rot", "ShareXX":"Bulb", /*"S":sproutSpot, "M":sproutPredicate*/] + etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc2, etc3, etc4, etc5])

		 // -------- Bulb -------------------------------------------------------
		case .bulb:
			self.init(of:leafKind, bindings:bMain, parts:[
				Bulb(["n":"main"]						+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genBulb:
			self.init(of:leafKind, 
//				bindings:bMain + ["G":"gen.P", "R":"gen.P"], parts:[		///2002
				bindings:bMain + ["":"gen", "G":"gen.P", "R":"gen.P"], parts:[
					Bulb([   "n":"main", "P":"gen"] 	+ etc3),	// "gen="
		 			GenAtom(["n":"gen",   "f":1]		+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

		 // -------- Previous -------------------------------------------------------
		case .genPrev:
			self.init(of:leafKind, 
				//let bPrevPM =    ["":"prev.S", "+":"prev.S", "-":"prev.T"					]
				bindings:bPrevPM + ["G":"gen.P", "R":"prev.L"], parts:[
					Previous(["n":"prev", "P":"gen=", "placeMe":"linky"] + etc3),
		 			GenAtom([ "n":"gen",  "f":1]		+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
		case .flipPrev:
			self.init(of:leafKind, 
				bindings:bPrevPM + ["G":"prev.L"/*@0*/, "R":"prev.L"], parts:[		// "G":"gen.P"
					Previous(["n":"prev", "spin":2,"f":1] + etc1),
			], leafConfig:								  etc2)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .prev:
			self.init(of:leafKind, 
				bindings:bPrevPM + ["G":"P", "R":"L"], parts:[
					Previous(["n":"prev", "spinX":1] 	+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])

		 // -------- Ago -------------------------------------------------------
		case .ago:
			self.init(of:leafKind, 
				bindings:["":"ago", "+":"ago"], parts:[
					Ago(["n":"ago"]						+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genAgo:
			self.init(of:leafKind, 
				bindings:bMain + ["G":"gen.P"], parts:[
					Ago([    "n":"main", "P":"gen="] 	+ etc3),
		 			GenAtom(["n":"gen",   "f":1]		+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
		case .agoMax:
			self.init(of:leafKind, bindings:bMain, parts:[
				Ago([  "n":"ago"]						+ etc3),
				MaxOr(["n":"main", "f":1, "P":"ago="]	+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
		//default:
		//	debugger("LeafKind \(leafKind.self) should never happen")
		}
//		groomModel(parent:nil, partBase:partBase)	// groom: add ports[] from children[]
//		fixPorts()
		nop
	}
	 /// Check that unused configuration hashes have nothing in them
	func unusedConfigsMustBeNil(_ unusedConfigs:[FwConfig]) {
		for config in unusedConfigs {
			assert(config.count == 0, "Config:\(config.pp(.line)) should be empty")
		}
	}
}

//	case mPort				= "multiPort"
//	case splitter			= "splitter"
//	case genSplitter		= "genSplitter"
//	case orModBcast			= "orModBcast"
//	case rotBcast			= "rotBcast"
//	case genPrevBcast		= "genPrevBcast		"
//	case prevBcast			= "prevBcast		"
//	case array([LeafKind])	= "array([LeafKind])"
//	case agoDistComb		= "agoDistComb"

//		case .port:
//			self.init(of:leafKind, 
//				bindings:["G":"P", "R":"P"], parts:[
//					 /// 200127 Cannot name Port's name, as it is in bindings as "P"
//					Port(["f":1]						+ etc2 + ["n":"P"]),	//etc2 dominates n:P
//			], fwConfig:				 				  etc1)
//			unusedConfigsMustBeNil([etc3, etc4, etc5])
//		case .mPort:
//			self.init(of:leafKind, 
//				bindings:["G":"P", "R":"P"], parts:[
//					 /// 200127 Cannot name Port's name, as it is in bindings as "P"
//					MultiPort(["f":1]					+ etc2 + ["n":"P"]),	//etc2 dominates n:P
//			], fwConfig:				 				  etc1)
//			unusedConfigsMustBeNil([etc3, etc4, etc5])

// 		// -------- Generic Splitter -------------------------------------------------------
//		case .splitter:
//			self.init(of:leafKind, bindings:[:], parts:[
//				Splitter(["n":"main"]					+ etc2),
//			], fwConfig:								  etc1)
//			unusedConfigsMustBeNil([etc3, etc4, etc5])
//		case .genSplitter:
//			self.init(of:leafKind, 
//				bindings:bMain + ["G":"gen.P", "R":"gen.P"], parts:[
//		 			Splitter(["n":"main", "P":"gen="] 	+ etc3),
//		 			GenAtom([ "n":"gen", "f":1] 		+ etc2),
//			], fwConfig:								  etc1)
//			unusedConfigsMustBeNil([etc4, etc5])

//		case .orModBcast:
//			self.init(of:leafKind, bindings:[:], parts:[			//"G":"gen.P"
//				MaxOr([    "n":"gen", "P":"mod.P="]		+ etc4),
//				Modulator(["n":"mod"] 					+ etc3),	// "mod":"???bid", (spin,0)})),
//				Broadcast(["n":"main", "P":"mod.S="]	+ etc2),
//			], fwConfig:								  etc1)
//		 	unusedConfigsMustBeNil([etc5])

//		case .rotBcast:
//			self.init(of:leafKind, 
//				bindings:bMain + ["G":"gen.P", "R":"gen.P"], parts:[
//					Broadcast(["n":"main", "P":"rot.T=", "latitude":-2, "jog":"0 -0.5 0"] 
//														+ etc3),
//					Rotator([  "n":"rot"]				+ etc2),
//			],fwConfig:									  etc1)
//			unusedConfigsMustBeNil([etc4, etc5])
 ////////// DEFAULT EVIDENCE with Previous's: #######################
//		case .genPrevBcast:
//			self.init(of:leafKind, 
//				bindings:bMainPM + ["G":"gen.P", "R":"prev.L"], parts:[
//					Broadcast(["n":"main-", "P":"prev.T="] + etc4),
//					Broadcast(["n":"main+", "P":"prev.S="] + etc4),
//					Previous([ "n":"prev",  "P":"gen="]  + etc3),
//		 			GenAtom[   "n":"gen",   "f":1  ]	+ etc2),
//			], fwConfig:								  etc1)
//			unusedConfigsMustBeNil([etc5])

						// BASIS port to invoke Previous's con2 to below:
//		case .prevBcast:
//			self.init(of:type:"prevBcast",
//				bindings:bMainPM + ["G":"ERROR-not generatable", "R":"prev.L"], parts:[
//					Broadcast(["n":"main-", "P":"prev.T="] + etc3),
//					Broadcast(["n":"main+", "P":"prev.S="] + etc3),
//					Previous([ "n":"prev", "spin":"R" ]  + etc2),	//??
//			], fwConfig:								  etc1)
//			unusedConfigsMustBeNil([etc4, etc5])
// // -------- qState -------------------------------------------------------
//		case .agoDistComb:
//			self.init(of:leafKind, 
//				bindings:["":"dist", "in":"comb"], parts:[
//				Broadcast(["n":"dist"]					+ etc2), xxx
// //			anAgo     (0,			@{n(ago), 		etc1etc}),	//"comb^"
// //			aBroadcast("ago=",	0,	@{n(dist),		etc2etc}),	//aBayes
//				aBroadcast(0,		0,	@{n(comb),flip, etc3etc, selfStackY}),		// name doesn't work!
//			], fwConfig:								etc1)
//			unusedConfigsMustBeNil([etc4, etc5])
// // -------- qState -------------------------------------------------------
//		case .array(let leafArray):
//			let _ = leafArray	// silences warning
//			debugger("should never happen")
