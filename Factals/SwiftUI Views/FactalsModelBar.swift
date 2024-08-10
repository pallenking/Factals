//
//  FactalsModelBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct FactalsModelBar: View {
	@Binding var factalsModel : FactalsModel
	
	var body: some View {
		VStack {
			RootPartBar (partBase: $factalsModel.partBase)
			SimulatorBar(simulator:$factalsModel.simulator)
		}
		.padding(4)
		.background(Color(red:1.0, green:1.0, blue:0.9))
		.border(Color.black, width:2.5)
		.padding(2)
	}
}

struct RootPartBar : View {
	@Binding var partBase : PartBase

	var body: some View {
		HStack {	// FULL!
			Text("Model (partBase): ").foregroundColor(.red).bold()
			Button(label:{	Text( "ptm")										})
			{	print(partBase.pp(.tree, ["ppDagOrder":true])) 					}
			Button(label:{	Text("ptLm")										})
			{	print(partBase.pp(.tree, ["ppDagOrder":true, "ppLinks":true]))	}
			Spacer()
			Text("app:").foregroundColor(.red).bold()
			Button(label:{	Text( "state")										})//.padding(.top, 300)
			{	printFwState()													}
			Button(label:{	Text( "config")										})
			{	printFwState()													}
			Button(label: {	Text("LLDB") 										})
			{	lldbPrint(partBase, /*VewBase.first!,*/ mode:.tree, [:])
				breakToDebugger()												}
			Text(" ")
		}
	}
}
struct SimulatorBar : View {
    @Binding var simulator : Simulator

	var body: some View {
		HStack {
			//	Text("Settled:\(isSettled() ? "true" : "false")")
			Text("simulator:").foregroundColor(.red).bold()
			Text(" t=")
			if let nogo = !simulator.simBuilt	? "unbuilt" : !simulator.simEnabled ? "disabled" : nil {
				Text(nogo)
				Spacer()
			}
			else {
				Text(String(simulator.timeNow))
				Button(label:{	Text("start")	})
				{	simulator.simEnabled = true
					simulator.startChits = 4								}
				Button(label:{	Text("stop")								})
				{	simulator.simEnabled = true
					simulator.simulateOneStep()
					simulator.simEnabled = false							}
				// Other things to worry about later
					//		!simulator.simTaskRunning
					//	ro	var timeStep		: Float = 0.01
					//		func isSettled() -> Bool				chevron
					//		var timingChains:[TimingChain] = []	chevron
					//	ro	var globalDagDirUp	: Bool	= true
				HStack {
					//let bRpQ		= $factalsModel.partBase//!.simulator		// Binding<Parts?>
					//	@Bindable var viewModel = viewModel
					//LabeledCGFloat(label:"time:", val:$bRpQ., oneLine:true)
					//@Bindable var s			= $factalsModel.partBase				// Binding<Parts?>
///
/// SEE FactalStatus.Simulator.ppFactalsState()
///
					//var timeNow : Float	= 0.0
//					LabeledCGFloat(label:" time:", val:$factalsModel.fooo, oneLine:true)
					Text("\(simulator.globalDagDirUp ? ".up"  : ".down") ")
					Text("chits: p:\(simulator.portChits) l:\(simulator.linkChits) s:\(simulator.startChits) ")
				}
				.padding(2)
				.background(Color(red:1.0, green:0.9, blue:0.9))
				Spacer()
			}
		}
	}
}
