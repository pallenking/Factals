////
////  ShaftBundleTap.swift
////  Factals
////
////  Created by Allen King on 11/1/23.
////
//import Foundation
//import SceneKit
//
//class ShaftBundleTap: Generator {
//	let nPoles : Int
//	var tread : Float						// angle of rotation?
//	var armNode : SCNNode?		= nil
//
//	// MARK: Factory
//	override init(_ argCon:FwConfig = [:]){
//		let defaultCon:FwConfig	= ["placeMy":"stacky"]
//		let config				= defaultCon + argCon
//
//		super.init(config) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//
//		  //  WorldModel.swift   Args (if needed)
//		 //  -- Basic discrete time/value data source
//		nPoles 					= localConfig["nPoles"] as? Int ?? 4
//	
//	}
//	
//	required init?(coder: NSCoder) {	fatalError("init(coder:) has not been implemented")	}
//	required init(from decoder: Decoder) throws {	fatalError("init(from:) has not been implemented")	}
//
//	 // MARK: - 5 Groom
//	override func groomModelPostWires(root:RootPart) {
//											super.groomModelPostWires(root:root)
//		  // Connect up our targetBundle:
//		 //
//		guard let pPort			= ports["P"] else {
//			return error("DiscreteTime has no 'P' Port")
//		}
//		if let targPort 		= pPort.portPastLinks {
//			let targetBundle 	= targPort.parent as? FwBundle
//			assert(targetBundle != nil, "targetBundle is nil")
//
//			  // Test new target bundle has both R (for reset) and G (for generate)
//			 //   (Commonly, these are Bindings)
//			targetBundle?.forAllLeafs(
//			{(leaf : Leaf) in									//##BLOCK
//				assert(leaf.port(named:"R") != nil, "\(leaf.fullName): Leaf<\(leaf.type)>: nil 'R' Port")
//				assert(leaf.port(named:"G") != nil, "\(leaf.fullName): Leaf<\(leaf.type)>: nil 'G' Port")
//			})
//		}
//	}
//
///*
//
//		let wmNeeded			= wmArgs.count != 0
//		wmArgs					+= ["n":"wm", "f":1]
//*/
//	 // MARK: - 8. Reenactment Simulator
//	func eventReady() -> String? {	return nil									}
//	func loadTargetBundle(event:FwwEvent) {fatalError("Not implemented")		}
//
//	/*override*/ func simulateDown(up upLocal:Bool) {
//
//		super.simulate(up:upLocal)	// step super FIRST
//
//		if (!upLocal) {
//			let nPoles = self.nPoles
//			var force: Float = 0.0
//
//			for i in 0..<nPoles {
//				var poleITread = self.tread - Float(i)
//				poleITread -= Float(nPoles) * round(poleITread / Float(nPoles))
//
//				assert(poleITread >= -Float(nPoles) / 2.0 && poleITread <= Float(nPoles) / 2.0, "Assertion failed")
//
//				var have: Float = 0.0
//				var forceGeom: Float = 0.0
//
//				if abs(poleITread) < 0.5 {
//					have = 1.0
//					forceGeom = poleITread * 2
//				} else {
//					forceGeom = poleITread < 0.0 ? -1.0 : poleITread > 0.0 ? 1.0 : 0.0
//				}
//
//bug;			let portI = self.getPort(i)
////				portI.valueTake = have
////
////				if portI.valueChanged {
////					"\(portI.fullName16)| ShaftBundleTap: new have (\(have))".ppLog()
////				}
////
////				let wPort = portI.con2?.port
////
////				if wPort?.valueChanged ?? false {
////					"\(portI.fullName16)| ShaftBundleTap: new want (\(wPort.value))".ppLog()
////				}
////
////				let want = wPort.valueGet
////				let dForce = want * forceGeom
////				force += dForce
//			}
//
//			self.tread -= force * 0.05
//
////			if force != 0 {
////				self.brain.kickstartSimulator()
////			}
//		}
//	}
//
//	func getPort(_ i: Int) -> Port {
//		assert(i < 7, "Assertion failed")
//
//		let bitName = "a"//String("abcdefg"[i])
////		guard let targetBundle = self.targetBundle else {
////			fatalError("targetBundle of '\(self.fullNameC)' is nil")
////		}
//
//		guard let port = targetBundle.genPortOfLeafNamed(bitName) as? Port else {
//			fatalError("\(self.fullName): didn't find Port '\(bitName)', or it has no 'G' port")
//		}
//
//		return port
//	}
//
//	// MARK: 3D Support
////	func gapAround(_ v: View) -> Bounds3f {
////		let r = self.brain.bitRadius
////		return Bounds3f(-5 * r, -5 * r, -5 * r, 5 * r, 5 * r, 5 * r)
////	}
//
//
//	 // MARK: - 9.3 reSkin
//	var height : CGFloat	{		return 1									}
//	override func reSkin(fullOnto vew:Vew) -> BBox  {
//		let scn					= vew.scn.find(name:"s-Atom") ?? {
//			let scn				= SCNNode()
//			vew.scn.addChild(node:scn, atIndex:0)
//			scn.name			= "s-Atom"
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
//
//
////		float treadInDegrees = 360 * self.tread / self.nPoles;
////		glRotatef(treadInDegrees, 1,0,0);
////
////		rc.color = colorRed;
////		glTranslatef(0, 0, radius/2);
////		myGlSolidCylinder(radius/10, radius, 16, 1);	// (radius, length, ...)
////		glTranslatef(0, 0, -radius/2);
////
////		rc.color = colorBlack;
////		glRotatef(90, 0,1,0);
////		glutSolidTorus(radius/6, radius, 3, self.nPoles*4);// innerRadius, outerRadius, nsides, nRings
//
//
//
//		} ()
//		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
//	}
//	 // MARK: - 9.4 rePosition
//	override func rePosition(portVew vew:Vew) {
//		let port				= vew.part as! Port
//		if port === ports["P"] {
//			assert(!port.flipped, "P Port in DiscreteTime must be unflipped")
//			vew.scn.transform	= SCNMatrix4(0, -port.height,0)
//		}
//		else if port === ports["S"] {
//			vew.scn.transform	= SCNMatrix4(0, height + port.height, 0, flip:true)
//		}
//		else {
//			super.rePosition(portVew:vew)
//		}
//	}
//	override func reVew(vew:Vew?, parentVew:Vew?) {
//	  // / Add InspecVc
//		super.reVew(vew:vew, parentVew:parentVew)
//		 // inspecNibName --> automatically add an InspecVc panel
//		// (might move into -postBuild
//		if inspecNibName != nil && !inspecIsOpen! {
//			panic()
//			//[self.brain.simNsWc.inspecVcs2open addObject:mustBe(Vew, view)]
//		}
//		self.inspecIsOpen = true		// only open once
//	}
//
//
//	// MARK: 3D Display
////	override func drawFullView(_ v: View, context rc: RenderingContext) {
////		let r = self.brain.bitRadius
////		let siz = v.bounds.size()
////		let radius = 2 * r
////
////		glPushMatrix()
////		glRotatef(90, 0, 1, 0)
////		glRotatef(90, 1, 0, 0)
////
////		for i in 0..<self.nPoles {
////			glPushMatrix()
////			let poleInDegrees = 360 * Float(i) / Float(self.nPoles)
////			glRotatef(poleInDegrees, 1, 0, 0)
////			glTranslatef(0, 0, radius + r)
////
////			let portI = self.getPort(i)
////
////			rc.color = colorOf2Ports(0.0, portI.connectedTo.value, 0)
////			myGlSolidCylinder(r, r / 2, 16, 1)
////
////			glTranslatef(0, 0, r / 2)
////			rc.color = colorOf2Ports(portI.value, 0.0, 0)
////			myGlSolidCylinder(r, r / 2, 16, 1)
////
////			glPushMatrix()
////			let inCameraShift = Vector3f(0.0, 0.0, 3)
////			let spot2labelCorner = Vector2f(0.5, 0.5)
////			rc.color = colorBlue
////			let poleChar = Character(UnicodeScalar(97 + i)!)
////			let poleStr = String(poleChar)
////			myGlDrawString(rc, poleStr, -1, inCameraShift, spot2labelCorner, 3)
////			glPopMatrix()
////
////			glPopMatrix()
////		}
////
////		let treadInDegrees = 360 * self.tread / Float(self.nPoles)
////		glRotatef(treadInDegrees, 1, 0, 0)
////
////		rc.color = colorRed
////		glTranslatef(0, 0, radius / 2)
////		myGlSolidCylinder(radius / 10, radius, 16, 1)
////		glTranslatef(0, 0, -radius / 2)
////
////		rc.color = colorBlack
////		glRotatef(90, 0, 1, 0)
////		glutSolidTorus(radius / 6, radius, 3, self.nPoles * 4)
////
////		glPopMatrix()
////	}
//
//	// MARK: PrettyPrint
//
//	override func pp1line(_ aux: Any) -> String {
//		var result = super.pp1line(aux)
//		result += "nPoles=\(self.nPoles), tread=\(String(format: "%.3f", self.tread))"
//		return result
//	}
//}
