//  Simulator.swift -- simulation control elements C190715PAK
import SceneKit

class Simulator : NSObject, Codable {

	 // MARK: - 2. Object Variables:
	var timingChains:[TimingChain] = []

	// MARK: - 2.1 Operational STATE
	 /// Simulation is fully built and running						////	var simBuilt : Bool {				// simulator is running (mostly for Log)
	var simBuilt : Bool = false	{		// sim constructed?			//		get		 {		return simBuilt_										}
		didSet {		// whenever simEnabled gets set, try to st	//		set(val) {		// whenever simEnabled gets set, try to start simulationsart simulation
			if simEnabled && simBuilt {								////			simBuilt_			= val
				simTaskRunning	= false	// (so startSimulationTask 	//			if simEnabled_ && simBuilt_ {notices)
				startSimulationTask()	// try irrespective of simTa//				simTaskRunning	= false	// (so startSimulationTask notices)skRunning
			}														////				startSimulationTask()	// try irrespective of simTaskRunning
		}															////			}
	}																////		}
																	////	};private var simBuilt_	 	= false		// sim constructed?
	 /// Enable simulation task to run:																					//
	var simEnabled : Bool 	 	= false {	// sim enabled to run?{				//var simEnabled	  	: Bool {
		didSet {																//	get 	 {		return simEnabled_ 										}																					//
			if simBuilt {														//	set(val) {		// whenever simEnabled gets set, try to start simulations																					//
				simTaskRunning	= false		// (so startSimulationTask notices)	//		simEnabled_			= val
				startSimulationTask()		// try irrespect~ of simTaskRunning	//		if simBuilt {
			}																	//			simTaskRunning	= false	// (so startSimulationTask notices)
		}																		//			startSimulationTask()	// try irrespective of simTaskRunning
	}																			//		}
																				//};private var simEnabled_ 	= false		// sim enabled to run?
	var simTaskRunning			= false		// sim task pending?

	// MARK: - 2.2 Manage Cycle Simulator
	var kickstart	  	:UInt8	= 0		// set to get simulator going
	var unsettledOwned	:Int	= 0		// by things like links

	func isSettled() -> Bool {
		 // Scan all Ports, count ones which haven't settled
		let nPortsBuisy 		= rootPart!.unsettledPorts().count

		 // Chits taken out by users, not yet returned.
		let nLinksBuisy 		= unsettledOwned

		return nPortsBuisy == 0  &&  nLinksBuisy == 0	//  &&  kickstart <= 0
	}
	var timeNow			: Float	= 0.0
	var simTimeStep		: Float = 0.01
	var globalDagDirUp	: Bool	= true
	weak var rootPart	: RootPart? = nil

	 /// Controls the Simulator's operation
//	var config4sim : FwConfig	= [:]
	func setConfiguration(to config:FwConfig) {
		if let se				= config["simEnabled"] {
			if let simEn		= se as? Bool {
				simEnabled 		= simEn
			}else{
				panic("simEnabled:\(se.pp(.line)) is not Bool")
			}
		}
		if let tStep			= config.float("simTimeStep") {
			simTimeStep 		= tStep
		}
		if let pst				= config.bool("simLogLocks") {
			simLogLocks	 		= pst
		}
	}
																		
