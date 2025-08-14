//
//  SelfiePoleBar.swift
//  Factals
//
//  Created by Allen King on 2/19/23.
//

import SwiftUI
struct SelfiePoleBar: View   {													//xyzzy15.5
	@Binding var selfiePole	: SelfiePole

	var body: some View {
		HStack {
			VStack {
				Text("SelfiePole").bold().foregroundColor(.red)
				Text("id:\(selfiePole.pp(.nameTag))")
			}
			HStack {
//				VStack {
//					Text("SelfiePole").bold().foregroundColor(.red)
//					Text("id:\(selfiePole.pp(.nameTag))")
//				}
				InspecSCNVector3(label:"position", vect3:$selfiePole.position, oneLine:false)
				LabeledCGFloat(label:"spin", val:$selfiePole.spin, oneLine:false)
				LabeledCGFloat(label:"gaze", val:$selfiePole.gaze, oneLine:false)
				LabeledCGFloat(label:"zoom", val:$selfiePole.zoom, oneLine:false)
				VStack {
					Button(label:{	Text("Zo+")									})//.padding(.top, 300)
					{	var s			= selfiePole
						s.zoom			*= 1.1
						print("======== \(s.pp(.tagClass)) z=\(s.pp(.line))")
						selfiePole 		= s	// Put struct's val back
					}
					Button(label:{	Text("Zo-")									})//.padding(.top, 300)
					{	var s			= selfiePole
						s.zoom			/= 1.1
						print("======== \(s.pp(.tagClass)) z=\(s.pp(.line))")
						selfiePole 		= s	// Put struct's val back
					}
				}
				LabeledCGFloat(label:"ortho",val:$selfiePole.ortho, oneLine:false)
				Button(label:{	Text("**")										})//.padding(.top, 300)
				{	var s			= selfiePole
					let values		= [0.0, 0.1, 1.0, 10]
					let i	 		= values.firstIndex(where: { $0 >= s.ortho } ) ?? values.count
					s.ortho 		= values[(i+1) % values.count]
					print("======== \(s.pp(.tagClass)) o=\(s.ortho.pp(.line))")
					selfiePole 		= s	// Put struct's val back
				}
			}
			.onChange(of: selfiePole.zoom) { print(".onChange(of:selfiePole.zoom:",$0, $1) }
			.background(Color(red:1.0, green:0.9, blue:0.9))	// pink
		}
		// .padding(6)
	}
}

////FloatingPoint
////BinaryFloatingPoint
//
//			if let o 			= selfiePole.ortho {
//
//				TextField("Number", value: $number, format: .number)
//					.keyboardType(.decimalPad)
//				Button("Submit") {
//					// use the optional CGFloat here
//				}
//				.onSubmit(of: .continue) {
//					// use the optional CGFloat here
//				}
//
//
//
//				TextField("ortho", text:$selfiePole.ortho, onCommit: {
//
////				TextField.init(_:  text:onEditingChanged:). Use View.onSubmit(of:_:) for functionality previously provided by the onCommit parameter. Use FocusState<T> and View.focused(_:equals:) for functionality previously provided by the onEditingChanged parameter.")
//
//
//					if let newValue = NumberFormatter().number(from: floatString)?.doubleValue {
//						selfiePole.ortho = CGFloat(newValue)
//					} else {
//						selfiePole.ortho = nil
//					}
//				})
//				.keyboardType(.decimalPad)
//
//				LabeledCGFloat(label:"ortho", val:$selfiePole.ortho, oneLine:false)
//			} else {
//				Button("nil") {
//
//				}
//			}
