//
//  VewBaseBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBaseBar: View {
	@Binding var vewBase : VewBase



	//@State var speed 	= 50.0			// WORSE
	@State   var speed : Float = 50.0	// BETTER
	@State   var isEditing = false
	@EnvironmentObject var factalsGlobals: FactalsApp.FactalsGlobals

	var body: some View {
		VStack {
			HStack {
				SelfiePoleBar(selfiePole:$vewBase.selfiePole)
				Spacer()
//				Button(label:{	Text("Z//RV").padding(.top, 300)				})
//				{	var s	= $vewBase.selfiePole
//			//		s.zoom	/= 1.1
//					print("======== \(s.pp(.uidClass)) z=\(s.pp(.line))")
//					$vewBase.selfiePole = s	// Put struct's val back
//				}
			}
			HStack {
				if let slot		= vewBase.slot, 	// Installed?
				  let factalsModel	= vewBase.factalsModel {
					Text("Vew").foregroundColor(.red).bold()
					Text("Slot\(slot):").foregroundColor(.green).bold()
					Button(label:{	Text("ptv")									})
					{	print("===== Vew of Slot\(slot): =====")
						print(vewBase.tree.pp(.tree, factalsGlobals.factalsConfig))
					}
					Button(label:{	Text("ptn")									})
					{	print("===== SCNNodes of Slot\(slot): =====")
						print(vewBase.scnBase.tree?.pp(.tree, factalsGlobals.factalsConfig) ?? "ews.scnBase.tree == nil")
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
					Button(label:{	Text("Z//RV")								})//.padding(.top, 300)
					{	var s	= vewBase.selfiePole
						s.zoom	/= 1.1
						print("======== \(s.pp(.uidClass)) z=\(s.pp(.line, factalsGlobals.factalsConfig))")
						vewBase.selfiePole = s	// Put struct's val back
					}
					Spacer()
					HStack (alignment:.top) {
						FwTextField(float:$speed).frame(width:40 ).foregroundColor(Color(.red))
						//				Text("   speed=\(speed), isEditing=\(isEditing):")
						Slider(value:$speed, in: 0.0...60.0) { editing in
							isEditing = editing
						}
						.frame(width:200 )
					}
				} else {
					Text("Not registered in rootVews").bold()
				}
			}
		}
		 .padding(4)
		 .background(Color(red:1.0, green:1.0, blue:0.9))
		 .border(Color.black, width:0.5)
//		 .padding(2)
	}
}