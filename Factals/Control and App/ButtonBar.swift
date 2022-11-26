//
//  ButtonBar.swift
//  Factals
//
//  Created by Allen King on 11/16/22.
//

import SwiftUI

struct ButtonBar: View {
	@Binding var document		: FactalsDocument	// the Document type
//	@Binding var dragonValue	: Int

	var body: some View {
		let fwGuts 				= document.fwGuts
		let rootVews			= fwGuts?.rootVews ?? [:]
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
				{	for (key, rootVew) in fwGuts?.rootVews ?? [:] {
						print("===== Slot \(key): =====")
						lldbPrint(rootVew, mode:.tree, terminator:"")
					}
				}
			//	Button(label:{	Text("0")}) { lldbPrint(rootVews[0]?, mode:.tree)}
			//	Button(label:{	Text("1")}) { lldbPrint(rootVews[1], mode:.tree)}
			//	Button(label:{	Text("2")}) { lldbPrint(rootVews[2], mode:.tree)}
				Button(label:{	Text(   "ptn")									})
				{	for (key, rootVew) in fwGuts?.rootVews ?? [:] {
						print("===== Slot \(key): =====")
						lldbPrint(rootVew.scn, mode:.tree, terminator:"")
					}// Tuple type 'Dictionary<Int, RootVew>.Element'  (aka '(key: Int, value: RootVew)') has no member 'scn'
				}
			//	Button(label:{	Text("0")}) { lldbPrint(rootVews[0].scn, mode:.tree)}
			//	Button(label:{	Text("1")}) { lldbPrint(rootVews[1].scn, mode:.tree)}
			//	Button(label:{	Text("2")}) { lldbPrint(rootVews[2].scn, mode:.tree)}
				Spacer()
				Button(label: {	Text("LLDB") 									})
				{	breakToDebugger()											}
			//	Text(" ")
			}
			HStack {
				Text("  Control:")
				Button(label:{	Text( "state").padding(.top, 300)				})
				{	printFwcState()												}
				Button(label:{	Text("config").padding(.top, 300)				})
				{	printFwcConfig()											}
				Spacer()
				Button(label: {	Text("Dragon:XX")								}) //\(dragonValue)++
				{}//dragonValue += 1							}	// %64
				Text(" ")
			}
		}
		 .padding(5)
	}
}
