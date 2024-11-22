// InspecBase.swift -- Basic Inspec.View, without Parts ©2020PAK
// In Hungarian Notation (:H:):   BASICJ(=I++)NSPECtorView
/* To Do:
	1. make proper connections
	2. Jinspec's don't go away if new one replaces
	3. remember window places of Jnpsec's
	//https://www.hackingwithswift.com/plus/intermediate-swiftui/creating-a-custom-property-wrapper-using-dynamicproperty
*/
import SceneKit
import SwiftUI

struct InspectorsVew: View {
	@ObservedObject var vewBase:VewBase
	var body: some View {
		let _ 					= Self._printChanges()
		
		VStack {
			ForEach(vewBase.inspectedVews, id: \.self) { vew in
				Group {
					HStack(alignment:.top) {
						let i = vewBase.inspectedVews.firstIndex(of: vew)!
						Inspec(vew:vew, index:i)
					}
				}
			}
		}
	}
}

 // MAIN ENTRY POINT:
struct Inspec: View, Equatable, Uid {
	@ObservedObject var vew:Vew			// arg1: object to be inspected.
	var index:Int				= 0		// arg2:
	var nameTag					= getNametag()

	static func == (lhs: Inspec, rhs: Inspec) -> Bool {
		lhs.nameTag == rhs.nameTag
		&& lhs.vew === rhs.vew
	}

	var body: some View {
		VStack(alignment:.leading)  {	// Add Class Inspectors
			HStack {
				Text("\(index)").bold().foregroundColor(.red)
				Text(": Location")
				Text(vew.part.fullName)
					.bold().foregroundColor(.red) //.font(.system(size:12) //.frame(maxWidth:.infinity)
					.onChange(of: vew.part.fullName) { oldValue, newValue in
						print("newValue: \(newValue)")
					}
				Spacer()
				Button(label:{ Text("x") }) {
					guard let vewBase = vew.vewBase() else { print("couldn't find vewBase()"); return }
					vewBase.removeInspector(forVew: vew)
				}
			}
								
		//	var first = true
			let inheritedClasses:[String] = vew.part.inheritedClasses()	 //["Net"]//
			ForEach (inheritedClasses, id:\.self) { subClass in
				inspectionViewBuilder(subClass:subClass)
		//		var first = false
			}
		//	ColorsPalette()
		//	PickerStyles()
		//	InspecTest(inspec:inspec)
		}
		.padding(10)
		.border(Color.black, width:1)
	}
	@ViewBuilder
	func inspectionViewBuilder(subClass:String) -> some View {
				 // Dispatch via switch
		switch subClass {
			case "Net":		  InspecNet(			  net:vew.part as! Net)
				
			case "Bulb": 	  InspecBulb(			 bulb:vew.part as! Bulb)
			case "Sequence":  InspecSequence(	 sequence:vew.part as! Sequence)
			case "KNorm": 	  InspecKNorm(			kNorm:vew.part as! KNorm)
			case "Multiply":  InspecMultiply(	 multiply:vew.part as! Multiply)
			case "Hamming":   InspecHamming(	  hamming:vew.part as! Hamming)
			case "Bayes":	  InspecNothing(	className:subClass)
			case "MinAnd": 	  InspecMinAnd(		   minAnd:vew.part as! MinAnd)
			case "MaxOr": 	  InspecMaxOr( 			maxOr:vew.part as! MaxOr)
			case "Broadcast": InspecBroadcast(	broadcast:vew.part as! Broadcast)
				
			case "Splitter":  InspecSplitter(    splitter:vew.part as! Splitter)
			case "Mirror":	  InspecMirror(		   mirror:vew.part as! Mirror)
			case "Atom":	  InspecAtom(	  	     atom:vew.part as! Atom, vew:vew)
				
		//	case "PartBase":  InspecRootPartBase(   parts:vew.part as! PartBase, vew:vew)
				
			case "Box":		  InspecNothing(className:subClass)
			case "CommonPart":InspecCommonPart(commonPart:vew.part as! CommonPart)
			case "Port":	  InspecPort(		     port:vew.part as! Port)
			case "Part":	  InspecPart(		     part:vew.part, vew:vew)
			default:		  InspecUndefined(className:subClass)
		}
	}
}

 // // // 3. Debug switch to select Previews:
// let inspectedPreview			= Vew(forPort:Port())	// 1. HNW Parts

struct InspecTest : View {
	@State private var placeSelfy 			= "placeSelfy"
//	@Binding private var placeSelfy 		= repD3View.part.placeMy
//  @ObservedObject private var placeSelfy	= repD3View.part.placeMy

	@State private  var indexStr : String 	= "0"
//	let indexInt 							InspecCommonPart= 0
	let indexInt 							= 0

	@State private  var score				= 0

