// Share.swift -- Maintains one channel of the plug protocol to a Splitter C2013PAK C2018PAK

import SceneKit
import SwiftUI

let sharesShortClassName = [
	"BroadcastSh"		: "BcstS",
	"MaxOrSh"			: "MxOrS",
	"MinAndSh"			: "MnAnS",
	"BayesSh"			: "BaysS",
	"HammingSh"			: "HammS",
	"MultiplySh"		: "MultS",
	"KNormSh"			: "KNrmS",
	"SequenceSh"		: "SequS",
	"BulbSh"			: "BulbS",
]
let pinSkin						= falseF		// shrink xz so insides can be seen

//protocol ShareX : Port {
//	//init(_:FwConfig)
//	//func reset()
//				 // ==== Initialize
//	func combinePre()							// INZ
//			//!<< combinePre >>: OPERATION
//			//! DEFAULT:	a1	=	0.0
//			//!	 MaxOr:		a1	=	-inf
//			//!	 MinAnd:	a1	=	+inf
//			//!	 Bayes:		a1	=	0.1
//			//!	 Multiply:	a1	=	1.0
//			//!	 Sequence:   ?
//	func combineNext(val:Float) -> Bool
//			//!<< combineNext >>: OPERATION		  RETURNS:
//			//!	DEFAULT:	a1   += con			false
//			//!	 MaxOr:		a1 max= con			==highest if con>0.01
//			//!	 MinAnd:	a1 min= con			==lowest
//			//!	 Hamming:	a1   += con-cut		false
//			//!	 Multiply:	a1   *= con			==lowest
//			//!	 KNorm		a1   += con**cp		false
//			//!	 Sequence:	  ---				false
//	func combinePost() 		/* Default: do nothing afterward */	//class
//
//	func bid() -> Float
//	func basicConSpot() -> ConSpot
//}

//##############################################################################
//##############################################################################
//################################## Share: ####################################
//##############################################################################
//##############################################################################
class Share : Port { // ///////////// The common parts//////////////////////////
	 // MARK: - 3. Part Factory
	override required init(_ config: FwConfig = [:]) {
		super.init(config) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
	 // MARK: - 3.5 Codable
	required init(from decoder: Decoder) throws { try super.init(from:decoder)	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
	 // MARK: - 8. Reenactment Simulator
	 //-- distribute: (local UP)--//
	func bid() -> Float {
		return self.con2?.port?.value ?? 0 	// Default: distribute proportionately according to want
	}
	//#########################################################################
	//##########################################################################

	 // MARK: - 9.0 3D Support
	//	A Share's con2 point is at its origin
	//	An upright Share opens up (connects to a Link/Port above)
	//	a Share may have no skins (Links have shares)
	//	A Share must connect to a Link
	override func basicConSpot() -> ConSpot {	// Ports default to this, shares override
		return ConSpot(radius:1)				// of prototypical share
	}

	  // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {	// Pyramid
		let scn : SCNNode		= vew.scnRoot.findScn(named:"s-Share") ?? { //(() -> SCNNode) in
			let s				= CGFloat(0.5)
			 // A plate:
			let scn 			= SCNNode(geometry:SCNBox(width:s, height:s/20, length:s, chamferRadius:0))// width:s, height:s, length:s))
//			let scnScene 		= SCNNode(geometry:SCNPyramid(width:s, height:s, length:s))
			scn.name			= "s-Share"	// (was a cone)
			scn.color0			= .black//.red
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(vew:Vew, first:Bool) {
		panic("I never get here!!")
		vew.scnRoot.transform		= SCNMatrix4(basicConSpot().center)	/// position at the portConSpot
	}
}

 // MARK: - SHARE SUBCLASSES -
//##############################################################################
class Broadcast : Splitter { //#################################################
	  // MARK: - 8. Reenactment Simulator
	 //-- distribute: (local UP)--//  // all distributions get the full total
	 //----------------------- draw: ----------------//
	var hBcast : CGFloat				{ 	return 2							}
	override func bidTotal() -> Float	{	return 1							} // Broadcast
	 // MARK: - 9.0 3D Support
	let height : CGFloat		= 1
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Broadcast") ?? {
			let scn  			= !pinSkin						// for debug
				? SCNNode(geometry:SCNHemisphere(radius:1, slice:0))
//				? SCNNode(geometry:SCNCylinder(radius:1, height:height))
				: SCNNode(geometry:SCNCone(topRadius:0.05, bottomRadius:0.01, height:height))	// for debug
			scn.color0			= .orange
			scn.name			= "s-Broadcast"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.scale 				= .unity * hBcast/2
		let bb					= vew.bBox
		scn.position			= bb.centerBottom //+ .uY * height/2
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class BroadcastSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func bid() -> Float	{	return 1								}
	override func basicConSpot() -> ConSpot {
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, 0*r, 0), radius:1*r)
	}
}

//##############################################################################
class MaxOr : Splitter {	//##################################################

