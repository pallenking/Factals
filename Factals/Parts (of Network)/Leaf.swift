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
	convenience init(bindings:FwConfig = [:], parts:[Part], leafConfig:FwConfig = [:]) { 	//leafKind:leafKind,
		let xtraConfig:FwConfig = ["parts":parts, "bindings":bindings]		// /*"type":type,*/
		self.init(leafConfig:leafConfig + xtraConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\xtraConfig+leafConfig
	}
	    /// Terminal element of a FwBundle
	   /// - parameter leafKind: -- of terminal Leaf
	  /// - parameter XXX config_: -- to configure Leaf
	 /// ## --- bindings: FwConfig -- binds external Ports to internal Ports by name
	init(leafConfig lc:FwConfig = [:]) {//override		//leafKind:LeafKind = .genAtom,
		let leafConfig			= ["placeMy":"linky"] + lc
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
		logSer(3, "Encoded  as? Leaf        '\(fullName)'")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 		= try decoder.container(keyedBy:LeafsKeys.self)
//		type	 			= try container.decode(LeafKind.self, forKey:.type)
		try super.init(from:decoder)
		logSer(3, "Decoded  as? Leaf       named  '\(name)'")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Leaf
//	//	theCopy.type			= self.type
//		logSer(3, "copy(with as? Leaf       '\(fullName)'")
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
	  // MARK: - 4.5 Iterate (forAllLeafs)
	func port4leafBinding(name:String) -> Part? {
		guard let binding		= bindings?[name] else { return nil 			}
		return findPart(binding:Path(withName:binding), openingDown:false, except:nil)
	}
	override func findPart(binding:Path, openingDown downInSelf:Bool, except:Part?=nil) -> Part? {
		 // At end of path?	( Terminal's name (w.o. Port) matches self )
//		if binding.atomName == self.name {

			 // ////////// Is named port a BINDING? ///////////////////
			var rv : Part? 		= nil
			if let bindingStr 	= bindings?[binding.portName!] {
				let bindingPath = Path(withName:bindingStr)		// Look inside Leaf
				logBld(5, "   MATCHES Inward check as Leaf '%@'\n   Search inward for binding[%@]->'%@'",
								  self.fullName, binding.portName!, bindingPath.pp())
				 // Look that name up
				for elt in parts {
					// Look up internal name
					let downInElt = !downInSelf == !elt.flipped	// was ^
					if let elt 	= elt as? Atom,
					   let rv1	= elt.findPart(binding:bindingPath, openingDown:downInElt) {	//downInSelf
						rv		= rv1
						break;					// found
					}
				}
			}
			else if binding.portName!.count == 0 { 	// empty string "" in bindings has priority
				panic("wtf")
			} //			rv = self;								// found	(why?)
			
			if let rv {
				logBld(5, "   MATCHES Inward check as Leaf '\(fullName)'")
				return rv
			}
			logBld(5, "   FAILS   Inward check as Leaf '\(fullName)'")
			return nil
//		}
		  // Didn't match as Leaf, try normal match:
		return super.findPart(binding:binding, openingDown:downInSelf, except:except)
	}
	 // MARK: - 4.7 Editing Network

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
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv 				= super.pp(mode, aux)
		if mode == .line {
			if aux.bool_("ppParam") {			// Ad Hoc: if printing Param's,
				return rv							// don't print extra
			}
		}
		return rv
	}
 }