	@ObservedObject var inspec:Vew
	var body: some View {
		HStack {
			ClassBox(labeled:"Test")
			Spacer()

			//Text("<<\(repD3View.part.config("placeMy"))>>")
			/// WHY: Instance method 'appendInterpolation(_:formatter:)' requires that 'FwAny?' inherit from 'NSObject'
			TextField("placeSelfy", text:$placeSelfy).frame(width:40)
//				.textFieldStyle(RoundedBorderTextFieldStyle)	/// BROKEN
				.onChange(of:placeSelfy) { newVal in 	// min 35: https://www.youtube.com/watch?v=uitE6bmeFxM
					print("placeSelfy: \(placeSelfy)  --> \(newVal)")
				}

			/// A WORKS
			Button(action: {
				score += 1
				//print("=== A:\(score)")
			}) {
				Text("A:\(score)++")
			}
			Text("A=\(score)")

			/// B DOESN'T CAUSE UPDATE
//			Button(action: {
//				scaffolding.score += 1
//				//print("=== B:\(scaffolding.score)")
//			}) {
//				Text("B:\(scaffolding.score)++")
//			}
//			Text("B=\(scaffolding.score)")			//

			Text("indexStr=\(indexStr)")
			TextField("index", text:$indexStr).frame(width:20)
		//	Text("IndexInt: \(indexInt)")
		//	Text("Score: \(scaffolding.score)")
//			Text("xxx \(placeSelfy)")

			  /// WHY: No inheritance, Opaque/concrete, code inheritance myself
			 /// Access struct in global namespace: BAD no structFrom(string:)
			//let newStruct : AnyStruct = structFrom(string:cl)

			  /// Want hash, array, closure returning of View's:
			 /// WHY: no typealias?
			//	typealias InspecVFactory = (D3View?) -> View	//Int//
			 /// WHY: not from array, hash?
			//		let str2SuiView = [			// works if all are same InspecSplitter
			//			"Part":		{ 	return  InspecSplitter( repD3View:$0 ) 		},
			//			"Atom":		{	return  InspecSplitter( repD3View:$0 ) 		},
			//		]
			//if let clV	= str2SuiView[cl], // @escaping @callee_guaranteed (@in_guaranteed Optional<D3View>) -> (@out Any)
			//  let clV2	= clV as? InspecVp {//partSuiView {//
			//	clV2(repD3View)
			//}

			 /// WHY: Type '()' cannot conform to 'View'; only struct/enum/class types can conform to protocols
			//if repD3View != nil {	print("")	}
		}
	}
}
struct InspecUndefined : View {
	var className:String
	var body: some View {
		HStack {
			ClassBox(labeled:className)
			Spacer()
			Text("<< Under Construction >>").padding(2).background(Color.yellow)
		}
	}
}
struct InspecNothing : View {
	var className:String
	var body: some View {
		Text(className).font(.custom("", size:9))
	}
}


struct ClassBox : View {
	let labeled: String						// arg1
	var isFirst:Bool = false				// arg2
	var body: some View {
		let color:Color = isFirst ? .red : .black
		Text(labeled)
			.foregroundColor(color)		//	.font(.custom("", size:12))
			.bold()
			.padding(3)
			.background(
				RoundedRectangle(cornerRadius: 5)
				.stroke())//.fill(Color.pink))
	}
}
struct ColorsPalette : View {
	var body: some View {
		HStack {
			ClassBox(labeled:"ColorsPalette")
			Text("primary")  .padding(5).background(Color.primary).foregroundColor(.white)
		//	Text("secondary").padding(5).background(Color.secondary).foregroundColor(.white)
			Text("black")    .padding(5).background(Color.black).foregroundColor(.white)

			Text("red")      .padding(5).background(Color.red)
			Text("orange")   .padding(5).background(Color.orange)
			Text("yellow")   .padding(5).background(Color.yellow)
			Text("green")    .padding(5).background(Color.green)
			Text("blue")     .padding(5).background(Color.blue)
			Text("purple")   .padding(5).background(Color.purple)
			Text("white")    .padding(5).background(Color.white).foregroundColor(.black)
//			Text("clear")    .padding(5).background(Color.clear)
		}
	}
}


struct PickerStyles : View {
	func indChange(_ tag: Int) {
		print("ind tag: \(tag)")
	}
	@State private var ind = 0
	{	didSet { print("ind=\(ind)")}											}

	var body: some View {
		HStack {
			ClassBox(labeled:"PickerStyles")
/*
	func colorChange(_ tag: Int) {
		print("Color tag: \(tag)")
	}        Picker(selection: $favoriteColor.onChange(colorChange), label: Text("Color")) {
*/
//			Picker<Text, SelectionValue: Hashable, TupleView<(some View, some View)>>
//				(" ", selection:$ind.onChange(indChange)) {
//			Picker(" ", selection:$ind.onChanged(indChange())) {
			Picker(selection: $ind, label:Text("Status")) {			//.onChanged(indChange)
				Text("aa").tag(1)
				Text("bb").tag(2)
			}													.frame(width:130)
			Picker("Menu", selection:$ind) {
				Text("aa").tag(1)
				Text("bb").tag(2)
			}.pickerStyle(MenuPickerStyle())					.frame(width:130)
			Picker("Default", selection:$ind) {
				Text("aa").tag(1)
				Text("bb").tag(2)
			}.pickerStyle(DefaultPickerStyle())					.frame(width:130)
			Picker("Radio", selection:$ind) {
				Text("aa").tag(1)
				Text("bb").tag(2)
			}.pickerStyle(RadioGroupPickerStyle())				.frame(width:130)
			Picker("Seg", selection:$ind) {
				Text("aa").tag(1)
				Text("bb").tag(2)
			}.pickerStyle(SegmentedPickerStyle())				.frame(width:130)
// 'WheelPickerStyle' is unavailable in macOS:
//			Picker("Wheel", selection:$ind) {
//				Text("aa").tag(1)
//				Text("bb").tag(2)
//			}.pickerStyle(WheelPickerStyle())					.frame(width:130)
		}
	}
}
