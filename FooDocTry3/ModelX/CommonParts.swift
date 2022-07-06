// GeomParts -- Parts with Geometric shapes. C2018PAK

import SceneKit

  /// A Box is a simple Atom
 ////////////////////////////////////////////////////////////////////////////
class CommonPart : Part {
	 // MARK: - 1. Class Variables:
	// Not needed: func equalsPart(_ part:Part) -> Bool

	 // MARK: - 2. Object Variables:
	var size : SCNVector3		= SCNVector3(1,1,1)

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {

		super.init(config)		//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		if let vectStr		= localConfig["size"] as? String,
		  let vect			= SCNVector3(from:vectStr) {
			size 			= vect
			localConfig["size"] = nil
		}
		if let vect			= config["size"] as? SCNVector3 {
			size 			= vect
			localConfig["size"] = nil
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
		atSer(3, logd("Decoded  as? CommonPart        named  '\(nam)' size:\(size.pp(.line))"))
	}
	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : CommonPart		= super.copy(with:zone) as! CommonPart
		theCopy.size			= self.size
		atSer(3, logd("copy(with as? CommonPart       '\(fullName)'"))
		return theCopy
	}
	 // MARK: - 3.7 Equitable
	func varsOfCommonPartEq(_ rhs:Part) -> Bool {
		guard let rhsAsCommonPart	= rhs as? CommonPart else {	return false		}
		return size    			== rhsAsCommonPart.size
	}
//	override func equalsPart(_ part:Part) -> Bool {
//		return	super.equalsPart(part) && varsOfCommonPartEq(part)
//	}
 
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Box") ?? {
			let scn				= SCNNode()
			scn.geometry		= SCNBox(width:size.x, height:size.y, length:size.z, chamferRadius:0)
			scn.name			= "s-Box"
			scn.scale			= size
			scn.color0			= NSColor.green//.change(saturationBy:0.4, fadeTo:0.5)
			vew.scn.addChild(node:scn, atIndex:0)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
class Box	: CommonPart {
}
class Sphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Sphere") ?? {
			let scn				= SCNNode(geometry:SCNSphere(radius:1.0))
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Sphere"
			scn.scale			= size
			scn.color0			= NSColor.green//.change(saturationBy:0.5)
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
class Cylinder : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Cyl") ?? {
			let scn				= SCNNode(geometry:SCNCylinder(radius:size.x, height:size.z))//SCNCylinder(radius:0.5, height:1)
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Cyl"
			scn.scale			= size
			scn.color0			= .green
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
class Hemisphere : CommonPart {
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-HSphr") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-HSphr"
			scn.geometry		= SCNHemisphere(radius:1, slice:0)
			scn.scale			= size
			scn.color0			= .green
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
class TunnelHood : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Tunl") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Tunl"
			scn.geometry		= SCNTunnelHood(n360:16, height:1, ends:false,
									tSize_:SCNVector3(1,0,1), tRadius:0.5,
									bSize_:SCNVector3(1,0,1), bRadius:0.75)
			scn.scale			= size
			scn.color0			= .green
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
class ShapeTest : CommonPart {
	 // / - used to test only
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-ShapeT") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-ShapeT"
			scn.geometry		= SCN3DPictureframe(width:3, length:3, height:0.25, step:0.25)
			scn.scale			= size
			scn.color0			= .purple
			return scn
		} ()
		return scn.bBox() * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
