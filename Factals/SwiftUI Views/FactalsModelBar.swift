//
//  FactalsModelBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct FactalsModelBar: View {
	/*@ObservedObject */@Bindable var factalsModel : FactalsModel
	
	var body: some View {
		HStack {
			Text("FactalsModel:").foregroundColor(.red).bold()
			Button(label:{	Text( "state")										})
			{	printFwState()													}
		//	Button(label:{	Text( "config")										})
		//	{	printFwConfig()													}
			Button(label: {	Text("LLDB") 										})
			{	breakToDebugger()												}
			Spacer()
		}
		VStack {
			PartBaseBar (partBase: $factalsModel.partBase)
			SimulatorBar(simulator:$factalsModel.simulator)
		}
		.padding(4)
		.background(Color(red:1.0, green:1.0, blue:0.9))
		.border(Color.black, width:2)
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
		}
	}
}
struct SimulatorBar : View {
    @Binding var simulator:Simulator

	@State private var timeNowText  : String = ""
	@State private var timeStepText : String = ""
	@State private var simTaskPeriodText: String = ""
	@State var epoch2 = 0
	@State private var myDouble: Double = 0.673

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
					simulator.simRun = false									}
				Text(simulator.simRun ? "RUN  " : "STOP")

				Text(" timeNow=")
				FwTextField(float: $simulator.timeNow).frame(width: 60)
				TextField("Double", value:$simulator.timeNow, format: .number)
//				FloatTextField(value:$simulator.timeNow, placeholder:"String")
//				TextField("", text:$timeNowText)
//					.onChange(of:timeNowText) { old, new in
//						simulator.timeNow = Float(new) ?? Float.nan				}
//					.onAppear {
//						timeNowText = String(simulator.timeNow)					}
//					.frame(width:50)
//				Text("\(simulator.globalDagDirUp ? ".up    "  : ".down") ")
				Spacer()

	//			Text("timeStep:")
	//			FloatTextField(value:$simulator.timeStep)
	//			TextField("", text:$timeStepText)
	//				.onChange(of: timeStepText) { old, new in
	//					//if let val = Float(new) {
	//					simulator.timeStep = Float(new) ?? Float.nan			}
	//				.onChange(of:simulator.timeNow) {
	//					timeNowText = String(simulator.timeNow)					}
	//				.onReceive(simulator.objectWillChange) { _ in
	//					epoch2 += 1												}
	//				.onAppear {
	//					timeStepText = String(simulator.timeStep)				}
	//				.frame(width:40)

	//			Text("taskPeriod:")
	//			FloatTextField(value:$simulator.simTaskPeriod)
	//			TextField("", text:$simTaskPeriodText)
	//				.onChange(of: simTaskPeriodText) { old, new in
	//					simulator.simTaskPeriod = Float(new) ?? Float.nan		}
	//				.onAppear {
	//					simTaskPeriodText = String(simulator.simTaskPeriod)		}
	//				.frame(width:40)
		//		Slider(value:$simulator.timeStep, in: 0.0...0.1) { e in }//isEditing = e	}
		//			.frame(width:100 )
			}}
		}
	}
}

struct FloatTextField: View {
	@Binding var value: Float

	var placeholder: String = "33.77"
	@State private var textValue: String = ""
	var body: some View {
		TextField(placeholder, text: $textValue)
			.onChange(of: textValue) { old, newValue in
				if let floatValue = Float(newValue) {
					value = floatValue
				} else {
					value = Float.nan
				}
			}
			.onAppear {
				textValue = String(value)
			}
			.frame(width: 50)
	}
}
