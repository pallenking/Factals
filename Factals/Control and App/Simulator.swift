//  Simulator.swift -- simulation control elements C190715PAK
import SceneKit

class Simulator : NSObject, Codable {		// Logd // NEVER NSCopying, Equatable	//Logd

	 // MARK: - 2. Object Variables:
	weak var factalsModel:FactalsModel? = nil// Owner

	var timingChains:[TimingChain] = []
	var timeNow			: Float	= 0.0
	var timeStep		: Float = 0.01
	var globalDagDirUp	: Bool	= true
	var logSimLocks				= true		// Overwritten by Configuration

	// MARK: - 2.1 Simulator State
	var simTaskRunning			= false		// sim task pending?
	var portChits		: Int	{	factalsModel?.partBase.tree.portChitArray().count ?? 0	}
	var linkChits		: Int	= 0			// by things like links
	var startChits	  	:UInt8	= 0			// set to get simulator going

	 /// Enable simulation task to run:																					//
	var simEnabled : Bool 	 	= false 	// sim enabled to run?{
	{	didSet {
			if simBuilt && !simTaskRunning {
				simTaskRunning	= false		// (so startSimulationTask notices)
				startSimulationTask()		// try irrespect~ of simTaskRunning
			}
		}
	}
	 /// Simulation is fully built and running
	var simBuilt : Bool = false				// sim constructed?
	{	didSet {		// whenever simEnabled gets set, try to st
			if simEnabled && simBuilt {
				simTaskRunning	= false		// (so startSimulationTask
				startSimulationTask()		// try irrespective of simTa
			}
		}
	}
	func isSettled() -> Bool {
		let nPortsBuisy 		= factalsModel?.partBase.tree.portChitArray().count ?? 0	// Busy Ports
		let nLinksBuisy 		= linkChits							// Busy Links
		return nPortsBuisy + nLinksBuisy == 0 ||  startChits > 0
	}
	 // MARK: - 2.3 Push Configuration to Controllers
	 /// Controls the Simulator's operation
	func configure(from c:FwConfig) {
		if let se				= c.bool("simEnabled") {
/**/		simEnabled 			= se						// set or reset
		}
		if let tStep			= c.float("timeStep") {
			timeStep 			= tStep
		}
		if let pst				= c.bool("logSimLocks") {
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
		case simEnabled
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
		try container.encode(simEnabled, 	forKey:.simEnabled)
		try container.encode(simTaskRunning,forKey:.simTaskRunning)
		try container.encode(startChits, 	forKey:.kickstart)
		try container.encode(linkChits,		forKey:.unsettledOwned)
		try container.encode(timeNow, 		forKey:.timeNow)
		try container.encode(timeStep,		forKey:.timeStep)
		try container.encode(globalDagDirUp,forKey:.globalDagDirUp)
//		atSer(3, logd("Encoded"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 				= try decoder.container(keyedBy:SimulatorKeys.self)
		timingChains 				= try container.decode([TimingChain].self, forKey:.timingChains	)
		simBuilt					= try container.decode(			Bool.self, forKey:.simBuilt		)
		simEnabled					= try container.decode(			Bool.self, forKey:.simEnabled	)
		simTaskRunning				= try container.decode(			Bool.self, forKey:.simTaskRunning)
		startChits					= try container.decode(		   UInt8.self, forKey:.kickstart	)
		linkChits					= try container.decode(		     Int.self, forKey:.unsettledOwned)
		timeNow						= try container.decode(		   Float.self, forKey:.timeNow 		)
		timeStep					= try container.decode(		   Float.self, forKey:.timeStep	)
		globalDagDirUp				= try container.decode(			Bool.self, forKey:.globalDagDirUp)

		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		atSer(3, logd("Decoded  as? Controller"))
	}
// END CODABLE /////////////////////////////////////////////////////////////////
	   // MARK: - x.1 Simulator Task
	  /// Start Simulation Task
	 /// N.B: start occurs on a thread which has Part tree already locked
	func startSimulationTask() {
		//return // never simulate
		if simBuilt && simEnabled {				// want to run
			if simTaskRunning == false {		// if not now running
				simTaskRunning	= true
				atBld(3, logd("# # # # STARTING Simulation Task (simEnabled=\(simEnabled))"))
			}
			let taskPeriod		= factalsModel?.fmConfig.double("simTaskPeriod") ?? 0.01
			let modes			= [RunLoop.Mode.eventTracking, RunLoop.Mode.default]
			perform(#selector(simulationTask), with:nil, afterDelay:taskPeriod, inModes:modes)
		}
		else {
			stopSimulationTask()				// ?? Perhaps wrong
		}
	}
	func stopSimulationTask() {
		if simTaskRunning == true {				// now running
			simTaskRunning		= false
			atBld(3, logd("# # # # STOPPED  Simulation Task \n"))
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
		guard simEnabled		else {	return 									}
		guard let partBase 		= factalsModel?.partBase else {	return			}

//partBase.foob(for: "xxxkwjfo")

		guard partBase  .lock  (for:"simulationTask", logIf:logSimLocks)
								else {	fatalError("simulationTask couldn't get PART lock")	}

	/**/	partBase.tree.simulate(up:globalDagDirUp)	// RUN Simulator ONE Cycle: up OR down the entire Network: ///////

			globalDagDirUp		= !globalDagDirUp
			timeNow				+= timeStep
			if startChits > 0 {			// Clear out start cycles
				startChits		-= 1
			}

		partBase .unlock (for:"simulationTask", logIf:logSimLocks)
	}
	// MARK: - 14. Building
	var log : Log {	factalsModel?.log ?? { fatalError("factalsModel nil in Simulator")}()}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}			//Cannot convert return expression of type 'Optional<_>' to return type 'Log'

	// MARK: - 13. IBActions
		/// Prosses keyboard key
	   /// - Parameter from: -- NSEvent to process
	  ///  - Parameter vew:         -- The Vew to use
	 ///   - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						// Simulator has no key-ups
		}
	//	let shift 				= nsEvent.modifierFlags.contains(.shift)
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {return false}
		switch character {
		case " ":							// perhaps "+ shift"
			 // One more cycle, stop if running:
			simEnabled 			= !simEnabled
			if simEnabled {
				startChits		= 4
			}	// (Not using ppLog -- log numbers to be independent of
			print("++++++++++ simEnabled=\(simEnabled) globalDagDirUp=\(globalDagDirUp) kickstart=\(startChits)")
			return true
		case "k":							// kickstart simulator
			simEnabled 			= true
			startChits			= 4
			print("++++++++++ simEnabled=\(simEnabled) globalDagDirUp=\(globalDagDirUp) kickstart=\(startChits)")
			return true
		case "?":
			print ("=== Simulator   commands:",
				"\t' '             -- Toggel simEnabled: run(-1) / stop(0) ",
				"\t'k'             -- kickstart simulator",
//				"\t' ' + shift     -- Set simEnabled = 1: Run 1 cycle, then stop",
				separator:"\n")
		default:
			nop
		}

		 // Check registered TimingChains
		for timingChain in timingChains {
/**/		if timingChain.processEvent(nsEvent:nsEvent, inVew:vew) {
				return true 				/* handled by timingChain */
			}
		}

		return false
	}
}
