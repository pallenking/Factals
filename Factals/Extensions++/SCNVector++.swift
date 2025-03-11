//  SCNVector++.swift -- Extensions for SCNVector's

//  Created from SCNVector3+MathUtils.swift by Jeremy Conkin on 4/26/16.
//	Split and Appended 180214 by Allen King

import SceneKit

let epsilon : Float 	= 1e-5
let eps		 			= CGFloat(epsilon)

// ////////////////////////// SCNVector3 //////////////////////////////////

// /////////////// Add / Subtract:
 /** 	C = A + B 		*/ // Add two vectors
func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
	return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}
 /** 	C = A - B		*/ // Subtract two vectors
func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
	return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}
 /** 	A += B 			*/ // Add one vector to another
func +=( left: inout SCNVector3, right:SCNVector3) {
	left = SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}
 /** 	A -= B 			*/ // Subtract one vector from another
func -=( left: inout SCNVector3, right:SCNVector3) {
	left = SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

 /** 	C = A + b 		*/ // To each component of Vector, add the same scalar
func +(left:SCNVector3, right:CGFloat) -> SCNVector3 {
	return SCNVector3(left.x + right, left.y + right, left.z + right)
}
 /** 	C = A - b		*/ // To each component of Vector, subtract the same scalar
func -(left:SCNVector3, right:CGFloat) -> SCNVector3 {
	return SCNVector3(left.x - right, left.y - right, left.z - right)
}
 /** 	C = b - A		*/ //?????
 /** 	A += b 			*/ // Add scalar to all components of a vector
func +=( left: inout SCNVector3, right:CGFloat) {
	left = SCNVector3(left.x + right, left.y + right, left.z + right)
}
 /** 	A -= b 			*/ // Subtract one vector from another
func -=( left: inout SCNVector3, right:CGFloat) {
	left = SCNVector3(left.x - right, left.y - right, left.z - right)
}

 /** 	C = A * c 		*/ // Multiply a vector times a constant
func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
	return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}
 /** 	C = c * A		*/ // Multiply (commutative)
func *(multiplier:SCNFloat, vector:SCNVector3) -> SCNVector3 {
	return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

// /////////////// Multiply / Divide
// Vew.swift:216:52: Overloads for '*' exist with these partially matching parameter lists: (Double, Double), (Double, double2), (Double, double3), (Double, double4), (Double, simd_double2x2), (Double, simd_double3x2), (Double, simd_double4x2), (Double, simd_double2x3), (Double, simd_double3x3), (Double, simd_double4x3), (Double, simd_double2x4), (Double, simd_double3x4), (Double, simd_double4x4), (Double, simd_quatd), (Double, Measurement<UnitType>)
///**  Multiply a constant times a vector PAK180306 */
//func *(multiplier:SCNFloat, vector:SCNVector3) -> SCNVector3 {
//    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
//}

 /** 	A *= c			*/ // Multiply a vector times a constant and update it inline
func *=( vector: inout SCNVector3, multiplier:SCNFloat) {
	vector = vector * multiplier
}

 /**	C = A * B		*/ // Component product of vectors
func *( v1:SCNVector3, v2:SCNVector3) -> SCNVector3 {
	return SCNVector3(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z)
}

 /** 	c = A * B		*/ // Dot product of v1 and v2
func *( v1:SCNVector3, v2:SCNVector3) -> CGFloat {
	return v1.x * v2.x  +  v1.y * v2.y  +  v1.z * v2.z
}
 /** 	c = dot(A,B) 	*/ // Dot product of v1 and v2
func dot( v1:SCNVector3, v2:SCNVector3) -> CGFloat {
	return v1.x * v2.x  +  v1.y * v2.y  +  v1.z * v2.z
}
 /** 	c = length(A) 	*/ // lenght of v1 and v2
func length(_ v:SCNVector3) -> CGFloat {
	return sqrt(v.x * v.x  +  v.y * v.y  +  v.z * v.z)
}

// 180219PAK Added to round out functionality
 /** 	C = A / c	 	*/ // Divide a vector by a constant
func /(vector:SCNVector3, divisor:SCNFloat) -> SCNVector3 {
	return SCNVector3(vector.x / divisor, vector.y / divisor, vector.z / divisor)
}
 /** 	C /= c			*/ // Divide a vector by a constant
func /=( vector: inout SCNVector3, divisor:SCNFloat) {
	vector = vector / divisor
}


 /** 	Ci = Ai / Bi 	*/ // Divide components of two vector
func /(vector:SCNVector3, divisor:SCNVector3) -> SCNVector3 {
	return SCNVector3(vector.x / divisor.x, vector.y / divisor.y, vector.z / divisor.z)
}
 /** 	Ci /= Bi 		*/ // Divide a vector by another vector and update inline
func /=( vector: inout SCNVector3, divisor:SCNVector3) {
	vector = vector / divisor
}

 /**	Ci = min(Ai,Bi) */ //Per component min (and max)
func maxPerAxis(_ a:SCNVector3, _ b:SCNVector3) -> SCNVector3 {
	return SCNVector3Make(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
}
func minPerAxis(_ a:SCNVector3, _ b:SCNVector3) -> SCNVector3 {
	return SCNVector3Make(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))
}

 /// Component-wise min/max: Ci = A |> B
infix operator |>		// ComponentWise Max
infix operator |<		// ComponentWise Min
func |>( a:SCNVector3, b:SCNVector3) -> SCNVector3 {
	return SCNVector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
}
func |<( a:SCNVector3, b:SCNVector3) -> SCNVector3 {
	return SCNVector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))
}
infix operator |>= : AdditionPrecedence
infix operator |<= : AdditionPrecedence
func |>=( a:inout SCNVector3, b:SCNVector3) {
	a				= SCNVector3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
}
func |<=( a:inout SCNVector3, b:SCNVector3) {
	a				= SCNVector3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))
}
 // augment someday:
