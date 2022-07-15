//  ConvPort.swift -- A Port for a Link, which includes delay/visual abilities ©21PAK
//  :H: CONVeyorPort
//

import SceneKit
struct LinkSegment  : Codable, Equatable {
	var heightPct	: Float		= 0		// how high the seg is: 0.0:near_self.Port, 1.0:near_outPort
	var val			: Float		= 0		// being propigated (BUT WHICH EDGE?)
}

class ConvPort : Port {
	// self.Port 						// 1. Connects to this end of link
	var array   : [LinkSegment] = []	// 2. Conveyor delay with visual
	var outPort : Port?			= nil	// 3. Output from Link

	var imageX0 : Int			= 0		// initial x of colored line image
	var imageY0 : Int			= 0		// initial y of colored line image
	static var colorOfVal0		= NSColor(hexString:"#FFFFFFFF")! // a particular white
	var 	   colorOfVal1 		= NSColor.purple	// should be overridden
	func addSegment(_ seg:LinkSegment) {
		array.append(seg)
		root?.simulator.unsettledOwned	+= 1
		assert(root?.simulator.unsettledOwned ?? 1 != 0, "wraparound")
	}

	init() { // only for nullConveyor
		outPort					= Port.error
		super.init()
	}

//	init( ["named":portName, "portProp":portProp]) :
	init(_ config_:FwConfig, parent:Atom, i0:(Int, Int)=(0,0), color0:NSColor?=nil, _ initialSegments:[LinkSegment] = []) {
		self.imageX0 			= i0.0
		self.imageY0 			= i0.1
		if let color0 = color0 {
			self.colorOfVal1	= color0
		}
		array					= initialSegments	// 21200825 UNUSED
		super.init(config_)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		self.parent				= parent
	}

