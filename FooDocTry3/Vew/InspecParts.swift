// InspecParts.swift -- Inspector Views for HNW Part subviews ©2020PAK
// Hungarian Notation (:H:):INSPECtorview

import SceneKit
import SwiftUI

struct InspecNet : View {												  // Net
	@ObservedObject var net: Net
//	@FooTrimmed<SCNVector3> var x = SCNVector3(3,4,5)

	var body: some View {
		HStack {
			ClassBox(labeled:"Net")
			Spacer()
					// MinSize:
			if net.minSize != nil {
				Button(action: {
					net.objectWillChange.send()
					net.minSize = nil
				}) {
					Text("minSize:")
				}
				InspecSCNVector3(vect3:.init(
					get: { 			net.minSize ?? .zero						},
					set: { (v) in	net.minSize = v								}))
			}
			else {
				Button(action: {
					net.objectWillChange.send()
					net.minSize = SCNVector3(30,30,30)//.zero
				}) {
				Text("")
					Text("minSize:nil")
				}
			}
		}
	}
}
struct InspecBulb : View {												 // Bulb
	@ObservedObject var bulb:Bulb
	var body: some View {
		HStack {
			ClassBox(labeled:"Bulb")
			Spacer()

			TextField("", value:$bulb.gain, 		 formatter:d2formatter).frame(width:50)
			TextField("", value:$bulb.offset, 		 formatter:d2formatter).frame(width:50)
			TextField("", value:$bulb.currentRadius, formatter:d2formatter).frame(width:50)
		}
	}
}
struct InspecSequence : View {										 // Sequence
	@ObservedObject var sequence:Sequence
	var body: some View {
		HStack {
			ClassBox(labeled:"Sequence")
			Spacer()
		}
	}
}
struct InspecKNorm : View {												// KNorm
	@ObservedObject var kNorm:KNorm
	var body: some View {
		HStack {
			ClassBox(labeled:"KNorm")
			Spacer()
		}
	}
}
struct InspecMultiply : View {										 // Multiply
	@ObservedObject var multiply:Multiply
	var body: some View {
		HStack {
			ClassBox(labeled:"Multiply")
			Spacer()
		}
	}
}
struct InspecHamming : View {										  // Hamming
	@ObservedObject var hamming:Hamming
	var body: some View {
		HStack {
			ClassBox(labeled:"Hamming")
			Spacer()
		}
	}
}
struct InspecBayes : View {												// Bayes
	@ObservedObject var bayes:Bayes
	var body: some View {
		HStack {
			ClassBox(labeled:"Bayes")
			Spacer()
		}
	}
}
struct InspecMaxOr : View {											    // MaxOr
	@ObservedObject var maxOr:MaxOr
	var body: some View {
		HStack {
			ClassBox(labeled:"MaxOr")
			Spacer()
//			TextField("", value:$maxOr.pipeRadius, formatter:d2formatter).frame(width:50)
//			TextField("", value:$maxOr.ringRadius, formatter:d2formatter).frame(width:50)
		}
	}
}
struct InspecMinAnd : View {										   // MinAnd
	@ObservedObject var minAnd:MinAnd
	var body: some View {
		HStack {
			ClassBox(labeled:"MinAnd")
			Spacer()
		}
	}
}
struct InspecBroadcast : View {										// Broadcast
	@ObservedObject var broadcast:Broadcast
	var body: some View {
		HStack {
			ClassBox(labeled:"Broadcast")
			Spacer()
			//Text("InspecBroadcast").background(Color.yellow)
		}//.padding(15).background(Color.yellow)	//blue
	}
}

