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
		if let vectStr		= config["size"] as? String,
		  let vect			= SCNVector3(from:vectStr) {
			size 			= vect
//			config["size"] = nil
		}
		if let vect			= config["size"] as? SCNVector3 {
			size 			= vect
//			config["size"] = nil
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
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.geometry			= SCNBox(width:1.0, height:1.0, length:1.0, chamferRadius:0)
//			scn.geometry		= SCNBox(width:size.x, height:size.y, length:size.z, chamferRadius:0)		// removed 20210709
			rv.name				= "s-Box"
			rv.scale			= size
			rv.color0			= NSColor.green//.change(saturationBy:0.4, fadeTo:0.5)
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Box	: CommonPart {
}
class Sphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Sphere") ?? {
			let rv				= SCNNode(geometry:SCNSphere(radius:1.0))
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-Sphere"
			rv.scale			= size
			rv.color0			= NSColor.green//.change(saturationBy:0.5)
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Cylinder : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Cyl") ?? {
			let rv				= SCNNode(geometry:SCNCylinder(radius:1.0, height:1.0))//(radius:0.5, height:1) (radius:size.x, height:size.z) (radius:0.5, height:1)
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-Cyl"
			rv.scale			= size
			rv.color0			= .green
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Hemisphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-HSphr") ?? {
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-HSphr"
			rv.geometry			= SCNHemisphere(radius:1.0, slice:0)
			rv.scale			= size
			rv.color0			= .green
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class TunnelHood : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Tunl") ?? {
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-Tunl"
			rv.geometry			= SCNTunnelHood(n360:16, height:1, ends:false,
									tSize_:SCNVector3(1,0,1), tRadius:0.5,
									bSize_:SCNVector3(1,0,1), bRadius:0.75)
			rv.scale			= size
			rv.color0			= .green
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class ShapeTest : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-ShapeT") ?? {
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= "s-ShapeT"
			rv.geometry			= SCN3DPictureframe(width:3, length:3, height:0.25, step:0.25)
			rv.scale			= size
			rv.color0			= .purple
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
