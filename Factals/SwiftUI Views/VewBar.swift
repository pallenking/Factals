//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {
	@Binding var rootVew : RootVew
	@EnvironmentObject var appGlobals: AppGlobals		// Access
//	@EnvironmentObject var docGlobals: DocGlobals

	var body: some View {
		VStack {
			HStack {
				SelfiePoleBar(selfiePole:$rootVew.selfiePole)
				Spacer()
//				Button(label:{	Text("Z//RV").padding(.top, 300)				})
//				{	var s	= rootVew.selfiePole
//					s.zoom	/= 1.1
//					print("======== \(s.pp(.uidClass)) z=\(s.pp(.line))")
//					rootVew.selfiePole = s	// Put struct's val back
//				}
			}
			HStack {
				if let slot		= rootVew.slot {	// Installed?
					Text("Vew").foregroundColor(.red).bold()
					Text("Slot\(slot):").foregroundColor(.green).bold()
					Button(label:{	Text("ptv")									})
					{	print("===== Vew of Slot \(slot): =====")
						print(rootVew.pp(.tree, appGlobals.appConfig)) //+ docGlobals.docConfig))
					}
					Button(label:{	Text("ptn")									})
					{	print("===== SCNNodes of Slot \(slot): =====")
						print(rootVew.scn.pp(.tree, appGlobals.appConfig))
					}
					Text("Review:")
					Button(label:{	Text("View")								})
					{	print("===== Rebuild Views of Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.vew)	})
						rootVew.updateVewSizePaint(for:"VewBar V-key")
					}
					Button(label:{	Text("siZe")								})
					{	print("===== Review siZes of Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.size)})
						rootVew.updateVewSizePaint(for:"VewBar V-key")
					}
					Button(label:{	Text("Paint")								})
					{	print("===== Re-Paint Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.size)})
						rootVew.updateVewSizePaint(for:"VewBar V-key")
					}
					Button(label:{	Text("Z//RV")								})//.padding(.top, 300)
					{	var s	= rootVew.selfiePole
						s.zoom	/= 1.1
						print("======== \(s.pp(.uidClass)) z=\(s.pp(.line, appGlobals.appConfig))")
						rootVew.selfiePole = s	// Put struct's val back
					}
					Spacer()
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
