//
//  GutsBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct FactalsModelBar: View {
	@Binding var factalsModel : FactalsModel
	
	var body: some View {
		VStack {
			if let simulator = factalsModel.rootPart?.simulator {
				HStack {
					//	Text("Settled:\(isSettled() ? "true" : "false")")
					Text("Simulator:").foregroundColor(.red).bold()
//					if let nogo = !simulator.simBuilt	? "unbuilt" : !simulator.simEnabled ? "disabled" : nil {
//						Text(nogo)
					if false {
					}
					else {
						Spacer()
						Button(label:{	Text("start")	})
						{	simulator.simEnabled = true
							simulator.kickstart	 = 4							}
						Button(label:{	Text("step")							})
						{	simulator.simEnabled = true
							simulator.simulateOneStep()
							simulator.simEnabled = false						}
						// Other things to worry about later
	//					!simulator.simTaskRunning
	//					var unsettledOwned	: Int	= 0			// by things like links
	//					var kickstart	  	: UInt8	= 0			// set to get simulator going
	//		ro			var timeStep		: Float = 0.01
	//					func isSettled() -> Bool				chevron
	//					var timingChains:[TimingChain] = []	chevron
	//					var timeNow			: Float	= 0.0
	//		ro			var globalDagDirUp	: Bool	= true
						HStack {
							//let bRpQ		= $factalsModel.rootPart//!.simulator		// Binding<RootPart?>
							//	@Bindable var viewModel = viewModel
							//LabeledCGFloat(label:"time:", val:$bRpQ., oneLine:true)
							//@Bindable var s			= $factalsModel.rootPart				// Binding<RootPart?>
							LabeledCGFloat(label:" time:", val:$factalsModel.fooo, oneLine:true)
							Text("\(simulator.globalDagDirUp ? ".up"  : ".down") ")
							Text("unsettled:\(simulator.unsettledOwned) kick:\(simulator.kickstart) ")
						}
						//.padding(6)
						.background(Color(red:1.0, green:0.9, blue:0.9))
						//Spacer()
					}
				}
			}

									//  --- FACTALS MODEL BAR  ---
			HStack {	// FULL!
				Text("FactalsModel").foregroundColor(.red).bold()
				Text("   PP App:")
				Button(label:{	Text( "state")										})//.padding(.top, 300)
				{	printFwState()													}
				
				if let rootPart = factalsModel.rootPart {
					Text("  Print Model:")
					Button(label:{	Text( "ptm")									})
					{	print(rootPart.pp(.tree, ["ppDagOrder":true]), 				   terminator:"") }
					Button(label:{	Text("ptLm")									})
					{	print(rootPart.pp(.tree, ["ppDagOrder":true, "ppLinks":true]), terminator:"") }
				} else {
					Text("<<no nodel>>:")
				}
				Spacer()
				Button(label: {	Text("LLDB") 										})
				{	lldbPrint(factalsModel.rootPart!, /*Vews.first!,*/ mode:.tree, [:])
					breakToDebugger()												}
				Text(" ")
			}
		}
		.padding(4)
		.background(Color(red:1.0, green:1.0, blue:0.9))
		.border(Color.black, width:2.5)
		.padding(2)
		//		 .padding(6)
		//		 .background(Color(red:0.9, green:0.9, blue:1.0))
		//		 .border(Color.black, width:0.5)
		//		 .padding(8)
	}
}
