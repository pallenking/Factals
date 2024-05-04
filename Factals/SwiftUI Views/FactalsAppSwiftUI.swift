////
////  FactalsAppSwiftUI.swift
////  Factals
////
////  Created by Allen King on 4/15/24.
////
//		Attempt to carve out the SuiftUI portions

//import Foundation
//import SwiftUI
//@main
//extension FactalsApp : App {
//	 // MARK: - SwiftUI
//	var body: some Scene {
//		DocumentGroup(newDocument:FactalsDocument()) { file in
//			ContentView(document: file.$document)
//			 .environmentObject(factalsGlobals)	// inject in environment
//			 .onOpenURL { url in					// Load a document from the given URL
//				let _ = FactalsDocument(fileURL:url)/*.retainIn($openDocuments)*/
//			}
//		}
//		 .commands {
//			CommandMenu("Library") {
//				ForEach(factalsGlobals.libraryMenuTree.children) { crux in
//					menuView(for:crux)
//				}
//			}
//		}
//	}
////}		//??Flock
////extension FactalsApp : App {
//	 // MARK: - Library Menu							 (RECIRSIVE)
//	func menuView(for crux:LibraryMenuTree) -> AnyView {
//		if crux.children.count == 0 {				// Crux has nominal Button
//			return AnyView(
//				Button(crux.name) {
//					@Environment(\.newDocument) var newDocument
//					newDocument(FactalsDocument(fromLibrary:"entry\(crux.tag)"))
//				}
//			)
//		}
//		return AnyView(
//			Menu(crux.name) {
//				ForEach(crux.children) { crux in
//					menuView(for:crux)					// ### RECURSIVE ###
//				}
//			} primaryAction: {
//				print("lskjvowijhiv")
//			}
//		)
//	}
//}								//
// // MARK: - Globals
//extension FactalsApp {		// FactalsGlobals
//	public class FactalsGlobals : ObservableObject {				// (not @Observable)
//		// MARK: -A Configuration
//		@Published var factalsConfig : FwConfig
//
//		// MARK: -B Library Menu:
//		var libraryMenuTree : LibraryMenuTree = LibraryMenuTree(name: "ROOT")
//		init(factalsConfig a:FwConfig, libraryMenuArray lma:[LibraryMenuArray]?=nil) {
//			factalsConfig 		= a
//			let libraryMenuArray = lma ?? Library.catalog().state.scanCatalog
//			let tree 			= LibraryMenuTree(array:libraryMenuArray)	 //LibraryMenuArray
//			libraryMenuTree 	= tree
//			//var catalogs:[LibraryMenuArray] = catalogs//[] // Library.catalog().state.scanCatalog.count == 0
// 		}
//	}
//}
//class LibraryMenuTree : Identifiable {		// of a Tree
//	let id						= UUID()
//	let name: String
//	var imageName: String? = nil
//	var tag						= -1
//	var children = [LibraryMenuTree]()
//	init(name n:String, imageName i:String?=nil) {
//		name 					= n
//		imageName 				= i
//		children 				= []
//	}
//	init(array entries:[LibraryMenuArray]) {
//		name					= "ROOT"
//		
//		for entry in entries { //entries[0...100]//
//			let path 			= entry.parentMenu
//			guard path.prefix(1) != "-" else  { 	continue 	}	// Do not create library menu
//			
//			// Make (or find) in the tree  the crux of path
//			var crux:LibraryMenuTree = self		// Slide crux from self(root) to spot to insert
//			for name in path.split(separator:"/") {
//				crux			= crux.children.first(where: {$0.name == name}) ?? {
//					let newCrux	= LibraryMenuTree(name:String(name), imageName: "1.circle")
//					crux.children.append(newCrux)
//					// print("---- added crux:\"\(name)\"")
//					return newCrux
//				}()
//			}
//			
//			// Make new menu entry:
//			//		print("-------- adding tag:\(test.tag) title:\"\(test.title.field(-54))\"     to menu:\"\(test.parentMenu)\"")
//			let newCrux			= LibraryMenuTree(name:entry.title)
//			newCrux.tag			= entry.tag
//			crux.children.append(newCrux)
//		}
//	}
//}
