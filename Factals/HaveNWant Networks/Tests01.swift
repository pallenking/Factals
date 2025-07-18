//  Tests01.swift -- Define interesting small HaveNWant networks C2018PAK
//   The one test marked with x#r() is used for initial network
//								   and the start of ^r updates

import SceneKit

// Sugar for common keys: (eliminates need for ""'s)
//
//  RESERVED WORDS:
// Sugar for L2(target) in Tests01
/*		Examples:
L2("bun/a/prev")		the Atom bun/a/prev
L2("bun/a/prev.S")		the Port bun/a/prev.S
L2("i", [direct:true])	direct link to closet part named "i"
L2("i", ...
L2("a.P")				name ends in "a", the Port name is "P"
*/
// Link to
private func L2(_ name:String, _ config:FwConfig = [:]) -> FwConfig {
	return ["name":name, "direct":false] + config
}
// Direct
private func D2(_ name:String) -> FwConfig {
	return ["name":name, "direct":true]
}

struct ArgKey : ExpressibleByStringLiteral, Hashable {							//	typealias StringLiteralType = String
	init(stringLiteral value: String) {
		self.value = value
	}
	let value:String

/// Names: Parts have a name whose domain is that of the parent Part, or "/" if ROOT with no parent.
	static let n 		: Self = "n"
	static let name		: Self = "name"
	static let named	: Self = "named"

/// Flip: Normal objects have their single port end facing down
	static let f		: Self = "f"
	static let flip		: Self = "flip"
	static let flipped 	: Self = "flipped"

/// Names of common Ports
	static let P		: Self = "P"		// The Primary Port
	static let S		: Self = "S"		// The Secondary Port
	static let T		: Self = "T"		// The Terciary Port
	static let G		: Self = "G"
	static let R		: Self = "R"
	static let share	: Self = "share"	// used to be "sec"

	static let size		: Self = "size"		// of ???
	static let color	: Self = "color"	// of ???

/// MPlacement
	static let placeMy	: Self = "placeMy"	// how my internals are placed
	static let placeMe	: Self = "placeMe"	// how I am placed
	static let parts	: Self = "parts"
	static let struc	: Self = "struc"

	static let expose 	: Self = "expose"
	static let eventLimit:Self = "eventLimit"
	static let jog		: Self = "jog"
	static let physics	: Self = "physics"
	static let gravity	: Self = "gravity"
	static let events	: Self = "events"
	static let simRun	: Self = "simRun"
	static let lookAt 	: Self = "lookAt"
	static let X	 	: Self = "X"
//	1h	macros for: names, flip, spin, placement, 			LANGUAGE
//var flip   					= "flip" : 1
//private let flip 				= ("flip", 1)
//	static let flip1	: Self = ("flip", 1)
//	static let flip0	: Self = ("flip", 0)
	static let spin		: Self =  "spin"
	static let spin_0	: Self =  "spin:0"		// Array control string
//	static let spin$0	: Self = ("spin", "0")	// Hash pair
	static let spin_R	: Self =  "spin:1"
//	static let spin$R	: Self = ("spin", "1")
	static let spin_1	: Self =  "spin:1"
//	static let spin$1	: Self = ("spin", "1")
	static let spin_2	: Self =  "spin:2"
//	static let spin$2	: Self = ("spin", "2")
	static let spin_L	: Self =  "spin:3"
//	static let spin$L	: Self = ("spin", "3")
	static let spin_3	: Self =  "spin:3"
//	static let spin$3	: Self = ("spin", "3")
}

private let n 		= "n"	   	;private let name	= "name"	;private let named	= "named"
private let f		= "f"		;private let flip	= "flip"	;private let flipped = "flipped"
private let P		= "P"		;private let S		= "S"		;private let T		= "T"
private let G		= "G"		;private let R		= "R"
private let share	= "share"	// used to be "sec"
private let size	= "size"	;private let color	= "color"
private let placeMy = "placeMy"	;private let placeMe = "placeMe"
private let stackx	= "stackx"
private let parts	= "parts"
private let struc	= "struc"	;private let of = "of"
//private let fooBar = "fooBar"

private let expose 				= "expose"
private let eventLimit			= "eventLimit"
private let jog					= "jog"
private let physics				= "physics"
private let gravity				= "gravity"
private let events				= "events"
private let simRun 			= "simRun"
private let lookAt 				= "lookAt"
private let X	 				= "X"

//	1h	macros for: names, flip, spin, placement, 			LANGUAGE
//var flip   					= "flip" : 1
//private let flip 				= ("flip", 1)
private let flip1				= ("flip", 1)
private let flip0				= ("flip", 0)

private let spin				=  "spin"
private let spin_0				=  "spin:0"		// Array control string
private let spin$0				= (spin, "0")	// Hash pair

private let spin_R				=  "spin:1"
private let spin$R				= (spin, "1")
private let spin_1				=  "spin:1"
private let spin$1				= (spin, "1")

private let spin_2				=  "spin:2"
private let spin$2				= (spin, "2")

private let spin_L				=  "spin:3"
private let spin$L				= (spin, "3")
private let spin_3				=  "spin:3"
private let spin$3				= (spin, "3")

enum Constants {
	static let spin_L				=  "spin:3"
}
/*
static enum
Constants.spin_L
 */

class Tests01 : Book {

	override func loadTest(args:ScanForKey, state:inout ScanState) {

		super.loadTest(args:args, state:&state)
			 // Some commonly used Environmental variables
		let e 	 : FwConfig		= logAt(8)
		let eSim : FwConfig		= e + [simRun:true]
		let eSimX: FwConfig		= e						// Neuter eSim
		let eTight:FwConfig		= e + [	// For debugging Link positions:
			"ppViewTight"		:true,		// eliminate titles in print
			"ppIndentCols"		:7,			// limit of tree height indentations
			"ppViewOptions"		:"UFVTWB",	// just Posn, World, and FwBBox
			"ppXYZWena"			:"XY",		// 3 axis(xyz), world coords,
			"ppNNameCols"		:6,			// shortened name
			"ppNClassCols"		:6,			// shortened class
			"ppNCols4VewPosns"	:15,
		//	"ppFloatA":5, "ppFloatB":2,		// 2 desimal digits: F5.2 (default is F4.1)
		]
		let eYtight				= eTight + [
			"ppXYZWena"		:"Y",			// Z(=0x4) is ignored
		]
		let eXYtight			= eTight + [
			"ppXYZWena"		:"XY",			// Z(=0x4) is ignored
		]
								//let eXYtight : FwConfig = e + [	// For debugging Link positions:
								//	"ppViewTight"	:true,		 	// eliminate titles in print
								//	"ppIndentCols"	:7,				// limit of tree height indentations
								//	"ppViewOptions"	:"UFVTWB",		// just Posn, World, and FwBBox
								//	"ppXYZWena"		:"XY",			// 3 axis(xyz), world coords,
								//	"ppNNameCols"	:6,				// shortened name
								//	"ppNClassCols"	:6,				// shortened class
								//	"ppNCols4VewPosns":15,
								////	"ppFloatA":5, "ppFloatB":2,		// 2 desimal digits: F5.2 (default is F4.1)
								//]
								//let eYtight				= eXYtight + [
								//	"ppViewOptions"	:"UFVTWB",		// W? just Posn, World, and FwBBox
								//	"ppXYZWena"		:"Y",			// Z(=0x4) is ignored
								//]
								//let eTight				= eXYtight + [
								//	"ppViewOptions"	:"UFVTWB",		// W? just Posn, World, and FwBBox
								//	"ppXYZWena"		:"Y",			// Z(=0x4) is ignored
								//]
		let eYtightX : FwConfig	= [:]
		let eNoUids  : FwConfig	= ["ppNUid4Tree":0, "ppNUid4Ctl":0]
		let eAnim    : FwConfig	= e + ["animatePhysics":true]
		let eW0		 : FwConfig = ["Vews":[]]
		let eW2		 : FwConfig = ["Vews":[VewConfig.openAllChildren(toDeapth:4),
										   VewConfig.openAllChildren(toDeapth:6)],]
		let eW3		 : FwConfig = ["Vew0":VewConfig.openAllChildren(toDeapth:4),
								   "Vew1":VewConfig.openAllChildren(toDeapth:2),
								   "Vew2":VewConfig.openAllChildren(toDeapth:0)]
		let _ = eW3
		 let _					= eSimX + eNoUids + eYtightX // no warning, even if unused
	    //
	   //
	  //
	 //
    //
   //
  // Change just one of the following r() to xr() to select it for building
 //
// ///////////////////////////////////////////////////////////////////////
 // MARK: - * Micro Forms
state.scanSubMenu				= "Micro Forms"
//r(e, { Net([parts:[
//	Broadcast([P:"t1"]),	// Did FAIL (g/t1/t2/ works)
//	Hamming([n:"t1"]),
//]]) })
r("e Part()",   e, { Part() })
r("Port()",		e, { Port() })
r("Atom()",		e, { Atom() })
// Having an Atom having a Part as a child is odd
//r("Atom(Part())",e, {															//	Atom([parts:[Atom([:])]])
//	{	let (p1, p2)	= (Atom(), Part() )
//		p1.children.append(p2)														//	p1.addChild(p2)
//		return p1
//	}()
//} )

// ///////////////////////////////////////////////////////////////////////
 // MARK: - * Basic
state.scanSubMenu				= "Testing"
r("e Nil",			e, { return nil }) 					// no body
r("e Part()",		e, { Part() }) 						// no body
r("Net(Part())",	e, { 	Net([parts:[
		Part()// () -> Net[Part]//
	]])
})
//r("<empty>", e, { Net(["minSize":".5 .5 .5"]) }) 		// no body
//r("<empty>", e, { Part() }) 							// no body
//r("<empty>", e, { Box(["minSize":".5 .5 .5"]) }) 		// +

//r("net flipped", e, { Net([placeMy:"stackx", f:1, parts:[
//	Broadcast([f:0]),
//	Broadcast([f:1]),
//]]) })
//r("for debug", e, { Broadcast([n:"a"]) 		})				// 190311 +

//r("<huh33>", e + selfiePole(s:0,u:0), { Net([placeMy:"linky", parts:[
//	Broadcast([n:"a"]),
//	MaxOr ([n:"or",  share:["a"], f:0, jog:"2 2 0"]),
//									]]) })

// cameraB(h:0,s:-134,u:5)

state.scanSubMenu				= "Primitive Forms"
r("Box",		e, { Box([n:"b", size:SCNVector3(2, 2, 2), color:"red"]) }) 					// +
//r("Port",			e, { Port([n:"port"]) })  		// Broken 191204
//r("Port2",		e, { Port([f:1]) })				// Broken 191204
r("Hemisphere", e + selfiePole(s:-134,u:5), { Hemisphere([jog+X:"2 3 0"])	})
r("TunnelHood", e + selfiePole(s:-134,u:5), { TunnelHood()					})
r("ShapeTest",	e + selfiePole(s:-134,u:5), { ShapeTest()					})
r("Port", 		e + selfiePole(s:-134,u:5), { Port()						})

 // MARK: - * Basic Atoms
state.scanSubMenu				= "Basic Atoms"
r("Broatcast",  		e,	{ Broadcast([n:"a", "lat":0])})				// 190311 +
r("Portless",  			e,  { Portless( [n:"a"]) 		})				// 190311 +
r("Broatcast flipped",	e,  { Broadcast([n:"a", f:1])	}) 				// 190311 +
r("MaxOr", 	   			e,  { MaxOr([    n:"a"]) 		})				// 190311 +
r("MaxOr flipped",		e,  { MaxOr([    n:"a", f:1])	}) 	 			// 190311 +
r("Ago",				e,  { Ago([      n:"a"])		}) 				// 190311 +
r("Previous",			eSim + selfiePole(s:45,u:10), { Previous([n:"a"])})	// 190311 +
r("NetPrevious", eSim + selfiePole(s:45,u:10), {
	Net([placeMy:"stackZ -1", "minSizeX":"3.14159 2 2", parts:[
		Net([placeMy:"stackX -1", "minSizeX":"2.717 3 3", parts:[
			Previous([n:"prev"])
		]]),
		Ago([n:"ago"])
	]])
})

	r("Mirror Display WORKS", e + logAt(8), {
		Net([parts:[
			Sphere(		["size":"1 1 1", "color":"orange"]),		//	//	b.color0		= NSColor.red
			Mirror(),
			Cylinder(	["size":"1 1 1", "color":"red"]),		//		parts.addChild(b)
		] ])
	})
	r("Mirror Display BROKEN", e + logAt(8), {
		Mirror()
	})

	r("Unatomize Net", eSim, {
		Net([expose+X:"atomic",
//			parts:[
//				Mirror()
//			]
		])
	})


r("testing Port BBoxes",e + selfiePole(s:45,u:0),  {
	Leaf([n:"g", of:"genBcast"])		//
} )

r("-bug frame of net wrong", e + selfiePole( s:0, u:0), { Net([placeMy:"stackx -1 -1", parts:[
	Net(),
	Net([parts:[
//		Sphere([size:SCNVector3(0.2, 0.2, 0.2),	color:"red"]),
//		Sphere([size:SCNVector3(0.2, 0.2, 0.2),	color:"orange"]),
		Sphere([size:SCNVector3(0.2, 0.2, 0.2),	color:"yellow"]),
		Sphere([size:SCNVector3(0.2, 0.2, 0.2),	color:"green"]),
	]]),
]]) })
r("-bug with overlap", eSim + selfiePole(s:5,u:5), { Net([placeMy:"stackX -1 0", parts:[
	Rotator()
//	Box(),
//	Sphere([color:"red", size:"0.5 0.5 0.5"]),
]]) })
r("-Hangs as 2'nd ^r", e + selfiePole(s:9, u:3), { Net([placeMy:"stackX -1", parts:[
//	Broadcast(),	//Broadcast(),
//	Mirror(),
	Atom(),
//	Port(),
]]) })
	r("-new Port skin", e + selfiePole(s:0, u:0), {
		Rotator()
//		MinAnd()
//		Mirror()
//		Broadcast()
	})

xxr("+Family Portrait", e + selfiePole(s:-90, u:30) +
			["wBox":"none", lookAt:"tc0"], { Net([placeMy:"stackX -1", parts:[
	Net([placeMy:"stackz 0 -1", parts:[
		Broadcast(),
		MaxOr(),
		MinAnd(),
		Bayes(),
		Hamming(),
		Multiply(),
		KNorm(),
		Sequence([spin:3]),
		Bulb(),
	]]),
	Net([placeMy:"stackz 0 -1", parts:[
		Atom(), // BAD BODY
		Ago(),
		Previous(),
		Mirror(),
		Modulator(),
		Rotator(),
	]]),
	Net([placeMy:"stackz 0 -1", parts:[
		WriteHead(),
		DiscreteTime(),
		TimingChain(),
		WorldModel(),
		GenAtom(),
	]]),
	Net([placeMy:"stackz 0 -1", parts:[
		Box(		[size:SCNVector3(3,  2,  2),	color:"red"]),
		Cylinder(	[size:SCNVector3(1.5,1.5,1.5),	color:"yellow"]),
		Hemisphere(	[size:SCNVector3(2,  2,  2),	color:"green"]),
		TunnelHood(	[size:SCNVector3(1.5,1.5,1.5),	color:"blue"]),
		Sphere(		[size:SCNVector3(2,  2,  2),	color:"[purple]"]),
	]]),
]]) })
	r("-Should never get here", e + selfiePole( s:-90, u:30) +
				["wBox":"none", lookAt:"tc0"], { Net([placeMy:"stackX -1", parts:[
		Bulb(),
		MaxOr(),
		TimingChain(),
		Box(),
	]]) })

r("-Atom overlap", e + selfiePole(s:43, u:30), { Net([placeMy:"linky", parts:[
	Box(		[size:SCNVector3(2, 1, 1)]),
//	Box(		[size:SCNVector3(0.5, 0.5, 0.5)]),
]]) })

// ///////////////////////////////////////////////////////////////////////
 // MARK: - * Nets:
state.scanSubMenu				= "Nets"
r("Net<Bcast", e + selfiePole(s:45,u:30), { Net([n:"a", placeMy:"stackx", parts:[
	Broadcast([n:"b"]),				Broadcast([n:"c"]),
]]) })
r("Net<Sphere", e, { Net([parts:[Sphere([size:"2 2 2"])]]) })													//Works; knob wrong-size bbox
r("Net<Box",    e, { Net([placeMy:"stackx", parts:[
//	Box([n:"a", size:SCNVector3(1, 1, 1), color:"orange"]),
	Box([n:"b", size:SCNVector3(2, 2, 2), color:"red"]),
]]) })
r("net flipped", e, { Net([placeMy:"stackx", f:1, parts:[
	Broadcast([f:0]),				Broadcast([f:1]),
]]) })

// ///////////////////////////////////////////////////////////////////////
 // MARK: - * Stacking:
state.scanSubMenu				= "Stacking"
r("Box stackx 3", e + selfiePole(s:5,u:5) + logAt(8), { Net([placeMy:"stackx -1 -1", parts:[
	Box(			[n:"a", color:"red",    size:"2 2 2"]),
//	Box(			[n:"b", color:"orange", size:"1 1 1"]),
//	Box(			[n:"c", color:"yellow", size:"1 4 1"]),
]]) })
r("+ Splitters family portrait", eXYtight + ["ppXYZMaskX":7] + selfiePole(s:45,u:10), { Net([placeMy:"stackx -1 0", parts:[
	Broadcast(		[n:"a"]),		MaxOr(			[n:"b"]),
	MinAnd(			[n:"c"]),		Bayes(			[n:"d"]),
	Hamming(		[n:"e"]),		Multiply(		[n:"f"]),
	KNorm(			[n:"g"]),		Sequence(		[n:"h"]),
	Bulb(			[n:"i"]),
]]) })
xxr("+ Leaf family portrait", e + selfiePole(s:-6,u:-27,z:0.622), { Net([placeMy:"stackx -1 0", parts:[
	Net([placeMy:"stacky -1 -1", parts:[
		Net([placeMy:"stackz -1 -1", parts:[
			Leaf([n:"a",  of:"nil_"]),
			//Leaf([n:"c",of:"port"]),		Leaf([of:"mPort"]),
			Leaf([n:"d",  of:"genAtom"]),
			//Leaf([n:"e",of:"splitter"]),	Leaf([n:"f", of:"genSplitter"]),
			Leaf([n:"g",  of:"bcast"]),		Leaf([n:"h", of:"genBcast"]),
		] ]),
		Net([placeMy:"stackz -1 -1", parts:[
			Leaf([n:"h",  of:"genMax"]),	Leaf([n:"i", of:"genMaxSq"]),
		] ]),
		Net([placeMy:"stackz -1 -1", parts:[
			Leaf([n:"j", of:"bayes"]),		Leaf([n:"k", of:"genBayes"]),
			Leaf([n:"l", of:"mod"]),		Leaf([n:"m", of:"rot"]),
		] ]),
	] ]),
	Net([placeMy:"stackz -1 -1", parts:[
		Net([placeMy:"stackz -1 -1", parts:[
			Leaf([n:"o", of:"branch"]),
			Leaf([n:"p", of:"bulb"]),		Leaf([n:"q", of:"genBulb"]),
			Leaf([n:"n", of:"rot"]),
			Leaf([n:"b", of:"cylinder"]),
		] ]),
		Net([placeMy:"stackz -1 -1", parts:[
			Leaf([n:"t", of:"prev"]),
			Leaf([n:"r", of:"genPrev"]),
			Leaf([n:"s", of:"flipPrev"]),
		] ]),
		Net([placeMy:"stackz -1 -1", parts:[
			Leaf([n:"u", of:"ago"]),		Leaf([n:"v", of:"genAgp"]),	Leaf([n:"w", of:"agoMax"]),
		] ]),
	] ])
] ] ) } )

r("- bug crept in Leaf([n:'i', of:'genMaxSq'", e + selfiePole(s:-6,u:-27,z:0.622), {
	Net([placeMy:"linky -1 0", parts:[
	//	Hamming([P:"main"]),
	//	MaxOr([	 n:"main"]),
		Leaf([n:"i", of:"genMaxSq"]),
//		Hamming(["P":"bbb"]),	//"share"
//		MaxOr([	 "n":"bbb", f:1]),
	]
] ) } )

	r("- Leaf Branch BUG", e + selfiePole(s:-6,u:-27,z:0.622), { Net([parts:[
		Leaf([n:"o", of:"branch"]),
	] ] ) } )
	r("- repaint bug", e + selfiePole(s:-6,u:-27,z:0.622), { Net([placeMy:"stackx -1 0", parts:[
//		Leaf([n:"c", of:"port"]),
//		Leaf([n:"p", of:"bulb"]),
//		Leaf([n:"t", of:"prev"]),
	] ] ) } )


r("- skin missing", e + selfiePole(s:45,u:10) + vel(-4) + logAt(), { Net([placeMy:"stackx -1 0", parts:[
	Leaf([of:"rot"]),		// nil_ genMaxSq, [n:"i"]),
] ] ) } )
	r("- skin missing", e + selfiePole(s:45,u:10) + vel(-4) + logAt(), { Leaf([of:"nil_"]) } )

r("Leaf problem child", e + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
//	Broadcast(["n":"main", "Px":"rot.T=", "latitude":1, "jogx":"0 -1.5 0"]),
	Leaf([n:"s", of:"flipPrev"]),
//	Leaf([n:"n", of:"rotBcast"]),
//	Leaf([n:"o", of:"branch"]),
//	Hamming(  [P:"main,l:1", "jog":"0 0 4"]),		// no share:main "0, -6, 3" "0, -5, 4"
//	MaxOr(	  [n:"main",  P:"gen="]),
//	GenAtom(  [n:"gen",   f:1]),
//	Leaf([n:"i", of:"genMaxSq"]),
] ] ) } )
r("-transform * bBox", e + selfiePole(s:0,u:90), { Net([parts:[
	CommonPart([size:"2 1 4", spin:3]),
] ] ) } )




 //  180323 Second Port is not a full Atom, placed bad:
