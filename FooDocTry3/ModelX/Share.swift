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
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
// Equatable??
	 // MARK: - 8. Reenactment Simulator
	 //-- distribute: (local UP)--//
	func bidOfShare() -> Float {
		return self.connectedTo!.value			// Default: distribute proportionately according to want
	}
	//#########################################################################
	//##########################################################################

	 // MARK: - 9.0 3D Support
	//	A Share's connection point is at its origin
	//	An upright Share opens up (connects to a Link/Port above)
	//	a Share may have no skins (Links have shares)
	//	A Share must connect to a Link
	override func basicConSpot() -> ConSpot {	// Ports default to this, shares override
		return ConSpot(radius:1)				// of prototypical share
	}

	  // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {	// Pyramid
		let scn : SCNNode		= vew.scn.find(name:"s-Share") ?? { //(() -> SCNNode) in
			let s				= CGFloat(0.5)
			 // A plate:
			let scn 			= SCNNode(geometry:SCNBox(width:s, height:s/20, length:s, chamferRadius:0))// width:s, height:s, length:s))
//			let scn 			= SCNNode(geometry:SCNPyramid(width:s, height:s, length:s))
			scn.name			= "s-Share"	// (was a cone)
			scn.color0			= .black//.red
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(vew:Vew) {
		panic("I never get here!!")
		vew.scn.transform		= SCNMatrix4(basicConSpot().center)	/// position at the portConSpot
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
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Bcast") ?? {
			let scn  			= !pinSkin ? SCNNode(geometry:SCNHemisphere(radius:1, slice:0))
				: SCNNode(geometry:SCNCone(topRadius:0.05, bottomRadius:0.01, height:2))	// for debug
			scn.color0			= .orange
			scn.name			= "s-Bcast"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.scale 				= .unity * hBcast/2
		let bb					= vew.bBox
		scn.position			= bb.centerBottom	// + .uY * gsnb/2
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class BroadcastSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func bidOfShare() 			  -> Float	{	return 1				}
	override func basicConSpot() -> ConSpot {
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, 0*r, 0), radius:1*r)
	}
}

//##############################################################################
class MaxOr : Splitter /*, ObservedObject<ObjectType: ObservableObject>*/ {	//##################################################

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
		let scn					= vew.scn.find(name:"s-Max") ?? {
			let scn				= SCNNode(geometry:SCNTorus(ringRadius:ringRadius, pipeRadius:pipeRadius))
			scn.name			= "s-Max"
			scn.color0			= .orange
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		let shrink :CGFloat		= 0.5//1.0//
		scn.scale 				= SCNVector3(1.0, shrink, 1.0)
		scn.position.y 			= pipeRadius * shrink
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
} //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class MaxOrSh : Share {	//#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, r/2, 0), radius:1*r)
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
		let scn					= vew.scn.find(name:"s-Min") ?? {
			let r : CGFloat		= 1//BroadcastSh.hBcast/2
			let scn				= SCNNode(geometry:SCNHemisphere(radius:r, slice:0))	//0.9*
			//let scn 			= SCNNode(geometry:SCNSphere(radius:r))	//
			scn.color0			= .orange
			scn.name			= "s-Min"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.scale				= SCNVector3(1, 1.6, 1)
		let bb					= vew.bBox
		scn.position			= bb.centerBottom
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class MinAndSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {	 // look at particular type of share:
		return ConSpot(radius:0.5 * super.radius)	//, inset:0.5*r	// return plitterSkinSize(3*r,2*r,3*r,  0.5*r, 0.5*r)	//4*r,2*r,4*r
	}
}

//##############################################################################
class Bayes : Splitter	{  //***################################################

