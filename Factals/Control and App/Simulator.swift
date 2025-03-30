//  Simulator.swift -- simulation control elements C190715PAK
import SceneKit
import Observation


@Observable
class Simulator : NSObject/*, ObservableObject*/, Codable {		// Logd // NEVER NSCopying, Equatable	//Logd

	 // MARK: - 2. Object Variables:
	weak var factalsModel:FactalsModel? = nil// Owner
	 /// Simulation is fully built and running
	var simBuilt : Bool = false				// sim constructed?
	{	didSet {		// whenever simRun gets set, try to st
			if simRun && simBuilt {
				simTaskRunning	= false		// (so startSimulationTask
				startSimulationTask()		// try irrespective of simTa
			}
		}
	}
	 /// Enable simulation task to run:																					//
	var simRun : Bool 	 		= false 	// sim enabled to run?{
	{	didSet {
			if simBuilt && !simTaskRunning {
				simTaskRunning	= false		// (so startSimulationTask notices)
				startSimulationTask()		// try irrespect~ of simTaskRunning
			}
		}
	}
	var timeNow 		: Float	= 0.0
	var globalDagDirUp	: Bool	= true
	var timeStep	   	: Float	= 0.01
	var simTaskPeriod  	: Float	= 0.01
								
	var timingChains	: [TimingChain] = []
	var logSimLocks				= true		// Overwritten by Configuration

	 // MARK: - 2.1 Simulator State
	var simTaskRunning			= false		// sim task pending?
	var linkChits		:  Int	= 0			// by things like links
	var startChits	  	: UInt8	= 0			// set to get simulator going

	func isSettled() -> Bool {
		let nPortsBuisy 		= factalsModel?.partBase.tree.portChitArray().count ?? 0	// Busy Ports
		let nLinksBuisy 		= linkChits							// Busy Links
		return nPortsBuisy + nLinksBuisy == 0 ||  startChits > 0
	}

	 // MARK: - 2.? init()
	init(configure:FwConfig) {
		super.init()
		self.configure(from:configure)
	}
	 // MARK: - 2.3 Push Configuration to Controllers
	 /// Controls the Simulator's operation
	func configure(from config:FwConfig) {
		if let se				= config.bool("simRun") {
/**/		simRun 			= se						// set or reset
		}
		if let ts				= config.float("timeStep") {
			timeStep 			= ts
		}
		if let stp				= config.float("simTaskPeriod") {
			simTaskPeriod 		= stp
		}
		if let pst				= config.bool("logSimLocks") {
			logSimLocks	 		= pst		// unset (not reset) if not present
		}
	}
																		
	// MARK: - 3. Factory
	override init() {
		super.init()
	}
// START CODABLE //////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum SimulatorKeys: String, CodingKey {
		case timingChains
		case simBuilt
		case simRun
		case simTaskRunning
		case kickstart
		case unsettledOwned
		case timeNow
		case timeStep
		case globalDagDirUp
	}
	 // Serialize
	func encode(to encoder: Encoder) throws  {
		var container 		= encoder.container(keyedBy:SimulatorKeys.self)
		try container.encode(timingChains, 	forKey:.timingChains)
		try container.encode(simBuilt, 		forKey:.simBuilt)
		try container.encode(simRun, 	forKey:.simRun)
		try container.encode(simTaskRunning,forKey:.simTaskRunning)
		try container.encode(startChits, 	forKey:.kickstart)
		try container.encode(linkChits,		forKey:.unsettledOwned)
		try container.encode(timeNow, 		forKey:.timeNow)
		try container.encode(timeStep,		forKey:.timeStep)
		try container.encode(globalDagDirUp,forKey:.globalDagDirUp)
//		logSer(3, "Encoded")
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 				= try decoder.container(keyedBy:SimulatorKeys.self)
		timingChains 				= try container.decode([TimingChain].self, forKey:.timingChains	)
		simBuilt					= try container.decode(			Bool.self, forKey:.simBuilt		)
		simRun					= try container.decode(			Bool.self, forKey:.simRun	)
		simTaskRunning				= try container.decode(			Bool.self, forKey:.simTaskRunning)
		startChits					= try container.decode(		   UInt8.self, forKey:.kickstart	)
		linkChits					= try container.decode(		     Int.self, forKey:.unsettledOwned)
		timeNow						= try container.decode(		   Float.self, forKey:.timeNow 		)
		timeStep					= try container.decode(		   Float.self, forKey:.timeStep	)
		globalDagDirUp				= try container.decode(			Bool.self, forKey:.globalDagDirUp)

		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		logSer(3, "Decoded  as? Controller")
	}