//r({ Net([parts:[Port(), Port()]]) })		// BAD (both Ports placed at 0)
//r({ Net([parts:[Box([size:SCNVector3(0.5,  3, 0.5),]), Port()]]) }) // BAD
//r({ Net([parts:[Port(), Ago()]]) })			// BAD
//r({ Net([parts:[Port(), Previous()]]) })	// BAD

//let gen1 = {
//	(config:FwConfig) -> Part in
//	return Leaf(.bcast, config)		// a simple thing to get started
//}

r("Bundles2, BUG?noBBox", e + selfiePole(s:90), { Net([placeMy:"stackz", parts:[//(s:45,u:10)
	Net([placeMy:"stackx", parts:[
		Sphere([n:"a", size:"0.6 0.6 0.6"]),
		Sphere([n:"b", size:"0.6 0.6 0.6"]),
	] ]),
	Net([placeMy:"stackx", parts:[
		Sphere([n:"c", size:"0.6 0.6 0.6"]),
		Sphere([n:"d", size:"0.6 0.6 0.6"]),
	] ]),
] ] ) } )

  // MARK: - * Skins (for Net, FwBundle, Leaf, and Splitter)
 // To test out the display of (aka Broadcast)
// :H: Atom Net FwBundle Tunnel Link Splitter Cylinder
state.scanSubMenu				= "Skins for Net"
r("SKIN: C", e, { Cylinder([n:"cyl"]) })							// +
r("SKIN: S", e, { Broadcast([n:"bcast"]) })						// +
r("SKIN: NC", e + selfiePole(s:45,u:10), { Net([placeMy:"stackx", parts:[
	Cylinder([n:"a", color:"orange"]),
	Cylinder([n:"b", color:"yellow"])									] ] ) } )
r("SKIN: BC", e + selfiePole(u:10), { FwBundle([placeMy:"stackx", parts:[
	Cylinder([n:"a", color:"yellow"]),
	Cylinder([n:"b", color:"orange"]),									] ] ) } )
//"SKIN: TC" malformed
r("SKIN: NL", e + selfiePole(s:0,u:0), { Net([placeMy:"stackx", parts:[
	Leaf([n:"leaf", of:"genAtom"])											] ] ) } )
r("SKIN: L",  e + selfiePole(s:45,u:10), 	{		Leaf([of:"genAtom"])				  } )
r("SKIN: LC", e + selfiePole(s:1, u:1,  z:1), {		Leaf([of:"cylinder"]) 		  } )
r("SKIN: LS", e + selfiePole(s:45,u:10), 	{		Leaf([of:"bcast", n:"a"]) 		  } )

r("-SKIN: BC", e + selfiePole(u:10), { FwBundle([placeMy:"stackx", parts:[
	Sphere([n:"a", color:"orange"]),									] ] ) } )

 // Leafs in various forms:
// stack direction bad
r("SKIN: NBtLS", e + selfiePole(s:45,u:10), { Net([placeMy:"stackx", parts:[
	FwBundle([n:"bun", struc:["a"], "of":"bcast", placeMy:"stackz"]),//, "b", "c", "d"
//	Tunnel([n:"tun", s  truc:["d", "e", "f"], placeMy:"stackz"]),
] ] ) } )
r("SKIN: BLS", e + selfiePole(s:0, u:0), {	//, "f", "g"
	FwBundle([n:"bun", struc:["a", "b", "c", "d", "e"], "of":"bcast", placeMy:"stackZ", expose+X:"atomic"])	//, "b"
} )
//r("-bug SKIN: TLS", e + selfiePole(s:90, u:0), {
//	Tunnel(of:.port, tunnelConfig:[n:"tun", struc:["a"], "of":"bcast", placeMy:"stackZ"])//"a", "b"
//})

 // Auto Broadcast: (GOOD TEST)
state.scanSubMenu				= "+ Auto Broadcast"
xxr("+ auto-bcast", eSim + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
	MinAnd([P:"a"]),  MinAnd([P:"a"]),  MinAnd([P:"a"]),
	MinAnd([P:"b"]),  MinAnd([P:"b"]),  MinAnd([P:"b"]),
	MinAnd([P:"c"]),  MinAnd([P:"c"]),  MinAnd([P:"c"]),
	MinAnd([P:"c.-"]),MinAnd([P:"c.-"]),MinAnd([P:"c.-"]),
	FwBundle([placeMy:"stackz 0 -1", parts: [
		FwBundle([struc:["a"], of:"genAtom", placeMy:"stackx -1 1"]),
		FwBundle([struc:["b"], of:"bcast",   placeMy:"stackx -1 1"]),
		FwBundle([struc:["c"], of:"prev",    placeMy:"stackx -1 1"], leafConfig:["value":"1.0"]),
	] ]),
] ] ) } )
	r("+ auto-bcast upward and downward", eSim + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MaxOr([n:"a1", P:"a"]), /**/ MinAnd([n:"a2", P:"a"]), /**/ Broadcast([n:"a3", P:"a"]),
		Previous([n:"a"]),
		FwBundle([struc:["b1", "b2", "b3"], of:"bcast", placeMy:"stackx -1 1"],
				 leafConfig:[share:"a.P", "value":"1.0"]),
	] ] ) } )
		r("+ auto-bcast upward", eSim + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
			MinAnd([P:"c"]),  MinAnd([P:"c"]), //MinAnd([P:"c"]),
			Broadcast([n:"c"]),
		] ] ) } )
	r("- auto-bcast ...1", e + selfiePole(s:5,u:5), { Net([placeMy:"linky", parts:[
		MinAnd([P:"a"]), MinAnd([P:"a"]),
		FwBundle([placeMy:"stackz 0 -1", parts: [
			FwBundle([struc:["a", "b"], of:"genAtom", placeMy:"stackx -1 1"]),
		] ]),
	] ] ) } )
	r("- auto-bcast ...2", e + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MinAnd([P:"a"]),   MinAnd([P:"a.+"]), MinAnd([P:"a"]),
		MinAnd([P:"a.-"]), MinAnd([P:"a.-"]), MinAnd([P:"a.-"]),
		FwBundle([struc:["a"], of:"prev"]),//prev//ge∂akinsnAtom//port//
	] ] ) } )

	r("- path bad", eSim + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
	//	MinAnd([P+X:"c.-"]),
	//	Previous([n:"c"])
		FwBundle([struc:["c"], of:"prev",    placeMy:"stackx -1 1"], leafConfig:["value":"1.0"]),
	] ] ) } )
	r("- port occupied", eSim + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MinAnd([P:"c"]),  MinAnd([P:"c"]),  MinAnd([P:"c"]),
		//Previous([n:"c"])
		Broadcast([n:"c"])
	] ] ) } )

	xxr("- binding-path", eSim + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MinAnd([P:"a"]), // MinAnd([P:"a"]),  MinAnd([P:"a"]),
		FwBundle([struc:["a"], "of":"bcast", placeMy:"stackx -1 1"]),		//of:.genAtom,
	] ] ) } )
	r("- path did not find Port", e + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MinAnd([P:"a"]), //MinAnd([P:"a"]), //MinAnd([P:"a"]),
		FwBundle([struc:["a"], of:"genAtom", placeMy:"stackx -1 1"], leafConfig:["value":1.0]),
	] ] ) } )
	r("- .genAtom no port 'G'", e + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		FwBundle([struc:["a"], of:"genAtom", placeMy:"stackx -1 1"]),
	] ] ) } )

	r("-already connected", e + selfiePole(s:45,u:10) + logAt(8), { Net([placeMy:"linky", parts:[
		MinAnd([P:"c", jog:"1 0 0"]),  MinAnd([P:"c"]),  MinAnd([P:"c"]),
	//	Previous([n:"c"]),
		FwBundle([struc:["c"], of:"genAtom"], leafConfig:["value":1.0]),
	] ] ) } )
	r("-already connected", e + cameraX(s:45,u:10) + logAt(8), { Net([placeMy:"linky", parts:[
		MinAnd( [P:"c", jog:"1 0 0"]),  MinAnd([P:"c"]),  //MinAnd([P:"c"]),
		GenAtom([n:"c", "value":"1.0", f:1])
	] ] ) } )
	r("-missing link", e + selfiePole(s:0,u:0), { Net([placeMy:"linky", parts:[
		MinAnd([P:"a", jog:"1 0 0"]),
	//	MinAnd([P:"a"]),
		Broadcast([n:"a", f:1])
	] ] ) } )
	r("-bug: two ports named \"\"", e + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MinAnd([P:"b"]), MinAnd([P:"b"]), MinAnd([P:"b"]),
		Broadcast([n:"b"])
	] ] ) } )

	r("-matchingPart", e + selfiePole(s:45,u:10), { Net([placeMy:"linky", parts:[
		MinAnd([P:"c.-"]),
		FwBundle([struc:["c"], of:"prev", placeMy:"stackx -1 1"]),
	] ] ) } )
	r("-Path error", e + selfiePole(s:180,u:0), { Net([placeMy:"linky", parts:[
		MinAnd([P:"c", jog:"2 0 0"]),
		Broadcast([n:"c", f:1])
//		Previous([n:"c"])
	] ] ) } )

r("one link", e + selfiePole(s:5,u:5), { Net([placeMy:"linky", parts:[
	MinAnd([n:"a", P:"b"]),
	MinAnd([n:"b"])
] ] ) } )
	r("-port(named bug", e + selfiePole(s:0,u:0), { Net([placeMy:"linky", parts:[
//		MinAnd([	n:"c", P:"a.S"]),
		MinAnd([	n:"b", P:"a"]),
		Previous([	n:"a"]),					// works when done
//		FwBundle([struc:["a"], of:"prev"]),	// works now
	] ] ) } )
	r("-Previous size", e + selfiePole(s:0,u:0), {
//		MinAnd()			// works
		Previous()
	} )

r("SKIN: LS", e + selfiePole(s:45,u:10), 	{	Leaf([n:"a", of:"genAtom"/*Bcast*/, placeMy:"stacky"])})
r("Testing bcast. \"\"", e + selfiePole(u:0), { Net([placeMy:"linky", parts:[
	MinAnd([f:1, share:"a"]),
//	MinAnd([f:1, share:".a"]),
	Tunnel([struc:["a"], of:"genAtom", placeMy:"stackx -1 1"]),
] ] ) } )
// MARK: * + blink and click
state.scanSubMenu				= "+ blink and click"
			//let tickTock	= ["b","tick","t","tock"]		// tick b		// b t
			let tickTock	= ["tock","tick","tock","tick"]	// tick b		// b t
			//let tickTock	= ["tick","b","tock","t"]		// tick b		// tick bewlfuwo
			//let tickTock	= ["tick","","tock",""]			// tick tock
			//let tickTock	= ["tick","tock","",""]			// does both
			//let tickTock	= ["","tick","","tock"]			// does both

