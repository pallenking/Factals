//  SCNMatrix++.swift -- Extensions for SCNVector's

//  Created from SCNVector3+MathUtils.swift by Jeremy Conkin on 4/26/16.
//	Split and Appended 180214 by Allen King

import SceneKit

extension SCNMatrix4 {

	public static func == (lhs: SCNMatrix4, rhs: SCNMatrix4) -> Bool {
		let rv					=
		lhs.m11 == rhs.m11 && lhs.m21 == rhs.m21 && lhs.m31 == rhs.m31 && lhs.m41 == rhs.m41 &&
		lhs.m12 == rhs.m12 && lhs.m22 == rhs.m22 && lhs.m32 == rhs.m32 && lhs.m42 == rhs.m42 &&
		lhs.m13 == rhs.m13 && lhs.m23 == rhs.m23 && lhs.m33 == rhs.m33 && lhs.m43 == rhs.m43 &&
		lhs.m14 == rhs.m14 && lhs.m24 == rhs.m24 && lhs.m34 == rhs.m34 && lhs.m44 == rhs.m44 
		return rv
	}
	static func != (lhs: SCNMatrix4, rhs: SCNMatrix4) -> Bool {
		return !(lhs == rhs)
	}

	 //  Matrix4 *(=) Scalar
	static func *(_ matrix:SCNMatrix4, _ scale:CGFloat) -> SCNMatrix4 {
		// 20211007PAK: EXC_BAD_ACCESS on M1
//		let a = SCNMatrix4MakeScale(scale, scale, scale)	// non-minimal
//		return SCNMatrix4Mult(matrix, a)
		let s					= Float(scale)
		var rv					= SCNMatrix4()
		for i in 0...3 {
			for j in 0...3 {
				let atIj 		= matrix.at(i,j) * s
				rv.setElement(i, j, to:atIj)
			}
		}
		return rv
		
	}
	static func *=(_ matrix1:inout SCNMatrix4, _ scale:CGFloat) {
		let a = SCNMatrix4MakeScale(scale, scale, scale)	// non-minimal
		matrix1 = matrix1 * a
//		matrix1 = SCNMatrix4Mult(matrix1, a)
	}

	//  Matrix4 *(=) Vector[3/4]
//			  <--  in.x   in.y   in.z <--
//		|out.x|   |m11* + m21* + m31*|   |in.x|
//		|out.y|<--|m12* + m22* + m32*| * |in.y|
//		|out.z|   |m13* + m23* + m33*|   |in.z|
//										  		
//				  |m11* + m12* + m13*|   |in.x| in (a Row) transposed
//				  |m21* + m22* + m23*|<--|in.y|
//				  |m31* + m32* + m33*|   |in.z|
//				  out.x   out.y  out.z
	static func *(_ m:SCNMatrix4, _ v:SCNVector4) -> SCNVector4 {
		let vx = m.m11*v.x + m.m21*v.y + m.m31*v.z + m.m41*v.w
		let vy = m.m12*v.x + m.m22*v.y + m.m32*v.z + m.m42*v.w
		let vz = m.m13*v.x + m.m23*v.y + m.m33*v.z + m.m43*v.w
		let vw = m.m14*v.x + m.m24*v.y + m.m34*v.z + m.m44*v.w
		return SCNVector4(vx, vy, vz, vw)
	}
	static func *(_ m:SCNMatrix4, _ v:SCNVector3) -> SCNVector3 {
		let vx = m.m11*v.x + m.m21*v.y + m.m31*v.z + m.m41
		let vy = m.m12*v.x + m.m22*v.y + m.m32*v.z + m.m42
		let vz = m.m13*v.x + m.m23*v.y + m.m33*v.z + m.m43
		return SCNVector3(vx, vy, vz)
	}
	 // Matrix4 *(=) Matrix4
	static func *(_ matrix1:SCNMatrix4, _ matrix2:SCNMatrix4) -> SCNMatrix4 {
		// 20211007PAK: EXC_BAD_ACCESS on M1
		//return SCNMatrix4Mult(matrix1, matrix2)
		var rv					= SCNMatrix4()
		for i in 0...3 {
			for k in 0...3 {
				var a : Float	= 0.0
				for j in 0...3 {
					a 			+= matrix1.at(i,j) * matrix2.at(j,k)
				}
				rv.setElement(i,k, to:a)
			}
		}
		return rv
	}
	static func *=(_ matrix1:inout SCNMatrix4, _ matrix2:SCNMatrix4) {
		matrix1 = SCNMatrix4Mult(matrix1, matrix2)
	}
//NOW IN FW++
//	infix operator ~==  : AdditionPrecedence	// Read as "Approximately Equal"
//	infix operator !~== : AdditionPrecedence	// Read as "Not Approximately Equal"
	 // Matrix4 (!)~== Matrix4
	static func ~==(_ m1:SCNMatrix4, _ m2:SCNMatrix4) -> Bool {
		for i in 1..<4 { 	// compare row at a time
			if  m1.at(i) !~== m2.at(i) {
				return false
			}
		}
		return true
	}
	static func !~==(_ m1:SCNMatrix4, _ m2:SCNMatrix4) -> Bool {
		for i in 1..<4 { 	// compare row at a time
			if  m1.at(i) !~== m2.at(i) {
				return true
			}
		}
		return false
	}

