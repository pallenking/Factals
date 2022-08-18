//
//  FooDocTry3App.swift
//  FooDocTry3
//
//  Created by Allen King on 5/18/22.
//

import SwiftUI


  //let (majorVersion, minorVersion, nameVersion) = (4, 0, "xxx")				// 180127 FactalWrokbench UNRELEASED
  //let (majorVersion, minorVersion, nameVersion) = (5, 0, "Swift Recode")
  //let (majorVersion, minorVersion, nameVersion) = (5, 1, "After a rest")		// 210710 Post
	let (majorVersion, minorVersion, nameVersion) = (6, 0, "FooDocTry3 re-App")	// 220628

var isRunningXcTests : Bool	= ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

////	Application Singletons:
//var APPDEL	 : AppDelegate? 	{	NSApp.delegate as? AppDelegate			}
//var APPLOG	 : Log 				{	APPDEL?.log ?? Log.null					}

//let DOCCTLR						= NSDocumentController.shared
var DOC   	 : FooDocTry3Document!		// (Currently Active) App must insure continuity
var DOCLOG   : Log 					{	DOC?.docState.rootPart.log ?? Log.null			}
// A basic tutorial :http://sketchytech.blogspot.com/2016/09/taming-nsdocument-and-understanding.html



@main
struct FooDocTry3App: App {
	var body: some Scene {
		DocumentGroup(newDocument: FooDocTry3Document()) { file in
			ContentView(document: file.$document)
		}
	}
}
