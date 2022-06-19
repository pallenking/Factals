//  SCNVector9XCTest.swift -- Fix BUG: Redundant conformance to protocol in unit test only ©21200909PAK
// https://stackoverflow.com/questions/56169303/redundant-conformance-to-protocol-in-unit-test-only

import SceneKit

extension SCNVector3 : Equatable, Codable {										}

extension SCNVector4 : Equatable, Codable {
	public static func == (lhs: SCNVector4, rhs: SCNVector4) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
	}
}

extension SCNMatrix4 : Equatable {		}

extension SCNNode : ObservableObject {	}
