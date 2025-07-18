//  Link.swift -- To Connect ports of Atoms C2018PAK

import SceneKit
//import Port.swift
/*
	Experiment:							Vew:					]
	'---P--' or sec			pCon2Port_	  *			.origin		]
		|			  portConSpot()	|\	  ^						]
	.---S--.						  \	  |						]
   (		upCPort					->	sCon2Vew				]
   {		)													]
   (  Link 	)													]
   {		)													]
   (		downCPort				->	pCon2Vew				]
	'---P--'						  /	  |						]
		|			  portConSpot()	|/_   v						]
	.---S--. or sec			pCon2Port	  *			.origin		]
*/				
enum LinkSkinType : String, CaseIterable, Codable	{
	case invalid		// causes error
	case invisible		// displays nothing		// BUG: shows Link's Ports
	case ray			// black line
	case tube			// Cylinder
	case dual			// Shows red and green
}
/*
	*-l0    . . . . . xform = I 	(Lives at parent's origin)
	| s-Link  . . . . xform = map from (0,1) to link ends (S,P)
	| | s-Ray   . . . Cube with wallpaper showing colors
	| | s-Paint . . . A line
	| *-S     . . . . S end
	| | s-LnkEn. . .
	| *-P     . . . . P end
	| | s-LnkEn. . .
 */
class Link : Atom {

	 // MARK: - 1. Class Variables:

	 // would like useBlane==true, but plane cannot have a Z component
	static var linkNo 			= 1			// elim->hash

	 // MARK: - 2. Object Variables:
	 // MARK: - specify type of line:
	var linkSkinType : LinkSkinType
	let usePlane	  			= false		// true is BROKEN //false//true//
	/// See notes at end
	var   pUpCPort : LinkPort!	= nil
	var sDownCPort : LinkPort!	= nil

	var minColorVal	: Float		= 0
	var maxColorVal	: Float		= 1

	 // MARK: - 3. Part Factory
	 /// Make a link
	 /// @class xxxxxxx ???
	 /// @abstract yy yy yy ???
	 ///   - config		- 	configuration hash
	override init(_ config:FwConfig = [:]) {

		 // Link type of display.  Several type names are recognized:
		let skinTypeAny : FwAny =
					config["linkSkinType"]	??
					config["type"] 			??		// short name
					config["t"]				??		// shorter name
					"dual"							// default
		guard let skinTypeString = skinTypeAny as? String,
		  let stStr				= LinkSkinType(rawValue:skinTypeString) else {
			debugger("Configuration for 'linkSkinType', 'type' or 't' has illegal value '\(skinTypeAny.pp())'")
		}
		linkSkinType 			= stStr

		super.init(config) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		  // Conveyor Ports to delay and display the data
		 // A Link uses special Ports with a built in conveyor:
		let greenOnLeft			= trueF//falseF/trueF/			//  (1, 0) : (2,300)

		let cUp					= config + ["name":"P"]//(2,300):(1, 0)
		let p0	/* (x, y) */	= greenOnLeft ? (1, 0) : (imageWidth-1, imageHeight)
		pUpCPort 				= LinkPort(cUp, i0:p0, color0:.green)
		addChild(pUpCPort)				//pUpCPort.parent = self
		ports["P"]				= pUpCPort

		let cDn					= config + ["name":"S", "f":1]
		let p1					= greenOnLeft ? (imageWidth-1,imageHeight) : (1, 0)
		sDownCPort				= LinkPort(cDn, i0:p1, color0:.red)
		addChild(sDownCPort)			//sDownCPort.parent = self
		ports["S"]				= sDownCPort

		pUpCPort.outPort		= sDownCPort
		sDownCPort.outPort		= pUpCPort

		 // Register CPorts
		assert(pUpCPort  .dirty == .clean, "paranoia")	//pPort.dirty.turnOff(.vew) // (link vew proper at init)
//??	assert(sDownCPort.dirty == .clean, "paranoia")	//sPort.dirty.turnOff(.vew) // (link vew proper at init)

		 // Initial values of LinkPort, for testing (of P/UpConveyor, not Q)
		if let valStr			= partConfig["initialSegments"] as? String {
			let valStrs			= valStr.split(separator: " ")
			for i in stride(from:0, to:valStrs.count, by:2) {
				let h			= Float(String(valStrs[i]))!
				let v			= Float(String(valStrs[i+1]))!
				let linkSegment = LinkSegment(heightPct:h, val:v)
				pUpCPort.addSegment(linkSegment)
			}
		}
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	 {  	[:]						}	// Ports defined elsewhere
//	override func hasPorts() -> [String:String]	 {  	["P":"cC", "S":"cCf"]	}	// Ports of Link created by this
//	override func hasPorts() -> [String:String]	 {  	["P":"c", "S":"cf"]		}
	var curActiveSegments : Int	{ pUpCPort.inTransit.count + sDownCPort.inTransit.count	}

	 // MARK: - 3.5 Codable
	enum LinksKeys: String, CodingKey {
		case linkSkinType
		case upCPort
		case downCPort
		case minColorVal
		case maxColorVal
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:LinksKeys.self)

		try container.encode(linkSkinType.rawValue,	forKey:.linkSkinType)
		try container.encode(pUpCPort, 				forKey:.upCPort)
		try container.encode(sDownCPort, 			forKey:.downCPort)
		try container.encode(minColorVal, 			forKey:.minColorVal)
		try container.encode(maxColorVal, 			forKey:.maxColorVal)
		logSer(3, "Encoded  as? Link        '\(fullName)'")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		linkSkinType 			= .invalid
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:LinksKeys.self)

