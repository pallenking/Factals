//  TestsFoo.swift -- HaveNWant network for FooTry3 ©2022PAK
//
import SceneKit

class TestsFoo : Book {
	override func loadTest(args:ScanForKey, state:inout ScanState) {
		super.loadTest(args:args, state:&state)
		let e 	 : FwConfig		= [:]		// Logs OFF "logPri4all":8

		 // MARK: - * Tivo World
		let ign	= "-"	//"-":ignore; "":test//
		state.scanSubMenu		= ign
		r("Prototype HaveNWant", e, { Part(["colorX":"yellow", "parts":[
			Sphere(		["size":"1 1 1", "color":"orange"]),		//	//	b.color0		= NSColor.red
			Cylinder(	["size":"1 1 1", "color":"red"]),			//		parts.addChild(b)
			//Box(		["size":"1 1 1"]),							//		for i in 1...3 {
			//Hemisphere(["size":"1 1 1"]),							//			let p		= Sphere()
		]]) })

		state.scanSubMenu		= ign+"Aaaa"
		r("Mirror Display WORKS", e + logAt(all:8), {
			Net(["parts":[
				Cylinder(	["size":"1 1 1", "color":"red"]),
				Broadcast(),
				Cylinder(	["size":"1 1 1", "color":"red"]),
			] ])
		})

		state.scanSubMenu		= ign+"Aaaa/Bbbb"
		r("Mirror Display WORKS", e + logAt(all:8), {
			Net(["parts":[
				Broadcast(),
				Broadcast(),
				Broadcast(),
			] ])
		})

		state.scanSubMenu		= ign+"Aaaa/Bbbb/Cccc"
		r("Broatcast",  	e,	{ Broadcast(["n":"a", "lat":1])})				// 190311 +

		state.scanSubMenu		= ign+"Aaaa/Bbbb/Cccc/Dddd"
		r("Broatcast",  	e,	{ Broadcast(["n":"a", "lat":1])})				// 190311 +
	}
}