infix operator |>|		// Bitwise .GT.

 /** 	 	A ~== B		*/ // Approximately Equal -- All components within epsilon:
//NOW IN FW++
//infix operator ~==  : AdditionPrecedence	// Read as "Approximately Equal"
//infix operator !~== : AdditionPrecedence	// Read as "Not Approximately Equal"
func ~==( left:SCNVector3, right:SCNVector3) -> Bool {
	return left.x ~== right.x && left.y ~== right.y && left.z ~== right.z
}
prefix func - (vector:SCNVector3) -> SCNVector3 {
	return SCNVector3(-vector.x, -vector.y, -vector.z)
}
//func (_ v3:SCNVector3) -> SCNVector4 {
//	return SCNVector4(v3.x, v3.y, v3.z, 1)
//}
//

// 20210909PAK: See SCNVector9XCTest
//extension SCNVector3 : Equatable {
//}
//extension SCNVector3 : Codable {}
extension SCNVector3 : Codable {			// : Codable (see SCNVector9XCTest)

	 // MARK: - 2. Object Variables:
	var isNan	: Bool 		{ return x.isNan || y.isNan || z.isNan				}

	// Calculate the magnitude of this vector
	var length :SCNFloat {	return sqrt(dotProduct(self))						}
	var length2:SCNFloat {	return dotProduct(self)								}

	// Vector in the same direction as this vector with a magnitude of 1
	var normalized:SCNVector3 {
		let len = length
		return SCNVector3(x/len, y/len, z/len)
	}

	/**  Calculate the dot product of two vectors	 */
	func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
		return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
	}

	/**	 Calculate the dot product of two vectors */
	func crossProduct(_ vectorB:SCNVector3) -> SCNVector3 {
		let computedX = (y * vectorB.z) - (z * vectorB.y)
		let computedY = (z * vectorB.x) - (x * vectorB.z)
		let computedZ = (x * vectorB.y) - (y * vectorB.x)
		return SCNVector3(computedX, computedY, computedZ)
	}

	/** Calculate the angle between two vector */
	// A Better way is to use atan2(x,y)
//	func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
//		//cos(angle) = (A.B)/(|A||B|)
//		let cosineAngle = (dotProduct(vectorB) / (length * vectorB.length))
//		return SCNFloat(acos(cosineAngle))
//	}

