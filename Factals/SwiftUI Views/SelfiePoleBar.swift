//
//  SelfiePoleBar.swift
//  Factals
//
//  Created by Allen King on 2/19/23.
//

import SwiftUI
import SceneKit

struct SelfiePoleBar: View   {													//xyzzy15.5
	@Bindable var vewBase: VewBase

	private var selfiePole: SelfiePole { vewBase.selfiePole }

	var body: some View {
		HStack {
			VStack {
				Text("SelfiePole")	//.bold()	//.foregroundColor(.red)
				Text("id:\(selfiePole.pp(.nameTag))")
			}
			HStack {
	//			VStack {
	//				Text("SelfiePole").bold().foregroundColor(.red)
	//				Text("id:\(selfiePole.pp(.nameTag))")
	//			}
				InspecSCNVector3(label:"position", vect3:$vewBase.selfiePole.position, oneLine:false)
				LabeledCGFloat(label:"spin", val:$vewBase.selfiePole.spin, oneLine:false)
				LabeledCGFloat(label:"gaze", val:$vewBase.selfiePole.gaze, oneLine:false)
				LabeledCGFloat(label:"zoom", val:$vewBase.selfiePole.zoom, oneLine:false)
				VStack {
					Button(label:{	Text("+")									})//.padding(.top, 300)
					{	vewBase.selfiePole.zoom	/= 1.1  // + zooms in (closer)
						updateCameraFromUI()
						print("======== \(selfiePole.pp(.tagClass)) z=\(selfiePole.pp(.line))")
					}
					Button(label:{	Text("-")									})//.padding(.top, 300)
					{	vewBase.selfiePole.zoom	*= 1.1  // - zooms out (farther)
						updateCameraFromUI()
						print("======== \(selfiePole.pp(.tagClass)) z=\(selfiePole.pp(.line))")
					}
				}
				LabeledCGFloat(label:"ortho",val:$vewBase.selfiePole.ortho, oneLine:false)
				VStack {
					Button(label:{	Text("/\\")										})//.padding(.top, 300)
					{	let values		= [0.0, 0.1, 1.0, 10]
						let i	 		= values.firstIndex(where: { $0 >= selfiePole.ortho } ) ?? values.count
						vewBase.selfiePole.ortho = values[(i+1) % values.count]
						updateCameraFromUI()  // Update camera projection
						print("======== \(selfiePole.pp(.tagClass)) o=\(selfiePole.ortho.pp(.line))")
					}
					Button(label:{	Text("-<")										})
					{	resetSelfiePole()
						print("======== SelfiePole RESET to fill screen")
					}
				}
			}
			.onChange(of:vewBase.selfiePole.zoom) {
				//print(".onChange(of:selfiePole.zoom:",$0, $1)
				updateCameraFromUI()  // Update camera when zoom changes from any UI source
			}
			.background(Color(red:1.0, green:0.9, blue:0.9))	// pink
			.frame(maxWidth:.infinity)
		}	// .padding(6)
	}

	private func updateCameraFromUI() {
		// Directly update camera when UI controls change selfiePole
		if let scnView 			= vewBase.headsetView as? ScnView {
			scnView.updateCamera(from: vewBase.selfiePole)
		}
	}

	private func resetSelfiePole() {
		// Reset SelfiePole to default view that fills the screen
		vewBase.selfiePole.position = SCNVector3(0, 0, 0)
		vewBase.selfiePole.spin = 0.0
		vewBase.selfiePole.gaze = 0.0  // Slight downward angle
		vewBase.selfiePole.zoom = 0.3
		vewBase.selfiePole.ortho = 0.0  // Perspective mode
		updateCameraFromUI()
	}
}

////FloatingPoint
////BinaryFloatingPoint
//
//			if let o 			= selfiePole.ortho {
//				TextField("Number", value: $number, format: .number)
//				 .keyboardType(.decimalPad)
//				Button("Submit") {			/* use the optional CGFloat here*/			}
//				.onSubmit(of: .continue) {	/* use the optional CGFloat here*/	}
//				TextField("ortho", text:$selfiePole.ortho, onCommit: {
//				TextField.init(_:  text:onEditingChanged:). Use View.onSubmit(of:_:) for functionality previously provided by the onCommit parameter. Use FocusState<T> and View.focused(_:equals:) for functionality previously provided by the onEditingChanged parameter.")
//					if let newValue = NumberFormatter().number(from: floatString)?.doubleValue {
//						selfiePole.ortho = CGFloat(newValue)
//					} else {
//						selfiePole.ortho = nil
//					}
//				})
//				LabeledCGFloat(label:"ortho", val:$selfiePole.ortho, oneLine:false)
//			} else {
//				Button("nil") {}
//			}
