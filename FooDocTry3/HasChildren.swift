//
//  HasChildren.swift
//  FooDocTry3
//
//  Created by Allen King on 6/9/22.
//

import Foundation

protocol HasChildren : Equatable {		//NSObject : BinaryInteger
	associatedtype T where T : Equatable
	associatedtype TRoot
	typealias ValidationClosure = (T) -> T?

	var name		: String	{	get	set		}
	var children 	: [T]		{	get	set		}
	var parent		:  T?		{	get	set		}		/*weak*/

	 // Helpers
	var root		:  TRoot?	{	get	set		}
	var child0	 	:  T?		{	get 		}
	var fullName	: String	{	get			}

	// MARK: - 4.2 Manage Tree
	/// Add a child part
	/// - Parameters:
	///   - child: child to add
	///   - index: index to added after. >0 is from start, <=0 is from start, nil is at end
	/// dirtyness of child is inhereted by self
	func addChild(_ child:T?, atIndex index:Int?) 										// (child is not dirtied any more)
	func removeChildren()

	var parents : [T] 			{	get			}
	 /// Ancestor array starting with self
	var selfNParents : [T]	 	{	get			}
	/// Ancestor array, from self up to but excluding 'inside'
	func selfNParents(upto:T?) -> [T]

	func find<T>(inMe2:Bool, all:Bool, maxLevel:Int?, except:T?, firstWith:ValidationClosure) -> T?
}

// MARK: Parents
extension HasChildren {

	 /// Ancestor array starting with parent
	var parents : [T] {
		var rv 		 : [T]		= []
		var ancestor :  T?		= parent
		while ancestor != nil {
			rv.append(ancestor!)
			ancestor 			= nil//ancestor!.parent
		}
		return rv
	}
	 /// Ancestor array starting with self
	var selfNParents : [T] {
		return selfNParents()
	}
	 /// Ancestor array, from self up to but excluding 'inside'
	func selfNParents(upto:T?=nil) -> [T] {
		var rv 		 : [T]		= []
		var ancestor :  T?		= Self.self as? Self.T		//???
		while ancestor != nil, 			// ancestor exists and
			  ancestor! != upto  {		// not at explicit limit
//		  ancestor!.name != "ROOT" {
			rv.append(ancestor!)
			ancestor 			= nil//ancestor!.parent
		}
		return rv
	}
}

// MARK: Searching
extension HasChildren {

		/// find if closure is true:
	func find<T>(inMe2 searchSelfToo:Bool=false, all searchParent:Bool=false, maxLevel:Int?=nil, except exception:T?=nil,
			  firstWith closureResult:ValidationClosure) -> T?
	{
		 // Check self:
		if let selfT			= self as? T,	// Why needed? E Better way?
		  searchSelfToo,
		  closureResult(selfT) != nil {		// Self match
			return selfT
		}
		if (maxLevel ?? 1) > 0 {			// maxLevel1: 0 nothing else; 1 immediate children; 2 ...
			let mLev1			= maxLevel != nil ? maxLevel! - 1 : nil
			 // Check children:
			//?let orderedChildren = upInWorld ? children.reversed() : children
			for child in children { //where child != exception! {	// Child match
				fatalError()
				if let sv		= child.find(inMe2:true, all:false, maxLevel:mLev1, firstWith:closureResult) {
					return sv
				}
			}
		}
		 // Check parent
		if searchParent {
//			return parent?.find(inMe2:true, all:true, maxLevel:maxLevel, except:self, firstWith:closureResult)
		}
		return nil
	}
																				//	@objc dynamic
																				//	var fullName	: String	{
																				//		let rv					= name=="ROOT"  ? 		   name :	// Leftmost component
																				//								  name=="_ROOT" ? 		   name :	// Leftmost component
																				//								  parent==nil  ? "" :
																				//								  parent!.fullName + "/" + name		// add lefter component
																				//		return rv
																				//	}
}
