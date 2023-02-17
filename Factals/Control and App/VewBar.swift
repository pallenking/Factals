//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {
//	@Binding var document			: FactalsDocument	// the Document type
	@Binding var rootVew : RootVew

	var body: some View {
		HStack {	// view
			let slot			= rootVew.keyIndex ?? -1
			Button(label:{	Text(   "ptv")									})
			{	print("===== Vew of Slot \(slot): =====")
				lldbPrint(rootVew, mode:.tree, terminator:"")
			}
			Button(label:{	Text(   "ptn")									})
			{	print("===== SCNNodes of Slot \(slot): =====")
				lldbPrint(rootVew.scn, mode:.tree, terminator:"")
			}
			Text("pole:\(  rootVew.rootScn.selfiePole.pp())")
			Text("camera:\(rootVew.rootScn.cameraScn?.transform.pp(.line) ?? "nil") ")
		}
	//	 .background(Color.white)//white)//yellow NSColor("verylightgray")!
	//	 .background(NSColor("verylightgray")!) //white)//yellow
		 .padding(8)
	//	 .RoundedRectangle
		 .border(Color.black, width:0.5)
		 .padding(8)
	}
}