//	func matrixLineZ(to:SCNVector3, up:SCNVector3) -> SCNMatrix4 {
//		let a : SCNVector3		= self
//		let toUz				= to - a
//		let toUy				= SCNVector3.zero
//		let toUx				= SCNVector3.zero
//
//		 // -------- Y:
//		let uY					= uY_ / uY_.length	// Normalize uY
//		 // -------- X:
//		var uX 					= uY.crossProduct(iY)// the vector that maps to iX
//		let uxLen				= uX.length
//		if uxLen < CGFloat(epsilon) {				// already verticalized?
//			return .identity						// return identity mtx
//		}
//		uX						= uX / uxLen
//		 // -------- Z:
//		var uZ 					= uX.crossProduct(uY)// the vector that maps to iZ
//		uZ						= uZ / uZ.length
//
//		/// a backward matrix which takes verticalized to unverticalized:
//		let rv					= SCNMatrix4(uX[0], uX[1], uX[2], 0,
//											 uY[0], uY[1], uY[2], 0,
//											 uZ[0], uZ[1], uZ[2], 0,
//											     0,	    0,     0, 1)
//			// maps		1, 0, 0 --> uX
//			//			0, 1, 0 --> uY
//			//			0, 0, 1 --> uZ
//		SCNMatrix4Invert(rv)	/// invert it forward
//		return rv;
//	}

	 // MARK: - 3. Factory
	init(_ x_:CGFloat, _ y_:CGFloat, _ z_:CGFloat) {
		self.init()
		(x, y, z)  = (x_, y_, z_)
	}
	init(_ v:SCNVector4) {
		self.init()
		(x, y, z)  = (v.x, v.y, v.z) /* v.w ignored*/
	}
	init(_ p:NSPoint) {
		self.init()
		(x, y, z)  = (p.x, p.y, 0)
	}

	 // Useful for configuration
	init?(from:FwAny?) {
		 // e.g. "4 3 2":
		var cgF :[CGFloat?] = []
		if let str			= from as? String {
			assert(!str.contains(substring:","), "Hint: Separate components of '\(str)' with ' ', NOT ','")
			let floatStrs 	= str.split(separator: " ")
			guard floatStrs.count == 3 else {		return nil					}
			cgF 			= floatStrs.map {		CGFloat(String($0))			}
		}
		 // e.g. ["4.0", "3.0", "2.0"]
		else if let array3string = from as? Array<String>,
		  array3string.count == 3 {
		  	cgF				= array3string.map {	CGFloat($0)					}
		}
		 // e.g. [4.0, 3.0, 2.0]
		else if let array3cgFloat = from as? Array<CGFloat>,
		  array3cgFloat.count == 3 {
			cgF				= array3cgFloat
		}

		 // Enough numbers supplied?
		guard cgF.count == 3 && cgF[0] != nil && cgF[1] != nil && cgF[2] != nil
		 else {				return nil 											}

		self.init(cgF[0]!, cgF[1]!, cgF[2]!)
	}

	 // MARK: - 3.5 Codable
	enum ScnVector3Keys:String, CodingKey {
		case x, y, z
	}
	 // from https://gist.github.com/magicien/b0c87d26ffded8aa2161630c56853ca4 :
	 // Serialize
	public func encode(to encoder: Encoder) throws {
		var container 			= encoder.container(keyedBy:ScnVector3Keys.self)
		try container.encode(self.x, forKey:.x)
		try container.encode(self.y, forKey:.y)
		try container.encode(self.z, forKey:.z)
		//logSer(3, DOClog.log("Encoded  ScnVector3"))
	}
	 // Deserialize
	public init(from decoder: Decoder) throws {
		self.init()
		let container 			= try decoder.container(keyedBy:ScnVector3Keys.self)

		x	 					= try container.decode(CGFloat.self, forKey:.x)
		y	 					= try container.decode(CGFloat.self, forKey:.y)
		z	 					= try container.decode(CGFloat.self, forKey:.z)
		print("Decoded  as? ScnVector3 \(self.pp(.line)) ")
	}
								
	init(string:String) {
		var arg : [Double]		= []
		for str in string.split(separator:" ") where !str.isEmpty {
			if let d 			= Double(str) {
				arg.append(d)
			}
		}
		let scnVector3			= arg.count==0 ? SCNVector3(x:0,      y:0,		z:0) :
								  arg.count==1 ? SCNVector3(x:arg[0], y:0,		z:0) :
								  arg.count==2 ? SCNVector3(x:arg[0], y:arg[1], z:0) :
								  arg.count==3 ? SCNVector3(x:arg[0], y:arg[1], z:arg[2]) :
								  				 SCNVector3(x:.nan,   y:.nan,	z:.nan)		// rethink
		self					= scnVector3
	}
