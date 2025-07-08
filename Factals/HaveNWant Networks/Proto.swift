//  Proto.swift -- Prototype HaveNWant network ©2021PAK
//
import SceneKit

class Proto : Book {
	override func loadTest(args:ScanForKey, state:inout ScanState) {
		super.loadTest(args:args, state:&state)
		let e 	 : FwConfig		= logAt(8)

		 // MARK: - * Tivo World
		state.scanSubMenu		= "Proto Menu"
//		r("Prototype HaveNWant", e, { Net(["parts":[
//			Actor(["n":"wheelA", "placeMy":"linky",
//				"con":Tunnel(["struc":["z", "y"], "f":1]),
//				"parts":[
//					MaxOr( ["n":"ma", "share":["z", "y"], "f":0]),
//					MinAnd(["n":"mi", "share":["a", "b", "c", "d"], "P":"ma", "f":1]),
//					MinAnd(["n":"mj", "share":["a", "b"], "f":1]),
//				],
//				"evi":Tunnel(["struc":["a", "b", "c", "d"], "placeMy":"stackz 0 -1"]),
//			]),
//			Generator(["n":"lo", "events":["a", "b", "c", "d", "again"], "P":"wheelA/evi"]),
//		]]) })
	}
}

