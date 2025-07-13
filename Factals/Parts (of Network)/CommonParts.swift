// GeomParts -- Parts with Geometric shapes. C2018PAK

import SceneKit

  /// A Box is a simple Atom
 ////////////////////////////////////////////////////////////////////////////
class CommonPart : Part {
	 // MARK: - 1. Class Variables:
	 // MARK: - 2. Object Variables:
	var size : SCNVector3		= SCNVector3(1,1,1)
	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {

		super.init(config)		//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		if let vectStr		= partConfig["size"] as? String,
		  let vect			= SCNVector3(from:vectStr) {
			size 			= vect
//			partConfig["size"] = nil
		}
		if let vect			= config["size"] as? SCNVector3 {
			size 			= vect
//			partConfig["size"] = nil
		}
	}
	 // MARK: - 3.5 Codable
	enum CommonPartKeys: String, CodingKey {
		case size
	}
	 // / Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:CommonPartKeys.self)

		try container.encode(size, forKey:.size)
		logSer(3, "Encoded  as? CommonPart  '\(fullName)'")
	}
	 /// Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 		= try decoder.container(keyedBy:CommonPartKeys.self)

		size 				= try container.decode(SCNVector3.self, forKey:.size)
		logSer(3, "Decoded  as? CommonPart        named  '\(name)' size:\(size.pp(.line))")
	}
//	 // MARK: - 3.6 NSCopying
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! CommonPart
//		theCopy.size			= self.size
//		logSer(3, "copy(with as? CommonPart       '\(fullName)'")
//		return theCopy
//	}
//	 // MARK: - 3.7 Equatable
//	override func equalsFW(_ rhs:Part) -> Bool {
//		guard self !== rhs 							 else {	return true			}
//		guard let rhs			= rhs as? CommonPart else {	return false		}
//		let rv					= super.equalsFW(rhs)
//			&& size				== rhs.size
//		return rv
//	}
 	override func reSize(vew:Vew) {
		vew.bBox				= reSkin(fullOnto:vew)				// xyzzy32 sets up bBox
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Box") ?? {
			let t1				= SCNNode()
			vew.scn.addChild(node:t1, atIndex:0)
			t1.geometry			= SCNBox(width:1.0, height:1.0, length:1.0, chamferRadius:0)
//			scn.geometry		= SCNBox(width:size.x, height:size.y, length:size.z, chamferRadius:0)		// removed 20210709
			t1.name				= "s-Box"
			t1.scale			= size
			t1.color0			= NSColor.green//.change(saturationBy:0.4, fadeTo:0.5)
			return t1
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Box	: CommonPart {
}
class Sphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Sphere") ?? {
			let t1				= SCNNode(geometry:SCNSphere(radius:1.0))
			vew.scn.addChild(node:t1, atIndex:0)
			t1.name				= "s-Sphere"
			t1.scale			= size
			t1.color0			= NSColor.green//.change(saturationBy:0.5)
			return t1
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Cylinder : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Cyl") ?? {
			let scn				= SCNNode(geometry:SCNCylinder(radius:1.0, height:1.0))//SCNCylinder(radius:0.5, height:1)
//			let scn				= SCNNode(geometry:SCNCylinder(radius:size.x, height:size.z))//SCNCylinder(radius:0.5, height:1)
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Cyl"
			scn.scale			= size
			scn.color0			= .green
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Hemisphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-HSphr") ?? {
			let t1				= SCNNode()
			vew.scn.addChild(node:t1, atIndex:0)
			t1.name				= "s-HSphr"
			t1.geometry			= SCNHemisphere(radius:1.0, slice:0)
			t1.scale			= size
			t1.color0			= .green
			return t1
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class TunnelHood : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Tunl") ?? {
			let t1				= SCNNode()
			vew.scn.addChild(node:t1, atIndex:0)
			t1.name				= "s-Tunl"
			t1.geometry			= SCNTunnelHood(n360:16, height:1, ends:false,
									tSize_:SCNVector3(1,0,1), tRadius:0.5,
									bSize_:SCNVector3(1,0,1), bRadius:0.75)
			t1.scale			= size
			t1.color0			= .green
			return t1
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class ShapeTest : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-ShapeT") ?? {
			let t1				= SCNNode()
			vew.scn.addChild(node:t1, atIndex:0)
			t1.name				= "s-ShapeT"
			t1.geometry			= SCN3DPictureframe(width:3, length:3, height:0.25, step:0.25)
			t1.scale			= size
			t1.color0			= .purple
			return t1
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
