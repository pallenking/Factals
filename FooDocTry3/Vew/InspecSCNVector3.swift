//  InspecSCNVector3.swift -- ©2021PAK
//

import SwiftUI
import SceneKit

@propertyWrapper struct FooTrimmed<Value> {
//	@state private var valueString = ""
	private(set) var value:Value

	var wrappedValue:Value {
		get		{ value }
		set(v)	{ value 	= v }
	}
	init(value:Value) {
		self.value	= value
	}
}

struct InspecSCNVector3opt : View {
	@Binding var vect3:SCNVector3?
	//@ObservedObject var net: Net
    var body: some View {
		if vect3 != nil {
			InspecSCNVector3(vect3:.init(
				get: { 			vect3!											},
				set: { (v) in	vect3 = v										}))
		}
		else {
			Button(action: {
				vect3			= .zero
			}) {
				Text("minSize:nil")
			}
		}
	}
}

struct InspecSCNVector3: View {
	@Binding var vect3:SCNVector3

    var body: some View {
		let formatter = NumberFormatter()
		HStack {
	        TextField("x", value:$vect3.x, formatter:formatter).frame(width:40)
	        TextField("y", value:$vect3.y, formatter:formatter).frame(width:40)
	        TextField("z", value:$vect3.z, formatter:formatter).frame(width:40)
		}
    }
}

var vect33:SCNVector3 = .zero
struct Inspec4SCNVector3_Previews: PreviewProvider {
    static var previews: some View {
//        InspecSCNVector3(vect3:$vect33)
      InspecSCNVector3(vect3:.constant(SCNVector3.zero))
    }
}
