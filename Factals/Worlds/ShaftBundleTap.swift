//
//  ShaftBundleTap.swift
//  Factals
//
//  Created by Allen King on 11/1/23.
//
import SceneKit

class ShaftBundleTap : BundleTap { //Generator {
	let nPoles  : Int
	var tread   : Float			= 0.0				// angle of rotation?
	var armNode : SCNNode?		= nil

	// MARK: Factory
	override init(_ config:FwConfig = [:]){
		let extraConfig:FwConfig = ["placeMy":"stacolorcky"]
		let sConfig				= extraConfig + config

		  //  WorldModel.swift   Args (if needed)
		 //  -- Basic discrete time/value data sources
		nPoles 					= sConfig["nPoles"] as? Int ?? 4

		super.init(sConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
	
	required init?(coder: NSCoder) {	debugger("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {	debugger("init(from:) has not been implemented")	}

	  // MARK: - 3.1 Port Factory
 	override func hasPorts() -> [String:String]	{
		return ["P":"cM"]			// ignore super.hasPorts(), BundleTao has "S"
 	}

	 // MARK: - 5 Groom
//	override func groomModelPostWires(partBase:PartBase) {
//		super    .groomModelPostWires(partBase:partBase)
//		 // Test new targetBundle has R and G bindings
//		guard let fwBundle		= ports["P"]?.portPastLinks?.parent as? FwBundle else {fatalError() }
//		assert(targetBundle != nil, "\(fullName): targetBundle  == nil")
//		fwBundle.forAllLeafs() {leaf in
//			assert(leaf.getPort(named:"R") != nil, "\(leaf.fullName): missing 'R' Port")
//			assert(leaf.getPort(named:"G") != nil, "\(leaf.fullName): missing 'G' Port")
//		}
//	}
	 // MARK: - 8. Reenactment Simulator
	func eventReady() -> String? {	return nil									}
	override func loadTargetBundle(event:FwwEvent) {debugger("Not implemented") }

	override func simulate(up upLocal:Bool) {

		super.simulate(up:upLocal)	// TOP (step super FIRST)

		if (!upLocal) {
//			let nPoles = self.nPoles
			var force: Float = 0.0

			for i in 0..<nPoles {
bug;			var poleITread = self.tread - Float(i)
				poleITread -= Float(nPoles) * round(poleITread / Float(nPoles))

				assert(poleITread >= -Float(nPoles) / 2.0 && poleITread <= Float(nPoles) / 2.0, "Assertion failed")

				var have: Float = 0.0
				var forceGeom: Float = 0.0

				if abs(poleITread) < 0.5 {
					have 		= 1.0
					forceGeom 	= poleITread * 2
				} else {
					forceGeom 	= poleITread < 0.0 ? -1.0 : poleITread > 0.0 ? 1.0 : 0.0
				}
								//
				if let portI 	= self.getPort(i) {
					portI.value = have											//portI.valueTake = have

					if portI.valueChanged() {
						print("\(portI.fullName16)| ShaftBundleTap: new have (\(have))")
					}
					if let wPort = portI.con2?.port {
						if wPort.valueChanged() {
							print("\(portI.fullName16)| ShaftBundleTap: new want (\(wPort.value))")
						}
						let want = wPort.getValue()
						let dForce = want * forceGeom
						force += dForce
					}
				}
			}
			self.tread -= force * 0.05
			if force != 0 {
//				self.brain.kickstartSimulator()
			}
		}
	}
	func getPort(_ i: Int) -> Port? {
		assert(i >= 0 && i < nPoles, "Assertion failed")	// a,b,....
		let bitName 			= String(Character(UnicodeScalar(Int(UnicodeScalar("a").value) + i)!))
		return targetBundle?.genPortOfLeafNamed(bitName)
	}
	 // MARK: - 9.3 reSkin
	var height : CGFloat	{ return 1.0		}	// 5
	var width  : CGFloat	{ return 6.0		}
	var ffRadius				= CGFloat(2.5)

	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-ShBT") ?? {
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name			= "s-SBT1"

			 // Shaft of rotation
			let shaftNode 		= SCNNode(geometry:SCNBox(width:0.5, height:1, length:7, chamferRadius:0.01))
			rv.addChild(node:shaftNode)
			shaftNode.color0	= NSColor("darkgreen")!//.orange
 			shaftNode.rotation 	= SCNVector4(0, 0, 1, Float.pi/8)//0)//
			 // Arm to a Pole
			let armNode 		= SCNNode(geometry: SCNCylinder(radius:0.1, height:ffRadius))
			shaftNode.addChild(node:armNode)
			armNode.position.x	= ffRadius / 2
			armNode.color0		= NSColor.orange	//("darkgreen")!//
 			armNode.rotation 	= SCNVector4(0, 0, 1, Float.pi/2)
			 // Arm to a Pole
			let arrowLen		= ffRadius/2.0
			let pointNode 		= SCNNode(geometry: SCNCone(topRadius:arrowLen/2.5, bottomRadius:0, height:arrowLen))
			shaftNode.addChild(node:pointNode)
			pointNode.position.x = ffRadius - arrowLen/2
			pointNode.color0	= NSColor.red
 			pointNode.rotation 	= SCNVector4(0, 0, 1, Float.pi/2)

			 // Donout Wheels
			for i in 0..<2 {
				let offset 		= (i == 0) ? -ffRadius : ffRadius
				let torus		= SCNTorus(ringRadius:2, pipeRadius:0.3)
				torus.ringSegmentCount	= 6
				torus.firstMaterial?.diffuse.contents = NSColor.black
				let wheel 		= SCNNode(geometry:torus)
				wheel.name		= "wheel\(i)"
				wheel.position	= SCNVector3(0, 0, offset)
				wheel.rotation	= SCNVector4(1, 0, 0, CGFloat.pi/2)
				rv.addChild(node:wheel)
			}
			 // Poles
			let r				= partConfig["bitRadius"]?.asCGFloat ?? 1.0
			for i in 0..<nPoles {
				let poleInDegrees = 360 * Float(i) / Float(nPoles)
				guard let portI = getPort(i) else {		fatalError()			}
				let pv			= portI.con2?.port?.value ?? -1
				let color1		= portI.colorOf2Ports(localValUp:0.0, localValDown:pv, downInWorld:false)
				let color2		= portI.colorOf2Ports(localValUp:portI.value, localValDown:0.0, downInWorld:false)

				let armNode 	= SCNNode()//geometry: SCNBox(width: r/2, height: r*15, length: r/2, chamferRadius: 0.1)) 				//)//
				rv.addChild(node:armNode)
				armNode.rotation = SCNVector4(0, 0, 1, GLKMathDegreesToRadians(poleInDegrees))

				let plate1		= SCNNode(geometry:SCNCylinder(radius:r, height:r))
				armNode.addChild(node:plate1)
				plate1.position = SCNVector3(0, ffRadius + r, 0)
				plate1.geometry?.firstMaterial?.diffuse.contents = color1

				let plate2		= SCNNode(geometry:SCNCylinder(radius:r*0.75, height:r))
				armNode.addChild(node:plate2)
				plate2.position = SCNVector3(0, ffRadius + 2 * r, 0)
				plate2.geometry?.firstMaterial?.diffuse.contents = color2
//				myGlDrawString(rc, poleStr, -1, inCameraShift, spot2labelCorner, 3)
			}
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["P"] {
			assert(!port.flipped, "P Port in DiscreteTime must be unflipped")
			vew.scn.transform	= SCNMatrix4(0, -ffRadius*2, 0)		//, -port.height - 10
		} else {
			panic("")
		}
	}
//	override func reVew(vew:Vew?, parentVew:Vew?) {
//	  // / Add InspecVc
//		super.reVew(vew:vew, parentVew:parentVew)
//	}

	 //	 MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv					= super.pp(mode, aux)
		if mode == .line {
			if aux.bool_("ppParam") {	// a long line, display nothing else.
				return rv
			}
			rv 					+= "nPoles=\(self.nPoles), tread=\(String(format: "%.3f", self.tread))"
		}
		return rv
	}
}
