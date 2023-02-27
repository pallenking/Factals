//  Vew.swift -- a tree of (Fw)Views per part C2013PAK
// :H: ViEW (Vew) is a contraction of View, and contains views of 3D objects
// :H: bbox=BBox, fw=FactalWorkbench

import SceneKit
		// Remove NSObject?
class Vew : NSObject, ObservableObject, Codable {	// NEVER NSCopying, Equatable

	// MARK: - 2. Object Variables:
	@Published var name :  String			// Cannot be String! because of FwAny


	@Published var selfiePole	= SelfiePole()


	 // Hierarchy:
	var fullName	: String	{
		name=="_ROOT" ? name :	// Leftmost component
		parent==nil   ? ""   :
		parent!.fullName + "/" + name		// add lefter component
	}
	@Published var color000	: NSColor? = nil
	{	willSet(v) {	part.markTree(dirty:.paint)							}	}
	var keep		:  Bool		= false		// used in reVew
	var parent		:  Vew?		= nil
	var children 	: [Vew]		= []
	var child0		:  Vew?		{	return children.count == 0 ? nil : children[0] }
	var rootVew		: RootVew?	{	rootVewRaw as? RootVew						}
	var rootVewRaw	:  Vew?		{	parent?.rootVewRaw ?? self	/* RECURSIVE */	}

	 // Glue these Neighbors together: (both Always present)
	@Published var part : Part 				// Part which this Vew represents	// was let
	var scn			:  SCNNode				// Scn which draws this Vew

	 // Used for construction, which must exclude unplaced members of SCN's boundingBoxes
	var bBox 		:  BBox		= .empty	// bounding box size in my coorinate system (not parent's)

	@Published var expose : Expose	= .open {// how the insides are currently exposed
		willSet(v) {
			if v != expose, parent != nil {		// ignore simple cases
				print("--- '\(fullName)'.expose.willSet: \(expose) -> \(v)")
				part.markTree(dirty:.vew)
			}
		}
	}
	var jog			: SCNVector3? = nil		// an ad-hoc change in position
	var force		: SCNVector3 = .zero 	// for Animation for positioning
																				 // Branch's Actor call for atomic?
																				//		if p is Branch ||			// we are Branch
																				//		   p is Leaf 		{			// we are Leaf
																				//			if let a = p.parent.enclosedByClass("Actor"),
																				//			  a.viewAsAtom {						// wants us to be atom
																				//					return true													}
	//	// Several ways to flip, each has problems:
	// 1. ugly, inverts Z along with Y: 	scn.rotation = SCNVector4Make(1, 0, 0, CGFloat.pi)
	// 2. IY ++, Some skins show as black, because inside out: 		scale = SCNVector3(1, -1, 1)
	// 3. causes Inside Out meshes, which are mostly tollerated:	scn.transform.m22 *= -1


	var log : Log			{ 	part.log 								}


