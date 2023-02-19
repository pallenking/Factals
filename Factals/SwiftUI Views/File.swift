//
//  File.swift
//  Factals
//
//  Created by Allen King on 2/19/23.
//

import SwiftUI

struct SelfiePoleBar: View {
	@Binding var selfiePole	: SelfiePole

	var body: some View {
		 //  --- B U T T O N S  ---
		HStack {	// FULL!
			Text("SelfiePole:")
/*
	var uid			: UInt16  		= randomUid()
	var at							= SCNVector3.origin	// world
	var spin  		: CGFloat 		= 0					// in degrees
	var horizonUp	: CGFloat 		= 0					// in degrees
	var zoom		: CGFloat 		= 1.0
*/
			TextField("", value:$selfiePole.spin,	 formatter:d2formatter).frame(width:50)
//			Button(label:{	Text( "state").padding(.top, 300)				})
//			{	printFwcState()												}
		}
		 .padding(6)
		 .border(Color.black, width:0.5)
		 .padding(8)
	}
}
