//  Random.swift -- interface to xx  ©2020PAK

import SceneKit

 // MARK: - Random Numbers
func randomProb(p:Float) -> Bool {				// 1 with prob p
	let r 						= Float(drand48())
	return r < p
}
func randomDist(_ min:Float, _ max:Float) -> Float {	// float boxcar, a..b, incl
	assert(max>=min, "illegal call, a>b")
	if min == max {						// boxcar is one point
		return min
	}
	let frac 					= Float(drand48())
	let rv						= min + (max-min) * frac
	if rv == max {					// we never want to return the upper value.
		return randomDist(min, max)		// N.B: This has an infinite probabilistic tail
	}
	return rv;
}
func randomUInt(_ limit:UInt64=0x100000000) -> UInt {	// float boxcar, a..b, incl
	let rv					= drand48() * Double(limit)
	let rv2					= UInt(rv)
	return rv2
}

func setRandomSeed(seed:Int) {
	srand48(seed)
//	static char seedState[256];			// currently, only one random generator supplied
//	initstate((int)seed, seedState, 128);
}

 // wall clock time
func dateTime(format:String) -> String {
	let formatter 			= DateFormatter()
	formatter.dateFormat 	= format
	formatter.timeZone 		= TimeZone(abbreviation: "GMT-5")
	let myString			= formatter.string(from: Date())

	return myString
}
