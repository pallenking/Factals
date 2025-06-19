//
//  FactalsModelBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct FactalsModelBar: View {
	@Bindable var factalsModel : FactalsModel
	
	var body: some View {
		VStack {
			HStack {
				Text("FactalsModel:").foregroundColor(.red).bold().presentationBackground(Color(.white))
				Button(label:{	Text( "state")									})
				{	print(ppControllers())										}
				Button(label:{	Text( "config")									})
				{	print(ppControllers())										}
				Button(label:{	Text("Reset")									})
				{	factalsModel.partBase.tree.reset()							}
				Spacer()
			//	Button(label: {	Text("++epoch\(factalsModel.epoch)")			})
			//	{	factalsModel.epoch		+= 1								}
				Button(label: {	Text("LLDB") 									})
				{	breakToDebugger()											}
				Text("http://brain-gears.blogspot.com")// pw isable URL test -- .foregroundColor(.red) ignored
			}
			PartBaseBar (partBase: $factalsModel.partBase)
			SimulatorBar(simulator:$factalsModel.simulator)
		}
		.padding(4)
		.background(Color(red:1.0, green:1.0, blue:0.9))	// faint yellow
		.border(Color.black, width:2)
	}
}
struct PartBaseBar : View {
	@Binding var partBase : PartBase		// NOT @Bindable

	var body: some View {
		HStack {	// FULL!
			let	hnw			= partBase.hnwMachine
			Text("PartBase:").foregroundColor(.red).bold()
			Text(hnw.sourceOfTest)
			TextField("title", text:$partBase.hnwMachine.title)
				.frame(width:200)
				.foregroundColor(.blue)
				.bold()
			Text(partBase.hnwMachine.postTitle)
			Spacer()
//			Button(label:{	Text( "ptm")										})
//			{	print(partBase.pp(.tree, ["ppDagOrder":true])) 					}
			Button(label:{	Text( "ptmX")										})
			{	print(partBase.pp(.tree, ["ppDagOrder":false])) 				}
			Button(label:{	Text("ptLm")										})
			{	print(partBase.pp(.tree, ["ppDagOrder":true, "ppLinks":true]))	}
		}
	}
}
struct SimulatorBar : View {
    @Binding var simulator:Simulator
								
	@State private var timeNowText  : String = ""
	@State private var timeStepText : String = ""
	@State private var simTaskPeriodText: String = ""
	@State var epoch2 			= 0
	@State private var myDouble : Double = 0.673
	@State private var volume   : Double = 1

	var body: some View {
		HStack {
			//	Text("Settled:\(isSettled() ? "true" : "false")")
			Text("Simulator:").foregroundColor(.red).bold()
			if simulator.simBuilt == false {
				Text("unbuilt")
				Spacer()
			}
			else { HStack {
				Text(simulator.simRun ? "RUNNING" : "STOPPED")
				Button(label:{	Text("start")	})
				{	simulator.simRun = true
					simulator.startChits = 4									}
				Button(label:{	Text(simulator.simRun ? "stop" : "step")										})
				{	simulator.simRun = true
					simulator.simulateOneStep()
					simulator.simRun = false									}
				Text(" timeNow=")
				TextField("timeNow=", value:$simulator.timeNow,
					format:.number.precision(.significantDigits(5))).frame(width:80)
				Text(" volume=")
				TextField("volume=", value:$volume,
					format:.number.precision(.significantDigits(5))).frame(width:80)
				Spacer()

				Text("timeStep:")
				TextField("timeStep=", value:$simulator.timeStep,
					format:.number.precision(.significantDigits(5))).frame(width:70)

				Text("taskPeriod:")
				TextField("taskPeriod=", value:$simulator.simTaskPeriod,
					format:.number.precision(.significantDigits(5))).frame(width:70)
		//		Slider(value:$simulator.timeStep, in: 0.0...0.1) { e in }//isEditing = e	}
		//			.frame(width:100 )
			}}
		}
	}
}
