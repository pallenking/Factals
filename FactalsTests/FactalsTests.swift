//
//  FactalsTests.swift
//  FactalsTests
//
//  Created by Allen King on 10/3/22.
//
// xcode: ctl opt cmd g -- redo last test

import XCTest
import Testing
import SceneKit

final class FactalsTests: XCTestCase {

//	static override func setUp() {
//		print("static override func setUp()")
//	}

	override func setUp() {
		print("-------------- XCTest.func setUp(): --------------------")
		super.setUp()
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		print("-------------- XCTest tearDownWithError code: --------------------")
		super.tearDown()
	}
//	override func setUpWithError() throws {
//		print("-------------- XCTest setup code: --------------------")
//		super.setUp()
//	}
//
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		print("-------------- XCTest tearDownWithError code: --------------------")
	}
	func testLeafKind() {
		let broadcastLeafKind 	= LeafKind.bcast
		let y					= broadcastLeafKind.pp(.tree)
		XCTAssertEqual(y, "LeafKind.bcast", "LeafKind.bcast.pp(.tree) FAILED")
	}
//	func testLeafConstructors() {
//		let fwb					= FwBundle([struc:"a", "of":LeafKind.bcast], leafConfig:["jog":"3"])
//		let str					= fwb.pp(.tree)
//		let correct				= "0001   <##        p1:FwBundle. . . . . . . ?48V \n0005   | < 0         a:Leaf    . . . . . . ?48V bindings:[:main, +:main, G:P, R:P] bindings:[:main, +:main, G:P, R:P] \n0003   | | < 0      main:Broadcas. . . . . ?48V Broadcast a1=0.00 cWin=0 Broadcast isBroadcast WTA false reComp\n0004   | | |\\            P:Port    . . . . ?48  0.00> unconnected\n"
//		XCTAssertEqual(str, correct, "failed Leaf Create--PP")
//	}
//?	func testLldb() {
//?		let x 					= LLDBParts
//?		lldbPrint(x, mode:.tree, [:])
//?	}
	func testUid() {	// incomplete
		let objectNs 			= FactalsModel(partBase:PartBase(/*tree:Part()*/), configure:[:])
		let objectSwift			= Part()
		let strNs				= pseudoAddressString(objectNs)
		let strSwift			= pseudoAddressString(objectSwift)
		print("pseudoAddress[ns:\(strNs), swift:\(strSwift)]")
	}

//	class Simulatee : NSObject, FwAny {					// won't compile
//	class Simulatee : NSObject 		  {		// FwAny	// HANGS
	class Simulatee : 		 	FwAny {					// WORKS
		func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
			//ppCommon(mode, aux)		// NO, try default method
			return "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ FSIVjsd"
		}
	}
	func testPpModeDefaultHangs() {
		print("&&&&&& EXPECT     ppMode Default Hang")

		let sim1				= Simulatee()
		let sim1str				= sim1.pp(.line)			// HANGS
		print("Simulatee:   '\(sim1str)'    DOESN'T HANG")					//

		let sim2				= Simulatee()
		print("Simulatee:   '\(sim2.pp())'    DOESN'T HANG")					//			// HANGS
		/*
		object calls method pp()
				class Simulatee { func pp(_ mode:PpMode = .tree, _ aux:FwConfig) -> String	{
				extension FwAny { func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String {
		 */
	}
//	func testRootAsPart1() {
//		let rootPart1			= Part()
//		print("Part:     '\(rootPart1.pp())'    DOESN'T HANG")				//
//		let factalsModel1		= FactalsModel(part:rootPart1)
//		print("FactalsModel:      '\(factalsModel1.pp())'    DOESN'T HANG")					// OK // (.tree, [:])
//		let document			= FactalsDocument(factalsModel:factalsModel1)
//
//		factalsModel1.anotherVewBase(vewConfig:.openAllChildren(toDeapth:5), fwConfig:[:])
//		print("FactalsModel(rP1:)  '\(factalsModel1.rootVew0?.pp() ?? "nil")'    DOESN'T HANG")								// OK // (.tree, [:])
//
//		print("&&&&&& No         ppMode Default Hang     errors")
//	}

