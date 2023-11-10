//
//  ShaftBundleTap.swift
//  Factals
//
//  Created by Allen King on 11/1/23.
//
import SceneKit

class ShaftBundleTap : BundleTap { //Generator {
	let nPoles : Int
	var tread : Float			= 0.0				// angle of rotation?
	var armNode : SCNNode?		= nil

	// MARK: Factory
	override init(_ config:FwConfig = [:]){
		let extraConfig:FwConfig = ["placeMy":"stacky"]
		let sConfig				= extraConfig + config

		  //  WorldModel.swift   Args (if needed)
		 //  -- Basic discrete time/value data sources
		nPoles 					= sConfig["nPoles"] as? Int ?? 4

		super.init(sConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
	}
	
	required init?(coder: NSCoder) {	fatalError("init(coder:) has not been implemented")	}
	required init(from decoder: Decoder) throws {	fatalError("init(from:) has not been implemented")	}

	  // MARK: - 3.1 Port Factory
 	override func hasPorts() -> [String:String]	{
		return ["P":"c"]			// ignore super.hasPorts(), BundleTao has "S"
 	}

	 // MARK: - 5 Groom
	override func groomModelPostWires(root:RootPart) {
											super.groomModelPostWires(root:root)
		  // Connect up our targetBundle:
		 //
		guard let pPort			= ports["P"] else {
			return error("DiscreteTime has no 'P' Port")
		}
		guard let targPort 		= pPort.portPastLinks,
		  let targetBundle 		= targPort.parent as? FwBundle else {
			print("targetBundle is nil")
			return
		}
		  // Test new target bundle has both R (for reset) and G (for generate)
		 //   (Commonly, these are Bindings)
		targetBundle.forAllLeafs(
		{(leaf : Leaf) in									//##BLOCK
			assert(leaf.port(named:"R") != nil, "\(leaf.fullName): Leaf<\(leaf.type)>: nil 'R' Port")
			assert(leaf.port(named:"G") != nil, "\(leaf.fullName): Leaf<\(leaf.type)>: nil 'G' Port")
		})
	}
/*

		let wmNeeded			= wmArgs.count != 0
		wmArgs					+= ["n":"wm", "f":1]
*/
	 // MARK: - 8. Reenactment Simulator
	func eventReady() -> String? {	return nil									}
	override func loadTargetBundle(event:FwwEvent) {fatalError("Not implemented") }

	/*override*/ func simulateDown(up upLocal:Bool) {

		super.simulate(up:upLocal)	// step super FIRST

		if (!upLocal) {
			let nPoles = self.nPoles
			var force: Float = 0.0

			for i in 0..<nPoles {
bug;			var poleITread = self.tread - Float(i)
				poleITread -= Float(nPoles) * round(poleITread / Float(nPoles))

				assert(poleITread >= -Float(nPoles) / 2.0 && poleITread <= Float(nPoles) / 2.0, "Assertion failed")

				var have: Float = 0.0
				var forceGeom: Float = 0.0

				if abs(poleITread) < 0.5 {
					have = 1.0
					forceGeom = poleITread * 2
				} else {
					forceGeom = poleITread < 0.0 ? -1.0 : poleITread > 0.0 ? 1.0 : 0.0
				}

				let portI = self.getPort(i)
//				portI.valueTake = have
//
//				if portI.valueChanged {
//					"\(portI.fullName16)| ShaftBundleTap: new have (\(have))".ppLog()
//				}
//
//				let wPort = portI.con2?.port
//
//				if wPort?.valueChanged ?? false {
//					"\(portI.fullName16)| ShaftBundleTap: new want (\(wPort.value))".ppLog()
//				}
//
//				let want = wPort.valueGet
//				let dForce = want * forceGeom
//				force += dForce
			}

			self.tread -= force * 0.05

//			if force != 0 {
//				self.brain.kickstartSimulator()
//			}
		}
	}

	func getPort(_ i: Int) -> Port? {
		assert(i < 7, "Assertion failed")
		let bitName 			= String(Character(UnicodeScalar(Int(UnicodeScalar("a").value) + i - 1)!))

		if let targetBundle,
		  let port 				= targetBundle.genPortOfLeafNamed(bitName) as? Port {
			return port
		}
		return nil
	}


	 // MARK: - 9.3 reSkin
	var height : CGFloat	{ return 1.0		}	// 5
	var width  : CGFloat	{ return 6.0		}
	var ffRadius		= CGFloat(4.0)

	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-ShBT") ?? {
														//	let scn				= SCNNode()
														//	vew.scn.addChild(node:scn, atIndex:0)
														//	scn.name			= "s-ShBT"
														//	//scn.geometry		= SCNBox(width:0.2, height:0.2, length:0.2, chamferRadius:0.01)	//191113
														//	scn.geometry		= SCNBox(width:width, height:height, length:3, chamferRadius:0.4)
														//	//scn.position		= SCNVector3(1.0, height/2, 0)
														//	scn.position		= SCNVector3(1.5, height/2, 0)
														//	let color			= vew.scn.color0
														//	//let color			= NSColor.blue//.gray//.white//NSColor("lightpink")!//NSColor("lightslategray")!
														//	scn.color0			= color.change(saturationBy:0.3, fadeTo:0.5)

			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-SBT1"

			 // Shaft of rotation
			let shaftNode 		= SCNNode(geometry:SCNBox(width:0.5, height:1, length:7, chamferRadius:0.01))
			scn.addChild(node:shaftNode)
			shaftNode.color0	= NSColor("darkgreen")!//.orange
 			shaftNode.rotation 	= SCNVector4(0, 0, 1, Float.pi/8)//0)//
			 // Arm to a Pole
			let armNode 		= SCNNode(geometry: SCNCylinder(radius:0.1, height:ffRadius))
			shaftNode.addChild(node:armNode)
			armNode.position.x	= ffRadius / 2
			armNode.color0		= NSColor.orange	//("darkgreen")!//
 			armNode.rotation 	= SCNVector4(0, 0, 1, Float.pi/2)
			 // Arm to a Pole
			let arrowLen		= 2.0
			let pointNode 		= SCNNode(geometry: SCNCone(topRadius:1, bottomRadius:0, height:arrowLen))
			shaftNode.addChild(node:pointNode)
			pointNode.position.x	= ffRadius - arrowLen/2
			pointNode.color0		= NSColor.red
 			pointNode.rotation 	= SCNVector4(0, 0, 1, Float.pi/2)

			 // Poles
			let r				= localConfig["bitRadius"]?.asCGFloat ?? 1.0
			for i in 0..<self.nPoles {
				let poleInDegrees = 360 * Float(i) / Float(self.nPoles)
				let portI 		= getPort(i)
				let color1		= NSColor.orange//colorOf2Ports(0.0, portI.con2?.port?.value, 0)
												//colorOf2Ports(localValUp:0.0, localValDown:portI!.con2?.port?.value ?? -1, downInWorld:false)		//
				let color2		= NSColor.brown//colorOf2Ports(portI.value, 0.0, 0)

				let armNode 	= SCNNode()//geometry: SCNBox(width: r/2, height: r*15, length: r/2, chamferRadius: 0.1)) 				//)//
				scn.addChild(node:armNode)
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
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}

	 // MARK: - 9.3 reSkin
//	//var height : CGFloat	{		return 2									}
//	func reSkinXX(fullOnto vew:Vew) -> BBox  {
//		let scn					= vew.scn.find(name:"s-ShBT") ?? {
//			let scn				= SCNNode()
//			vew.scn.addChild(node:scn, atIndex:0)
//			scn.name			= "s-ShBT"
//
//			 // Arm
//			let armNode 		= SCNNode(geometry: SCNCylinder(radius:0.2, height: 7))
//			scn.addChild(node:armNode)
////			scn.geometry		= SCNBox(width:7, height:height, length:7, chamferRadius:1)
/////			scn.geometry		= SCNCylinder(radius:3, height:height)
////			scn.position.y		= height/2
////			scn.color0			= NSColor("darkgreen")!//.orange
//
//			 // Poles
//			let r					= localConfig["bitRadius"]?.asCGFloat ?? 1.0
//			let radius = 2*r;
//			for i in 0..<self.nPoles {
//				let poleInDegrees = 360 * Float(i) / Float(self.nPoles)
//				let cylinderNode = SCNNode(geometry: SCNCylinder(radius: CGFloat(r), height: CGFloat(r/2)))
//				cylinderNode.position = SCNVector3(0, 0, radius + r)
//				cylinderNode.rotation = SCNVector4(1, 0, 0, GLKMathDegreesToRadians(poleInDegrees))
//				// Set the material properties for the cylinder here.
//	//			cylinderNode.geometry?.firstMaterial?.diffuse.contents = colorOf2Ports(0.0, portI.connectedTo.value, 0)
//				scn.addChild(node:cylinderNode)
//			}
//			return scn
//		} ()
//		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb

//		float treadInDegrees = 360 * self.tread / self.nPoles;
//		glRotatef(treadInDegrees, 1,0,0);
//
//		rc.color = colorRed;
//		glTranslatef(0, 0, radius/2);
//		myGlSolidCylinder(radius/10, radius, 16, 1);	// (radius, length, ...)
//		glTranslatef(0, 0, -radius/2);
//
//		rc.color = colorBlack;
//		glRotatef(90, 0,1,0);
//		glutSolidTorus(radius/6, radius, 3, self.nPoles*4);// innerRadius, outerRadius, nsides, nRings
//	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["P"] {
			assert(!port.flipped, "P Port in DiscreteTime must be unflipped")
			vew.scn.transform	= SCNMatrix4(0, -ffRadius*2, 0)		//, -port.height - 10
		}
		else if port === ports["S"] {
			bug;vew.scn.transform	= SCNMatrix4(0, height + port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}
	override func reVew(vew:Vew?, parentVew:Vew?) {
	  // / Add InspecVc
		super.reVew(vew:vew, parentVew:parentVew)
		 // inspecNibName --> automatically add an InspecVc panel
		// (might move into -postBuild
//		if inspecNibName != nil && !inspecIsOpen! {
//			panic()	//[self.brain.simNsWc.inspecVcs2open addObject:mustBe(Vew, view)]
//		}
//		self.inspecIsOpen = true		// only open once
	}


	// MARK: 3D Display
//	override func drawFullView(_ v: View, context rc: RenderingContext) {
//		let r = self.brain.bitRadius
//		let siz = v.bounds.size()
//		let radius = 2 * r
//
//		glPushMatrix()
//		glRotatef(90, 0, 1, 0)
//		glRotatef(90, 1, 0, 0)
//
//		for i in 0..<self.nPoles {
//			glPushMatrix()
//				let poleInDegrees = 360 * Float(i) / Float(self.nPoles)
//				glRotatef(poleInDegrees, 1, 0, 0)
//				glTranslatef(0, 0, radius + r)
//
//				let portI = self.getPort(i)
//
//				rc.color = colorOf2Ports(0.0, portI.connectedTo.value, 0)
//				myGlSolidCylinder(r, r / 2, 16, 1)
//
//				glTranslatef(0, 0, r / 2)
//				rc.color = colorOf2Ports(portI.value, 0.0, 0)
//				myGlSolidCylinder(r, r / 2, 16, 1)
//
//				glPushMatrix()
//					let inCameraShift = Vector3f(0.0, 0.0, 3)
//					let spot2labelCorner = Vector2f(0.5, 0.5)
//					rc.color = colorBlue
//					let poleChar = Character(UnicodeScalar(97 + i)!)
//					let poleStr = String(poleChar)
//					myGlDrawString(rc, poleStr, -1, inCameraShift, spot2labelCorner, 3)
//				glPopMatrix()
//			glPopMatrix()
//		}
//
//		let treadInDegrees = 360 * self.tread / Float(self.nPoles)
//		glRotatef(treadInDegrees, 1, 0, 0)
//
//		rc.color = colorRed
//		glTranslatef(0, 0, radius / 2)
//		myGlSolidCylinder(radius / 10, radius, 16, 1)
//		glTranslatef(0, 0, -radius / 2)
//
//		rc.color = colorBlack
//		glRotatef(90, 0, 1, 0)
//		glutSolidTorus(radius / 6, radius, 3, self.nPoles * 4)
//
//		glPopMatrix()
//	}

	// MARK: PrettyPrint

	 //	 MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
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