	 // MARK: - 3.5 Codable
	enum LinksKeys: String, CodingKey {
		case inVal
		case inPort
		case outPort
		case imageX0
		case imageY0
	//	case colorOfVal1
		case array
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to:encoder)
		var container 			= encoder.container(keyedBy:LinksKeys.self)

//		try container.encode(inVal,		forKey:.inVal)
//		try container.encode(inPort,	forKey:.inPort)
		try container.encode(outPort,	forKey:.outPort)
		try container.encode(imageX0,	forKey:.imageX0)
		try container.encode(imageY0,	forKey:.imageY0)
//		try container.encode(colorOfVal1,	forKey:.colorOfVal1)
		try container.encode(array,		forKey:.array)
		atSer(3, logd("Encoded  ConvPort        '\(self.fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)	// 20210908		no super.decode(from:) call, because ConvPort  ????
		let container 			= try decoder.container(keyedBy:LinksKeys.self)

		outPort	 				= try container.decode(			Port.self, forKey:.outPort)
		imageX0	 				= try container.decode(			 Int.self, forKey:.imageX0)
		imageY0	 				= try container.decode(			 Int.self, forKey:.imageY0)
//		colorOfVal1	 			= try container.decode(		 NSColor.self, forKey:.colorOfVal1)
		array	 				= try container.decode([LinkSegment].self, forKey:.array)
		atSer(3, logd("Decoded  as? ConvPort"))
	}
	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : ConvPort	= super.copy(with:zone) as! ConvPort
		theCopy.outPort	 		= self.outPort
		theCopy.imageX0	 		= self.imageX0
		theCopy.imageY0	 		= self.imageY0
	//	theCopy.colorOfVal	 	= self.colorOfVal1
		theCopy.array	 		= self.array
		atSer(3, logd("copy(with as? ConvPort       '\(fullName)'"))
		return theCopy
	}
	 // MARK: - 3.7 Equitable
	func varsOfConvPortEq(_ rhs:Part) -> Bool {
		guard let rhsAsConvPort	= rhs as? ConvPort else {	return false		}
		return outPort	 		== rhsAsConvPort.outPort
			&& imageX0	 		== rhsAsConvPort.imageX0
			&& imageY0	 		== rhsAsConvPort.imageY0
		//	&& colorOfVal	 	== rhsAsConvPort.colorOfVal
			&& array	 		== rhsAsConvPort.array
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfConvPortEq(part)
	}
	 // MARK: - 8. Reenactment Simulator
	func simulate() {
 		guard let simulator		= root?.simulator else  {	return				}
		guard outPort != nil else						{	fatalError()		}
		  // Up and Down are processed alike!
		 // Take data from inPort, and put output into outPort
		let inPortCon2			= self.connectedTo

		 // ENQUEUE the event (at beginning of array)
		if inPortCon2?.valueChanged() ?? false {
			let (valueIn, valuePrev) = inPortCon2!.getValues()
			assert(!valueIn.isNaN,      "enqueing nan value to link")
			assert(!valueIn.isInfinite, "enqueing inf value to link")
			atDat(3, logd("<=_/  %.2f (was %.2f)", valueIn, valuePrev))
			atDat(5, logd("ENQUE %.2f   to link (was %.2f)", valueIn, valuePrev))

			 // Set the previous value into the conveyer, to go up
			array .insert( LinkSegment(heightPct:0.0, val:valuePrev), at:0)
			simulator.unsettledOwned += 1			/// not settled
			assert(simulator.unsettledOwned != 0, "unsettledOwned count wraparound")
		}

		 // Determine ConvPort velocity
		var logVel 				= config("linkVelocityLog2")?.asFloat ?? -5		// ~ in Configurations dominates
		if let linksVel			= localConfig["v"]?.asFloat {
 			logVel				+= linksVel	// Link may override local
		}
		let conveyorVelocity 	= exp2f(logVel)

		if conveyorVelocity != 0,			// If ConvPort moving
		   array.count != 0 {				  // and something in it
			parent?.markTree(dirty:.paint)		// Redisplay it
		}

		  // Run the link "ConvPort BELT".
		 // DEQUEUE the event (at beginning of array)
		for i in stride(from:array.count-1, to:-1, by:-1) { // do backwards, so remove works

			 // Move every segment up, according to seg...vel.
			array[i].heightPct 	+= conveyorVelocity	// move along, from 0.0...1.0

			 // DEQUEUE an event?:
			if array[i].heightPct >= 1 {	// has a seg gone off the end?
				array.remove(at:i) 				// deque used up element
				let	v			= array.count >= 1 ?
								  array[i-1].val   :// TAKE the value quietly (not takeValue w printout)
								 inPortCon2!.value 	// Link input port if no previous value
				atDat(5, outPort!.logd("DEQUE %.2f from link (was %.2f)", v, outPort!.value))
				if outPort!.value != v {
					outPort!.value = v												//outPort.take(value:v)
					outPort!			 .markTree(dirty:.paint)
					outPort!.connectedTo?.markTree(dirty:.paint)		// repaint my other too
				}
				 // Decrement unsettled count
				assert(simulator.unsettledOwned != 0, "wraparound")
				simulator.unsettledOwned -= 1
			}
		}
	}
	func paintSegments(on image:NSImage) {	// Draw contents of ConvPort on an NSImage
		guard let parentLink	= parent as? Link else {	fatalError("")		}
		image.lockFocus()
		let imageHeight			= Float(parentLink.imageHeight)

		   // A NSBezierPath can have only one color.
		  // .:. Each color value must be in a separate path
		 // color of segment:
		let v					= connectedTo?.value ?? 0.0
		var color : NSColor		= NSColor(mix:ConvPort.colorOfVal0, with:v, of:colorOfVal1)
		var fromPt				= NSPoint(x:imageX0, y:imageY0)
		for linkSegment in array {		// scan is from inPort to outPort

			 // Draw a line of specified color:
			let htPct			= imageY0 == 0 ? linkSegment.heightPct	// going up		0.0 ..< 1.0
										 : 1.0 - linkSegment.heightPct	// going down	1.0 >.. 0.0
			let toPt			= NSPoint(x:imageX0, y:Int(htPct * imageHeight))
			color.setStroke()
			NSBezierPath.strokeLine(from:fromPt, to:toPt)

			 // Advance to Next Segment:
			color				= NSColor(mix:ConvPort.colorOfVal0, with:linkSegment.val, of:colorOfVal1)
			fromPt				= toPt
		}
		let htPct : Float		= imageY0 == 0 ? 1.0	// going up		0.0 ..< 1.0
										 	   : 0.0 	// going down	1.0 >.. 0.0
		let toPt				= NSPoint(x:imageX0, y:Int(htPct * imageHeight))
		color.setStroke()
		NSBezierPath.strokeLine(from:fromPt, to:toPt)
		image.unlockFocus()
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ name:String) -> String	{
		var (rv, sep)			= ("", name)
		for linkSegment in array {
			rv 					+= "\t\t\t\t\t\t\(sep) [\(linkSegment.heightPct): val=\(linkSegment.val)]\n"
			sep					= "  "
		}
		return rv
	}
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv = super.pp(mode, aux)
		switch mode! {
		case .tree:
			var sep				= ""
			for seg in array {
				rv 				+= "\t\t\t\t\t\t\(sep) [\(seg.heightPct): val=\(seg.val)]\n"
				sep				= "  "
			}
		default: nop
		}
		return rv
	}
	static let nullConveyor		= ConvPort()
}