//testSounds() {
//
//}

	func testVewPp() {
		let m1 = MaxOr()
		let m2 = m1.pp(.tagClass)
		XCTAssertTrue(m2.hasSuffix(":MaxOr"))

		let n1 = Vew(forPart:m1)
		let n2 = n1.pp(.tagClass)
		XCTAssertTrue(n2.hasSuffix(":Vew"))

		let o0 = PartBase(tree:Part())
		let o1 = VewBase(for:o0, vewConfig:.openAllChildren(toDeapth:5) )
		let o2 = o1.pp(.tagClass)
//??	XCTAssertTrue(o2.hasSuffix("factalsModel BAD"))		// may be wrong

//		let p2 = self.pp(.tagClass)
//		XCTAssertTrue(p2.hasSuffix(":FactalsTests"))		// may be wrong
	}
	func testStringFormat() {
		let leaf				= Leaf(["name":"g", "of":"genBcast"])		//
		let l					= leaf.boundPort(named:"R")
		XCTAssertTrue(l != nil, "boundPort(named(xx))")
//		assert(leaf.boundPort(named:"R") != nil, "Leaf '\(leaf.pp(.fullName))' has no R port\n")
//		guard leaf.boundPort(named:"R") != nil else
//		{	fatalError("Leaf '\(leaf.pp(.fullName))' has no R port\n")			}
//
//
//		let l					= leaf.boundPort(named:"R")
//		let args : [CVarArg]	= ["/p3/wheelA/evi/a", "P", "gen.P,[]"]
//		let format				= "bld5    Inward check as Leaf '%@'\n   Search inward for binding[%@]->'%@'"
//		let x					= String(format:format, arguments:args)
	}