	 // MARK: - 8. Reenactment Simulator
	 //-- combine: (local DOWN)--//
	override func combinePre() {
		a1						= -.infinity
	}
	override func combineNext(val:Float) -> Bool {
		a1 						= max(a1, val)

		let idle		= val < 0.01 && onlyPosativeWinners		//special idle mode when no substantial winner
				 // 160427 HACK: special mode: not active
				  // 161020 -- consider replacing with squelch
		let rv			= a1 == val && !idle	//  winner: if we are at max
		return rv
	}
	 // MARK: - 9.0 3D Support
	let pipeRadius : CGFloat	= 0.4 + 0.4
	let ringRadius : CGFloat	= 1.4 - 0.4
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Max") ?? {
			let scn				= SCNNode(geometry:SCNTorus(ringRadius:ringRadius, pipeRadius:pipeRadius))
			scn.name			= "s-Max"
			scn.color0			= .orange
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		let shrink :CGFloat		= 0.5//1.0//
		scn.scale 				= SCNVector3(1.0, shrink, 1.0)
		scn.position.y 			= pipeRadius * shrink
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
} //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class MaxOrSh : Share {	//#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, 0, 0), radius:1.5*r)	//
	}
}

//##############################################################################
class MinAnd : Splitter { //####################################################

	  // MARK: - 8. Reenactment Simulator
	 //-- combine: (local DOWN)--//
	override func combinePre() {
		a1 						= .infinity
	}
	override func combineNext(val:Float) -> Bool {	//class
		a1						= min(a1, val)
		return a1 == val
	}
	 // MARK: - 9.0 3D Support
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Min") ?? {
			let r : CGFloat		= 1//BroadcastSh.hBcast/2
			let scn				= SCNNode(geometry:SCNHemisphere(radius:r, slice:0))	//0.9*
			//let scnScene 			= SCNNode(geometry:SCNSphere(radius:r))	//
			scn.color0			= .orange
			scn.name			= "s-Min"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.scale				= SCNVector3(1, 1.6, 1)
		let bb					= vew.bBox
		scn.position			= bb.centerBottom
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class MinAndSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {	 // look at particular type of share:
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, -r/2, 0), radius:r)
//		return ConSpot(radius:0.5 * super.radius)	//, inset:0.5*r	// return plitterSkinSize(3*r,2*r,3*r,  0.5*r, 0.5*r)	//4*r,2*r,4*r
	}
}

//##############################################################################
class Bayes : Splitter	{  //***################################################

	 // MARK: - 8. Reenactment Simulator
	   // The upward sensation goes proportionately to the normalized downward desire
	  //   Acc1 is sum of downward vals...
	 //-- distribute: (local UP)--//
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Bayes") ?? {
			let scn				= SCNNode(geometry:SCNBox(width:3, height:3, length:3, chamferRadius:0.75))
			scn.color0			= .orange
			scn.name			= "s-Bayes"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.position.y			= 1.5
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class BayesSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {	 // look at particular type of share:
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, r, 0), radius:r)		// return SplitterSkinSize(2*r,2*r,2*r, r, r)
	}
}

//###################################################################################################
class Hamming : Splitter { //###################################################

