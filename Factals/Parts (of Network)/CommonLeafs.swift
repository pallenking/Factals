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
//enum LeafKindx: Codable {
//    case nil_
//    case cylinder
//    case closureCase(() -> Int) // Case with a closure returning an Int
//	init(from:Decoder) throws		{ fatalError()}
//	func encode(to:Encoder) throws {}
//}

enum LeafKind: String, Codable, FwAny {
//	case leaf(kind:Leaf)	// Enum with raw type cannot have cases with arguments
	case nil_
	case cylinder
	case genAtom
	case genMirror
	case bcast
	case genBcast
	case genMax
	case genMaxSq
	case bayes
	case genBayes
	case mod
	case rot
	case branch
	case bulb
	case genBulb
	case genPrev
	case flipPrev
	case prev
	case ago
	case genAgo
	case agoMax

	// Decoding
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(String.self)
		guard let value = LeafKind(rawValue: rawValue) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid LeafKind value: \(rawValue)")
		}
		self = value
	}

	// Encoding
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.rawValue)
	}
}
extension Leaf {	/// Generate Common Leafs
	convenience init(_ etc1:FwConfig=[:], _ etc2:FwConfig=[:],
					 _ etc3:FwConfig=[:], _ etc4:FwConfig=[:], _ etc5:FwConfig=[:]) {
		let raw					= etc1["leafKind"]?.asString ?? "genAtom"
//		guard let raw			= etc1["leafKind"]?.asString else { fatalError("leafKind is not specified")}
		let leafKind 			= LeafKind(rawValue:raw)
		switch leafKind {
	//	case .leafClosure(let closure):
	//		let b 				= ["":"gen", "G":"gen.P", "R":"gen.P"]
	//		let p				= closure()		//might get e.g. [GenAtom(["n":"gen", "f":1] + etc2)]
	//		self.init(bindings:b, parts:[p], leafConfig:etc1)			//of:leafKind,
	//		unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .`nil_`:
			self.init(bindings:[:], parts:[], leafConfig:["minSize":"0.5 0.5 0.5"] + etc1)	//of:leafKind,
			unusedConfigsMustBeNil([etc3, etc4, etc5])	// etc2: WTF?
		case .cylinder:
			self.init(bindings:[:],												//of:leafKind,
				parts:[
					Cylinder(								etc2),//"size":"1 1 1" +
				],
				leafConfig: 								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genAtom:
			let b 				= ["":"gen", "G":"gen.P", "R":"gen.P"]
			let p				= [GenAtom(["n":"gen", "f":1]/* + etc2*/)]	//etc2=[struc:[1 elts], n:evi, placeMy:stackz 0 -1]
			self.init(bindings:b, parts:p, leafConfig:etc1)	//of:leafKind,  //etc1=[placeMy:linky]
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genMirror:
			self.init(bindings:bMain + ["G":"gen.P", "R":"gen.P"],	//of:leafKind,
				parts:[
		 			Mirror(["n":"gen", "f":1] 			+ etc2),		//[placeMy:stackx -1 1, struc:[3 elts]]
				], leafConfig:								  etc1)			//[gain:-1, f:1, offset:1, placeMy:linky]
			unusedConfigsMustBeNil([etc3, etc4, etc5])

		 // -------- Broadcast -------------------------------------------------------
		case .bcast:
			self.init(bindings:bMain + ["G":"P", "R":"P"],			//of:leafKind,
				parts:[
					Broadcast(["n":"main"]  			+ etc2),
				], leafConfig:							  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genBcast:					// elim?
			self.init(bindings:bMain + ["G":"gen.P", "R":"gen.P"],		//of:leafKind,
				parts:[
					Broadcast(["n":"main", "P":"gen="]	+ etc3),
		 			GenAtom([  "n":"gen", "f":1] 		+ etc2),
				],
				leafConfig:				 				  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

		case .genMax:
			self.init(bindings:bMain + ["G":"gen.P", "R":"gen.P"],		//
				parts:[		// R:NO STATE
					MaxOr([  "n":"main",  "P":"gen="]	+ etc3),
		 			GenAtom(["n":"gen",   "f":1]		+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

		////////// DEFAULT CONTEXT #######################
		case .genMaxSq:
			self.init(bindings:bMain + ["G":"gen.P", "R":"gen.P"],		//of:leafKind,
				parts:[	// R:NO STATE
					Hamming(["P":"main,l:1",  "jog":"0 0 4"]),		// no sec:main "0, -6, 3" "0, -5, 4"
					MaxOr([	 "n":"main", "P":"gen="]	+ etc3),
					GenAtom(["n":"gen", "f":1]			+ etc2),
				],
				leafConfig:				 				  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
 		 // -------- Bayes -------------------------------------------------------
		case .bayes:
			self.init(bindings:bMain,			//of:leafKind,
				parts:[
					Bayes(["n":"main"]					+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genBayes:
			self.init(bindings:bMain + ["G":"gen.P", "R":"gen.P"],	//of:leafKind,
				parts:[
					Bayes([  "n":"main", "P":"gen="]	+ etc3),
		 			GenAtom(["n":"gen", "f":1]			+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

 		// -------- Mod -------------------------------------------------------
		case .mod:
			self.init(bindings:bMain,		//of:leafKind,
				parts:[
					Modulator(["n":"main"] 				+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		 // -------- Rotator -------------------------------------------------------
		case .rot:
			self.init(bindings:bMain,				//of:leafKind,
				parts:[
					Rotator(["n":"main"]				+ etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		 // -------- Branch -------------------------------------------------------
		case .branch:
			self.init(bindings:bMain,		//of:leafKind,
				parts:[
//					Branch(["n":"rot", "ShareXX":"Bulb", /*"S":sproutSpot, "M":sproutPredicate*/] + etc2),
				],
				leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc2, etc3, etc4, etc5])

		 // -------- Bulb -------------------------------------------------------
		case .bulb:
			self.init(bindings:bMain, parts:[			//of:leafKind,
				Bulb(["n":"main"]						+ etc2),
			], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genBulb:
			self.init(bindings:bMain + ["":"gen", "G":"gen.P", "R":"gen.P"],
				parts:[
					Bulb([   "n":"main", "P":"gen"] 	+ etc3),	// "gen="
		 			GenAtom(["n":"gen",   "f":1]		+ etc2),
				], leafConfig:							  etc1)
			unusedConfigsMustBeNil([etc4, etc5])

		 // -------- Previous -------------------------------------------------------
		case .genPrev:
			self.init(
				bindings:bPrevPM + ["G":"gen.P", "R":"prev.L"],	//of:leafKind,
				parts:[
					Previous(["n":"prev", "P":"gen=", "placeMe":"linky"] + etc3),
		 			GenAtom([ "n":"gen",  "f":1]		+ etc2),
				], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
		case .flipPrev:
			self.init(bindings:bPrevPM + ["G":"prev.L"/*@0*/, "R":"prev.L"],		//of:leafKind,
				parts:[		// "G":"gen.P"
					Previous(["n":"prev", "spin":2,"f":1] + etc1),
			], leafConfig:								  etc2)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .prev:
			self.init(bindings:bPrevPM + ["G":"P", "R":"L"],
				parts:[
					Previous(["n":"prev", "spinX":1] 	+ etc2),
				], leafConfig:							  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])

		 // -------- Ago -------------------------------------------------------
		case .ago:
			self.init(bindings:["":"ago", "+":"ago"], //of:leafKind,
				parts:[
					Ago(["n":"ago"]						+ etc2),
				], leafConfig:							  etc1)
			unusedConfigsMustBeNil([etc3, etc4, etc5])
		case .genAgo:
			self.init(
				bindings:bMain + ["G":"gen.P"], //of:leafKind,
				parts:[
					Ago([    "n":"main", "P":"gen="] 	+ etc3),
		 			GenAtom(["n":"gen",   "f":1]		+ etc2),
				], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
		case .agoMax:
			self.init(bindings:bMain,			//of:leafKind, 
				parts:[
					Ago([  "n":"ago"]						+ etc3),
					MaxOr(["n":"main", "f":1, "P":"ago="]	+ etc2),
				], leafConfig:								  etc1)
			unusedConfigsMustBeNil([etc4, etc5])
		default:
			debugger("LeafKind \(leafKind.self) should never happen")
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
