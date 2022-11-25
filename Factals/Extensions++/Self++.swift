//
//  Self++.swift
//  SwiftFactals
//
//  Created by Allen King on 1/15/21.
//  Copyright © 2021 Allen King. All rights reserved.
//

import Foundation

//https://stackoverflow.com/questions/42746981/list-all-subclasses-of-one-class

func subclasses<T>(of theClass: T) -> [T] {
	var count: UInt32 = 0, result: [T] = []
	let allClasses = objc_copyClassList(&count)!
	let classPtr = address(of: theClass)

	for n in 0 ..< count {
		let someClass: AnyClass = allClasses[Int(n)]
		guard let someSuperClass = class_getSuperclass(someClass), address(of: someSuperClass) == classPtr else { continue }
		result.append(someClass as! T)
	}

	return result
}
public func address(of object: Any?) -> UnsafeMutableRawPointer{
	return Unmanaged.passUnretained(object as AnyObject).toOpaque()
}
