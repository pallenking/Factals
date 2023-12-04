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


//class ViewModel: ObservableObject {
//	@Published var numberString: String = ""
//	var number: CGFloat? {
//		if let doubleValue = Double(numberString) {
//			return CGFloat(doubleValue)
//		}
//		return nil
//	}
//
//	init(number: CGFloat?) {
//		if let number = number {
//			numberString = "\(number)"
//		} else {
//			numberString = "nil"
//		}
//	}
//}

//@propertyWrapper
//struct OptionalFloatingPoint<T: FloatingPoint> {
//	private var value: T?
//
//	var wrappedValue: String {
//		get {
//			guard let value = value else { return "nil" }
//			value == 1
//			return String(describing: value)
//		}
//		set {
//			if newValue.lowercased() == "nil" {
//				value = nil
//			} else if let number = Float(newValue) { 	// T(newValue) fails
//				value = number as! T
//			} else if let number = T(exactly:1) { 	// T(newValue) fails
//				value = number
//			} else {
//				value = nil
//			}
//		}
//	}
//	init() {
//		self.value = nil
//	}
//}

struct SelfiePoleBar: View {
	@Binding var selfiePole	: SelfiePole

	var body: some View {
		HStack {
			VStack {
				Text("SelfiePole").foregroundColor(.red).bold()
				Text("\(selfiePole.pp(.uid)):")
			}
//			Text("SelfiePole:\n\(selfiePole.pp(.uid)):")//.foregroundColor(.red).bold()
			 .padding(.horizontal, -8)
			InspecSCNVector3(label:"position", vect3:$selfiePole.position, oneLine:false)
			 .padding(.horizontal, 5)
			LabeledCGFloat(label:"spin", val:$selfiePole.spin, oneLine:false)
			LabeledCGFloat(label:"gaze", val:$selfiePole.gaze, oneLine:false)
			LabeledCGFloat(label:"zoom", val:$selfiePole.zoom, oneLine:false)
			Button(label:{	Text("Z**")											})//.padding(.top, 300)
			{	var s			= selfiePole
				s.zoom			*= 1.1
				print("======== \(s.pp(.uidClass)) z=\(s.pp(.line))")
				selfiePole 		= s	// Put struct's val back
			}
			LabeledCGFloat(label:"ortho",val:$selfiePole.ortho, oneLine:false)
			Button(label:{	Text("O-+")											})//.padding(.top, 300)
			{	var s			= selfiePole
				let values		= [0.0, 0.1, 1.0, 10]
				let i	 		= values.firstIndex(where: { $0 >= s.ortho } ) ?? values.count
				s.ortho 		= values[(i+1) % values.count]
				print("======== \(s.pp(.uidClass)) o=\(s.ortho.pp(.line))")
				selfiePole 		= s	// Put struct's val back
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
		}
		// .padding(6)
		 .background(Color(red:1.0, green:0.9, blue:0.9))
	}
}