//	func getPort(named:String, localUp wantUp:Bool?=nil, wantOpen:Bool=false, allowDuplicates:Bool=false) -> Port? {
//		logBld(7, " '\(fullName)'   called getPort(named:\"\(named)\" want:\(ppUp(wantUp)) wantOpen:\(wantOpen) allowDuplicates:\(allowDuplicates))")
	func testGetPortNamed() {
		 // -- Check BINDINGS?
//		if let bindingString 	= bindings?[named] {
//			let bindingPath		= Path(withName:bindingString)
//			let boundPart		= find(path:bindingPath)	// find bound Part
//nop
//			let sWantUp			= wantUp==nil ? nil : wantUp! ^^ boundPart!.upInPart(until:self)
//
//			if let bAtom 		= boundPart as? Atom {			// Case 1: Atom?
//	/**/		return bAtom.getPort(named:named, localUp:sWantUp, wantOpen:wantOpen, allowDuplicates:allowDuplicates)
//			}								//????		//A\\ ??
//
//			if let rv 			= boundPart as? Port {			// Case 2: Port?
//				if !wantOpen || rv.con2==nil {
//	/**/			return rv										// okay
//				} 													// or Recursion:
//	/**/		return rv.atom?.getPort(named:bindingPath.portName!, localUp:wantUp, wantOpen:wantOpen, allowDuplicates:allowDuplicates)
////	/**/		return rv.atom?.getPort(named:bindingString, localUp:wantUp, wantOpen:wantOpen, allowDuplicates:allowDuplicates)
//			}
//			panic("boundPart \(boundPart?.pp(.fullNameUidClass) ?? "nil, ") not recognized: ")
//		}
	}

	func testForEach() {
		let array = ["aaa", "bbb", "ccc"]
		var a = ""
		array.forEach { str in
			a.append(str)
			print("Str = \(str)")
		}
		XCTAssertEqual(a, "aaabbbccc", "actual:\(a) != expected:\"aaabbbccc\"")
	}
	func testAllLeafs() {
		let tunnel		= Tunnel(["struc":["a", "b", "c", "d"], "of":"bcast", "placeMy":"stackz 0 -1"])
		var rv:String	= ""
		tunnel.forAllLeafs {
			(leaf:Leaf) in
			rv			+= leaf.name + " "
		}
		XCTAssertEqual(rv, "a b c d ", "forAllLeafs()")
	}

	 // First test is verrry easy
	func testPp() {
		let t1 = "xsweyzzy", t2 = 32
		let tests:[(()->String, String)]	= [
			({"Most basic test"}, 	"Most basic test"),
			({"String \(t1) here"}, "String xsweyzzy here"),
			({"Number \(t2)"}, 		"Number 32"),
		]

		for (i, (actual, expected)) in tests.enumerated() {
			print("\n############ \(i+1). Expecting: \"\" \(expected) \"\"   ###########")
			let act					= actual()
			XCTAssertEqual(act, expected, "\(i): actual:\(act) != expected:\(expected)")
		}
	}

	func testClassFromString () {
		let tests:[(Part, String)]	= [	// ALL CLASSES AS OF 20210911
			(Part(), 						"Part"			),
			(	Atom(), 					"Atom"			),
			(		Ago(), 					"Ago"			),
			(		DiscreteTime(), 		"DiscreteTime"	),
			(		GenAtom(), 				"GenAtom"		),
			(		Link(), 				"Link"			),
			(			MultiLink(), 		"MultiLink"		),
			(		Mirror(), 				"Mirror"		),
			(		Modulator(), 			"Modulator"		),
			(			Rotator(), 			"Rotator"		),
			(		Net(), 					"Net"			),
			(			Actor(), 			"Actor"			),
			(			FwBundle(), 		"FwBundle"		),
			(				Leaf(), 		"Leaf"			),
			(				Tunnel(), 		"Tunnel"		),
			(			Generator(), 		"Generator"		),
			(		Portless(), 			"Portless"		),
			(		Previous(), 			"Previous"		),
			(		Splitter(), 			"Splitter"		),
			(			Bayes(), 			"Bayes"			),
			(			Broadcast(), 		"Broadcast"		),
			(			Bulb(), 			"Bulb"			),
			(			Hamming(), 			"Hamming"		),
			(			KNorm(), 			"KNorm"			),
			(			MaxOr(), 			"MaxOr"			),
			(			MinAnd(), 			"MinAnd"		),
			(			Multiply(),			"Multiply"		),
			(			Sequence(), 		"Sequence"		),
			(		TimingChain(), 			"TimingChain"	),
			(		WorldModel(), 			"WorldModel"	),
			(	CommonPart(), 				"CommonPart"	),
			(		Box(),					"Box"			),
			(		Cylinder(),				"Cylinder"		),
			(		Hemisphere(),			"Hemisphere"	),
			(		ShapeTest(),			"ShapeTest"		),
			(		Sphere(),				"Sphere"		),
			(		TunnelHood(),			"TunnelHood"	),
//			(		LinkPort(), 			"LinkPort"		),  // LinkPort(cUp, parent:self, i0:p0, color0:.green)
			(	PolyWrap(), 				"PolyWrap"		),
			(	Port(), 					"Port"			),
			(		MultiPort(), 			"MultiPort"		),
			(		ParameterPort(), 		"ParameterPort"	),
			(		Share(), 				"Share"			),
			(			BayesSh(), 			"BayesSh"		),
			(			BroadcastSh(), 		"BroadcastSh"	),
			(			BulbSh(), 			"BulbSh"		),
			(			HammingSh(), 		"HammingSh"		),
			(			KNormSh(), 			"KNormSh"		),
			(			MaxOrSh(), 			"MaxOrSh"		),
			(			MinAndSh(), 		"MinAndSh"		),
			(			MultiplySh(),		"MultiplySh"	),
			(			SequenceSh(), 		"SequenceSh"	),
		//	(	Parts(), 					"Parts"			),
		]
		for (i, (part, expectedClassName)) in tests.enumerated() {

			 // Forward: :Part -> String/* *** */
			let partsClassName =    part.fwClassName
										/* *** */
			if partsClassName != expectedClassName {
				let msg			= "testClassFromString \(i): (\(part.pp(.tagClass)).fwClassName " +
								  "is \(partsClassName), expected \(expectedClassName)"
				XCTAssertEqual(partsClassName, expectedClassName, msg)
				print("############ \(i+1). (\(part.pp(.tagClass))).fwClassName is \(partsClassName), should be \(expectedClassName) ###########")
				let _			= part.fwClassName	// try again for debugger
			}

			 // Backward: String -> Part.Type	/* *** */
			let expectedClass : Part.Type =    classFrom(string:expectedClassName)
												/* *** */
			let partsClass		= type(of:part)
			if expectedClass != partsClass {
				XCTAssertFalse(true, "")		//		XCTAssertFalse(false, "")
				print("############ \(i+1). (\(part.pp(.tagClass))).Type is \(partsClass), should be \(expectedClass) ###########")
				let _ : Part.Type = classFrom(string:expectedClassName)
			}
		}
	}
	func XXtestPartFind() {
		let parts = Net(["n":"c", "parts":[
				Broadcast(["n":"a"]),
				MaxOr(	  ["n":"b"]),
			] ])
		struct Test {
			let start	: String
			let path	: Path
			let end		: String
		}
		let tests:[Test] 		= [
			Test(start:"/a", path:Path(withName:"b"), end:"/c/b"),
		]
		for (i, test) in tests.enumerated() {
			let start			= parts.find(name:test.start)
			XCTAssert(start != nil, "\(i): Could not find part named '\(test.start)'")
			let end				= start!.find(path:test.path)
			XCTAssertEqual(end?.fullName, test.end, "\(i): From '\(start!.fullName)', Path '\(test.path.pp(.line))' FAILED")
		}
	}

	func testIdenticalOperator() {
//		var vew : Vew?			= Vew()
//		vew						??= Vew()

		struct Test {
			let lhs : Part?
			let rhs : Part?
			let ans : Part?
			let note: String
		}
		let partA 				= Part(["n":"A"])
		let partB 				= Part(["n":"B"])
		let tests:[Test] 		= [
			Test(lhs:nil,   rhs:nil,   ans:nil,   note:"nil ?? nil -> nil"),
			Test(lhs:nil,   rhs:partA, ans:partA, note:"nil ?? A   -> A"),

			Test(lhs:partA, rhs:nil,   ans:partA, note:"A   ?? nil -> A"),
			Test(lhs:partA, rhs:partB, ans:partA, note:"A   ?? B   -> A"),	// booby tray .null someday
		//	Test(lhs:nil,   rhs:nil,   ans:partA, note:"purposefully wrong -- should fail"),
		]
		for (i, test) in tests.enumerated() {
			var lhs	: Part?		= test.lhs

//			lhs					??= test.rhs
			lhs					= lhs ?? test.rhs

			let match			= lhs === test.ans
			XCTAssert(match, "testNilEqualsOperator \(i): \( test.note)")
		}
	}

	func testPartIdenticalEquatable() {
								//
		let part1  = Part(["n":"a"]), part2	 = Part(["n":"a"]), part3 = Part(["n":"a"])
		let	part4  = Part(["n":"b"])
			part2.nameTag 		= part1.nameTag		// make part2 (value) Equavalent to part1
//			part2.uidForDeinit 	= part1.uidForDeinit// make part2 (value) Equavalent to part1
		let port1  = Port(["n":"a"]), port2	 = Port(["n":"a"]), port3 = Port(["n":"b"])
		let atom1  = Atom(["n":"a"]), atom2	 = Atom(["n":"a"]), atom3 = Atom(["n":"b"])
		let net1  				= Net(), 			net3	= Net()
		let ago  				= Ago();

		let tests:[(Part, Part, Bool, Bool)]	= [
			// =========== ident  equal ========== Parts Only
			(part1, part1, true , true ),		// 1
			(part1, part2, false, true ),		// 2
			(part1, part3, false, true ),		// 3
			(part1, part4, false, false),		// 4
			// =================================== Ports and Ports
			(port1, port1, true , true ),		// 5
			(port1, port2, false, true ),		// 6
			(port1, port3, false, false),		// 7
			(port1, part1, false, false),		// 8
			(part1, port1, false, false),		// 9
			// =================================== Parts and Atoms
			(atom1, atom1, true , true ),		// 10
			(atom1, atom2, false, true ),		// 11	bad
			(atom1, atom3, false, false),		// 12
			(atom1, part1, false, false),		// 13
			(part1, atom1, false, false),		// 14
			// =================================== Parts and Nets
			(net1,  net1,  true , true ),		// 15
			(net1,  part1, false, false),		// 16
			(part1, net1,  false, false),		// 17
			(net1,  net3,  false, false),		// 18
			// =================================== Ago
			(ago,   ago,   true , true ),		// 19
			(part1, ago,   false, false),		// 20
			(ago,   part1, false, false),		// 21
			(net1,  ago,   false, false),		// 22
			(ago,   net1,  false, false),		// 23
		]
		for (i, (p1, p2, identity, equatable)) in tests.enumerated() {
			print("\n############  \(i+1). (\(p1.pp(.tagClass))).equalsPart(\(p2.pp(.tagClass)))  ###########")
			print("\(p1.pp(.tree)) ??====(\(identity ? " " : "!")identical, \(equatable ? " " : "!")equatable)====??  CALCULATED\n\(p2.pp(.tree))", terminator:"")
			let matchIdnetP		= p1 === p2						//  identity
			let matchEqualP		= p1.equalsFW(p2)				//  equatableFW

			 // Questionable Value:
			print(" p1 \(matchIdnetP ? "=" : "!")== p2, p1.equals(p2) => \(matchEqualP)")
			XCTAssertEqual(matchIdnetP, identity,  "testPartIdenticle \(i): \(p1.pp(.tagClass)) === \(p2.pp(.tagClass)) isn't \(identity)")
			XCTAssertEqual(matchEqualP, equatable, "testPartEquatable \(i): \(p1.pp(.tagClass))  == \(p2.pp(.tagClass)) isn't \(equatable)")
			let matchIdnetM		= p1 !== p2						// !identity
			let matchEqualM		= p1.equalsFW(p2)	== false 	// !equatableFW
			XCTAssertEqual(matchIdnetM, !identity, "!testPartIdenticle \(i): \(p1.pp(.tagClass)) === \(p2.pp(.tagClass)) isn't \(identity)")
			XCTAssertEqual(matchEqualM, !equatable,"!testPartEquatable \(i): \(p1.pp(.tagClass))  == \(p2.pp(.tagClass)) isn't \(equatable)")

			 // Redo for debug if any errors
			if matchIdnetP != identity || matchEqualP != equatable ||
			   matchIdnetM == identity || matchEqualM == equatable {
				//bug // do again for debugging
				let matchIdnetP		= p1 === p2
				let matchEqualP		= false//p1  == p2
				let _ = matchIdnetP ^^ matchEqualP
			}
			nop
		}
	}
								
	func testSCNMatrix4Mult() {
		 // 20211006:PAK: failed to catch EXC_BAD_ACCESS in "*"
		let test				= SCNMatrix4.identity * SCNMatrix4.identity
		XCTAssert(test == SCNMatrix4.identity, "matrix multiply")
	}

	func testPolyWrap() {
		let tests:[(String, Part)]	= [
			("Most basic test", 		Part(	 ["n":"a"])),
			("First Atomic form", 		Portless(["n":"a"])),
			("First Port",				Port(	 ["n":"a"])),
			("First form with Ports",	Atom(	 ["n":"a"])),
			("First Splitter form",		MaxOr(	 ["n":"a"])),
			("Pruned Big example 1",	Net() ),
			("Big example 1",			Net(["placeMy":"stackx -1 0", "parts":[
				Broadcast(["n":"a"]),		MaxOr(	 ["n":"b"]),
				MinAnd(	  ["n":"c"]),		Bayes(	 ["n":"d"]),
				Hamming(  ["n":"e"]),		Multiply(["n":"f"]),
				KNorm(	  ["n":"g"]),		Sequence(["n":"h"]),
				Bulb(	  ["n":"i"]),
			] ]) ),
			("2-Atom Example",	Net(["placeMy":"linky", "parts":[
				Broadcast(		["n":"a"]),
			//	MaxOr(			["n":"b"]),
			] ]) ),
		]
		 // Run Tests
		for (i, (purpose, testPart)) in tests.enumerated() {
			print("\n############ \(i+1). Beginning of   '\(purpose)'   ###########")
			guard let serdesPart = try? serializeDeserialize(testPart) else {
				XCTFail("serializeDeserialize returns nil or throws")
				continue
			}
			let match			= true//serdesPart == testPart
			print("testPolyWrap() has no EQUITABLE")
			XCTAssert(match, "Test \(i+1): Purpose: \(purpose)")
		}
	}

	func serializeDeserialize(_ inPart:Part) throws -> Part? {
		logSer(5, "========== inPart_ to Serialize:\n\(inPart.pp(.tree))", terminator:"")

		 //  - INSERT -  PolyWrap's
		let inPolyPart:PolyWrap	= inPart.polyWrap()	// modifies inPart
		logSer(5, "========== wrapped inPart:\n\(inPolyPart.pp(.tree))", terminator:"")

		 //  - ENCODE -  PolyWrap as JSON
		let jsonData 			= try JSONEncoder().encode(inPolyPart)
		guard let jsonString 	= String(data:jsonData, encoding:.utf8) else {
			logSer(5, "========== JSON: FAILED")
			return nil
		}
		logSer(5, ("========== JSON: " + jsonString).wrap())

		 //  - DECODE -  PolyWrap from JSON
		let outPolyPart			= try JSONDecoder().decode(PolyWrap.self, from:jsonData)
		logSer(5, "========== outPolyPart is recovered warapped inPart:\n\(outPolyPart.pp(.tree))", terminator:"")
		let match				= true//outPolyPart == inPolyPart
		print("testPolyWrap() has no EQUITABLE")
		logSer(5, "\t\t\tMatches:\(match)")

		 //  - REMOVE -  PolyWrap's
		let outPart				= outPolyPart.polyUnwrap()
		 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
		let _					= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()
		logSer(5, "========== Output From Deserialize:\n\(outPart.pp(.tree))", terminator:"")
		
		return outPart
	}

