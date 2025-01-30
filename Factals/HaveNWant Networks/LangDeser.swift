//  LangDeser.swift -- Language Deserializer Network ©2021PAK
//
import SceneKit

class LangDeser : Book {

	override func loadTest(args:ScanForKey, state:inout ScanState) {
		super.loadTest(args:args, state:&state)
		let e 	 : FwConfig 	= [:]		// Logs OFF
	    //
	   //
	  //
	 //
    //
   //
  // Change just one of the following r () to x#r () to select it for building
 //
// ///////////////////////////////////////////////////////////////////////
 // MARK: - * Tivo WorlTestsFood
 // , "", "", "", "", "", ""
state.scanSubMenu	= "Language Deserializer"
let wordType		= ["proposition", "determinat", "nouns", "auxiliary", "verbs", "cp"]
let wordType0		= ["foo"]
let determinat		= ["the"]
let cp				= ["that"]
let verbs			= ["told", "fix"]
let auxiliary		= ["will"]
let nouns			= ["Mary", "Bill", "Mayor", "Boston", "leak"]
let proposition		= ["of"]
let words			= ["proposition", "determinat", "nouns", "auxiliary", "verbs", "cp"]
let words0			= ["auxiliary"]
//let words			= [proposition, determinat, nouns, auxiliary, verbs, cp]
let inputWords		= [
				"Mary", "told", "Bill", "that",
				"the", "mayor", "of", "Boston",
				"will", "fix", "the", "leak", "."]
let _ = [wordType, determinat, cp, verbs, auxiliary, nouns, proposition, words, inputWords]

 // Nounst words		:
//		let vinputWordsalPtr			= noun_lookup(nouns)

  // BROKEN
 // Verbs:
//xxr("Language Deserializer", e, {
//  Net(["parts":[
//	Actor(["n":"wordType", "placeMy":"linky",
//		"con":Tunnel(["struc":wordType, "f":1]),
//		"parts":[
//			MaxOr( ["n":"ma", "share":"auxiliary", "f":0, "P":"mj"]),
//			MinAnd(["n":"mj", "shareX":["determinat", "nouns"], "f":1]),
//	//		MaxOr( ["n":"ma", "share":["nouns", "auxiliary"], "f":0, "P":"mj"]),
//	//		MinAnd(["n":"mj", "share":["determinat", "nouns"], "f":1]),
//		],
//		"evi":Tunnel(["struc":words0, "n":"words", "placeMy":"stackz"]),
//	]),
////	Generator(["n":"lo", "P":"wordType/evi", "events":inputWords]),
//  ]])
//})
 // BROKEN
//	r("Language Deserializer", e, {
//	  Net(["parts":[
//		Actor(["n":"wordType", "placeMy":"linky",
//			"con":Tunnel(["struc":wordType0, "f":1]),
//			"parts":[
//				MaxOr( ["n":"ma", "share":["foo"], "f":0, "P":"mj"]),//"nouns",  "auxiliary"
//				MinAnd(["n":"mj", "share":["bar"], "f":1]),
//			],
//			"evi":Tunnel(["struc":words0, "n":"words", "placeMy":"stackz"]),
//		]),
//	  ]])
//	})

r("- bug: Ref:\"a\" is confused by definitions", e, {
  Net(["placeMy":"linky", "parts":[
	MinAnd(["n":"a"]),		// 					   "a" opening down
	MaxOr( ["share":["a"]]),//	   => reference to "a" opening down
//	Broadcast(["n":"ax"]),	// CONFOUNDER: another "a" opening down
  ]])
})
	xxr("- bug: Ref:\"a\" is confused by definitions", e, {
	  Tunnel(["struc":wordType, "f":1])
	})
	r("- nan Link FIXED", e, {
	  Net(["parts":[
		Actor(["n":"wordType", "placeMy":"linky", "parts": [
				Tunnel(["n":"evi", "placeMy":"stackz", "struc":"a"]),
		] ]),
		DiscreteTime(["n":"lo", "P":"evi", "f":1])
	  ]])
	})
 // BROKEN
//r("Language Deserializer", e, {
//  Net(["parts":[
//	Actor(["n":"wordType", "placeMy":"linky",
//		"con":Tunnel(["struc":["a", "b"], "f":1]),
//		"parts":[
//			Bulb(["n":"mk", "P":"mj"]),
//			MaxOr(["n":"mj", "share":["told", "fix"], "f":1]),
//		],
//		"evi":Tunnel(["n":"words", "placeMy":"stackz", "struc":verbs]),
//	]),
//	Generator(["n":"lo", "P":"wordType/evi", "events":inputWords]),
//  ]])
//})
//
 //
  //
   //
	//
	 //
	  //
	   //
	}
}

