//  InspecSCNVector3.swift -- ©2021PAK
//

import SwiftUI
import SceneKit

struct InspecSCNVector3: View {
			 var label		: String
	@Binding var vect3:SCNVector3
			 var formatter	: NumberFormatter = d2formatter
			 var oneLine	= false

    var body: some View {
		let formatter = NumberFormatter()
		if oneLine {
			LabeledCGFloat(label:label+"x", val:$vect3.x, formatter:formatter)
			LabeledCGFloat(label:"y", 		val:$vect3.y, formatter:formatter)
			LabeledCGFloat(label:"z", 		val:$vect3.z, formatter:formatter)
		} else {
			VStack {
				Text(label).padding(.vertical, -10)
				HStack {
					LabeledCGFloat(label:"x", val:$vect3.x, formatter:formatter)
					LabeledCGFloat(label:"y", val:$vect3.y, formatter:formatter)
					LabeledCGFloat(label:"z", val:$vect3.z, formatter:formatter)
				}
			}
		}
    }
}
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
