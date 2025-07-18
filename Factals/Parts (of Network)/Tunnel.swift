//  Tunnel.swift -- Tunneling combines multiple signals into one C2019PAK

import SceneKit

 ///  Tunnel: combines multiple Ports into one MultiPort
class Tunnel : FwBundle {
	 // MARK: - 2. Object Variables:
	//var label : String?			= nil
	 // MARK: - 3. Part Factory
	override  init(_ tunnelConfig:FwConfig=[:], leafConfig:FwConfig=[:]) { 	////.port
		super.init(  tunnelConfig,	   			leafConfig:leafConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ //of:kind,
	}		// 	  [struc:["a","b"],of:genBcast]	[]
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{  
		return ["P":"pcM"]
	}

	 // MARK: - 3.5 Codable
	enum TunnelsKeys: String, CodingKey {
		case minSize
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)											//		try super.encode(to:container.superEncoder())
		var container 			= encoder.container(keyedBy:TunnelsKeys.self)

		try container.encode(minSize, forKey:.minSize)
		logSer(3, "Encoded  as? Tunnel         '\(fullName)'")
	}
	  // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:TunnelsKeys.self)

		minSize 				= try container.decode(SCNVector3?.self, forKey:.minSize)
		logSer(3, "Decoded  as? Tunnel        named  '\(name)' minSize = \(minSize?.pp(.line) ?? "nil")")
	}
	required init?(coder: NSCoder) {debugger("init(coder:) has not been implemented")}
//	 // MARK: - 3.6 NSCopying
//	override func copy(with zone: NSZone?=nil) -> Any {
//		let theCopy				= super.copy(with:zone) as! Tunnel
//		theCopy.minSize			= self.minSize
//		logSer(3, "copy(with as? Tunnel       '\(fullName)'")
//		return theCopy
//	}
	 // MARK: - 3.7 Equatable
	override func equalsFW(_ rhs:Part) -> Bool {
		guard self !== rhs 					  else {	return true				}
		guard let rhs			= rhs as? Net else {	return false 			}
		let rv					= super.equalsFW(rhs)
								&& minSize == rhs.minSize
		return rv
	}
	 // MARK: - 8. Reenactment Simulator
	/*							====== Experiment 2 =====		====== Experiment 1 =====
										Push +CHOSEN+				Pull -NOT USED-	
		|_ L|								++++L++++								
		  o ZZ						Get	|	+  (L)>-.			ZZ	Get *  (L)>-.	
	/	  H		   /			   \|	|	+  /|	|			   \|	|	|	|	
	|  WW_o_   XX_o_			+++(L)>-'++++	Get	|			WW (L)>-'	|	|	
	|	|L  |___|L  |			WW	L				|			WW	Get	L	|	|	
	|  (	Tunnel	 )				take(val		|			   \|	|	|	|	
	|	|____M Port_|				|\			   \|/				| up|	| dn|	
	|	 P2	  o					P2	 \			   /			P2	| ^	|	| |	|	
	|		  H						take(v,k	take(v,k			| |	|	| |	|	
	|  P1____o_____				P1	   \		 /				P1	| |	|	| v	|	
	|	|	 M Port	|_				   /|\		|/				O	|	|	|	|
	|  (	Tunnel	  ) 				|		take(val			|	|  /|	|	
	|	|_ L|   |_ L|					|		L				BB	|	|	Get	L	
	|	  o BB    o CC			BB	Get	|	+++(L)>-.++			BB	|	|	(L)>-.	
	\	  H						   \|	|	+  /|	|				|	|	|	|	
	   AA_o_ 					AA (L)>-'	+	Get	|			AA (L)>-'		|
		|L  |				 ++AA++L++++++++	   /				Get	*	getValue
										take(val					'->-'			
	L:Latch, G:Generate action
	*/
	override func simulate(up upLocal:Bool) {
		super.simulate(up:upLocal)	// TOP

		if !upLocal, 					 // If going up
		  								  // our "P" Port is connected to a MultiPort
		  let pAsMPort			= ports["P"]?.con2?.port as? MultiPort
		{ 
			// For ALL Leaf values through Tunnel:
			forAllLeafs(
			{leaf in	
				 // if Leaf's G has Port:
				if let gPort 	= leaf.getPort(named:"G") {
					assert(gPort !== pAsMPort, "output port matches input port")
					if let gPortCon2 = gPort.con2?.port,
						   gPortCon2.valueChanged()
					{	 // move changed leaf value
						let val = gPortCon2.getValue()
						pAsMPort.take(value:val, key:leaf.name)	// move it through MPort
					}
				}
			})
		}
	}
	func take(value val:Float, key:String?) {
		ports[key!]?.take(value:val)
	}
	func valueChanged(key:String?=nil) -> Bool {
		return ports[key!]?.valueChanged() ?? false
	}
	func getValue(key:String?=nil) -> Float {
		return ports[key!]?.getValue() ?? -99
	}
	func getValues(key:String?=nil) -> (Float, Float) {
		return (ports[key!]?.getValues())!
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.findScn(named:"s-Tun") ?? {
			let rv				= SCNNode()
			vew.scn.addChild(node:rv, atIndex:0)
			rv.geometry 		= SCNBox(width:1, height:1, length:1, chamferRadius:0)
			rv.name				= "s-Tun"
			rv.color0			= NSColor("darkgreen")!//.change(alphaTo:0.3)
			return rv
		}()
		let gsnb				= vew.config("gapTerminalBlock")?.asCGFloat ?? 0.0
		let bb					= vew.bBox
		scn.scale				= bb.size
		scn.scale.y				= gsnb
		scn.position			= bb.centerBottom + .uY * gsnb/2
		scn.position.y			+= ports["P"]==nil ?     -gsnb/2 :
								   ports["P"]!.height + 3*gsnb/2
		//scn.isHidden			= true
		return bb						//view.scnScene.bBox() //scnScene.bBox() // Xyzzy44 ** bb
	}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port === ports["P"] {		/// Position "P" Port
			let gsnb			= vew.config("gapTerminalBlock")?.asCGFloat ?? 0.0
			assert(!vew.part.flipped, "P Port in Tunnel must be unflipped")
			 // Place at parent's center bottom
			let parentVew		= vew.parent!
			var ctr				= parentVew.bBox.centerBottom	// Parent's bottom
			ctr.y				-= 1*gsnb + port.height			// up, just inside
			vew.scn.transform	= SCNMatrix4(ctr, flip:false)
		}
		else {
			super.rePosition(portVew:vew)
		}
	}
	 // MARK: - 11. 3D Display
	override func typColor(ratio:Float) ->  NSColor {
		let inside				=  NSColor(0.7, 0.7, 0.7,  1)
		let outside				=  NSColor(0.7, 0.7, 0.7,  1)
		return NSColor(mix:inside, with:ratio, of:outside)
	}
}
