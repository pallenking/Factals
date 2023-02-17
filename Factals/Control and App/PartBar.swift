//
//  PartBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct PartBar: View {
	@Binding var document			: FactalsDocument	// the Document type

	var body: some View {
		let fwGuts 				= document.fwGuts
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
			Spacer()
			Button(label: {	Text("LLDB") 									})
			{	breakToDebugger()											}
			Text("  Ctl:")
			Button(label:{	Text( "state").padding(.top, 300)				})
			{	printFwcState()												}
			Button(label:{	Text("config").padding(.top, 300)				})
			{	printFwcConfig()											}
			Spacer()
		}
	}
}