struct InspecSplitter : View {										 // Splitter
	@ObservedObject var splitter:Splitter
	var body: some View {
		HStack {
			ClassBox(labeled:"Splitter")
			Spacer()
			Text(splitter.onlyPosativeWinners ? "win>0"  : "allWin")
			Text(splitter.isBroadcast 		  ? "isBcast" : "!Bcast")
			Text("a1:")
			TextField("",  value:$splitter.a1,			formatter:d2formatter).frame(width:50)
			switch splitter.combineWinner {
			case 0:										//  0	no winner yet declared
				Text("no wnr:").background(Color.yellow)
			case -1:			// <0 segfaults			// -1	proportional sharing
				Text("proportional:").background(Color.yellow)
			default:									// >S	Winning Share
				TextField("", value:$splitter.combineWinner, formatter:d2formatter).frame(width:50)
			}
		}//.padding(15).background(Color.yellow)
	}
}
struct InspecMirror : View {										   // Mirror
	@ObservedObject var mirror: Mirror
	var body: some View {	// empty, nothing inspectable
		let fwActivationFormatter = { () -> NumberFormatter in
			let rv 				= NumberFormatter()
			rv.minimumFractionDigits = 2
			return rv
		} ()
		HStack {
			ClassBox(labeled:"Mirror")
			Spacer()
			Text("gain")
			TextField("gain", value:$mirror.gain, formatter:fwActivationFormatter).frame(width:50)
			Text("offset")
			TextField("offset", value:$mirror.offset, formatter:fwActivationFormatter).frame(width:50)
		}
	}
}
struct InspecAtom : View {												 // Atom
	@ObservedObject var atom: Atom
	@ObservedObject var vew:Vew				// For Inspec navigation

    @State private var bgColor = Color.white

	var body: some View {	// empty, nothing inspectable
		HStack {
			ClassBox(labeled:"Atom")
			Spacer()
			if atom.ports.count > 0 {
				Text("Ports:")
				Picker("", selection:Binding<String>(	get:{ "" }, set:{		// Always out of range
					let port	= atom.ports[$0]!
					let newVew	= rootVewL.find(part:port, inMe2:true) ?? vew
bug//				atom.root?.fwDocument?.showInspecFor(vew:newVew, allowNew:false)
//					DOc.showInspecFor(vew:newVew, allowNew:false)
				} )) {
					ForEach(Array(atom.ports.keys.enumerated()), id:\.element) { _, key in
						Text(key)
					}
				} 												.frame(width:30)
			}else{
				Text("No Ports")
			}
			/*
			vew.scn.color0 		= c			// in SCNNode, material 0's reflective color
			*/
//			ColorPicker("Color:", selection: $vew.scn.color0)
			ColorPicker("Band Color:", selection: $bgColor)
		}
/*
	var proxyColor: NSColor?	= nil
	var postBuilt				= false		// object has been built
	var bindings : [String : String]? = nil	// a map of names to internal Ports.
*/
	}
}

struct InspecRootPart : View {										 // RootPart
	@ObservedObject var rootPart:RootPart
	@ObservedObject var vew:Vew				// For Inspec navigation

	var body: some View {	// empty, nothing inspectable
		VStack {
			HStack {			// Simulator
				ClassBox(labeled:"RootPart")
				Spacer()
				Text("Logger")
				Text("Time")
				Text("Break")
				Text("LogEvents")
				Text("LogTime")
			}
			HStack {			// Simulator
				Spacer()
				Text("velocity")
				Text("")
				Text("")
				Text("")
				Text("")
			}
//			HStack {			// Simulator
//				Text("Volume")
//				Slider(
//					value: $rootPart.foo,
//					in: 0...100,
//					onEditingChanged: { editing in }
//				//	label:Text("sss")
//				).frame(width:50)
//			}
		}
	}
}

struct InspecCommonPart : View {								   // CommonPart
	@ObservedObject var commonPart: CommonPart
	var body: some View {	// empty, nothing inspectable
		HStack {
			ClassBox(labeled:"CommonPart")
			Spacer()
			Text("size")
			InspecSCNVector3(vect3:$commonPart.size)
		}
	}
}
struct InspecPort : View {												 // Port
	@ObservedObject var port: Port
//	@Binding<get:{ return ""}, set:{}> valueString : String
 //	@Binding<Float> var x = inspec.part as? Port.value

//	static let taskDateFormat: DateFormatter = {
//		let formatter = DateFormatter()
//		formatter.dateStyle = .long
//		return formatter
//	}()
//	var dueDate = Date()