var a00:String 	{ 	"a,v:1"									}	// Unison
var a01:String 	{ 	"a,v:\(String(randomDist(0.0, 0.5)))"	}	// Random
var a02:String 	{ 	"a,v:\(String(randomDist(0.0, 0.9)))"	}	// Random Big
var a03:String 	{ 	"a,v:\(String(randomDist(0.0, 0.0)))"	}	// Unison
var a1:String 	{												// Binary Counter:
	aOffset			+= 1
	let vVal		= aOffset//log(a2offset+3)
	return "a,v:-\(String(vVal))"		 //\(String(a2offset))
}
var a2:String 	{												// Wave
	aOffset			+= 0.1
	let vVal		= aOffset//log(a2offset+3)
	return "a,v:-\(String(vVal))"		 //\(String(a2offset))
}
var aOffset = 0.0

xxr("+ simple blink tick", eSimX + eYtight + vel(0) + selfiePole(h:5.0, s:45,u:0,z:2.0)
			+ ["lookAtX":"b"], { Net([placeMy:"linky", parts:[
	Bulb(  		[n:"d", P:"a,v:3.5"]),	// ,l:4
//	Bulb(		[n:"b", P:"a,v:3.5"]),
	MaxOr(		[n:"b", P:"a,v:3.5"]),
//	Mirror(		[n:"b", P:"a,v:4"]),
 //	PortSound(	[n:"c", "inP":"b.P", "sounds":tickTock]),
	Mirror(		[n:"a", "gain":-1, "offset":1, f:1]),
] ]) })
 
////	FwBundle([struc:["a","b"/*,"c","d","e","f"*/]/*, of:"genAtom"*/, placeMy:"stackx -1 1"]) {			//"a","b","c","d","e","f","g","h"
xxr("- way extra size", eSimX + eYtight + vel(-4) + selfiePole(h:5.0, s:0, u:10, z:2.0)
			+ ["animateVBdelay":1.0], { Net([placeMy:"stackx", parts:[
	Net([placeMy:"linky", parts:[
		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),	// 3:ok,4:fails
//		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),
//		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),
		Mirror([n:"b", P:"a,v:3", jog:"4", "latitude":-1, "spinX":"1"]),
		PortSound([n:"snd1", "inP":"b.P", "sounds":tickTock, "soundVolume":10.0 ]),
//		PortSound([n:"snd1", "inP":"a.P", "sounds":tickTock, "soundVolume":10.0 ]),
		Mirror([n:"a", "gain":-1, "offset":1, f:1]),
//		Mirror([n:"b", P:"a,v:3", jog:"4", "latitude":-1, "spinX":"1"]),
//		PortSound([n:"s1", "inP":"b.P", "sounds":tickTock, "soundVolume":5.0 ]),
//		Mirror([n:"a", "gain":-1, "offset":0, f:1]),
	] ])
] ]) })
var a8:String {"a,v:\(String(randomDist(3.0, 5.0))),l:3" }
xxr("- bulb doesn't animate", eSimX + eYtight + vel(-4) + selfiePole(h:5.0, s:0, u:10, z:3.0)
			+ ["animateVBdelay":3.0], { Net([placeMy:"linky", parts:[
	Bulb(  [n:"x", P:"a,v:4.0,l:3"]),
	Mirror([n:"y", P:"a,v:1.5,l:3"]),
//	PortSound([n:"snd1", "inP":"a.P", "sounds":tickTock, "soundVolume":0.0 ]),
	Mirror([n:"a", "gain":-1, "offset":1, f:1]),
 ] ]) })
xxr("- animate size ??", eSimX + eYtight + vel(-4) + selfiePole(h:5.0, s:0, u:10, z:2.0)
			+ ["animateVBdelay":0.1], { Net([placeMy:"stackx", parts:[
	Net([placeMy:"linky", parts:[
//		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),
		Bulb([P:a8]),	//	Bulb([P:a8]),		Bulb([P:a8]),
		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),		Bulb([P:a8]),
		Mirror([n:"b", P:"a,v:3", jog:"4", "latitude":-1, "spinX":"1"]),
		PortSound([n:"s1", "inP":"b.P", "sounds":tickTock, "soundVolume":0.0 ]),
		Mirror([n:"a", "gain":-1, "offset":1, f:1]),
	] ])
] ]) })



xxr("- atomicToggle bug",eYtight, { Net([placeMy:"linky", parts:[
	Net([expose:"atomic", parts:[
		Broadcast([P:"a"]),		//Bulb
	] ]),
	Mirror([n:"a", f:1]),
 ] ]) })
xxr("- atomicToggle bug",eYtight, { Net([placeMy:"linky", parts:[
	Mirror([n:"b", P:"a,v:4,l:3", jog+X:"4"]),	//+X
	Mirror([n:"a", "gain":-1, "offset":1, f:1]),
 ] ]) })
		xxr("- bug: ???", e + selfiePole(s:0,u:0), { Net(["parts":[
			Mirror(  [n:"x", f:0, P:"y,v:1,l:2", "gain":-1, "offset":1]),
			Sequence([n:"y", f:1, spin:12, "share":["a,v:5","b,v:5","c,v:5","d,v:5"]]),
			Tunnel([struc:["a","b","c","d"], of:LeafKind.genBulbMirror])//genMirror]),//genBulbMirror]),
//			Tunnel([struc:["a","b","c","d"], of:LeafKind.genMirror]),//:"genMirror"
		]]) })
		xxr("- bug: ???", e + selfiePole(s:0,u:0), { Net(["parts":[
//			Mirror(  [n:"x", f:0, P:"y,v:1,l:2", "gain":-1, "offset":1]),
			Sequence([n:"y", f:1, spin:12, "share":["a,v:5"]]),
			Broadcast([n:"a"]),
//			Tunnel([struc:["a"], of:LeafKind.genMirror])//BulbMirror]),
		]]) })

	r("-+ stackx does linky", [:], { Net([placeMy:"stackx", parts:[
		Sphere(),//[placeMe:"stackx"]),
		Box(   ) //[placeMe:"stackx"]),
	 ] ]) })

xxr("+ Atom.reSize bug", eSimX + vel(-4) + selfiePole(h:5.0, s:45,u:0,z:2.0) + ["lookAtX":"b"], {
	Net([placeMy:"linky", spin:4, parts:[
		Bulb([P:"a,l:3"]),//+X
		Mirror([n:"b", P:a2, jog:"4", "latitude":-1, "spinX":"1"]),		//a2//"a,v:-1"
		PortSound([n:"s1", "inP":"a.P", "sounds":tickTock]),
		Mirror([n:"a", "gain":-1, "offset":1, f:1]),
	] ] )
})

xxr("+ blinking flowers", e + selfiePole(s:45,u:10,z:1.5) + logAt(0) + vel(-5), { Net([placeMy:"linky", parts:[
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),		Bulb([P:a9]),
	Mirror([n:"b", P:"a", jog:"4"]),
	PortSound([n:"s1", "inP":"a.P", "sounds":tickTock]),
	Mirror([n:"a", "gain":-1, "offset":1, f:1]),
] ] ) } )
var a9:String { "a,v:-\(String(randomDist(0.0, 1.0))),l:\(String(randomDist(4.0, 6.0)))" }

	xxr("Testing 'share'", eSim + selfiePole(s:45,u:10,z:1.5) + logAt(0) + vel(-6), { Net([placeMy:"linky", parts:[
		Bulb(  [n:"u", P:"a"]),
		Mirror([n:"a", P+X:"u", "gain":-1, "offset":1, f:1]),
	] ] ) } )
	r("Bulb sizing", eSim + vel(-7) , { Net([placeMy:"linky", parts:[
		Bulb([  n:"b", P:"m"]),  				// Broadcast
		Mirror([n:"m", P+X:"b", "gain":-1, "offset":1, f:1]),
	] ]) })
	r("-Bulb as disc", eSim + vel(-7) , { 	Bulb([n:"u"])  						})
	r("SKIN: LC", e + selfiePole(s:1,u:1), 	{	Leaf([n:"a", of:"bcast"])		})

// NB: Some bugs only showed up with a repaint (hit P): state in existing vew.
r(e + selfiePole(u:20), { Net([parts:[Box(), Box()]]) })
r(e + selfiePole(u:20), { Net([parts:[Box()]]) })

// // MARK: - * Tunnels:
// 200102: BUG: Timmel placement bad
state.scanSubMenu				= "Tunnels"
// HANGS in positioning Port 'c':
r("False Ago Bcast overlap", e + selfiePole(s:2,u:2), { Net([placeMy:"linky", parts:[
	Tunnel([struc:["c"], of:"bcast", placeMy:"stackZ"]) // , "d"  .port .genAtom .prev .agoMax Bcast
]]) } )
//r("False Ago Bcast overlap", e + selfiePole(s:1,u:1), { Tunnel([
//	struc:["c", "d"], of:"bcast", placeMy:"stackz"]) // .port .genAtom .prev .agoMax Bcast
//} ) // "c"
//r("Testing Tunnel Port placement", e + selfiePole(s:1,u:1), {
//xxx Tunnel([placeMy:"stackx -1 1"])//struc:["a", "b"],
//} )
//r("Testing Tunnel Port placement", e + selfiePole(s:1,u:1), { Net([placeMy:"linky", parts:[
//	Tunnel([parts:[		Sphere(),		]]),
//] ] ) } )
//r("Tunnel skin bad2", e, { Tunnel([parts: [Broadcast()]]) } )
//r("Tunnel-Tunnel", e + selfiePole(s:90, u:0), { Net([placeMy:"linky", parts:[
//	Tunnel([n:"t2", struc:["a", "b"], of:"owvwov", placeMy:"stackZ", P:"t1"]),
//	Tunnel([n:"t1", struc:["a", "b"], of:"owvwov", placeMy:"stackZ", f:1]),
//]]) })

 // MARK: - * Open/Atom:
state.scanSubMenu				= "Open Atom"
r(e + selfiePole(u:0), { Box([expose:"atomic",  size:"2 2 2"]) })		// test 3D Cursor Pole placement on Atom
r(eSim + selfiePole(u:0) + ["inspec":"ROOT/net0"],//atomic//invis//
	{ Net([expose+X:"invis", parts:[ Box([size:"2 2 2"])]]) })
r(e + selfiePole(u:0), { Net([placeMy:"stackX", parts:[
	Sphere(),
	Net([placeMy:"stackX", parts:[Box()]]),
//	Box(),
]]) })
r("-DC Atom", e + selfiePole(u:20, z:1.5), { Net([placeMy:"stackx", parts:[
	Net([expose:"atomic"]),
//	Net([expose:"atomic", parts:[Box()]]),
]]) })
	r("-DC Atom", e + selfiePole(u:20, z:1.5), { Net([parts:[Box()]])})
	r("-Atomic Net", e, { 	Net([expose:"atomic"])	})
// 190319PAK: extra spaces around inner nets
r(e + selfiePole(u:20), { Net([placeMy:"stackX",parts:[  // Pretty
	Net([placeMy:"stackZ", expose:"atomic",  parts:[ Box([n:"ba"]), Box([n:"ba"]),  ]]),
	Net([placeMy:"stackZ", expose:"atomic",  parts:[ Box([n:"ca"]), Box([n:"ba"]),  ]]),
]]) })
r("close/open fails", eSim + selfiePole(u:20) + ["inspec":"ROOT/net0/m"],{
  Net([placeMy:"stackX",parts:[  // Pretty
 	Previous([n:"g", expose:"open", color:"green"]),//open/atomic/invis//
 	MaxOr([   n:"m", ]),
//	Box([     n:"r", expose:"invis",  color:"red"]),
//	Box([     n:"o", expose:"atomic", color:"orange", size:"2 2 2"]),
	Net([     n:"n", expose:"atomic", placeMy:"stackZ", parts:[
		Box([ n:"ba"]), Sphere([n:"bb", color:"red"]), Box([n:"bc"]) ]]),
]]) })
r("atomic bug", eSim + selfiePole(u:20) + ["inspec":"ROOT/net0/m"],{
	Net([     n:"n", expose:"atomic", placeMy:"stackZ", parts:[
		Box([ n:"ba"]),
]]) })
	r(" Open/Close Atomic test", e + selfiePole(s:100, u:10), { Net([placeMy:"stackX -1 0", parts:[        //"bundle",
			Bayes(),
	]]) })

	r("atom color not black", eSim + selfiePole(u:20), {
		Box([expose:"atomic", color:"orange"])
	})

// Good complex test
r("+ Open/Close Atomic test", e + selfiePole(s:0, u:10), { Net([placeMy:"stackX -1 0", parts:[        //"bundle",
	Net([placeMy:"stackZ 0 -1", parts:[
		MaxOr(),
		Broadcast(),
		MinAnd(),
	]]),
	Net([placeMy:"stackZ 0 -1", parts:[
		Bayes(),
		Hamming(),
		Multiply(),
	]]),
	Net([placeMy:"stackZ 0 -1", parts:[
		KNorm(),
		Sequence(),
		Bulb(),
	]]),
]]) })
r("+ Open/Close Atomic test", e + selfiePole(s:100, u:10), { Net([placeMy:"stackX -1 0", parts:[        //"bundle",
//	Net([placeMy:"stackZ 0 -1", parts:[
		Bayes(),
//		Hamming(),
//		Multiply(),
//	]]),
]]) })
r("erant bundle skirt position", e + selfiePole(s:90, u:0), { Net([placeMy:"stackZ -1 -1", parts:[        //"bundle",
//	Net([n:"a", parts:[		Box(),	]]),
	[Box([n:"a"]), Net([n:"a"])][1],
	Net([n:"b", parts:[		Box(),	]]),
//	Net([n:"c", parts:[		Box(),	]]),
]]) })
r("190527-Bug Port placement", e + selfiePole(s:0, u:10), { Net([placeMy:"stackX -1 -1", parts:[        //"bundle",
	Hamming(),
//	Net([placeMy:"stackZ", expose+X:"atomic",  parts:[
//		Hamming(),	Hamming(),
//	]]),
]]) })
r("190528-Dual Ports vew", e + selfiePole(s:0, u:30), { Net([placeMy:"stackY", parts:[        //"bundle",
	Broadcast()
]]) })
r(e + selfiePole(s:0, u:30), { Net([placeMy:"stacky", parts:[
	Net([placeMy:"stackZ", flip:1, parts:[Broadcast(), Broadcast(), Broadcast(), Broadcast(),]]),
	Box([size:"0.2 2 0.2"]),
	Net([placeMy:"stackZ", parts:[
		Net([placeMy:"stackX", parts:[Hamming(), Hamming(), Hamming(), Hamming()]]),
		Net([placeMy:"stackX", parts:[Hamming(), Hamming(), Hamming(), Hamming()]]),
		Net([placeMy:"stackX", parts:[Hamming(), Hamming(), Hamming(), Hamming()]]),
		Net([placeMy:"stackX", parts:[Hamming(), Hamming(), Hamming(), Hamming()]]),
	]]),
]]) })
r(e + selfiePole(s:90), { Net([placeMy:"stacky", parts:[
	Net([placeMy:"stackz", flip:1, parts:[Sphere(),Sphere(),]]),
	Box([size:"2 2 2"]),
]]) })
r("-placement bug", e + selfiePole(s:90), { Net([placeMy:"stackZ", parts:[
	Net([parts:[ Broadcast()]]),
	Hamming(),
]]) })
r("-placement bug", e + selfiePole(s:90), { Net([placeMy:"stacky", parts:[
	Net([placeMy:"stackZ", flip:1, parts:[Broadcast(), Broadcast()]]),
]]) })
r("-placement bug", e + selfiePole(s:90), { Net([placeMy:"stacky", parts:[
	trueF ? Net([placeMy:"stackZ", flip:1, parts:[Broadcast()]]) : Broadcast([flip:1]),
	Hamming()
]]) })
r(e + selfiePole(s:0, u:0), { Net([placeMy:"stackX", parts:[ /// BUG: Bulb size
	Broadcast([expose:"atomic"]), Bulb(),  Bulb(),  //Bulb(),  Bulb(),  Bulb(),
]]) })


   // //////  Formation of    _ L I N K S _   :
  // //
 // /////////////// Baseline (no link)
 // MARK: - * Links:
 // MARK:  All in One