	// MARK: - 3. Factory
	override init() {
		super.init()
//		atCon(6, logd("init(\(config4sim.pp(.line)))"))
	}
// START CODABLE //////////////////////////////////////////////////////
	 // MARK: - 3.5 Codable
	enum SimulatorKeys: String, CodingKey {
//		case timingChains
//		case simBuilt_
//		case simEnabled_
//		case simTaskRunning
//		case kickstart
//		case unsettledOwned
		case timeNow
		case simTimeStep
		case globalDagDirUp
//		case config4sim_
	}
	 // Serialize
	func encode(to encoder: Encoder) throws  {
		var container 		= encoder.container(keyedBy:SimulatorKeys.self)
//		try container.encode(timingChains, 	forKey:.timingChains)
//		try container.encode(simBuilt_, 	forKey:.simBuilt_)
//		try container.encode(simEnabled_, 	forKey:.simEnabled_)
//		try container.encode(simTaskRunning,forKey:.simTaskRunning)
//		try container.encode(kickstart, 	forKey:.kickstart)
//		try container.encode(unsettledOwned,forKey:.unsettledOwned)
		try container.encode(timeNow, 		forKey:.timeNow)
		try container.encode(simTimeStep, 	forKey:.simTimeStep)
		try container.encode(globalDagDirUp,forKey:.globalDagDirUp)
////		try container.encode(config4sim_, 	forKey:.config4sim_)
//
//		//try super.encode(to:encoder) 		// Superclass=NSObject has no encode(to:)
//		atSer(3, logd("Encoded"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		let container 				= try decoder.container(keyedBy:SimulatorKeys.self)
//		simBuilt_					= try container.decode(			Bool.self, forKey:.simBuilt_	)
//		simEnabled_					= try container.decode(			Bool.self, forKey:.simEnabled_	)
//		simTaskRunning				= try container.decode(			Bool.self, forKey:.simTaskRunning)
//		kickstart					= try container.decode(		   UInt8.self, forKey:.kickstart	)
//		unsettledOwned				= try container.decode(		     Int.self, forKey:.unsettledOwned)
		timeNow						= try container.decode(		   Float.self, forKey:.timeNow 		)
		simTimeStep					= try container.decode(		   Float.self, forKey:.simTimeStep	)
		globalDagDirUp				= try container.decode(			Bool.self, forKey:.globalDagDirUp)
////		config4sim_					= try container.decode(		FwConfig.self, forKey:.config4sim_	)
//		timingChains 				= try container.decode([TimingChain].self, forKey:.timingChains	)
//		simBuilt_ 					= try container.decode(			Bool.self, forKey:.simBuilt_	)
//		simEnabled_					= try container.decode(			Bool.self, forKey:.simEnabled_	)
//		simTaskRunning				= try container.decode(			Bool.self, forKey:.simTaskRunning)
//		config4sim_					= [:]	//?
//
		super.init() //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//		atSer(3, logd("Decoded  as? Controller"))
	}
// END CODABLE /////////////////////////////////////////////////////////////////
	 // MARK: - 3.6 NSCopying
	func copy(with zone: NSZone?=nil) -> Any {
bug;	let theCopy : Simulator		= Simulator()//super.copy(with:zone) as! Simulator
//		theCopy.simBuilt_			= self.simBuilt_
//		theCopy.simEnabled_			= self.simEnabled_
//		theCopy.simTaskRunning		= self.simTaskRunning
//		theCopy.kickstart			= self.kickstart
//		theCopy.unsettledOwned		= self.unsettledOwned
//		theCopy.timeNow				= self.timeNow
//		theCopy.simTimeStep			= self.simTimeStep
//		theCopy.globalDagDirUp		= self.globalDagDirUp
//		theCopy.config4sim_			= self.config4sim_
//		theCopy.timingChains 		= self.timingChains
//		atSer(3, logd("copy(with as? Simulator       ''"))
		return theCopy
	}
//
//	 // MARK: - 3.7 Equitable
	func varsOfSimulatorEq(_ rhs:Part) -> Bool {
		guard let rhsAsSimulator	= rhs as? Simulator else {	return false		}
bug;	return false
//		return simBuilt_		== rhsAsSimulator.simBuilt_
//			&& simEnabled_		== rhsAsSimulator.simEnabled_
//			&& simTaskRunning	== rhsAsSimulator.simTaskRunning
//			&& kickstart		== rhsAsSimulator.kickstart
//			&& unsettledOwned	== rhsAsSimulator.unsettledOwned
//			&& timeNow			== rhsAsSimulator.timeNow
//			&& simTimeStep		== rhsAsSimulator.simTimeStep
//			&& globalDagDirUp	== rhsAsSimulator.globalDagDirUp
//		//	&& config4sim_		== rhsAsSimulator.config4sim_
//			&& timingChains 	== rhsAsSimulator.timingChains
//			&& simBuilt_		== rhsAsSimulator.simBuilt_
//			&& simEnabled_		== rhsAsSimulator.simEnabled_
//			&& simTaskRunning	== rhsAsSimulator.simTaskRunning
//			&& kickstart		== rhsAsSimulator.kickstart
//			&& unsettledOwned	== rhsAsSimulator.unsettledOwned
//			&& timeNow			== rhsAsSimulator.timeNow
//			&& simTimeStep		== rhsAsSimulator.simTimeStep
	}
	func equalsPart(_ part:Part) -> Bool {
bug;	return	/*super.equalsPart(part) &&*/ varsOfSimulatorEq(part)
		//Value of type 'NSObject' has no member 'equalsPart'
	}
//
	   // MARK: - 8. Reenactment Simulator
	  /// Start Simulation Task
	 /// N.B: start occurs on a thread which has Part tree already locked
	func startSimulationTask() {
		 //return // never simulate
		if simBuilt && simEnabled {		// want to run
			if simTaskRunning == false {	// if not now running
				simTaskRunning	= true
				atBld(3, logd("# # # # STARTING Simulation Task (simEnabled=\(simEnabled))"))
			}
			let taskPeriod		= rootPart?.fwGuts.document.config.double("simTaskPeriod") ?? 0.01
			let modes			= [RunLoop.Mode.eventTracking, RunLoop.Mode.default]
			perform(#selector(simulationTask), with:nil, afterDelay:taskPeriod, inModes:modes)
		}else{
			stopSimulationTask()		// ?? Perhaps wrong
		}
	}
	 /// Simulation Task auto-repeats once called
	@objc func simulationTask() {
		guard simBuilt				else {	return panic("calling for simulationTask() before simBuilt") }
		guard simEnabled			else {	return 								}
		if let rp : RootPart	= DOCfwGutsQ?.rootPart  {

			// semaphore:
			guard rp.lock(partTreeAs:"simulationTask", logIf:simLogLocks) else {
				fatalError("simulationTask couldn't get PART lock")
			}
				// Clear out start cycles before simulate():
			kickstart			-= kickstart > 0 ? 1 : 0	// ATOMICITY PROBLEM HERE:

				// RUN Simulator ONE Cycle: up OR down the entire Network: ///////
	/**/	rp.simulate(up:globalDagDirUp)
			globalDagDirUp		= !globalDagDirUp
			timeNow				+= simTimeStep

			rp.unlock(partTreeAs:"simulationTask", logIf:simLogLocks)
		}
		else {
			print("Simulating with sim\(ppUid(self)) rootPart==nil")
		}																				//}
		startSimulationTask()		// reStartSimulationTask
	}
	var simLogLocks				= false	// OVERWRITTEN by Configuration
	 /// Stop the simulation task
	func stopSimulationTask() {
		if simTaskRunning == true {		// now running
			simTaskRunning		= false
			atBld(3, logd("# # # # STOPPED  Simulation Task \n"))
			 // Remove "perform-requests" from the current run loop, not ALL run loops.
			NSObject.cancelPreviousPerformRequests(withTarget:self)
		}
	}

// MARK: - 13. IBActions
		/// Prosses keyboard key
	   /// - Parameter from: -- NSEvent to process
	  ///  - Parameter vew:         -- The Vew to use
	 ///   - Returns: Key was recognized
	func processKey(from nsEvent:NSEvent, inVew vew:Vew?) -> Bool {
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
			Swift.print ("=== Simulator   commands:",
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
