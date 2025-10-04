//  Vew.swift -- a tree of (Factals)Views per part C2013PAK
// :H: ViEW (Vew) is a contraction of View, and contains views of 3D objects
// :H: bbox=BBox, fw=FactalWorkbench

import SceneKit

extension Vew : Equatable {
	static func == (lhs: Vew, rhs: Vew) -> Bool {
		lhs === rhs
//		if lhs.part	!= rhs.part 	{ 							return false 	}
//	//	if lhs.vewConfig != rhs.vewConfig 	{ 					return false 	}
//		for (lhsChild, rhsChild) in zip(lhs.children, rhs.children) {
//			if lhsChild != rhsChild {							return false	}
//		}
//		return true
	}
}
extension Vew: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(part)
		for child in children {
			hasher.combine(child)
		}
	}
}
		// can't remove NSObject?
class Vew : /*NSObject, */ ObservableObject, Codable, Uid {	// NEVER NSCopying, Equatable, Uid, Logd xyzzy4
	// MARK: - 2. Object Variables:
	var nameTag 				= getNametag()	 // Uid:
	var name 		: String
	 // Glue these Neighbors together: (both Always present)
	var part 		: Part 						// Part which this Vew represents	// was let
	var parent		:  Vew?		= nil
	var children 	: [Vew]		= []

	var scn			: SCNNode		 // PAK20240913 reverting back:
	var vewConfig   : VewConfig	= .null

	var keep		:  Bool		= false			// used in reVew

	 // Sugar:
	var child0		:  Vew?		{	return children.count == 0 ? nil : children[0] }
	var fullName	: String	{	 // Hierarchy:
		return parent==nil  ? 		"/" + name :
			   						parent!.fullName + "/" + name
//
//		name == "_ROOT" ?		name :			// Leftmost component
//		parent == nil  	? 		""   :
//								parent!.fullName + "/" + name	// add lefter component
	}
	func vewBase() -> VewBase?	{	part.partBase?.factalsModel?.vewBase(ofVew:self) }

	 // Used for construction, which must exclude unplaced members of SCN's boundingBoxes
	var bBox 		:  BBox		= .empty	// bounding box size in my coorinate system (not parent's)

	var expose : Expose	= .open {			// how the insides are currently exposed
		willSet(v) {
			part.markTreeDirty(bit:.vew)											}
	}
	var jog			: SCNVector3? = nil		// an ad-hoc change in position
	var force		: SCNVector3 = .zero 	// for Animation for positioning
	var log 					= Log.shared

	 // MARK: - 3. Factory
	init(forPart p:Part/*?=nil*/, expose e:Expose? = nil) {	 // Vew(forPart:expose:)
		let part				= p
		self.part 				= part
		self.name				= "_" + part.name 	// View's name is Part's with '_'
		self.expose				= e ?? part.initialExpose
		scn						= SCNNode()		// makes rootNode:SCNNode too
		scn.name				= "*-" + part.name								// scn.name = self.scn.name ?? ("*-" + part.name)
		  // Visible Shape:
		 // Jog
		if let jogStr	 		= part.config["jog"]?.asString,
		   let jogVect 			= SCNVector3(from:jogStr) ??			// x y z
		  						  SCNVector3(from:jogStr + " 0") ??		// x y 0
		  						  SCNVector3(from:jogStr + " 0 0") {	// x 0 0
			jog 				= jogVect
		}
	}
	func configureVew(config:VewConfig) {
		vewConfig				= config
	}
	init(forPort port:Port) {			/// Vew(forPort
		self.part 				= port
		self.name				= "_" + port.name 	// Vew's name is Part's with '_'
		self.expose				= .open
		scn						= SCNNode()		 // Make new SCN:
		scn.name				= "*-" + port.name

		let portProp : String?	= port.config["portProp"] as? String //"xxx"//
		scn.flipped 			= portProp?.contains(substring:"f") ?? false
		 // Flip
		// Several ways to do a flip. Each has problems:
		// 1. ugly, inverts Z along with Y: 	scnScene.rotation = SCNVector4Make(1, 0, 0, CGFloat.pi)
		// 2. IY ++, Some skins show as black, because inside out: 		scale = SCNVector3(1, -1, 1)
		// 3. causes Inside Out meshes, which are mostly tollerated:	scnScene.transform.m22 *= -1
	}

