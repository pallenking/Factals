//
//  GutsBar.swift
//  Factals
//
//  Created by Allen King on 2/14/23.
//

import SwiftUI

struct FwGutsBar: View {
	@Binding var fwGuts			: FwGuts

	var body: some View {
		 //  --- B U T T O N S  ---
		HStack {	// FULL!
			Text("FwGutsBar").foregroundColor(.red).bold()
			Text("   Print Application:")
			Button(label:{	Text( "state").padding(.top, 300)				})
			{	printFwState()												}
			Button(label:{	Text("config").padding(.top, 300)				})
			{	printFwConfig()											}
			if let rootPart = fwGuts.rootPart {
				Text("  Print Model:")
				Button(label:{	Text( "ptm")								})
				{	print(rootPart.pp(.tree), terminator:"")
					//lldbPrint(rootPart, mode:.tree)
				}
				Button(label:{	Text("ptLm")								})
				{	print(rootPart.pp(.tree, ["ppLinks":true]), terminator:"")
					//lldbPrint(rootPart, mode:.tree, ["ppLinks":true])
				}
			} else {
				Text("<<no nodel>>:")
			}
			Spacer()
			Button(label: {	Text("LLDB") 									})
			{	breakToDebugger()											}
			Text(" ")
		}
		 .padding(6)
		 .background(Color(red:0.9, green:0.9, blue:1.0))
		 .border(Color.black, width:0.5)
		 .padding(8)
	}
}
