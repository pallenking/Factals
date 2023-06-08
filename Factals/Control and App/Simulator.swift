//  Simulator.swift -- simulation control elements C190715PAK
import SceneKit

					// Remove NSObject
//class Simulator : Logd, Codable {		// NEVER NSCopying, Equatable
//	var uid: UInt16				= randomUid()
class Simulator : NSObject, Codable {		// NEVER NSCopying, Equatable

	 // MARK: - 2. Object Variables:
	weak var rootPart	: RootPart! = nil	// Owner
	var timingChains:[TimingChain] = []
	var timeNow			: Float	= 0.0
	var simTimeStep		: Float = 0.01
	var globalDagDirUp	: Bool	= true
	var logSimLocks				= false		// Overwritten by Configuration

	// MARK: - 2.1 Simulator State
	var simTaskRunning			= false		// sim task pending?
	var kickstart	  	:UInt8	= 0			// set to get simulator going
	var unsettledOwned	:Int	= 0			// by things like links

	 /// Enable simulation task to run:																					//
	var simEnabled : Bool 	 	= false {	// sim enabled to run?{
		didSet {
			if simBuilt {
				simTaskRunning	= false		// (so startSimulationTask notices)
				startSimulationTask()		// try irrespect~ of simTaskRunning
			}
		}
	}
	 /// Simulation is fully built and running
	var simBuilt : Bool = false	{			// sim constructed?
		didSet {		// whenever simEnabled gets set, try to st
			if simEnabled && simBuilt {
				simTaskRunning	= false		// (so startSimulationTask
				startSimulationTask()		// try irrespective of simTa
			}
		}
	}
	func isSettled() -> Bool {
		 // Scan all Ports, count ones which haven't settled
		let nPortsBuisy 		= rootPart!.unsettledPorts().count

		 // Chits taken out by users, not yet returned.
		let nLinksBuisy 		= unsettledOwned

		return nPortsBuisy == 0  &&  nLinksBuisy == 0	//  &&  kickstart <= 0
	}
	   // MARK: - 2.2 Simulator Task
	  /// Start Simulation Task
	 /// N.B: start occurs on a thread which has Part tree already locked
	func startSimulationTask() {
		//return // never simulate
		if simBuilt && simEnabled {				// want to run
			if simTaskRunning == false {		// if not now running
				simTaskRunning	= true
				atBld(3, logd("# # # # STARTING Simulation Task (simEnabled=\(simEnabled))"))
			}
			let taskPeriod		= rootPart?.fwGuts.document.config.double("simTaskPeriod") ?? 0.01
			let modes			= [RunLoop.Mode.eventTracking, RunLoop.Mode.default]
			perform(#selector(simulationTask), with:nil, afterDelay:taskPeriod, inModes:modes)
		}else{
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
		guard simBuilt				else {	return panic("calling for simulationTask() before simBuilt") }
		guard simEnabled			else {	return 								}
		if let rp : RootPart	= rootPart  {

			// semaphore:
			guard rp.lock(partTreeAs:"simulationTask", logIf:logSimLocks) else {
				fatalError("simulationTask couldn't get PART lock")
			}
				// Clear out start cycles before simulate():
			kickstart			-= kickstart > 0 ? 1 : 0	// ATOMICITY PROBLEM HERE:

				// RUN Simulator ONE Cycle: up OR down the entire Network: ///////
	/**/	rp.simulate(up:globalDagDirUp)
			globalDagDirUp		= !globalDagDirUp
			timeNow				+= simTimeStep

			rp.unlock(partTreeAs:"simulationTask", logIf:logSimLocks)
		}
		else {
			print("Simulating with sim\(ppUid(self)) rootPart==nil")
		}																				//}
		startSimulationTask()		// reStartSimulationTask
	}
	 // MARK: - 2.3 Push Configuration to Controllers
	 /// Controls the Simulator's operation
	func configureDocument(from c:FwConfig) {
		if let se				= c["simEnabled"] {
			if let simEn		= se as? Bool {
				simEnabled 		= simEn
			}else{
				panic("simEnabled:\(se.pp(.line)) is not Bool")
			}
		}
		if let tStep			= c.float("simTimeStep") {
			simTimeStep 		= tStep
		}
		if let pst				= c.bool("logSimLocks") {
			logSimLocks	 		= pst
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
		case simTimeStep
		case globalDagDirUp
	}
	 // Serialize
	func encode(to encoder: Encoder) throws  {
		var container 		= encoder.container(keyedBy:SimulatorKeys.self)
		try container.encode(timingChains, 	forKey:.timingChains)
		try container.encode(simBuilt, 		forKey:.simBuilt)
		try container.encode(simEnabled, 	forKey:.simEnabled)
		try container.encode(simTaskRunning,forKey:.simTaskRunning)
		try container.encode(kickstart, 	forKey:.kickstart)
		try container.encode(unsettledOwned,forKey:.unsettledOwned)
		try container.encode(timeNow, 		forKey:.timeNow)
		try container.encode(simTimeStep, 	forKey:.simTimeStep)
		try container.encode(globalDagDirUp,forKey:.globalDagDirUp)
		//try super.encode(to:encoder) 				// Superclass=NSObject has no encode(to:)
//		atSer(3, logd("Encoded"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 				= try decoder.container(keyedBy:SimulatorKeys.self)
		timingChains 				= try container.decode([TimingChain].self, forKey:.timingChains	)
		simBuilt					= try container.decode(			Bool.self, forKey:.simBuilt		)
		simEnabled					= try container.decode(			Bool.self, forKey:.simEnabled	)
		simTaskRunning				= try container.decode(			Bool.self, forKey:.simTaskRunning)
		kickstart					= try container.decode(		   UInt8.self, forKey:.kickstart	)
		unsettledOwned				= try container.decode(		     Int.self, forKey:.unsettledOwned)
		timeNow						= try container.decode(		   Float.self, forKey:.timeNow 		)
		simTimeStep					= try container.decode(		   Float.self, forKey:.simTimeStep	)
		globalDagDirUp				= try container.decode(			Bool.self, forKey:.globalDagDirUp)

		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		atSer(3, logd("Decoded  as? Controller"))
	}
// END CODABLE /////////////////////////////////////////////////////////////////
	// MARK: - 14. Building
	var log : Log { rootPart.fwGuts?.log ?? .help					}
	func log(banner:String?=nil, _ format_:String, _ args:CVarArg..., terminator:String?=nil) {
		log.log(banner:banner, format_, args, terminator:terminator)
	}			//Cannot convert return expression of type 'Optional<_>' to return type 'Log'

	// MARK: - 13. IBActions
		/// Prosses keyboard key
	   /// - Parameter from: -- NSEvent to process
	  ///  - Parameter vew:         -- The Vew to use
	 ///   - Returns: Key was recognized
	func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
		guard let character		= nsEvent.charactersIgnoringModifiers?.first else {
			return false
		}
		if nsEvent.type == .keyUp {			// ///// Key UP ///////////
			return false						// Simulator has no key-ups
		}
	//	let shift 				= nsEvent.modifierFlags.contains(.shift)
		switch character {
		case " ":							// perhaps "+ shift"
			 // One more cycle, stop if running:
			simEnabled 			= !simEnabled
			if simEnabled {
				kickstart		= 4
			}	// (Not using ppLog -- log numbers to be independent of
			print("++++++++++ simEnabled=\(simEnabled) globalDagDirUp=\(globalDagDirUp) kickstart=\(kickstart)")
			return true
		case "k":							// kickstart simulator
			simEnabled 			= true
			kickstart			= 4
			print("++++++++++ simEnabled=\(simEnabled) globalDagDirUp=\(globalDagDirUp) kickstart=\(kickstart)")
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
		return false
	}
}