		linkSkinType			= try container.decode(LinkSkinType	.self, forKey:.linkSkinType)
		pUpCPort	 			= try container.decode(LinkPort	.self, forKey:.upCPort)
		sDownCPort				= try container.decode(LinkPort	.self, forKey:.downCPort)
		minColorVal	 			= try container.decode(Float		.self, forKey:.minColorVal)
		maxColorVal	 			= try container.decode(Float		.self, forKey:.minColorVal)
		logSer(3, "Decoded  as? Link       named  '\(name)'")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Link
//		theCopy.linkSkinType	= self.linkSkinType
//		theCopy.pUpCPort	 	= self.pUpCPort
//		theCopy.sDownCPort	= self.sDownCPort
//		theCopy.minColorVal	 	= self.minColorVal
//		theCopy.maxColorVal	 	= self.maxColorVal
//		logSer(3, "copy(with as? Actor       '\(fullName)'")
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					   else {	return true				}
		guard let rhs			= rhs as? Link else {	return false 			}
		let rv					= super.equalsFW(rhs)
								&& linkSkinType == rhs.linkSkinType
							//??	&& pUpCPort 	== rhs.pUpCPort
							//??	&& sDownCPort 	== rhs.sDownCPort
								&& minColorVal 	== rhs.minColorVal
								&& maxColorVal 	== rhs.maxColorVal
		return rv
	}
	 // MARK: - 5 Groom
	override func reset() {							super.reset()
		sDownCPort.inTransit.removeAll()
		  pUpCPort.inTransit.removeAll()
		markTreeDirty(bit:.size)
	}
	 // MARK: - 8. Reenactment Simulator
	override func simulate(up:Bool) {
		up ?
		     pUpCPort.simulate() :
		   sDownCPort.simulate()
	}
	  // MARK: - 9.0 make a Vew for a Part
	override func VewForSelf() -> Vew? {
		return LinkVew(forPart:self)
	}
	 // MARK: - 9.1 reVew
	override func reVew(vew:Vew?, parentVew:Vew?) {
		if trueF {//trueF//falseF//
			 // Use inherited reVew
			super.reVew(vew:vew, parentVew:parentVew) //\/\/\/\/\/\/\/\/\/
		}
//		else { 		// EXPERIMENTAL, unused
//			 // Insure Vew of Link
//			let linksVew : Vew?	= vew ??								// from arg
//								  parentVew?.find(part:self, maxLevel:1) ?? // from parent
//								  addNewVew(in:parentVew)					// create
//			 // reVew Link's Ports ourselves. (Inherited reVew in Atom may not work)
//			markTreeDirty(bit:.size)	// NEEDED, if no super.reVew(vew:)	// 2. why needed
//			for childPart in children {
//	bug;		if	childPart.test(dirty:.vew) {							// 3. can't put in
//					childPart.reVew(parentVew:linksVew)
//					if let childVew = linksVew?.find(part:childPart, maxLevel:1) {
//						 // Tiny Black Sphere
//						childVew.scnScene.geometry = SCNSphere(radius:0.1)
//						childVew.scnScene.color0 = NSColor.black
//					}else{
//						panic("linksVew?.find")
//					}
//				}
//			}
//		}
	}	// Xyzzy19e

	 // MARK: -- Connect LinkVew's [sp]Con2Vew endpoints and constraints:
	override func reVewPost(vew:Vew) 	{	// Add constraints
		guard let linkVew		= vew as? LinkVew
		 else { 	panic("Link's Vew isn't a LinkVew");return					}

		 // Connect LinkVew to its two end Port's Vew	  // :H: [S/P] CONnectd 2 Vew
		guard let p	: Vew		= vewConnected(toPortNamed:"P", inViewHier:vew)
		 else {		panic("\nLink end \(self.fullName).P unconnected");return	}
		guard let s	: Vew		= vewConnected(toPortNamed:"S", inViewHier:vew)
		 else {		panic("\nLink end \(self.fullName).S unconnected");return	}

		 // Load LinkVew with Ports it connects to
		linkVew.pCon2Vew		= p	  // get Views we are connect to:
		linkVew.sCon2Vew		= s

		if linkVew.scn.constraints == nil {
			if linkSkinType == .dual {	 	// SCNBillboardConstraint, SCNLookAtConstraint
				guard let parentVew = linkVew.parent else { return }

				// Add constraints to keep link endpoints attached in parent's coordinate space
				let pConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace:false)
				{ (node, position) in			// Get connected port's position locally in parent's coordinate space
					guard let pConnectedVew = linkVew.pCon2Vew,
						  let pPort = pConnectedVew.part as? Port else { return position }
					let pConSpot = pPort.portConSpot(inVew: parentVew)
					return pConSpot.center
				}
				let sConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace:false)
				{ (node, position) in			// Get connected port's position locally in parent's coordinate space
					guard let sConnectedVew = linkVew.sCon2Vew,
						  let sPort = sConnectedVew.part as? Port else { return position }
					let sConSpot = sPort.portConSpot(inVew: parentVew)
					return sConSpot.center
				}
			//	linkVew.scn.constraints?.append(contentsOf: [pConstraint, sConstraint])
			//	// Apply constraints to the link's endpoints
			//	if let pVew = linkVew.find(name:"_P", maxLevel:1) {
			//		pVew.scn.constraints = [pConstraint]
			//	}
			//	if let sVew = linkVew.find(name:"_S", maxLevel:1) {
			//		sVew.scn.constraints = [sConstraint]
			//	}
			}
