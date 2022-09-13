// Generator.swift -- composite objetct which generates stimulus for a HaveNWant network C2013

import SceneKit

 // A Generator is supervises the creation and expression of sampled data to a Network
// It is a composite objetct, composed of
// 		* A World Model (WM) which operates in discrete sample time
//		* A Timing Chain (TC) to insure the network settles before the new sample time enters
//		* A Discrete Time (DT) to connect to the network
/*
				  S	 S	  S	 S
				  [Dt]	  [Dt]
					P		P
					:		:
					S		S		discreteTimes.append(dt2add)
					  [Tc]
						P
						:
						S
					  [Wm]
 */
class Generator : Net {

	 // MARK: - 3. Part Factory
	override init(_ argCon:FwConfig = [:]) {
		let defaultCon:FwConfig	= ["placeMy":"stacky"]
		let config				= defaultCon + argCon

		super.init(config) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//		Generator([P:wheelA/evi, events:[6 elts], placeMy:stacky]) name:'lo'

		  //  WorldModel.swift   Args (if needed)
		 //  -- Basic discrete time/value data source
		var wmArgs  : FwConfig	= [:]
		if let events 			= localConfig["events"] {
			wmArgs["events"] 	= events
			localConfig["events"] = nil
		}
		if let prob 			= localConfig["prob"]?.asFloat {
			wmArgs["prob"] 		= prob
			localConfig["prob"] = nil
		}
		if let eventLimit		= localConfig["eventLimit"]?.asInt {
			wmArgs["eventLimit"] = eventLimit
			localConfig["eventLimit"] = nil
		}
		let wmNeeded			= wmArgs.count != 0
		wmArgs					+= ["n":"wm", "f":1]

		  // /////  TimingChain.swift: Insert Discrete Time samples into HaveNWant Network
		 //
		var tcArgs : FwConfig	= ["n":"tc", "f":1]//, f:flipMe]
		let dtNeeded 			= localConfig["dtNeeded"]?.asBool ?? true
		if dtNeeded {
			tcArgs["P="] 		= "dt"		// Discrete Time --> timingChain
		}
		if wmNeeded {
			tcArgs["S="] 		= "wm"		// World Experiment   --> timingChain
		}

		  // //////  DiscreteTime.swift   Args: Connects to HnW Network
		 //  An Atom which generates data C2014PAK
		var dtArgs : FwConfig	= ["n":"dt", "f":1]
		if let nib 				= localConfig["nib"] {
			dtArgs["nib"] 		= nib
			localConfig["nib"]	= nil
		}
		if let p				= localConfig["P"] {	// generator connects to network here
			dtArgs["P"] 		= p
			localConfig["P"]	= nil
		}
		if let resetTo			= localConfig["resetTo"] {
			dtArgs["resetTo"]	= resetTo
			localConfig["resetTo"] = nil
		}
		if let ie 				= localConfig["incrementalEvents"] {
			dtArgs["incrementalEvents"] = ie
			localConfig["incrementalEvents"] = nil
		}

		 // /////////// MAKE Elements
		if dtNeeded {
			let dt				= DiscreteTime(dtArgs)	// MAKE Discrete Time
			assertWarn(dtArgs["P"] != nil, "'\(dt.pp(.fullNameUidClass))' \"P\":Port unconnected")
			addChild(dt)
		}
		addChild(TimingChain(tcArgs))					// MAKE Timing Chain
		if wmNeeded {
			let wm				= WorldModel(wmArgs)
			addChild(wm)								// MAKE World Model
		}

		 // ////////// Flip order if needed
		if localConfig.bool_("f") {						// reverse order
			children			= children.reversed()
		}
	}

	 // MARK: - 3.5 Codable
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : Generator		= super.copy(with:zone) as! Generator
bug//	theCopy.con				= self.con
		atSer(3, logd("copy(with as? Generator       '\(fullName)'"))
		return theCopy
	}

	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	 // MARK: - 3.7 Equitable				// ## IMPLEMENT!
	func varsOfGeneratorEq(_ rhs:Part) -> Bool {
		guard let rhsAsGenerator = rhs as? Generator else {		return false	}
		return true
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfGeneratorEq(part)
	}
}
