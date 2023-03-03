//
//  File.swift
//  Factals
//
//  Created by Allen King on 2/19/23.
//

import SwiftUI

struct LabeledCGFloat: View {
			 var label		: String
	@Binding var val		: CGFloat
			 var formatter	: NumberFormatter = d2formatter
			 var oneLine	= true

	var body: some View {
		if oneLine {
			Text(label)
			 .padding(.horizontal, -3)
			TextField("", value:$val, formatter:formatter).frame(width:35)
			 .padding(.horizontal, -3)
		} else {
			VStack {
				Text(label)
				 .padding(.horizontal, -3)
				 .padding(.vertical, -10)
				TextField("", value:$val, formatter:formatter).frame(width:35)
				 .padding(.horizontal, -3)
			}
		}
	}
}

struct SelfiePoleBar: View {
	@Binding var selfiePole	: SelfiePole

	var body: some View {
		HStack {
			Text("SelfiePole:\n\(selfiePole.pp(.uid)):")
			 .padding(.horizontal, -8)
			InspecSCNVector3(label:"position", vect3:$selfiePole.position, oneLine:false)
			 .padding(.horizontal, 5)
			LabeledCGFloat(label:"spin", val:$selfiePole.spin, oneLine:false)
			LabeledCGFloat(label:"gaze", val:$selfiePole.gaze, oneLine:false)
			LabeledCGFloat(label:"zoom", val:$selfiePole.zoom, oneLine:false)
								
			Button(label:{	Text( "Z**").padding(.top, 300)							})
			{	var s			= selfiePole
				s.zoom			*= 1.1
				print("======== \(s.pp(.uidClass)) z=\(s.pp(.line))")
				selfiePole 		= s	// Put struct's val back
			}

		}
		 .padding(6)
	}
}