//			if linkSkinType == .dual {	 	// SCNBillboardConstraint, SCNLookAtConstraint
//				guard let parentVew = linkVew.parent else { return }
//
//				// Add constraints to keep link endpoints attached in parent's coordinate space
//				let pConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: false)
//				{ (node, position) in			// Get connected port's position locally in parent's coordinate space
//					guard let pConnectedVew = linkVew.pCon2Vew,
//						  let pPort = pConnectedVew.part as? Port else { return position }
//					let pConSpot = pPort.portConSpot(inVew: parentVew)
//					return pConSpot.center
//				}
//				let sConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: false)
//				{ (node, position) in			// Get connected port's position locally in parent's coordinate space
//					guard let sConnectedVew = linkVew.sCon2Vew,
//						  let sPort = sConnectedVew.part as? Port else { return position }
//					let sConSpot = sPort.portConSpot(inVew: parentVew)
//					return sConSpot.center
//				}
//			//	linkVew.scn.constraints?.append(contentsOf: [pConstraint, sConstraint])
//			//	// Apply constraints to the link's endpoints
//			//	if let pVew = linkVew.find(name:"_P", maxLevel:1) {
//			//		pVew.scn.constraints = [pConstraint]
//			//	}
//			//	if let sVew = linkVew.find(name:"_S", maxLevel:1) {
//			//		sVew.scn.constraints = [sConstraint]
//			//	}
//			}
		}
	}
	func vewConnected(toPortNamed portName:String, inViewHier vew:Vew) -> Vew? {
		let parent_				= vew.parent!
		if let port 	 		= ports[portName]!.con2?.port {	// Where Port ends
			for s in port.selfNParents {
				if let s2		= parent_.find(part:s, inMe2:true) {			//, maxLevel:1??
					return s2
				}
			}
		}
		return nil
	}
	  // MARK: - 9.2 reSize (position its ends)
	override func reSize(vew:Vew) {
		logRsi(8, "<><> L 9.2:   \\reSize Link '\(vew.part.fullName)'")
		 // HELP: dThis should go in Link.reSkin!
		vew.scn.categoryBitMask = FwNodeCategory.picable.rawValue 	// Link skins picable

		 // Reskin Link's Ports:
		for (_, port) in ports {
//bug //NReset
			if port.test(dirty:.size) {		// clear Port's dirty size
				guard let portsVew = vew.find(part:port, maxLevel:1) else {debugger("Link's Part has no Vew") }

				let _			= port.reSkin(linkPortsVew:portsVew)		// xyzzy32 Link rebuilds link skins

				portsVew.scn.categoryBitMask = FwNodeCategory.picable.rawValue 	// Link Port skins picable
			}
		}
	 	   // Link's positioning of its Ports is entirely different
		  //  from Atom's, it's superclass.	.:. Don't call super
		 //------ NOT SURE WHY THIS IS HERE (except it must be)
		vew.bBox				= .empty			// ??? Set view's bBox EMPTY
		vew.bBox				= reSkin(expose:.same, vew:vew)	// Put skin on Part		// xyzzy32 -- Link's positioning of its Ports
		markTreeDirty(bit:.paint)
	}
	 // MARK: - 9.3 reSkin (Link Billboard)
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		logRsi(8, "<><> L 9.3:   \\reSkin Link '\(vew.part.fullName)'")
		let name				= "s-Link"
		let _/*scn*/ : SCNNode	= vew.scn.findScn(named:name) ?? {
			let rv				= SCNNode()	// invisible bucket
//			sLink.isHidden		= true	// N.B: so unpositioned Links don't interfere
			vew.scn.addChild(node:rv, atIndex:0)
			rv.name				= name

			 // Make a UNIT skin, one of length:1 in .uZ
			var sPaint:SCNNode? = nil
			var nPaint			= 0			// Number of materials to create
			switch linkSkinType {
			case .invalid:
				panic("Link Skin type '.invalid' cannot be drawn")
			case .invisible:
				nop
			case .ray:						// from origin (0,0,0) to .uZ (0,0,1)
				 // Add a 1-pixel wide line, length:1, from origin to .uZ
				let sRay		= SCNNode(geometry:SCNGeometry.lines(lines:[0,1], withPoints:[.zero, -.uZ]))
				rv.addChild(node:sRay)
				sRay.name		= "s-Ray"
				sRay.color0		= .black
			case .dual:
				 // Add a 1-pixel wide line -- for UNIT skin
				let sRay		= SCNNode(geometry:SCNGeometry.lines(lines:[0,1], withPoints:[.zero, -.uZ]))
				rv.addChild(node:sRay)
				sRay.name		= "s-Dual"//"s-Ray"
				sRay.color0		= .black

				 // Add Billboard of bidirectional values
				sPaint			= SCNNode()
				rv.addChild(node:sPaint!)
				sPaint!.name	= "s-Paint"
				if usePlane {				//(210805PAK: leaner, has bugs)
					nPaint 		= 1				// 1-sided xy square; normal=.uZ
					sPaint!.geometry = SCNPlane(width:1, height:1) // 1-sided; normal=.uZ
				}else{
					nPaint 		= 6				// 1-sided xy square; normal=.uZ
					sPaint!.geometry = SCNBox(width:1, height:0 , length:1, chamferRadius:0) // 2-sided!
				}
				sPaint!.position = -.uZ/2	// one end at origin, the other -.uZ
			case .tube:
				 // Add a 1-pixel wide line
				sPaint			= SCNNode()
				rv.addChild(node:sPaint!)
				sPaint!.name	= "s-Paint"
				sPaint!.geometry = SCNCylinder(radius:0.6, height:1) 			// height -> y
				//				= SCNBox(width:0.2,  height:1,  length:0.2,chamferRadius:0) // width:.uX, height:.uY, length:.uZ
				sPaint!.color0	= .red		// BROKEN
				sPaint!.transform = SCNMatrix4MakeRotation(.pi/2, 1,0,0)
				sPaint!.position.z -= 0.5
			}

			 // Create MATERIALS for faces to display colors
			if let geom			= sPaint?.geometry {
				geom.materials 	= []
				for _ in 0..<nPaint {
					 // Create MATERIALS for faces to display colors
					let m 		= SCNMaterial()
					m.diffuse.contents = NSColor(hexString:"#00000000")		// not normal .white
					geom.materials.append(m)
				}
			}																	//	skinLink.pivot.position	= SCNVector3(0, 0, 0)	// Pivot about Z-end
			rv.isHidden			= true	// N.B: so unpositioned Links don't interfere
			return rv
		} ()
		markTreeDirty(bit:.paint)
		return .empty						// Xyzzy19e	// Xyzzy44	vsb
	}
	 // MARK: - 9.4 rePosition
	 // Set Link's end position
		 /// A Link's origin is at it's parent's origin. It's P and S mark it's ends from that.
		 /// Skin "s-Link" displays the two bidirectional opposing values
		 /// All calculations done in parentVew(.scnScene)'s coordinate system
	override func reSizePost(vew:Vew) {				//  find endpoints
		let aux					= params4partPp				//log.params4defaultPp
		guard let linkVew		= vew as? LinkVew else { debugger("Link's Vew isn't a LinkVew") }
		guard let parentVew		= linkVew.parent  else { return	/* no parent, do nothing*/}
		linkVew.scn.position	= .zero

		  // :H: CONnected to_2_,			// Vew or Port that Link's S/P Port is connected to
		 //  :H: _S_ port, _P_ port, 		// ends of link
		guard let pCon2Port 	= linkVew.pCon2Vew?.part as? Port,
		  let sCon2Port : Port	= linkVew.sCon2Vew?.part as? Port else { return	}

		  // :H: conSpot; scn_V_ector3; scn_F_loat
		 //  :H: CONnnected to(2)
		let pCon2SIp 			= pCon2Port.portConSpot(inVew:parentVew)	// (Spot defines area arround)
		 let sCon2SIp			= sCon2Port.portConSpot(inVew:parentVew)
		assertWarn(!(pCon2SIp.center.isNan || sCon2SIp.center.isNan), "\(linkVew.pp(.fullNameUidClass).field(-35)) connect spot is nan")
		logRsi(4, "<<===== reSizePost, FOUND pCon2SIp=\(pCon2SIp.center.pp(.line, aux)), s=\(sCon2SIp.center.pp(.line, aux))")

		 // Center point of each end, in world coordinates
		// :H: _CENT_er					// of spot
		// :H: SETBACK
		// :H: END 						// actual line endpoint
		// :H: _P_osition, _L_ength
		// :H: In Parent,
		//												<==============* lCentRayUnit
		//		*<------------------ lCentV, lCentL ------------------>*
		//	  pCentVip												sCentVip

 		let  pCon2VIp 			= pCon2SIp.center	// e.g: p9/t1.P // SCNVector3(0,2,0)
		 let sCon2VIp			= sCon2SIp.center	// e.g: p9/t3.P // SCNVector3(0,0,-2)
		assertWarn(!(pCon2VIp.isNan || sCon2VIp.isNan), "\(linkVew.pp(.fullNameUidClass).field(-35)) position is nan")

/**/	linkVew.bBox			= BBox(pCon2VIp, sCon2VIp)

		   // - - - Now all furthur computations are in    _IN  PARENT  VIEW_    - - -
		  // Both size and position LinkVew here
		 // Length between center endpoints:
		let lCentV : SCNVector3 = sCon2VIp - pCon2VIp
		let lCentL				= lCentV.length
		var unitRay				= lCentV / lCentL
 		let (pR, sR)		 	= (pCon2SIp.radius, sCon2SIp.radius)
		let desiredRadii		= pR + sR

		 // Many degenerate cases land here
		if desiredRadii < eps {
			assert(pR<eps && sR<eps, "paranoia")
			unitRay				= .zero				// observe no radius
		}
		if desiredRadii > lCentL {			// Centers are too close for both balls
			unitRay				*=   desiredRadii / lCentL
		}
		 // Position "P" Port
		let p					= pCon2VIp + pR * unitRay	// position
//**/	linkVew.find(name:"_P", maxLevel:1)!.scn.position = p							// -> Port
		let pNode = linkVew.find(name:"_P", maxLevel:1)!.scn
		pNode.position = p																	// -> Port
		linkVew.pEndVip			= p

		 // Position "S" Port
		let s					= sCon2VIp - sR * unitRay
		let sVew				= linkVew.find(name:"_S", maxLevel:1)!
/**/	sVew.scn.position		= s
		sVew.scn.position		= s
		linkVew.sEndVip			= s

		logRsi(8, "<><> L 9.3b:  \\reSizePost set: p=\(p.pp(.line)) s=\(s.pp(.line)) (inParent)")
	}

		// Xyzzy19e
	 // Position one Link Ports, from its [ps]EndV
	override func rePosition(portVew:Vew)	{
bug	// Never USED?
		guard let port			= portVew.part as? Port,	// All Link's children should be Ports
		  let parentLinkVew		= portVew.parent as? LinkVew else
		{	panic("rePosition(portVew is confused");	return					}

		for (portStr, endVip) in [	("P", parentLinkVew.pEndVip),		// Both Ends
									("S", parentLinkVew.sEndVip) ] {
			if port == ports[portStr] {
				guard let p		= endVip else {
					if Log.shared.eventIsWanted(ofArea:"rsi", detail:3) {
						warning("\(parentLinkVew.pp(.fullNameUidClass)) has \(portStr)endVip:SCNVector3 == nil")
					}
					continue
				}
				portVew.scn.position = p
				logRsi(8, "<><> L 9.4\(portStr):  = \(p)")
			}
		}
	}
	  // MARK: - 9.5: Render Protocol
	  // MARK: - 9.5.2: did Apply Animations -- Compute spring forces
	override func computeLinkForces(vew:Vew) {
		logRve(8, "<><> L 9.5.2: \\ Compute Spring Force from: '\(vew.part.fullName)'")
		guard !vew.scn.transform.isNan else {
			return print("\(vew.pp(.fullNameUidClass)): Position is nan")
		}
		if let lv 				= vew as? LinkVew,		// lv is link
		  let lvp				= lv.parent, 				// lv has parent
		  let lvPCon2Vew		= lv.pCon2Vew,
		  let lvSCon2Vew		= lv.sCon2Vew
		{
//			print(lv.sCon2Vew.parent?.scnScene.pp(.tree) ?? "xx")
			let sPinPar			= lvp.localPosition(of:.zero, inSubVew:lvSCon2Vew)// e.g: p9/t3.P
			let pPinPar			= lvp.localPosition(of:.zero, inSubVew:lvPCon2Vew)// e.g: p9/t1.P
//			if pPinPar.isNan {				/// FOR DEBUG
//				computeLinkForces(vew:vew)		// might go recursive!
//				return
//			}
			let delta 			= sPinPar - pPinPar
			let springK			= CGFloat(1.0)
			let force			= delta * springK
			if !force.isNan {
				let pInertialVew = lvPCon2Vew.intertialVew	// Who takes brunt?
				let sInertialVew = lvSCon2Vew.intertialVew
				if (pInertialVew?.force.isNan ?? false) || (sInertialVew?.force.isNan ?? false) {
					panic("lskdfj;owifj")
				}

				 // Accumulate FORCE on node:
	/**/		pInertialVew?.force += force
	/**/		sInertialVew?.force -= force
				logRve(9, "Force  \(force.pp(.line)) "
					+ "from  \(pInertialVew?.pp(.fullName) ?? "fixed") "
					+    "to \(sInertialVew?.pp(.fullName) ?? "fixed")")
				logRve(9, " posn: \(vew.scn.transform.pp(.line))")

			}
			else {
				logAni(3, "##### computeLinkForces found nan connecting p:\(pPinPar.pp(.short)) to s:\(sPinPar.pp(.short))")//Warn
			//	let sPinParX	= lvp.localPosition(of:.zero, inSubVew:lv.sCon2Vew)
			}
		}
	}		// Xyzzy19e

	 // MARK: - 9.5.4: will Render Scene -- Rotate Links toward camera
	 // Transform so endpoints so [0,1] aligned with [.origin, .uZ]:
	override func rotateLinkSkins(vew:Vew) {	// create Line transform
		guard let linkVew		= vew as? LinkVew 	 else { debugger("Vew type mismach")}
		guard let base			= vew.vewBase(),
		 	  let cameraScn		= base.cameraScn else 
		{	print("silently: can't find camera")
			return
		}			// :H: VECTor,Vector,  InWorld, InParent
		 // Get ends of link, and set positions
		if let pEndVectIp		= linkVew.pEndVip,
		  let  sEndVectIp 		= linkVew.sEndVip {
//			logRsi(8, "<><> L 9.5.4: \\set xform from p:\(pEndVip.pp(.line)) s:\(sEndVip.pp(.line))")

			 // Create a transform that maps (0,0,0)->pEndVip and (0,0,1)->sEndVip
			//	  |m11* + m12* + m13*|   |in.x| transposed into a colum
			//	  |m21* + m22* + m23*|<--|in.y|
			//	  |m31* + m32* + m33*|   |in.z|
			//	  out.x   out.y  out.z			output is a row
			let linkVectIp		= sEndVectIp - pEndVectIp
			let len				= length(linkVectIp)
			 assertWarn(!len.isNan, "\(linkVew.pp(.fullNameUidClass).field(-35)) position is nan")
			guard let cameraPosnIp	= vew.parent?.scn.convertPosition(cameraScn.position, from:nil as SCNNode?)
			 else {fatalError()}
			let f1				= cameraPosnIp.crossProduct(linkVectIp)
			let fLen			= length(f1)
			var transform		= SCNMatrix4.identity
			if fLen > eps {
				let f			= f1 / fLen
				let g1			= -f.crossProduct(linkVectIp)		// see perpendicular above!!!
				let g			= g1 / length(g1)
				transform		= SCNMatrix4(row1v3:f, row2v3:g, row3v3:-linkVectIp, row4v3:pEndVectIp)	// print("a:\(a.pp(.line))--d:\(delta.pp(.line))-> cam:\(camera.pp(.line)),\nf:\(f.pp(.line)), g:\(g.pp(.line)), m:\n\(m.pp(.tree))")
			}; assert(!transform.isNan, "Transformation of Link failed")

			  // Link's position isn't in linkVew.scnScene, but it's child "s-Link".
			 // (This allows S and P ornaments in linkVew.scnScene to be unstretched)
			let sLink			= linkVew.scn.findScn(named:"s-Link")!
			sLink.transform 	= transform
		}else{
			logRnd(1, "CURIOUS3 -- link ends nil, cannot rotate link toward camera")
		}
	}		// Xyzzy19e

	  // MARK: - 9.6: Paint Image:
	 /// UPDATE APPEARANCE of Links
	var imageWidth : Int				 	{ 	return 3						}
	var imageHeight: Int					{ 	return 300						}
	 /// Paint red and green onto Link skins
	override func rePaint(vew:Vew) 		{		// paint red and green
		logRsi(8, "<><> L 9.6:   \\rePaint")
		 // S and P port of a link have no views, but their .paint bits must be cleared:
		let _ 					= ports.map {	$1.dirty.turnOff(.paint) 		}
		 // ???? delay till all repainted?

		super.rePaint(vew:vew)				// hits my end LinkPorts

		if linkSkinType == .dual {
			guard let linkVew	= vew as? LinkVew else {	debugger("paranoia")	}
			let linksImage		= NSImage(size: NSSize(width:imageWidth, height:imageHeight))
			let link : Link 	= linkVew.part as! Link
			link  .pUpCPort.paintSegments(on:linksImage)
			link.sDownCPort.paintSegments(on:linksImage)

				// N.B: For updates to linksImage to take place, a NEW skin
			   //   must be generated every frame! (PERFORMANCE ISSUE??)
			  // DOc SAYS: SceneKit creates a transaction automatically
			 //    whenever you modify the objects in a scene graph.
								//
			 // Apply image to shape (Plane or Box)
			let scn2paintOn		= linkVew.scn.findScn(named: "s-Paint")
			guard let geom		= scn2paintOn?.geometry
			 else { debugger("Attempt to paint on scnScene wo geometry") 		}
			let i				= usePlane ? 0 : 4		// 0:base, 4:left side if rect
			assert(i < geom.materials.count, "Link '\(pp(.fullName))' access: to \(i) but only has \(geom.materials.count) materials")
			geom.materials[i].diffuse.contents = linksImage						//for j in 0..<6 {
		}																		//	geom.materials[j].diffuse.contents = linksImage
		if let scnLink:SCNNode	= vew.scn.findScn(named:"s-Link") {
			//assert(scnLink.isHidden, "paranoia") //21200823 Happens often!
			scnLink.isHidden	= false				// now vew link
		}
	}		// Xyzzy19e
								
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		var rv = super.pp(mode, aux)
		switch mode {
		case .tree:
			if mode ==  .tree  && !aux.bool_("ppParam") {		//$
				rv				+=   pUpCPort.pp("up")
				rv				+= sDownCPort.pp("dn")
			}
		case .line:
			let n				= pUpCPort.inTransit.count + sDownCPort.inTransit.count
			rv					+= "ev=" + String(n)
			if linkSkinType != .invisible {
				rv				+= ", linkSkinType:\(linkSkinType.rawValue)"
			}
		default:
			nop
		}
		return rv
	}
         // MARK: - 17. Debugging Aids
	override var description	  : String {	return "'\(pp(.short))'"		}
	override var debugDescription : String {	return "'\(pp(.short))'"		}
	override var summary		  : String {	return "'\(pp(.short))'"		}
}

extension Port {
		 // MARK: - 9.3 reSkin
	func reSkin(linkPortsVew vew:Vew) -> BBox  {
		assert(parent is Link, "sanity check")
		let name				= "s-LnkEnd"
		let scn:SCNNode 		= vew.scn.findScn(named:name) ?? {
			 // None found, make one.
			//logRsi(8, "<><> L 9.3:   \\reSkin(linkPortsVew \(vew.part.fullName))")
			let rv				= SCNNode(geometry:SCNSphere(radius:0.2))		// the Ports of Links are invisible
			vew.scn.addChild(node:rv)
			rv.name				= name
			rv.color0 			= NSColor("lightpink")!	//.green"darkred"
			return rv
		} ()
		return scn.bBox() * scn.transform //return vew.scnScene.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
}