	 // MARK: - 3.5 Codable
	enum VewKeys : CodingKey { 	case nameTag, name, part, parent, children, scn
								case vewConfig, keep, bBox, expose, jog, force }
	func encode(to encoder: Encoder) throws {
//		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:VewKeys.self)
		try container.encode(nameTag, 	forKey:.nameTag	 	)
		try container.encode(name, 		forKey:.name 	 	)
		try container.encode(part, 		forKey:.part 	 	)
		try container.encode(parent, 	forKey:.parent	 	)
		try container.encode(children, 	forKey:.children  	)
	//	try container.encode(scn, 		forKey:.scn		 	)
	//	try container.encode(vewConfig, forKey:.vewConfig  	)
		try container.encode(keep, 		forKey:.keep	 	)
		try container.encode(bBox, 		forKey:.bBox 	 	)
		try container.encode(expose, 	forKey:.expose 	 	)
		try container.encode(jog, 		forKey:.jog		 	)
		try container.encode(force, 	forKey:.force	 	)
		logSer(3, "Encoded  as? Path        '\(String(describing: fullName))'")
	}
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:VewKeys.self)
		nameTag					= try container.decode(    NameTag.self, forKey:.nameTag)
		name 					= try container.decode(     String.self, forKey:.name 	)
		part 					= try container.decode(       Part.self, forKey:.part 	)
		parent					= try container.decode(       Vew?.self, forKey:.parent	)
		children 				= try container.decode(      [Vew].self, forKey:.children)
	bug;scn 					= SCNNode()
	//	scn						= try container.decode(    SCNNode.self, forKey:.scn	)
	//	vewConfig  				= try container.decode(  VewConfig.self, forKey:.vewConfig)
		keep					= try container.decode(       Bool.self, forKey:.keep	)
		bBox 					= try container.decode(       BBox.self, forKey:.bBox 	)
		expose 					= try container.decode(     Expose.self, forKey:.expose )
		jog						= try container.decode(SCNVector3?.self, forKey:.jog	)
		force					= try container.decode( SCNVector3.self, forKey:.force		)
		//super.init()
 		logSer(3, "Decoded  as? Vew       named  '\(String(describing: fullName))'")
	}
	 // MARK: - 4.2 Manage Tree
	 /// Array of ancestor. The first element is self, last is top Vew:
	var selfNParents : [Vew] {
		return selfNParents()
	}
	func selfNParents(upto:Vew?=nil) -> [Vew] {
		var rv	   : [Vew]		= [] 				// [self,...,top]
		var aVew   :  Vew?		= self
		repeat {
			rv.append(aVew!)
			aVew 				= aVew!.parent
		} while aVew != nil && (upto == nil || upto != aVew)
		return rv
	}
	 /// Ancestor array where the first element is parent:
	var parents : [Vew] {
		return parent?.selfNParents() ?? []
	}
	func parents(inside:Vew?=nil) -> [Vew] {
		return parent?.selfNParents(upto:inside) ?? []
	}
	/// Add child Vew to self, and childs's scnScene to self.scnScene
	/// - Parameters:
	///   - vew: to add
	///   - ind: index to insert before
	func addChild(_ vew:Vew?, atIndex ind:Int?=nil) {
		guard let vew else {
			return							// no part, nuttin to do
		}
		if let ind {						// Index specified
			children.insert(vew, at:ind)
		}
		else {								// Index nil --> append
			children.append(vew)
		}
		vew.parent 				= self
		assert(part.parent === parent?.part, "fails consistency check")
		part.parent?.markTreeDirty(bit:.size)	// Affects parent's size
		part.markTreeDirty(bit:.vew)

		// Add the "entry SCNNode" for the vew
		scn.addChild(node:vew.scn)			// wire scn tree isomorphically	// was node:vew.scnScene
//		scnScene.addChild(node:vew.scnScene)// wire scnScene tree isomorphically
	}
	 // Remove if parent exists
	func removeFromParent() {
		guard let i		 		= parent?.children.firstIndex(where: {$0 === self}) else {
			debugger("\(pp(.fullNameUidClass)).removeFromParent(): not in parent:\(parent?.pp(.fullNameUidClass) ?? "nil")")
		}
		parent?.children.remove(at:i)
		parent?.part.markTreeDirty(bit:.size)	//.vew
	}
	func removeAllChildren() {
		for childVew in children { 			// Remove all child Vews
			childVew.scn.removeFromParent()		// Remove their skins first (needed?)
			childVew.removeFromParent()			// Remove them
		}
	//	part.markTreeDirty(bit:.vew)
//		scn.removeAllChildren()				// wipe out my skin
	}

