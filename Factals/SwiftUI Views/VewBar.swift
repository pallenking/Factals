//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {
	@Binding var rootVews : [RootVew]
	let keySlot  : Int

	var body: some View {
		if keySlot < rootVews.count {
			let rootVew				= rootVews[keySlot]
			VStack {
				HStack {
					let keyIndex		= rootVew.keyIndex ?? -1
					Text("Slot\(keyIndex):")
					let slot			= rootVew.keyIndex ?? -1
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
						rootVew.updateVewSizePaint(needsLock:"FwGuts V-key")
					//	lldbPrint(rootVew.scn, mode:.tree, terminator:"")
					}
					Button(label:{	Text("siZes")								})
					{	print("===== Review siZes of Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.size)})
						rootVew.updateVewSizePaint(needsLock:"FwGuts V-key")
					//	lldbPrint(rootVew.scn, mode:.tree, terminator:"")
					}
					Button(label:{	Text("Paint")								})
					{	print("===== Re-Paint Slot\(slot): =====")
						rootVew.rootPart.forAllParts({	$0.markTree(dirty:.size)})
						rootVew.updateVewSizePaint(needsLock:"FwGuts V-key")
					//	lldbPrint(rootVew.scn, mode:.tree, terminator:"")
					}
					Spacer()
				}
				HStack {					let rootScn 		= rootVew.rootScn
					Text("pole:\(rootScn.pp(.uid))=\(rootScn.selfiePole.pp())")
					Text("cameraScn:\(rootScn.cameraScn?.pp(.uid) ?? "nil") ")
//					Text("camera:\(rootVew.rootScn.cameraScn?.transform.pp(.line) ?? "nil") ")
					Spacer()
				}
			}
	//		 .background(Color.white)//white)//yellow NSColor("verylightgray")!
	//		 .background(NSColor("verylightgray")!) //white)//yellow
			 .padding(6)
		//	 .RoundedRectangle(RoundedRectangle(cornerRadius:2))// ERROR Value of type 'some View' has no member 'RoundedRectangle'
			 .border(Color.black, width:0.5)
			 .padding(8)
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
