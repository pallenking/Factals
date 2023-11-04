////  BundleTap.mm -- an Atom which generates data for a Bundle C2014PAK
//// 171004 -- removed TimingChain and SimpleWorlds.
//// 231101 -- transliterated from objc
//import SceneKit
////#import "GenAtom.h"
////#import "BundleTap.h"
////#import "Link.h"
////#import "Bundle.h"
////#import "Actor.h"
////#import "Leaf.h"
////#import "View.h"
////#import "Brain.h"
////#import "FactalWorkbench.h"
////#import "SimNsWc.h"
////#import "SimNsVc.h"
////
////#import "Common.h"
////#import <GLUT/glut.h>
////#import "GlCommon.h"
////#import "NSCommon.h"
////#import "Id+Info.h"
////#import "vmath.hpp"
////#import "Path.h"
//
//class BundleTap : Atom {
////- init; {						self = [super init];
////	return self;
////}
////- (void) dealloc {
////	self.resetTo			= nil;
////	self.inspectorNibName = nil;
////	self.targetBundle		= nil;
////
////    [super dealloc];
////}
////#pragma mark  3. Deep Access
////- (id) deepMutableCopy; {				id rv = [super deepMutableCopy];
////	panic(@"");
////	return rv;
////}
//
// // MARK: - 4. Factory
//- (id) atomsDefinedPorts;	{				id rv = [super atomsDefinedPorts];
//	
//	rv[@"S"]		= @"pc";	// Secondary					(always create)
//	return rv;
//}
//
//BundleTap *aBundleTap(id etc) {
//	BundleTap *newbie = anotherBasicPart([BundleTap class]);
//XX	newbie = [newbie build:etc];
//	return newbie;
//}
//BundleTap *aBundleTap(int limit, id etc) {
//	panic(@"Old style Generator -- DEPRICATED");
//	id info = @{@"eventLimit":[NSNumber numberWithInt:limit], etcEtc};
//
//	BundleTap *newbie = anotherBasicPart([BundleTap class]);
//XX	newbie = [newbie build:info];
//	return newbie;
//}
//
//- (id) build:(id)info;	{								[super build:info];
//
////! xzzy1 BundleTap::	1. resetTo				  :<event>	-- on reset
////!	xzzy1 BundleTap::	2. nib					  :<name of nib file>.nib
////!	xzzy1 BundleTap::	3. heightAlongRightSide :<float>
////!	xzzy1 BundleTap::	4. incrementalEvents	  :<bool>	-- values hold between events, must be explicitly cleared
//
//	assert(!self.parameters[@"events"], (@"BundleTap does not support events any more"));
////	assert(self.parameters[@"asyncData"], (@"BundleTap does not support setting syncData"));??
//
//	if (NSString *nibString		= [self takeParameter:@"nib"])
//		self.inspectorNibName	= nibString;
//
//	if (id resetTo 				= [self takeParameter:@"resetTo"])
//		self.resetTo			= resetTo;
//
//	if (NSNumber *num			= [self takeParameter:@"heightAlongRightSide"])
//	   self.heightAlongRightSide= [num floatValue];
//	else
//	   self.heightAlongRightSide= nan("unset");
//
//	if (id incrementalEvents 	= [self takeParameter:@"incrementalEvents"])
//		self.incrementalEvents	= [incrementalEvents intValue];
//
//	return self;
//}
//
//- (void) postBuild; {									[super postBuild];
////?	assert(self.targetBundle, (@"'%s'.targetBundle is nil, must be set", self.fullNameC));
//
//		/// Connect up our targetBundle:
//	   ///
//	 // my P-Port connects where?
//	Port *pPort 				= self.pPort;
//	assert([pPort.name isEqualToString:@"P"], (@"all bets off"));
//	
//	id targPort 				= pPort.portPastLinks;
//XX	self.targetBundle 			= coerceTo(Bundle, [targPort parent]);	//****
//	assert(self.targetBundle, (@"targetBundle is nil"));
//	
//	 // Test new target bundle; must have both R (for reset) and G (for generate)
//	[self.targetBundle forAllLeafs:^(Leaf *leaf) {			//##BLOCK
//		id r 					= [leaf port4leafBinding:@"R"];
//		id g 					= [leaf port4leafBinding:@"G"];
//		assert(r and g, (@"Leaf type '%@' has no R or G port, needed by\n"
//						 "%@: %@: %@\nConsider using Leaf with a BundleTap",
//						 leaf.type, self.pp, self.targetBundle.pp, leaf.pp));
//	}];
//}
//
//#pragma mark 7-. Simulation Actions
//- (void) reset; {								[super reset];
//	
//	  //// reset to an BundleTap generates a resetTo pattern to target bundle
//	 ///
//	self.anonValue = 1.0;				// first so resetTo = @"a" sets a=1
//	if (id resetTo = self.resetTo) {
//		[self logEvent:@"|| resetTo '%@'", [resetTo pp]];
//		[self loadHashEvent:resetTo];
//	}
//}
//- (void) resetForAgain; {
//	self.anonValue = 1.0;		// anonymous value restarts on "again"
//
//// 180123 added back in for Chevy 2
//// 171227 removed: "again" kept Previous from working
//XX	[self loadPreClear];
//}
//#pragma mark  8. Reenactment Simulator
//
// /// Load the next event to the target bundle:
//- (void) loadTargetBundle:event {
//	self.anonValue = 1.0;
//
//	  /// Event is a single number
//	 ///
//	if (NSNumber *e = coerceTo(NSNumber, event)) {
//
//		  /// Floating Point --> Random Events
//		 ///
//		if ([e respondsToSelector:@selector(floatValue)]) {
//			float prob = [e floatValue];
//			[self logEvent:@"|| Event '%@': RANDOMIZE targetBundle %@",
//										[event pp], self.targetBundle.fullName];
//			 // Put in random data
//			[self.targetBundle forAllLeafs:^(Leaf *leaf) {			//##BLOCK
//				Port *genPort			= mustBe(Port, [leaf port4leafBinding:@"G"]);
//				float value				= randomProb(prob);
//				genPort.valueTake		= value;
//			} ];
//		}
//
//		  /// Integer --> @0 Epoch Mark
//		 ///
//		else if (e.objCType[0]=='i' and e.intValue==0) // 'i' is integer
//			[self logEvent:@"|| Event '%@': Epoch Mark", [event pp]];
//
//		else
//			panic(@"|| Event '%@' ILLEGAL", [event pp]);
//	}
//	
//	  /// Event is an Array
//	 ///
//	else if (NSArray *eventArray = coerceTo(NSArray, event)) {
//		[self logEvent:@"|| Event '%@' LOADS targetBundle %@...",
//						 			[event pp], self.targetBundle.fullName];
//
//		  /// First element of an array sets the current anonymous value
//		 ///
//		if (id ea0 = eventArray.firstObject) {
//			if (coerceTo(NSNumber, ea0)) {
//				if ([ea0 respondsToSelector:@selector(floatValue)]) {
//					self.anonValue = [ea0 floatValue];
//					[self logEvent:@"|| Element 1 ='%@'; %f => anonValue", ea0, self.anonValue];
//				}
//			}
//		}
//		 /// Clear:
//		if (!self.incrementalEvents)
//XX			[self loadPreClear];
//		 /// Load:
//XX		if (id label = [self loadHashEvent:event])
//			self.targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
//
//		[self.brain kickstartSimulator];	// start simulator
//	}
//
//	  /// Event is an String
//	 ///
//	else if (NSString *eventStr = coerceTo(NSString, event)) {
//
//		/// ("incrementalEvents" is a reserved word amongst signal names)
//		if ([eventStr isEqualToString:@"incrementalEvents"]) {
//			[self logEvent:@"|| Event 'incrementalEvents' -- hold previous values"];
//			self.incrementalEvents = true;
//			return;
//		}
//
//		[self logEvent:@"|| Event '%@' to targetBundle %@",
//						 			[event pp], self.targetBundle.fullName];
//		if (!self.incrementalEvents)
//XX			[self loadPreClear];
//
//XX		if (id label = [self loadHashEvent:event])
//			self.targetBundle.label = label; // GUI: Labels in events are moved onto the bundle
//
//		[self.brain kickstartSimulator];	// start simulator
//	}
//
//	  /// Event is an NSInteger, etc. -- no effect on
//	 ///
//	else
//		[self logEvent:@"|| Event '%@': targetBundle %@ UNCHANGED",
//						 			[event pp], self.targetBundle.fullName];
//	return;
//}
//
//- (void) loadPreClear {
//
////	if (self.incrementalEvents) {
////		[self logEvent:@"|| .incrementalEvents ABORTS loadPreClear of '%@'", self.targetBundle.name];
////		return;
////	}
//
//	[self logEvent:@"|| loadPreClear: Clears all '%@'.G Ports:", self.targetBundle.name];
//
//	   /////// 2. CLEAR all Port value's inValue
//	  ///
//	[self.targetBundle forAllLeafs:^(Leaf *leaf) {					//##BLOCK
//		Port *genPort				= [leaf port4leafBinding:@"G"];
//		if (coerceTo(Port, genPort)) {
//			genPort.valueTake = 0.0;		// set value to 0
//// wild removal:
////			genPort.valuePrev = 0.01;		// set different
//		}
//		else if (NSNumber *genNumber = coerceTo(NSNumber, genPort))
//			assert([genNumber intValue]==0, (@"@0 is ignore, others not permitted"));
//		else
//			panic(@"Leaf '%@' has no \"G\" binding", [genPort name]);
//	} ];															//##BLOCK
//}
//
//  /// Load an event into the target bundle.
// /// The event may be a String, Number, or Array
///// Returns a label for display
//- (id) loadHashEvent:(id)event; {
//	id rv_label = @"";	// For any label that the event has for the bundle.
//						//  e.g: the name of the letter for Morse Code
//
//	   ////////////  EVENT STRING: A lone string acts as an array of 1 element
//	  ///
//	 // E.g: @"a"
////	id foo = [event asString];
//	if (NSString *eventStr = [event asString])
//XX		rv_label = [self loadOneBitFromString:event];
//
//	   ////////////  EVENT NUMBER: @0 means no signals: @n is illegal
//	  ///
//	 // E.g: @0
//	else if (NSNumber *eventNum = [event asNumber])
//		assert(eventNum.intValue==0, (@"@%d is illegal epoch", eventNum.intValue));
//		
//	   ////////////  EVENT ARRAY: process multiple signals inside
//	  ///
//	 // E.g: @[ ... ]
//	else if (NSArray *eventArray = mustBe(NSArray, event)) {
//		for (NSString *signal in eventArray)	  // go through all signals in event:
//XX			if (id ev_label=[self loadOneBitFromString:signal])
//				rv_label=[rv_label addF:@"%@", ev_label];  // catenate all event labels
//	}
//	else
//		panic(@"event '%s' malformed", [event ppC]);
//
//	return [rv_label length]? rv_label: nil;
//}
//
//- loadOneBitFromString:signal; {
//	if (coerceTo(NSNumber, signal))			// ignore defaultValues, ...
//		return nil;
//
//	if ([mustBe(NSString, signal) componentsSeparatedByString:@"/"].count > 1)
//		panic(@"Signal '%s' must not contain components (e.g. using '/')", [signal UTF8String]);
//	id labeled = nil;
//
//	 //////// Parse signal string. <name> = <valueSpec>
//	NSArray *comp = [signal componentsSeparatedByString:@"="];
//	float value = 1.0;
//	if (comp.count==2 and [comp[0] length]!=0) { // it is legal for names to start wit an "="
//		signal  = comp[0];
//		id eval = comp[1];
//		if (float v = [eval floatValue])
//			value = v;					/// fixed value e.g. "foo=0.7"
//		else if ([eval hasPrefix:@"rnd "]) {
//			float prob = [[eval substringFromIndex:4] floatValue];
//			value = randomProb(prob);	/// 1 with probability prob
//		}								///             e.g. "foo=rnd 0.3"
//		else if ([eval hasPrefix:@"rVal "]) {
//			float rVal = [[eval substringFromIndex:5] floatValue];
//			value = randomDist(0, rVal);/// Boxcar      e.g. "foo=rVal 4"
//		}
//		labeled = eval;			// signal has bundle lable, based on contents
//	}
//	else if (comp.count==1)				///				e.g. "foo"
//		if (!isNan(self.anonValue))	/// set to anonValue; allows clearing
//			value = self.anonValue;
//
//XX	Port *genPort			= [self.targetBundle genPortOfLeafNamed:signal];
//
//	[genPort logEvent:@"|| /\\/\\ '%@'.valueTake = %.2f was%.2f", genPort.name, value, genPort.valueGet];
//	genPort.valueTake		= value;
//
//	  // hack: If we are part of a GenAtom, load the S Port also.
//	 //        This allows initial values to be synced with .nib values
//	if (GenAtom *ga = coerceTo(GenAtom, self.parent))
//		ga.sPort.valueTake	= value;
//		
//	return labeled;
//}
//
//#pragma mark 9. 3D Support
//- (Bounds3f) gapAround:(View *)v;	{
//	float r = self.brain.bitRadius, f = 3.0;
//	return Bounds3f(-f*r, 0, -f*r,	 f*r, 3*r, f*r); // 160824
//}
//
// /// nibName33 --> automatically add an inspector pannel;
//// (might move into -postBuild
//- (View *) reViewIntoView:(View *)v; {					v = [super reViewIntoView:v];
//
//	if (self.inspectorNibName and !self.inspectorAlreadyOpen)
//		[self.brain.simNsWc.autoOpenInspectors addObject:mustBe(View, v)];
//	self.inspectorAlreadyOpen = true;		// only open once
//
//	return v;
//}
//#pragma mark 11. 3D Display
//- (void) drawFullView:(View *)v context:(RenderingContext *)rc; {
//
//	float r = self.brain.bitRadius;
//	Vector3f ctr = v.bounds.center();			// origin2center of BundleTap
//	Vector3f siz = v.bounds.size();
//
//	if (self.inspectorNibName) {
//		glPushMatrix();
//			glTranslatefv(ctr);				// Billboard
//			glScalef(siz.x, siz.y, 0.1);
//			FColor outside =  {0.55,0.0, 0.0,  1};
//			rc.color = outside;//colorRed3;	//colorWhite
//			glutSolidCube(self.brain.bitRadius);
//		glPopMatrix();
//	}
//	else {
//		glPushMatrix();
//			siz -= Vector3f(0.1, 0, 0.1);				// main body is inset
//			ctr.y += r/2;
//			glTranslatefv(ctr + Vector3f(0, -0.5,0));
//			rc.color = colorYellow;
//			glScalef(siz.x*0.8, 1, siz.z-r);
//			glutSolidCube(r);
//			rc.color = colorBlue;
//			glTranslatef(0, 0.5*r, 0);
//			glScalef(1.1, 0.5, 1.1);
//			glutSolidCube(r);
//		glPopMatrix();
//	}
//	[super drawFullView/*Ports*/:v context:rc];	// paint Ports and bounding box
//}
//
//#pragma mark 15. PrettyPrint
/////////////////////////// Strings for Printing  /////////////////////////
//- (NSString *) pp1line:aux; {		id rv=[super pp1line:aux];
//
//	if (self.resetTo)
//		rv=[rv addF:@"resetTo=%@ ", [self.resetTo pp]];
//
//	if (self.inspectorNibName)
//		rv=[rv addF:@"nibName33=%@ ", [self.inspectorNibName pp]];
//
//	rv=[rv addF:@"tBundle=%@ ", self.targetBundle.fullName];
//	return rv;
//}
//
//@end
