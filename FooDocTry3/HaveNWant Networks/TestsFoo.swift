//  TestsFoo.swift -- HaveNWant network for FooTry3 ©2022PAK
//
import SceneKit

class TestsFoo : Library {
	override func loadTest(args:ScanArgs, state:inout ScanState) {
		super.loadTest(args:args, state:&state)
		let e 	 : FwConfig		= [:]		// Logs OFF "logPri4all":8

		 // MARK: - * Tivo World
		state.scanSubMenu		= "Proto Menu"
		xr("Prototype HaveNWant", e, { Part(["colorX":"yellow", "parts":[
			Sphere(		["size":"1 1 1", "color":"orange"]),		//	//	b.color0		= NSColor.red
			Cylinder(	["size":"1 1 1", "color":"red"]),			//		rootPart.addChild(b)
			Box(		["size":"1 1 1"]),							//		for i in 1...3 {
			Hemisphere(	["size":"1 1 1"]),							//			let p		= Sphere()
		]]) })
		r("Mirror Display WORKS", e + log(all:8), {
			Net(["parts":[
				Cylinder(	["size":"1 1 1", "color":"red"]),
				Broadcast(),
				Cylinder(	["size":"1 1 1", "color":"red"]),
			] ])
		})
		r("Mirror Display WORKS", e + log(all:8), {
			Net(["parts":[
				Broadcast(),
				Broadcast(),
				Broadcast(),
			] ])
		})
		r("Broatcast",  	e,	{ Broadcast(["n":"a", "lat":1])})				// 190311 +
	}
}

