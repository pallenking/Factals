//  TimingChain.mm -- Split analog time into Sample time C2017PAK
import SceneKit

 /// A TimingChain bridges the gap betweent analog time and discrete time
 /// - Sequences loading event, clocking Previous, and WriteHead's Conceive and Labor
class TimingChain : Atom {

	  // MARK: - 2. Object Variables:
	 // our BOSSES: (presuming sensor orientation)
	var worldModel 	: WorldModel? = nil	// of WorldModels

	 // our WORKERS:
	var discreteTimes: [DiscreteTime] = []
								
	 // our Status:
    var event		:FwwEvent? = nil	// event being executed
	var state 		: UInt8	= 0	{	// of timing chain
		didSet {
			if animateChain && state != oldValue {
				markTree(dirty:.size)
			}
		}
	}
	var animateChain			= true		//false//true//

	// Basic Op Mode: Variations in Insertion Cycle:
	 // Halt insertion sequence in middle while user key or button is down
	var eventDownPause 	: Bool	= false
	 // Issue previous clock late in the cycle
	var asyncData 		: Bool	= false // change clocking mode:
	// ____ Asynchronous Gui ____: Data with Snapshot:
	//	User adjusts sliders and buttons, changes propigate through the network real time
	//	User presses button to capture existing data. (optional)
	// ____ Synchronous Data ____: (lists, sync world model)
	// 	downstroke: capture old data at time t, then load new data of t+1.
	//		Calculate Unknowns, and conceive a network modification to learn.
	//	upstroke: release the modification and allow the Network to settle
	//

		//______Sync_Data:______________________Async_Data:_________
		//					00: Idle
		//					01: Await EventDown + SIM-SETTLED
		//		- .clockPrevious				- nop
		//		- load TargetBundle:
		//						- nil->event
		//					02: Await SIM-SETTLED
		//						- sim_writeHeadConcieve
		//						- sim_writeHeadLabor
		//					03: Await SIM-SETTLED + EventUp
		//		 - nop							- .clockPrevious
		//						- retractPort
		//					04: Await SIM-SETTLED
		//					00: Idle

	 // Retract 1:N assertion when button UP
	var retractPort : Port?	= nil

	  // MARK: - 3. Part Factory
	 /// Defines Sample clocks
	 /// - parameter config: 
	/// ## --- asyncData    :Bool   --  computNClock v.s. clockNCompute
	override init(_ config:FwConfig = [:]) {
		super.init(config)//, leafKind:leafKind_)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ //
		asyncData				= partConfig["asyncData"]    as? Bool ?? false
		if let ac				= trueF_ {//factalsModel!.config4factalsModel.bool("animateChain") {		//partConfig["animateChain"] //config.bool("animateChain")
			animateChain		= ac		//Bool(fwAny:ac) ?? false
		}

		 // Register ourselves with simulator:
		root?.factalsModel?.simulator.timingChains.append(self)	/*WTF!*/
		//root?.simulator.timingChains.append(self)	/*WTF!*/
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv 					= super.hasPorts()			/// has 2 ports:
		rv["S"]					= "pcf"
		return rv
	}

