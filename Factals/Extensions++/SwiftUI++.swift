//
//  SwiftUI++.swift
//  Factals
//
//  Created by Allen King on 7/22/22.
//

import SwiftUI

extension Button {
	init(label: @escaping () -> Label, action:@escaping () -> Void){
		self.init(action:action, label:label)
	}
//	init(label: @escaping () -> Label, action:@escaping () -> Void){
//		self.init(action:action, label:label)				//.color(.red)
//	}
 //	init(label: () -> Label, action: @escaping () -> Void) {
 //		self.init(action:action, label:
 //			label()
 //				.padding()
 //				.background(Color.blue.opacity(0.5)) // Light blue background
 //				.cornerRadius(8)
 // //				.foregroundColor(.white) // Text color
 //		)}
 //	}
}