//		if let scnVector3		= SCNVector3(from:string) ??			// x y z
//								  SCNVector3(from:string + " 0") ??	// x y 0
//								  SCNVector3(from:string + " 0 0") {
	
	 // MARK: - 4.1 Subscript
	//var elt(_ index:Int) : CGFloat { // Brian would like help herer
	subscript(index:Int)  -> CGFloat {		//return elt(index)					}
		get {
			return index==0 ? x :
				   index==1 ? y :
				   index==2 ? z : CGFloat.nan
		}
		set(toValue) {
			switch index {
			case 0:			x = toValue
			case 1:			y = toValue
			case 2:			z = toValue
			default:		let _ = 3		// stops errors
			}
		}
	}
	subscript(index:Int) -> Float {
		get {
			return index==0 ? Float(x) :
				   index==1 ? Float(y) :
				   index==2 ? Float(z) : Float.nan
		}
		set(toValue) {
			switch index {
			case 0:			x = CGFloat(toValue)
			case 1:			y = CGFloat(toValue)
			case 2:			z = CGFloat(toValue)
			default:		let _ = 3		// stops errors
			}
		}
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String {
		let m				= aux.string("ppXYZWena") ?? "XYZ"
		var pre				= ""
		var rv				= "["
		if mode != .tree && mode != .short && x~==0 && y~==0 && z~==0 {
			return "[0 0 0]"			// common special case
		}
		switch mode {		// PpMode .short and .phrase exists in many places
			case .short:			// Fixed length fields
				if x ~== 0 && y ~== 0 && z ~== 0 {		return "0"				}
				// TODO: .short is a bad name, should be .fixed
				let a 		= aux.int_("ppFloatA")
				let b 		= aux.int_("ppFloatB")
				if m.contains("X") 	{	rv += pre+fmt("%*.*f", a, b, x)			}
				if m.contains("Y") 	{	rv += pre+fmt("%*.*f", a, b, y)			}
				if m.contains("Z") 	{	rv += pre+fmt("%*.*f", a, b, z)			}
			case .phrase:
				if self.x ~== 0 && self.y ~== 0 && self.z ~== 0 {
					return "0"
				}
				let a 		= aux.int_("ppFloatA")
				let b 		= aux.int_("ppFloatB")
				var (fullStr, shortStr, shortened) = ("", "", false)
				for (v, vEnt, vName) in [(x, "X", "x"), (y, "Y", "y"), (z, "Z", "z")] {
					var numStr = fmt("%*.*f", a, b, v)
					while numStr.hasSuffix("0") {
						numStr = numStr[0..<numStr.count-1]
					}

					fullStr	+= pre + numStr
					pre		= " "
					let shorten 	= !m.contains(vEnt) || v ~== 0
//					let shorten = vMask & mask == 0 || v ~== 0

					shortStr += shorten ? "" : vName + ":" + numStr
					shortened ||= shorten
				}
				rv 			+= shortened ? shortStr : fullStr
			case .line:
				if m.contains("X") 	{	rv += pre+fmt("%6.3f", x);		pre=" "	}
				if m.contains("Y") 	{	rv += pre+fmt("%6.3f", y);		pre=" "	}
				if m.contains("Z") 	{	rv += pre+fmt("%6.3f", z)				}
			case .tree:
				if m.contains("X") 	{	rv += pre+fmt("x:%6.3f\n", x);	pre=" "	}
				if m.contains("Y") 	{	rv += pre+fmt("y:%6.3f\n", y);	pre=" "	}
				if m.contains("Z") 	{	rv += pre+fmt("z:%6.3f\n", z)			}
				rv 				= String(rv.dropLast())
			case .fullName, .name, .nameTag:		//.fwClassName,
				return ""
			default:
				return ppFixedDefault(mode, aux)		// NO, try default method
		}
		return rv + "]"
	}

	 // MARK: - 16. Global Constants
	static let nan 				= SCNVector3(CGFloat.nan, CGFloat.nan, CGFloat.nan)
	static let zero 			= SCNVector3(0, 0, 0)
	static let origin 			= SCNVector3(0, 0, 0)
	static let unity 			= SCNVector3(1, 1, 1)

	 // Unit Vector for axis:
	static let uX				= SCNVector3(1, 0, 0)
	static let uY				= SCNVector3(0, 1, 0)
	static let uZ				= SCNVector3(0, 0, 1)

	 // MARK: - 17. Debugging Aids
	var description		 : String	{	return  "d'\(pp(.short))'"				}
	var debugDescription : String	{	return "dd'\(pp(.short))'"				}
	var summary			 : String	{	return  "s'\(pp(.short))'"				}
}