	 // MARK: - 3.5 Codable
	enum TimingChainKeys:String, CodingKey {
		case worldModel
		case discreteTimes
		case event
		case state
		case animateChain
		case eventDownPause
		case asyncData
		case retractPort
//		case bundleTap
	}

//	struct ParamDef {
//		var keyPath 		: KeyPath<Any, Any>
//		var codingKey		: CodingKey
//		var classx			: AnyClass
//		init(_ keyPath:KeyPath<Any, Any>, _ codingKey:TimingChainKeys, _ classx:AnyClass) {
//			self.keyPath 		= keyPath
//			self.codingKey		= codingKey
//			self.classx			= classx
//		}
//	}
//	var myParams : [ParamDef] { [
//		ParamDef(\TimingChain.worldModel! 	 as! KeyPath<Any, Any>, .worldModel,	WorldModel),
//		ParamDef(\TimingChain.discreteTimes! as! KeyPath<Any, Any>, .discreteTimes, DiscreteTime),
//		ParamDef(\TimingChain.event! 		 as! KeyPath<Any, Any>, .event, 		FwwEvent),
//		ParamDef(\TimingChain.animateChain!	 as! KeyPath<Any, Any>, .animateChain, 	Bool),
//	] }	//Cannot convert value of type 'KeyPath<TimingChain, WorldModel>'
//		//	 to expected argument type 'KeyPath<Any, Any>'
//
//	func getPropertyValue<Type, Value>(in object:Type, keyPath:KeyPath<Type,Value>) -> Value {
//		return object[keyPath:keyPath]
//	}
//	override func encode(to encoder: Encoder) throws  {
//		try super.encode(to: encoder)
//		var container 			= encoder.container(keyedBy:TimingChainKeys.self)
//		for param in myParams {
//			let xx = self[keyPath:param.keyPath]  //getPropertyValue(in:self, keyPath:param.keyPath)
////			let x  = self[keyPath:param.keyPath] as! param.classx
//			try container.encode(xx, forKey:param.codingKey as! TimingChain.TimingChainKeys)
//		}
//	}

	
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:TimingChainKeys.self)

		try container.encode(worldModel, 	forKey:.worldModel)
		try container.encode(discreteTimes,	forKey:.discreteTimes)
		try container.encode(event, 		forKey:.event)
		try container.encode(state,			forKey:.state)
		try container.encode(animateChain,	forKey:.animateChain)
		try container.encode(eventDownPause,forKey:.eventDownPause)
		try container.encode(asyncData, 	forKey:.asyncData)
		try container.encode(retractPort, 	forKey:.retractPort)
		atSer(3, logd("Encoded  as? TimingChan  '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
        let container 			= try decoder.container(keyedBy:TimingChainKeys.self)

		worldModel	 	= try container.decode(    WorldModel.self, forKey:.worldModel)
		discreteTimes	= try container.decode([DiscreteTime].self, forKey:.discreteTimes)
		event	 		= try container.decode( 		FwwEvent.self, forKey:.event)
		state	 		= try container.decode( 	    UInt8.self, forKey:.state)
		animateChain	= try container.decode( 	     Bool.self, forKey:.animateChain)
		eventDownPause	= try container.decode( 		 Bool.self, forKey:.eventDownPause)
		asyncData	 	= try container.decode( 		 Bool.self, forKey:.asyncData)
		retractPort	 	= try container.decode( 		 Port.self, forKey:.retractPort)
		atSer(3, logd("Decoded  as? TimingChan named  '\(name)'"))
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! TimingChain
//		theCopy.worldModel		= self.worldModel
//		theCopy.discreteTimes	= self.discreteTimes
//		theCopy.event			= self.event
//		theCopy.state			= self.state
//		theCopy.animateChain	= self.animateChain
//		theCopy.eventDownPause	= self.eventDownPause
//		theCopy.asyncData		= self.asyncData
//		theCopy.retractPort		= self.retractPort
//		atSer(3, logd("copy(with as? TimingChain       '\(fullName)'"))
//		return theCopy
//	}
	 // MARK: - 3.7 EquatableFW
	func equalsFW(_ a:Part?, _ b:Part?) -> Bool {
		if a == nil && b == nil {	return true		}	// nil == nil
		if a != nil || b != nil {	return false	}	// nil != !nil
		return a!.equalsFW(b!)							// both !nil
	}
	func equalsFW(_ a:[Part], _ b:[Part]) -> Bool {
		guard a.count == b.count 					  else {	return false	}
		for i in 0...a.count {
			guard a[i].equalsFW(b[i])					  else {	return true		}
		}
		return true
	}
	func equalsFW(_ a:FwwEvent?, _ b:FwwEvent?) -> Bool {
		if a == nil && b == nil {	return true		}	// nils match
		if a != nil || b != nil {	return false	}	// only 1 nil mismatches
		bug; return false								// not debugged past here
//		bug;return a!.equals(b! ??? )					// both exist
	}
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 							  else {	return true		}
		guard let rhs			= rhs as? TimingChain else {	return false	}
		let rv					= super.equalsFW(rhs)
								&& equalsFW(worldModel,    rhs.worldModel)
								&& equalsFW(discreteTimes, rhs.discreteTimes)
								&& equalsFW(event,		   rhs.event)
								&& state 		  		== rhs.state
								&& animateChain   		== rhs.animateChain
								&& eventDownPause 		== rhs.eventDownPause
								&& asyncData 	  		== rhs.asyncData
								&& equalsFW(retractPort,   rhs.retractPort)
		return rv
	}
	 // MARK: - 5 Groom
	override func groomModelPostWires(root:RootPart) {
											super.groomModelPostWires(root:root)
		asyncData				= partConfig["asyncData"] as? Bool ?? false
		if let ac				= root.factalsModel?.document.docConfig.bool("animateChain") {		//partConfig["animateChain"] //config.bool("animateChain")
			animateChain		= ac		//Bool(fwAny:ac) ?? false
		}

		 // Register ourselves with simulator:
		root.factalsModel?.simulator.timingChains.append(self)
//		root.simulator.timingChains.append(self)

		  // Add P's target to discreteTimes array
		 // User specifies as P and S Ports, but needed in worldModel
		if let pPort			= ports["P"],				// TC's Target
		  let myPPort			= pPort.portPastLinks,			// traverse Link
		  let dt2add			= myPPort.atom as? DiscreteTime {	// add to DTs
			discreteTimes.append(dt2add)
		}
		else {
			atDat(4, warning("TimingChain's 'P' Port must be connected to a DiscreteTime\n" +
									"\t" + "Sometimes this is from an auto-inserted"))
		}

		if let sPort			= ports["S"],
		  let mySPort			= sPort.portPastLinks,
		  let mySAtom 			= mySPort.atom as? WorldModel		{	
			worldModel			= mySAtom
		}
		else {
			atDat(4, warning("TimingChain's 'S' Port must be connected to a WorldModel"))
		}
	}

	 // MARK: - 8. Reenactment Simulator
	//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*
	//**//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//
	//***//*//*//*//*//*//      Reenactment Simulator     //*//*//*//*//*//*//*
	//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*
	//**//*//*//*//*//*/s*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//
	override func reset() {								super.reset()
		state 					= 0000
		eventDownPause			= false

		atEve(4, logd("############ eventDownPause = false -- reset")) //print("
		//[bundleTap reset]
	}
	 /// When "again" is encountered, some state must be reset for proper operation
	func resetForAgain() {
		for discreteTime in discreteTimes {
			discreteTime.resetForAgain()
		}
	}

	override func simulate(up upLocal:Bool) {	 /// Step all my parts:
		guard let simulator		= root?.factalsModel?.simulator else {return} // no sim
//		guard let simulator		= root?.simulator else { return /* no sim */	}
		guard simulator.simEnabled				  else { return /* not emabled */}
		 // Check for FwwEvent
		if (state == 0) {	// when State Machine becomes idle
			if let nextEvent = worldModel?.dequeEvent() { 	/// DUPLICATED in IBActions
				 // DEQUEUED a pending World Experiment FwwEvent:
				assert(state == 0, "    TimingChain Gone Busy")
				atEve(4, logd("    TimingChain: worldModel?.dequeEvent '\(nextEvent.pp())'"))
				assert(self.event==nil, "Should be space by now")

				 // Receive FwwEvent inside ourselves:
				event				= nextEvent		// Symbolic, Destined for targetBundle

				retractPort			= nil			// default param
				eventDownPause		= true			// assert lock, which blocks till up
				atEve(4, logd("############ eventDownPause = true  -- simulate(up:) && state==0"))
				state 				= 0001			// Start Timing Chain
				//!	playSound("")
			//?	releaseEvent()
	bug;		simulator.startChits = 200			// start simulator after key goes up
//				simulator.linkChits += 1			// not settled
//				assert(simulator.linkChits != 0, "linkChits count wraparound")
			}
		}
		super.simulate(up:upLocal)

		guard upLocal 							else {	return					}
			// Only advance when simulator is settled:
		guard simulator.isSettled()				else {	return 					}

		 // ///// STATE MACHINE: ///////
		var nextState 	: UInt8 = 0				// default next state is 0
		switch state {
		case 0:					// ----> Idle. (Needs -takeEvent: to activate)
			return								// idle, do nothing

		case 1:					// ----> When Settled do 'ad1:?cPrev,lData'
		//	if simulator.settled == false {		// Sim unsettled or not enabled
		//		return							// do nothing
		//	}											// ## 1. Await Sim Settled
			if asyncData {
				atEve(4, logd("//// %02o=>State; Sim Settled; Asynchronous Data Mode: nop", state))
			}
			else {
				atEve(4, logd("//// %02o=>State; Sim Settled; Synchronous Data Mode: cPrev;lData", state))
														// ## 2. do EARLY Clk Previous:
				root!.sendMessage(fwType:.clockPrevious)

				for discreteTime in discreteTimes {
					discreteTime.loadTargetBundle(event:event!)//## 3. load target bundle
				}
				simulator.startChits = 4 		// start simulator before State 2
			}
			atEve(7, logd("|| LOAD FwwEvent '\(event?.pp() ?? "nil")' complete"))
			event				= nil		// done with event, even if async

			nextState			= 2
		case 2:					// ----> When Settled do 'ad2:Conceive'
			atEve(4, logd("|||| %02o=>State; Sim Settled; Now do 'ad2:Conceive'", state))
														// ## 4. Await Sim Settled
			root!.sendMessage(fwType:.writeHeadConcieve)	// ## 5. do: CONCEIVE:
			root!.sendMessage(fwType:.writeHeadLabor)		// ## 6. do: LABOR, BIRTH:

			  // Disable simulator to freeze activations levels and newborn in canal.
			 //   Conceive leaves SIM unsettled//newb->birth canal (Unfortunately)
	//		simulator.simEnabled	-= simulator.simEnabled > 0 ? 1 : 0
			// 171021 If release occurs before here, ++ and -- still cancel to +=0

			nextState			= 3
		case 3:					// ----> When Settled AND UsrUp do '?cPrev ?retract'
			if eventDownPause {					// First, wait till user pause is up
				return
			}
		//	if !simulator.settled { 					// Second, Await simSettled
		//		return
		//	}
			atEve(4, logd("|||| %02o=>State: userUpEvent and Sim Settled.  Now do 'ad3:?cPrev'", state))
														// ## 8. Let Newbie run
			assert(!eventDownPause, "should be OFF")	// elim after a while

			 //	 !asyncData used in Morse Code (F1, F2, F3)
			if asyncData {		 						// ## 9. LATE Previous Clk
				root!.sendMessage(fwType:.clockPrevious)
			}
			retractPort?.take(value:0.0)
			retractPort			= nil

			nextState			= 4
		case 4:					// ----> When Settled, we're done!
		//	if !sim.settled { 				// Await simSettled
		//		return
		//	}
			atEve(4, logd("\\\\\\\\ %02o=>State; Sim Settled;  EVENT DONE", state))

			 // Stop wanting simulator
//			assert(simulator.linkChits != 0, "wraparound")
//			simulator.linkChits -= 1
			nextState			= 0					// ** 11. go idle
		default:				// ----> PROBLEMS!
			panic(fmt("state=%04o UNDEFINED", state))
		}
		state = nextState					// Enter next state
	}

	 // MARK: - 9.3 reSkin
	var height : CGFloat	{		return 1									}
	override func reSkin(fullOnto vew:Vew) -> BBox  {
	  // / Put full skin onto TimingChain
		let scn					= vew.scn.find(name:"s-Tc") ?? {
			 // First Box
			let h				= height
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Tc"
			scn.position.y		= h/2			

			 // Two Rings of a Chain:
			for i in 0...1 {
				let chain 		= SCNNode()
				scn.addChild(node:chain, atIndex:0)
				chain.name		= "chain\(i)"
				chain.geometry	= SCNTorus(ringRadius:2, pipeRadius:0.5)
				let arm			= SCNVector3([1,-1][i], 0, 0)
				chain.position	= arm
				chain.rotation	= SCNVector4(arm[0],0,0, CGFloat.pi/16)
				let c			= NSColor.red
				chain.color0	= i == 0 ? c : c.change(saturationBy:0.6)
			}
			return scn
		} ()
		let s					= animateChain ? min(Int(state), 4) : 0
		scn.scale.y				= [1.0, 1.5, 1.75, 1.51, 1.25][s]				//[1.0, 1.25, 1.5, 1.75, 2]//[1.0, 2, 1.75, 1.5, 1.25]
		atEve(4, logd("@@@@@ @ @ @ @ @@@@@ TimingChain scale.y: \(scn.scale.y)"))
		return scn.bBox() * scn.transform	//vew.scn.bBox()// Xyzzy44 ** sbt
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["S"] {
			assert(port.flipped == true, "S Port in Generator must be unflipped")
			vew.scn.transform	= SCNMatrix4(0, height + port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}

	 // MARK: - 13. IBActions
	override func processEvent(nsEvent:NSEvent, inVew vew:Vew) -> Bool {
		if nsEvent.type == .keyDown {		// nsEvent.modifierFlags.rawValue & FWKeyUpModifier == 0	{
				  // ///////// key DOWN ///////
			if worldModel?.processEvent(nsEvent:nsEvent, inVew:vew) ?? false {
				root?.factalsModel?.simulator.startChits = 4// set simulator to run, to pick event up
				//root!.simulator.startChits = 4					// set simulator to run, to pick event up
				return true				// other process processes it
			}
		}		  // ///////// key UP  ///////
		else if eventDownPause {
			releaseEvent()				// retract event
		}
		return false
	}
	  // MARK: - 8.1 FwwEvent Chain
	 // Get an event from users (e.g. PushButtonBidirNsV, keyboard, ...)
	func releaseEvent() {
		atEve(4, logd("    TimingChain: Release FwwEvent"))
		eventDownPause			= false			// assert lock, which blocks till up
		atEve(4, logd("############ eventDownPause = false -- releaseEvent"))
		root?.factalsModel?.simulator.startChits = 4// set simulator to run, to pick event up
		//root!.simulator.startChits = 4					// set simulator to run, to pick event up
		retractPort?.take(value:0.0)
		return
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode = .tree, _ aux:FwConfig = params4aux) -> String	{
		var rv 					= super.pp(mode, aux)
		switch mode {
		case .line:	
			if aux.bool_("ppParam") {	// a long line, display nothing else.
				return rv
			}
			for discreteTime in discreteTimes {
				rv				+= "dt:'\(discreteTime.pp(.fullName))' "
			}
			rv					+= "wm:'\(worldModel?.pp(.fullName) ?? "")' "

			if (event != nil) {
				rv				+= "event:\(event!.pp()) "
			}
			rv					+= fmt("state:%03o ", state)
			rv					+= eventDownPause ? "eventDownPause " : ""
			rv					+= animateChain  ? "animateChain "  : ""
			rv					+= asyncData 	 ? "asyncData " 	: ""
			if retractPort != nil {
				rv				+= "retractPort:\(retractPort!.pp(.fullName)) "
			}
		default:
			break
		}
		return rv
	}
}