//***** AFTER reVew(vew:Vew?, parentVew:Vew?):
//   _l0:LinkVew o- w[ 0.0 0.0 0.0]  ->aa4@,aa4@
//  |   _P:Vew   o+ w[ 0.0 0.0 0.0] f 0.0< 0.0,  0.0< 0.0,  0.0< 0.0
//Ff|   _S:Vew   o+ w[ 0.0 0.0 0.0] f 0.0< 0.0,  0.0< 0.0,  0.0< 0.0
//*-l0     pI       [ 0.0 0.0 0.0]01 geom:nil
//| *-P    pI       [ 0.0 0.0 0.0]01 <Sphere: r=0.1>
//| *-S    pI       [ 0.0 0.0 0.0]01 <Sphere: r=0.1>

//***** AFTER reVewPost(vew:Vew):
//   _l0:LinkVew    w[ 0.0 0.0 0.0]  ->b08@,300@

// "CURIOUS -- link position with nil ends"

 //**** reSize(vew:) calls:
//***** AFTER reSkin(fullOnto:Vew):
//*-l0                       [ 0.0 0.0 0.0]01 geom:nil
//| s-Link                   [ 0.0 0.0 0.0]#H geom:nil
//| | s-Line                 [ 0.0 0.0 0.0]01 Geometry
//| | s-Dual pI[-0-0-0.5]    [ 0.0 0.0-0.5]01 <Box:  w=1.0 h=0.0 l=1.0 cr=0.0>
//| *-S                      [ 0.0 0.0 0.0]01 <Sphere:  r=0.1>
//| *-P                      [ 0.0 0.0 0.0]01 <Sphere:  r=0.1>

//***** AFTER reSizePost(vew:):
//_l0:LinkV        w[ 0.0 0.0 0.0]  ->d3c@[ 0.0 0.8 0.0],332@[ 0.0 4.8 0.0]
//| *-P     .pI[0.0 0.8 0.0] [ 0.0 0.8 0.0]01 <Sphere:  r=0.1>
//| *-S     .pI[0.0 4.8 0.0] [ 0.0 4.8 0.0]01 <Sphere:  r=0.1>

//***** AFTER rePaint(vew:)
	//*** super.sdarePaint(on
//| s-Link p<-1.0 1.0-4.0>I   [ 0.0 0.8 0.0]01 geom:nil






//	.line: SCNGeometry(sources:[source], elements:[element])
//	.tube: SCNBox(width:0.2, height:0.2, length:2, chamferRadius:0)  .uY
//	.dual: SCNBox(width:1,   height:0, length:2, chamferRadius:0)  2-sided!

//***** reVewPost(vew:Vew)
//	linkVew.[s/p]Con2Vew	= [s/p]Con2Vew	 get Views we are connect to:
//	.dualf:linkVew.scn.constraints = [[], [con0], [con0, con1]][nConstraints]
//	//***** reSize(vew:Vew)
//	markTree(dirty:.paint)					 mark tree to cause re-paint

//***** reSizePost(vew:Vew)
//	vew.scn.transform = SCNMatrix4(row1v3:row2v3:row3v3:row4v3:)
//	//***** rePaint(vew:Vew)
//	.dual: geom.materials[i].diffuse.contents = NSImage(size:)
