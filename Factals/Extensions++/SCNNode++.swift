 //  SCNNode++.swift -- Customization of SceneKit C2018PAK

import SceneKit

//	SCNNode 'name' Convention:
//		*-<name>	-- SCNNode pointed to by	  Vew _<name>
//		s-<name>	-- SCNNode used for Skin of Vew _<name>
//		w-...		-- SCNNode bounding box  of Vew _<name>
//j∆

extension SCNNode /*: HasChildren */ {		// : FwAny from SceneKit (extension)
	typealias T = SCNNode
	typealias TRoot = SCNNode
																				//extension SCNNode : HasChildren  {
																				//class SCNNodeFW : SCNNode, HasChildren   {
																				//	typealias T = SCNNode
																				//	typealias TRoot = SCNNode
																				//
																				//	var nam : String {//Cannot override mutable property 'name' of type 'String?' with covariant type 'String'
																				//		get 		{		return super.name ?? "<>"							}
																				//		set(v)		{		super.nam = v										}
																				//	}	// Function call causes an infinite recursion
																				//	var fullName: String {
																				//		get			{	fatalError()											}
																				//	}
																				//	var children: [SCNNode] {
																				//		get 		{	fatalError();return []}//childNodes										}
																				//		set(v)		{	fatalError() 											} //childNodes = v }
																				//	}
																				//	var child0 :  SCNNode?	{	childNodes.count == 0 ? nil : childNodes[0] as? SCNNode 	}
																				//	override var parent: SCNNode? {
																				//		get 		{	fatalError()											}//self.parent}
																				//		set(v) 		{	fatalError()											}//self.parent = v}
																				//	}
																				//	var root		:  SCNNode?	{
																				//		get 		{	debugger("Vew has no .partBase")}
																				//		set(v)		{	debugger("Vew has no .partBase")}
																				//	}
																				//
																				//	func addChild(_ child: SCNNode?, atIndex index: Int?) {
																				//		fatalError()
																				//	}
																				//
																				//	func removeChildren() {
																				//		fatalError()
																				//	}
	// Superclass properties of interest:
	//\\var 	transform
	//\\var 	position
	//\\var		worldTransform
	//\\var		geometry
	//\\var		parent, childNodes
	//\\var?	physics system
	//\\var?	audioPlayers			// UNUSED:
	//\\var		actionKeys: [String] 	// The list of keys for which the node has attached actions.

//	 // MARK: - 2. Sugar for Object Variables:
//	var name: String {	get	set		}
	var children: [SCNNode] 	{
		get 	{ childNodes }
		set(v) 	{ fatalError() }
	}
	var child0: SCNNode? 		{	get { childNodes[0] }						}
																				//	var parent: SCNNode? 		{	get	set		}
																				//	var root: SCNNode? 			{	get	set		}
																				//	var fullName: String 		{	get	set		}
																				//	var fullName: String 		{	get	{ fatalError()							} }
	func forAllChildren(_ fun:(SCNNode) -> ()) {
		fun(self)
		for child in children {
			child.forAllChildren(fun)
		}
	}
	func nodeCount() -> Int {
		var rv					= 0
		forAllChildren { vew in
			rv					+= 1
		}
		return rv
	}


//	 /// Color of material[0]
//	// Should figure out a Kosher way of setting colors
	var color0 : NSColor {
		get {	 material_0()?.diffuse.contents as? NSColor ?? .black		}
//		get {	 material_0()?.reflective.contents as? NSColor ?? .black		}
		set(newColor) {
			if let m 			= material_0() {
				m.lightingModel	= .blinn		// 190220 Try it out!s
				//m0?.locksAmbientWithDiffuse = true
				///https://www.raywenderlich.com/2243-scene-kit-tutorial-getting-started self[k]!.asCGFloat
				var color2		= newColor
				if let skinAlpha = FACTALSMODEL?.fmConfig.cgFloat("skinAlpha") {
					color2		= color2.change(alphaTo:skinAlpha)
				}
				m.diffuse.contents = color2
				m.specular.contents = NSColor.white
			}
		}
	}