	 // MARK: - 2. Object Variables:
	func at(_ x:Int, _ y:Int) -> Float {
		var rv : CGFloat?  = nil
		switch x {
			case 0:		rv 		= y==0 ? m11 : y==1 ? m12 : y==2 ? m13 : y==3 ? m14 : nil
			case 1:		rv 		= y==0 ? m21 : y==1 ? m22 : y==2 ? m23 : y==3 ? m24 : nil
			case 2:		rv 		= y==0 ? m31 : y==1 ? m32 : y==2 ? m33 : y==3 ? m34 : nil
			case 3:		rv 		= y==0 ? m41 : y==1 ? m42 : y==2 ? m43 : y==3 ? m44 : nil
			default:	rv 		= nil
		}
		assert(rv != nil, "ERROR")
		return Float(rv!)
	}
	mutating func setElement(_ x: Int, _ y:Int, to value:Float) {
		var val 				= CGFloat(value)
		switch x {
		case 0:
			switch y {
			case 0:	m11		= val
			case 1:	m12		= val
			case 2:	m13		= val
			case 3:	m14		= val
			default: fatalError("SCNMatrix4.setElement(\(x), \(y), \(val)) fails")
			}
		case 1:
			switch y {
			case 0:	m21		= val
			case 1:	m22		= val
			case 2:	m23		= val
			case 3:	m24		= val
			default: fatalError("SCNMatrix4.setElement(\(x), \(y), \(val)) fails")
			}
		case 2:
			switch y {
			case 0:	m31		= val
			case 1:	m32		= val
			case 2:	m33		= val
			case 3:	m34		= val
			default: fatalError("SCNMatrix4.setElement(\(x), \(y), \(val)) fails")
			}
		case 3:
			switch y {
			case 0:	m41		= val
			case 1:	m42		= val
			case 2:	m43		= val
			case 3:	m44		= val
			default: fatalError("SCNMatrix4.setElement(\(x), \(y), \(val)) fails")
			}
		default: fatalError("SCNMatrix4.setElement(\(x), \(y), \(val)) fails")
		}
	
	}
//	func at(_ x:Int) -> SCNVector3 {		// leads to ambiguity
//		switch x {
//			case 0:		return SCNVector3(m11, m12, m13)
//			case 1:		return SCNVector3(m21, m22, m23)
//			case 2:		return SCNVector3(m31, m32, m33)
//			default:	panic(); return SCNVector3.nan
//		}
//	}
	func at(_ x:Int) -> SCNVector4 {
		switch x {
			case 0:		return SCNVector4(m11, m12, m13, m14)
			case 1:		return SCNVector4(m21, m22, m23, m24)
			case 2:		return SCNVector4(m31, m32, m33, m34)
			case 3:		return SCNVector4(m41, m42, m43, m44)
			default:	panic(); return SCNVector4.nan
		}
	}