	 // MARK: - 3. Factory
	init(forPart p:Part?=nil, scn s:SCNNode?=nil, expose expose_:Expose? = nil) {
		let part				= p ?? .null
		self.part 				= part
		self.name				= "_" + part.name 	// View's name is Part's with '_'
		self.expose				= expose_ ?? part.initialExpose

		 // Make SCN from supplied skin:
		scn						= s ?? SCNNode()
		scn.name 				= self.scn.name ?? ("*-" + part.name)

		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		  // Visible Shape:
		// Jog
		if let jogStr	 		= part.localConfig["jog"]?.asString,
		   let jogVect 			= SCNVector3(from:jogStr) ??
		  						  SCNVector3(from:jogStr + " 0") ??
		  						  SCNVector3(from:jogStr + " 0 0") {
			jog 				= jogVect
		}
	}
	init(forPort port:Port) {
		self.part 				= port
		self.name				= "_" + port.name 	// Vew's name is Part's with '_'
		self.expose				= .open

		 // Make new SCN:
		scn						= SCNNode()
		scn.name 				= "*-" + port.name

		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		 // Flip
		let portProp	: String? = port.localConfig["portProp"] as? String //"xxx"//
		scn.flipped				= portProp?.contains(substring:"f") ?? false
	}
	 // MARK: - 3.5 Codable
	enum VewKeys : CodingKey { 	case name, color000, keep, parent, children, part, scn, bBox, jog, force}
	func encode(to encoder: Encoder) throws {
//		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:VewKeys.self)
		try container.encode(name, 		forKey:.name 	)
	//	try container.encode(color000,	forKey:.color000)
		try container.encode(keep, 		forKey:.keep	)
		try container.encode(parent, 	forKey:.parent	)
		try container.encode(children, 	forKey:.children)
		try container.encode(part, 		forKey:.part 	)
	//	try container.encode(scn, 		forKey:.scn		)
		try container.encode(bBox, 		forKey:.bBox 	)
		try container.encode(jog, 		forKey:.jog		)
		try container.encode(force, 	forKey:.force	)
		atSer(3, logd("Encoded  as? Path        '\(String(describing: fullName))'"))
	}
	required init(from decoder: Decoder) throws {
		let container 			= try decoder.container(keyedBy:VewKeys.self)
		name 					= try container.decode(		String.self, forKey:.name 	)
	//	color000				= try container.decode(	  NSColor?.self, forKey:.color000)
		keep					= try container.decode(		  Bool.self, forKey:.keep	)
		parent					= try container.decode( 	  Vew?.self, forKey:.parent	)
		children				= try container.decode(		 [Vew].self, forKey:.children)
		part 					= try container.decode(		  Part.self, forKey:.part 	)
	//	scn						= try container.decode(	   SCNNode.self, forKey:.scn	)
		bBox 					= try container.decode(		  BBox.self, forKey:.bBox 	)
		jog						= try container.decode(SCNVector3?.self, forKey:.jog	)
		force					= try container.decode(SCNVector3 .self, forKey:.force	)
		scn						= SCNNode()		// OOOOPS

		super.init()
 		atSer(3, logd("Decoded  as? Vew       named  '\(String(describing: fullName))'"))
	}
	 // MARK: - 4.2 Manage Tree
	 /// Array of ancestor. The first element is self, last is rootVew:
	var selfNParents : [Vew] {
		return selfNParents()
	}
	func selfNParents(upto:Vew?=nil) -> [Vew] {
		var rv	   : [Vew]		= [] 				// [self,...,rootVew]
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
	/// Add child Vew to self, and childs's scn to self.scn
	/// - Parameters:
	///   - vew: to add
	///   - ind: index to insert before
	func addChild(_ vew:Vew?, atIndex ind:Int?=nil) {
		guard let vew else {
			return							// no part, nuttin to do
		}
		if let ind {					// Index specified
			children.insert(vew, at:ind)
		}
		else {								// Index nil --> append
			children.append(vew)
		}
		vew.parent 				= self
//      assert(part.parent == parent?.part, "fails consistency check")
        part.parent?.markTree(dirty:.size)	// Affects parent's size
//      part.markTree(dirty:.vew)

		// Add the "entry SCNNode" for the vew
		scn.addChild(node:vew.scn)			// wire scn tree isomorphically
	}
	func replaceChild(_ oldVew:Vew?, withVew newVew:Vew) {
		let i					= children.firstIndex(where: {$0 === oldVew ?? .null})
		oldVew?.scn.removeFromParent()		// remove old
		oldVew?.removeFromParent()
		addChild(newVew, atIndex:i)			// add new
		part.markTree(dirty:.size)			// recalculate size
	}
	 // Remove if parent exists
	func removeFromParent() {
		if let i		 		= parent?.children.firstIndex(where: {$0 === self}) {
			parent?.children.remove(at:i)
			parent?.part.markTree(dirty:.size)	//.vew
		}else{
			panic("\(pp(.fullNameUidClass)).removeFromParent(): not in parent:\(parent?.pp(.fullNameUidClass) ?? "nil")")
		}
	}
	func removeAllChildren() {
		for childVew in children { 			// Remove all child Vews
			childVew.scn.removeFromParent()		// Remove their skins first (needed?)
			childVew.removeFromParent()			// Remove them
		}
	//	part.markTree(dirty:.vew)
//		scn.removeAllChildren()				// wipe out my skin
	}

	func nodeCount() -> Int {
		var rv					= 0
		forAllSubViews {
		vew in
			rv					+= 1
		}
		return rv
	}

	typealias VewOperation 		= (Vew) -> ()
	func forAllSubViews(_ viewOperation : VewOperation)  {
		viewOperation(self)
		for child in self.children {
			child.forAllSubViews(viewOperation)
		}
	}
	 /// Lookup configuration from Part's localConfig, and scene
	func config(_ name:String) -> FwAny? {
		for s in selfNParents {				// s = self, parent?, ..., root, cap, 0
			if let rv			= s.part.localConfig[name] {
				return rv						// return an ancestor's config
			}
		}
		let fwGuts				= rootVew?.fwGuts
		assert(fwGuts == part.root?.fwGuts, "paranoia: fwGuts mismatch")		//(fwGuts==nil || fwGuts! == part.root?.fwGuts
		return falseF ? nil : fwGuts?.document.config[name] //trueF//falseF//
//Thread 1: Simultaneous accesses to 0x600001249118, but modification requires exclusive access
	}

	 // MARK: - 4.6 Find Children
	 /// FIND child Vew by its NAME:
	func find(name:String,					inMe2 searchSelfToo:Bool=false,
				all searchParent:Bool=false, maxLevel:Int?=nil) -> Vew?
	{
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.name == name		// view's name matches
		}
	}
	 /// FIND child Vew by its PART:
	func find(part:Part, 				 	 inMe2 searchSelfToo:Bool=false,
				all searchParent:Bool=false, maxLevel:Int?=nil) -> Vew?
	{
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.part === part	// view's part matches
//			return vew.part == part		// view's part matches
		}
	}
	 /// FIND child Vew by its Part's NAME:
	func find(forPartNamed name:String,		 inMe2 searchSelfToo:Bool=false,
				all searchParent:Bool=false, maxLevel:Int?=nil) -> Vew?
	{
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.part.name == name	// view's part.name matches
		}
	}
	 /// FIND child Vew by its SCNNode:	// 20210214PAK not used
	func find(scnNode node:SCNNode,		 	inMe2 searchSelfToo:Bool=false,
				all searchParent:Bool=false, maxLevel:Int?=nil) -> Vew?
	{
		return find(inMe2:searchSelfToo, all:searchParent, maxLevel:maxLevel)
		{(vew:Vew) -> Bool in
			return vew.scn == node			// view's SCNNode
		}
	}
		/// find if closure is true:
	func find(inMe2 searchSelfToo:Bool=false, all searchParent:Bool=false, maxLevel:Int?=nil, except exception:Vew?=nil,
			  firstWith closureResult:(Vew) -> Bool) -> Vew?
	{
		 // Check self:
		if searchSelfToo,
		  closureResult(self) {				// Self match
			return self
		}
		if (maxLevel ?? 1) > 0 {			// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
			 // Check children:
			//?let orderedChildren = upInWorld ? children.reversed() : children
			for child in children where child != exception {	// Child match
				if let sv		= child.find(inMe2:true, all:false, maxLevel:mLev1, firstWith:closureResult) {
					return sv
				}
			}
		}
		 // Check parent
		if searchParent {
			return parent?.find(inMe2:true, all:true, maxLevel:maxLevel, except:self, firstWith:closureResult)
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
			let vewScn			= vew.scn.physicsBody==nil ? vew.scn
														   : vew.scn.presentation
			let pInParent		= vewScn.transform * position
					// RECURSIVE
			let rv				= localPosition(of:pInParent, inSubVew:vewParent)

			atRsi(9, log("localPosition(of:\(position.pp(.short)), inSubVew:'\(vew.parent!.pp(.fullName))' returns \(rv.pp(.short))"))
			return rv
		}
		fatalError("localPosition(of:\(position.pp(.short)), inSubVew:'\(vew.pp(.fullName))' HAS NO PARENT")
	}
	func localPositionX(of position:SCNVector3, inSubVew vew:Vew) -> SCNVector3 {
//		atRsi(6, log("localPosition(of:\(position.pp(.line)), inSubVew:'\(vew.parent!.pp(.fullName))')"))
		 // Go from vew toward self
		if vew == self {
			return position
		}
		if let vewParent		= vew.parent {
			let vewScn			= vew.scn.physicsBody==nil ? vew.scn
														   : vew.scn.presentation
			let vewParentScn	= vewParent.scn.physicsBody==nil ? vewParent.scn
																 : vewParent.scn.presentation
			let pInParent		= vewScn.transform * position
			// we now have position in our parent's view
			let rv				= vew.localPosition(of:pInParent, inSubVew:vewParent)

//			let activeScn		= vew.scn.physicsBody==nil ? vew.scn : vew.scn.presentation
//			let pInParent		= activeScn.transform * position
//			let rv				= convert(position:pInParent, in:vewParent)
	//		rv					= convertPosition(rv, from:activeScn)
			atRsi(9, log("localPosition(of:\(position.pp(.short)), inSubVew:'\(vew.parent!.pp(.fullName))' returns \(rv.pp(.short))"))
			return rv
		}
		fatalError("localPosition(of:\(position.pp(.short)), inSubVew:'\(vew.parent!.pp(.fullName))' FAILED")
//		 /// Go from vew toward self
//		var rv					= position
//		atRsi(9, log(" position=\(rv.pp(.line))  (in \(vew.pp(.fullName)))"))
//		for v in vew.selfNParents(upto:self) {	// vew, v+, ... s-, self
//			if let parentsScn 	= v.parent?.scn {
//				let activeScn	= v.scn.physicsBody==nil ? v.scn : v.scn.presentation
//				rv				= parentsScn.convertPosition(rv, from:activeScn)
//				atRsi(9, log(" position=\(rv.pp(.line))  (in \(v.parent!.pp(.fullName)))"))
//			}
//		}
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
//		return scn.convertPosition(windowPositionV3, from:nil)
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
		atRsi(5, log(" in parent:  bBox=\(sBBoxInP.pp(.line)), ctr=\(sCenterInP.pp(.line)). Relevant Spots:"))
		atRsi(5, logSpots(relevantSpots))

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
					atRsi(8, log("%3d+\(dir): overlaps %-3d! c:\(tryBBox.center.pp(.line))", i, ol))
				}
				else {
					 // ADD one of 4 SPOTs around placedSpot to spots, to check later
					let newSpot	= SpotData(state:.added, bBox:tryBBox, vew:nil)
					atRsi(5, log("   \(relevantSpots.count): \(newSpot.pp())") )
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

		scn.position			+= movedBy
		atRsi(4, log("<<===== Moved by \(movedBy.pp(.short)) to \(scn.transform.position.pp(.short))"))
	}
	func orBBoxIntoParent() {
		if let parentVew 		= parent {
			let myBip 			= bBox * scn.transform
			parentVew.bBox		|= myBip	// Accumulate me into parent
		}
	}
	func logSpots(_ spots:[SpotData]) {		// Print for debug
		for (i, spot) in spots.enumerated() {
			log("   \(i): \(spot.pp())")
		}
	}

	// MARK: - 9 Update Vew + :
	   /// Update the Vew Tree from Part Tree
	  /// - Parameter as:		-- name of lock owner. Obtain no lock if nil.
	 /// - Parameter log: 		-- log the obtaining of locks.
	func updateVewSizePaint(vewConfig:VewConfig?=nil, needsLock named:String?=nil, logIf log:Bool=true) { // VIEWS
		guard let fwGuts		= part.root?.fwGuts else {	print("Paranoia 29872"); return }
		guard let fwGuts2		= rootVew?  .fwGuts else {	print("Paranoia 23872"); return }
		assert(fwGuts === fwGuts2, "Paranoia i5205")
		var needsViewLock		= named		// nil if lock obtained
		let vRoot				= self
		let pRoot				= part.root!
		guard let pTrunk		= pRoot.children.first else {print("Paranoia 48080"); return }

/**/	SCNTransaction.begin()
		SCNTransaction.animationDuration = CFTimeInterval(0.15)	//0.3//0.6//

				 /// Is Part Tree dirty? If so, obtain lock
				 /// - Parameters:
				 ///   - dirty: kind of dirty (.vew, .size, or .paint) to check
				 ///    - viewLockName: Owner of lock; nil -> no lock needed
				 ///     - log: log the message
				 ///      - message: massage to log
				 ///      - Returns: Work
				func hasDirty(_ dirty:DirtyBits, needsViewLock viewLockName:inout String?, log:Bool, _ message:String) -> Bool {
					if pRoot.testNReset(dirty:dirty) {		// DIRTY? Get VIEW LOCK:
						guard let fwGuts = part.root?.fwGuts else {	fatalError("### part.root?.fwGuts is nil ###")		}

						 // Lock  _ALL_  root Vews:
						for rootVew in fwGuts.rootVews {
							guard rootVew.lock(vewTreeAs:viewLockName, logIf:log) else {
								fatalError("updateVewSizePaint(needsViewLock:'\(viewLockName ?? "nil")') FAILED to get \(viewLockName ?? "<nil> name")")
							}
						}
						viewLockName = nil		// mark gotten
						return true
					}
					return false
				}

		 // ----   Create   V I E W s   ---- // and SCN that don't ever change
		if hasDirty(.vew, needsViewLock:&needsViewLock, log:log,
			" _ reVew _   Vews (per updateVewSizePaint(needsLock:'\(needsViewLock ?? "nil")')") {

			if let vewConfig, false {					// NEW WAY
				atRve(6, log ? logd("updateVewSizePaint(vewConfig:\(vewConfig):....)") : nop)
				pTrunk.adorn(in:vRoot, openChildrenUsing:vewConfig)
			}
			else {								// OLD WAY
				atRve(6, log ? logd("updateVewSizePaint(vewConfig:nil:....)") : nop)
				  // Update Vew tree objects from Part tree
				 // (Also build a sparse SCN "entry point" tree for Vew tree)
/**/			pRoot.reVew(vew:vRoot, parentVew:nil)
			}
			pRoot.reVewPost(vew:vRoot)
		}
		 // ----   Adjust   S I Z E s   ---- //
		if hasDirty(.size, needsViewLock:&needsViewLock, log:log,
			" _ reSize _  Vews (per updateVewSizePaint(needsLock:'\(needsViewLock ?? "nil")')") {
			atRsi(6, log ? logd("rootPart.reSize():............................") : nop)

/**/		pRoot.reSize(vew:vRoot)				// also causes rePosition as necessary
			
			vRoot.bBox			|= BBox.unity		// insure a 1x1x1 minimum
								
			pRoot.rePosition(vew:vRoot)				// === only outter vew centered
			vRoot.orBBoxIntoParent()
			pRoot.reSizePost(vew:vRoot)				// ===(set link Billboard constraints)
	//		vRoot.bBox			= .empty			// Set view's bBox EMPTY
			atRsi(6, log ? logd("..............................................") : nop)
		}
		 // -----   P A I N T   Skins ----- //
		if hasDirty(.paint, needsViewLock:&needsViewLock, log:log,
			" _ rePaint _ Vews (per updateVewSizePaint(needsLock:'\(needsViewLock ?? "nil")')") {

/**/		pRoot.rePaint(vew:vRoot)				// Ports color, Links position

			 // THESE SEEM IN THE WRONG PLACE!!!
//			pRoot.computeLinkForces(vew:vRoot) 		// Compute Forces (.force == 0 initially)
//			pRoot  .applyLinkForces(vew:vRoot)		// Apply   Forces (zero out .force)
			pRoot .rotateLinkSkins (vew:vRoot)		// Rotate Link Skins
		}
		let unlockName			= named == nil ? nil :	// no lock wanted
								  needsViewLock == nil ? named :// we locked it!
								  nil							// we locked nothing
/**/	SCNTransaction.commit()
		for rootVew in fwGuts.rootVews {
			rootVew.unlock(vewTreeAs:unlockName, logIf:log)	// Release VIEW LOCK
		}
	}

	 // MARK: - 9.5 Wire Box
	func updateWireBox() {

		 // Determine color0, or ignore
		let wBoxStr				= config("wBox")?.asString	// master
//		let wBoxStr				= part.config("wBox")?.asString	// master
		let myColor : NSColor?	= 				// Config declares:
			wBoxStr  == nil 	 ?	.red 		:	// red for debug
//			wBoxStr  == nil 	 ?	nil 		:	// nothing about Part
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
		let wBoxScn	: SCNNode		= scn.find(name:"w-", prefixMatch:true, maxLevel:1) ??	// 20210912PAK SStep BAD Here
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
			 // Name the result
			var doc				= DOC!
			let wBoxNameIndex	= doc.indexFor["WBox"] ?? 1
			doc.indexFor["WBox"] = wBoxNameIndex + 1
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
	 // MARK: - 14. Logging
	func log(banner:String?=nil, _ format:String, _ args:CVarArg..., terminator:String?=nil) {
		let (nl, fmt)			= format.stripLeadingNewLines()
		if let rootVew {
			rootVew.fwGuts.log(banner:banner, nl + fullName.field(12) + ": " + fmt, args, terminator:terminator)
		}else if let root		= part.root {	// strangely redundant, but okay
			root.fwGuts.log(banner:banner, nl + fullName.field(12) + ": " + fmt, args, terminator:terminator)
		}else{
			Log.help.log(banner:banner, nl + fullName.field(12) + ": " + fmt, args, terminator:terminator)
		}
	}
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
		switch mode! {
			case .name:
				return self.name
			case .fullName:
				return self.fullName
			case .phrase, .short:
				var rv 			= name + ppUid(pre:"/", self) + ":" + fwClassName + " "
				rv 				+= "->"  + part.pp(.fullNameUidClass)
				rv				+= ", ->" + scn.pp(.fullNameUidClass)
				return rv
			case .line:
				let ppViewOptions = aux.string("ppViewOptions") ?? "UFVSPLETBIW" // Default to ALL
				let ppViewTight = aux.bool_("ppViewTight")
				func tight<T>(_ a:T, _ b:T) -> T 	{ 	return ppViewTight ? a : b	}

				  // 	(Tight==false:)
				 //  a68:Ff|    _net0:NetVew  s:  *-net0/2a0 p:  net0/aff:Net   . . . .  o+pI[-0.6-1.5-0.0]     w[-0.6-1.5-100.0] f-2.0< 3.2, -1.1< 4.1, -2.0< 2.0
				 //  AaaaBbCcDddddddddEeeeeeeFffffffffffGgggHhhIiiiiiJjjjjKkkkkkLlllllllMmmNnnnnnnnnnnnnnnnOoooooooooooooooooooooPpppppppppppppppppppppppppppppppp
				 //  c77:Ff|     _v:Vew      *-v/6a4       v/6a4:Mirror. . . . .  o+IY[y:-0.4]  f=-1.5< 1.5, -1.0< 0.1, -1.5< 1.5
				 //  AaaaBbCcDddddddEeeeFffffffffGgggHIiiiiiIiiiJKkkkkkLlllllllllMmmNnnnnnnnnnnnPpppppppppppppppppppppppppppppppp

				var rv			= ""						// /// PLACEMENT:
				if ppViewOptions.contains("U") {				 	// Uid:
					rv			+= ppUid(self, post:":")	 	 		  // (A)
				}
				if ppViewOptions.contains("F") {				 	// Flipped:
					rv			+= part.upInWorld ? "F" : " "			  // (B)
					rv			+= part.flipped   ? "f" : " "			  // (B)
				}
															// Indent
				rv 				+= log.indentString() 				  // (C)
				if ppViewOptions.contains("V") {					// Vew (self):
					rv			+= name.field(tight(6,8),dots:false) + ":"// (D) VIEW and MODEL names:
					rv			+= fwClassName.field(-tight(5,7),dots:false)// (E)
				}
															// /// LINKAGES:
				if ppViewOptions.contains("S") {					// Scn:
					rv			+= tight("", " s:")						  // (F)
					rv			+= (scn.name ?? "<none>").field(tight(5,8), dots:false)
					rv			+= ppUid(pre:"/", scn)					  // (G)
				}
				if ppViewOptions.contains("P") {					// Part:
					rv			+= tight("", " p:")						  // (H)
					rv			+= part.name.field(6)					  // (I)
					rv			+= ppUid(pre:"/", part) + ":"			  // (J)
					rv			+= part.pp(.fwClassName).field(-tight(4,6), dots:false) // (K)
				}
															// /// SKINS:
																	// UNIndent
				rv 				=  log.unIndent(rv)					  // (L)

				if ppViewOptions.contains("L") {					 // Leaf:
					let s		= self as? NetVew
					rv			+= s==nil ? "   " :
								   "\(s!.heightLeaf)/\(s!.heightTree)"
				}
				if ppViewOptions.contains("E"),					 	// Expose:
				  !ppViewTight {
					rv			+= " " + expose.pp(.short, aux)			  // (M)
					rv			+= keep ? "+" : "-"						  // (M)
				}
				var rv1			= ""						// /// POSITIONS:
				if ppViewOptions.contains("T") {				 	// Transform:
					let tr		= scn.transform.pp(.phrase, aux)		  // (N)
					rv1			+= tr=="I" ? "" : (tight("", " p") + tr + " ")
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

				let rScn		= rootVew?.scn ?? .null
				rv				+= !ppViewOptions.contains("W") ? ""
								:  "w" + scn.convertPosition(.zero, to:rScn).pp(.short) + " "
				if !(self is LinkVew) {
					 // SceneKit's BBox:
					if aux.bool_("ppScnBBox") {
						rv += tight("", "s") + scn.bBox().pp(.line, aux)
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
				return ppDefault(self:self, mode:mode, aux:aux) // NO: return super.pp(mode, aux)
		}
	}

	func panic(_ message: @autoclosure () -> String=("")) { //ppUid(self)
		print("\n\n\(fullName) \(log.ppCurThread) \(pp(.fullNameUidClass))" +
			": --------------\n\(message())\n" + "----------------------------\n")
		machineTrap()				// transfer control to debugger
	}

	  // MARK: - 16. Global Constants
	static let null 			= Vew(forPart:.null)	/// Any use of this should fail

	 // MARK: - 17. Debugging Aids
	override var description	  : String {	return  "d'\(pp(.short))'"		}
	override var debugDescription : String {	return "dd'\(pp(.short))'" 		}
	var summary					  : String {	return  "s'\(pp(.short))'" 		}
	 // MARK: - 20. Extension variables
	var adornTargetVew 			  : Vew?	= nil
}