	 // Several ways to flip, each has problems:
	  /// 1. ugly, inverts Z along with Y:
	 //rotation 				= SCNVector4Make(1, 0, 0, CGFloat.pi)
	  /// 2. IY ++, Some skins show as black, because inside out
	 //scale 					= SCNVector3(1, -1, 1)
	 var flipped : Bool? {
		 /// 3. causes Inside Out meshes, which are mostly tollerated
		 get {			/// Transform CGFloat to Bool?
			 let m22			= transform.m22
			 return m22 ~== 1.0 ? true : m22 ~== -1.0 ? false : nil
		 }
		 set (value) {	/// Transform Bool? to CGFloat
			 transform.m22	= value == true ? -1.0 : 1.0
		 }
	 }
	 /// Set Colors of material[0]:
	func color0(		diffuse		: NSColor?=nil,
						specular	: NSColor? = nil,
						ambient		: NSColor? = nil,
						reflective	: NSColor? = nil,
						metalness	: NSColor? = nil,
						roughness	: NSColor? = nil,
						multiply	: NSColor? = nil,
						normal		: NSColor? = nil,
						emission	: NSColor? = nil,
						transparent	: NSColor? = nil)
	{
		let m0 = material_0()
		//m0?.locksAmbientWithDiffuse = true
		m0?.lightingModel		= .blinn		// 190220 Try it out!s
		if diffuse != nil {
  			m0?.diffuse.contents = diffuse!			//NSColor("darkGray")
		}
		if specular != nil {
  			m0?.specular.contents = specular!		//NSColor.white
		}
		if ambient != nil {
  			m0?.ambient.contents = ambient!			//NSColor("darkGray")
		}
		if reflective != nil {
  			m0?.reflective.contents	= reflective!	//NSColor("darkGray")
		}
		if metalness != nil {
  			m0?.metalness.contents = metalness!		//NSColor("darkGray")
		}
		if roughness != nil {
  			m0?.roughness.contents = roughness!		//NSColor("darkGray")
		}
		if multiply != nil {
  			m0?.multiply.contents = multiply!		//NSColor("darkGray")
		}
		if normal != nil {
  			m0?.normal.contents = normal!			//NSColor("darkGray")
		}
		if emission != nil {
  			m0?.emission.contents = emission!		//NSColor("darkGray")
		}
		if transparent != nil {
  			m0?.transparent.contents = transparent!	//NSColor("darkGray")
		}
	}
	func material_0() -> SCNMaterial? {
		let geom : SCNGeometry? = geometry 			// I have a geometry
						?? (childNodes.count <= 0 ? nil // no child nodes
						  : childNodes[0].geometry)	// child node has geometry
		assert(geom != nil, "Setting color0 before its geometry has been established")
		geom!.name				= "material"

		var rv 		: SCNMaterial? = geom?.materials[0]
		if rv==nil {
			rv 					= SCNMaterial()
			geom!.materials.append(rv!)
		}
		return rv!
	}
////	var focusBehavior: SCNNodeFocusBehavior
//	   // Q: This occurs in Part, Vew, and SCNNode!
//	//	var transform	: SCNMatrix4 {
//	//		get {
//	//			return (self as SCNNode).transform
//	//		}
//	//		set(newXform) 			{
//	//			assert(self != SCNNode.stopit, "found stopit SCNNode")
//	//			self.transform 	= newXform
//	//		}
//	//	}
//	//	var transform	: simd_float4x4 {
//	//		get {
//	//			return self.simdTransform
//	//		}
//	//		set(newXform) 			{
//	//			assert(self != SCNNode.stopit, "found stopit SCNNode")
//	//			self.simdTransform 		= newXform
//	//		}
//	//	}
//	// 	// root of tree (Cap Vew) has nil parent
//	//	static var stopit : SCNNode? = nil
	func bBox() -> BBox				{
		let s					= self
		let b					= s.boundingBox
		return BBox(b.min, b.max)
	}

//	  // MARK: - 3. Factory
//	  /// Make from LINES
//	 convenience init(lines:[Int32], withPoints points:[SCNVector3], color0:NSColor = .black, name:String? = nil) {
//		 let material 			= SCNMaterial()
//		 material.diffuse.contents = color0		// BUG doesn't work, all are white
//		 material.lightingModel = .blinn
//		 let source 			= SCNGeometrySource(vertices:points)
//		 let element 			= SCNGeometryElement(indices:lines, primitiveType:.line)
//		 let line 				= SCNGeometry(sources:[source], elements:[element])
//		 line.name 				= name ?? line.name
//
//		 self.init(geometry: line) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//
//		 self.name				= name
//		 geometry?.materials 	= [material]
//	 }

	 // MARK: - * PRocess envent

	 // MARK: - 4.2 Manage Tree
	var fullName : String {
		parent==nil  ? 		"/" + (name ?? "???") :
							parent!.fullName + "/" + (name ?? "???")
	}
	  /// Add child node
	 /// Semantic Sugar, to make SCNNode, Vew, and Part all use term children
	/// - entries are unique
	func addChild(node:SCNNode, atIndex index:Int?=nil) {
		guard !childNodes.contains(node) else { debugger("no duplicates allowed")}
		let ind					= index ?? children.count
		insertChildNode(node, at:ind)
	}