	func rotationMatrixVerticalizing(vector uY_:SCNVector3, to iY:SCNVector3) -> SCNMatrix4 {
		 // -------- Y:
		let uY					= uY_ / uY_.length	// Normalize uY
		 // -------- X:
		var uX 					= uY.crossProduct(iY)// the vector that maps to iX
		let uxLen				= uX.length
		if uxLen < CGFloat(epsilon) {				// already verticalized?
			return .identity						// return identity mtx
		}
		uX						= uX / uxLen
		 // -------- Z:
		var uZ 					= uX.crossProduct(uY)// the vector that maps to iZ
		uZ						= uZ / uZ.length

		// a backward matrix which takes verticalized to unverticalized:
		let rv					= SCNMatrix4(uX[0], uX[1], uX[2], 0,
											 uY[0], uY[1], uY[2], 0,
											 uZ[0], uZ[1], uZ[2], 0,
											     0,	    0,     0, 1)
			// maps		1, 0, 0 --> uX
			//			0, 1, 0 --> uY
			//			0, 0, 1 --> uZ
		SCNMatrix4Invert(rv)	// invert it forward
		return rv;
	}

	var position : SCNVector3 {
		get {		return SCNVector3Make(m41, m42, m43)						}
		set(newPosition)			{
			m41 = newPosition.x
			m42 = newPosition.y
			m43 = newPosition.z
		}
	}

	var isNan	: Bool {
		return 	m11.isNan || m12.isNan || m13.isNan || m14.isNan ||
				m21.isNan || m22.isNan || m23.isNan || m24.isNan ||
				m31.isNan || m32.isNan || m33.isNan || m34.isNan ||
				m41.isNan || m42.isNan || m43.isNan || m44.isNan
	}

	 // MARK: - 3. Factory
	init(_ m11:CGFloat, _ m12:CGFloat, _ m13:CGFloat, _ m14:CGFloat,
		 _ m21:CGFloat, _ m22:CGFloat, _ m23:CGFloat, _ m24:CGFloat,
		 _ m31:CGFloat, _ m32:CGFloat, _ m33:CGFloat, _ m34:CGFloat,
		 _ m41:CGFloat, _ m42:CGFloat, _ m43:CGFloat, _ m44:CGFloat) {
		self.init(m11:m11, m12:m12, m13:m13, m14:m14,
			 	  m21:m21, m22:m22, m23:m23, m24:m24,
				  m31:m31, m32:m32, m33:m33, m34:m34,
				  m41:m41, m42:m42, m43:m43, m44:m44)
	}

	 /// Create SCNVector4 from 4 SCNVector4's
	init(_ m1:SCNVector4, _ m2:SCNVector4, _ m3:SCNVector4, _ m4:SCNVector4) {
		self.init(m11:m1.x, m12:m1.y, m13:m1.z, m14:m1.w,
			 	  m21:m2.x, m22:m2.y, m23:m2.z, m24:m2.w,
			 	  m31:m3.x, m32:m3.y, m33:m3.z, m34:m3.w,
			 	  m41:m4.x, m42:m4.y, m43:m4.z, m44:m4.w)
	}
	/// Create with SCNVector3's or SCNVector4's
	/// - Parameters:
	///   - row1v4: First      row as SCNVector4
	///   - row1v3: First      row as SCNVector3
	///   - row2v4: Second row as SCNVector4
	///   - row2v3: Second row as SCNVector3
	///   - row3v4: Third	     row as SCNVector4
	///   - row3v3: Third     row as SCNVector3
	///   - row4v4: Fourth   row as SCNVector4
	///   - row4v3: Fourth   row as SCNVector3
	init(row1v4:SCNVector4?=nil, row1v3:SCNVector3?=nil,
		 row2v4:SCNVector4?=nil, row2v3:SCNVector3?=nil, 
		 row3v4:SCNVector4?=nil, row3v3:SCNVector3?=nil, 
		 row4v4:SCNVector4?=nil, row4v3:SCNVector3?=nil) {
		let m1					= row1v4 ?? (row1v3 != nil ? SCNVector4(row1v3!) : .uX)
		let m2					= row2v4 ?? (row2v3 != nil ? SCNVector4(row2v3!) : .uY)
		let m3					= row3v4 ?? (row3v3 != nil ? SCNVector4(row3v3!) : .uZ)
		var m4					= row4v4 ?? (row4v3 != nil ? SCNVector4(row4v3!) : .uW)
		m4.w					= 1
		self.init(m11:m1.x, m12:m1.y, m13:m1.z, m14:m1.w,
			 	  m21:m2.x, m22:m2.y, m23:m2.z, m24:m2.w,
			 	  m31:m3.x, m32:m3.y, m33:m3.z, m34:m3.w,
			 	  m41:m4.x, m42:m4.y, m43:m4.z, m44:m4.w)
	}

