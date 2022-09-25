//
//  CG++.swift
//  CG++.swift -- my enhancements to CG... things C1804PAK

import SceneKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
	return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
	return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func sin(a: CGFloat) -> CGFloat {
	return CGFloat(sin(Float(a)))
}
func cos(a: CGFloat) -> CGFloat {
	return CGFloat(cos(Float(a)))
}
func sqrt(a: CGFloat) -> CGFloat {
	return CGFloat(sqrtf(Float(a)))
}

extension CGPoint {
	func length() -> CGFloat {
		return sqrt(x*x + y*y)
	}
	func normalized() -> CGPoint {
		return self / length()
	}
}

extension CGFloat {		// convert to Float
	enum CGFloatKeys: String, CodingKey {	case float		}
	 /// Serialize
	func encode(to encoder: Encoder) throws  {
		var container 		= encoder.container(keyedBy:CGFloatKeys.self)
		let aFloat			= Float(self)
		try container.encode(aFloat, forKey:.float)
	}
	 /// Deserialize
	init(from decoder: Decoder) throws {
		let container 		= try decoder.container(keyedBy:CGFloatKeys.self)
		let aFloat			= try container.decode(Float.self, forKey:.float)
		self				= CGFloat(aFloat)
	}
}
