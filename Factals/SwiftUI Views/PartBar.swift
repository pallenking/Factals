//
//  PartBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct PartBar: View {
	@Binding var fwGuts			: FwGuts

	var body: some View {
		 //  --- B U T T O N S  ---
		HStack {	// FULL!
			Text("   Application:")
			Button(label:{	Text( "state").padding(.top, 300)				})
			{	printFwState()												}
			Button(label:{	Text("config").padding(.top, 300)				})
			{	printFwConfig()											}
			if let rootPart = fwGuts.rootPart {
				Text("  Model:")
				Button(label:{	Text( "ptm")								})
				{	lldbPrint(rootPart, mode:.tree)							}
				Button(label:{	Text("ptLm")								})
				{	lldbPrint(rootPart, mode:.tree, ["ppLinks":true])}
			} else {
				Text("<<no nodel>>:")
			}
			Spacer()
			Button(label: {	Text("LLDB") 									})
			{	breakToDebugger()											}
			Text(" ")
		}
		 .padding(6)
		 .border(Color.black, width:0.5)
		 .padding(8)
	}
}