	 /// HaveNWant initializers for SCNMatrix4:
	init(_ x:CGFloat, _ y:CGFloat, _ z:CGFloat,
			flip	 :Bool		= false,
			latitude :CGFloat	= 0,
			spin	 :CGFloat	= 0,
			magnitude:CGFloat	= 1
		) {
		let position 			= SCNVector3(x, y, z)
		self.init(position, flip:flip, latitude:latitude, spin:spin, magnitude:magnitude)
	}
	init(_ position	:SCNVector3	= .zero,
			flip	 :Bool		= false,
			latitude :CGFloat	= 0,
			spin	 :CGFloat	= 0,
			magnitude:CGFloat	= 1
		) {
		  /// The rotation part of the transform is in v's local system
		self					= .identity			// 1. flipped into self
//		self.m22				= flip ? -1.0 : 1.0						   // negative y gain
		if flip {
			self 				= SCNMatrix4MakeRotation(.pi,     1, 0, 0) // 180 about X Axis
		}											// 2. spin, in radians
		let spinMtx				= SCNMatrix4MakeRotation(spin,     0, 1, 0)
													// 3. latitude, in radians
		let latMtx  			= SCNMatrix4MakeRotation(latitude, 0, 0, 1)
													// 4. magnitude
		self					= (self * spinMtx * latMtx) * magnitude
		self.position			= position			// 5. position
	}
	 /// Just the rotation part (3x3) of a 4x4
	var m3x3 : SCNMatrix4 {
		let a					= self
		let rv					= SCNMatrix4(
									a.m11, a.m12, a.m13, 0,
									a.m21, a.m22, a.m23, 0,
									a.m31, a.m32, a.m33, 0,
									    0,     0,     0, 1)
		return rv	
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String {
		switch mode! {		// PpMode .short and .phrase exists in many places
			case .short:
				var rv				= ""
				for i in 0..<4 {
					let sm:SCNMatrix4 = self
					rv 				+= sm.at(i).pp(.short)
				}
				return rv
			case .phrase:
				return ppM1(aux)
			case .line:
				return ppM1(aux)
			case .tree:
				var (rv, sep) 	= ("", "[")
				for i in 0..<4 {		// pile o crap:
					rv 			+= sep + at(i).pp(.line)
					sep			= "\n "
				}
				return rv + "]"
//			case .full:
//				var rv = ""
//				for i in 0..<4 {
//					rv 			+= at(i).pp(.line, aux)
//				}
//				return rv
			default:
				return ppDefault(self:self, mode:mode!, aux:aux)
		}
	}
	   /// Attempt to encode inner 3x3 matrix into common named types
	 /// - Examples: I0, I(3,4,2), IXY[y=3], ...
	func ppM1(_ aux:FwConfig)	-> String	{
/*
[[ 0.7 0-0.7 0]		// Here's another special case
 [ 0.0 1 0.0 0]
 [ 0.7 0 0.7 0]
 [ 0.0 0 0.0 1]]
		*/
		 /// A new special case: rotation matrix is all zero
		var allZero				= true
		var anyNan				= false
		for i in 0..<3 {
			for j in 0..<3 {
				let	atIj		= at(i, j)
				allZero			&&=   atIj ~== 0
				anyNan			||=   atIj.isNan
			}
		}
		if allZero {
			bug;return "0\(position.pp(.short))"
		}
		if anyNan {
			return "<hasNan>"
		}

		    // Definition: A row is "dominated" when one of its colmns
		   // is much bigger than any of the others
		  // Look for the case when all rows are dominated by one column:
		var domAxis 			= [Int]   (repeating: -1, count:3)
		var domVals 			= [Float] (repeating:0.0, count:3)
		var foundGoodRow		= false				// None at start
		var foundBadRow_reason :String? = nil		// Nothing bad at start
		for column in 0..<3 {	// Check if each column is dominated by one row:
			var zeroComponentCount = 0
			for row in 0..<3 {		// Scan all rows of this column		// ?..<2
				if (abs( at(column,row) ) < epsilon){
					zeroComponentCount	+= 1		/// Zero entry
				}
				else {								/// Non-zero entry
					foundGoodRow = true
					if domAxis[column] == -1 {			// first non-zero
						domVals[column] = at(column,row)
						domAxis[column] = row
					}
					else {								// 2'nd non-zero
						foundBadRow_reason = "second row non-zero"
						domVals[column] = Float.nan		// set as error
						domAxis[column] = -1
						break
					}
				}
			}
			if zeroComponentCount == 0 {
				foundBadRow_reason = "No row non-zero"
			}
		}
		var rv = ""
		if (foundGoodRow && foundBadRow_reason==nil) {	// ALL the rows dominated by ONE column
			 // Are all dominated by same value?
			let absDomVals		= domVals.map 	{ 	abs($0) 					}
			var aNames 			= ""
			let allSame			=  absDomVals[0] ~== absDomVals[1]
								&& absDomVals[0] ~== absDomVals[2]
								&& absDomVals[1] ~== absDomVals[2]
			if allSame			{	// all rows same value
				 // all same, but not 1.0
				if absDomVals[0] !~== 1.0 {
					rv 			= fmt("%.2f", abs(domVals[0]))
				}

				let axisNames 	= [["x","X"], ["y","Y"], ["z","Z"], ]
				for column in 0..<3 {
					let x 		= domVals[column]<0 ? 1 : 0
					let y 		= domAxis[column]
					aNames		+= axisNames [y] [x]
				}	// xyz -> domAxis[]/domVal[]
				let shortINames = ["xyz":"", "Xyz":"X", "xYz":"Y", "xyZ":"Z",
									  		 "xYZ":"YZ","XyZ":"XZ","XYz":"XY"]
				rv 				+= "I" + (shortINames[aNames] ?? aNames)
			}
									/// scale of rows have different values
			else {
				let scale 		= SCNVector3(domVals[0], domVals[1], domVals[2])
				rv				= "<" + String(scale.pp(.short).dropLast().dropFirst()) + ">I"
			}
			rv					+= position.pp(.short)
		}
		else {			/// Print 4x4 matrix:
			for i in 0..<4 {
				rv 				+= at(i).pp(.short)
			}
		}
		return rv.removeUnneededSpaces()		// remove extra spaces
	}

	 // MARK: - 16. Global Constants
	static let identity 		= SCNMatrix4Identity    // a more uniform name
	static let rotateYtoZ		= SCNMatrix4MakeRotation(.pi/2, 1,0,0)

	 // MARK: - 17. Debugging Aids
	var description		:String	{	return "\"\(pp(.short))\""					}
	var debugDescription:String	{	return  "'\(pp(.short))'"					}
//	var summary			:String	{	return  "<\(pp(.short))>"					}
}
