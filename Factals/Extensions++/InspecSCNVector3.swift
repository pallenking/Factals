//  InspecSCNVector3.swift -- ©2021PAK
//

import SwiftUI
import SceneKit

let d2formatter					= { () -> NumberFormatter in
	let rv 						= NumberFormatter()
	rv.minimumFractionDigits 	= 2
	rv.maximumFractionDigits 	= 2
	return rv
} ()

struct InspecSCNVector3: View {
			 var label		: String		// ARG 1: Title
	@Binding var vect3:SCNVector3			// ARG 2: the vector
			 var formatter	: NumberFormatter = d2formatter
			 var oneLine	= false

    var body: some View {
		let formatter = NumberFormatter()
		if oneLine {
			LabeledCGFloat(label:label+"x", val:$vect3.x, formatter:formatter)
			LabeledCGFloat(label:"y", 		val:$vect3.y, formatter:formatter)
			LabeledCGFloat(label:"z", 		val:$vect3.z, formatter:formatter)
		} else {
			VStack (spacing:0){
				Text(label).fixedSize()		//.padding(.vertical, -10)
//				Text(label).lineLimit(1)		//.padding(.vertical, -10)
				HStack {
					LabeledCGFloat(label:"x", val:$vect3.x, formatter:formatter)
					LabeledCGFloat(label:"y", val:$vect3.y, formatter:formatter)
					LabeledCGFloat(label:"z", val:$vect3.z, formatter:formatter)
				}
			}
		}
    }
}
struct LabeledCGFloat: View {				// 2: New, requires 2 enters!
	var label					: String				// arg1:
	@Binding var val			: CGFloat				// arg2:
	@State private var localVal	: CGFloat = .nan
	var oneLine					= true					// arg3?:
	var formatter : NumberFormatter = d2formatter		// arg4?:

	var body: some View {
		if oneLine {			// Horizontal
			thaTwo()
		}
		else {					// Vertical
			VStack {
				thaTwo()
			}
		}
	}
	@ViewBuilder
	func thaTwo() -> some View {
		Text(label)
			.padding(.horizontal, -3)
			.padding(.vertical, -0)
		TextField("", value: $localVal, formatter:formatter) {
			val = localVal  // Editing done, notify rest of world
		}
		.frame(width: 35)
		.onAppear {
			localVal = val  // Initialize the local value with the bound value
		}
		.onChange(of: val) { oldValue, newValue in
			localVal = newValue  // Sync local copy when binding changes externally
		}
		.padding(.horizontal, -3)
	}
}								//
struct LabeledCGFloat0: View {			// 0: orig PW
	var label					: String				// arg1:
	@Binding var val			: CGFloat				// arg2:
	var oneLine					= true					// arg3:
	var formatter : NumberFormatter = d2formatter		// arg4:
	var body: some View {
		if oneLine {
			Text(label)
				.padding(.horizontal, -3)
			TextField("", value:$val, formatter:formatter)
				.frame(width:35)
				.padding(.horizontal, -3)
		} else {
			VStack {
				Text(label)
					.padding(.horizontal, -3)
					.padding(.vertical, -10)
				TextField("", value:$val, formatter:formatter)
					.frame(width:35)
					.padding(.horizontal, -3)
			//		.keyboardType(.decimalPad) // Ensure decimal input for floats
			}
		}
	}
}

//class ViewModel: ObservableObject {
//	var numberString: String = ""
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