//	func testPpUidSimple() {
//		let y  : String			= ppUid(pre:"pre:", DOClog, post:":post")
//		//Ambiguous use of 'ppUid(pre:_:post:showNil:aux:)'
//		XCTAssert(y.hasPrefix("pre:") && y.hasSuffix("post"))
//	}

	func testMatrix4PpMode() {
		var aMtx				= SCNMatrix4(SCNVector3(4,5,6))
		let aMtxPpLine			= aMtx.pp(.line)
	}
	func XtestFindPartVewScn() {
		let partBase			= PartBase(fromLibrary:"Structure for XCTEST")
		logTst(1, "===========####: built test \(partBase.hnwMachine.titlePlus())  ####=================\n")
//		logTst(1, "===========####: built test '\(partBase.title)' from '\(partBase.sourceOfTest)'  ####=================\n")
		partBase.wireAndGroom([:])
		let p1					= partBase.tree.find(name:"p1")
		let strP1				= p1?.fullName
		XCTAssert(strP1 == "/p2/p1")

		let vewBase				= VewBase(for:partBase, vewConfig:vewConfigAllToDeapth4)		// Create
		vewBase.tree.openChildren(using:vewConfigAllToDeapth4)	// Vew configuration	//vewBase.updateVSP()
		let vewP1				= vewBase.tree.find(part:p1!)
		let strVew				= vewP1?.fullName
		XCTAssert(strVew == "/_p2/_p1")

		let scnP1				= vewP1?.scn
		let strScn				= scnP1?.fullName
		XCTAssert(strScn == "/*-p2/*-p1")
		nop
	}
	func testFwXppMode() {
		print("""
			\n\n\n
			 ============================================================================
			======================== Testing with fwTypesTest(): =========================
			""")
		 /// All these Object Kinds
		let objects :[FwAny] = [
			//-------- top -------
			SCNVector4(1.0,2.0,3.0,4.0),	// ppXYZWena == 7?
			SCNVector3(1,2,3),
			SCNMatrix4Identity,				// test the various stringification of various forms
			SCNMatrix4(1.0,2.0,3.0,4.0,  1.1,1.2,1.3,1.4,  2.1,2.2,2.3,2.4,  1.1,1.2,1.3,1.4),
			String("Printing Out A String"),
			Bool(true),
			Int(1234),
			Int16(32767),					// No Int8 or UInt*
			Float(12.34),
			CGFloat(777.2),
			Array(["A", 0, 3.2]),
		//	Dictionary(["A":4, "B":5, "C":6]),
		//	NSObject(),						// needs work
	 // 190627 eliminated
			Port(),
			MaxOr(),						// needs work, ...
			Net(["parts":[Port(), MaxOr()]]),
						]
		for obj in objects {
			print("\n"+"======== \(obj.pp(.fwClassName)) ==========")
			print("   pp( .fwClassName     )  -->  \(obj.pp(.fwClassName))")
			print("   pp( .fullNameUidClass)  -->  \(obj.pp(.fullNameUidClass))")
			print("   pp( .name            )  -->  \(obj.pp(.name))")
			print("   pp( .fullName        )  -->  \(obj.pp(.fullName))")
			print("   pp( .phrase          )  -->  \(obj.pp(.phrase))")
			print("   pp( .line            )  -->  \(obj.pp(.line))")
			print("   pp( .tree            )  --> ------------------\n\(obj.pp(.tree))"
				   + "\n" + "-----------------------------------------------")
		}
		if falseF {
			print("Look okay? [y]")
			let pass = readLine()
			let p						= pass == nil || pass == "y" || pass == ""
			print("\"\(pass ?? "???")\" -> " + (p ? "PASS" : "FAIL\n"))
			XCTAssertEqual(p, true, "Pretty Print Tests")
		}
	}

	 /// Expedient test: build specified tests in the library. (Correctness and vew not checked)
	func testBuildLibrary() {

		 // Build every part in the library
		let justNumber : Int?	= nil	//10//94//217//
		let firstNumber			= 1
		var lastNumber			= 1200//74//12//31//1200	// Limit of tests
		for var testNum in firstNumber...lastNumber {
			if let justNumber {
				testNum 		= justNumber
				lastNumber		= justNumber
			}
			logTst(1, "\n==================== XCTest Build Document: 'entry\(testNum)' ====================")

			let partBase		= PartBase(fromLibrary:"entry\(testNum)")
			logTst(1, "===========####: built test \(partBase.hnwMachine.titlePlus())  ####=================\n")
			partBase.wireAndGroom([:])

			if justNumber != nil || partBase.hnwMachine.config.bool("LastTest") ?? false {
				break							// Done
			}
		}
		logTst(1, "\n==================== XCTest completed all \(lastNumber-12) tests ====================")
	}	/// When it leaves here, deinit's things, then accesses an illegal address
	 // Test form XCTest:
	func testOpen(urlNamed name:String) {
//		openURL(named:name)
	}

	func testUint8() {
		let spin3any : FwConfig = ["spin":3]								//		Sequence([spin:3]),
		var rv : UInt8?			= nil
		if let spinAny			= spin3any["spin"],
		  let spinInt			= Int(fwAny:spinAny),
		  let spinUInt8			= UInt8?(UInt8(spinInt)) {			/// why so convoluted? -> bug in UIint8 extensions
			rv	 				= spinUInt8
		}
//		if let spinAny			= spin3any["spin"],
//		  let spinUInt8			= UInt8(spinAny) {			/// why so convoluted? -> bug in UIint8 extensions
//			rv	 				= spinUInt8
//		}
		XCTAssertEqual(rv, UInt8(3), "Failed tom make UInt8(3) from FwConfig")
	}

