//
//  Branch.swift
//  Factals
//
//  Created by Allen King on 2/21/25.
//

import SceneKit

//#pragma mark  4a Factory Access						// Methods defined by Factory
var atomsDefinedPorts:[String:String]	= [ //				id rv = [super atomsDefinedPorts];
//	 /// upper (splitter) half: Has P U
	 // Just as a reminder:
	//"P" 	: "pcd", 	// Bottom of upper half, connects to L <-.
	//"U" 	: "p  ",	// Unknown sensation
//	 /// bottom half:												 |
	"S"		: "pcd",	// Lowest Port in Branch 170202
	"L"		: "pc ",	// Top of bottom half, connects to P <---'
	"M"		: "p d",	// Modulator, enables
	"SPEAK"	: "p, d",	// Chooses shareProto[0,1]
	]


class Branch : Splitter {
	var speak		: Bool 		= false			// or 0->listen
	var noMInSpeak	: Bool 		= false
	var lPreLatch	: Float 	= 0.0
	
	init() {														super.init()
	}
	
	required init?(coder: NSCoder) {	fatalError("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {	fatalError("init(from:) has not been implemented") }
	
//    func deepMutableCopy() -> Branch {
//        let rv 				= super.deepMutableCopy() as! Branch
//        rv.speak 				= self.speak
//        rv.noMInSpeak 		= self.noMInSpeak
//        rv.lPreLatch 			= self.lPreLatch
//        return rv
//    }
								//
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()
		rv["S"] 				= "pcd"
		rv["L"] 				= "pc "
		rv["M"] 				= "p d"
		rv["SPEAK"] 			= "p d"
		return rv
	}
	 // atomsPortAccessors(sPort,	S,	 true)
	var     sPort   : Port! { getPort(named:"sPort", localUp:true, wantOpen:false, allowDuplicates:false) }
	var     sPortIn : Port! { sPort.con2?.port									}
	 // atomsPortAccessors(lPort,	L,	 false)
	var     lPort   : Port! { getPort(named:"lPort", localUp:false, wantOpen:false, allowDuplicates:false) }
	var     lPortIn : Port! { lPort.con2?.port 									}
	 // atomsPortAccessors(mPort,	M,	 true)
	var     mPort   : Port! { getPort(named:"mPort", localUp:true, wantOpen:false, allowDuplicates:false) }
	var     mPortIn : Port! { mPort.con2?.port 									}
	 // atomsPortAccessors(speakPort,SPEAK,true)
	var speakPort   : Port! { getPort(named:"speakPort", localUp:true, wantOpen:false, allowDuplicates:false) }
	var speakPortIn : Port! { speakPort.con2?.port 								}

	override init(_ config:FwConfig = [:]) {
		let config1 			= ["P":".L=", "bandColor":".L"] + config
		super.init(config1)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		if let speak 			= partConfig["SPEAK"]?.asPart as? Port {
			self.speak 			= speak.value == 0
		}
		if let noMInSpeak 		= partConfig["noMInSpeak"] as? Bool {
			self.noMInSpeak 	= noMInSpeak
		}
//		self.parameters["addPreviousClock"] = 1
	}
	override func sendMessage(fwType:FwType) {
bug;	logEve(4, "||      all parts: sendMessage(\(fwType)).")
		let fwEvent 			= HnwEvent(fwType:fwType)
		return receiveMessage(fwEvent:fwEvent)
	}
	 /// Recieve message and broadcast to all children
	override func receiveMessage(fwEvent:HnwEvent) {
		if fwEvent.fwType == .clockPrevious {
			logEve(4,"$$$$$$$$ << clockPrevious >>")
			clockPrevious()
		}
	}
	
	func clockPrevious() {
		logEve(4, "|| $$ clockPrevious to Branch: L=\(lPreLatch) (was \(lPort?.value ?? -1))")
		lPort!.take(value:lPreLatch)
	}
	
	override func simulate(up upLocal:Bool) {
		let sInPort 			= sPort.con2!.port ?? sPort
		//let mInPort 			= mPort.con2!.port ?? mPort
		let lInPort 			= lPort.con2!.port ?? lPort
		let speakInPort 		= speakPort.con2!.port ?? speakPort
		
		if speakInPort?.valueChanged() ?? false {
			let valPrev 		= speakInPort!.valuePrev
			let valNext 		= speakInPort!.value
			logEve(4, "Branch: speak=\(valNext) (was \(valPrev))")
bug//		self.speak = Int(valNext)
		}

		if !self.speak {
			if upLocal { //!downLocal {
				if sInPort!.valueChanged() {
					logEve(4, "Branch: S->lPre =(was)")
					logEve(4, "Branch: S->lPre =\(sInPort!.value) (was \(lPreLatch))")
					lPreLatch 	= sInPort!.value
				}
				super.simulate(up:upLocal)
			} else {
				super.simulate(up:upLocal)
				if lInPort?.valueChanged() ?? false {
					let valPrev = lInPort!.valuePrev
					let valNext = lInPort!.value
					if let mPort = self.mPort {
						logEve(4, "Branch: L->M=\(valNext) (was \(valPrev))")
						mPort.take(value:valNext)
					} else {
						logEve(4, "Branch: L->S=\(valNext) (was \(valPrev))")
						sPort.take(value:valNext)
					}
				}
			}
		}
	}
	
//	override func pp1line(aux: Any?) -> String {
//		var rv = super.pp1line(aux: aux)
//		rv += " speak=\(speak) lPrev=\(lPreLatch) "
//		if noMInSpeak {
//			rv += "noMInSpeak "
//		}
//		return rv
//	}
}

let discThickness: Float = 0.5
let discDiameter: Float = 3.5

////
////  Branch.m
////  Factals
////
////  Created by Allen King on 2/21/25.
////
//
//
////  Branch.mm -- an outshoot from a crux, somehow enabled 2016PAK
//
//#import "Branch.h"
//#import "Bundle.h"
//#import "View.h"
//#import "Port.h"
//#import "Share.h"
//#import "WriteHead.h"
//#import "Actor.h"
//#import "FactalWorkbench.h"
//
//#import "NSCommon.h"
//#import "common.h"
//#import "Id+Info.h"
//#import "GlCommon.h"
//#import <GLUT/glut.h>
//#import "Colors.h"
//#import "Path.h"
//
//@implementation Branch
//
//- (id) init; {								self = [super init];
//
//	self.speak		= 0;
//	return self;
//}
//
//#pragma mark  3. Deep Access
//- (id) deepMutableCopy; {		Branch *rv = [super deepMutableCopy];
//
//	rv.speak						= self.speak;
//	rv.noMInSpeak					= self.noMInSpeak;
//	rv.lPreLatch					= self.lPreLatch;
//	return rv;
//}
//
								//#pragma mark  4a Factory Access						// Methods defined by Factory
								//- (id) atomsDefinedPorts;	{				id rv = [super atomsDefinedPorts];
								//											// probably returns P sec U B kind
								//	  /// upper (splitter) half: Has P U
								//	 // Just as a reminder:
								//	//rv[@"P"]		= @"pcd";	// Bottom of upper half, connects to L <-.
								//	//rv[@"U"]		= @"p  ";	// Unknown sensation
								//	 /// bottom half:												 |
								//	rv[@"S"]		= @"pcd";	// Lowest Port in Branch 170202
								//	rv[@"L"]		= @"pc ";	// Top of bottom half, connects to P <---'
								//	rv[@"M"]		= @"p d";	// Modulator, enables
								//	rv[@"SPEAK"]	= @"p d";	// Chooses shareProto[0,1]
								//	return rv;
								//}
//atomsPortAccessors(sPort,		S,		true)
//atomsPortAccessors(lPort,		L,		false)
//atomsPortAccessors(mPort,		M,		true)
//atomsPortAccessors(speakPort,	SPEAK,	true)
//
//#pragma mark 4. Factory
//
//Branch *aBranch(id etc) {
//	 // stuff that's the same in all Branches:
//	id info = @{@"P":@".L=",			// Connect bottom half to top
//				@"bandColor":@".L",		// Monitor "L" port
//				etcEtc}.anotherMutable;
//
//	Branch *newbie = anotherBasicPart([Branch class]);
//XX	newbie = [newbie build:info];
//	return newbie;
//}
//
//- (NSString *) classCommonName6	{
//	return [@"" addN:6 F:@"Br<%@", [self.shareClass className]];
//}
//
//- (id) build:(id)info;	{					[super build:info];
//
////! xzzy1 Branch::		1. speak			:<bool>
////! xzzy1 Branch::		1. noMInSpeak		:<bool>		// M port is dormant.
////xx xzzy1 Branch::		1. lVal				:<float>	// initial L value
//
//	if (id speak = [self parameterInherited:@"SPEAK"])
//		if (coerceTo(Port, speak)) // might be a SPEAK Port, handled elsewhere
//			self.speak = [speak intValue];
//
//	if (bool noMInSpeak = [self parameterInherited:@"noMInSpeak"])
//		self.noMInSpeak = noMInSpeak;
//
//	self.parameters[@"addPreviousClock"] = @1;		// so the Latch in Branch works
//	return self;
//}
//
///////
//
//id dida2char = @{
//	@"ia"  :@"A",		@"aiii":@"B",		@"aiai":@"C",		@"aii" :@"D",
//	@"i"   :@"E",		@"iiai":@"F",		@"aai" :@"G",		@"iiii":@"H",
//	@"ii"  :@"I",		@"iaaa":@"J",		@"aia" :@"K",		@"iaii":@"L",
//	@"aa"  :@"M",		@"ai"  :@"N",		@"aaa" :@"O",		@"iaai":@"P",
//	@"aaia":@"Q",		@"iai" :@"R",		@"iii" :@"S",		@"a"   :@"T",
//	@"iia" :@"U",		@"iiia":@"V",		@"iaa" :@"W",		@"aiia":@"X",
//	@"aiaa":@"Y",		@"aaii":@"Z",										};
//
//      // Name: <charName> <didaString> <terminal>
//     // <charName>	= a capatilized letter A..Z or "base" for no character (starting value)
//    // <didaString>	= the sequence with "i" being d_i, and "a" being d_a.
//   // <terminal>	= "$" if terminal (in context), "" if in tree but not leaf
//  // e.g <nil>="_$" E="E." I="I,," S="S,,," V="V,,,_" V$="V,,,_$"
// //
//NSString *nextMorseName(NSString *predName, Part *crux) {
//
//	  /// Name new element as Worker crux catenated with last char in, if possible
//	 ///
//	NSArray *predComps = [predName componentsSeparatedByString:@"/"];
//	int n=(int)predComps.count, i;
//	for (i=n-1; i>=0; i--)
//		if ([predComps[i] hasPrefix:@"d_"])			// find the symbol (i, a, or t)
//			break;
//	assert(i>0, (@"d_* not found, or first in path!!"));
//
//	id predComp = [predComps[i] substringFromIndex:2];		// an "i", "a", or "t"
//	id newMorseName = @"";									/// initial name
//	if (crux != nil) {
//		id charName		= nil;
//		id didas		= @"";
//		if (![crux.name isEqualToString:@"base"])
//			didas		= [crux.name substringFromIndex:1];	// didas come after the name
//
//		if (![predComp isEqualToString:@"t"]) {			/// a 'i' or 'a'
//	XR		newMorseName= [didas addF:@"%@", predComp];		// e.g. "ia"
//			charName	= dida2char[newMorseName]?:@"_";	// e.g. "A" or "_"
//		}
//		else {											/// a 't'
//	XR		newMorseName= [didas addF:@"$"];				// e.g. "ia>"
//			charName	= dida2char[didas]?:@"_";			// e.g. "A" or "_"
//		 }
//		newMorseName = [charName addF:@"%@", newMorseName]; // 'A[ia'
//	}
//	assert(newMorseName, (@"found nil new name to follow %@", predName));
//	return newMorseName;
//}
//
//#pragma mark 7. Simulator Messages
//- (id) receiveMessage:(FwEvent *)event; {
//
//	if (event->fwType == sim_clockPrevious) {
//		[self logEvent:@"$$$$$$$$ << clockPrevious >>"];
//
//		[self clockPrevious]; /// Branch got -receiveMessage; send customers
//	}
//	return nil;			 // do not call super needed
//}						// because the Previous manages everything inside itself.
//
//- (void) clockPrevious; {
//	[self logEvent:@"|| $$ clockPrevious to Branch: L=%.2f (was %.2f)", self.lPreLatch, self.lPort.value];
//	self.lPort.valueTake = self.lPreLatch;
//}
//
//+ (Part *) conceiveBabyIn:(WriteHead *)wh evi:evi con:con; {
//
//	  ///// Find the spot, and sprout predicate of the new branch
//	 ///
//	Atom *sproutSBase		= nil;	// sprout from here
//	Atom *sproutMPredicate	= nil;	// use this predicate
//	for (Atom *known2BUnknown in mustBe(NSArray,    evi   )) {
//
//		 // It's a predicate if in actor's evidence bundle
//		if ([known2BUnknown hasAsAncestor:wh.actor.evi]){ // in ?
//			assert(sproutMPredicate==nil, (@"Multiple sprout predicates detected:%@ and %@", sproutMPredicate.fullName, known2BUnknown.fullName));
//			sproutMPredicate = known2BUnknown;
//		}
//		else {	// the spot to sprout from
//			assert(sproutSBase==nil, (@"Multiple sprout spots detected:%@ and %@", sproutSBase.fullName, known2BUnknown.fullName));
//			sproutSBase		= known2BUnknown;
//		}
//	}
//
//	  ///// ADD a baby, presuming Morse Code
//	 //
//	Branch *baby=nil;
//	Part *babysParent=wh.actor;
//	if (sproutSBase and sproutMPredicate) {
//		[sproutSBase logEvent:@"Branch: add newborn -> S:%@, M@:%@", pp(sproutSBase), pp(sproutMPredicate)];
//
//		 ////// NOT TERMINAL: It's a "d_i" or "d_a": add in Actor
//		if (![sproutMPredicate.parent.name isEqualToString:@"d_t"])
//			baby = aBranch(@{@"Share":@[@"MaxOr", @"MaxOr"], @"SPEAK@":@"speak", @"KIND@":@"speak",
//							 @"S":sproutSBase,
//							 @"M":sproutMPredicate,
//							 @"U":@"write@"});			// Unknown cause subsequent sprout
//
//		else {	////// TERMINAL:	 It's a "d_t":			add in context Bundle
//
//			baby = aBranchLeaf(@{
//							@"Share":@"Bulb",
//							@"SPEAK@":@"speak",
//							@"S":sproutSBase,
//							@"M@":sproutMPredicate,
//							@"noMInSpeak":@1,			// do not say a final d_t
//							});
//			Actor *a			= wh.actor;	// WriteHead has outter actor 'a'
//			babysParent			= a.con;	// baby goes here (unless inner actor)
//
//			// If context is Actor
//			if (Actor *actr		= coerceTo(Actor, babysParent))
//				babysParent		= actr.evi;		// parent is it's evi bundle
//			a.positionViaCon	= 0;		// Convert my actor to not position upward to .con
//		}									// (this is an expediently simple place to do it)
//
//		// Insert baby in its parent:
//		wh.baby = baby;
//		baby.name = nextMorseName(sproutMPredicate.fullName, sproutSBase);
//		[babysParent addPart:baby];
//	}
//	else		// can't use logEvent -- no Part!
//		[wh logEvent:@" ABORT Branch Sprouting!  (spot=%@, predicate=%@)",
//		  					sproutSBase.fullName, sproutMPredicate.fullName];
//
//	return baby;
//}
//
//#pragma mark 8. Reenactment Simulator
//
//- (void) simulateDown:(bool)downLocal; {
//
//	Port *sPort		= self.sPort,		*sInPort	= sPort.connectedTo;
//	Port *mPort		= self.mPort,		*mInPort	= mPort.connectedTo;
//	Port *lPort		= self.lPort,		*lInPort	= lPort.connectedTo;
//	Port *speakPort	= self.speakPort,	*speakInPort= speakPort.connectedTo;
//
////	if (speakInPort)
////		self.speak = speakInPort.valueGet;
//	if (speakInPort.valueChanged) {			// "speak" Port --> speak @property
//		float valPrev	= speakInPort.valuePrev;
//		float valNext	= speakInPort.valueGet;		// ( get new value; remove )
//		[self logEvent:@" Branch: speak=%.2f (was %.2f)", valNext, valPrev];
//		self.speak		= valNext;
//	}
//
//	if (!self.speak) {		// L I S T E N
//		if (!downLocal) {					//============: going UP
//			if (sInPort.valueChanged) {			/// S --> latch
//				[self logEvent:@"Branch: S->lPre =%.2f (was %.2f)", sInPort.value, self.lPreLatch];
//				self.lPreLatch = sInPort.valueGet;	//####### from S port (clear changed bit
//			}
//			 // Perform Splitter function last:
//			[super simulateDown:downLocal];
//		}
//
//		else {								//============: going DOWN
//			 // Perform Splitter function first
//			[super simulateDown:downLocal];
//
//			if (lInPort.valueChanged) {			/// L --> M or S
//				float valPrev = lInPort.valuePrev;	// L.in prev
//				float valNext = lInPort.valueGet;	// ( get new value; remove )
//				if (mPort) {					/// L -> M
//					[self logEvent:@"Branch: L->M=%.2fwas %.2f)", valNext, valPrev];
//					mPort.valueTake = valNext;		//####### to M Port
//				}								/// if no M: (e.g. base)
//				else {							///   L -> S
//					[self logEvent:@"Branch: L->S=%.2fwas %.2f)", valNext, valPrev];
//					sPort.valueTake = valNext;		//####### to S Port
//				}
//			}
//			if (mInPort.valueChanged) {			/// M --> S (if M)
//				float valPrev = mInPort.valuePrev;	// L.in prev
//				float valNext = mInPort.valueGet;	// ( get new value; remove )
//				[self logEvent:@"Branch: M->S=%.2fwas %.2f)", valNext, valPrev];
//				sPort.valueTake = valNext;			//####### to S Port
//			}
//
////			  // 160916 Note: The downward S Latch must maintain a slight
////			 // keepalive signal, so the Branch below's Maxor will see it
//			float keepalive = 0.01;
////#warning fix keepalive
////			if (sPort.value < keepalive)
////				sPort.value = keepalive;
////			sPort.valueTake = max(sPort.value, keepalive);
//		}
//	}
//	else {					// S P E A K
//		if (downLocal) {					//============: going DOWN
//			 // Perform Splitter function first:
//			[super simulateDown:downLocal];
//
//			if (lInPort.valueChanged) {			/// L --> S
//				float valPrev = lInPort.valuePrev;		// L.in prev
//				float valNext = lInPort.valueGet;		// ( get new value; remove )
//				[self logEvent:@" Branch: L->S S=%.2fwas %.2f) Event /A or \E",
//                                                    valNext, sInPort.valuePrev];
//				sPort.valueTake = valNext;				//####### to S Port
//			}
//		}
//		else {								//============: going UP
//			sInPort = sInPort?: sPort;              // (if S is unconnected, read from it (loop))
//			if (sInPort.valueChanged) {
//				float sValuePrev	= sInPort.valuePrev;// S.in prev
//				float sValueNext	= sInPort.valueGet;	// ( get new value; remove )
//				assert(!isNan(sValuePrev) and !isNan(sValueNext), (@""));
//
//				if (mPort and !self.noMInSpeak) {/// S --> M (if present)
//					if (sValuePrev<0.5 and sValueNext>=0.5){// RISING/  EDGE of S.in (Event B)
//						[self logEvent:@" Branch: S.in (%.2fwas %.2f) RISES "
//                                "Event B: 1->M.out", sValueNext, sValueNext/*mInPort.value*/];
//						mPort.value = 1.0;				//####### 1->M.out (silently)
//					}
//					if (sValuePrev>=0.5 and sValueNext<0.5){// FALLING\\ EDGE of S.in (Event F)
//						[self logEvent:@" Branch: S.in (%.2fwas %.2f) FALLS "
//                                "Event F: 0->L.lPre", sValueNext, sValueNext/*mInPort.value*/];
//						self.lPreLatch	= 0.0;			//####### 0->lPre
//					}
//				}
//				else
//					self.lPreLatch	= sValueNext;		//####### S.in --> lPre
//			}
//			if (mInPort.valueChanged) {			/// M --> L
//				float mValuePrev	= mInPort.valuePrev;// M.in prev
//				float mValueNext	= mInPort.valueGet;	// ( get new value; remove );
//				assert(!isNan(mValuePrev) and !isNan(mValueNext), (@""));
//				assert(mPort, (@"mPort assumed for now"));
//
//				if (mValuePrev<0.5 and mValueNext>=0.5){ // RISING/  EDGE of M.in (Event C)
//					[self logEvent:@" Branch: M.in (%.2fwas %.2f) RISES "
//                                "Event C: 0->M.out", mValueNext, mValuePrev];
//					mPort.value = 0.0;					//####### 0->M.out
//				}
//				else if (mValuePrev>=0.5 and mValueNext<0.5){// FALLING\ EDGE of M.in (Event D)
//					[self logEvent:@" Branch: M.in (%.2fwas %.2f) FALLS "
//                                "Event D: 1->L.lPre", mValueNext, mValuePrev/*, mInPort.value*/];
//					self.lPreLatch	= 1.0;				//####### 1->L.lPre
//				}
//				else
//					[self logEvent:@" Branch: M.in: NO EDGE (%.2fwas %.2f)",
//                                mValueNext, mValuePrev];
//			}
//
//			 // 170407: Speak operates asynchronously, no l latch.
//			self.lPort.valueTake = self.lPreLatch;
//
//			 // Perform Splitter function last
//			[super simulateDown:downLocal];
//		}
//	}
//}
//
//#pragma mark 9. 3D Support
//
//float branchWidth		= 2.0;	// was 1
//float branchHeight		= 4.0;				// height of branch?
// // a disc is the major body feature of the Branch:
//float discThickness		= 0.5;
//float discDiameter		= 3.5;
//
//- (Matrix4f) positionOfPort:(Port *)port inView:(View *)bitV; {
//	Bounds3f splitterP	= [self gapAround:bitV];
//	Vector3f bitSpot	= splitterP.centerYBottom();
//
//	if ([port.name isEqualToString:@"P"]) {
//		assert(port.flipped, (@"'P' should be flipped"));
//		bitSpot.y	   += branchHeight - 1.5;
//		return [port suggestedPositionOfSpot:bitSpot];
//	}
//
//	if ([port.name isEqualToString:@"S"]) {
//		assert(port.flipped, (@"'S' should be flipped"));
//		bitSpot.y	   += 0;					// at bottom
//		return [port suggestedPositionOfSpot:bitSpot];
//	}
//
//	if ([port.name isEqualToString:@"L"]) {
//		assert(!port.flipped, (@"'L' shouldn't be flipped"));
//		bitSpot.y	   += 2.;					//branchBottom-2;
//		return [port suggestedPositionOfSpot:bitSpot];
//	}
//
//	if ([port.name isEqualToString:@"M"]) {
//		assert(port.flipped, (@"'M' should be flipped"));
//		bitSpot.y	   += 1.0;
//		bitSpot.z	   -= 2.0;
//		port.spin		= 3;
//		port.latitude	= 3;		// was 4
//		return [port suggestedPositionOfSpot:bitSpot];
//	}
//
//	if ([port.name isEqualToString:@"SPEAK"]) {
//		assert(port.flipped, (@"'SPEAK' should be flipped"));
//		bitSpot.y	   += 1.0;
//		bitSpot.x	   -= 2.0;
//		port.spin		= 2;
//		port.latitude	= 3;
//		return [port suggestedPositionOfSpot:bitSpot];
//	}
//
//XR	return [super positionOfPort:port inView:bitV];
//}
//- (Bounds3f) gapAround:(View *)v; {
//	SplitterSkinSize sss = [self.shareClass splitterSkinSizeIn:self]; // to compute GAP AROUND
//	float w				= max(sss.width/2,  branchWidth);
//	float d				= max(sss.deapth/2, branchWidth);
//	float h				=     sss.height  + branchHeight/2;
//	return Bounds3f(-w,	0, -d,
//					 w, h,  d);
//}
////- (Bounds3f) gapAround:(View *)v; {
////		return Bounds3f(  -branchWidth,			  0.0, -branchWidth,
////						   branchWidth,  branchHeight,  branchWidth);
////}
//
//#pragma mark 11. 3D Display
//
// // Draw FULL
//- (void) drawFullView:(View *)v context:(RenderingContext *)rc; {
//	float radius		= discDiameter;
//	float height		= discThickness;
//	rc.color			= colorBlue; // of name, and bandColor==nil
//
//	if (Port *bandPort = coerceTo(Port, self.bandColor)) {
//
//		if (bandPort.value > 0.5) {		// banded and ON (>0.5)
//			 // DISPLAY ON Branch BIGGER:
//			radius		+= 0;
//			height		+= 0;
//
//			// DISPLAY NAME of ON Branch:
//			glPushMatrix();
//				glTranslatefv(v.bounds.center());
//				Vector3f inCameraShift = Vector3f(0.5, 1.0, 0);
//				Vector2f spotPercent = Vector2f(0., 0.);
//				myGlDrawString(rc, self.name, -1, inCameraShift, spotPercent);
//			glPopMatrix();
//		}
//		rc.color		= bandPort.colorOfValue;	// band color from bandPort
//	}
//
//	 // Band around Branch reflects Port's value
//	glPushMatrix();				// Large cylinder of monitor color
//		glTranslatef(0, 2 + discThickness/2.0, 0);
//		glRotated(90, 1, 0, 0);
//		myGlSolidCylinder(radius, height, 16, 1);	// (radius, length, ...)
//	glPopMatrix();
//
//	[super drawFullView:v context:rc];
//}
//
//#pragma mark 15. PrettyPrint
//    ///\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\///
//   ///\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\///
//  ///\\//\\//\\//\\//\\//\\//\\// PRINTOUT //\\//\\//\\//\\//\\//\\//\\//\\///
// ///\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\///
/////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\///
//
//- (NSString *)	pp1line:aux; {		id rv=[super pp1line:aux];
//
//	rv=[rv addF:@"speak=%d lPrev=%.2f ", self.speak, self.lPreLatch];
//
//	if (self.noMInSpeak)
//		rv=[rv addF:@"noMInSpeak "];
//
//	return rv;
//}
//
//
//@end