//let phys						= physics+X				// turn all physics OFF
let phys						= physics				// turn all physics ON
state.scanSubMenu				= "Links"
let j							= SCNVector3(2,0,0)
r("+ All various flips A",  e + selfiePole(s:30, u:30), { Net([placeMy:"stackx", parts:[
  	Net([n:"n0", placeMy:"linky", parts:[
		Broadcast([n:"b",		]),
		Broadcast([n:"a", 		f:1, jog:j]), //*Link+P,P
  	] ]),
  	Net([n:"n1", placeMy:"linky", parts:[
		Broadcast([n:"b",		]),
		Broadcast([n:"a",P:"b", f:1, jog:j]), //*Link+P->P
	] ]),
	Net([n:"n2", placeMy:"linky", parts:[
		Broadcast([n:"b", P:"a"	]),
		Broadcast([n:"a", 		f:1, jog:j]), //*Link+P<-P
	] ]),
	Net([n:"n3", placeMy:"linky", parts:[
		Broadcast([n:"b", f:1	]),
		Broadcast([n:"a",P:"b", f:1, jog:j]), //*Link+P->S
	] ]),
	Net([n:"n4", placeMy:"linky", parts:[
		Broadcast([n:"b", P:"a"	]),
		Broadcast([n:"a"		   , jog:j]), //*Link+S->P
	] ]),
	Net([n:"n5", placeMy:"linky", parts:[
		Broadcast([n:"b",		]),
		Broadcast([n:"a",share:"b"   , jog:j]), //*Link+S->P
	] ]),
	Net([n:"n6", placeMy:"linky", parts:[
		Broadcast([n:"b", f:1	]),
		Broadcast([n:"a",share:"b"   , jog:j]), //*Link+S->S
	] ]),
	Net([n:"n7", placeMy:"linky", parts:[
		Broadcast([n:"t1", f:1	]),
//bug	Link([S:"t1", P:"t2"]),
		Broadcast([n:"t2", phys:[gravity:1], jog:"4 0 0"]),
	] ]),
] ]) } )

// :
xxr("- explicit Link broken",  e + selfiePole(s:30, u:30), { Net([placeMy:"stackx", parts:[
	Broadcast([n:"t1", share:"t2", f:1	]),
	 // Enable this for a bug:
 	//Link([S:"t1", P:"t2"]),
	Broadcast([n:"t2", flip:0, jog:"4 0 0"]),
] ]) } )


r("+ All various flips B", eXYtight + selfiePole(s:0,u:0) + logAt(dat:5, eve:5), {
	Net([placeMy:"stackx", parts:[
		Net([placeMy:"linky", parts:[	// AC
			Broadcast([n:"ma", P:["x,l:5,t:dual"],jog:"0 0 2"]),	// A
			MaxOr(	  [n:"x", f:1]),								// C
		]]),
		Net([placeMy:"linky", parts:[	// BC
			Broadcast([n:"ma", share:["x,l:5,t:dual"], f:1]),		// B
			MaxOr(	  [n:"x", f:1]),								// C
		]]),
		Net([placeMy:"linky", parts:[	// AD
			Broadcast([n:"ma", P:["x,l:5,t:dual"],jog:"0 0 2"]),	// A
			MaxOr(	  [n:"x"]),										// D
		]]),
		Net([placeMy:"linky", parts:[	// AD
			Broadcast([n:"ma", share:["x,l:5,t:dual"], f:1]),		// B
			MaxOr(	  [n:"x"]),										// D
		]]),
	]])
})
	r("+ All various flips B", eXYtight + selfiePole(s:0,u:0) + logAt(dat:5, eve:5), {
		Net([parts:[
			Broadcast([n:"ma", P:["x"]]),
			MaxOr(	  [n:"x"]),
		]])
	})

r("+ Show Link skin types", eSim + selfiePole(h:0,s:-48,u:-10,z:0.815) + velX(-9) + ["gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
//	Broadcast([n:"e", share:["x,len:2,type:illegalValue"],  jog:"2 0 0", f:1]),	// Should be BAD:
	Broadcast([n:"d", share:["x,l:2,t:dual"],      jog+X:"2 0 0",  f:1]),
 	Hamming(  [n:"c", share:["x,l:2,t:tube"],      jog+X:"2 0 0",  f:1]),		// no line
	Broadcast([n:"b", share:["x,l:2,t:ray"],       jog+X:"2 0 0",  f:1]),
	Broadcast([n:"a", share:["x,l:2,t:invisible"], jog+X:"0.5 0 0",f:1]), // no line
 	Mirror(   [n:"x", "gain":0, "offset":1, f:1]),
]]) })
r("+ Generate AppIcon", e + selfiePole(h:0,s:10,u:10,z:1) + velX(-9) + ["gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
	MaxOr(	[n:"m", share:["a,l:0", "b,l:0.4", "c,l:0"],  f:1]),
	Hamming([n:"a", share:["y,l:0.4", "x,l:0"],  f:1]),
 	Hamming([n:"b", share:["y,l:0"], f:1]),		// no line
	Hamming([n:"c", share:["y,l:0.4", "z,l:0"],  f:1]),
	Net([placeMy:"stackx -1 1", parts:[
 		Mirror(   [n:"x", "gain":0, "offset":1, f:1]),
 		Mirror(   [n:"y", "gain":0, "offset":1, f:1]),
 		Mirror(   [n:"z", "gain":0, "offset":1, f:1]),
	] ])
]]) })
	 xxr("- Multiple SCNViews", e + eW0 + selfiePole(h:0,s:10,u:10,z:1) +
	 		velX(-9) + ["gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
		Hamming([n:"c", f:1]),	//, share:["z"]
 		Mirror( [P:"c", f:1]),	// X+
	]]) })

	r("- Port Missing", e + selfiePole(h:0,s:-48,u:-10) + velX(-9) + ["gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
//		MaxOr(  [n:"b", f:1]),
		Hamming([n:"b", f:1]),
		Hamming([n:"a", f:1]),
	]]) })
	r("- placement of autoBroadcast", eSim + selfiePole(h:0,s:-48,u:-10,z:0.815) + velX(-9) + ["gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
		Hamming([n:"d", share:["x"],  f:1]),
		Hamming([n:"c", share:["x"],  f:1]),		// no line
		Net([placeMy:"stackx", parts:[
			Mirror(   [n:"x", "gain":0, "offset":1, f:1]),
		] ])
	]]) })

 //200418: lock name fault
r("+ All L2 forms?",  e + selfiePole(s:10,u:10) + ["scene":[gravity:"0 0 8"]], { Net([n:"net", placeMy:"stackX -1", parts:[
	Net([placeMy:"linky", parts:[
		Hamming(  [n:"t1", f:1, phys:[gravity:1], share:"t2" 		   	]),
		Broadcast([n:"t2", f:1, phys:1]),
	] ]),
	Net([placeMy:"linky", parts:[
		Hamming(  [n:"t3", f:1, phys:[gravity:1], share:[L2("t4,l:1")]  ]),
		Broadcast([n:"t4", f:1, phys:1]),
	] ]),
	Net([placeMy:"linky", parts:[
		Hamming(  [n:"t5", f:1, phys:[gravity:1], share:L2("t6",["l":2])]),
		Broadcast([n:"t6", f:1, phys:1]),
	] ]),
	Net([placeMy:"linky", parts:[
		Hamming(  [n:"t7", f:0, phys:[gravity:1], P:D2("t8"), 	   ]),
		Broadcast([n:"t8", f:1, phys:1]),
	] ]),
] ]) } )
r("+ Link AllInOne", e + selfiePole(s:80,u:10), { Net([placeMy:"stackx -1 -1", parts:[
	Net([n:"f1", placeMy:"stackZ -1 -1",  parts:[
		Net([n:"a", placeMy:"linky", parts:[		// ///// A: Explicit Link: P->P
			Hamming  ([n:"t2", jog:"0 4 0"]),
			Broadcast([n:"t1", P:"t2", f:1, phys:[gravity:1]]),
		] ] ),
		Net([n:"b", placeMy:"linky", parts:[		// ///// B: Explicit Link: Sec->P
			Hamming  ([n:"t2", jog:"0 4 0"]),
			Broadcast([n:"t1", share:"t2", phys:[gravity:1]]),
		] ] ),
		Net([n:"c", placeMy:"linky", parts:[		// ///// C: Explicit Link: Sec->Sec
			Hamming  ([n:"t2", f:1, jog:"0 4 0", phys:[gravity:1]]),
			Broadcast([n:"t1", share:"t2"]),
		] ] ),
		Net([n:"d", placeMy:"linky", parts:[		// ///// D: Explicit Link: Sec->Sec
			Hamming  ([n:"t2", f:1, jog:"0 4 0", phys:[gravity:1]]),
			Broadcast([n:"t1", P:"t2", f:1]),
		] ] ),
	] ] ),
	Net([n:"f2", placeMy:"stackZ -1 -1",  parts:[
		Net([n:"e", placeMy:"linky", parts:[		// ///// E: Implicit Sec->Sec
			Hamming  ([n:"t2", f:1, jog:"0 4 0"]),
			Broadcast([n:"t1", share:L2("t2"), phys:[gravity:1]]),
		] ] ),
		Net([n:"f", placeMy:"linky", parts:[		// ///// F: Funny Implicit Case:
			Hamming  ([n:"t2", f:1, jog:"0 4 0"]),
			Broadcast([n:"t1", share:L2("t2"), phys:[gravity:1]]),
		] ] ),
		Net([n:"g", placeMy:"linky", parts:[		// ///// G: Implicit P->P
			Hamming  ([n:"t2", P:L2("t1"), jog:"0 4 0", phys:[gravity:1]]),
			Broadcast([n:"t1", f:1]),
		] ] ),
	] ] ),
] ]) })


 // MARK:  Linking special cases eXYtight+eSim+logAt(1) eSim+eXYtight+logAt(dat:5, eve:5)
r("-debug link as t:tube", eXYtight+logAt(ser:0,dat:5,eve:5)+selfiePole(h:0,s:-48,u:-10,z:0.815) +
		 vel(-5) + ["gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
 	Mirror([n:"a", P:["b,l:5,t:dual"]]),// :dual:tube:ray:
// 	Mirror([n:"b", f:1]),
 	Mirror([n:"b", "gain":-1,"offset":1, f:1]),
]]) })


r("-Link length bad", eSimX + eXYtight + selfiePole(s:0,u:0) + vel(-9) + ["ppViewOptions":"UFVTBW", "gapLinkFluff":3], {Net([placeMy:"linky", parts:[	//stacky
	Hamming([n:"g", share:["a"], f:1, jog:"4 0 0"]),	// share:L2("t6",["l":2])
	Mirror( [n:"a", "gain":0,"offset":1, "con":1, 	 f:1]),
]]) })
r("Link is screwey", e + selfiePole(s:0,u:0), {Net([placeMy:"linky", parts		:[
	Broadcast([n:"a", share:["g,l:0.5"], f:1]),
	Hamming([  n:"g",            f:0]),				//, "b"
]]) })
xxr("Bug Positioning", e + selfiePole(s:90,u:0), {Net([placeMy:"linky", parts:[
//	Hamming([n:"d", share:["a,l:0.1"], f:1]),				//, "b"
//	Broadcast([n:"a"]),
	Broadcast([n:"ax", P:"evi/a"]), //"a"]),
	Tunnel([ n:"evi", struc:["a"], of:"bcast", placeMy:"stackz 0 -1"]),//, "d", "e", "f", "g", "h", "i", "j"
]]) })
r("Positioning bug", e + selfiePole(s:0,u:0), {Net([placeMy:"linky", parts:[
	Hamming([  n:"d", share:["a"], f:1]),//,l:2
	Broadcast([n:"a",		   f:1]),
]]) })
xxr("- Link pre SCNSceneRenderer",  e + selfiePole(s:0), { Net([placeMy:"linky", parts:[	//linky
	Broadcast([n:"t1", P:"t2", jog:"2"]),
	Hamming  ([n:"t2", f:1]),
] ]) } )
r("-200116 body missing",  e + selfiePole(s:10,u:10) + ["scene":[gravity:"0 8 0"]], {
	Net([placeMy:"linky", parts:[
		Hamming([phys:1])				// good
//		Hamming([phys:[gravity:1]])		// bad -- missing body
	] ])
} )
r("- positions go NAN",  e + selfiePole(s:10,u:10), {
	Sphere([phys:1])			// Works
//		Sphere([phys:[gravity:1]])	// BAD
} )
r("BUG 190708 link facing camera", eSim + selfiePole(s:0,u:0) + vel(-7), { Net([placeMy:"linky", parts:[
	Broadcast([n:"t2", share:"t1", f:1, jog:"3 0 0"]),	//, jog:"0 -3 4"
	Broadcast([n:"t1"]),
] ]) })
	r("???", e + selfiePole(s:80,u:10), { Net([placeMy:"stackx -1 -1", parts:[
		Net([n:"f1", placeMy:"stackZ -1 -1",  parts:[
				Hamming  ([n:"t2", jog:"0 4 0"]),
				Broadcast([n:"t1", P:"t2", f:1, phys:[gravity:1]]),
		] ] ),
	] ]) })
	r("-'P' moves up", e + selfiePole(s:0,u:0), {
		Net([placeMy:"stackx", parts:[
			Broadcast([n:"t1", f:0]),
		] ])
	})
	r("-+'P' moves up", e + selfiePole(s:80,u:10), {
			Sphere()
	//	Broadcast()
	})
 // First test of link values
let decay = 0.0//5//.1
xxr("+Mirror Oscillator", e + selfiePole(s:0,u:30) + vel(-5) + logAt(0), { Net([placeMy:"linky", parts:[
	Mirror([n:"t1", "gain":-1, "offset":1-decay]),
	Mirror([n:"t2", f:1, P:"t1,l:4", jog:"0 4" ]),
] ]) })
xxr("- short Oscillator", e + selfiePole(s:0,u:0) + vel(-5) + logAt(0), { Net([placeMy:"linky", parts:[
	Mirror([n:"t1", "gain":0, "offset":1]),
	Mirror([n:"t2", f:1, P:"t1,l:4", jog:"0 4" ]),
 ] ]) })
xxr("+Mirror Sequence Osc", eSimX + selfiePole(s:90,u:0) + vel(-5) + logAt(0), { Net([placeMy:"linky", parts:[
	Mirror(  [n:"t0", P:"t1.P", "gain":-1, "offset":1]),
	Sequence([n:"t1", 			  f:1]),
	Mirror(  [n:"t2", P:"t1,l:2", f:1, jog:"0 -1 -8" ]),
	Mirror(  [n:"t3", P:"t1,l:2", f:1, jog:"0 -1 -4" ]),
	Mirror(  [n:"t4", P:"t1,l:2", f:1 ]),
] ]) })
	r("-position of Sequence", eSimX + selfiePole(s:0,u:0) + vel(-5) + logAt(0), { Net([placeMy:"linky", parts:[
//		Broadcast([n:"t1", 			  f:1, jog:"3"]),
		Sequence( [n:"t1", 			  f:1, jog:"3"]),
		Mirror(   [n:"t2", P:"t1,l:2", f:1 ]),
	] ]) })

	 // Use Inspec to change offset
	r("LinkPort.out BUG231219", eSimX + selfiePole(s:0,u:0) + vel(-7) + logAt(0), { Net([f:0, placeMy:"linky", parts:[
		Mirror(   [n:"t2", "gain":0, "offset":1]),
		Mirror(   [n:"t1", "gain":0, "offset":1, P:"t2,l:4", f:1, ]),
	] ]) })
	 // Use Inspec to change offset
	r("testing Mirror Gui", eSimX + selfiePole(s:0,u:0) + vel(-7) + logAt(0), { Net([placeMy:"linky", parts:[
		Mirror(   [n:"t3", "gain":-1, "offset":1]),
		//Broadcast([n:"t2", share:"t3", jog:"5"]),
		Mirror(   [n:"t1", P:"t3,l:5", f:1]),
	] ]) })

r("", e + selfiePole(s:-45,u:30) + logAt(0) + ["bBox4Atoms":true], { Net([placeMy:"stackY", parts:[
	Net([placeMy:"stackZ", parts:[//, jog:"0 1 0"
		Box([color:"red"]),
		Box([color:"orange"]),
	]]),
	Box([n:"t5a", size:"2 0.5 0.5", color:"blue"]),
]]) })
//
//  // MARK: - * Sound
//state.scanSubMenu				= "Sound"
//r("-sound; press 'r'", e + selfiePole(s:90) + logAt(eve:5), { Box([n:"a"]) })

  // MARK: - * Springs
state.scanSubMenu				= "Springs"
 // 190529 BAD: make Ago's in invisible Net, or unNetted
 // 191029 Animations bad!
 // 200204 Animations GOOD!
