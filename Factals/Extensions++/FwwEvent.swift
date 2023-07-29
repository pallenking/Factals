//  FwwEvent.swift -- generate digital words C190822PAK
import SceneKit

protocol ProcessNsEvent {
	func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool
}

// extension TimingChain	: ProcessNsEvent {}		// Redundant
// extension WorldModel		: ProcessNsEvent {}		// Redundant
extension Part				: ProcessNsEvent {}
extension FactalsDocument	: ProcessNsEvent {}
extension FwGuts			: ProcessNsEvent {}
extension RootScn			: ProcessNsEvent {}
//extension EventReceiver	: ProcessNsEvent {}		// ???
extension Simulator			: ProcessNsEvent {}
//extension FwwEvent		: ProcessNsEvent {}



//extension NSEvent {
//		// Determine the RootVew referenced by this event.
//	func rootVew() -> RootVew? {
//		let fwGuts 				= DOCfwGuts
//		if let nsViewOfEv 		= window?.contentView {		// NSView of all SwiftUI
//
//			 // Find rootVew whose base fwView is a descendant of nsViewOfEv
//			for rootVew in fwGuts.rootVews {
//				if let fwView	= rootVew.rootScn.fwView,//rootScn.fwView,
//				  fwView.isDescendant(of:nsViewOfEv) {
//					return rootVew
//				}
//			}
//		}
//		return nil
//	}
//}
		//	print("--- nsEvent.window?.contentView?.subviews[i]: \(view) ")
		//	for subv in view.subviews {
		//		print("-------- subv: \(subv) ")
		//		if let scnView	= subv as? SCNView {
		//			if let scnScene = scnView.scene {
		//				print("#### gotit \(scnScene) ")
		//			}
		//			print("-------- subv: \(scnView) ")
		//		}
		//	}
//	var rootVew : (Int, RootVew?) {
//		bug
//		return (0, nil)
//		let contentVew			= window?.contentView
//		for document in DOCctlr.documents {
//			for rootScn in fwScns {
//
//			}
//		}
//	}


class HnwEvent {							// NOT NSObject
	let fwType : FwType

	let	nsType : Int 			= 999
		// As defined in NSEvent.NSEventType:
		//NSLeftMouseUp 		NSRightMouseDown 	NSRightMouseUp NSMouseMoved
		//NSLeftMouseDragged	NSRightMouseDragged
		//NSMouseEntered 		NSMouseExited
		//NSKeyDown 			NSKeyUp 			NSFlagsChanged (deleted PAK170906)
		//NSPeriodic 			NSCursorUpdate		NSScrollNSTablet 	NSTablet
		//NSOtherMouse 			NSOtherMouseUp		NSOtherMouseDragged
		//NSEventTypeGesture	NSEventTypeMagnify	NSEventTypeSwipe 	NSEventTypeRotate
		//NSEventTypeBeginGesture NSEventTypeEndGesture NSEventTypeSmartMagnify NSEventTypeQuickLook
	var clicks		: Int		= 0		// 1, 2, 3?
	var key			: Character = " "
	var modifierFlags: Int64	= 0
		// As defined in NSEvent.modifierFlags:
		// NSAlphaShiftKeyMask 	NSShiftKeyMask 		NSControlKeyMask 	NSAlternateKeyMask
		// NSCommandKeyMask 	NSNumericPadKeyMask NSHelpKeyMask 		NSFunctionKeyMask
	var mousePosition:SCNVector3 = .zero	// after[self convertPoint:[theEvent locationInWindow] fromVew:nil]
	var deltaPosition:SCNVector3 = .zero	// since last time
	var deltaPercent :SCNVector3 = .zero	// since last time, in percent of screen
	var scrollWheelDelta		= 0.0

	init(fwType f:FwType) {
		fwType 					= f
	}
}

 // An event used by the Simulator
//extension FwwEvent : Equatable {
//	func equalsFW(_ rhs: FwwEvent) -> Bool {
//bug;	return self == rhs
//	}
//}
enum FwwEvent : Codable, EquatableFW {
	func equalsFW(_: Part) -> Bool {
		bug
		return false
	}
	// Uid,
	//var uid 		: UInt16 		{ 	return SwiftFactals.uid(nsOb:self)	}
	case aString(String)
	case anArray([FwwEvent])
	case anEpoch(Int)
	case aProb(Float)
	case aNil_

	init?(any:Any?) {
		if any==nil {
			self				= .aNil_
		}
		else if let str			= any! as? String {
			self				= .aString(str)
		}
		else if let epo			= any! as? Int {
			self				= .anEpoch(epo)
		}
		else if let prob		= any! as? Float {
			self				= .aProb(prob)
		}
		else if let arr 		= any! as? Array<Any> {
			var rv : [FwwEvent]	= []
			for elt in arr {
				if let eElt		= FwwEvent(any:elt) {
					rv.append(eElt)
				}
				else {
					return nil
				}
			}
			self				= .anArray(rv)
		}
		else {
			return nil
		}
	}
//	 // MARK: - 3.5 Codable
//	enum FwwEventKeys:String, CodingKey {
//		case x, y, z
//	}
//	init(from decoder: Decoder) throws 		{		fatalError()	}
//
//	 // Serialize
////	func encode(to encoder: Encoder) throws {		fatalError()	}
//	func encode(to encoder: Encoder) throws {
//		var container 		= encoder.container(keyedBy:ScnVector3Keys.self)
//		try container.encode(self.x, forKey:.x)
//		try container.encode(self.y, forKey:.y)
//		try container.encode(self.z, forKey:.z)
//		atSer(3, DOClog.log("Encoded  ScnVector3"))
//	}
/*	 // Deserialize
	public init(from decoder: Decoder) throws {
		self.init()
		let container 		= try decoder.container(keyedBy:ScnVector3Keys.self)

		x	 				= try container.decode(CGFloat.self, forKey:.x)
		y	 				= try container.decode(CGFloat.self, forKey:.y)
		z	 				= try container.decode(CGFloat.self, forKey:.z)
		print("Decoded  as? ScnVector3 \(self.pp(.line)) ")
	}
*/