// END CODABLE /////////////////////////////////////////////////////////////////
	   // MARK: - x.1 Simulator Task
	  /// Start Simulation Task
	 /// N.B: start occurs on a thread which has Part tree already locked
	func startSimulationTask() {
		//return // never simulate
		if simBuilt && simRun {				// want to run
			if simTaskRunning == false {		// if not now running
				simTaskRunning	= true
				logEve(6, "@ @ @ @ STARTING Simulation Task (simRun=\(simRun))")
			}
//			let taskPeriod		= factalsModel?.fmConfig.double("simTaskPeriod") ?? 2	// DEFAULT IS VERY JERKEY
			let modes			= [RunLoop.Mode.eventTracking, RunLoop.Mode.default]
			perform(#selector(simulationTask), with:nil, afterDelay:TimeInterval(Float(simTaskPeriod)), inModes:modes)
		}
		else {
			stopSimulationTask()				// ?? Perhaps wrong
		}
	}
	func stopSimulationTask() {
		if simTaskRunning == true {				// now running
			simTaskRunning		= false
			logEve(6, "@ @ @ @ STOPPED  Simulation Task \n")
			 // Remove "perform-requests" from the current run loop, not ALL run loops.
			NSObject.cancelPreviousPerformRequests(withTarget:self)
		}
	}
	 /// Simulation Task auto-repeats once called
	@objc func simulationTask() {
		simulateOneStep()
		startSimulationTask()		// reStartSimulationTask
	}
	func simulateOneStep() {
		guard simBuilt			else {	return panic("calling for simulationTask() before simBuilt") }
		guard simRun			else {	return 									}
		guard let partBase 		= factalsModel?.partBase else {	return			}

		guard partBase  .lock  (for:"simulationTask", logIf:logSimLocks)
								else {	debugger("simulationTask couldn't get PART lock")	}

	/**/	partBase.tree.simulate(up:globalDagDirUp)	// RUN Simulator ONE Cycle: up OR down the entire Network: ///////

			globalDagDirUp		= !globalDagDirUp		// Alternate Up and Down
			timeNow				+= timeStep
			if  startChits > 0 {			// Clear out start cycles
				startChits		-= 1
			}

		partBase .unlock (for:"simulationTask", logIf:logSimLocks)
	}
		 // MARK: - 13. IBActions
		/// Prosses keyboard down events
	   /// - Parameter from: -- NSEvent to process
	  ///  - Parameter vew:         -- The Vew to use
	 ///   - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {return false}

		var rv					= false
		for timingChain in timingChains
	/**/{	rv					||= timingChain.processEvent(nsEvent:nsEvent, inVew:vew)}
		if rv
		{	return true															}

		guard nsEvent.type == .keyDown else { return false} // /// Key UP //////
		switch character {									// /// Key DOWN ////
		case " ":							// perhaps "+ shift"
			 // One more cycle, stop if running:
			simRun 				= !simRun
			if simRun {
				startChits		= 4
			}	// (Not using ppLog -- log numbers to be independent of
			logEve(7, "++++++++++ simRun=\(simRun) globalDagDirUp=\(globalDagDirUp) kickstart=\(startChits)")
			return true
		case "k":							// kickstart simulator
			simRun 				= true
			startChits			= 4
			logEve(7, "++++++++++ simRun=\(simRun) globalDagDirUp=\(globalDagDirUp) kickstart=\(startChits)")
			return true
		case "?":
			print ("=== Simulator   commands:",
				"\t' '             -- Toggel simRun: run(-1) / stop(0) ",
				"\t'k'             -- kickstart simulator",
				separator:"\n")
		default: nop
		}
		return false
	}
}
