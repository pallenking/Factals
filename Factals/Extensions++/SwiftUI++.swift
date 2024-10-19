//
//  SwiftUI++.swift
//  Factals
//
//  Created by Allen King on 7/22/22.
//

import SwiftUI

extension Button {

	init(label: () -> Label, action:@escaping () -> Void){
		self.init(action:action, label:label)
	}


}
