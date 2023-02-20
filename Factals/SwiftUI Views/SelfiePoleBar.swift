//
//  File.swift
//  Factals
//
//  Created by Allen King on 2/19/23.
//

import SwiftUI

struct LabeledCGFloat: View {
			 var label		: String
	@Binding var cgFloat	: CGFloat
			 var formatter	: NumberFormatter = d2formatter
			 var oneLine	= true

	var body: some View {
		if oneLine {
			Text(label)
			 .padding(.horizontal, -3)
			TextField("", value:$cgFloat, formatter:formatter).frame(width:35)
			 .padding(.horizontal, -3)
		} else {
			VStack {
				Text(label)
				 .padding(.horizontal, -3)
				 .padding(.vertical, -10)
				TextField("", value:$cgFloat, formatter:formatter).frame(width:35)
				 .padding(.horizontal, -3)
			}
		}
	}
}

struct SelfiePoleBar: View {
	@Binding var selfiePole	: SelfiePole

	var body: some View {
		HStack {
			Text("SelfiePole:\(selfiePole.pp(.uid)):")
			 .padding(.horizontal, -8)
			InspecSCNVector3(label:"position", vect3:$selfiePole.position,		 oneLine:false)
			 .padding(.horizontal, 5)
			LabeledCGFloat(label:"spin", cgFloat:$selfiePole.spin,	 oneLine:false)
			LabeledCGFloat(label:"upw",  cgFloat:$selfiePole.horizonUp,oneLine:false)
			LabeledCGFloat(label:"zoom",  cgFloat:$selfiePole.zoom,	 oneLine:false)
		}
		 .padding(6)
	}
}
