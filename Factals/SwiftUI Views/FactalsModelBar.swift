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
			RootPartActorBar(rootPartActor:factalsModel.rootPartActor, factalsModel: $factalsModel)
			SimulatorBar(simulator:$factalsModel.simulator)
		}
		.padding(4)
		.background(Color(red:1.0, green:1.0, blue:0.9))
		.border(Color.black, width:2.5)
		.padding(2)
	}
}

struct RootPartActorBar : View {
    @StateObject var rootPartActor : RootPartActor
    @Binding var factalsModel : FactalsModel
    @State private var rootPart: RootPart?

	var body: some View {
		HStack {	// FULL!
			if let rootPart {
				Text("rootPart: ").foregroundColor(.red).bold()
				Button(label:{	Text( "ptm")								})
				{	print(rootPart.pp(.tree, ["ppDagOrder":true]), terminator:"") }
				Button(label:{	Text("ptLm")								})
				{	print(rootPart.pp(.tree, ["ppDagOrder":true, "ppLinks":true]), terminator:"") }
				Spacer()
				Text("app:").foregroundColor(.red).bold()
				Button(label:{	Text( "state")								})//.padding(.top, 300)
				{	printFwState()											}
				Button(label: {	Text("LLDB") 								})
				{	lldbPrint(rootPart, /*Vews.first!,*/ mode:.tree, [:])
					breakToDebugger()										}
				Text(" ")
			}
			else {
				  // Use an onAppear modifier to trigger the asynchronous fetch
				 // of the actor property when the view appears
				Text("Loading \(rootPartActor.factalsModel == nil ? "" : "factalsModel ") " +
									  "\(rootPart == nil ? "" : "rootPart ") ...")
			}
		}
		.onAppear {
			Task {	// Access the actor property asynchronously
				rootPart = await rootPartActor.rootPart
			}
		}
	}
}
struct SimulatorBar : View {
    @Binding var simulator : Simulator

	var body: some View {
		HStack {
			//	Text("Settled:\(isSettled() ? "true" : "false")")
			Text("simulator:").foregroundColor(.red).bold()
			if let nogo = !simulator.simBuilt	? "unbuilt" : !simulator.simEnabled ? "disabled" : nil {
				Text(nogo)
				Spacer()
			}
			else {
				Button(label:{	Text("start")	})
				{	simulator.simEnabled = true
					simulator.startChits = 4								}
				Button(label:{	Text("step")								})
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
					//let bRpQ		= $factalsModel.rootPart//!.simulator		// Binding<RootPart?>
					//	@Bindable var viewModel = viewModel
					//LabeledCGFloat(label:"time:", val:$bRpQ., oneLine:true)
					//@Bindable var s			= $factalsModel.rootPart				// Binding<RootPart?>
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
