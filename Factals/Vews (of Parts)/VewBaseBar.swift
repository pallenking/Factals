//
//  VewBaseBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBaseBar: View {
	@Binding var vewBase : VewBase
	@EnvironmentObject var factalsGlobals: FactalsApp.FactalsGlobals
	@State   var isEditing = false

//	@EnvironmentObject private var appDelegate: FactalsAppDelegate

	var body: some View {
		//let _ 				= Self._printChanges()
		VStack {
			if let slot			= vewBase.slot, 	// Installed?
			  let factalsModel	= vewBase.factalsModel {
				HStack {
					Text("VewBase")   .foregroundColor(.red)  .bold()
					Text("[\(slot)]:").foregroundColor(.green).bold()
					TextField("title", text:$vewBase.title)
				}
				HStack {
					Button(label:{	Text("ptv")									})
					{	print("===== Vew of Slot\(slot): =====")
						print(vewBase.tree.pp(.tree, factalsGlobals.factalsConfig))
					}
					Button(label:{	Text("ptn")									})
					{	print("===== SCNNodes of Slot\(slot): =====")
						print(vewBase.gui?.anchor.pp(.tree, factalsGlobals.factalsConfig) ?? "ews.scnBase.tree == nil")
					}
					Spacer()
					Button(label:{	Text("Test")								})
					{	print("===== Test =====")
						let v1 = 1.0
						let v2 = 0.0
						logDat(3, "\n1:v1=%.2f, v2=%.2f", v1, v2)						// v1 = 0.00   v2 = 0.00
						logDat(3, "\n2:v1=%.2f, v2=%.2f", v1, v2)	// v1=0.00, v2=0.00
//						print("\n3:")
				//		let eventArea="dat", eventDetail=3, args:1.0;, 0.0//v1, v2
				//		let eventStr = eventArea + String(format:"%1d ", eventDetail)
				//		let message	 = eventStr + String(format:format, args)	// FINALLY
				//		Log.shared.logd(message, terminator:terminator, msgFilter:eventArea, msgPriority:eventDetail)
				//		ld way
				//		let str		 = String(format:"%1d", eventDetail)
				//		let format	 = eventArea + str + " " + format
				//		Log.shared.logd(format, args, terminator:terminator, msgFilter:eventArea, msgPriority:eventDetail)
						//Log.shared.atFoo("dat", 3, format:"v1=%.2f, v2=%.2f", args:v1, v2)	// v1=0.00, v2=0.00
					}
					LabeledCGFloat(label:"prefFps",val:$vewBase.prefFps)
					Slider(value:$vewBase.prefFps, in: 0.0...60.0) { e in isEditing = e	}
					 .frame(width:100 )
				}
				HStack {
					Text("Re-")
					Button(label:{	Text("Vew")									})
					{	print("===== Rebuild Views of Slot\(slot): =====")
						vewBase.partBase.tree.forAllParts({$0.markTreeDirty(bit:.vew)	})
						factalsModel.updateVews()		//(gui instgated)
					}
					Button(label:{	Text("siZe")								})
					{	print("===== Review siZes of Slot\(slot): =====")
						vewBase.partBase.tree.forAllParts({$0.markTreeDirty(bit:.size)})
						factalsModel.updateVews()
					}
					Button(label:{	Text("Paint")								})
					{	print("===== Re-Paint Slot\(slot): =====")
						vewBase.partBase.tree.forAllParts({$0.markTreeDirty(bit:.size)})
						factalsModel.updateVews()
					}
					Spacer()
				}
			} else {
				Text("FactalsModel not registered in VewBase!").foregroundColor(.red).bold()
			}
			HStack {
 //				SelfiePoleBar3(selfiePole:$vewBase.selfiePole)
				SelfiePoleBar(selfiePole:$vewBase.selfiePole)
	//	 .border(Color.gray, width: 3)
//		 .frame(width:800, height:20)
			}
			Divider()
		}
		 .padding(4)
//		 .background(Color(red:1.0, green:1.0, blue:0.9))
	//	 .border(Color.black, width:1.0)
//		 .padding(2)
	}
}
