//
//  VewBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct VewBar: View {
	@Binding var document			: FactalsDocument	// the Document type
	@Binding var keyIndex			: Int
//	@Binding var rootVew : RootVew

	var body: some View {
		HStack {	// view
			Text("\(keyIndex):")
			let rootVews		= document.fwGuts.rootVews
			if rootVews.count <= keyIndex 	{			fatalError()			}
			let  rootVew			= rootVews[keyIndex]
			let slot			= rootVew.keyIndex ?? -1
			//	assert(slot == keyIndex, "paranoia")
			if slot == keyIndex {	//paranoia
				Button(label:{	Text(   "ptv")									})
				{	print("===== Vew of Slot \(slot): =====")
					lldbPrint(rootVew, mode:.tree, terminator:"")
				}
				Button(label:{	Text(   "ptn")									})
				{	print("===== SCNNodes of Slot \(slot): =====")
					lldbPrint(rootVew.scn, mode:.tree, terminator:"")
				}
				Text("pole:\(     rootVew.rootScn.selfiePole.pp())")
				Text("cameraScn:\(rootVew.rootScn.cameraScn?.pp(.uidClass) ?? "nil") ")
//				Text("camera:\(rootVew.rootScn.cameraScn?.transform.pp(.line) ?? "nil") ")
			} else {
				Text("slot!=keyIndex INCONSISTENCY / paranoia")
			}
		}
	//	 .background(Color.white)//white)//yellow NSColor("verylightgray")!
	//	 .background(NSColor("verylightgray")!) //white)//yellow
		 .padding(8)
	//	 .RoundedRectangle
		 .border(Color.black, width:0.5)
		 .padding(8)
	}
}
