//  LinkPort.swift -- A Port for a Link, which includes delay/visual abilities ©21PAK

// NOTE: Philosophy of modeling delays:
//			Delays happen in links.
//			Computational Elements have zero to minimal delays.

import SceneKit
struct LinkSegment  : Codable {
	var heightPct	: Float		= 0		// how high the seg is: 0.0:near_self.Port, 1.0:near_outPort
	var val			: Float		= 0		// being propigated (BUT WHICH EDGE?)
}
	 // MARK: - 3.7 Equatable
extension LinkSegment : Equatable {
	func equals(_ rhs: LinkSegment) -> Bool {
bug//	guard self !== rhs 					  else {	return true				}
		return heightPct == rhs.heightPct  &&  val == rhs.val
	}
}

class LinkPort : Port {
	// self.Port 						// 1. Connects to this end of link
	var inTransit:[LinkSegment] = []	// 2. Conveyor delay with visual
	var outPort : Port?			= nil	// 3. Output from Link

	var imageX0 : Int			= 0		// initial x of colored line image
	var imageY0 : Int			= 0		// initial y of colored line image
	var colorOfVal0				= NSColor(hexString:"#FFFFFFFF")! // a particular white
	var colorOfVal1 			= NSColor.purple	// should be overridden
	func addSegment(_ seg:LinkSegment) {
		inTransit.append(seg)
		root?.simulator.linkChits	+= 1
		assert(root?.simulator.linkChits ?? 1 != 0, "wraparound")
	}

//	init() { // only for nullConveyor
//		outPort					= Port.error
//		super.init()
//	}

//	init( ["named":portName, "portProp":portProp]) :
	init(_ config_:FwConfig, parent:Atom, i0:(Int, Int)=(0,0), color0:NSColor?=nil, _ initialSegments:[LinkSegment] = []) {
		self.imageX0 			= i0.0
		self.imageY0 			= i0.1
		if let color0 = color0 {
			self.colorOfVal1	= color0
		}
		inTransit				= initialSegments	// 21200825 UNUSED
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
		try container.encode(inTransit,		forKey:.array)
		atSer(3, logd("Encoded  LinkPort    '\(self.fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)	// 20210908		no super.decode(from:) call, because LinkPort  ????
		let container 			= try decoder.container(keyedBy:LinksKeys.self)

		outPort	 				= try container.decode(			Port.self, forKey:.outPort)
		imageX0	 				= try container.decode(			 Int.self, forKey:.imageX0)
		imageY0	 				= try container.decode(			 Int.self, forKey:.imageY0)
//		colorOfVal1	 			= try container.decode(		 NSColor.self, forKey:.colorOfVal1)
		inTransit	 				= try container.decode([LinkSegment].self, forKey:.array)
		atSer(3, logd("Decoded  as? LinkPort"))
	}
//	 // MARK: - 3.6 NSCopying
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! LinkPort
//		theCopy.outPort	 		= self.outPort
//		theCopy.imageX0	 		= self.imageX0
//		theCopy.imageY0	 		= self.imageY0
//	//	theCopy.colorOfVal	 	= self.colorOfVal1
//		theCopy.array	 		= self.array
//		atSer(3, logd("copy(with as? LinkPort       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 							   else {	return true		}
		guard let rhs			= rhs as? LinkPort else {	return false 	}
		let rv					= super.equalsFW(rhs)
							//??	&& equalsFW(outPort, rhs.outPort)
								&& imageX0	  == rhs.imageX0
								&& imageY0	  == rhs.imageY0
		//						&& colorOfVal == rhs.colorOfVal
								&& inTransit	  == rhs.inTransit
bug;	return rv
	}
	 // MARK: - 8. Reenactment Simulator
	func simulate() {
		 // Up and Down are processed alike!
 		guard let simulator		= root?.simulator else  {	fatalError(fullName)}
		guard let outPort 						  else  {	fatalError(fullName)}
		guard let inPort2Port	= self.con2?.port else  {	fatalError(fullName)}

		 // Take data from inPort, and put output into outPort
		if inPort2Port.valueChanged() {

		 	 // ENQUEUE the event (at beginning of inTransit)
			let (valueIn, valuePrev) = inPort2Port.getValues()
			assert(!valueIn.isNaN,      "enqueing nan value to link")
			assert(!valueIn.isInfinite, "enqueing inf value to link")
			atDat(3, logd("Link<--' %.2f (was %.2f)", valueIn, valuePrev))

			 // Set the previous value into the conveyer, to go up
			inTransit.insert( LinkSegment(heightPct:0.0, val:valuePrev), at:0)
			simulator.linkChits += 1			/// not settled
			assert(simulator.linkChits != 0, "linkChits count wraparound")
		}

		 // Determine LinkPort velocity
		var logVel 				= config("linkVelocityLog2")?.asFloat ?? -5		// ~ in Configuration dominates
		if let linksVel			= localConfig["v"]?.asFloat {
 			logVel				+= linksVel	// Link may override local
		}
		let conveyorVelocity 	= exp2f(logVel)

		if conveyorVelocity != 0,			// If LinkPort moving
		   inTransit.count != 0 {			  // and something in it
			parent?.markTree(dirty:.paint)		// order redisplay
		}

		 // Run the link "inTransit BELT", which delays changes for visualization.
		for i in stride(from:inTransit.count-1, to:-1, by:-1) { // do backwards, so remove works

			 // Move every segment up, according to seg...vel.
			inTransit[i].heightPct 	+= conveyorVelocity	// move along, from 0.0...1.0

			 // DEQUEUE the next event (at beginning of inTransit)
			 // DEQUEUE an event?:
			if inTransit[i].heightPct >= 1 {	// has a seg gone off the end?
				inTransit.remove(at:i) 				// deque used up element
				 // Decrement unsettled count
				assert(simulator.linkChits != 0, "wraparound")
				simulator.linkChits -= 1

				let	nextVal		= inTransit.count >= 1 ?
								  inTransit[i-1].val   :// TAKE the value quietly (not takeValue w printout)
								  inPort2Port.value 	// Link input port if no previous value
				atDat(5, outPort.logd("Link-->> %.2f (was %.2f) to '\(outPort.fullName)'", nextVal, outPort.value))
				if outPort.value != nextVal {
					let rootPart = outPort.root
					let c1		= rootPart?.portChitArray().map { $0() }.joined(separator:", ")
					print("Before: \(c1 ?? "")")
					outPort.value = nextVal								// not outPort.take(value:v)
					outPort.markTree(dirty:.paint)
					outPort.con2?.port?.markTree(dirty:.paint)		// repaint my other too
					let c2		= rootPart?.portChitArray().map { $0() }.joined(separator:", ")
					print("After:  \(c2 ?? "")")
					nop
				}
			}
		}
	}
	func paintSegments(on image:NSImage) {	// Draw contents of LinkPort on an NSImage
		guard let parentLink	= parent as? Link else {	fatalError("")		}
		image.lockFocus()
		let imageHeight			= Float(parentLink.imageHeight)

		   // A NSBezierPath can have only one color.
		  // .:. Each color value must be in a separate path
		 // color of segment:


//		if inPort2Port.valueChanged() {
//			let (valueIn, valuePrev) = inPort2Port.getValues()
//		guard let inPort2Port	= self.con2?.port else  {	return				}



		guard let con2Port		= con2?.port else 	{ fatalError()				}
		let v					= con2Port.valuePrev
		var color : NSColor		= NSColor(mix:colorOfVal0, with:v, of:colorOfVal1)
		var fromPt				= NSPoint(x:imageX0, y:imageY0)
		for linkSegment in inTransit {		// inTransit ordered least to most

			 // Draw a line of specified color:
			let htPct			= imageY0 == 0 ? linkSegment.heightPct	// going up	  0.0..<1.0
										 : 1.0 - linkSegment.heightPct	// going down 1.0>..0.0
			let toPt			= NSPoint(x:imageX0, y:Int(htPct * imageHeight))
			color.setStroke()
/**/		NSBezierPath.strokeLine(from:fromPt, to:toPt)

			 // Advance to Next Segment:
			color				= NSColor(mix:colorOfVal0, with:linkSegment.val, of:colorOfVal1)
			fromPt				= toPt
		}
		let htPct : Float		= imageY0 == 0 ? 1.0	// going up		0.0..<1.0
										 	   : 0.0 	// going down	1.0>..0.0
		let toPt				= NSPoint(x:imageX0, y:Int(htPct * imageHeight))
		color.setStroke()
/**/	NSBezierPath.strokeLine(from:fromPt, to:toPt)
		image.unlockFocus()
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ name:String) -> String	{
		var (rv, sep)			= ("", name)
		for linkSegment in inTransit {
			rv 					+= "\t\t\t\t\t\t\(sep) [\(linkSegment.heightPct): val=\(linkSegment.val)]\n"
			sep					= "  "
		}
		return rv
	}
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv = super.pp(mode, aux)
		if mode == .tree {
			var sep				= ""
			for seg in inTransit {
				rv 				+= "\t\t\t\t\t\t\(sep) [\(seg.heightPct): val=\(seg.val)]\n"
				sep				= "  "
			}
		}
		return rv
	}
//	static let nullLinkPort	= LinkPort()
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
