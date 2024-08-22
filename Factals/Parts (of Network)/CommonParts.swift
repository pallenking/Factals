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
			partConfig["size"] = nil
		}
		if let vect			= config["size"] as? SCNVector3 {
			size 			= vect
			partConfig["size"] = nil
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
		atSer(3, logd("Encoded  as? CommonPart  '\(fullName)'"))
	}
	 /// Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 		= try decoder.container(keyedBy:CommonPartKeys.self)

		size 				= try container.decode(SCNVector3.self, forKey:.size)
		atSer(3, logd("Decoded  as? CommonPart        named  '\(name)' size:\(size.pp(.line))"))
	}
//	 // MARK: - 3.6 NSCopying
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! CommonPart
//		theCopy.size			= self.size
//		atSer(3, logd("copy(with as? CommonPart       '\(fullName)'"))
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
		let scn					= vew.scnRoot.find(name:"s-Box") ?? {
			let scn				= SCNNode()
			scn.geometry		= SCNBox(width:1.0, height:1.0, length:1.0, chamferRadius:0)
//			scn.geometry		= SCNBox(width:size.x, height:size.y, length:size.z, chamferRadius:0)		// removed 20210709
			scn.name			= "s-Box"
			scn.scale			= size
			scn.color0			= NSColor.green//.change(saturationBy:0.4, fadeTo:0.5)
			vew.scnRoot.addChild(node:scn, atIndex:0)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Box	: CommonPart {
}
class Sphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.find(name:"s-Sphere") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1.0))
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-Sphere"
			scn.scale			= size
			scn.color0			= NSColor.green//.change(saturationBy:0.5)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class Cylinder : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.find(name:"s-Cyl") ?? {
			let scn				= SCNNode(geometry:SCNCylinder(radius:1.0, height:1.0))//SCNCylinder(radius:0.5, height:1)
//			let scn				= SCNNode(geometry:SCNCylinder(radius:size.x, height:size.z))//SCNCylinder(radius:0.5, height:1)
			vew.scnRoot.addChild(node:scn, atIndex:0)
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
		let scn					= vew.scnRoot.find(name:"s-HSphr") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-HSphr"
			scn.geometry		= SCNHemisphere(radius:1.0, slice:0)
			scn.scale			= size
			scn.color0			= .green
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class TunnelHood : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.find(name:"s-Tunl") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-Tunl"
			scn.geometry		= SCNTunnelHood(n360:16, height:1, ends:false,
									tSize_:SCNVector3(1,0,1), tRadius:0.5,
									bSize_:SCNVector3(1,0,1), bRadius:0.75)
			scn.scale			= size
			scn.color0			= .green
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scnScene.bBox()	// Xyzzy44 vsb
	}
}
class ShapeTest : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scnRoot.find(name:"s-ShapeT") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-ShapeT"
			scn.geometry		= SCN3DPictureframe(width:3, length:3, height:0.25, step:0.25)
			scn.scale			= size
			scn.color0			= .purple
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