// Someday:
	//		let uz					= SCNVector3.uZ
	//		print(uz.pp(.phrase))
	//		let ppp					= uz.pp(.phrase)

//	func testUrlDocLoadX() {
//		let tests				= [
//			("", ""),
//		]
//		for (url, cUrl) in tests {
//			let x = testOpen(urlNamed:test)
//		}
//	}
	let aux4PpFwTest : FwConfig = [
		"ppViewOptions": "UFVSPLETBIW", 					"ppNNameCols"	: 8,
		"ppLinks"	   : true, "ppScnBBox"	  : false,		"ppNClassCols"	: 8,
		"ppPorts"	   : true, "ppFwBBox"	  : true,		"ppNUid4Tree"	: 3,
		"ppScnMaterial": false,"ppXYZWena"    : "XYZW",		"ppNUid4Ctl" 	: 3,
		"ppDagOrder"   : true, "ppViewTight"  : false,		"ppNCols4Posns"	: 20,
		"ppParam"	   : false,"ppBBoxCols"   : 28,			"ppNCols4ScnPosn":35,
		"ppIndentCols" : 10,   "ppFloatA"	  : 4, 			"ppFloatB"		:1,
	]
	func testPpFwTypes() {
		let tests :[(FwAny, PpMode, String)] = [
			// input 						PpMode  				expected
			(fwObj:SCNVector3.uZ,		ppMode:PpMode.short,	expect:"[ 0.0 0.0 1.0]"),
			(fwObj:SCNVector3.uZ,		ppMode:PpMode.phrase,	expect:"[z: 1.]"),
// !!!		(fwObj:SCNMatrix4.identity,	ppMode:PpMode.line,		expect:"I"),
//			(fwObj:SCNMatrix4.identity,	ppMode:PpMode.phrase,	expect:"I"),
		]
		for (fwObj, ppMode, expect) in tests {
			let result 			= fwObj.pp(ppMode, aux4PpFwTest)
			let match			= result == expect
			if !match {
				XCTAssertEqual(result, expect, "testPpFwMode failed")
				logTst(1, "Test fwObj:'\(fwObj.pp())' .pp(in mode \(ppMode)) actual:'\(result)' expected:'\(expect)' MISMATCH")
				bug
				let _ 			= fwObj.pp(ppMode, aux4PpFwTest)
			}
		}
	}
	 // Test form XCTest:		/// MOVE TO ManyTests.swift