r("+Springs", e + selfiePole(s:-45,u:5), { Net([placeMy:"stacky", f:0, parts:[
	Net([f:1, placeMy:"stackZ", jog:"0 4 0", parts:[
		Hamming([n:"t1a"]),
		Hamming([n:"t1b"]),
		Hamming([n:"t1c"]),
		Hamming([n:"t1d"]),
	]]),
	Net([placeMy:"stackZ", jog:"0 4 0", parts:[
		Ago([n:"t3a", S:"t1a", P:"t5a", phys:[gravity:false]]),
		Ago([n:"t3b", S:"t1b", P:"t5b", phys:[gravity:false]]),
		Ago([n:"t3c", S:"t1c", P:"t5c", phys:[gravity:false], jog:"6 0 0"]),
		Ago([n:"t3d", S:"t1d", P:"t5d", phys:[gravity:false]]),
	]]),
	Net([placeMy:"stackX", jog:"0 4 0", parts:[
		Broadcast([n:"t5a"]),
		Broadcast([n:"t5b"]),
		Broadcast([n:"t5c"]),
		Broadcast([n:"t5d"]),
	]]),
]]) })
	 // BUG: spring-links don't track physics/gravity motions.
	r("- bug:spring-links don't move", eXYtight, { Net([parts:[
		Broadcast([n:"t1", f:1, phys:[gravity:0], jog:"4 0 0"]),
		Hamming  ([n:"t3", share:"t1", f:0]),	//true//false//
	]]) })
	r("- bug:spring-links don't move", eXYtight , { Net([parts:[
		Hamming  ([n:"t1", jog:"4 0 0", f:1]),
		Broadcast([n:"t3", phys:[gravity:0], share:"t1"]),	//true//false//
	]]) })

// SPRINGS
// 200102: BUG: Timmel placement bad
r("+ 5 BCast free-fall", e + selfiePole(s:0,u:0), {
  Net([placeMy:"linky", n:"net", parts:[
	Mirror([n:"t1", P:"t0"]),
	MaxOr ([n:"t0", share:["a", "b", "c", "d", "e"], f:1]),//, jog:"0 0 10"
	Tunnel([struc:["a", "b", "c", "d", "e"], of:"genAtom", placeMy:"stackx 1", n:"net2"]),
]]) })
r("-reform tunnel", e + selfiePole(s:0,u:0), {
  Net([placeMy:"linky", n:"net", parts:[
	MaxOr ([n:"t0", share:["a", "b"], f:1]),//
	Tunnel([struc:["a", "b"], of:"genAtom", placeMy:"stackx 1", n:"net2"]),	//.port
]]) })

 // 180719 Bug fixed?: First display has Ago in wrong spot. Hit P to reVew and fix
//  200204 Fixed
r("-BUG: physics with Nets", e + selfiePole(s:-45,u:5), {
 Net([placeMy:"linky", parts:[
	Net([n:"n5", jog+X:"-4 -2 0", parts:[	Broadcast([n:"t5a"]),	]]),
	 // problem if both n3 and n3a have physics!
	Net([n:"n3", jog:"4 0 0", phys:[gravity:0], parts:[
		Ago([n:"t3a", S:"t5a", P:"t1a", phys:[gravity:0]]),
	]]),
	Net([n:"n1", parts:[					MaxOr([n:"t1a", f:1]),	]]),
]]) })

r("-physics, 3-chain falls", e + selfiePole(s:1,u:1), { Net([placeMy:"linky", parts:[
	MaxOr(	  [n:"t3", f:1, jog:"4 0 2"]),
	Hamming(  [n:"t2", f:1, share:L2("t1"), P:[L2("t3")], jog:"0 4 0", phys:[gravity:1]]),
	Broadcast([n:"t1", phys:[gravity:1]]),
]]) })
r("-physics, 3-chain falls", e + selfiePole(s:1,u:1), { Net([placeMy:"linky", parts:[
//	MaxOr(	  [n:"t4", P:"t3",	jog:"0 4 0"]),
//	MaxOr(	  [n:"t3", P:"t2",	jog:"0 4 0", phys:0]),
	Hamming(  [n:"t2", P:"t1",	jog:"0 4 0"]),
//	Broadcast([n:"t1", 			phys:[gravity:1]]),		// Bug: DOESN'T WORK!!
	Broadcast([n:"t1", 			phys:1]),				// Works
]]) })

r("FIXED BUG: physics with Nets", e + selfiePole(s:-45,u:5), {
 Net([placeMy:"linky", parts:[
	Broadcast([n:"t5a"]),
	Net([n:"n3", phys:1, parts:[
		Ago([n:"t3a", S:"t5a", P:"t1a"]),
	]]),
	MaxOr([n:"t1a", f:1]),
]]) })

r("191030 had in-Net positioning", e + selfiePole(s:-45,u:5), {
 Net([placeMy:"linky", parts:[
	Net([n:"n5", parts:[
		Broadcast([n:"t5a"]),
	]]),
	Net([n:"n3", parts:[
		Ago([n:"t3a", S:"t5a", P:"t1a", phys:["gravityX":true]]),
	]]),
	Net([n:"n1", parts:[
		MaxOr([n:"t1a", f:1]),
	]]),
]]) })

 // 191030 Bug: First display has Ago in wrong spot. Hit P to reVew and fix
r("Link positioning in Nets", e + selfiePole(s:0,u:0), {
 Net([placeMy:"linky", parts:[	//linky stacky
	Net([n:"n3", parts:[	Ago([n:"t3a", P:"t1a"]), ]]),
	MaxOr([n:"t1a", f:1]),
]]) })
 // 180719 Bug: First display has Ago in wrong spot. Hit P to reVew and fix
r("BUG: physics with Nets", e + selfiePole(s:0,u:0), { Net([placeMy:"stacky", parts:[
	Net([n:"n3", phys:[gravity:1], parts:[
		Ago([n:"t3a", P:"t1a"]),
	]]),
//	Net([n:"n1", parts:[
		MaxOr([n:"t1a", f:1]),
//	]]),
]]) })

// //////////////////////////////////////////////////////////////////////
r("BUG physics inside of Physics", e + selfiePole(s:91,u:1), { Net([placeMy:"stackx", parts:[
	Net([       n:"b",  phys:[gravity:1], parts:[					// Net 		 Required
		Sphere([n:"t2", phys:[gravity:1], size:"3 3 3"]),// physics Required ".03 .03 .03"
	] ] ),
] ]) })
r("BUG Links Spin", e + selfiePole(s:-45,u:5), { Net([placeMy:"stacky", parts:[
	Broadcast([n:"t5a"]),
	Net([phys:[gravity:1], parts:[
		Ago([n:"t3a", S:"t5a"]),
	]]),
]]) })
// //////////////////////////////////////////////////////////////////////
r("-debug springs", e + selfiePole(s:-45,u:5), {
	Net([placeMy:"linky", "minSize":"0 50 50", parts:[
		Hamming([n:"t1a", f:1]),
		Ago([n:"t3a", "Px":"t5a", S:"t1a,l:10", phys:1]),//[gravity:1]
	]])
})
r("+springs, no gravity", e + selfiePole(s:-45,u:5), {
	Net([placeMy:"linky", "minSize":"50 50 50", parts:[
		Hamming([n:"t1a", f:1, phys:false]),
		Ago([n:"t3a", P:"t5a", S:"t1a,l:10", phys:1]),//[gravity:1]
		Broadcast([n:"t5a"]),
	]])
})
// 200102: prev, then next hangs
 // 180920
r("GOOD: Hammign floats above", e + selfiePole(s:-45,u:5) + ["scene":[gravity:"0 20 0"]], { Net([placeMy:"linky", parts:[
	Hamming([n:"t1", share:["t2", "t3"], f:1, phys:1]),//[gravity:1]
	Net([jog:"4 2 0", placeMy:"stackx", parts:[
		Broadcast([n:"t2"]),
		Broadcast([n:"t3"]),
	]]),
]]) })
	r("GOOD: Hammign floats above", e + selfiePole(s:0,u:0) + ["scene":[gravity:"0 20 0"]], { Net([placeMy:"linky", parts:[
		Hamming([n:"t1", share:["t2"], f:1, phys:1, jog:"2 0 0"]),//[gravity:1]
		Broadcast([n:"t2"]),
	]]) })

 // 190518 open/close failed once
r("GOOD: physicsBody big", e + selfiePole(s:-45,u:5), { Net([placeMy:"stackY", parts:[
	Net([expose+X:"atomic",  parts:[
		Sphere([size:"2 1 2", phys:true, color:"orange"]),	// "physicsX" fixes
		Box   ([size:"2 1 2"]),
	]]),
]]) })
//-----------------
r("O", e + selfiePole(s:0,u:5), { Net([parts:[
	Net([placeMy:"linky", expose+X:"atom", parts:[		// ///// A: Explicit Link: P->P
		Broadcast([n:"t1", share:"t2", f:1]),
		Hamming  ([n:"t2", jog+X:"0 4 0", phys:1]),//[gravity:1]
	] ] ),
] ]) })
r("190529 FIXED: Link doesn't open", e + selfiePole(s:0,u:5) + vel(-8), {
	Net([placeMy:"linky", expose+X:"atom", parts:[
		Hamming  ([n:"t2"]),
		Broadcast([n:"t1", P:"t2,l:5", f:1]),
	] ])
})

 // MARK: - * expose
state.scanSubMenu				= "first show"
r(expose, e + selfiePole(s:-135,u:5), { Net([placeMy:"stackZ", parts:[
	Net([n:"a", placeMy:"stackX", expose:"xatom", parts:[		// ///// A: Explicit Link: P->P
		Hamming  ([n:"t2", jog:"0 4 0"]),
		Broadcast([n:"t1", P:"t2", f:1, phys:1]),//[gravity:1]
	] ] ),
	Net([n:"b", placeMy:"stackX", parts:[		// ///// B: Explicit Link: Sec->P
		Hamming  ([n:"t2", f:1, share:"t1", jog:"0 4 0", phys:1]),//[gravity:1]
		Broadcast([n:"t1"]),
	] ] ),
] ]) })
xxr(e + selfiePole(s:5,u:5) + ["scene":[gravity:"0 10 0"]], { Net([parts:[
	Net([placeMy:"linkY", expose+X:"atom", parts:[
	//	Hamming(  [n:"t4", f:1, share:[L2("t1")], jog:"0 4 0"]),
	//	Hamming(  [n:"t3", f:1, share:["t2", L2("t1")]]),
		Hamming(  [n:"t4", f:1, share:[L2("t1")],       phys:[gravity:1], jog+X:"0 4 0"]),
//		Hamming(  [n:"t3", f:1, share:["t2", L2("t1")], phys:[gravity:1], jog+X:"0 9 0"]),
//		Broadcast([n:"t2"]),
		Broadcast([n:"t1"]),
	] ] ),
]]) })

// ORIG
xxr(e + selfiePole(s:5,u:5) + ["scene":[gravity:"0 10 0"]], { Net([parts:[
	Net([placeMy:"stacky", expose+X:"atom", parts:[
//		Hamming(  [n:"t4", f:1, share:[L2("t1")], jog:"0 4 0"]),
//		Hamming(  [n:"t3", f:1, share:["t2", L2("t1")]]),
		Hamming(  [n:"t4", f:1, share:[L2("t1")],       phys:[gravity:1], jog+X:"1 0 0"]),
	//	Hamming(  [n:"t3", f:1, share:["t2", L2("t1")], phys:[gravity:1], jog+X:"2 0 0"]),
		Broadcast([n:"t2", jog:"-3 -2 0"]),
		Broadcast([n:"t1"]),
	] ] ),
]]) })

 // 180727:Fixed 180725: Should wire t3.share to t1.share, but picks t3.P to t1.share
r(e + selfiePole(s:-45,u:5), { Net([parts:[
	Broadcast([n:"t1"]),
	Hamming(["flipx":true, share:"t1", jog:"4 0 0"]),
]]) })
 // 180726:Fixed 180725 throws:
r(e, { Net([parts:[
	Broadcast([P:"t1"]),	// Did FAIL (g/t1/t2/ works)
	Hamming([n:"t1"]),
]]) })
 // FIXED 180726: BUG says t2.share, but picks t2.P
r(e + selfiePole(s:0,u:0), { Net([placeMy:"linky", parts:[
	Broadcast([n:"t1", jog:"4 0 0"]),
	Hamming  ([n:"t2", f:1, P:"t1"]),
]]) })
 // MARK: - * Links Positioning
state.scanSubMenu				= "Links Positioning"
// 20210111:link positions bad
// BROKEN:
r("+'f': link positioning", e + selfiePole(s:90,u:5) + ["animatePhysics":false], { Net([placeMy:"linky", parts:[
	Net([n:"n1", placeMy:"stackZ", jog:"0 0 0", parts:[
		MaxOr([n:"t1a", f:1]),
		MaxOr([n:"t1b", f:1]),
		MaxOr([n:"t1c", f:1]),
		MaxOr([n:"t1d", f:1]),
	]]),
	Hamming([n:"t3a", f:0, share:"t1a", P:"t5a", phys:1]),
	Hamming([n:"t3b", f:0, share:"t1b", P:"t5b", phys:1]),
	Hamming([n:"t3c", f:0, share:"t1c", P:"t5c", phys:1]),//, jog:"4 0 0"
	Hamming([n:"t3d", f:0, share:"t1d", P:"t5d", phys:1]),
	Net([n:"n2", placeMy:"stackX", parts:[
		Broadcast([n:"t5a"]),
		Broadcast([n:"t5b"]),
 		Broadcast([n:"t5c"]),
 		Broadcast([n:"t5d"]),
	]]),
]]) })
	r("+'f': link positioning", e + selfiePole(s:0,u:5) + ["animatePhysics":true,
			lookAt:"t1a", "scene":[gravity:"0 10 0"]], { Net([placeMy:"linky", parts:[
		MaxOr([n:"t1a", f:1, jog:"6 0 0"]),						   // gravity: 1,0,true,false, or "0 0 0" "0 1 0"
		Hamming([n:"t3a", f:0, share:"t1a", P:"t5a", phys:[gravity:"0 10 0"]]),//+X/[gravity:1]/1/
		Broadcast([n:"t5a"]),
	]]) })
		r("- PolyPart ptm bug", e + selfiePole(s:0,u:5), { Net([placeMy:"linky", parts:[
			Broadcast([n:"t5a", P:"t1a"]),
			MaxOr([n:"t1a", f:1]),
		]]) })

	r("- share bug", e + selfiePole(s:0,u:5), { Net([placeMy:"linky", parts:[
		MaxOr([n:"t1", f:0]),
		Hamming([n:"t2", f:1, P:"t1", phys:1]),// share
	]]) })
	r("- ^r is bad if animatePhysics left ON", eAnim + selfiePole(z:1) + [lookAt:"a"], { Net() })
	r("-stacking bug", e + selfiePole(s:90) + [lookAt:"a"], { Net([parts:[
		Box([n:"a"]),
	]]) })
let xx3 = 1
r("-stacking bug", e + selfiePole(s:90), { Net([placeMy:"stackZ", parts:[
	MaxOr([n:"a", f:xx3]),
	MaxOr([n:"b", f:xx3]),
]]) })
r(e + selfiePole(s:0,u:5), { Net([placeMy:"linky", parts:[
	MaxOr([n:"t", f:1]),
	Hamming([n:"u", share:"t"]),
]]) })
r(e + selfiePole(s:0,u:0), { Net([placeMy:"stackY", parts:[
	Net([placeMy:"stackX", parts:[
		Box([color:"red"]),
		Box([color:"orange"]),
	]]),
	Net([placeMy:"stackY", parts:[
		Box([color:"yellow"]),
		Box([color:"green"]),
	]]),
	Net([placeMy:"stackZ", parts:[
		Box([color:"blue"]),
		Box([color:"violet", "sizeX":"1.5 1.5 1.5"]),
	]]),
]]) })
r(e, { Broadcast([phys:[gravity:1]]) })
r(e, { Net([parts:[				//"bundle",
	Box(	 [color:"red"]),
	Sphere(	 [color:"orange"]),
	Cylinder([color:"yellow"]),
]]) })

 // MARK: - * Shaft
