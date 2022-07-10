//  TestsFoo.swift -- HaveNWant network for FooTry3 ©2022PAK
//
import SceneKit

class TestsFoo : Library {
	override func loadTest(args:ScanArgs, state:inout ScanState) {
		super.loadTest(args:args, state:&state)
		let e 	 : FwConfig		= [:]		// Logs OFF "logPri4all":8

		 // MARK: - * Tivo World
		state.scanSubMenu		= "Proto Menu"
		xr("Prototype HaveNWant", e, { Part(["parts":[
					Sphere(		["size":"2 2 2"]),								//	//	b.color0		= NSColor.red
					Cylinder(	["size":"2 2 2"]),								//		rootPart.addChild(b)
					Box(		["size":"2 2 2"]),								//		for i in 1...3 {
					Hemisphere(	["size":"2 2 2"]),								//			let p		= Sphere()
		]]) })
	}
}