	 // MARK: - 8. Reenactment Simulator
	let cut : Float 			= 0.9
	 //-- combine: (local DOWN)--//		// Combine:  (SUMi (Xi - cut)) + cut
	override func combineNext(val:Float) -> Bool {	 //class
		let delta				= val - cut
		a1			   			+= delta
		return false			// Never declare a winner all distributions are 100%
	}
	override func combinePost() {
		a1					+= 0.9
	}
	 //-- distribute: (local UP)--//  // all distributions get the full total
	override func bidTotal() -> Float	{	return 1							} // Hamming
	 // MARK: - 9.0 3D Support
	var height:CGFloat	{ 		return 2								} // override??
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Hamm") ?? {
			let scn  			= !pinSkin ? 
				SCNNode(geometry:SCNCone(topRadius:0, bottomRadius:1, height:height)) :			
				SCNNode(geometry:SCNCone(topRadius:0.15, bottomRadius:0.01, height:height))	// debug
			scn.name			= "s-Hamm"
			scn.position 		= SCNVector3(0, height/2, 0)
			scn.color0			= .orange
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class HammingSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func bid() -> Float	{		return 1							}
	override func basicConSpot() -> ConSpot {	 // look at particular type of share:
		let r					= radius
		return ConSpot(center:SCNVector3(0, -0.5*r, 0), radius:r)
	}
}

//##############################################################################
class Multiply : Splitter { //##################################################

	 // MARK: - 8. Reenactment Simulator
	 //-- combine: (local DOWN)--//
	override func combinePre() {
		a1						= 1.0
	}
	override func combineNext(val:Float) -> Bool {//class
		a1						*= val		// a1 is multiply (*=)
		return false 						// a2 == contrib
	}
	 //-- distribute: (local UP)--//
	let bidParam : Float 	= 3		//
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Mult") ?? {
			let s				= CGFloat(2.0)
			let scn				= SCNNode(geometry:SCNPyramid(width:s, height:s, length:s))
			scn.name			= "s-Mult"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.color0				= .orange
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class MultiplySh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {
		return ConSpot(radius:2*super.radius)		//, inset:2*r
	}
}

//##############################################################################
class KNorm : Splitter { //#####################################################
let kNormK : Float		 = 1.0	// build this out

	 // MARK: - 8. Reenactment Simulator
	 //-- combine: (local DOWN)--//
	override func combineNext(val:Float) -> Bool {			//class
		a1 						+= powf(val, kNormK)
		return false
	}
	override func combinePost() {
		a1 						= powf(a1, 1.0/kNormK)
	}
	 // MARK: - 9.0 3D Support
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-KNorm") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1.6))
			scn.color0			= .orange
			scn.name			= "s-KNorm"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.position.y			= 0.6
		scn.scale				= SCNVector3(1, 0.4, 1)
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class KNormSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {
		let r					= super.radius
		return ConSpot(radius:1.2*r)			//, inset:1.2 * r
	}
}

//##############################################################################
class Sequence : Splitter	{ //################################################

