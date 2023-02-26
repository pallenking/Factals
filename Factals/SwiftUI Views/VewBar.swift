//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {

	 // N.B: Sending the array and index allows internal checking
	@Binding var rootVews : [RootVew]
	let keySlot  : Int

	var body: some View {
		if keySlot < rootVews.count {
			let rootVew				= rootVews[keySlot]
			VStack {
				let slot		= rootVew.slot ?? -1
				HStack {
					Text("Slot\(slot):")
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
						Button(label:{	Text( "state").padding(.top, 300)				})
						{	printFwcState()												}
						Button(label: {	Text("LLDB") 									})
						{	breakToDebugger()											}
					}
				}
				HStack {
					//let rootScn 		= rootVew.rootScn
					let rootVew 		= rootVews[slot]
					SelfiePoleBar(selfiePole:$rootVews[slot].selfiePole)
					Spacer()
					Button(label:{	Text( "Z**").padding(.top, 300)				})
					{	rootVew.selfiePole.zoom	*= 1.1							}
				}
			}
	//		 .background(Color.white)//white)//yellow NSColor("verylightgray")!
	//		 .background(NSColor("verylightgray")!) //white)//yellow
			 .padding(4)
		//	 .RoundedRectangle(RoundedRectangle(cornerRadius:2))// ERROR Value of type 'some View' has no member 'RoundedRectangle'
			 .border(Color.black, width:0.5)
			 .padding(2)
		} else {
			HStack {	// view
				Text("rootVew=nil")
			}
			 .padding(6)
			 .border(Color.black, width:0.5)
			 .padding(8)
		}
	}
}
