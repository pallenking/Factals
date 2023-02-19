//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {
//	@Binding var document			: FactalsDocument	// the Document type
//	@Binding var keyIndex			: Int
	@Binding var rootVews : [RootVew]
	let keySlot  : Int

	var body: some View {
		if keySlot < rootVews.count {
			let rootVew				= rootVews[keySlot]
			HStack {	// view
				let keyIndex		= rootVew.keyIndex ?? -1
				Text("\(keyIndex):")
				let slot			= rootVew.keyIndex ?? -1
				Button(label:{	Text(   "ptv")									})
				{	print("===== Vew of Slot \(slot): =====")
					lldbPrint(rootVew, mode:.tree, terminator:"")
				}
				Button(label:{	Text(   "ptn")									})
				{	print("===== SCNNodes of Slot \(slot): =====")
					lldbPrint(rootVew.scn, mode:.tree, terminator:"")
				}
				let rootScn 		= rootVew.rootScn
				Text("pole:\(rootScn.pp(.uid))=\(rootScn.selfiePole.pp())")
				Text("cameraScn:\(rootScn.cameraScn?.pp(.uid) ?? "nil") ")
//				Text("camera:\(rootVew.rootScn.cameraScn?.transform.pp(.line) ?? "nil") ")
			}
	//		 .background(Color.white)//white)//yellow NSColor("verylightgray")!
	//		 .background(NSColor("verylightgray")!) //white)//yellow
			 .padding(8)
	//		 .RoundedRectangle
			 .border(Color.black, width:0.5)
			 .padding(8)
		} else {
			HStack {	// view
				Text("rootVew=nil")
			}
	//		 .background(Color.white)//white)//yellow NSColor("verylightgray")!
	//		 .background(NSColor("verylightgray")!) //white)//yellow
			 .padding(8)
	//		 .RoundedRectangle
			 .border(Color.black, width:0.5)
			 .padding(8)
		}
	}
}
