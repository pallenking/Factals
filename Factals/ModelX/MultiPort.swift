//  MultiPort.swift -- a multi-bit Port
import SceneKit

// MARK: -
class MultiPort : Port {
// control option command G
	 // MARK: - 1. Class Variables:
	 // MARK: - 2. Object Variables:
	override var height : CGFloat	{ return 0.4								}
	override var radius : CGFloat	{ return super.radius * 1.5 				}
	 // MARK: - 8.1 PortTalk protocol
	override func take(value val:Float, key:String?=nil) {

		 // Forward to other MPort, whose parent should be a Tunnel:
		if let tunnel			= self.atom as? Tunnel {
			tunnel.forAllLeafs		// Go through all Leafs of Tunnel:
			{(leaf:Leaf) in			  //##BLOCK
				if key==nil || 		// nil --> 'all mode'
				  leaf.name == key! 	// at named Leaf
				{
					guard let gPort = leaf.port(named:"G") else {
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
			atDat(3, logd(">=~.  %.2f (was %.2f)", value, valuePrev))
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
			atDat(3, logd(">=~.  %.2f (was %.2f)", value, valuePrev))
		}
		return (cur, prev)
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {		// Ports and Shares
	  // / Put full skin onto MultiPort
		let scn					= vew.scn.find(name:"s-Port") ?? {
			let (r, h)			= (radius, height)
			let ep : CGFloat 	= 0.01//0.1//

			 // Scn is the big Cylinder 
			let scn				= SCNNode(geometry:SCNCylinder(radius:r, height:h-ep))
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Port"
			scn.position.y 		+= h/2 + ep/2		// All above origin
			scn.color0 			= NSColor(mix:NSColor("lightpink")!, with:0.4, of:NSColor("darkgreen")!)
//			scn.color0 			= NSColor("lightpink")! //"red"//.green//"darkred"//.lightpink//

			 // Disc marks its connection point
			let disc 			= SCNNode(geometry:SCNCylinder(radius:r/2, height:ep))
			scn.addChild(node:disc, atIndex:0)
			disc.name			= "disc"
			disc.position.y		-= h/2
			disc.color0			= NSColor.black
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	  // MARK: - 9.5: RePaint:
//	 override func rePaint(vew:Vew) {	// MultiPorts have no colorings
//		super.rePaint(vew:vew)
//	 }
	static let null1 			= MultiPort()
}
