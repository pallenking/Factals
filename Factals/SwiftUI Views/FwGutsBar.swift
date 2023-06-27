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

			if let rootPart = fwGuts.rootPart {
				Text("  Print Model:")
				Button(label:{	Text( "ptm")								})
				{	print(rootPart.pp(.tree), terminator:"")
					lldbPrint(rootPart, mode:.tree)
				}
				Button(label:{	Text("ptLm")								})
				{	print(rootPart.pp(.tree, ["ppLinks":true]), terminator:"")
					lldbPrint(rootPart, mode:.tree, ["ppLinks":true])
				}
			} else {
				Text("<<no nodel>>:")
			}
			Spacer()
			Button(label: {	Text("LLDB") 									})
			{	breakToDebugger()											}
			Text(" ")
		}
		 .padding(4)
		 .background(Color(red:1.0, green:1.0, blue:0.9))
		 .border(Color.black, width:2.5)
		 .padding(2)
//		 .padding(6)
//		 .background(Color(red:0.9, green:0.9, blue:1.0))
//		 .border(Color.black, width:0.5)
//		 .padding(8)
	}
}