	 // MARK: - 8. Reenactment Simulator
	 // This presumes numbers are <1.0 for now
	override func combinePre() 					 {	/*print("debug me")*/			}
	override func combineNext(val:Float) -> Bool {	/*print("debug me")*/return false}
	 // MARK: - 9.0 3D Support
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn : SCNNode		= vew.scn.findScn(named:"s-Seq") ?? {
			let height 			= Double(parent?.children.count ?? 2) - 1.0
			let scn				= SCNNode(geometry:SCNCylinder(radius:1.0, height:height))
			scn.color0			= .orange
			scn.name			= "s-Seq"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.rotation			= SCNVector4(1,0,0, CGFloat.pi/2)
		scn.position.y			= 1
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class SequenceSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	  // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {	// Pyramid
		let scn : SCNNode		= vew.scnRoot.findScn(named:"s-SeqSh") ?? {
			let scn 			= SCNNode(geometry:SCNSphere(radius:0.25))
			scn.name			= "s-SeqSh"
			scn.color0			= .red
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
	override func basicConSpot() -> ConSpot {
		let r				= super.radius
		let ind				= parent?.children.firstIndex(where: {$0 === self}) ?? 0
		let nChildren 		= parent?.children.count ?? 0
		let foo				= Double(ind) - Double(nChildren)/2
		//return ConSpot(center:SCNVector3(0, SeqY, foo * r), radius:0)//2*r, foo * r))
		return   ConSpot(center:SCNVector3(0, -2*r, foo * r), radius:0)
	}
	override func simulate(up upLocal:Bool)
	{
		super.simulate(up:upLocal)
		let parent : Splitter 		= self.parent as! Splitter

	/* Splitter:								Events: A->a, B->b, ...H->h
			 .----------------> 1.up --v	->__aTTTb___________________________
			 | .--------------< 1.dn TASK1	<-______BTTTC_______________________
			 | |    .--------->	2.up --v	->__________cTTTd___________________
			 | |    | .-------<	2.dn TASK2	<-______________DTTTE_______________
			 | |    | |    .-->	3.up --v	->__________________eTTTf___________
			 | |    | |    | .<	3.dn TASK3	<-______________________FTTTG_______
			 | |    | |    | |
	=========^=v====^=v====^=v=== Splitter
	=        | |    | |    | |  =
	=        |1|    |2|    |3|  =
	=    A B | |C D | |E F | |  =		Shares S1, S2, and S3
	=   -. ,-|-+. ,-|-<. ,-|-<  =
	=  | /=\ |  /=\ |  /=\ | |  =				DETAIL: FLIP FLOP
	=  | S=R |  S=R |  S=R | |  =	(/S) Leading edge sets     (\R) Trailing edge resets
	=  | ==Q-'  ==Q-'  ==Q-' |  =						   /=\
	=  |					 |  =						   S=R
	=  |        G H          |  =						   ==Q
	=  +--------\=/----------'  =						        Q is output
	=  |        R=S             =
	=  |        ==Q             =
	=  | 		  |          	=
	=  |0.--------'			    =		Share 0
	=  | |						=
	===^=v=======================
	   | |
	   +----------------------< 0.up		<-__ATTTTTTTTTTTTTTTTTTTTTTTTTTTH___
	   | +--------------------> 0.dn		->__________________________gTTTh___
	   | |

	At time   At Share      We detect		and do    with
	Event:  Processed by:  inVar edge	 	action:   var:		Comment:

		A: in 1 going up	 0.up /  --->   set   / 1.up  :a	Primary Starts TASK1

		B: in 1 going down	 1.dn /  --->   clear \ 1.up  :b	TASK1 completion
		C: in 1 going down	 1.dn \  --->   set   / 2.up  :c	Share 1 Starts TASK2

		D: in 2 going down	 2.dn /  --->   clear \ 2.up  :d	TASK2 completion
		E: in 2 going down	 2.dn \  --->   set   / 3.up  :e	Share 2 Starts TASK3

		F: in 3 going down	 3.dn /  --->   clear \ 3.up  :f	TASK3 completion
		G: in 3 going down	 3.dn \  --->   set   / 0.dn  :g	declare our completion

		H: in 0 going down	 0.up \  --->   clear \ 0.up  :a	completion acknowledged
	Notes:		/ is rising edge   \ is falling edge
	 */
								
		 // Our share number in parent's children:
		let selfNo				= parent.children.firstIndex(where: {$0 === self})!// (of:self)!
		if upLocal, 			// ==== UP ====:
		  selfNo == 1, 				// First Share output (up) is set by primaryPort:
		  let pPort	= parent.ports["P"],	// Our primary port "P"'s parent:
		  let pPort2Port = pPort.con2?.port
		{
			let (value, valuePrev) = pPort2Port.getValues()
			if valuePrev<0.5 && value>=0.5 {	// RISING EDGE (Event A)
				take(value:1.0)						// START: / Share 1 output
			}
			if valuePrev>=0.5 && value<0.5 { 	// FALLING EDGE (Event H)
				pPort.take(value:0.0)				// set next port
			}
		}
		if !upLocal {			// ==== DOWN ====
			 // Output number for next Share
			let outNo 		= selfNo+1<parent.children.count ? selfNo+1 : 0
			let outPort		= parent.children[outNo] as! Port

			guard let inPort = self.con2?.port else {return}// self's down before
			let (value, valuePrev) = inPort.getValues()		// self's down now

			if valuePrev<0.5 && value>=0.5 {		// RISING EDGE (Events C,E)
				self.take(value:0.0)					// clears our output value
			}
			if valuePrev>=0.5 && value<0.5 {		// FALLING EDGE (Events B,D,F)
				outPort.take(value:1.0)					// sets the next port output
			}
		}
	}
}

//##############################################################################
@Observable				 //#####################################################
 class Bulb : Splitter {

	 // MARK: - 2. Object Variables:
	var pValue : Float			= 0.0
	 // Current Way:
	// Xyzzy18.1. Bulb.simulate(up) reads it's P input
	// Xyzzy18.2. Set bulbValue, If it is the different, mark tree as having dirty size

//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Bulb
//		theCopy.pValue 			= self.pValue
//		theCopy.gain 			= self.gain
//		theCopy.offset 			= self.offset
//		theCopy.currentRadius 	= self.currentRadius
//		logSer(3, "copy(with as? LinkPort       '\(fullName)'")
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					   else {	return true				}
		guard let rhs			= rhs as? Bulb else {	return false 			}
		let rv					= super.equalsFW(rhs)
								&& pValue 		 == rhs.pValue
								&& gain 		 == rhs.gain
								&& offset 		 == rhs.offset
								&& currentRadius == rhs.currentRadius
		return rv
	}
	 // MARK: - 8. Reenactment Simulator
	override func bidTotal() -> Float 		{	return 1						} // Bulb
	override func simulate(up upLocal:Bool) {
		super.simulate(up:upLocal)		// BUG: Breakpoint here doesn't work

		 // Bulbs size may change:
		if upLocal,
		  let pInput			= ports["P"]?.con2?.port?.getValue(),
		  pValue != pInput 			// Value changed?	//prev != total
		{
			logDat(3, "   BULB: %.2f (was %.2f)", pInput, pValue)
			pValue				= pInput	//	pass on 
			markTree(dirty:.size)			// mark Splitter's size as dirty
		}
	}	
	 /// Diameter and Radius are functions of value
	func diam(  ofValue value:Float) -> CGFloat	{	return CGFloat(max(gain * value + offset, 0.0))	}
	func radius(ofValue value:Float) -> CGFloat	{	return CGFloat(max(gain * value + offset, 0.0))	}
	var gain  : Float	= 5.0//2.0//0.1//
	{	didSet { if gain != oldValue {
				markTree(dirty:.size)
																		}	}	}
	var offset: Float	= 0.5
	{	didSet { if offset != oldValue {
				markTree(dirty:.size)
																		}	}	}
	var currentRadius : CGFloat = 0.0
//	{	didSet { if currentRadius != oldValue {
//				markTree(dirty:.size)
//																		}	}	}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.findScn(named:"s-Bulb") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1))
			scn.color0			= .orange
			scn.name			= "s-Bulb"
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		} ()
		let r					= radius(ofValue:pValue)
		currentRadius			= r
		scn.scale				= SCNVector3(r, r, r)		//0.01*
		scn.position.y			= max(r-0.2, 0)		// ensure sphere and Port overlap
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
	override func reSize(vew:Vew) {
		super.reSize(vew:vew) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv 					= super.pp(mode, aux)
		if mode == .line { 
			rv					+= ", r(\(currentRadius)) =v(\(pValue))*g(\(gain))+o(\(offset))"
		}
		return rv
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class BulbSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func bid() -> Float	{	return 1								}
	 /// Intercept Port.value, to perhaps set viewSizeIsDirty
	private var looparoundValue : Float = .nan
	override var value : Float 		{		// a place for debug breakpoints:
		get		{	return true ? looparoundValue : super.value	 				}
		set(v) 	{
			if super.value != v {

				 // A change in value -->  resize / rebound  event
				parent?.markTree(dirty:.size)

				super.value 	= v
			}
			looparoundValue 	= v
		}
	}
	override func basicConSpot() -> ConSpot {
		let b					= atom as? Bulb
		let v					= b!.pValue
		let (r, d)				= (b!.radius(ofValue:v), b!.diam(ofValue:v))
		return ConSpot(center:SCNVector3(0, d/2, 0), radius:r)
	}
}//#########################################################################



