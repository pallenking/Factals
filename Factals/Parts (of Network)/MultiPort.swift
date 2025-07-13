//  MultiPort.swift -- a multi-bit Port
import SceneKit

// MARK: -
class MultiPort : Port {
// control option command G
	 // MARK: - 1. Class Variables:
	 // MARK: - 2. Object Variables:
	override var height : CGFloat	{ return 0.4								}
	override var radius : CGFloat	{ return super.radius * 1.5 				}
	 // MARK: - 3. Part Factory:
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	required init?(coder: NSCoder) { debugger("init(coder:) unimplemented")	}
	required init(from decoder: Decoder) throws {	debugger("init(from:) unimplemented")	}

	// MARK: - 8.1 PortTalk protocol
	override func take(value val:Float, key:String?=nil) {

		 // Forward to other MPort, whose parent should be a Tunnel:
		if let tunnel			= self.atom as? Tunnel {

			if key != nil {
				tunnel.forAllLeafs() {
					(leaf:Leaf) in
					print(leaf.fullName)
				}
			}
			tunnel.forAllLeafs() {
			(leaf:Leaf) in
				if key  == nil || 		// --> 'all mode'
				   key! == leaf.name 	// at named Leaf
				{
					guard let gPort = leaf.getPort(named:"G") else {
						panic("Leaf \(leaf.fullName) must have 'G' Port")
						return
					}						// use 'G' Port in Leaf for generation
					assert(gPort !== self, "output port matches input port")
					gPort.take(value:val)	// put to Leaf's 'G' Port
				}
			}
		}
	}
	override func valueChanged(key:String?=nil) -> Bool {
		let t					= parent as? Tunnel
		assert(t != nil, "Multi-Port's parent should be a Tunnel")
		assert(key != nil, "valueChanged(key:<nil>) fails")
		let port				= t!.ports[key!]
		assert(port != nil, "valueChanged: port for key:\(key!) nil")
		return port!.valueChanged()
	}
	override func getValue(key:String?=nil) -> Float {
		let atm					= parent as? Atom
		assert(atm  != nil, "Multi-Port's parent should be a Tunnel")
		assert(key  != nil, "valueChanged(key:<nil>) fails")
		let port				= atm!.ports[key!]
		assert(port != nil, "getValue(  port for key:\(key!) nil")

		let changed				= port!.valueChanged()
		let cur					= port!.getValue()

		if changed {
			logDat(3, ">------.  %.2f (was %.2f) (\(fullName))", value, valuePrev)
		}
		return cur
	}
	  // get new value, save current as prev .:. it's set to unchanged
	 // N.B: getter with side effect! //
	override func getValues(key:String?=nil) -> (Float, Float) {
		let atm					= parent as? Atom
		assert(atm  != nil, "Multi-Port's parent should be a Tunnel")
		assert(key  != nil, "valueChanged(key:<nil>) fails")
		let port				= atm!.ports[key!]
		assert(port != nil, "getValues(  port for key:\(key!) nil")

		let changed				= port!.valueChanged()
		let (cur, prev)			= port!.getValues()

		if changed {
			logDat(3, ">------.s %.2f (was %.2f) (\(fullName))", value, valuePrev)
		}
		return (cur, prev)
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {		// Ports and Shares
	  // / Put full skin onto MultiPort
		let scn					= vew.scn.findScn(named:"s-Port") ?? {
			let (r, h)			= (radius, height)
			let ep : CGFloat 	= 0.01//0.1//

			 // Scn is the big Cylinder 
			let t1				= SCNNode(geometry:SCNCylinder(radius:r, height:h-ep))
			vew.scn.addChild(node:t1, atIndex:0)
			t1.name				= "s-Port"
			t1.position.y 		+= h/2 + ep/2		// All above origin
			t1.color0 			= NSColor(mix:NSColor("lightpink")!, with:0.4, of:NSColor("darkgreen")!)
//			t1.color0 			= NSColor("lightpink")! //"red"//.green//"darkred"//.lightpink//
			 // Disc marks its con2 point
			let disc 			= SCNNode(geometry:SCNCylinder(radius:r/2, height:ep))
			t1.addChild(node:disc, atIndex:0)
			disc.name			= "disc"
			disc.position.y		-= h/2
			disc.color0			= NSColor.black
			return t1
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