	var body: some View {
//		let formatter			= { () -> NumberFormatter in
//			let rv 				= NumberFormatter()
//			rv.minimumFractionDigits = 2
//			return rv
//		} ()
		HStack {
			ClassBox(labeled:"Port")
			 // Somewhat misguided:
			//Toggle(isOn: $port.noCheck) {
			//	Text("noChk")
			//}.background(Color.yellow) //										.frame(width:50)
			//Toggle(isOn: $port.dominant) {
			//	Text("dom")
			//}.background(Color.yellow) //										.frame(width:50)

			Text("out:")
			TextField("v", value:$port.value, formatter:d2formatter).frame(width:50)

			Spacer()
			if let x 		= port.connectedTo {
				Text("->")
				Text(x.fullName)
				 // THIS IS OUTSIDE PANEL!!!
				TextField("w", value:$port.con2ib.value, formatter:d2formatter).frame(width:50)
				Text(":in")

			//	TextField("in", value:$port.con2ib.value, formatter:formatter).frame(width:50)
			//	Text("\(port.connectedTo?.value ?? -42, specifier: "%.2f")").background(Color.yellow)
			}else{
				Text("Unconnected")
			}
		}
	}
}
struct InspecPart : View {												 // Part
	@ObservedObject var part:Part
	@ObservedObject var vew:Vew				// For Inspec navigation

	@State private var placeSelfy = "placeSelfy"		//	@Binding private var placeSelfy = repD3View.part.placeMy // @ObservedObject private var placeSelfy = repD3View.part.placeMy
		//https://medium.com/better-programming/three-ways-to-react-to-state-changes-in-swiftui-a30545c72361

	var body: some View {
		VStack {
			HStack {						// ========================== LINE 1
				ClassBox(labeled:"Part")
				Spacer()

				 // Flip:
				Toggle(isOn: $part.flipped) {
					Text("flip")
				}													.frame(width:50)
				 // Latitude:
				Picker("lat:", selection:$part.lat) {
					ForEach(Latitude.allCases, id:\.self) { lat in
						Text(Latitude.latitude2string[lat.rawValue]).tag(lat.rawValue)
					}
				}.pickerStyle(MenuPickerStyle()).frame(width:130)				//MenuPickerStyle//SegmentedPickerStyle//

						// --- Navigate:
				let navList		= part.selfNParents.reversed() + part.children
				let selfIndex	= part.selfNParents.count - 1
				Text("Inspect:")
				Picker("", selection:Binding<Int>(	get:{ -1 }, set:{		// Always out of range
					let nav		= navList[$0]					// Set notification
					let newVew	= rootVewL.find(part:nav, inMe2:true) ?? vew
//					part.root!.fwDocument!.showInspecFor(vew:newVew, allowNew:false)
					DOC.showInspecFor(vew:newVew, allowNew:false)
				} ) ) {
 					ForEach(navList, id:\.self) { aPart in
						let ind = navList.firstIndex(of:aPart)!
						let label = ind <  selfIndex ? "/ \(aPart.name)" :
									ind == selfIndex ? "- \(aPart.name)" :
													  "\\ \(aPart.name)"
						Text(label).tag(ind)
					}
				}												.frame(width:30)
			}
			HStack {						// ========================== LINE 2

				 // Initial Display Mode:
				Picker("expose", selection:$vew.expose) {
					ForEach(Expose.allCases, id:\.self) { expose in
						if expose != .null {
							Text(expose.pp(.name, [:])).tag(expose.rawValue)
						}
					}
				}.pickerStyle(MenuPickerStyle()).frame(width:120)				//.background(Color.yellow)//MenuPickerStyle//SegmentedPickerStyle//

//				 // Place:
//				Text("place")//=\(inspec.part.configPlaceSelf)		.frame(width:40)
//				TextField("placeSelf", text:$part.configPlaceSelf)
//								.padding(2).background(Color.yellow)//.frame(width:70)
				Spacer()

				 // Dirty:
				Picker("", selection:$part.dirty) {	// \(inspec.part.dirty.rawValue)
					ForEach(DirtyBits.allCases, id:\.self) { dBits in
						let n	= dBits == .clean ? "clean" : "dirty " + dBits.pp()
						Text(n).tag(dBits.rawValue)
					}
				}												.frame(width:100)
				 // Spin:
				Text("spin")							//(=\(inspec.part.spin))
				Button(action: {
					part.spin	= (part.spin + 1) % UInt8(Part.spinMax)
					part.markTree(dirty:.size)	// resize
				}) {
					Text("\(part.spin)")
				}
				 // ReView:
				Button(action: {
					part.objectWillChange.send()
				}) {
					Text("ReView")
				}
			}
		}
	}
}