//	func nodeCount() -> Int {
//		var rv					= 0
//		forAllSubViews {vew in
//			rv					+= 1
//		}
//		return rv
//	}

	typealias VewOperation 		= (Vew) -> ()
	func forAllSubViews(_ viewOperation : VewOperation)  {
		viewOperation(self)
		for child in self.children {
			child.forAllSubViews(viewOperation)
		}
	}

	 /// Lookup configuration from Part's config, up to root
	func getConfig(_ name:String)		-> FwAny? 		{

		 // Go up Vew tree to top, looking...
		for s in selfNParents {				// s = self, ..., top
			if let rv			= s.part.config[name] {
				return rv						// return an ancestor's config
			}
		}

		 // Try Document's configuration (in FactalsModel)
		guard let factalsModel	= part.partBase?.factalsModel else { return nil }
		if let rv				= factalsModel.fmConfig[name] {
			return rv
		}

	//	 // Look in vewBase's configuration...
	//	if let vewBase			= vewBase(),
	//	  let rv				= vewBase.tree.vewConfig[name] {
	//		return rv
	//	}
		return nil
	}

	 // MARK: - 4.6 Find Children
	 /// FIND child Vew by its NAME:
	//	all ->		up2		 :Bool	= false,			// search relatives of my parent
	//	inMe2 ->	inMe2		 :Bool	= true,				// search me
	func find(name:String,

			  up2:Bool=false,
			  inMe2:Bool=false,
			  maxLevel:Int?=nil) -> Vew?
	{
		return find(up2:up2, inMe2:inMe2, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.name == name		// view's name matches
		}
	}
	 /// FIND child Vew by its PART:
	func find(vew:Vew,

			  up2:Bool=false,
			  inMe2:Bool=false,
			  maxLevel:Int?=nil) -> Vew?
	{
		return find(up2:up2, inMe2:inMe2, maxLevel:maxLevel)
		{(v:Vew) -> Bool in
			return v === vew	// view's part matches
		}
	}
	 /// FIND child Vew by its PART:
	func find(part:Part,

			  up2:Bool=false,
			  inMe2:Bool=false,
			  maxLevel:Int?=nil) -> Vew?
	{
		return find(up2:up2, inMe2:inMe2, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.part === part	// view's part matches
		}
	}
	 /// FIND child Vew by its Part's NAME:
	func find(forPartNamed name:String,

			  up2:Bool=false,
			  inMe2:Bool=false,
			  maxLevel:Int?=nil) -> Vew?
	{
		return find(up2:up2, inMe2:inMe2, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.part.name == name	// view's part.name matches
		}
	}
	 /// FIND child Vew by its SCNNode:	// 20210214PAK not used
	func find(scnNode soughtNode:SCNNode,

			  up2:Bool=false,
			  inMe2:Bool=false,
			  maxLevel:Int?=nil) -> Vew?
	{
 		logRve(8, "Sought = \(soughtNode.fullName)")		//factalsModel.*/logd(
		return find(up2:up2, inMe2:inMe2, maxLevel:maxLevel)
		{ (vew:Vew)->Bool in
			logRve(8, "  Trying \(vew.scn.fullName)")		//factalsModel.*/logd(
			 // soughtNode is vew
			if soughtNode == vew.scn {
				return true
			}
			 // soughtNode is inside vew
			var rv2 = true
			let rv = vew.scn.find(maxLevel:maxLevel)
			{ (scn:SCNNode)->Bool in
 				logRve(8, "       ? \(scn.fullName)")		//factalsModel.*/logd(
 				if (scn.name ?? "").hasPrefix("*-") {
					rv2 = false
					return true		//
				}
				return scn == soughtNode
			}
			return rv2 && rv != nil
		}
	}
		/// find if closure is true:
	func find(up2:Bool=false,
			  inMe2:Bool=false,
			  maxLevel:Int?=nil,
			  except exception:Vew?=nil,

			  firstWith closureResult:(Vew) -> Bool) -> Vew?
	{
		 // Check self:
		if inMe2,
		  closureResult(self) {				// Self match
			return self
		}
		if (maxLevel ?? 1) > 0 {			// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
			 // Check children:
			//?let orderedChildren = flippedInWorld ? children.reversed() : children
			for child in children
			  where child != exception {	// Child match
				if let sv		= child.find(up2:up2, inMe2:true, maxLevel:mLev1, firstWith:closureResult) {
					return sv
				}
			}
		}
		 // Check around self
		if up2 {
			return parent?.find(up2:false, inMe2:true, maxLevel:maxLevel, except:self, firstWith:closureResult)
		}
		return nil
	}
	 // MARK: - 9. 3D Support
	/// Convert Position from Vew to self's Vew
	/// - Parameters:
	///   - position: a position in vew
	///   - vew: Vew of this position. vew is a sub-Vew of self. nil --> ???
	/// - Returns: position in View self
	func localPosition(of position:SCNVector3, inSubVew vew:Vew) -> SCNVector3 {
		if vew == self {
			return position
		}
		 // Go from vew toward self
		if let vewParent		= vew.parent {
			let vewScn:SCNNode	= vew.scn.physicsBody==nil ? vew.scn
											   : vew.scn.presentation
			let pInParent		= vewScn.transform * position
					// RECURSIVE
			let rv				= localPosition(of:pInParent, inSubVew:vewParent)

			logRsi(9, "localPosition(of:\(position.pp(.short)), inSubVew:'\(vew.parent!.pp(.fullName))' returns \(rv.pp(.short))")
			return rv
		}
		debugger("localPosition(of:\(position.pp(.short)), inSubVew:'\(vew.pp(.fullName))' HAS NO PARENT")
	}

	    /// Convert bBox from vew to self's Vew
	   /// - parameter bBox: -- Bounding Box in vew to transfer
	  /// - parameter vew: -- Vew of bBox
	 /// - Ignore animation
	func convert(bBox:BBox, from vew:Vew) -> BBox {
		let transform			= scn.convertTransform(.identity, from:vew.scn)
		let rv					= bBox.transformed(by:transform)
		return rv
	}