	mutating func add(event:FwwEvent) {
		if case .anArray(var a) = self {
			a.append(event)
		}
		else {
			panic("Adding event to non-array")
		}
	}


	/* Functionality by Example:
	
	Example of 5 samples of bundle with leafs named "a" and "b" with random 1-ness
	 of 0.6 and 0.7 resp., set up to play again:
	
		id foo = [ "repeat 5", ["a=rnd .6", "b=rnd .7"], "again"]
	
	Reserved Symbols:
		"again"
		"repeat <n>"	unroll the array that follows <n> times
		0				do not preclear

	String form for Name/Values:
		String:			Set bundle's leaf
		"a"				a to value 1.0
		"a=0.5"			a to value 0.5
		"a=rnd 0.5"		a to 1 with prob(0.5)
		"a=rVal 0.5"	a to random value >0 and <0.5
	  */

	 // 161201 This code is a shadow of what it started out as, and could be rebuilt
	func eventUnrand(events:FwwEvent) -> String {
		if case .anArray(let eventsArray) = events {
			for event in eventsArray {
				if case .aString(var eventString) = event {
					 // .., "repeat count", <body>, ..
					if eventString.hasPrefix("repeat") {
						eventString.removeFirst(6)
		//				let n 	= eventString.asInt
		//				let body = eventsArray[i]			// <body> --> eventUnrand(<body>)
		panic()
		//				i		+= 1
		//				for j in 0..<n {
		//					rv.addObject(eventUnrand(body))
		//				}
					}
					 // .., "again"]
					else if eventString.hasPrefix("again") {
						//panic("wtf")
		//				rv.add(event:eventString)	// just pass thru, processed elsewhere
					}
					 // .., valueSpec, ...		// valueSpec = <name>["=" [("rnd" <prob>) | "rVal" <maxVal>)]]
					else {
						var name = eventString				// initial guess: no "="
						var value = Float(0.0)

						  // names are space-separated or quoted (REALLY?)
						 // signal may contain a value (e.g. "foo=0.7")
						let comp = eventString.components(separatedBy:"=")
						if comp.count == 2 && comp[0].count != 0 {	/// E.g: <k>=<v>
							 // legal for names to start wit an "="? e.g. "=a=3"
							name = comp[0]
							let rawValue = comp[1]
							if let rVal  = rawValue.asString {
								if let v = rVal.asFloat {	/// E.g: "a=0.3"
									value = v
								}
								else if rawValue.hasPrefix("rnd"),	/// E.g: "a=rnd 0.5"
									 // value = 1, with probability prob
									let prob = String(rawValue.dropFirst(3)).asFloat {
									value 	= randomProb(p:prob) ? 1 : 0 // 1 with prop
								}
								else if rawValue.hasPrefix("rVal"), /// E.g: "a=rVal 0.5"
								  let rVal	= String(rawValue.dropFirst(5)).asFloat {
									value	= randomDist(0, rVal) // value 	= random boxcar, between 0 and value rVal
								}
								else {
									panic("")
								}
							}
						}
						if value != 0.0 {
							let _/*absSignal*/	= name + (value == 1 ? "=1": fmt("=%.3f", value))
		//					rv.addObject(absSignal)
						}
					}
				}
			}
			//atEve(4, D OClog.log("- - - - - eventUnrand((events.pp()))"))
			 // paw through all elements of outter array
			return "broken"
		}
		panic()
		return "WTF"
	}

	 //	 MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		switch mode {
		case .phrase, .short:
			switch self {
			case .aString(let s):		return s
			case .anArray(let a):		return a.pp(.phrase)
			case .anEpoch(let e):		return String(e)
			case .aProb(  let f):		return String(f)
			case .aNil_:				return "<nil>"
			}
		case .line:
			switch self {
			case .anArray(let a):
				var (rv, sep)	= ("[", "")
				for elt in a {
					rv 			+= sep + elt.pp(.short, aux)
					sep			= ", "
				}
				return rv + "]"
			default:
				return pp(.short, aux)
			}
																				// Ee..
		case .tree:
			switch self {
			case .anArray(let a):
				var (rv, sep)	= ("[", "")
				for elt in a {
					rv 			+= sep + elt.pp(.short, aux)
					sep			= ", \n "
				}
				return rv + "]"
			default:
				return pp(.short, aux)
			}
		default:
			return ppCommon(mode, aux)		// NO, try default method
		}
	}
}
func makeFwEvent(fwType:FwType) -> HnwEvent {
	let rv : HnwEvent			= HnwEvent(fwType:fwType)
//	rv.fwType 					= fwType
	return rv;
}

let  p8X5 = [ "repeat 5", ["a=rnd .5", "b=rnd .5", "c=rnd .5", "d=rnd .5",
						   "e=rnd .5", "f=rnd .5", "g=rnd .5", "h=rnd .5"],	"again"] as [Any];