// ////////////////////////// SCNVector4 //////////////////////////////////

 /** 	 	A ~== B		*/// Approximately Equal -- All components within epsilon:
func ~==( left:SCNVector4, right:SCNVector4) -> Bool {
	return left.x  ~== right.x && left.y  ~== right.y && left.z  ~== right.z && left.w  ~== right.w }
func !~==( left:SCNVector4, right:SCNVector4) -> Bool {
	return left.x !~== right.x || left.y !~== right.y || left.z !~== right.z || left.w !~== right.w }

 /** 	C = -A	 		*/ // Unary Negate
prefix func - (vector:SCNVector4) -> SCNVector4 {
	return SCNVector4(-vector.x, -vector.y, -vector.z, -vector.w)
}

extension SCNVector4 {

	 // MARK: - 2. Object Variables:
	var isNan	: Bool 		{ return x.isNan || y.isNan || z.isNan || w.isNan	}

	 // MARK: - 3. Factory
	init(_ v:SCNVector3, _ w_:CGFloat=0) {
		self.init()
		(x, y, z, w)  = (v.x, v.y, v.z, w_)
	}

	 // MARK: - 3.5 Codable
	enum ScnVector4Keys:String, CodingKey {
		case x, y, z, w
	}
	 // Serialize
	public func encode(to encoder: Encoder) throws {
		var container 		= encoder.container(keyedBy:ScnVector4Keys.self)

		try container.encode(self.x, forKey:.x)
		try container.encode(self.y, forKey:.y)
		try container.encode(self.z, forKey:.z)
		try container.encode(self.w, forKey:.w)
		//logSer(3, DOClog.log("Encoded  ScnVector4      named"))
	}
	 // Deserialize
	public init(from decoder: Decoder) throws {
		self.init()
		let container 		= try decoder.container(keyedBy:ScnVector4Keys.self)

		x	 					= try container.decode(CGFloat.self, forKey:.x)
		y	 					= try container.decode(CGFloat.self, forKey:.y)
		z	 					= try container.decode(CGFloat.self, forKey:.z)
		w	 					= try container.decode(CGFloat.self, forKey:.w)
		print("Decoded  as? ScnVector4 \(self.pp(.line)) ")
	}