//	func convertToLocal(windowPosition:NSPoint) -> SCNVector3 {
//		windowPositionV3		= SCNVector3(windowPosition.x, windowPosition.y, 0)
//		return scnScene.convertPosition(windowPositionV3, from:nil)
//	}
	 /// Find a parent with a physis body, to take force
	var intertialVew : Vew? {
		for vew in selfNParents {
			if vew.scn.physicsBody != nil {
				return vew
			}
		}
		return nil
	}

	   // SPOTS are areas which might overlap
	  //
	 // They are of the following kinds
	enum SpotType : String{
		case empty				= "empty"	// nothing in entry
		case given				= "given"	// given/fixed, unknown at xxx
		case added				= "added"	// given/fixed, is not xxx
		case end				= "end  "	// end of active area
	}
	struct SpotData {	 // Everything that is known here about a spot
		var state	: SpotType
		var bBox 	: BBox
		var vew 	: Vew?	// vew associated with the Spot
		func pp() -> String {
			return "\(state.rawValue), bBox:'\(bBox.pp(.line))', vew:\(vew?.pp(.fullName) ?? "nil")"
		}
	}										// origin of the spot?

	func overlap(of bBox:BBox, withAnyIn spots:[SpotData]) -> Int? {
		for (i, spot) in spots.enumerated() where spot.state == .given {
			let oLapBBox		= bBox & spot.bBox								//;oLapBBox.min.y += 0.2
			if oLapBBox.isEmpty == false {	// bBox overlaps spots?
				return i						// overlaps, return index
			}
		}
		return nil						// no overlap, done!
	}
	func moveSoNoOverlapping() {
		var relevantSpots : [SpotData] = []	 // Define an ARRAY of SPOTS:
		  // All computations are done in the superVew ( H: Parent, Self)
		 // Process self bounds
		let sBBoxInP 			= bBox * scn.transform
		let sSizeInP			= sBBoxInP.size
		let sCenterInP			= sBBoxInP.center

		 // spots[] = relevant spots
		for sibling in parent?.children ?? [] {
			 // ignore the special types of views:
			if  sibling is LinkVew 	||		// ignore Links
//				sibling.part is Label||		// ignore Labels
				sibling == self		||		// ignore self
			   !sibling.keep		||		// ignore not yet placed
				sibling.bBox.isNan 	||		// ignore bad bounds
				sibling.bBox.size.length <= eps	// ignore small bounds
			{
				continue
			}
			 // Ignore siblings which have if no chance of collision from Y dimension
			let siblingBBox 	= sibling.bBox * sibling.scn.transform
			let centerDistY 	= siblingBBox.center.y - sCenterInP.y - eps	// between the 2
			let extentY  		= (siblingBBox.size.y  +   sSizeInP.y)/2	// size
			if extentY <= centerDistY || extentY <= -centerDistY {
				continue							// no overlap in y
			}
			 // ADD this spot as 'given'. We must be sure not to bump into it.
			relevantSpots.append(SpotData(state:.given, bBox:siblingBBox, vew:sibling))
		}
		
		/* ALGORITHM: Flood outward from self till a spot is found:
				spots contains all of the known spots at this level.
				It starts with the spot specified by self. It is set unspecified
				It loops till there are no unspecified spots
					Pick the unspecified spot that is closest to self
					If it overlaps, add the 4 spots around as unspecified spots
					If no overlap, USE THIS SPOT
		*/
		 // see if we don't overlap any spot given
		if overlap(of:sBBoxInP, withAnyIn:relevantSpots) == nil {
			return								// no overlap, done!
		}
		logRsi(5, " in parent:  bBox=\(sBBoxInP.pp(.line)), ctr=\(sCenterInP.pp(.line)). Relevant Spots:")
		if Log.shared.eventIsWanted(ofArea:"rsi", detail:5) {
			logSpots(relevantSpots)
		}
		 // go through all given spots, adding the 4 points around each
		for (i, trySpot) in relevantSpots.enumerated() where trySpot.state == .given {
			var tryBBox			= sBBoxInP 	// trial starts with self's size
			let size2 			= (trySpot.bBox.size + sSizeInP) / 2.0

			  // Go in all 4 directions from givenSpot. Either:
			 //
			for dir in [0,1,4,5] {//0..<4 {//
				var tryCenter 	= trySpot.bBox.center	// trial starts at goodSpot center
				let s2 :CGFloat = size2[dir/2]
				tryCenter[dir/2] += dir & 1 == 0 ? s2 : -s2
				tryBBox.center	= tryCenter		// move givenBBox to new center

				 // Does trial overlap any given spot?
				if let ol 		= overlap(of:tryBBox, withAnyIn:relevantSpots) {
					logRsi(8, "%3d+\(dir): overlaps %-3d! c:\(tryBBox.center.pp(.line))", i, ol)
				}
				else {
					 // ADD one of 4 SPOTs around placedSpot to spots, to check later
					let newSpot	= SpotData(state:.added, bBox:tryBBox, vew:nil)
					logRsi(5, "   \(relevantSpots.count): \(newSpot.pp())")
					relevantSpots.append(newSpot)
				}
			}
		}
		  // Find the closest of all potential spots.
		 //
		var closestDist 		= CGFloat.infinity
		var closestSpot : SpotData? = nil
		for aSpot in relevantSpots where aSpot.state == .added {
			 // Compute min distance to self
			let d 				= aSpot.bBox.center - sCenterInP
			let dist2self 		= d.length
			if closestDist > dist2self {
				closestDist 	= dist2self
				closestSpot 	= aSpot
			}
		}
		 // Move self by this amount
		assert(closestSpot != nil, "Could not find closest spot")
		var movedBy 			= closestSpot!.bBox.center - sCenterInP
		movedBy.y 				= 0			// HACK: keep same Y

		scn.position 			+= movedBy
		logRsi(4, "=====>> Moved by \(movedBy.pp(.short)) to \(scn.transform.position.pp(.short))")	//scn.transform.position.pp(.short)
	}
	func orBBoxIntoParent() {
		if let parentVew 		= parent {
			let myBip 			= bBox * scn.transform
			parentVew.bBox		|= myBip	// Accumulate me into parent
		}
	}
	func logSpots(_ spots:[SpotData]) {		// Print for debug
		for (i, spot) in spots.enumerated() {
			logRve(4, "   \(i): \(spot.pp())")
		}
	}


	 // MARK: - 9.5 Wire Box
	func updateWireBox() {

		 // Determine color0, or ignore
		let wBoxStr				= getConfig("wBox")?.asString	// master // part.getConfig("wBox")?.asString
		let myColor : NSColor?	= 				// Config declares:
			wBoxStr  == nil 	 ?	.red 		:	// red for debug	// nil : // nothing about Part
			wBoxStr! == "none"   ?	nil 		:	// disabled!
			wBoxStr! == "gray"   ?	.lightGray 	:	// gray!
			wBoxStr! == "white"  ?	.white 		:	// white!
			wBoxStr! == "gray"   ?	.lightGray	:	// gray!
			wBoxStr! == "black"  ?	.black		:	// black!
			wBoxStr! == "colors" ?	wBoxColorOf[part.fwClassName]:	// Part's class definition
									nil				// no wire box
		guard let color1		= myColor,				// color valid
		  expose == .open else {		 				// on open Views:
			return											// NO, no wire box
		}

		 // Get wire box
		let wBoxScn	: SCNNode		= scn.findScn(named:"w-", prefixMatch:true, maxLevel:1) ??	// 20210912PAK SStep BAD Here
		{	  // Recreate Wire box, and link it in
			 // Make a unit cube so size changes can use same base SCNNode
			var corners : [SCNVector3] = []
			for i in 0 ..< 8 {		// 8 corners of Cube: (+-1, +-1, +-1):
				corners.append(SCNVector3(i&1 != 0 ? 1:-1,i&2 != 0 ? 1:-1,i&4 != 0 ? 1:-1 ))
			}										  //			Y
			 // indices of the Wire Frame Cube:		  //	 		2-----3
			let indices:[Int32] = [0,1, 2,3, 4,5, 6,7,// X runs	  6-----7 |
								   0,2, 1,3, 4,6, 5,7,// Y runs   | |	| |
								   0,4, 1,5, 2,6, 3,7]// Z runs	  | 0 --|-1 ->X
			 // Make the SCNNode					  //		  4-----5
			let bBoxScn			= SCNComment("")	  //		Z
			scn.addChild(node:bBoxScn, atIndex:0)

			 // Name the wire frame
			let partBase		= part.partBase
			let wBoxNameIndex	= partBase?.indexFor["WBox"] ?? 1
			partBase?.indexFor["WBox"] = wBoxNameIndex + 1
//			assert(partBase != nil, "%%%%%%%% partBase==nil")
			print(partBase != nil ? "" : "%%%%%%%% partBase==nil")
			bBoxScn.name		= fmt("w-%d", wBoxNameIndex)
			bBoxScn.geometry 	= SCNGeometry.lines(lines:indices, withPoints:corners) //material.diffuse.contents = color0		// BUG doesn't work, all are white
			bBoxScn.categoryBitMask = FwNodeCategory.adornment.rawValue			//material.lightingModel 	= .blinn
			return bBoxScn
		} ()

		 // Set bBox size by it's .scale transform modifier
		wBoxScn.position		= bBox.center	//(bBox.min + bBox.max) / 2	// Read bBox
		wBoxScn.scale			= bBox.size / 2	//(bBox.min - bBox.max) / 2
		wBoxScn.color0 			= color1
		 // Put size in as SCNNode comment
		if let bBoxCom 			= wBoxScn as? SCNComment {
			bBoxCom.comment 	= "bb:\(bBox.pp(.line))"
		}
		 // Undo hidden
		wBoxScn.isHidden		= false
	}

	 // MARK: - 13. IBActions
	  // Repack children in us, then position ourselves in parent
	 //
	func process(theEvent:NSEvent)	-> Bool		{
		panic();
		return true
	}	// calls toggelOpen()
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String	{
		switch mode {
			case .name:
				return self.name
			case .fullName:
				return self.fullName
			case .phrase, .short:
				var rv 			= name + ppUid(pre:"/", self) + ":" + fwClassName + " "
				rv 				+= " ->" + part.pp(.fullNameUidClass, aux)
				rv				+= ", ->" + scn.pp(.fullNameUidClass, aux)
//				rv				+= ", ->" + scnScene.pp(.fullNameUidClass, aux)
				return rv
			case .line:
				let ppViewOptions = aux.string("ppViewOptions") ?? "UF PVS LETBIW" // Default to ALL
				let ppViewTight = aux.bool_("ppViewTight")
				func tight<T>(_ a:T, _ b:T) -> T 	{ 	return ppViewTight ? a : b	}

				  // 	(Tight==false:)
				 //  a68:Ff|    _net0:NetVew  s:  *-net0/2a0 p:  net0/aff:Net   . . . .  o+pI[-0.6-1.5-0.0]     w[-0.6-1.5-100.0] f-2.0< 3.2, -1.1< 4.1, -2.0< 2.0
				 //  AaaaBbCcDddddddddEeeeeeeFffffffffffGgggHhhIiiiiiJjjjjKkkkkkLlllllllMmmNnnnnnnnnnnnnnnnOoooooooooooooooooooooPpppppppppppppppppppppppppppppppp
				 //
				 //  c77:Ff|     _v:Vew      *-v/6a4       v/6a4:Mirror. . . . .  o+IY[y:-0.4]  f=-1.5< 1.5, -1.0< 0.1, -1.5< 1.5
				 //  AaaaBbCcDddddddEeeeFffffffffGgggHIiiiiiIiiiJKkkkkkLlllllllllMmmNnnnnnnnnnnnPpppppppppppppppppppppppppppppppp

				var rv			= ""						// /// PLACEMENT:
				if ppViewOptions.contains("U") {				 	// Uid:
					rv			+= ppUid(self, post:":")	 	 		  // (A)
				}
				if ppViewOptions.contains("F") {				 	// Flipped:
					rv			+= part.flippedInWorld ? "F" : " "			  // (B)
					rv			+= part.flipped   ? "f" : " "			  // (B)
				}
																	// Indent:
				rv 				+= log.indentString() 				  	  // (C)
				if ppViewOptions.contains("V") {					// Vew (self):
					rv			+= name.field(tight(6,8),dots:false) + ":"// (D) VIEW and MODEL names:
					rv			+= fwClassName.field(-tight(5,7),dots:false)// (E)
				}
															// /// LINKAGES:
				if ppViewOptions.contains("S") {					// Scn:
					rv			+= tight("", " s:")						  // (F)
					rv			+= (scn.name ?? "<none>").field(tight(5,8), dots:false)
					rv			+= ppUid(pre:"/", scn)					  // (G)
//					rv			+= (scn.name ?? "<none>").field(tight(5,8), dots:false)
//					rv			+= ppUid(pre:"/", scnScene)				  // (G)
				}
				if ppViewOptions.contains("P") {					// Part:
					rv			+= tight("", " p:")						  // (H)
					rv			+= part.name.field(6)					  // (I)
					rv			+= ppUid(pre:"/", part) + ":"			  // (J)
					rv			+= part.pp(.fwClassName, aux).field(-tight(4,6), dots:false) // (K)
				}
															// /// SKINS:
																	// UNIndent
				rv 				=  log.unIndent(rv)					  	  // (L)

				if ppViewOptions.contains("L") {					// Leaf:
					let s		= self as? NetVew
					rv			+= s==nil ? "   " :
								   "\(s!.heightLeaf)/\(s!.heightTree)"
				}
				if ppViewOptions.contains("E"),					 	// Expose:
				  !ppViewTight {
					rv			+= " " + expose.pp(.short, aux)			  // (M)
					rv			+= keep ? "+" : "-"						  // (M)
				}

// SCN:

				var rv1			= ""						// /// POSITIONS:
				if ppViewOptions.contains("T") {				 	// Transform:
					let tr		= scn.transform.pp(.phrase, aux)		  // (N)
//					rv1			+= tr=="I" ? "" : (tight("", " p") + tr + " ")
				}
				 // hasActions ??
				if ppViewOptions.contains("B") {					// physics Body:
					let pr		= scn.physicsBody == nil ? "I" :		// ("I" -> "")
								  scn.presentation.transform.pp(.phrase, aux)
					rv1			+= pr=="I" ? "" : "b" + pr				  // (*)
				}
				if ppViewOptions.contains("I") {				 	// pIvot:
					let pi		= scn.pivot.pp(.phrase, aux)			  // (*)
					rv1			+= pi=="I" ? "" : tight(pi, "i" + pi + " ")
				}
				let nCols		= tight(12, aux.int_("ppNCols4VewPosns"))
				rv				+= rv1.field(-nCols, dots:false) + " "

				if let rootScn	= vewBase()?.gui?.getScene?.rootNode {
					rv			+= !ppViewOptions.contains("W") ? ""	// World coordinates
								:  "w" + scn.convertPosition(.zero, to:rootScn).pp(.line, aux) + " "
				}
				if !(self is LinkVew) {
					 // SceneKit's BBox:
					if aux.bool_("ppScnBBox") {
						rv += tight("", "s") + scn.bBox().pp(.line, aux) + " "
					}
					 // Factal Workbench BBox:
					if aux.bool_("ppFwBBox") {
						rv += tight("", "f") + bBox.pp(.line, aux)		  // (O)
					}
				}
				return rv
			case .tree:
				var rv			= pp(.line, aux) + "\n"// print 1-line of self
				 // Print children
				log.nIndent	+= 1					// at increased indent
				for child in children {
					if child.parent != self {
						rv 		+= "!!! parent bad !!!"
					}
					rv 			+= child.pp(.tree, aux)	// ### RECURSIVE
				}
				log.nIndent	-= 1
				return rv
			default:
				return ppFixedDefault(mode, aux) 		// NO, try default method
		}
	}
	 // MARK: - 17. Debugging Aids
	/*override*/ var description	  : String {	return "'\(pp(.short))'"	}
	/*override*/ var debugDescription : String {	return "'\(pp(.short))'" 	}
	var summary					 	  : String {	return "'\(pp(.short))'"	}
	 // MARK: - 20. Extension variables
	var adornTargetVew 			  : Vew?	= nil
}
