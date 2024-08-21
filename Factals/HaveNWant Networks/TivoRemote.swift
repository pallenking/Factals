//  TivoRemote.swift -- Networks controlling a Tivo Remote ©2021PAK
//
import SceneKit

class TivoRemote : Book {

	override func loadTest(args:ScanForKey, state:inout ScanState) {
		super.loadTest(args:args, state:&state)
		let e 	 : FwConfig		= [:]
		let eXYtight : FwConfig = e + [	// For debugging Link positions:
			"ppViewTight"		:true,		// eliminate titles in print
			"ppIndentCols"		:7,			// limit of tree height indentations
			"ppViewOptions"		:"UFVTWB",	// just Posn, World, and FwBBox
			"ppXYZWena"			:"XY",		// 3 axis(xyz), world coords,
			"ppNNameCols"		:6,			// shortened name
			"ppNClassCols"		:6,			// shortened class
			"ppNCols4VewPosns"	:15,
		//	"ppFloatA":5, "ppFloatB":2,		// 2 desimal digits: F5.2 (default is F4.1)
		]

		 // MARK: - * Tivo World
		state.scanSubMenu		= "Tivo World"
		r("Atom()", e,  { Atom() })
/*
choose  ** ACTIONS **
	tivo								// home
	live								// switch to ~
	up,down,left,right
	ok									// do this one
	channelUp, channelDown
																				//	back								// ??
																				//	exit,guide,thumbsUp,thumbsDown		// ??
																				//play ACTIONS
																				//	play?
																				//	foreward,backward	 (3 speeds)
																				//	stop
																				//	forward30,back8
																				//	A,B,C,D
SENSOR
	lineNo<item> : Int				// line number of item

SENSOR.aboveAtBelow
	<now>isAbove<goal> 	=> lineNo<now> > lineNo<goal>.aboveAtBelow
	<now>isAt<goal> 	=> lineNo<now> = lineNo<goal>.aboveAtBelow
	<now>isBelow<goal> 	=> lineNo<now> < lineNo<goal>

CONTEXT select<now,goal> -> Bool
	INPUTS: aboveAtBelow
	STATE:
		<now>isAbove<goal>					=> up
		<now>isAt<goal>						=> okay, true	// press OK, exit true
		<now>isBelow<goal>					=> down

CONTEXT: findProgramToWatch:
	ACTIONS<choose>
	STATE: unknown, onScreen, selectionScreen, startScreen
		unknown homeScreen??				=> tivo, tivo, channelUp, channelUp	//
		onScreen, select<selectionScreen>	=> selectionScreen
		selectionScreen, select<startScreen>=> startScreen
		startScreen, select<playScreen>


*/
		let screenStatus : [Any] = [
			"commercial",
			"commercialEnd",
			"content",
			"contentEnd"
		]

		let remoteButtons : [Any] = [
					"name:remoteButtons", "placeMy:stackz",
				 	[	 "name:Row1", "placeMy:stackx",
				 			"tivo",				// home button
							"up",
							"live",				// live button
							"channelUp",
					], ["name:Row2", "placeMy:stackx",
							"left",				//
							"ok",				// do this one
							"right",
							"channelDown",
					], ["name:Row3", "placeMy:stackx",
							"back",				//
							"down",				//
							"exit",				//
							"record",			//
					], ["name:Row4", "placeMy:stackx",
							"guide",			//
							"thumbsDown",		//
							"thumbsUp",			//
							"info",				//
					], ["name:Row5", "placeMy:stackx",
							"reverse",			//
							"greenArrow",		//
							"forward",			//
							"skip",				//
					], ["name:Row6", "placeMy:stackx",
							"back8",			//
							"stop",				//
							"forward30",		//
							"next",				//
					], ["name:Row7", "placeMy:stackx",
							"A",				//
							"B",				//
							"C",				//
							"D",				//
					],
				]
		let remoteButtons0 : [Any] = [
				[	"placeMy:stackz",
		 			"a",
		 			"b",
				], ["placeMy:stackz",
		 			"c",
		 			"d",
		 			"e",
				] 					]
//		r("- bug: drive with sequence", eXYtight + ["simRun":true] + selfiePole(s:90,u:0), { Net(["placeMy":"linky", "parts":[
//			Mirror(["n":"v", "P":"s", "gain":-1, "offset":1]),
//			Sequence(["n":"s", "f":1, "share":["a"]]),//, "a", "a", ]]),
//			Tunnel(of:.genMirror,["struc":["a"]]),
//		]]) })
//		r("- bug: why call reSize twice", eXYtight + selfiePole(s:90,u:0), { Net(["placeMy":"linky", "parts":[
//			Sequence( ["f":1, "share":["a", "b"]]),
////			Broadcast(["f":1, "share":["a", "b"]]),
//			Tunnel(of:.genAtom,  ["struc":["a", "b"]]),
//		]]) })
//		r("- bug: drive with sequence", eXYtight + selfiePole(s:90,u:0), { Net(["placeMy":"linky", "parts":[
////			Broadcast(["f":1, "share":["a"]]),
//			Sequence( ["f":1, "share":["a"]]),
//			Broadcast(["n":"a"]),
//		]]) })
//
		// WORKS:
		xxr("- bug: drive with sequence", e + selfiePole(s:0,u:0), { Net(["parts":[
			Sequence(["f":1, "share":["a", "b", "c"]]),
			Tunnel(["struc":["a", "b", "c"]]),
		]]) })
//		r("+ bug: ? Leaf and GenAtom overlap", e + selfiePole(s:0,u:0), { Net(["parts":[
//			Tunnel(  ["struc":["a", "b"]]),						// in X
//			FwBundle(["placeMy":"stackz", "struc":["a", "b"]]),	// in Z
//			FwBundle(["struc":["placeMy:stackx", "a", "b"]]),						// Vert
//		]]) })
//		r("+ bug: ? Net and Box overlap", e + selfiePole(s:0,u:0), {
//			Net(["parts":[
//				Box(),
//			]
//		]) })


		r("Port()", e, { Port() })
		r("Atom()", e,  { Atom() })

		 // MARK: - * *** END **** *
		//r("DONE TESTS     --     ALL TESTS DONE       ", e + ["lastTest":1], { Part() })
	}
}