//	func testOpen(urlNamed name:String) {
//		APP.openURL(named:name)
//	}
//	func tesSoundLoadding() {
//		let m = Foundation. ?? Bundle.main
//		
//		let a00g = m.url(forResource: "di-sound", withExtension: "m4a")
//		let a01x = m.url(forResource: "da-sound", withExtension: "m4a")
//		let a02g = m.url(forResource: "di-sound", withExtension: "m4a", subdirectory: "")
//		let a03x = m.url(forResource: "di-sound", withExtension: "m4a", subdirectory: "Assets")
//		let a04x = m.url(forResource: "di-sound", withExtension: "m4a", subdirectory: "Assets.xcassets")
//		
//		let b00x = SCNAudioSource(named: "di-sound")
//		let b01x = SCNAudioSource(named: "da-sound")
//		let b02  = SCNAudioSource(named: "da-sound.dataset/da-sound.m4a")
//		let b03  = SCNAudioSource(named: "di-sound.m4a")
//		
//		let _ = (a00g, a01x, a02g, a03x, a04x, b00x, b01x, b02, b03)
//
//		if let source = SCNAudioSource(named:"Assets.xcassets/di-sound.dataset/di-sound") {
//			source.load()
//			nop
//		} else {
//			print("Failed to load audio source 'da-sound'")
//		}
//	}
}
