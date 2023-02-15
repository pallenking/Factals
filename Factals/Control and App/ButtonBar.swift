//
//  ButtonBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct ButtonBar: View {
	@Binding var document			: FactalsDocument	// the Document type

	var body: some View {
		let fwGuts 				= document.fwGuts
		let rootVews			= fwGuts?.rootVews ?? []
		VStack {
			 //  --- B U T T O N S  ---
			HStack {	// FULL!
				if let rootPart = fwGuts?.rootPart {
					Text("  Model:")
					Button(label:{	Text(   "ptm")								})
					{	lldbPrint(rootPart, mode:.tree)							}
					Button(label:{	Text(  "ptLm")								})
					{	lldbPrint(rootPart, mode:.tree, ["ppLinks":true])}
				}
				Text(" ")
				Button(label:{	Text(   "ptv")									})
				{	for (i, rootVew) in rootVews.enumerated() {
						print("===== Vew of Slot \(i): =====")
						lldbPrint(rootVew, mode:.tree, terminator:"")
					}
				}
				Button(label:{	Text(   "ptn")									})
				{	for (i, rootVew) in rootVews.enumerated() {
						print("===== SCNNodes of Slot \(i): =====")
						lldbPrint(rootVew.scn, mode:.tree, terminator:"")
					}
				}
				Spacer()
				Button(label: {	Text("LLDB") 									})
				{	breakToDebugger()											}
			//	Text(" ")
			}
			HStack {
				Text("  Ctl:")
				Button(label:{	Text( "state").padding(.top, 300)				})
				{	printFwcState()												}
				Button(label:{	Text("config").padding(.top, 300)				})
				{	printFwcConfig()											}
				Text("pole:\( rootVew0.rootScn.selfiePole.pp() ?? "-") cam-< \(rootVew0.rootScn.cameraScn?.transform.pp(.line) ?? "nil") ")
				Spacer()
				Text(" ")
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
