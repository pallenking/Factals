// Generator.swift -- composite objetct which generates stimulus for a HaveNWant network C2013

import SceneKit

 // Present clocked, interface "Discrete Time" data into a HaveNWant Network:
// 	  Contains 3 classes
//		* Dt: Discrete Time: connects discrete time to HaveNWant analog time.
//		* Tc: Timing Chain: to insure the network settles before the new sample time enters
// 		* Wm: World Model: operates in discrete sample time
//						has clocked data (Out?,Hist?) prob,again,gate
/*
		(HaveNWant network)
				  [Dt]	  [Dt]		DiscreteTime
					P		P
					:		:
					S		S					discreteTimes.append(dt2add)
					  [Tc]			TimingChain
						P
						:
						S
					  [Wm]			World Model
		Synchronous WorldModel			// P,S are Ports
 */
class Generator : Net {

	 // MARK: - 3. Part Factory
	override init(_ argCon:FwConfig = [:]) {
		let defaultCon:FwConfig	= ["placeMy":"stacky"]
		let config				= defaultCon + argCon

		super.init(config) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

		  //  WorldModel.swift   Args (if needed)
		 //  -- Basic discrete time/value data source
		var wmArgs  : FwConfig	= [:]
		if let events 			= partConfig["events"] {
			wmArgs["events"] 	= events
			partConfig["events"] = nil
		}
		if let prob 			= partConfig["prob"]?.asFloat {
			wmArgs["prob"] 		= prob
			partConfig["prob"]	= nil
		}
		if let eventLimit		= partConfig["eventLimit"]?.asInt {
			wmArgs["eventLimit"] = eventLimit
			partConfig["eventLimit"] = nil	// Remove from partConfig and put in wmArgs
		}
		let wmNeeded			= wmArgs.count != 0
		wmArgs					+= ["n":"wm", "f":1]

		  // /////  TimingChain.swift: Insert Discrete Time samples into HaveNWant Network
		 //
		var tcArgs : FwConfig	= ["n":"tc", "f":1]//, f:flipMe]
		let dtNeeded 			= partConfig["dtNeeded"]?.asBool ?? true
		if dtNeeded {
			tcArgs["P="] 		= "dt"		// Discrete Time --> timingChain
		}
		if wmNeeded {
			tcArgs["S="] 		= "wm"		// World Experiment   --> timingChain
		}

		  // //////  DiscreteTime.swift   Args: Connects to HnW Network
		 //  An Atom which generates data C2014PAK
		var dtArgs : FwConfig	= ["n":"dt", "f":1]
		if let nib 				= partConfig["nib"] {
			dtArgs["nib"] 		= nib
		}
		if let p				= partConfig["P"] {	// generator connects to network here
			dtArgs["P"] 		= p
			partConfig["P"]	= nil
		}
		if let resetTo			= partConfig["resetTo"] {
			dtArgs["resetTo"]	= resetTo
			partConfig["resetTo"] = nil
		}
		if let ie 				= partConfig["incrementalEvents"] {
			dtArgs["incrementalEvents"] = ie
			partConfig["incrementalEvents"] = nil
		}

		 // /////////// MAKE Elements
		if dtNeeded {
			let dt				= DiscreteTime(dtArgs)	// MAKE Discrete Time
			assertWarn(dtArgs["P"] != nil, "'\(dt.pp(.fullNameUidClass).field(-35))' \"P\":Port unconnected")
			addChild(dt)				// //////
		}
		addChild(TimingChain(tcArgs))	// //////		// MAKE Timing Chain
		if wmNeeded {
			let wm				= WorldModel(wmArgs)
			addChild(wm)				// //////		// MAKE World Model
		}

		 // ////////// Flip order if needed
		if partConfig.bool_("f") {						// reverse order
			children			= children.reversed()
		}
	}

	 // MARK: - 3.5 Codable
	 // Deserialize
	required init?(coder: NSCoder) { debugger("init(coder:) has not been implemented") }
	required init(from decoder: Decoder) throws {
		debugger("init(from:) has not been implemented")						}
//	// MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Generator
//		logSer(3, "copy(with as? Generator       '\(fullName)'")
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
bug;	return super.equalsFW(rhs)
	}
}