state.scanSubMenu				= "Shaft"
xxr("+ ShaftBT 3", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
	Net([parts:[
//		Generator([n:"hi", "nib??":"HiGen_fwdBkw", "resetTo":["fwd"], "P":"wheelA/con"]),
		Actor([n:"wheelA", "positionViaCon":1, "minHeight":0.0,
			"con":Tunnel([struc:["fwd", "bkw"], of:"genBcast",  f:1]),			//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
			"parts":[
				Hamming([P:"fwd", share:["a.+", "b.-"], f:1]),
				Hamming([P:"fwd", share:["b.+", "c.-"], f:1]),
				Hamming([P:"fwd", share:["c.+", "a.-"], f:1]),
				Hamming([P:"bkw", share:["a.+", "c.-"], f:1]),
				Hamming([P:"bkw", share:["b.+", "a.-"], f:1]),
				Hamming([P:"bkw", share:["c.+", "b.-"], f:1]),
			],
			"evi":Tunnel([struc: ["a", "b", "c"], of:"genPrev"], leafConfig:["mode":"netForward", spin:4]), //, "b", "c"//"proto":aGenPrevBcastLeaf(0, @{@"mode":@"netForward", spin$1}) }),
		]),
		ShaftBundleTap(["nPoles":3, P:"wheelA/evi", f:1]),
	] ])
})
	xxr("- fails", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
		Net([parts:[
			Actor([n:"wheelA", "evi":Tunnel([struc:["a", "b", "c", "d", "e", "f"], of:"genAtom"])]),
			ShaftBundleTap([n:"shaft", "nPoles":6, P:"wheelA/evi", f:1]),
		] ])
	})
xxr("- bugVect", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
	Net([parts:[
//		Generator([n:"hi", "nib??":"HiGen_fwdBkw", "resetTo":["fwd"], "P":"wheelA/con"]),
		Actor([n:"wheelA", "positionViaCon":1, "minHeight":0.0,
			"con":Tunnel([struc:["fwd", "bkw"], of:"genBcast",  f:1]),			//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
			"parts":[
				Hamming([P:"fwd", share:["a.+", "b.-"], f:1]),
				Hamming([P:"fwd", share:["b.+", "c.-"], f:1]),
				Hamming([P:"fwd", share:["c.+", "a.-"], f:1]),
				Hamming([P:"bkw", share:["a.+", "c.-"], f:1]),
				Hamming([P:"bkw", share:["b.+", "a.-"], f:1]),
				Hamming([P:"bkw", share:["c.+", "b.-"], f:1]),
			],
			"evi":Tunnel([struc: ["a", "b", "c"], of:"genPrev"], leafConfig:["mode":"netForward", spin:4]), //, "b", "c"//"proto":aGenPrevBcastLeaf(0, @{@"mode":@"netForward", spin$1}) }),
		]),
		ShaftBundleTap(["nPoles":3, P:"wheelA/evi", f:1]),
	] ])
})
	xxr("- no R port", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
		Net([parts:[
			Hamming([P:["a"]]),
			Hamming([P:["a"]]),
			Tunnel( [n:"evi", struc: ["a"], of:"genPrev"]),
			ShaftBundleTap([n:"shaft", P:"evi", "nPoles":1, f:1]),
		] ])
	})
xxr("- bugAutoBcast", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
	Net([parts:[
													// Broadcast([n:"fwd", f:1]),
													// Tunnel([struc:["fwd"], of:"bcast"/*nil_A*/,  f:0]),	//bcast/*nil_A*///genPrev		//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
		Actor([n:"wheelA", placeMy:"linky"/*stackx*/, "positionViaCon":1, "minHeight":0.0,
			"con":FwBundle([struc:["fwd"], of:"bcast", f:1], leafConfig:[f:0]),
			"parts":[
				Hamming([P:"fwd", share:"a.-", f:1]),
				Hamming([P:"fwd", share:"b", f:1]),
				Hamming([P:"fwd", share:"c", f:1, jog:"0 0 2"]),
			],
			"evi":FwBundle([struc:["a", "b", "c"], of:"genPrev", f:0], leafConfig:[spin:4])	//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
		]),
	] ])
})

xxr("- shapeTest", [:], {
	Net([n:"w", placeMy:"stacky","parts":[
		Sphere([n:"sphere"]),
		Box([n:"box"]),
],	]) })
	
if false {		//true//false//
	xxr("- t1 non-Actor", [:], {
		Net([n:"w", placeMy:"linky", "minHeight":0.0,//, "positionViaCon":1
			"parts":[
				FwBundle([n:"con", struc:["fwd"], of:"bcast", f:1, "latitude":0], leafConfig:[f:1]),	// Leaf([n:"fwd", of:"bcast", f:0]),
				Hamming([P:"fwd", f:1, "latitude":0]),
	],	]) })
} else {
	xxr("- t2 Actor UPSIDEDOWN", [:], {
		Actor([n:"w", placeMy:"linky", "minHeight":0.0,
			"con":FwBundle([n:"con", struc:["fwd", "xxx"], of:"bcast", f:1, "latitude":0], leafConfig:[f:1]),	// "con":Leaf([n:"fwd", of:"bcast", f:0]/*, leafConfig:[f:1]*/),
			"parts":[
				Hamming([n:"ham", P:"fwd",/**/ f:1, "latitude":0]),
				Hamming([n:"ham", P:"xxx",/**/ f:1, "latitude":0]),
		],	])
	})
}
	xxr("- placement of parts", [:], {
		Net([parts:[
			Actor([n:"wheelA", placeMy:stackx, "positionViaCon":1, "minHeight":0.0,
				"con":FwBundle([n:"con", struc:["fwd1", "fwd2"], of:"bcast", f:1, "latitude":0], leafConfig:[f:1]),	// "con":Leaf([n:"fwd", of:"bcast", f:0]/*, leafConfig:[f:1]*/),
				"parts":[
					Hamming([P:"fwd1", f:1, jog+X:4]),
					Hamming([P:"fwd2", f:1]),
				],
			]),
		] ])
	})
	xxr("- bugAutoBcast V2", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
		Net([parts:[
			Leaf([n:"fwd", of:"bcast"/*nil_A*/, f:1]),
//			Tunnel([n:"con", struc:["fwd"], of:"bcast"/*nil_A*/, f:1]),	//bcast/*nil_A*///genPrev		//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
			Hamming([P:"fwd", f:1, jog:4]),
			Hamming([P:"fwd", f:1]),
		] ])
	})
xxr("+ Previous auto-broadcast bug", eSimX + selfiePole(s:45,u:10) + logAt(dat:5, eve:5), {
	Net([parts:[
		Hamming([n:"h1", P:["a"]]),
		Hamming([n:"h2", P:["a"]]),
		Previous([n:"a"]),
//		Broadcast([n:"a"]),
	] ])
})
r("- top congestion bug", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
	Net([parts:[
		Actor([n:"wheelA", "positionViaCon":1, "minHeight":0.0,
//			"con":Tunnel([struc:["fwd"],  f:1]),			//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
			"parts":[
				Broadcast([n:"fwd", P:"a"]),
			],
			"evi":Tunnel([struc: ["a"], of:"genPrev", S+X:"fwd"],
						 leafConfig:["mode":"netForward", spin:4]),
		]),
	] ])
})
let bundleNames = ["a"]//,"b","c","d","e","f","g","h","i"]
xxr("- links 4", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
	Net([parts:[
//		Broadcast([n:"x", f:1])//, "a.-"//
		Hamming([n:"A", share:bundleNames, f:1]),//, "a.-"//
		Tunnel([struc:bundleNames, of:"genBcast"], leafConfig:[share:"A"]), //, "b", "c"//"proto":aGenPrevBcastLeaf(0, @{@"mode":@"netForward", spin$1}) }),
	] ])
})
	r("- minimum link", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
		Broadcast([n:"x", f:1])//, "a.-"//
	})

r("- con bug", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {Net([parts:[
	Broadcast([n:"fwd", f:0]),
	Net([placeMy:stackx, parts:[
		 Hamming([P:"fwd", f:1]),
		 Hamming([P:"fwd", f:1]),
	] ])
] ]) })

xxr("- FIXED: no con T bug", eTight + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {
	Net([parts:[
		Hamming([P:["a.T,l:2"], jog:"1 0 0"]), // +-ST
		Previous([n:"a"]),
		//Broadcast()
	] ])
})
//		Actor([n:"wheelA", "positionViaCon":1, "minHeight":0.0,
//			"parts":[
//				Hamming([P:["a.-="], jog:"0 0 0"]), // +-ST
//			],
//			"evi":Tunnel([struc: ["a"], of:"genPrev"], leafConfig:["mode":"netForward"]), //, "b", "c"//"proto":aGenPrevBcastLeaf(0, @{@"mode":@"netForward", spin$1}) }),
//		]),
r("- funny placement corner", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
		Actor([n:"wheelA", "positionViaCon":1, "minHeight":0.0, "placeMy":"linky",
			"con":Tunnel([struc:["fwd", "bkw"], of:"bcast"/*nil_A*/,  f:1]),			//"proto":aGenMaxLeaf(), spin$1, "positionPriorityXz":1,
			"parts":[
				Hamming([P:"fwd", f:1]),
				Hamming([P:"bkw", f:1]),
			],
		])
})
r("+ ShaftBT 3", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBox":"black"], {	// FAILS
	Actor([n:"wheelA", "positionViaCon":1, "minHeight":0.0,
		"evi":Tunnel([struc:["a"], of:"genPrev"], leafConfig:["mode":"netForward", spin:4]) //, "b", "c"//"proto":aGenPrevBcastLeaf(0, @{@"mode":@"netForward", spin$1}) }),
	])
//	Net([parts:[
//		ShaftBundleTap(["nPoles":5, P+sX:"wheelA/evi", f:1])
//	] ])
})
 // MARK: - * Generator
