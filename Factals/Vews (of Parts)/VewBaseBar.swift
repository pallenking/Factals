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

	var body: some View {
//		let _ = Self._printChanges()
		VStack {
			HStack {
				if let slot		= vewBase.slot, 	// Installed?
				  let factalsModel	= vewBase.factalsModel {
					Text("VewBase")   .foregroundColor(.red)  .bold()
					Text("[\(slot)]:").foregroundColor(.green).bold()
					Button(label:{	Text("ptv")									})
					{	print("===== Vew of Slot\(slot): =====")
						print(vewBase.tree.pp(.tree, factalsGlobals.factalsConfig))
					}
					Button(label:{	Text("ptn")									})
					{	print("===== SCNNodes of Slot\(slot): =====")
						let scnScene = vewBase.scnSceneBase.tree
						print(scnScene?.rootNode.pp(.tree, factalsGlobals.factalsConfig) ?? "ews.scnSceneBase.tree == nil")
//						print(scnScene?.pp(.tree, factalsGlobals.factalsConfig) ?? "ews.scnSceneBase.tree == nil")
					}
					Text("Re-")
					Button(label:{	Text("Vew")									})
					{	print("===== Rebuild Views of Slot\(slot): =====")
						vewBase.partBase.tree.forAllParts({$0.markTree(dirty:.vew)	})
						factalsModel.updateVews()
					}
					Button(label:{	Text("siZe")								})
					{	print("===== Review siZes of Slot\(slot): =====")
						vewBase.partBase.tree.forAllParts({$0.markTree(dirty:.size)})
						factalsModel.updateVews()
					}
					Button(label:{	Text("Paint")								})
					{	print("===== Re-Paint Slot\(slot): =====")
						vewBase.partBase.tree.forAllParts({$0.markTree(dirty:.size)})
						factalsModel.updateVews()
					}
					Spacer()

					LabeledCGFloat(label:"prefFpsC",val:$vewBase.prefFpsC)
//					Text("prefFps=")
//					TextField("prefFps", value:$vewBase.prefFps, formatter:d2formatter)
//					 .frame(width:60 ).foregroundColor(Color(.red))
					Slider(value:$vewBase.prefFpsC, in: 0.0...60.0) { e in isEditing = e	}
					 .frame(width:100 )
				} else {
					Text("VewBase not registered in FactalsModel!").foregroundColor(.red).bold()
				}
			}
			HStack {
				SelfiePoleBar(selfiePole:$vewBase.selfiePole)
				Spacer()
			}
		}
		 .padding(4)
		 .background(Color(red:1.0, green:1.0, blue:0.9))
		 .border(Color.black, width:0.5)
//		 .padding(2)
	}
}
