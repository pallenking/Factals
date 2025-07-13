//  Net.swift -- A collection of Atoms wired together C2018PAK

import SceneKit

/// A Net is a collection of Atoms wired together
class Net : Atom {		// Atom // Part

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {
			// E.g:		[struc:["a"],of:genBcast,placeMy:stackx,f:0]
		let config				= ["placeMy":"linky"] + config	// default
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/

//		if let a 				= partConfig["parts"] as? [Part] {
//			a.forEach { addChild($0) }						// add children in "parts"
//			partConfig["parts"] = nil
//		}
//		if let parts 			= partConfig["parts"] {
//			let arrayOfParts	= parts as? [Part]
//			assert(arrayOfParts != nil, "Net([parts:<val>]), but <val> is not [Part]")
//			arrayOfParts!.forEach { addChild($0) }				// add children in "parts"
//			partConfig["parts"] = nil
//		}
		if let minSizeStr 		= partConfig["minSize"] as? String {
			if let vect 		= SCNVector3(from:minSizeStr) {
				minSize 		= vect
			}
			partConfig["minSize"] = nil
		}
		if let str 				= partConfig["minHeight"] as? String {
			if let f 			= CGFloat(str) {
				if minSize==nil {
					minSize 	= SCNVector3.zero
				}
				minSize!.y 		= f
			}
//			partConfig["minHeight"] = nil
		}
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{	return [:]	} // None for debug
	 // MARK: - 3.5 Codable
	enum NetsKeys: String, CodingKey {
		case minSize
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)											//		try super.encode(to:container.superEncoder())
		var container 			= encoder.container(keyedBy:NetsKeys.self)

		try container.encode(minSize, forKey:.minSize)
		logSer(3, "Encoded  as? Net         '\(fullName)'")
	}
	  // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:NetsKeys.self)

		minSize 				= try container.decode(SCNVector3?.self, forKey:.minSize)
		logSer(3, "Decoded  as? Net        named  '\(name)' minSize = \(minSize?.pp(.line) ?? "nil")")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Net
//		theCopy.minSize			= self.minSize
//		logSer(3, "copy(with as? Net       '\(fullName)'")
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					  else {	return true				}
		guard let rhs			= rhs as? Net else {	return false			}
		guard super.equalsFW(rhs)				  else {	return false			}
		guard self.minSize		== rhs.minSize else{	return false			}
		return true
	}

	var minSize :SCNVector3? 	= nil
	{	didSet { 	markTreeDirty(bit:.size)  									}	}

	var enable3 : Port?		{	return getPort(named:"E", localUp:false)			}

	   // MARK: - 9.0 make a Vew for a Net
	override func VewForSelf() -> Vew? {
		return NetVew(forPart:self)
	}
	  // MARK: - 9.1 reVew
	override func reVew(vew:Vew?, parentVew:Vew?) {
		let vew : Vew?			= vew
								?? parentVew?.find(part:self, maxLevel:1)	// should do by name?
		 // Tree Height:
		let pVewNet				= parentVew as? NetVew
		let vewNet				= vew       as? NetVew
		vewNet?.heightLeaf		= pVewNet?.heightLeaf ?? 0 + 1
		vewNet?.heightTree		= vewNet? .heightLeaf ?? 0	// layer in current Net //BUGSVILLE

		super.reVew(vew:vew, parentVew:parentVew) //\/\/\/\/\/\/\/\/\/

		 // Tree Height in parent is at least:
		pVewNet?.heightTree 	= max(pVewNet?.heightTree ?? 0, vewNet?.heightTree ?? 0)
	}
	  // MARK: - 9.2 reSize
	override func reSize(vew:Vew) {
		super.reSize(vew:vew) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		 // (this initializes skin to initial size)

		 // Minimum Size:
		if let ms				= minSize {
			vew.bBox.size		|>= ms
		}

		 // Extra GAP around Atom:
		let gsnb				= vew.config("gapTerminalBlock")?.asCGFloat ?? 0.0
		vew.bBox.size			+= 2*gsnb

		 // Net expands skin to encompass repacked contents
		let _					= reSkin(expose:.same, vew:vew)			// xyzzy32
	}
	 // MARK: - 9.3 reSkin
	// / Put full skin onto Net
    // / - Parameter vew_: -- The Vew to use
	override func reSkin(fullOnto vew_:Vew) -> BBox {
		guard let vew 			= vew_ as? NetVew else {
			panic("Net \(vew_.part.pp(.tagClass))'s has Vew \(vew_.pp(.tagClass)), not NetVew")
			return .empty
		}
		 // Color fades:
		let den					= Float(vew.heightTree)
		let ratio : Float		= den != 0 ? Float(vew.heightLeaf)/den : 0.5
		let color0				= typColor(ratio:ratio)		// NSColor.brown

		let bb					= vew.bBox		// existing value
		let size				= bb.size
		let gsnb				= vew.config("gapTerminalBlock")?.asCGFloat ?? 0
		let gsnbMin				= min(size.y, gsnb)
		putNetRing (scnName:"s-HiFrame", top:true)	// Ring at top:
		putNetRing (scnName:"s-LoFrame", top:false)	// Ring at bottom:
		//*debug*/assert(size.y < 30.0, "debug: size.y (=\(size.y)) >= 30.0")
		return vew.bBox				// vew.scnScene.bBox() // Xyzzy44 ** vb

		func putNetRing (scnName:String, top:Bool) {
			let scn				= vew.scn.findScn(named:scnName) as? SCNComment ?? {
				let scn			= SCNComment()//SCNNode()
				scn.name		= scnName
				vew.scn.addChild(node:scn, atIndex:0)
				return scn
			}()
			 // Pictureframe geometry:
			let height			= top ? -gsnbMin : gsnbMin
			scn.geometry 		= SCN3DPictureframe(width:size.x, length:size.z, height:height, step:gsnb) //SCNPictureframe//SCNBox
			scn.position		= top ? bb.centerTop    + .uY * -0.001*height	// N.B: cancels side effect of initial net y=.2
									  : bb.centerBottom + .uY * -0.001*height
			scn.comment			= fmt("PictureFrame(w:%.2f, l:%.2f, h:%.2f step:%.2f)", size.x, size.z, height, gsnb)
			scn.color0			= color0// .withAlphaComponent(0.5)
		}
	}
	override func typColor(ratio r:Float) -> NSColor {
		let ratio				= min(max(r, 0), 1)
		let inside  = NSColor(red:0.7, green:0.0, blue:0.7,  alpha:1)
		let outside = NSColor(red:0.5, green:0.0, blue:0.5,  alpha:1)
		return NSColor(mix:inside, with:ratio, of:outside)
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv 					= super.pp(mode, aux)

		switch mode {
		case .phrase:
			rv 					+= " \(children.count) children, \(ports.count) Ports"
		case .short:
			rv 					+= " Net with \(children.count) children and \(ports.count) Ports"
		case .line:
			rv					+= minSize?.pp(.line, aux) ?? ""
		default:
			nop
		}
		return rv
	}
}

class NetVew : Vew {
	 // Outside has heightLeaf=0, first branch=1, ...
	var heightLeaf	: UInt8		= 0		// height in current tree
	var heightTree	: UInt8		= 0		// max height of whole tree
}
