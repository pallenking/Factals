////  EditNet.swift -- Network Editing facilities C2020PAK

//		  Atom.autoBroadcast(toPort:Port) -> Port
//	o Splitter.autoBroadcast(toPort:Port) -> Port
//
//	  Splitter.anotherShare(named portName:String? = nil) -> Share
//
//		  Atom.biggestBit(openingUp upInSelf:Bool?) -> Port?
//	o Splitter.biggestBit(openingUp upInSelf:Bool?) -> Port?
//
//		 Atom.port(named name:String? = nil, localUp:Bool?=nil, wantOpen:Bool = false, allowDuplicates:Bool=false) -> Port?
//	o    Leaf.port(named name:String? = nil, localUp:Bool?=nil, wantOpen:Bool = false, allowDuplicates:Bool=false) -> Port?


//
//import Foundation
//extension Splitter {
//   // MARK: - 4.4 Tree Navigation
//	/// Create new shares if appropriate
//   override func autoBroadcast(toPort:Port) -> Port {
//	   if //isBroadcast, 
//		 toPort.flipped { 							 /// active end of a splitter?
//		   return anotherShare(named:"*")// + + make a new Share + +
//	   }
//	   return super.autoBroadcast(toPort:toPort) 
//   }
//	/// Create a Share of kind 'shareName'
//   func anotherShare(named portName:String?=nil) -> Share {
//	   let nam					= fmt("s%ld", ports.count)
//	   let aClass 	: AnyClass	= classFrom(string:shareName!)
//	   let shareType			= aClass as! Share.Type
//
//	   let share				= shareType.init(["named":nam])	/// INIT
//
//	   share.flipped			= true			// shares are always flipped
//		/// Optionally insert new share in ports:
//	   if portName != nil {
//		   let name : String	= portName! != "*" ? portName! : share.name
//		   assert(ports[name]==nil, "\(pp(.fullName)) already has a Share named '\(name)'")
//
//		   ports[name]	 		= share			/// add to ports
//		   addChild(share)						/// add to children
//		   upIsDirty 			= true			// new Shares need downward,
//	   }										 // then upward pass
//	   return share
//   }
//   override func biggestBit(openingUp upInSelf:Bool?) -> Port? {
//	   if flipped {										// trunk?
//		   return super.biggestBit(openingUp:flipped)	// follow P
//	   }
//		// Up in self canonic form
//	   if let rv 				= children[combineWinner] as? Port {
//		   return rv
//	   }
////		let cw					= combineWinner,
////		if cw >= 0 && cw < children.count {
////			return children[cw] as? Port
////		}
//	   var rv : Port?			= nil
//	   for port_ in children {
//		   if let port 		= port_ as? Port {
//			   if port.flipped == upInSelf {
//				   if port.name == "U" {										}
//				   else if rv==nil	{			// first
//					   rv 		= port										}
//				   else {
//					   atBld(4, log("????? [%@ getBit_...]: ignoring %@, alrady found %",
//						   name, port.name, rv?.name ?? "-"))
//				   }
//			   }
//		   }
//	   }
//	   return rv
//   }
//}
//extension Atom {
//	 // MARK: - 4.4 Tree Navigation
//	  /// Search for Port in Atom
//	 // nil name or "" ==> default Port
// //func port(named portName:String?=nil, localUp portUp:Bool?=nil, wantOpen:Bool=false, allowDuplicates:Bool=false, extra:String="Atom") -> Port? 
//	func port(named name:String?=nil, localUp:Bool?=nil, wantOpen:Bool=false, allowDuplicates:Bool=false, extra:String="Atom") -> Port? {
//		var rv : Port?			= nil
//		for (_, port) in ports {					/// Search ports
//			if localUp==nil || port.flipped==localUp!,	/// flipped properly
//			      name==nil || name == "" || 			/// name is nil, null,
//			  				   name==port.name,				/// or matches port
//			  !wantOpen || port.connectedTo==nil 		/// need not be open, or is open
//			{
//				assert(allowDuplicates || rv==nil, "Two candidates found for port named '\(name ?? "")'")
//				rv				= port			/// found unique acceptable Port
//			}
//		}
//		 /// Not found above, try an edit
//		if wantOpen,							/// want an open port
//		   rv==nil							/// didn't find open port above
//		{/// Get the Port that almost meets desires, but is occupied
//			if let occupiedPort	= port(named:name, localUp:localUp, wantOpen:false, allowDuplicates:true) { 
//				assert(occupiedPort.connectedTo!=nil, "should be occupied")
//				rv				= autoBroadcast(toPort:occupiedPort)
//			}
//			else if localUp!,
//			  let splitter		= self as? Splitter {
//				return splitter.anotherShare(named:"*")
//			}
//		}
//		return rv
//	}
//	 	 //////////// Edit a Network to add a Share
//	    /// At the Port that needs tapping
//	   ///   Trace through the Links
//	  ///	   Try, perhaps it's a Bcast
//	 ///        Otherwise, insert a new Broadcast Element into the network
//	func autoBroadcast(toPort:Port) -> Port {
//		 /// If toPort's Atom is a Broadcast, just add another share
//		if toPort.flipped,
//		  let splitter 			= self as? Splitter,
//		  splitter.isBroadcast {
//			return splitter.anotherShare(named:"*")
//		}
//		 /// If toPort has a Broadcast already attached to it, use it
//		if let conSplitter	 	= toPort.connectedTo?.atom as? Splitter,
//		  conSplitter.isBroadcast {
//			return conSplitter.anotherShare(named:"*")
//		}
//		   /// NOPE,
//		  ///   "AUTO-BCAST": Add a new Broadcast to split the port
//		 ///					/auto Broadcast/auto-broadcast/
//		atBld(1, log("<<++ Auto Broadcast ++>>"))
//
//		 /// 1.  Make a Broadcast Splitter Atom:
//		let newName				= "\(name)\(toPort.name)"
//		let newBcast 			= Broadcast(["name":newName])
//		newBcast.flipped		= true		// add flipped  //false add unflipped
//
//		 /// 2.  Find a spot to insert it (above or below):
//		let papaNet				= toPort.atom!.enclosingNet! /// Find Net
//									/// worry about toPort inside Tunnel
//		let child	 			= toPort.ancestorThats(childOf:papaNet)!
//		guard var ind 			= papaNet.children.firstIndex(of:child) else {
//			fatalError("Broadcast index bad of false'\(toPort.fullName)'")
//		}
//		if toPort.upInPart(papaNet) {
//			ind					+= 0		// add new bcast after child
//			newBcast.flipped	= false		// not flipped
//		}
//		else {
//			ind					+= 1		// add new bcast after child
//			newBcast.flipped	= true
//		}
//		 /// 3.  Insert it
//		papaNet.addChild(newBcast, atIndex:ind)
//
//		 /// 4,  Wire up Broadcast into Network:
//		let share1 : Share		= newBcast.anotherShare(named:"*") // newShare to replicate old connection
//		let share2 : Share		= newBcast.anotherShare(named:"*")
//		let pPort  : Port		= newBcast.ports["P"]!
//		share1.connectedTo		= toPort.connectedTo/// 1. move old connection to share1
//		toPort.connectedTo?.connectedTo = share1
//		pPort.connectedTo		= toPort	  		/// 2. link newBcast to toPort.
//		toPort.connectedTo		= pPort
//		return share2								/// 3. share2 is autoBroadcast
//	}
//	func biggestBit(openingUp  upInSelf:Bool) -> Port? {
//		var rv : Port? 			= nil
//		for child in children {
//			if let port 		= child as? Port,
//			  port.flipped == upInSelf {					// correct facing?
//				if rv==nil {
//					rv 			= port
//				}
//				else {
//					atBld(4, log("[getBit)????? : ignoring %@, alrady found %", port.name, rv!.name))
//				}
//			}
//		}
//		return rv
//	}
//
//}
