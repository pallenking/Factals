//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {

	 // N.B: Sending the array and index allows internal checking
	// N.B: When VewBar loads rootVews, it is empty! It is not empty when accessed [slot]
	@Binding var rootVews : [RootVew]
	let slot : Int

	var body: some View {
		if slot < rootVews.count {
			let rootVew			= rootVews[slot]
			VStack {
				HStack {
					Text("Slot\(slot):").foregroundColor(.green).bold()
					Button(label:{	Text("ptv")									})
					{	print("===== Vew of Slot \(slot): =====")
						lldbPrint(rootVew, mode:.tree, terminator:"")
					}
					Button(label:{	Text("ptn")									})
					{	print("===== SCNNodes of Slot \(slot): =====")
						lldbPrint(rootVew.scn, mode:.tree, terminator:"")
					}
					Text("Review:")
					Button(label:{	Text("Views")								})
					{	print("===== Rebuild Views of Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.vew)	})
						rootVew.updateVewSizePaint(needsLock:"VewBar V-key")
					}
					Button(label:{	Text("siZes")								})
					{	print("===== Review siZes of Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.size)})
						rootVew.updateVewSizePaint(needsLock:"VewBar V-key")
					}
					Button(label:{	Text("Paint")								})
					{	print("===== Re-Paint Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.size)})
						rootVew.updateVewSizePaint(needsLock:"VewBar V-key")
					}
					Spacer()
					// just for debug
					if trueF {
						Button(label:{	Text( "state").padding(.top, 300)		})
						{	printFwState()										}
						Button(label: {	Text("LLDB") 							})
						{	breakToDebugger()									}
					}
				}
				HStack {
					SelfiePoleBar(selfiePole:$rootVews[slot].selfiePole)	// Bad: $rootVew.selfiePole
					Spacer()
					Button(label:{	Text("Z**RV").padding(.top, 300)				})
					{	var s	= rootVew.selfiePole
						s.zoom	*= 1.1
						print("======== \(s.pp(.uidClass)) z=\(s.pp(.line))")
						rootVews[slot].selfiePole = s	// Put struct's val back
					}
				}
			}
			 .padding(4)
			 .background(Color(red:1.0, green:1.0, blue:0.9))
			 .border(Color.black, width:2.5)
			 .padding(2)
		} else {
			Text("rootVew=nil")
		}
	}
}