	 // MARK: - 8. Reenactment Simulator
	   // The upward sensation goes proportionately to the normalized downward desire
	  //   Acc1 is sum of downward vals...
	 //-- distribute: (local UP)--//
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Bayes") ?? {
			let scn				= SCNNode(geometry:SCNBox(width:3, height:3, length:3, chamferRadius:0.75))
			scn.color0			= .orange
			scn.name			= "s-Bayes"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.position.y			= 1.5
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class BayesSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func basicConSpot() -> ConSpot {	 // look at particular type of share:
		let r					= super.radius
		return ConSpot(center:SCNVector3(0, r, 0), radius:r)		// return SplitterSkinSize(2*r,2*r,2*r, r, r)
	}
}

//##############################################################################
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
		let scn					= vew.scn.find(name:"s-Hamm") ?? {
			let scn  			= !pinSkin ? 
				SCNNode(geometry:SCNCone(topRadius:0, bottomRadius:1, height:height)) :			
				SCNNode(geometry:SCNCone(topRadius:0.15, bottomRadius:0.01, height:height))	// debug
			scn.name			= "s-Hamm"
			scn.position 		= SCNVector3(0, height/2, 0)
			scn.color0			= .orange
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class HammingSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func bidOfShare() 			  -> Float	{		return 1			}
	override func basicConSpot() -> ConSpot {	 // look at particular type of share:
		let r					= radius
		return ConSpot(center:SCNVector3(0, 0.5*r, 0), radius:1*r)		//1
//		return ConSpot(center:SCNVector3(0, 1*r, 0), radius:1*r)		//1
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
		let scn					= vew.scn.find(name:"s-Mult") ?? {
			let s				= CGFloat(2.0)
			let scn				= SCNNode(geometry:SCNPyramid(width:s, height:s, length:s))
			scn.name			= "s-Mult"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.color0				= .orange
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
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
		let scn					= vew.scn.find(name:"s-KNorm") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1.6))
			scn.color0			= .orange
			scn.name			= "s-KNorm"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.position.y			= 0.6
		scn.scale				= SCNVector3(1, 0.4, 1)
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
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
		let scn : SCNNode		= {  //vew.scn.find(name:"s-Seq") ?? {
			let height 			= Double(parent?.children.count ?? 2) - 1.0
			let scn				= SCNNode(geometry:SCNCylinder(radius:1.0, height:height))
			scn.color0			= .orange
			scn.name			= "s-Seq"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		}()
		scn.rotation			= SCNVector4(1,0,0, CGFloat.pi/2)
		scn.position.y			= 1
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class SequenceSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	  // MARK: - 9.3 reSkin
	//override func reSkin(fullOnto vew:Vew) -> BBox  {	// Pyramid
	//	let scn : SCNNode		= vew.scn.find(name:"s-Share") ?? { //(() -> SCNNode) in
	//		let scn 			= SCNNode(geometry:SCNSphere(radius:0.5))
	//	//	let s				= 0.5
	//	//	let scn 			= SCNNode(geometry:SCNBox(width:s, height:s/20, length:s, chamferRadius:0))// width:s, height:s, length:s))
	//	//	let scn 			= SCNNode(geometry:SCNPyramid(width:s, height:s, length:s))
	//		scn.name			= "s-Share"
	//		scn.color0			= .red
	//		vew.scn.addChild(node:scn, atIndex:0)
	//		return scn
	//	} ()
	//	return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	//}
	override func basicConSpot() -> ConSpot {
		let r				= super.radius
		let ind				= parent?.children.firstIndex(of:self) ?? 0
		let nChildren 		= parent?.children.count ?? 0
		let foo				= Double(ind) - Double(nChildren)/2
		//return ConSpot(center:SCNVector3(0, SeqY, foo * r), radius:0)//2*r, foo * r))
		return ConSpot(center:SCNVector3(0, 2*r, foo * r), radius:0)
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
		let selfNo					= parent.children.firstIndex(of:self)!

		if (upLocal) {		// === UP:
			if (selfNo == 1) {		// First Share output (up) is set by primaryPort:
				 // Our parent's primary port:
				let pPort		= parent.ports["P"] ?? .error
				let pPortCon2	= pPort.connectedTo
				let (value, valuePrev) = pPortCon2!.getValues()	// self's up now and prev

				if valuePrev<0.5 && value>=0.5 {	// RISING EDGE (Event A)
					take(value:1.0)						// START: / Share 1 output
				}
				if valuePrev>=0.5 && value<0.5 { 	// FALLING EDGE (Event H)
					pPort.take(value:0.0)				// set next port
				}
			}
			else {					// other Share outputs (up)
			}						//		were left there by previous Share's down
		}
		else {					// === DOWN
			 // Output number for next Share
			let outNo 		= selfNo+1<parent.children.count ? selfNo+1 : 0
			let outPort		= parent.children[outNo] as! Port

			let inPort		= self.connectedTo		// self's down before
			let (value, valuePrev) = inPort!.getValues()		// self's down now

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
class Bulb : Splitter { //######################################################

	 // MARK: - 2. Object Variables:
	var pValue : Float			= 0.0
	 // Current Way:
	// Xyzzy18.1. Bulb.simulate(up) reads it's P input
	// Xyzzy18.2. Set bulbValue, If it is the different, mark tree as having dirty size

	 // MARK: - 3.7 Equitable
	func varsOfBulbEq(_ rhs:Part) -> Bool {
		guard let rhsAsBulb		= rhs as? Bulb else {	return false			}
		return 		  pValue == rhsAsBulb.pValue
			&& 			gain == rhsAsBulb.gain
			&& 		  offset == rhsAsBulb.offset
			&& currentRadius == rhsAsBulb.currentRadius
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfBulbEq(part)
	}

	 // MARK: - 8. Reenactment Simulator
	override func bidTotal() -> Float 		{	return 1						} // Bulb
	override func simulate(up upLocal:Bool) {
		super.simulate(up:upLocal)		// BUG: Breakpoint here doesn't work

		 // Bulbs size may change:
		if upLocal,
		  let pInput			= ports["P"]?.connectedTo?.getValue(),
		  pValue != pInput 			// Value changed?	//prev != total
		{
			atDat(3, logd("   BULB: %.2f (was %.2f)", pInput, pValue))
			pValue				= pInput	//	pass on 
			markTree(dirty:.size)			// mark splitter size as dirty
		}
	}	
	 /// Diameter and Radius are functions of value
	func diam(  ofValue value:Float) -> CGFloat	{	return CGFloat(max(gain * value + offset, 0.0))	}
	func radius(ofValue value:Float) -> CGFloat	{	return CGFloat(max(gain * value + offset, 0.0))	}
	@Published var gain  : Float	= 2.0//0.1//
	{	didSet { if gain != oldValue {
				markTree(dirty:.size)
																		}	}	}
	@Published var offset: Float	= 0.5
	{	didSet { if offset != oldValue {
				markTree(dirty:.size)
																		}	}	}
	@Published var currentRadius : CGFloat = 0.0
	{	didSet { if currentRadius != oldValue {
				markTree(dirty:.size)
																		}	}	}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Bulb") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1))
			scn.color0			= .orange
			scn.name			= "s-Bulb"
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		} ()
		let r					= radius(ofValue:pValue)
		currentRadius			= r
		scn.scale				= SCNVector3(r, r, r)		//0.01*
		scn.position.y			= max(r-0.2, 0)		// ensure sphere and Port overlap
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	override func reSize(vew:Vew) {
		super.reSize(vew:vew) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv 					= super.pp(mode, aux)
		if mode == .line { 
			rv					+= "radius(\(currentRadius)) = pVal(\(pValue)) * gain(\(gain)) + offset(\(offset))"
		}
		return rv
	}
}  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
class BulbSh : Share {  //#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
	override func bidOfShare() 			  -> Float	{	return 1				}
	 /// Intercept Port.value, to perhaps set viewSizeIsDirty
	override var value : Float 		{		// a place for debug breakpoints:
		get		{	return super.value											}
		set(v) 	{ 
			if super.value != v {
				 // A change in value -->  resize / rebound  event
				parent?.markTree(dirty:.size)
				super.value 	= v
			}
		}
	}
	override func basicConSpot() -> ConSpot {
		let b					= atom as? Bulb
		let v					= b!.pValue
		let (r, d)				= (b!.radius(ofValue:v), b!.diam(ofValue:v))
		return ConSpot(center:SCNVector3(0, d/2, 0), radius:r)
	}
}//#########################################################################



