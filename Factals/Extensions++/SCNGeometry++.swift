//  SCNGeometry++.swift -- meshes ©2018PAK

import SceneKit

class SCNTunnelHood : SCNGeometry {
	  // n360 is the number of points in a full buzel (360 degrees)
	 // :H: Top, Bottom
	convenience init(n360:Int, height:CGFloat, ends:Bool,
			tSize_:SCNVector3, tRadius:CGFloat, bSize_:SCNVector3, bRadius:CGFloat)
	{
		assert(n360 != 0, "oops")

		 // Vertices for all:
		var vert :[SCNVector3]	= []
		var mx 					= CGFloat( 1)
		var mz					= CGFloat(-1)
		let tSize 				= tSize_ - SCNVector3(tRadius, 0, tRadius)
		let bSize 				= bSize_ - SCNVector3(bRadius, 0, bRadius)
		for i in 0..<n360 {
			if (i * 4) % n360 == 0 {		// every 90 degrees
				let swap		= mx
				mx				= -mz
				mz				= swap 			// rotate mx and mz by 90deg
			}
			let theta 			= 2 * CGFloat.pi * (CGFloat(i) + 0.5) / CGFloat(n360)		// N.B: 0.5
			let sint			= sin(theta)
			let cost 			= cos(theta)
			let x				= SCNVector3( mx * bSize.x + bRadius * cost,  0,       mz * bSize.z + bRadius * sint)
			vert.append(x)
			vert.append(SCNVector3( mx * tSize.x + tRadius * cost,  height,  mz * tSize.z + tRadius * sint))
		}

		var indxSide:[Int16]	= []
		var indxTop :[Int16]	= []
		var indxBot :[Int16]	= []
		for i1 : Int in 0...n360 {
			let i2				= 2 * (i1 % n360)	// wrap around
			 // Indices for Sides:
			let i16				= Int16(i2)
			indxSide.append(i16)			// A 	B
			indxSide.append(i16 + 1)		// B 	C
			 // Indices for Bottom:
			indxBot .append(Int16(0))
			indxBot .append(Int16(i2))
			 // Indices for Top:
			indxTop .append(Int16(i2 + 1))
			indxTop .append(Int16(0  + 1))
		}

		let source1				= SCNGeometrySource(vertices:vert)
		let elementSide			= SCNGeometryElement(indices:indxSide, primitiveType:.triangleStrip)//.line //.lineStrip//.point//triangleStrip
		let elementTop			= SCNGeometryElement(indices:indxTop,  primitiveType:.triangleStrip)
		let elementBot			= SCNGeometryElement(indices:indxBot,  primitiveType:.triangleStrip)
		 //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		self.init(sources:[source1], elements:[elementBot, elementSide, elementTop])
	}
}

class SCNHemisphere : SCNGeometry {		///			  ---*---		<-- PREVious BASE
										///		   /		   \	<-- BASE
//	var radius		:CGFloat	= 1.0				// 16 5 // 5 2 // 4 4 //
//		 /// +1:small disc, 0: hemisphere,  -1: whole sphere
//	var slice 		:CGFloat	{
//		get 			{	return sliceINT 									}
//		set(toValue)	{
//			print("Setting SCNHemisphere.slice = \(toValue)")
//			sliceINT = toValue
//		}
//	}
//	private var sliceINT : CGFloat = 0.0
//
//	var stepsAround	:Int		= 16
//	var stepsBetweenPoles:Int	= 8
//	var cap			:Bool		= true