	func removeAllChildren() {
		for s in children {
			s.removeFromParent()			// remove all child SCNs
		}
	}
	func removeFromParent() {
		removeFromParentNode()				// remove scnScene from parent
	}

	var root : SCNNode {
		return self.parent?.root ?? self
	}
	 // MARK: - 4.6 Find Children
	// WHY THESE TWO?
	 /// flat search of one layer.
	func findScn(named:String, prefixMatch:Bool=false, maxLevel:Int?=nil) -> SCNNode? 	{
		 /// Check children only to 1 level:
		return find(inMe2:false, all:false, maxLevel:maxLevel, firstWith:
		{(scn:SCNNode) -> Bool in
			return prefixMatch ?
					scn.name?.hasPrefix(named) ?? false :
					scn.name == named
			// return scn.name == name	// previous hash
		} )
	}

	 /// First where closure is true:
	typealias ScnPredicate 	= (SCNNode) -> Bool
	func find(inMe2				:Bool		= false,
			  all searchParent	:Bool 		= false,
			  maxLevel			:Int?		= nil,
			  except exception	:SCNNode? 	= nil,
			  firstWith closureResult:ScnPredicate)-> SCNNode? /// Search by closure:
	{
		 /// Check self:
		if inMe2,
		  closureResult(self) {			// Self match?
			return self
		}
		if (maxLevel ?? 1) > 0 {		// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
			 /// Check children:
			for child in children where child != exception { // don't redo exception
				if let rv 		= child.find(inMe2:true, all:false, maxLevel:mLev1, firstWith:closureResult) {
					return rv
				}
			}
		}
		 /// Check parent
		if searchParent {
			return parent?.find(inMe2:true, all:true, maxLevel:maxLevel, except:self, firstWith:closureResult)
		}
		return nil
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String {
		
		let log					= Log.shared
		var rv					= ""
//		 // UGLY: Can't override an extension
//		if let imARootNode		= self as? ScnBase {
//			rv					+= imARootNode.pp(mode, aux)
//		}

		switch mode {
		case .name:
			rv					= name ?? "_"
		case .fullName:			//return fullName
			rv 					+= name == "*-ROOT" ? "" :										// stop-condition of recursion
								(parent?.pp(.fullName) ?? "") + "/" + (name ?? "unnamed225")	// RECURSION
		case .fullNameUidClass, .short:
			let fn				= fullName
			return "\(ppUid(self, post:"."))\(fn):\(fwClassName)"
		case .phrase:
			rv					= "SCNNode[ " + (name ?? "")  + ":"
			rv					+= pp(.fwClassName, aux).field(-3, dots:false)
		case .line:
			//AaaBbbbbbCcccccccDdddddEeeeeeeeeeeeeeeeeeeeeeeeeFffGggggggggggggggggggggggggggggggggggggggggg
			//1eb| | | s-Port  . . . p=I[y: 0.1]              01 <Cylinder: 'material' 3 eltsr=1.0 h=0.190>
			rv					= log.pidNindent(for:self)		//			(AB)
			rv					+= "\((name ?? "UNNAMED ").field(-8, dots:false))"//(C)
			rv 					= log.unIndent(rv)				// unindent (D)
			rv					+= self.scn1Line(aux) 			//		    (E..G)
		case .tree:
			 /// 1. MAIN: print self on 1 line
			rv					= pp(.line, aux) + "\n"

			 /// 2. Create SCNNode Physics Body line:
			if physicsBody?.type == .dynamic,
			  transform != presentation.transform {	// presentationInstance isPresentationInstance
				let pbStuff		= physicsBody == nil ? " \\" :
								  " \\PB\(physicsBody!.isAffectedByGravity ? ":gra" : "")"
				let pbs2		= pbStuff.field(-8, dots:false, fill:"_")
				rv				+= log.pidNindent(for:presentation) + pbs2
				rv 				=  log.unIndent(rv)
				rv				+= presentation.scn1Line(prefix:"", aux) + "\n"
			}

			 /// 3. SCNNode Constraints:
			for constraint in constraints ?? [] {
				rv				+= log.pidNindent(for:constraint) + " \\"
				log.nIndent	+= 1
				let nicknames	= ["SCNLookAtConstraint":"LookAt",
								   "SCNBillboardConstraint":"Billboard"]
				var cName		= nicknames[constraint.fwClassName] ?? constraint.fwClassName
				if let c 		= constraint as? SCNLookAtConstraint,
				  let cTarget	= c.target {
					cName		+= ": " + cTarget.fullName
				}
				rv				+= "\(cName)\n"
				log.nIndent	-= 1
			}
					/* Also someday: SCNPhysicsField, SCNParticleSystem */
			 /// 4. Materials
			log.nIndent		+= 1
			if aux.bool_("ppScnMaterial") {
				for material in geometry?.materials ?? [] {
					rv			+= " " + material.ppSCNMaterialColors(debugDescription) + "\n"
					rv			+= material.pp(.line) + "\n"
				}
			}
			 /// 5. SCNAudioPlayer Sound
			for audioPlayer in audioPlayers {
				rv				+= log.pidNindent(for:audioPlayer) + " \\sound:"
				rv 				=  log.unIndent(rv) + "\n"
			//	assert(audioPlayer.audioNode == self, "wtf audioPlayer")
				let audioSource	= audioPlayer.audioSource
				rv				+= "name:??\n"
			}
			 // Surpurflus info:
			if let light {
				rv				+= log.pidNindent(for:light) + " \\light:"
				rv 				=  log.unIndent(rv) + "\n"
			}
			if let camera {
				rv				+= log.pidNindent(for:camera) + " \\camera:"
				rv 				=  log.unIndent(rv) + "\n"
			}

			 /// 6. LAST print lower Parts, some are Ports
			for child in children {
				guard child.name != nil else {  debugger("scnScene with nil name")  }
				rv				+= child.name! == "*-axis"
								?  child.pp(.line, aux)+" (TRUNCATED)\n"
								:  child.pp(.tree, aux)
			}
			log.nIndent		-= 1
		default:
			rv					=  ppFixedDefault(mode, aux)	//bug?
		}
		return rv
	}
	func scn1Line(prefix:String="", _ aux:FwConfig) -> String {
		var p					= transform.pp(.phrase, aux)		// position	 (E)
		p						= p == "I0" ? "" : ("p" + p + " ")
		var piv					= pivot.pp(.phrase, aux)
		piv						= piv == "I0" ? "" : ("i" + piv + " ")
		let ppNCols4ScnPosn 	= aux.int_("ppNCols4ScnPosn")
		var rv2					= (prefix + p + piv).field(-ppNCols4ScnPosn, dots:false) + " "// (E)
		if aux.bool_("ppScnBBox") {
			rv2					+= "s" + bBox().pp(.line, aux)
		}

		 // display position in trunk:
	//	if params4partPp.string_("ppViewOptions").contains("W"),	// DOClog.params4defaultPp; params4defaultPp
	//	  let vews : VewBase	= FACTALSMODEL?.vewBase(ofScnScene:self) {
	//		let p				= convertPosition(.zero, to:vews.tree.scnScene)
	//		rv2					+= p.pp(.short, aux).field(-11, dots:false)
	//	}

//		rv						+= physicsBody != nil ? "pb" : "--"	// debugging
		rv2						+= isHidden ? "#H " :
								   fmt("%02x ", categoryBitMask) 	//	 (F)
		if let scnCom			= self as? SCNComment {
			rv2					+= scnCom.comment					//	 (G)
		}
		else if let g = geometry {
			let material 		= g.materials[0]
			if let n 			= material.name {					//	 (G)
				rv2 			+=  n + " "
			}
			let geos			= String(describing:g).shortenStringDescribing()
			if geos.contains("3DPictureframe") {					//	 (G)
				rv2				+= "3DPictureframe:" + bBox().pp(.line, aux) //+ "y=\(position.y)"
			} else {
				rv2				+= geos								//	 (G)
			}
		} else {
			rv2					+= "geom:nil"
		}
		return rv2
	}
	 // MARK: - 16. Global Constants
//      // MARK: - 17. Debugging Aids
	override open var description	   : String {	return "'\(pp(.short))'"	}
	override open var debugDescription : String {	return "'\(pp(.short))'"	}		// works 181120
	var summary					  	   : String {	return "'\(pp(.short))'"	}
}

class SCNComment : SCNNode {
	var comment : String
	init(_ com:String = "") {
		comment = com
		super.init()
	}
	required init?(coder: NSCoder) { debugger("init(coder:) has not been implemented")	}
}

 //https://openbase.com/swift/GDPerformanceView
//GDPerformanceMonitor.sharedInstance.configure(configuration: { (textLabel) in
//	textLabel?.backgroundColor = .black
//	textLabel?.textColor = .white
//	textLabel?.layer.borderColor = UIColor.black.cgColor
//})
//GDPerformanceMonitor.sharedInstance.startMonitoring()
		// TO DO:
		 // in Docs/www //  https://github.com/dani-gavrilov/GDPerformanceView-Swift/blob/master/GDPerformanceView-Swift/GDPerformanceMonitoring/GDPerformanceMonitor.swift
		//scnView?.background	= NSColor("veryLightGray")!
		// https://developer.apple.com/documentation/scenekit/scnview/1523088-backgroundcolor

