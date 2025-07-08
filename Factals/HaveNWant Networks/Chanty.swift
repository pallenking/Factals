//  Chanty.swift -- Miscellaneous small networks ©2021PAK
//
import SceneKit
let e 	 : FwConfig				= logAt(8)

class WorldSpaniel : Book {
	override func loadTest(args:ScanForKey, state:inout ScanState) {
		super.loadTest(args:args, state:&state)

		 // MARK: - * Tivo World
		state.scanSubMenu		= "Proto Menu"
		r("Prototype HaveNWant", e, { Net(["parts":[
			/*
			Coalition(USA, friends:[Ukrain, other], enemies:[Russia,other2])
			Coalition(other, friends:[USA,Ukrain]], enemies:[Russia,other2])
			Coalition(Russia, friends:[China, Iran, other2], enemies:[US, other, Ukrain])
			Coalition(other2, friends:[Russia,China], enemies:[Iran,china1])
			Coalition(China, friends:[Russia, other2], enemies:[])
//			Coalition(, friends:[], enemies:[])
			 */
		] ]) })
	}
}

class Chanty : Book {
	override func loadTest(args:ScanForKey, state:inout ScanState) {
		super.loadTest(args:args, state:&state)

		 // MARK: - * Tivo World
		state.scanSubMenu		= "Proto Menu"
//		r("Prototype HaveNWant", e, { Net(["parts":[...]) })
	}
}