	convenience init(radius		: CGFloat	= 1.0,				// 16 5 // 5 2 // 4 4 //
					 slice		: CGFloat	= 0.0,
					 stepsAround:Int		= 16,
					 stepsBetweenPoles:Int	= 8,
					 cap		:Bool		= true
					 ) {
//		self.init(sources:[], elements:[]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

//		self.radius	 			= radius
//		self.slice	 			= slice
//		self.stepsAround	 	= stepsAround
//		self.stepsBetweenPoles	= stepsBetweenPoles
//		self.cap				= cap

//		let (vert, indx)		= regen()
//	func regen() -> ([SCNVector3], [Int16]) {
		var vert:[SCNVector3]	= [1.0 * .uY]			// North Pole
		var norm:[SCNVector3]	= [1.0 * .uY]			// North Pole
		var indx:[Int16]		= []

		let stepsThruRimF		= CGFloat(stepsBetweenPoles) * (1 - slice)
		let stepsThruRim		= Int(stepsThruRimF)  //1//rounds up
		assert(stepsThruRim >= 0, "")

		 /// Rings, from North Pole downward
		var base				= vert.count
		var prevBase : Int?		= nil
		for lat in 1...stepsThruRim {	// step from (one down from the North Pole), to (rim)
			let latPct			= CGFloat(lat) / CGFloat(stepsBetweenPoles)
			let latAng			= 0.5 * CGFloat.pi * latPct
			let latXfm			= SCNMatrix4MakeRotation(latAng, 1,0,0)
			let arm0			= latXfm * SCNVector4(0,-radius,0,0)	/// boom rises from -Y to +Y

			for lon in 0...stepsAround {	// around the equator, hitting starting point twice
				let lon0		= lon % stepsAround
				let lonPct		= (CGFloat(lon0)) / CGFloat(stepsAround)
				let lonAng		= 2.0 * CGFloat.pi * lonPct
				let lonXfm		= SCNMatrix4MakeRotation(lonAng, 0,1,0)
				let arm			= -SCNVector3(lonXfm * arm0)/// boom spins about +Y
				if lon < stepsAround {		// don't enter starting point twice
					vert.append(arm)
					norm.append(arm.normalized)
					// Note 1: vertex normals make reflective lighting less patchy
					// Note 2: In special case of (hemi)sphere, Vertex Normals
				}	// 		   simply point away from origin.

				let prevIndex	= prevBase != nil ? prevBase! + lon0 : 0
				assert(prevIndex >= 0 && prevIndex < vert.count, "index out of range")
				indx.append(Int16(prevIndex))		// A 	B
				indx.append(Int16(base + lon0))		// B 	C
				//indx.append(Int16(base + lon0)) 	// B 	C
			}
			prevBase			= base
			base				+= stepsAround // lat % 2 == 0 ? 1 : 0
		}

		 /// Disc to cover missing half:
		if cap {
			for lon in 1..<stepsAround {			// around the equator
				indx.append(Int16(prevBase! + lon))
				indx.append(Int16(prevBase!))
			}
		}

		let sourceV1			= SCNGeometrySource(vertices:vert)
		let sourceN1			= SCNGeometrySource(normals: norm)
		if trueF {	/*//trueF//falseF*/ /// Areas
			let element0 		= SCNGeometryElement(indices:indx, primitiveType:.triangleStrip)
			self.init(sources:[sourceV1, sourceN1], elements:[element0]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		} else {					    /// Lines
			let element0 		= SCNGeometryElement(indices:      indx, primitiveType:.line) //.point
			let element1 		= SCNGeometryElement(indices:[0] + indx, primitiveType:.line)
			self.init(sources:[sourceV1], elements:[element0, element1]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		}
	}
}/*
vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                semantic:SCNGeometrySourceSemanticVertex
                                             vectorCount:VERTEX_COUNT
                                         floatComponents:YES
                                     componentsPerVector:3 // x, y, z
                                       bytesPerComponent:sizeof(float)
                                              dataOffset:offsetof(MyVertex, x)
                                              dataStride:sizeof(MyVertex)];

+ (instancetype)geometrySourceWithNormals:(const SCNVector3 *)normals count:(NSInteger)count;


normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                semantic:SCNGeometrySourceSemanticNormal
                                             vectorCount:VERTEX_COUNT
                                         floatComponents:YES
                                     componentsPerVector:3 // nx, ny, nz
                                       bytesPerComponent:sizeof(float)
                                              dataOffset:offsetof(MyVertex, nx)
                                              dataStride:sizeof(MyVertex)];


	*/																			//let strideOfSCNVector3 	= MemoryLayout<SCNVector3>.stride(ofValue:.zero)
																				//let xOffsetInSCNVector3 = MemoryLayout<SCNVector3>.offset(of: \SCNVector3.x)!
																				//let sizeOfFloat			= MemoryLayout<Float>.size(ofValue:Float(0.0))
																				//let data = NSData(bytes:vert, length:vert.count * strideOfSCNVector3) as Data
																				//let source2				= SCNGeometrySource(
																				//					data				:data,
																				//					semantic			:SCNGeometrySource.Semantic.vertex,
																				//					vectorCount			:vert.count,
																				//					usesFloatComponents	:true,
																				//					componentsPerVector	:3, 		// (x, y, and z)
																				//					bytesPerComponent	:sizeOfFloat,
																				//					dataOffset			:xOffsetInSCNVector3,
																				//					dataStride			:strideOfSCNVector3)
 /// A single point, useful only in extending bounding boxes.
class SCNPoint : SCNGeometry {
	convenience override init() {
		let vert:[SCNVector3]	= [.zero]
		let indx:[Int16]		= [0]//,0,0]	/// One triangle at origin
		let source				= SCNGeometrySource(vertices:vert)
		let element1 			= SCNGeometryElement(indices:indx, primitiveType:.point)//triangleStrip)
		self.init(sources:[source], elements:[element1]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		firstMaterial!.lightingModel = .blinn
	}
}
class SCNCornerTriangle : SCNGeometry {
	convenience init(length:CGFloat) {		
		let vert:[SCNVector3]	= [.zero, .uX*length, .uY*length, .uZ*length]
		let indx:[Int16]		= [
			0,1,			// -- startup
			2,		 		// 012	A			 Y^ 	        2
			3, 				// 123	B			  | /Z			| /3
			0,				// 230	C			  |/			|/
			1,				// 301	D			  o -->X		0----1
			0,				// -- reverse
			3,				// 103	D'
			2,				// 032	C'
			1,				// 321	B'
			0,				// 210	A'
		  ]
		let source				= SCNGeometrySource(vertices:vert)
		let element0 			= SCNGeometryElement(indices:indx, primitiveType:.triangleStrip)
		self.init(sources:[source], elements:[element0]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		firstMaterial!.lightingModel = .blinn
	}
}
class SCNOpenBox : SCNGeometry {
	convenience init(width:CGFloat, height:CGFloat, length:CGFloat, bottom:Bool=true) {
		var vert:[SCNVector3]	= []
		for y : CGFloat in stride(from:-1, to:1.1, by:2)  {
			for x : CGFloat in stride(from:-1, to:1.1, by:2) {
				for z : CGFloat in stride(from:-1, to:1.1, by:2)  {
					vert.append(SCNVector3(x * width/2, y * height/2, z * length/2))
				}
			}
		}
		var indx:[Int16]		= [	4,0,					// setup
									5,1, 7,3, 6,2, 4,0,		// left far right near
									4,2, 6,3, 7,1, 5,0, 4]	// other direction
		if bottom {
			indx				+= [0,2,1,3,  0,2]			// bottom (and other direction)
		}

		let source				= SCNGeometrySource(vertices:vert)
		let element0 			= SCNGeometryElement(indices:indx, primitiveType:.triangleStrip)
		self.init(sources:[source], elements:[element0]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		firstMaterial!.lightingModel = .blinn
	}
}

class SCNPictureframe : SCNGeometry {
	convenience init(width:CGFloat, length:CGFloat, step:CGFloat) {
		let indx:[Int16]		= [	0,1, 2,3,  6,7,  4,5,		// top surface
									0,1, 4,5,  6,7,  2,3, 0,1]	// bottom
		let (x, z, s) 			= (width/2, length/2, step/2)
		let vert:[SCNVector3]	= [
			/// External Points:			  	Inset to form Border:
			// Second design												// First design
			SCNVector3( x,   0,  z  ),		SCNVector3( x-s, 0,  z-s),	// 0, 1 SCNVector3( x-s, 0,  z-s),		SCNVector3( x,   0,  z  ),	// 0, 1
			SCNVector3( x,   0, -z  ),		SCNVector3( x-s, 0, -z+s),	// 2, 3	SCNVector3( x-s, 0, -z-s),		SCNVector3( x,   0, -z  ),	// 2, 3
			SCNVector3(-x,   0,  z  ),		SCNVector3(-x+s, 0,  z-s),	// 4, 5	SCNVector3(-x-s, 0,  z-s),		SCNVector3(-x,   0,  z  ),	// 4, 5
			SCNVector3(-x,   0, -z  ),		SCNVector3(-x+s, 0, -z+s),	// 6, 7	SCNVector3(-x-s, 0, -z-s),		SCNVector3(-x,   0, -z  ),	// 6, 7
		]
		let source				= SCNGeometrySource(vertices:vert)
		let element0 			= SCNGeometryElement(indices:indx, primitiveType:.triangleStrip)
		self.init(sources:[source], elements:[element0]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		name 					= fmt("w=%.2f l=%.2f s=%.2f", width, length, step)
		firstMaterial!.lightingModel = .blinn
	}
}
class SCN3DPictureframe : SCNGeometry {
	convenience init(width:CGFloat, length:CGFloat, height:CGFloat, step:CGFloat) {
		let (w, l, h, s)		= (width/2, length/2, height, step)
		 /// :H: inSet, smaller than outside, but never negative
		let (wInset, lInset)	= (max(w - s, 0), max(l - s, 0) )
		var indx:[Int16]		= []
		var vert:[SCNVector3]	= []
		let facesPRod			= 3		// :H: FACES Per ROD
		let rodsPFrame			= 4		// :H: RODS Per FRAME
		let corners : [CGFloat]	= [-1,-1, 1, 1, -1]

		for i in 0..<rodsPFrame {
				let nA 			= Int16(vert.count)	  // index of beginning corner 
				let nB			= (nA + Int16(facesPRod))// index of ending corner
					 % Int16(facesPRod * rodsPFrame)
				let points		= h >= 0 ? 					 
									// 1 	h		  .1 -<- 4.	
									//				 / |back | \
									// 0 	0\__	/ _2-----5_ \ diagonal
									// 2 	0/		0'----------'3		
					[nA+0, nB+0,	// ab: 0,->3 |	diagonal a:031,b:314			
					 nA+1, nB+1,	// cd: 1,->4 |  back	 c:142,d:415
					 nA+2, nB+2,	// ef: 2,->5 |  bottom   e:250,f:503			
					 nA+0, nB+0] :	// gh: 0,->3-'	 nB		   nA
					[nA+0, nB+0,	// ab: 0,->3 |	diagonal a:032,b:325
					 nA+2, nB+2,	// cd: 2,->5 |  back	 c:251,d:514
					 nA+1, nB+1,	// ef: 1,->4 |  bottom   e:140,f:403
					 nA+0, nB+0]	// gh: 0,->3-'	 nB		   nA
				assert(points.count - 2 == 2 * facesPRod, "indx mismatches facesProd")	
				indx.append(contentsOf:points)											

				let cornerA:CGFloat	= corners[i]		// e.g. 1..<4
				let cornerB:CGFloat	= corners[i+1]					 //			^
				vert.append(SCNVector3(w      * cornerA,  0, l      * cornerB))// n*3 + 0	|
				vert.append(SCNVector3(wInset * cornerA,  h, lInset * cornerB))// n*3 + 1	|
				vert.append(SCNVector3(wInset * cornerA,  0, lInset * cornerB))// n*3 + 2	0
		}
		let source				= SCNGeometrySource(vertices:vert)
		if trueF {
			let element0 		= SCNGeometryElement(indices:indx, primitiveType:.triangleStrip)//.line //.lineStrip//.point//triangleStrip
			self.init(sources:[source], elements:[element0]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		}
		else {
			let element0 		= SCNGeometryElement(indices:indx, primitiveType:.line)
			let indx1			= Array(indx.dropFirst())
			let element1 		= SCNGeometryElement(indices:indx1, primitiveType:.line)
			self.init(sources:[source], elements:[element0, element1]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		} 
		name 					= fmt("w=%.2f l=%.2f s=%.2f", width, length, step)
		firstMaterial!.lightingModel = .blinn
	}
//	static var ver				= 1
//	static let cornersLib		= [					// Each	   -w -ws   ws  w
//		/** 0: Tri Frame *///   ____				// Corner:  n+1:	   n:
//			[ 2, 5,		// a:  2'-.5 |	top line	//	Center:	e:141			Diag:
//			  0, 3,		// c:  0'-.3 ^  corner line	//	 h		  .4 -<- 1.		d: 314
//			  1, 4,		// e:  1'-.4 |  bottom line	//			 / |	 | \	c: 031
//			  1, 		// g:  1./   |  bottom line	//	-h		/ .5-----2. \	
//			  3, 0,		// i:  3'-.0 |  corner line	//	-h		3'----------'0		
//			  2, 5],	// k:  2'-.5-'	top line	//	Bottom:	b:503     a:250	
//		/** 1: L Frame  *///   ____					
//			[ 0, 3,		// a:  0'-.3 |c	setup			
//			  1, 4,		// c:  1'-.4 |  backspace
//			  2, 5,		// e:  2'-.5 |  diagonal
//			  0, 3],	// 0'-.3-	top
//		/** 2: Null Frame */ []]
/// NEW, BUGGY:
//	convenience init(ver_:Int, width:CGFloat, length:CGFloat, height:CGFloat, step:CGFloat) {
//		let (w, l, h, s)		= (width/2, length/2, height, step)
//		 /// :H: inSet, smaller than outside
//		let (ws, ls)			= (max(w - s, 0), max(l - s, 0) )//(w2 - s, l2 - s) //
//
//		 /// Create vertices for 4 corners:
//		var vert : [SCNVector3]	= []
//		let cosTable :[CGFloat] = [-1,-1, 1, 1, -1] // Each		w  ws  -ws -w	
//		for iCorner in 0..<4 {						// Corner:  n:	     n+1:	
//			let m1:CGFloat		= cosTable[iCorner]	//			0  2	 5  3	
//			let m2:CGFloat		= cosTable[iCorner+1]//			   1     4		
//			vert.append(SCNVector3(m1 * w,  -h, m2 * l )) 	// iCorner + 0
//			vert.append(SCNVector3(m1 * ws,  h, m2 * ls))	// iCorner + 1
//			vert.append(SCNVector3(m1 * ws, -h, m2 * ls))	// iCorner + 2
//		}
//		let nVerts				= vert.count
//		let source				= SCNGeometrySource(vertices:vert)
//
//		 /// Create indices for 4 corners:
//		let cornerLib :[Int]	= SCN3DPictureframe.cornersLib[SCN3DPictureframe.ver]
//		var indx : [Int16]		= []
//		for iCorner in 0..<1 {
//			for point in cornerLib {
//				let iPoint		= Int16((point + iCorner * 3) % nVerts)
//				indx.append(iPoint)
//			}
//		}
//		let element0 			= SCNGeometryElement(indices:indx, primitiveType:[.triangleStrip,.line][0])
//
//		self.init(sources:[source], elements:[element0]) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//
//		name 					= fmt("w=%.2f l=%.2f s=%.2f", width, length, step)
//		firstMaterial!.lightingModel = .blinn
//	}
}
 // 3 lines, along each axis
func originMark(size:Float) -> SCNNode {		// was myGlJack3
	let vertices : [SCNVector3] = [SCNVector3(size, 0, 0), SCNVector3(-size, 0, 0),
								   SCNVector3(0, size, 0), SCNVector3(0, -size, 0), 
								   SCNVector3(0, 0, size), SCNVector3(0, 0, -size)]
	let indices:[Int32] = [0,1, 4,5]//, 2,3

	let rv						= SCNComment("OriginMark(size:\(size))")

	let rootPart				= DOCfwGuts.rootPart
	let originNameIndex 		= rootPart.indexFor["origin"] ?? 1
	rootPart.indexFor["origin"] = originNameIndex + 1
	rv.name						= fmt("o-%d", originNameIndex)
	rv.geometry 				= SCNGeometry.lines(lines:indices, withPoints:vertices)
	return rv
}

extension SCNGeometry {
	class func line(from vector1:SCNVector3, to vector2:SCNVector3) -> SCNGeometry {
		let indices: [Int32] 	= [0, 1]
		let source = SCNGeometrySource(vertices:[vector1, vector2])
		let element = SCNGeometryElement(indices:indices, primitiveType:.line)
		return SCNGeometry(sources:[source], elements:[element])
	}
	class func lines(lines:[Int32], withPoints points:[SCNVector3]) -> SCNGeometry {
//	convenience init(lines:[Int32], withPoints points:[SCNVector3], color0:NSColor = .black, name:String? = nil) {
//		let material 			= SCNMaterial()
//		material.diffuse.contents = color0		// BUG doesn't work, all are white
//		material.lightingModel 	= .blinn
		let source 				= SCNGeometrySource(vertices:points)
		let element 			= SCNGeometryElement(indices:lines, primitiveType:.line)
		return SCNGeometry(sources:[source], elements:[element])
	}
	open override var description : String 	{		return "SCNGeometry"		}
}
extension SCNConstraint {

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		return "uncoded"
	}
}
extension SCNMaterial {
	func blink(to blipColor:NSColor, attack timeA:Float, retract timeR:Float) {
		let oldColor = self.reflective.contents
		SCNTransaction.begin()
bug//	atRve??(8, logg("  /#######  SCNTransaction: BEGIN"))
		self.reflective.contents = NSColor.black 		/// go black
		SCNTransaction.animationDuration = CFTimeInterval(timeA*0.25)
		SCNTransaction.completionBlock = {		 		  /// Then:
			SCNTransaction.begin()
			atRve(8, self.logd("  /#######  SCNTransaction: BEGIN"))
			self.reflective.contents = NSColor.white 		/// go white
			SCNTransaction.animationDuration = CFTimeInterval(timeA*0.75)
			SCNTransaction.completionBlock = {		 		  /// Then:
				SCNTransaction.begin()
				atRve(8, self.logd("  /#######  SCNTransaction: BEGIN"))
				self.reflective.contents = oldColor				///  restore
				SCNTransaction.animationDuration = CFTimeInterval(timeR)

				atRve(8, self.logd("  \\#######  SCNTransaction: COMMIT"))
				SCNTransaction.commit()
			} 
			atRve(8, self.logd("  \\#######  SCNTransaction: COMMIT"))
			SCNTransaction.commit()
		}
		atRve(8, self.logd("  \\#######  SCNTransaction: COMMIT"))
		SCNTransaction.commit()
	}
}
extension SCNMaterial {
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {
			case .name:				return name ?? "_"
				/// THIS WOULD BE NICE
			case .phrase, .short:
				let n				= name ?? ""
				return "SCNMaterial[ " + (n) + "]"		//  + ":" + pp(.fwClassName, aux).field(-3, dots:false)
			case .line:
				var rv			= DOClogger.pidNindent(for:self)	//			(AB)
				rv				+= "\((name ?? "material ").field(-8, dots:false))"//(C)
				rv 				=  DOClogger.unIndent(rv)// unindent	 (D)
				rv				+= " " + ppSCNMaterialColors(debugDescription)
				return rv
			default:
	bug;return "bug"
//				return ppDefault(self:self, mode:mode, aux:aux)
		}
	}
}

/*"
<SCNMaterial: 0x600003d00b40\n
  diffuse=<SCNMaterialProperty: 0x600002c14c80 | contents=sRGB IEC61966-2.1 colorspace 0.662745 0.662745 0.662745 1>\n
  specular=<SCNMaterialProperty: 0x600002c14e80 | contents=sRGB IEC61966-2.1 colorspace 1 1 1 1>\n
  reflective=<SCNMaterialProperty: 0x600002c14f00 | contents=sRGB IEC61966-2.1 colorspace 0.501961 0.501961 1 0.501961>\n
  multiply=<SCNMaterialProperty: 0x600002c14f80 | contents=sRGB IEC61966-2.1 colorspace 0.5 0.5 0.5 1>\n
>"
"<SCNMaterial: 0x600003d00780\n
  diffuse=<SCNMaterialProperty: 0x600002c12100 | contents=sRGB IEC61966-2.1 colorspace 0.501961 0.501961 1 0.501961>\n
  specular=<SCNMaterialProperty: 0x600002c12180 | contents=Generic Gray Gamma 2.2 Profile colorspace 1 1>\n
  reflective=<SCNMaterialProperty: 0x600002c12200 | contents=sRGB IEC61966-2.1 colorspace 0.501961 0.501961 1 0.501961>\n>"

 */
extension SCNMaterial {
	func ppSCNMaterialColors(_ str:String) -> String {
		let lines				= str.split(separator:"\n")
			//	0: "<SCNMaterial: 0x100d2fc30"		/// SKIP
			//	1: "  diffuse=<SCNMaterialProperty: 0x600002c2d000 | contents=Generic Gray Gamma 2.2 Profile colorspace 0 1>"
			//	2: "  specular=<SCNMaterialProperty: 0x600002c2cf80 | contents=Generic Gray Gamma 2.2 Profile colorspace 1 1>"
			//	3: ">"								/// SKIP
		var (rv, separator)		= ("", "")
		if lines.count > 1 {
			// (Skip over lines[0]; it's just SCNMaterial)
			for line in lines[1..<lines.count - 1]
					where line != ")>>>" && line != ")>>" && line != ">"
			{
				let split 		= line.split(separator:"=")
				assert(split.count >= 3, "format has changed")

				 /// split[0]: Color Property:
				let split0		= split[0].replacingOccurrences(of:"  ", with:"")
				let shortNames 	= [	"diffuse"		: "difu",
										"specular"		: "spcu",
										"reflective"	: "refl",
										"ambient"		: "ambi",
										"metalness"		: "metl",
										"roughness"		: "roug",
										"normal"		: "norm",
										"emission"		: "emis",
										"transparent"	: "trns"	]
				if let sName	= shortNames[split0] {
					rv			+= separator + sName + ":"
	bug//			rv			+= NSColor.ppColor(scnString:aString(split[2])) ?? "<Bad Color>"
				}else{
					rv			+= separator + "unknown:<?>"
				}
				separator			= ", "
			}
		}
		return rv
	}
}
