// Leaf.swift -- Terminal element of a FwBundle C2015PAK

import SceneKit

// A Leaf is both:
//		The mechanism for a bit in some FwBundle in the machine
//		A prototype for making said mechanisms
// N.B: There is an inherent circularity in this definition:
// 181011:	1. Factory explicitly makes any kind of Part, we use it for Leafs in Bundles

/* ?? Find Home
	Access Ports:
		P	Primary Port of Atom
		S	Secondary Port of Atom
		T	Terciary, TimeDel, ...
		M	Mode
		L	Latch
 */

 /// A Leaf is a functional terminal of a FwBundle
class Leaf : FwBundle {			// perhaps : Atom is better 200811PAK

	 // MARK: - 2. Object Variables:
//	var type : LeafKind
//	var type : String 				= "undefined"	// for printout/debug
//	var bindings 					= [String:String]()

	 // MARK: - 3. Part Factory
//	convenience init(_  leafKind:LeafKind, fwConfig:FwConfig = [:], bindings:FwConfig = [:], parts:[Part]) {   // A WAY
//	convenience init(of leafKind:LeafKind, bindings:FwConfig = [:], parts:[Part], leafConfig:FwConfig = [:]) { // OLD WAY
	convenience init(bindings:FwConfig = [:], parts:[Part], leafConfig:FwConfig = [:]) { 	//leafKind:leafKind,  // NEW WAY
		let xtraConfig:FwConfig = ["parts":parts, "bindings":bindings]		// /*"type":type,*/
		self.init(leafConfig:leafConfig+xtraConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\xtraConfig+leafConfig
	}
	    /// Terminal element of a FwBundle
	   /// - parameter leafKind: -- of terminal Leaf
	  /// - parameter config_: -- to configure Leaf
	 /// ## --- bindings: FwConfig -- binds external Ports to internal Ports by name
	init(leafConfig leafConfig_:FwConfig = [:]) {//override		//leafKind:LeafKind = .genAtom,
		let leafConfig			= ["placeMy":"linky"] + leafConfig_
		//type					= leafKind//.rawValue//leafKind!.rawValue
		super.init(leafConfig)//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	 // MARK: - 3.5 Codable
	enum LeafsKeys: String, CodingKey {
		case type
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:LeafsKeys.self)

//		try container.encode(type, forKey:.type)
		atSer(3, "Encoded  as? Leaf        '\(fullName)'")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 		= try decoder.container(keyedBy:LeafsKeys.self)
//		type	 			= try container.decode(LeafKind.self, forKey:.type)
		try super.init(from:decoder)
		atSer(3, "Decoded  as? Leaf       named  '\(name)'")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Leaf
//	//	theCopy.type			= self.type
//		atSer(3, logd("copy(with as? Leaf       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					   else {	return true				}
		guard let rhs			= rhs as? Leaf else {	return false 			}
		let rv					= super.equalsFW(rhs)
	//		&& type				== rhs.type
		return rv
	}
	// MARK: - 4.1 Part Properties
//	override func apply(prop:String, withVal val:FwAny?) -> Bool {
//		 // Leafs get sound names from the .nib file:
//		if prop == "sound" {	// e.g. "sound:di-sound" or
//bug		//	if let sndPPort		= port(named:"SND"),
//		//	  let sndAtom		= sndPPort.atom as? SoundAtom,
//		//	  let v				= val as? String
//		//	{
//		//		sndAtom.sounds	= [v]
//		//	}
//		//	else {
//		//		panic()
//		//	}
//		}
//		if prop == "sounds" {
//bug		}
//		return super.apply(prop:prop, withVal:val)
//	}
	  // MARK: - 4.5 Iterate (forAllLeafs)
	func port4leafBinding(name:String) -> Part? {
bug;//	let binding 			= self.bindings?[name]
	//	if let path				= binding as? Path,
	//	  let p					= resolveInwardReference(path, openingDown:false, except:nil)  {
	//		return p
	//	}
		return nil;			// not found
	}
	func resolveInwardReference(_ path:Path, openingDown downInSelf:Bool, except:Part?) -> Part? {
bug;	return nil
//		// path matches self's name
//		if path.atomName == self {		// Terminal's name (w.o. Port) matches
//			var rv : Part? 		= nil
//								//
//			  //////////// Is named port a BINDING? ///////////////////
//			 //
//			if let bindingStr 	= self.bindings?[path.namePort] {
//				let bindingPath = Path(withName:bindingStr)		// Look inside Leaf
//				
//				atBld(5, logd("   MATCHES Inward check as Leaf '%@'\n   Search inward for binding[%@]->'%@'",
//								  self.fullName, path.namePort, bindingPath.pp()))
//
//				  // Look that name up
//				 //XX		rv=[self resolveInwardReference:bindingPath openingDown:downInSelf except:nil]
//				for elt in parts {
////					if (coerceTo(NSNumber, elt))
////						continue;
//					
//					// Look up internal name
//					let downInElt = !downInSelf == !elt.flipped	// was ^
//					if let rv	= elt.resolveInwardReference(bindingPath, openingDown:downInSelf, except:nil) {
//						break;					// found
//					}
//				}
//			}
//			else if path.namePort.count == 0 { 	// empty string "" in bindings has priority
//				panic("wtf")
//			} //			rv = self;								// found	(why?)
//			
//			if let rv {
//				atBld(5, "   MATCHES Inward check as Leaf '\(fullName)'")
//			}
//			return rv;
//		}
//		atBld(5, "   FAILS   Inward check as Leaf '\(fullName)'")
//		
//		// Didn't match as Leaf, try normal match:
//		return super.resolveInwardReference(path, openingDown:downInSelf, except:except)
	}

	 // MARK: - 9.2 reSize
	override func reSize(vew:Vew) {
		super.reSize(vew:vew) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		 // Minimum Size:
		if let ms				= minSize {
			vew.bBox.size		|>= ms
		}
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Leaf") ?? {
//		let scn					= vew.scnRoot.find(name:"s-Leaf") ?? {
			let scn				= SCNNode()
			vew.scnRoot.addChild(node:scn, atIndex:0)
			scn.name			= "s-Leaf"
			return scn
		}()

		 /// Purple Ring at bottom:
		let bb					= vew.bBox		// | BBox(size:0.5, 0.5, 0.5)
		let gsnb				= vew.config("gapTerminalBlock")?.asCGFloat ?? 0.0
		// thrashes:
		let bbs					= bb.size
		scn.geometry 			= SCN3DPictureframe(width:bbs.x, length:bbs.z, height:gsnb, step:gsnb) //SCNPictureframe(width:bb.size.x, length:bb.size.z, step:gsnb)//bb.size.x/2)//0.1) //*gsnb/2)
		scn.position			= bb.centerBottom //+ .uY * gsnb
		scn.color0				= .red
		return bb						// vew.scnScene.bBox()//scnScene.bBox()// Xyzzy44 ** bb
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 				= super.pp(mode, aux)
		if mode == .line {
			if aux.bool_("ppParam") {			// Ad Hoc: if printing Param's,
				return rv							// don't print extra
			}
			rv				+= "type:.(type) "	// print type and bindings:
			rv				+= "bindings:\(bindings?.pp(.line, aux) ?? "none") "
		}
		return rv
	}
}
