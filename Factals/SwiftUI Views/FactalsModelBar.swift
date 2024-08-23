//
//  FactalsModelBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct FactalsModelBar: View {
	@ObservedObject var factalsModel : FactalsModel
	
	var body: some View {
		HStack { Text("FactalsModel:").foregroundColor(.red).bold(); Spacer() }
		VStack {
			PartBaseBar (partBase: $factalsModel.partBase)
			SimulatorBar(simulator:$factalsModel.simulator)
		}
		.padding(4)
		.background(Color(red:1.0, green:1.0, blue:0.9))
		.border(Color.black, width:2.5)
		.padding(2)
	}
}

struct PartBaseBar : View {
	@Binding var partBase : PartBase

	var body: some View {
		HStack {	// FULL!
			Text("PartBase: ").foregroundColor(.red).bold()
			Text(partBase.title).foregroundColor(.blue).bold()
//			FwTextField(string: partBase.title)
			Button(label:{	Text( "ptm")										})
			{	print(partBase.pp(.tree, ["ppDagOrder":true])) 					}
			Button(label:{	Text("ptLm")										})
			{	print(partBase.pp(.tree, ["ppDagOrder":true, "ppLinks":true]))	}
			Spacer()
			Text("FactalsApp:").foregroundColor(.red).bold()
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
    @Binding var simulator:Simulator
	@State private var (textValue)  : String = ""
	@State private var (textValue2) : String = ""

	var body: some View {
		HStack {
			//	Text("Settled:\(isSettled() ? "true" : "false")")
			Text("Simulator:").foregroundColor(.red).bold()
			if simulator.simBuilt == false {
				Text("unbuilt")
				Spacer()
			}
			else { HStack {
				Button(label:{	Text("start")	})
				{	simulator.simRun = true
					simulator.startChits = 4									}
				Button(label:{	Text(simulator.simRun ? "stop" : "step")										})
				{	simulator.simRun = true
					simulator.simulateOneStep()
					simulator.simRun = false								}
				Text(simulator.simRun ? "RUN  " : "STOP")
				Text(" timeNow=")
				FwTextField(float: $simulator.timeNow).frame(width: 60)
				TextField("", text: $textValue)
					.onChange(of: textValue) { old, newTextValue in
						simulator.timeNow = Float(newTextValue) ?? Float.nan
					}
					.onAppear {
						textValue 	= String(simulator.timeNow)
					}
					.frame(width:50)
		//		if  simulator.simRun == false {
		//			Text("stopped")
		//		}
				Text("\(simulator.globalDagDirUp ? ".up    "  : ".down") ")
				Spacer()

				Text("timeStep:")
		//		FwTextField(float:$simulator.timeStep).frame(width:60 ).foregroundColor(Color(.red))
				TextField("", text: $textValue)
					.onChange(of: textValue) { old, newTextValue in
						simulator.timeStep = Float(newTextValue) ?? Float.nan
					}
					.onAppear {
						textValue 	= String(simulator.timeStep)
					}
					.frame(width:40)
				Text("simTaskPeriod:")
		//		FwTextField(float:$simulator.timeStep).frame(width:60 ).foregroundColor(Color(.red))
				TextField("", text: $textValue2)
					.onChange(of: textValue2) { old, newTextValue in
						simulator.simTaskPeriod = Double(newTextValue) ?? Double.nan
					}
					.onAppear {
						textValue2 	= String(simulator.simTaskPeriod)
					}
					.frame(width:40)
		//		Slider(value:$simulator.timeStep, in: 0.0...0.1) { e in }//isEditing = e	}
		//			.frame(width:100 )
		//
		//				//@Bindable var s			= $factalsModel.partBase				// Binding<Parts?>
		//				//Text("chits: p:\(simulator.portChits) l:\(simulator.linkChits) s:\(simulator.startChits) ")
		//				// Other things to worry about later
		//				//		!simulator.simTaskRunning
		//				//	ro	var timeStep		: Float = 0.01
		//				//		func isSettled() -> Bool				chevron
		//				//		var timingChains:[TimingChain] = []	chevron
		//				//	ro	var globalDagDirUp	: Bool	= true
//				HStack {
//					///
//					/// SEE FactalStatus.Simulator.ppFactalsState()
//					///
//					//var timeNow : Float	= 0.0
//					//					LabeledCGFloat(label:" time:", val:$factalsModel.fooo, oneLine:true)
//				}
//				.padding(2)
//				.background(Color(red:1.0, green:0.9, blue:0.9))
			}}
	//		Spacer(minLength:4.0)
	//		Text("             ")
////			@State   var speed 	= 50.0			// WORSE
//			@State   var speed : Float = 50.0
//			@State   var isEditing = false
//			HStack (alignment:.top) {
//				FwTextField(float:$speed)
////				Text("   speed=\(speed), isEditing=\(isEditing):")
//				Slider(value:$speed, in: 0.0...60.0) { editing in
//					isEditing = editing
//				}
//			}
		}
	}
}