	init(string:String) throws {
		var arg : [Double]		= []
		for str in string.split(separator:" ") where !str.isEmpty {
			if let d 			= Double(str) {
				arg.append(d)
			}
		}
		let scnVector4			= arg.count==0 ? SCNVector4(x:0,      y:0,	    z:0,	  w:0) :
								  arg.count==1 ? SCNVector4(x:arg[0], y:0,	    z:0,	  w:0) :
								  arg.count==2 ? SCNVector4(x:arg[0], y:arg[1], z:0,	  w:0) :
								  arg.count==3 ? SCNVector4(x:arg[0], y:arg[1], z:arg[2], w:0) :
								  arg.count==4 ? SCNVector4(x:arg[0], y:arg[1], z:arg[2], w:arg[3]) :
								  				 SCNVector4(x:.nan,   y:.nan,	z:.nan,	  w:.nan)		// rethink
		self					= scnVector4

		if let scnVector3		= SCNVector3(from:string) ??			// x y z
								  SCNVector3(from:string + " 0") ??	// x y 0
								  SCNVector3(from:string + " 0 0") {
			self				= SCNVector4(scnVector3)
		}
		else {
			bug//throw()
		}
	}
	 // MARK: - 4.1 Subscript Access
	subscript(index:Int) -> CGFloat {
		get {
			return index==0 ? x :
				   index==1 ? y :
				   index==2 ? z :
				   index==3 ? z : CGFloat.nan
		}
		set(toValue) {
			switch index {
			case 0:				x = toValue
			case 1:				y = toValue
			case 2:				z = toValue
			case 3:				w = toValue
			default:			let _ = 3		// stops errors
			}
		}
	}
	subscript(index:Int) -> Float {
		get {
			return index==0 ? Float(x) :
				   index==1 ? Float(y) :
				   index==2 ? Float(z) :
				   index==3 ? Float(z) : Float.nan
		}
		set(toValue) {
			switch index {
			case 0:				x = CGFloat(toValue)
			case 1:				y = CGFloat(toValue)
			case 2:				z = CGFloat(toValue)
			case 3:				w = CGFloat(toValue)
			default:			let _ = 3		// stops errors
			}
		}
	}
/*
	case fwClassName	//    (Really should be "class"?)		(e.g: "Port"
	case nameTag		// 10 Uid								(e.g: "4C4")
	case uidClass		//5,8 Uid:Class							(e.g: "4C4:Port")
	case classUid		//  9 Class<nameTag>					(e.g: "Port<4C4>")
  
	case name			//6,14name in parent, a single token 	(e.g: "P")
	case nameTagClass	//  7 name/Uid:Class					(e.g: "P/4C4:Port")
  
	case fullName		// 13 path in composition 				(e.g: "/net/a.P")
	case fullNameUidClass//11 Identifier: fullName/Uid:Class	(e.g: "ROOT/max.P/4C4:Port")
  
	 // How to PrettyPrint Contents:

 */
	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4defaultPp) -> String {
		let m 					= aux.string("ppXYZWena") ?? "XYZW"
		let a 					= aux.int_("ppFloatA")
		let b 					= aux.int_("ppFloatB")
		var pre					= ""
		var rv					= "["
		switch mode {		// PpMode .short and .phrase exists in many places
			case .short:
				if self.x ~== 0 && self.y ~== 0 && self.z ~== 0 && self.w ~== 0 {
					return "0"
				}
				if m.contains("X") 	{	rv += pre+fmt("%4.1f",  x);		pre=" "	}
				if m.contains("Y") 	{	rv += pre+fmt("%4.1f",  y);		pre=" "	}
				if m.contains("Z") 	{	rv += pre+fmt("%4.1f",  z);		pre=" "	}
				if m.contains("W") 	{	rv += pre+fmt("%4.1f ", w)				}
			case .phrase:
				if self.x ~== 0 && self.y ~== 0 && self.z ~== 0 && self.w ~== 0 {
					return "0"
				}
				var (fullStr, shortStr, shortened) = ("", "", false)
				for (v, vEnt, vName) in [(x, "X", "x"), (y, "Y", "y"), (z, "Z", "z"), (w, "Z", "w")] {
					let numStr	= fmt("%*.*f", a, b, v)
					fullStr		+= pre + numStr
					pre			= " "
					let shorten = !m.contains(vEnt) || v ~== 0
					shortStr	+= shorten ? "" : vName + ":" + numStr
					shortened	||= shorten
				}
				rv 				+= shortened ? shortStr : fullStr
			case .line:
				//m 			= "XYZW"	// all components, for now
				if m.contains("X") 	{	rv += pre+fmt("%6.3f ", x);		pre=" " }
				if m.contains("Y") 	{	rv += pre+fmt("%6.3f ", y);		pre=" " }
				if m.contains("Z") 	{	rv += pre+fmt("%6.3f ", z);		pre=" " }
				if m.contains("W") 	{	rv += pre+fmt("%6.3f ", w)				}
				rv 				= String(rv.dropLast())
			case .tree:
				//m 			= "XYZW"	// all components, for now
				if m.contains("X") 	{	rv += pre+fmt("x:%6.3f\n", x);	pre=" " }
				if m.contains("Y") 	{	rv += pre+fmt("y:%6.3f\n", y);	pre=" " }
				if m.contains("Z") 	{	rv += pre+fmt("z:%6.3f\n", z);	pre=" " }
				if m.contains("W") 	{	rv += pre+fmt("w:%6.3f\n", w)   		}
				rv 				= String(rv.dropLast())
			case .fullName, .name, .nameTag:		//.fwClassName,
				return ""
			default:
				return ppFixedDefault(mode, aux)		// NO, try default method
		}
		return rv + "]"
	}

	 // MARK: - 17. Debugging Aids
	var description			:String	{	return  "d'\(pp(.short))'"				}
	var debugDescription	:String	{	return "dd'\(pp(.short))'"				}
	var summary				:String	{	return  "s'\(pp(.short))'"				}

	 // MARK: - 16. Global Constants
	static let nan 			= SCNVector4(CGFloat.nan, CGFloat.nan, CGFloat.nan, CGFloat.nan)
	static let zero 		= SCNVector4(0, 0, 0, 0)
	static let uX			= SCNVector4(1, 0, 0, 0)
	static let uY			= SCNVector4(0, 1, 0, 0)
	static let uZ			= SCNVector4(0, 0, 1, 0)
	static let uW			= SCNVector4(0, 0, 0, 1)
}