state.scanSubMenu				= "Generator"
//	xxr("+'f': link positioning", e + selfiePole(s:0,u:5) + ["animatePhysics":true,
//			lookAt:"t1a", "scene":[gravity:"0 10 0"]], { //Net([placeMy:"linky", parts:[
//xr("+ Shaft Spin 3", e + selfiePole(s:45,u:10) + vel(-3) + logAt(dat:5, eve:5) + ["wBoxX":"none"], {
xxr("+ Shaft Spin 3", eSim + selfiePole(s:45,u:10) + vel(-3) + logAt() + ["wBoxX":"none"], {	// FAILS
  Net([parts:[												// logAt(dat:5, eve:5)
 	DiscreteTime([n:"hiGen", P:"wheelA/con", "generator":"loGen", events:["y", "z", [], "again"]]),
	Actor([n:"wheelA", placeMy:"linky",
		"con":Tunnel([struc:["z", "y"], of:"bcast"/*nil_A*/, f:1]),
		parts:[
//			Bulb(	[n:"mk", P:"mj"]),
//			Hamming([n:"mj", share:["a", "b"], f:1]),
			MaxOr(	[n:"ma", share:["z", "y"], f:0]),
			MinAnd(	[n:"mi", share:["a", "b", "c", "d"], P:"ma", f:1]),
		],
		"evi":Tunnel([struc:["a", "b", "c", "d"], of:"bcast"/*nil_A*/, placeMy:"stackz 0 -1"]),
	]),
	Generator([n:"loGen", events:["a", ["a", "b"], "b", "c", ["a", "b", "c", "d"], "again"],
			P:"wheelA/evi", expose+X:"atomic"]),
]]) })
xxr("+ Shaft Spin 3", eSim + selfiePole(s:45,u:10) + vel(-3) + logAt() + ["wBoxX":"none"], {	// FAILS
  Net([parts:[												// logAt(dat:5, eve:5)
	Actor([n:"wheelA", placeMy:"linky",
		"evi":Tunnel([struc:["a", "b"], of:"bcast"/*nil_A*/, placeMy:"stackz 0 -1"]),
	]),
	Generator([n:"loGen", events:["a", ["a", "b"], "b", "again"],
			P:"wheelA/evi", expose+X:"atomic"]),
]]) })

	 // eTight
	xxr("Structure for XCTEST", eSim + selfiePole(s:45,u:10) + logAt(dat:5, eve:5) + ["wBoxX":"none"], {
	  Net([placeMy:"linky", parts:[
		MinAnd([n:"z", f:0, jog+X:"2 0 0"]),
		MaxOr( [P:"z,l:5", f:1]),	// no Link
	//	MaxOr(["share":"z,l:5"]),	// no Link
	]]) })
	xxr("- duplicate name PP SS", eSimX + selfiePole(s:45,u:10) + vel(-3) + logAt() + ["wBoxX":"none"], {	// FAILS
	  Net([parts:[												// logAt(dat:5, eve:5)
		Tunnel([n:"b", P:"a", struc:[], of:"bcast"/*nil_A*/, jog:"1"]),
		Tunnel([n:"a", struc:[], of:"bcast"/*nil_A*/, f:1]),
	]]) })

	r("- drive from top too", eSim + selfiePole(s:45,u:0,z:0.7) + vel(-3) + logAt(dat:5, eve:5) + ["wBoxX":"none"], {
	  Net([parts:[
		Generator([n:"hi", events:[["y", "z"], [], "again"], P:"wheelA/con", "resetTo":["y", "z"], f:1]),
//		DiscreteTime([n:"hiDt", P:"wheelA/con", "generator":"lo", "resetTo":["x", "y"]]),
		Actor([n:"wheelA", placeMy:"linky",
			"con":Tunnel([struc:["z", "y"], of:"bcast"/*nil_A*/, f:1]),
			parts:[
				MaxOr(	[n:"ma", share:["z", "y"], f:0]),
				MinAnd(	[n:"mi", share:["a", "b"], f:1, P:"ma"]),
			],
			"evi":Tunnel([struc:["a", "b"], of:"bcast"/*nil_A*/, placeMy:"stackz 0 -1"]),
		]),
	//	Tunnel([n:"qqq", struc:["a", "b"], placeMy:"stackz 0 -1"]),
//		Generator([n:"lo", events:["a", ["a", "b"], "b", [], "again"], P:"wheelA/evi", "resetTo":["a", "b"]]),//"wheelA/evi"
			//	 ([P:wheelA/evi, events:[6 elts], placeMy:stacky])

	//	Generator([n:"lo", events:["a", ["a", "b"], "b", [], "again"], P:"qqq"]),//"wheelA/evi"
	//	DiscreteTime([n:"dt", f:1]),	//"wheelA/evi", P:"qqq"
	//	TimingChain( [n:"tc", f:1, "S=":"dt", "P=":"wm"]),						// S]--> wm
	//	WorldModel(  [n:"wm", f:1, events:["a", ["a", "b"], "b", [], "again"]]),
	]]) })
	r("- drive from top too", eSim + selfiePole(s:45,u:0,z:0.7) + vel(-3) + logAt(dat:5, eve:5) + ["wBoxX":"none"], {
	  Net([parts:[
		Generator([n:"hi", events:["y", [], "again"], P:"wheelA/con", "resetTo":["y"], f:1]),
		Actor([n:"wheelA", placeMy:"linky",
			"con":Tunnel([struc:["y"], of:"bcast", f:1]),
			parts:[
				MaxOr(	[n:"ma", share:["y"], f:0]),
				MinAnd(	[n:"mi", share:["a"], f:1, P:"ma"]),
			],
			"evi":Tunnel([struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),
		]),
		Generator([n:"lo", events:["a", [], "again"], P:"wheelA/evi", "resetTo":["a"]]),
	]]) })
// tc."S=":"wm" -> wm

	xxr("- grows vert", eSimX + eYtight + selfiePole(s:0,u:0,z:0.7) + logAt(1, dat:5, eve:5), {Net([placeMy:"linky", parts:[
		Mirror(		[n:"mk", P:"a,l:4"]),//, "gain":-1, "offset":1
//		MaxOr(		[n:"mk", P:"a,l:4"]),
		Tunnel(		[n:"evi", struc:["a"], of:"genBcast"]),
		Generator(	[n:"lo", events:["a", [], "again"], P:"evi"]),
	]]) })
	xxr("- bug:", e + selfiePole(s:0,u:0,z:0.7) + logAt(1, dat:5, eve:5), {Net([placeMy:"linky", parts:[
 //		Mirror(		[n:"a", P:"b"]),//, "gain":-1, "offset":1s
 //		MaxOr(		[n:"b", f:1]),
	//	Mirror(		[n:"mk", P:"a"]),//, "gain":-1, "offset":1s
	//	MaxOr(		[n:"mk", P:"a,l:4"]),
		Tunnel(		[n:"evi", struc:["a"], of:"genBcast"]),
//		Generator(	[n:"lo", events:["a", [],                  "again"], P+X:"evi"]),
		Generator(  [n:"lo", events:["a", ["a", "b"], "b", [], "again"], P:"evi"]),//"wheelA/evi"
	//	DiscreteTime([n:"dt", f:1]),	//"wheelA/evi", P:"qqq"
	//	TimingChain( [n:"tc", f:1, "S=":"dt", "P=":"wm"]),						// S]--> wm
	//	WorldModel(  [n:"wm", f:1, events:["a", ["a", "b"], "b", [], "again"]]),
	]]) })
	r("- link l", e + selfiePole(s:0,u:0) + logAt(dat:5, eve:5), {//Net([parts:[
		Actor([n:"wheelA", placeMy:"linky",
			"con":Tunnel([struc:["z"], of:"bcast", f:1]),
//			"con":GenAtom([n:"z", f:0]),
			parts:[
				MaxOr( [n:"ma", share:["z"], f:0]),	//
				MinAnd([n:"mi", P:"ma,l:5", f:1]),	//, share:["a"]
//				Modulator(),
//				Modulator(),
			],
//			"evi":Tunnel(),
		])
//	]])
	})
		r("- position bug", e + selfiePole(s:0,u:0) + logAt(dat:5, eve:5), {//Net([parts:[
			Actor([n:"wheelA", placeMy:"linky",
				parts:[
//					MaxOr( [n:"ma", share:["x"], f:1]),		//,"y", "z"			//
					MaxOr( [n:"ma", P:["x"]]),									// works
				],
				"evi":Tunnel([struc:["x"], of:"genBcast"]),	//,"y", "z"
			])
		})
			r("- w[] bug", e + selfiePole(s:0,u:0) + logAt(dat:5, eve:5)
					+ ["ppViewOptions":"UFVTBW"], {
				Net([placeMy:"linky", parts:[
					Broadcast([n:"ma", jog:"2 0 0"])
				]])
			})

		r("- con:GenAtom", e + selfiePole(s:0,u:0) + logAt(dat:5, eve:5), {Net([placeMy:"linky", parts:[
//			Broadcast([n:"e", P:"d"]),
//			Broadcast([n:"d", P:"c"]),
	//		Broadcast([n:"c", P:"b"]),
			Hamming(  [n:"b", P:"a"]),//,l:5
			Broadcast([n:"a"]),
		]]) })
	r("-evi missing", eSim + selfiePole(s:90,u:10), {Net([parts:[
		//Hamming(  [share:["a", "b"], f:1]),
		Actor([n:"wheelA", placeMy:"linky",
			"evi":Tunnel([struc:["a", "b"], of:"genBcast", placeMy:"stackz 0 -1"]),
		]),
		Generator([n:"lo", events:["a", ["a", "b"], "b", [], "again"],
									expose+X:"atomic", P:"wheelA/evi"]),
	]]) })
	xxr("-evi missing", eSimX + selfiePole(s:90,u:10) + logAt(dat:5, eve:5) + vel(-3), {Net([placeMy:"linky", parts:[//log(all:5)
		Actor([n:"wheelA", placeMy:"linky",
			parts:[
//	/*a*/		Mirror(		[n:"u", P:"v"]),
//				Broadcast(	[n:"v", P:"a"]),
//	/*b*/		Hamming(	[n:"u", share:"a,l:3", f:1]),
	/*c*/		Bulb(   	[n:"v", P:"a,l:3"]),
			],
			"evi":Tunnel([struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),
		]),
		Generator([n:"lo", events:["a", [], "again"],
									expose+X:"atomic", P:"wheelA/evi"]),
	]]) })
		r("-^P spaz", eSim + selfiePole(s:45,u:0) + logAt(8), {
			Net([parts:[
	//			TimingChain([n:"tc", f:1, "xP=":"wm"]),	//20220225
	//			WorldModel( [n:"wm", f:1]),
//				Previous()
				Broadcast()
	//			Portless()
	 		]])
		})

r("-share of MaxOr", e + selfiePole(s:10,u:10), {Net([parts:[
	Actor([n:"wheelA", placeMy:"linky",
		"con":Tunnel([struc:["z", "y"], of:"bcast", f:1]),
		parts:[
			MaxOr( [n:"ma", share:["z", "y"], f:0]),
		],
	]),
]]) })


r("-Tunnel Leafs", e + selfiePole(s:0,u:0), {Net([parts:[
	Tunnel([n:"evi", struc:["a", "b", "c"], of:"genBcast", f:0, placeMy:"stackx -1 -1"]),//, "d", "e"
]]) })

let bits = ["a", "b"]//, "b"]
r("-Tunnel Leafs", e + selfiePole(s:0,u:0), {Net([placeMy:"stacky", parts:[
	//.nil_//.cylinder//.genAtom//.genBcast//genSplitter//bulb	//, "d", "e"/
	FwBundle([n:"evi1", placeMy:"stackx",struc:bits,of:"bcast",   f:0]),			//of:.genAtom,
 	Tunnel([n:"evi2", placeMy:"stackx", struc:bits, of:"genPrev", f:0]),
//	Tunnel([n:"evi3", placeMy:"stackx", struc:bits, of:"port", 	  f:0]),
	Tunnel([n:"evi4", placeMy:"stackx", struc:bits, of:"bulb",    f:0]),
 	Tunnel([n:"evi5", placeMy:"stackx", struc:bits, of:"genAtom", f:0]),
	Tunnel([n:"evi6", placeMy:"stackx", struc:bits, of:"cylinder",f:0],	//genMaxSq
						leafConfig:["size":"0.2 1.0 0.2"]					),
]]) })
	r("-Tunnel Leaf is Port", e + selfiePole(s:0,u:0), {Net([placeMy:"stacky", parts:[
		Tunnel([n:"evi", placeMy:"stackx", struc:bits,of:"genAtom",f:0]),
	]]) })
		r("-Tunnel/Leaf is nil_", e + selfiePole(s:0,u:0), { //, "c", "d"
			Tunnel([n:"evi", placeMy:"stackx", struc:bits, of:"nil_", f:0])
		} )
		r("-Tunnel/Leaf is cylinder", e + selfiePole(s:0,u:0), { //, "c", "d"
			Tunnel([n:"evi", placeMy:"stackx", struc:bits, of:"cylinder",f:0],
						leafConfig:["size":"0.8 6 0.4"])
		} )
		r("-FwBundle/Leaf(s)", e + selfiePole(s:0,u:0), {FwBundle([placeMy:"stackx -1", parts:[	//Tunnel
//			Leaf( [n:"a". .port,]),
			Leaf([n:"b", of:"genAtom"]),
			Leaf([n:"c", of:"Zcylinder"]),
		]]) })

	r("-+Tunnel Leaf,Leaf is nil_", e + selfiePole(s:0,u:0), {Net([placeMy:"stackx", parts:[
		Leaf([n:"a", of:".nil_"]),
		Leaf([n:"b", of:".nil_"])
	]]) })
		r("-Leaf is nil_", e + selfiePole(s:0,u:0), {
			Leaf([n:"a", of:"nil_"])
		} )
		xxr("+ Bulb sizing", e + eW2 + selfiePole(s:45,u:0,z:1.6) + vel(-3) + logAt(8) + //logAt(dat:5, eve:5) +
				["gapLinkFluff":1, "wBox":"colors", lookAt+X:"/net0/v.P"], { Net([placeMy:"linky", parts:[
			Mirror([n:"t", P:"u"]),
			Bulb(  [n:"u"]),					// Broadcast
			Mirror([n:"v", P:"u", "gain":-1, "offset":1, f:1]),
		] ]) })
		r("-Port Skins", e + selfiePole(s:45,u:0,z:1.3) + vel(-8) + logAt(rve:8) + ["wBox":"gray"], { Net([parts:[	//placeMy:"linky",
			Mirror([n:"t", P:"u", jog:"2 0 0"]),
			Bulb(  [n:"u"]),					// Broadcast
		] ]) })
		r("-Port Skins", e + selfiePole(s:45,u:0,z:1.3) + logAt(rve:8), { Bulb([n:"u"])	})
		r("-bug Bulb sizing", eSim + selfiePole(s:0,u:0) + vel(-7) + logAt(8) + //eve:5, dat:5
					[lookAt:"/net0"], { Net([placeMy:"linky", parts:[
				Bulb(  	  [n:"y", P:"v,l:1.4,v:0.04"]),
	//			Bulb(  	  [n:"x", P:"v,l:1.2,v:0.02"]),
	//			Bulb(  	  [n:"w", P:"v,l:1.0,v:0.00"]),
				Mirror(   [n:"v", "gain":-1, "offset":1, f:1]),
			] ])
		})
			xxr("+ BlinksSlently", eSim + eXYtight + /*logAt(7) +*/ [lookAt:"/net0"], { 	Net([placeMy:"linky", placeMe:stackx, parts:[
					Mirror(		[n:"w", P:"v,l:3,v:3"]),
					Mirror( 	[n:"v", "gain":-1, "offset":1, f:1]),
				] ])
			})
			xxr("+ BlinksABit", eSim + eXYtight + /*logAt(7) +*/ [lookAt:"/net0"], { 	Net([placeMy:"linky", placeMe:stackx, parts:[
					Mirror(		[n:"w", P:"v,l:5,v:2.0"]),
					PortSound(	[n:"s1", "inP":"v.P", "sounds":tickTock]),
				//	Broadcast(	[n:"v"], P:),
					Mirror( 	[n:"v", "gain":-1, "offset":1, f:1]),
				] ])
			})
			xxr("+ BlinksALot", eSimX + eXYtight + /*logAt(7) +*/ [lookAt:"/net0"], { 	Net([placeMy:"linky", placeMe:stackx, parts:[
					FwBundle([n:"bundle",  parts:[
						Mirror(	[n:"y", P:"v,l:5,v:7.3 "]),
						Mirror(	[n:"x", P:"v,l:5,v:4.0"]),
						Mirror(	[n:"u", P:"v,l:5,v:4.4"]),
					 ] ]),
					PortSound(	[n:"s1", "inP":"v.P", "sounds":tickTock]),
					Broadcast(	[n:"v", P:"v1,l:0.8,v:10"]),
					Mirror( 	[n:"v1", "gain":-1, "offset":1, f:1]),
				] ])
			})

			r("Blinks4", eSim + eXYtight + selfiePole(s:45,u:10,z:1.6) + //logAt(7) +
						[lookAt:"/net0"], { Net([placeMy:"linky", parts:[
					Mirror(	  [n:"y", P:"v,l:1.4,v:0.04"]),
					Mirror(	  [n:"x", P:"v,l:1.2,v:0.02"]),
					Mirror(	  [n:"w", P:"v,l:1.0,v:0.00"]),
					Mirror(	  [n:"t", P:"s,l:0.8,v:-0.02"]),
					Broadcast([n:"s", P:"v,l:0.8,v:-0.02"]),
					Mirror(   [n:"v", "gain":-1, "offset":1, f:1]),
				] ])
			})
		r(" Bulb sizing", e + selfiePole(s:45,u:0) + vel(-5), {Net([placeMy:"linky", parts:[
	//		Mirror(			[n:"t"]),
		//	Leaf(.genBulb,	[n:"t"]),//port//gen19
			Bulb(			[n:"t"]),
			Mirror(			[n:"v", P:"t,l:4", "gain":-1, "offset":1, f:1]),
		] ]) })
	
		r("-missing links", e + selfiePole(s:0,u:0) + ["wBox":"colors"], {Net([placeMy:"linky", parts:[
			//Mirror( [n:"t"]),
			//Bulb(	  [n:"t"]),
			Broadcast([n:"t"]),
//			Broadcast([n:"v", P:"t,l:2", f:1]),							// GOOD
			Mirror(	  [n:"v", P:"t,l:2", f:1]),  						// BAD
		] ]) })
	r("-bug Bulb sizing", e + selfiePole(s:45,u:0), {
		Bulb()
//		Portless()
//		Broadcast([:])
	})
r("-bug struct['a']", eSim + selfiePole(s:30,u:0) + vel(-2), {Net([placeMy:"linky", parts:[
	Mirror([P:"b,l:5"]),
	Tunnel([n:"evi", struc:["a", "b"], of:"genBcast"]),	//.genSplitter
	Generator([n:"lo", P:"evi=", events:[["a"], ["a", "b"], ["b"], [], "again"], eventLimit:0]),
//	Mirror([P:"a,l:5"]),
]]) })
	r("-bug busy at start", e + selfiePole(s:30,u:0), {Net([placeMy:"linky", parts:[
		Mirror([P:"a"]),
		MaxOr([n:"a"]),//Splitter([n:"a"]),
//		Tunnel(tunnelConfig:[n:"evi", struc:["a"], of:"port"]),	// genSplitter	//port
	]]) })
	r("-bug 'proto' ", e + selfiePole(s:30,u:0), {Net([placeMy:"linky", parts:[
		Broadcast([n:"h",   share:["a"], f:1]),
		Broadcast([n:"a"]),
	]]) })

r("-bug tunnel skins", e + selfiePole(s:30,u:0) + [lookAt:"a"], {
	Tunnel([n:"evi", struc:["a"], of:"genAtom"])//.genSplitter
})

r("-bug sole port flipped", e + selfiePole(s:1,u:1),  	{	MultiPort([f:1])	} )
r("-bug sole port flipped", e + selfiePole(s:1,u:1),  	{	MultiPort([f:0])	} )

r("-bug", e + selfiePole(s:1,u:1),  		{	Net([placeMy:"linky", parts:[
	Port([f:0])				 		]]) })
r("-bug", e + selfiePole(s:1,u:1),			{	Tunnel([struc:["a"], of:"genAtom"])} )

r("-bug runs forever", eSim + selfiePole(s:45,u:10) + vel(-7) + logAt(dat:5, eve:5) + [lookAt:"a"], {Net([placeMy:"linky", parts:[
//	Mirror([P:"a,l:5"]),
	Tunnel([n:"evi", struc:["a", "b"], of:"genAtom"]),//.genSplitter
	Generator([n:"lo", events:["a", [], "again"], eventLimit+X:1, P:"evi="]),
]]) })
	xxr("- M1 SCN bbox/matrix", [:], {	Part([:]) })

xxr("+Gen Ham Bulb", e + selfiePole(s:45,u:0) + vel(-2) + logAt(dat:5, eve:5) +
		[lookAt+X:"/net0/e"], {Net([placeMy:"linky", parts:[
//	Mirror([   n:"f",  P:"e"]),
	Bulb([	   n:"f",  P:"e", f:0]),
	Hamming([  n:"e",  share:["da", "db"], f:1]),		//MaxOr
//	Hamming([  n:"da", share:L2("a",["v":0.5]), f:1]),
	Hamming([  n:"da", share:["a,v:1"], f:1]),	//,v:0.5
	Hamming([  n:"db", share:["b"], f:1]),
//	Hamming([  n:"dc", share:["c"], f:1]),
	Tunnel([n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"]),//, "d", "e", "f", "g", "h", "i", "j"
	Generator([n:"lo", P:"evi=", eventLimit:0, events:
//		["a", "b", "c", [], "again"],
//		["a", 	   ["a",	"b=0.9"],			[], "again"],
//		["a=0.9", ["a=0.9", "b"    ], "b",     	[], "again"],
//		["a", 	   ["a",	"b=0.9"], "b=0.9",  [], "again"],
		["a", 	   ["a",	"b"], 	  "b", 		[], "again"],
	]),
]]) })
xxr("+Gen 3 Bulbs", eSim + selfiePole(s:90,u:0) + vel(-4) + logAt(dat:5, eve:5) +
							[lookAt+X:"/net0/e"], {Net([placeMy:"linky", parts:[
	Tunnel([n:"evi", struc:["a", "b", "c"], of:"genBulb", placeMy:"stackz 0 -1"]),
	Generator([n:"lo", P:"evi=", placeMy:"stacky", eventLimit:0, events:[	//-1
		 "a",
		["a", "b"],
				   "c",
		["a", "b", "c"],
			  "b",
		[],
		"again"]]),
]]) })
xxr("- bug failed to follow path", logAt(dat:5, eve:5), {Net([placeMy:"linky", parts:[
	Tunnel([n:"evi", struc:["a", "b", "c"], of:"genBulb",  placeMy:"stackz 0 -1"]),
	Generator([n:"lo", P:"evi=", placeMy:"stacky", eventLimit:0]),
]]) })
xxr("-bug struct['a']", e + eXYtight + selfiePole(s:30,u:0) + vel(-8), {Net([placeMy:"linky", parts:[
	Tunnel([n:"evi", struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]), //genBulb//of:.genPrev,
	Generator([n:"lo", P:"evi=", placeMy:"stacky"]),
	//Mirror([n:"a", P:"b,l:5"]),
	//Mirror([n:"b", "gain":-1, "offset":1, f:1]),
]]) })

	r("- tunnel spacing", eSim + selfiePole(s:90,u:0) + vel(-4) + logAt(rve:8) +
							[lookAt+X:"/net0/e"], {Net([placeMy:"linky", parts:[
		Tunnel([n:"evi", placeMy:"stackz 0 -1", of:"genBulb"]),
		DiscreteTime([f:1, P:"evi="]),
	//	Generator([n:"lo", P:"evi=", placeMy:"stacky"]),
	]]) })

	r("-bug overlap placement", e + selfiePole(s:0,u:0) + logAt(rve:8), { Net([placeMy:"linky", parts:[
		Hamming([  n:"b", share:["a"], f:1]),
		Broadcast([n:"a",            f:1]),
	]]) })

	// This 2-test sequence leaves the second unable to run. Press ^r s
		r("- press ^r s", eSim + logAt(5), { Net() } )
		r("+Gen 1 Bulb", e + logAt(5) + vel(-8), { Net( [placeMy:"linky", parts:[
//			Hamming([n:"a",     P:["b"]]),
			Hamming([n:"a", share:["b"], f:1, jog:"2"]),
			Mirror(	[n:"b", "gain":-1, "offset":1, f:1]),
//			Tunnel([n:"evi", struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),
//			Generator([n:"lo", events: ["a", [], "again"], P:"evi="]),
		]]) })



	r("+Gen 2 Bulbs", e + selfiePole(s:90,u:0) + logAt(dat:9, eve:9) + vel(-4) +		//eSim
						[lookAt+X:"/net0/evi"], {Net([placeMy:"linky", parts:[
		Tunnel([n:"evi", struc:["a", "b"], of:"genBulb", placeMy:"stackz 0 -1"]),
		Generator([n:"lo", P:"evi=", eventLimit:0, events:[	//-1
			"a", ["a", "b"], "b", [],	"again"]]),
	]]) })
	r("+Gen 1 Bulb", eSim + selfiePole(s:90,u:0) + vel(-7) + logAt(eve:5), {Net([placeMy:"linky", parts:[
		Mirror([   n:"f", P:"a"]),
		Tunnel([n:"evi", struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),
		Generator([n:"lo", events: ["a", [], "again"], P:"evi="]),
	]]) })


	r("-Net name", e + logAt(eve:5), {Net() })

	r("+Gen 1 Port", eSim + selfiePole(s:90,u:0) + logAt(ani:5, dat:5, eve:5), {Net([placeMy:"linky", parts:[
		Tunnel([n:"evi", struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),
		Generator([n:"lo", events:["a", [], "again"], P:"evi="]),
	]]) })
		xxr("- bug: drive with sequence", e + selfiePole(s:0,u:0), { Net(["parts":[
//			Broadcast(["n":"a"]), Broadcast(["n":"b"]), Broadcast(["n":"c"]),
			Tunnel(["f":0, struc:["a", "b"], of:"genBcast"]),
//			Sequence(["f":0, "share":["a", "b"]]),
//			Sequence(["f":1, "share":["a", "b"]]),
//			Tunnel([struc:["a", "b"], of:["genAtom","genBulb","genBcast"][2]]),
		]]) })
		xxr("- bug: drive with sequence", e + selfiePole(s:0,u:0), {
			Tunnel([f:0, struc:["a", "b"], "of":"genBulb"])
		})
r("pack tighter", e + selfiePole(s:90,u:0), {Net([placeMy:"stacky", parts:[
	Tunnel([/*of:"nil_",*/ parts:[	Box()	]]),
]]) })
	r("- 'P' resizes wrong", e + selfiePole(s:0,u:0), {
		Tunnel([n:"evi", struc:["a", "b", "c"], of:"nil_", placeMy:"stackx -1 0"])
	})

xxr("+3Gen 7Ham Max Mir", eSim + selfiePole(s:070,u:23, z:0.535) + vel(-1) + logAt(dat:3, eve:5) +
			[lookAt:"/net0/evi/b/genP", "wBox":"none"], {Net([placeMy:"linky", parts:[
	Mirror([   n:"f3", P:"e1"]),
	Mirror([   n:"f2", P:"e2"]),
	Mirror([   n:"f1", P:"e3"]),
//	Bulb([     n:"b1", P:"e1"]	),
//	Bulb([     n:"b2", P:"e2"]	),
//	Bulb([     n:"b3", P:"e3"]	),
	MaxOr([    n:"e3", share:["d7"], f:1]),
	MaxOr([    n:"e2", share:["d3", "d5", "d6"], f:1]),
	MaxOr([    n:"e1", share:["d1", "d2", "d4"], f:1]),
	Mirror([   n:"f",  P:"e"]),
	MaxOr([    n:"e",  share:["d1", "d2", "d3", "d4", "d5", "d6", "d7"], f:1]),
	Hamming([  n:"d1", share:["a",         ], f:1]),
	Hamming([  n:"d2", share:[     "b"     ], f:1]),
	Hamming([  n:"d3", share:["a", "b"     ], f:1]),
	Hamming([  n:"d4", share:[          "c"], f:1]),
	Hamming([  n:"d5", share:["a",      "c"], f:1]),
	Hamming([  n:"d6", share:[     "b", "c"], f:1]),
	Hamming([  n:"d7", share:["a", "b", "c"], f:1]),
  	Tunnel([n:"evi", struc:["a", "b", "c"], of:"genAtom", placeMy:"stackz 0 -1"]),//, "d", "e", "f", "g", "h", "i", "j"
 	Generator([n:"lo", events:[
 			["a"          ],
 			["a", "b"     ],
			[     "b"     ],
			[     "b", "c"],
 			["a", "b", "c"],
 			["a",      "c"],
 			[          "c"],
			[             ],
			"again"] as [Any],   P:"evi="]),
]]) })
xxr("+2Gen 3Ham 3Max Mir", eSim + selfiePole(s:070,u:23) + vel(-1) + logAt(dat:3, eve:5) +
					[lookAt:"/net0/evi/b/genP"], {Net([placeMy:"linky", parts:[
	MaxOr([  n:"e2", share:["d3"], f:1]),
	MaxOr([  n:"e1", share:["d1", "d2"], f:1]),
	Mirror([ n:"f",  P:"e"]),
	MaxOr([  n:"e",  share:["d1", "d2", "d3"], f:1]),
	Hamming([n:"d1", share:["a",    ], f:1]),
	Hamming([n:"d2", share:[     "b"], f:1]),
	Hamming([n:"d3", share:["a", "b"], f:1]),
  	Tunnel([n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"]),
 	Generator([n:"lo", P:"evi=", events:[["a"], ["a", "b"], ["b"], [], "again"]]),
]]) })
	xxr("- Layout Bug -- OK", eSim + selfiePole(s:070,u:23) + vel(-1) + logAt(dat:3, eve:5) +
						[lookAt:"/net0/evi/d1/genP"], {Net([placeMy:"linky", parts:[
		MaxOr([  n:"e2", share:["d3", "d2"], f:1]),
		MaxOr([  n:"e1", share:["d1", "d2"], f:1]),
		Tunnel([n:"evi", struc:["d1", "d2", "d3"], of:"genAtom", placeMy:"stackz 0 -1"]),
	]]) })
		xxr("- auto-bcast Bug ", eSim + selfiePole(s:070,u:23) + vel(-1) + logAt(dat:3, eve:5) +
							[lookAt:"/netƒ0/evi/d1/genP"], {Net([placeMy:"linky", parts:[
			MaxOr([  n:"e2", P:["d2"], f:0]),
			MaxOr([  n:"e1", P:["d2"], f:0]),
			MinAnd([ n:"d2", f:1])
//			MaxOr([  n:"e2", share:["d2"], f:1]),
//			MaxOr([  n:"e1", share:["d2"], f:1]),
//			MinAnd([ n:"d2", f:1])
		]]) })
	xxr("- Layout Bug", eSim + selfiePole(s:90,u:0) + vel(-1) + logAt(5, dat:5, eve:5) +
						[lookAt:"/net0/evi/b/genP"], {Net([placeMy:"linky", parts:[
		MaxOr([  n:"e2", share:["d3", "d2"], f:1]),
		MaxOr([  n:"e1", share:["d1", "d2"], f:1]),
		Hamming([n:"d1", share:["a",    ], f:1]),
		Hamming([n:"d2", share:[     "b"], f:1]),
		Hamming([n:"d3", share:["a", "b"], f:1]),
		Tunnel([n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"]),
		Generator([n:"lo", P:"evi=", events:[["a"], ["a", "b"], ["b"], [], "again"], eventLimit:1, expose+X:"atomic"]),
	]]) })
	xxr("test Previous", eSim + selfiePole(s:25,u:10) + vel(-6) +
					logAt(dat:5, eve:5), { Net([placeMy:"linky", parts:[ //all:8
		Bulb(	  [n:"p", P:"a", f:0]),
//		Broadcast([n:"p", P:"a"]),
//		Previous( [n:"p", P:"a"]),
		Tunnel([n:"evi", struc:["a"], of:"genAtom", placeMy:"stackz 0 -1"]),//genPrev//genBulb
		Generator([n:"lo", events:["a", [], "again"], eventLimit:1, P:"evi=", expose+X:"atomic"]),
	]]) })		//["a", "b", [], "again"]
/*
	8 ss.. 16+
	16+
	12 s 13+
	12 s 13+
	16+
	14+
	15+
	13+
	12 s 13+
*/
r("+2Gen 3Ham Max Mir", eSim + selfiePole(s:40,u:3) + logAt(dat:3, eve:5) +
							[lookAt:"/net0/d1"], {Net([placeMy:"linky", parts:[
	Mirror([ n:"f",  P:"e"]),
	MaxOr([  n:"e",  share:["d0", "d1", "d2"], f:1]),
	Hamming([n:"d0", share:["a", "b"], f:1, jog+X:"1 0 0"]),
	Hamming([n:"d1", share:["b"], f:1]),
	Hamming([n:"d2", share:["a"], f:1]),
  	Tunnel([n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"], leafConfig:["value":1.0]),
//	Mirror( [n:"a", "gain":-1, "offset":1, f:1]),
//	Mirror( [n:"b", "gain":-1, "offset":1, f:1]),
//  	Tunnel([n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"]),//, "d", "e", "f", "g", "h", "i", "j"
// 	Generator([n:"lo", events:["a", ["a", "b"], "b", "again"],   P:"evi="]),
]]) })
xxr("- test eSim", eSimX + selfiePole(s:40,u:3) + logAt(dat:3, eve:5), {Net([placeMy:"linky", parts:[
	Mirror([n:"d2", P:["a,l:5"]]),
	Mirror( [n:"a", "gain":-1, "offset":1, f:1]),	// 1 -> 0 -> 1
]]) })
r("-Hamming output bad", e + selfiePole(s:40,u:3) + logAt(dat:5, eve:0), {Net([placeMy:"linky", parts:[
		Mirror([   n:"f", P:"e"]),
		Hamming([  n:"e", share:["a"], f:1]),
//		Mirror(   [n:"a", "gain":-1, "offset":1, f:1]),
  		Tunnel([n:"evi", struc:["a"], of:"genAtom", placeMy:"stackz 0 -1"], leafConfig:["value":1.0]),
//		Tunnel([n:"evi", struc:["a"], of:"genAtom", placeMy:"stackz 0 -1"]),//, "b", "d", "e", "f", "g", "h", "i", "j"
//		Generator([n:"lo", events:["a", [], "again"], eventLimit:1,  P:"evi="]),
	]]) })
	r("-Port coloring", eSim + selfiePole(s:40,u:3) + logAt(dat:5, eve:0), {Net([placeMy:"linky", parts:[
		Mirror([   n:"f", P:"a"]),
//		Broadcast([ n:"e", P:["a="], f:1]),
		Tunnel([n:"evi", struc:["a"], of:"genAtom", placeMy:"stackz 0 -1"]),//, "b", "d", "e", "f", "g", "h", "i", "j"
		Generator([n:"lo", events:["a", [], "again"], eventLimit:1,  P:"evi="]),
	]]) })
	r("-runs forever", eSim + selfiePole(s:40,u:3) + logAt(dat:9, eve:5), {Net([placeMy:"linky", parts:[
		Mirror([   n:"mir", P:"d0"]),
		Hamming([  n:"d0", share:["a", "a"], 	f:1]),
		Tunnel([n:"evi", struc:["a"], of:"genAtom"], leafConfig:["value":1.0]),
	]]) })

r("+2Gen 2Ham Max Mir", eSim + selfiePole(s:90,u:0) + vel(-4) + logAt(dat:9, eve:9), {Net([placeMy:"linky", parts:[
	Mirror([   n:"f", P:"e"]),
	MaxOr([    n:"e", share:["d1", "d2"], f:1]),	//, "c"
	Hamming([  n:"d1", share:["b"], f:1]),
	Hamming([  n:"d2", share:["a"], f:1]),
  	Tunnel([n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"]),//, "d", "e", "f", "g", "h", "i", "j"
 	Generator([n:"lo", events:[
		"a", "b", [], "again"			// hangs on 3
// 		"b", "a", [], "again"			// ok
// 		"a", [], "b", "again"			// ok
 		],   eventLimit:2, P:"evi="]),
//	Generator([n:"lo", events:["a", "b", [], "again"],   P:"evi="]),
]]) })

r("+2Gen 1And", eSim + selfiePole(s:90,u:0), {Net([parts:[
	Mirror([n:"f",  P:"mi"]),
	MinAnd([n:"mi",  share:["a", "b"], f:1]),
	Tunnel([n:"evi", struc:["a", "b"], of:"genBcast", placeMy:"stackz 0 -1"]),
	Generator([n:"lo", events:["a", ["a", "b"], "b", [], "again"],  P:"evi="]),
]]) })		//["a", "b", [], "again"]
r("+1Gen 1And", eSim + selfiePole(s:90,u:0) + vel(-6) + [lookAt:"/net0/tun/a"], {Net([parts:[
	Mirror([P:"a", f:0]), //BUG
	Tunnel([n:"tun", struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),	//.genAtom//genBcast
	Generator([n:"lo", events:["a", [], "again"], eventLimit:0, P:"tun"]),
]]) })

	r("-Double Click expose", e + selfiePole(s:90,u:0) , {
		Net([placeMy+X:"linky", parts:[
			Net([placeMy+X:"linky", parts:[
				Net([expose:"atomic", parts:[
					Box()
				]])
			]])
		]])
	})
		xxr("-expose link", e + selfiePole(s:90,u:0) + [lookAt:"/net1/net0"], {Net([placeMy:"linky", parts:[
			Mirror([P:"a", f:0]), //BUG
			Net([parts:[Broadcast([n:"a"])]])
		]]) })

r("Debug Tunnel placement", eSim + selfiePole(s:0,u:0), {
//	Tunnel([   n:"evi", struc:["a", "b"], of:"genAtom", placeMy:"stackz 0 -1"])
 	Generator([n:"lo", events:["a"]])
})
r("Bug Leaf port[R] nil", e + selfiePole(s:30,u:0), {Net([parts:[
	DiscreteTime([n:"hiDt", P:"con"]),
	Tunnel([      n:"con", struc:["z"], of:"genBcast", f:1]),
//	Actor([       n:"wheelA", placeMy:"linky", "con":Tunnel([struc:["z"], of:"genBcast", f:1]),
//	]),
]]) })
r("Bug w wire", e + selfiePole(s:30,u:0), {Net([parts:[
		Tunnel([n:"con", struc:["z"], of:"bcast", f:1]),
		MinAnd([share:["z"]]),
]]) })

// drill-downs:
r(e + selfiePole(s:90,u:0), {Net([parts:[
	Tunnel([n:"tun", struc:["a"], of:"genBcast", placeMy:"stackz 0 -1"]),
]]) })
r("Link LinkPort Bug", e + selfiePole(s:90,u:0), {Net([placeMy:"linky", parts:[
	MinAnd([n:"mi", share:["a"], f:1]),
	MaxOr([ n:"a"])
]]) })
r("Shaft Spin 3", eSim + selfiePole(s:30,u:0), {Net([parts:[
//	DiscreteTime([n:"hiDt", P:"con"]),
	Tunnel([n:"con", struc:["z"], of:"genBcast", f:0]),
	Generator([n:"lo", P:"con", events:["a", [], "a", "again"]]),
]]) })
r("BUG", e, { TimingChain([n:"aTc"]) })

 // MARK: - * *** END **** *
r("ALL TESTS DONE", e + ["LastTest":true],  { Part()	})	// Indicate Last test
//
 //
  //
   //
	//
	 //
	  //
	   //
	}
}
