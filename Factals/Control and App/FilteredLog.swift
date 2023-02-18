//  FilteredLog.swift -- selective filtering of Log messages ©2021PAK

import Foundation

//	at<A>(<V>, {...}) executes an action dependent on "arguments" <A> and <V>.
//	If the current DOClog.verbosity[<A>] is >= <V> the closure is executed.
//
//	The following verbosities <V> are defined:
		// 0 : silent (prints nothing)		// 5 : Normal
		// 1 : initialization and errors	// 6 : Verbose
		// 2 : 1 line per model				// 7 : a lot
		// 3 : important					// 8 : Most Everything
		// 4 : lite							// 9 : Everything

//	The following areas <A> are defined:
		// app	-- APPlication		- construction of app
//______// men	-- MENues 			- construction of menus
		// doc	-- DOCument			- construction of document
		// ser	-- SERilization		- serialization and desrialization of Part
//______// bld	-- BuiLD			- building of part
		// dat	-- sim DATa			- simulation data
		// eve	-- sim EVEnts		- simulation events
		// rve	-- ReViEw 			- review visual properties
		// rsi	-- ReSIze 			- reSize shapes
		// rnd	-- ReNDer protocol	-
		// ani	-- phys ANImation	- physical animation events
		// ins	-- INSpectors		-
		// tst	-- TeSTing
		// all	-- ALL OF ABOVE		-

//	E.g: the following will print "construction message" if DOClog.verbosity
//	calls for >=3 verbosity messages:
//			atApp(3, Log(<construction message>))

 // Functions called by logee, sugar to shorten commonly used cliche.
func atApp(_ pri:Int, _ act:@autoclosure()->Void) { return at("app",pri,act())	}
func atDoc(_ pri:Int, _ act:@autoclosure()->Void) { return at("doc",pri,act())	}
func atBld(_ pri:Int, _ act:@autoclosure()->Void) { return at("bld",pri,act())	}
func atSer(_ pri:Int, _ act:@autoclosure()->Void) { return at("ser",pri,act())	}
func atAni(_ pri:Int, _ act:@autoclosure()->Void) { return at("ani",pri,act())	}
func atDat(_ pri:Int, _ act:@autoclosure()->Void) { return at("dat",pri,act())	}
func atEve(_ pri:Int, _ act:@autoclosure()->Void) { return at("eve",pri,act())	}
func atIns(_ pri:Int, _ act:@autoclosure()->Void) { return at("ins",pri,act())	}
func atMen(_ pri:Int, _ act:@autoclosure()->Void) { return at("men",pri,act())	}
func atRve(_ pri:Int, _ act:@autoclosure()->Void) { return at("rve",pri,act())	}
func atRsi(_ pri:Int, _ act:@autoclosure()->Void) { return at("rsi",pri,act())	}
func atRnd(_ pri:Int, _ act:@autoclosure()->Void) { return at("rsi",pri,act())	}
func atTst(_ pri:Int, _ act:@autoclosure()->Void) { return at("tst",pri,act())	}
func atAny(_ pri:Int, _ act:@autoclosure()->Void) { return at("all",pri,act())	}	// may be buggy

  /// Functions called by loggee, long form
 /// if a message closure shows an importance over in any category
/// Categories should roughly
func at(app:Int?=nil, doc:Int?=nil, bld:Int?=nil, ser:Int?=nil,
		ani:Int?=nil, dat:Int?=nil, eve:Int?=nil, ins:Int?=nil,
		men:Int?=nil, rve:Int?=nil, rnd:Int?=nil, tst:Int?=nil, all:Int?=nil,
		_ action:@autoclosure() -> Void)
	{
	if 		app != nil {		at("app", app!, action()) 						}
	else if doc != nil {		at("doc", doc!, action()) 						}
	else if bld != nil {		at("bld", bld!, action()) 						}
	else if ser != nil {		at("ser", ser!, action()) 						}
	else if ani != nil {		at("ani", ani!, action()) 						}
	else if dat != nil {		at("dat", dat!, action()) 						}
	else if eve != nil {		at("eve", eve!, action()) 						}
	else if ins != nil {		at("ins", ins!, action()) 						}
	else if men != nil {		at("men", men!, action()) 						}
	else if rve != nil {		at("rve", rve!, action()) 						}
	else if rnd != nil {		at("rnd", rnd!, action()) 						}
	else if tst != nil {		at("tst", tst!, action()) 						}
	else if all != nil {		at("all", all!, action()) 						}
}

 /// Common Filter routine:
/// * Executes the closure if the priority in DOClog.filter[area] >= verbosity
/// - parameters:
///   - area: 	= the kind of message, where the message is from.
///   - verbosity:	= the priority of the message, how important 0<msgPri<10
///   - action: = an automatically generated closure which does a (log) operation
func at(_ area:String, _ verbos:Int, _ action:@autoclosure() -> Void) {	// Location supplied
	assert(verbos >= 0 && verbos < 10, "Message priorities must be in range 0...9")
	if let log					= DOCfwGutsQ?.log ?? APPQ?.log,
	   let verbosity			= log.verbosity
	{	if trueF 								|| // DEBUGGING ALL messages
		  (verbosity[area]  ?? -1) >= verbos	|| // verbosity[area]  high enough	OR
		  (verbosity["all"] ?? -1) >= verbos	   // verbosity["all"] high enough
		{
			if log.msgFilter != nil || log.msgPriority != nil {
				let c			= "<>X<>X<>X<>X<>X<>X<> PROBLEM "
				let new			= Log.pp(filter:area, priority:verbos)
				let now			= Log.pp(filter:log.msgFilter, priority:log.msgPriority)		//(log.msgFilter ?? "flt") + (log.msgPriority == nil ? "-" : String(log.msgPriority!))
				print(c + " '\(new)' found log '\(log.title)' busy doing '\(now)'")
			}
			log.msgFilter		= area
			log.msgPriority		= verbos
			action()							// Execute the action closure
			log.msgFilter		= nil
			log.msgPriority		= nil
		}
	}
	else {										// always do if missing verbosity
//		print("logNil; ", terminator:"")
		print("!!: ", terminator:"")
		action()
	}
}


