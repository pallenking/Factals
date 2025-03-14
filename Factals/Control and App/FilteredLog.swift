//  FilteredLog.swift -- selective filtering of Log messages ©2021PAK

import Foundation

// MARK: A Event Generation:
// e.g:	logRve(5, log("hi")		// Just Normal detail on ReView screen
//		atAll(0, {...})			// no output
// MARK: B Log Attention:
//func logAt(app:doc:bld:ser:ani:dat:eve:ins:men:rve:rsi:rnd:tst:all:) -> FwConfig
//
// MARK: 1.1 Detail
//		0 : silent (prints nothing)		5 : Normal
//		1 : initialization and errors	6 : Verbose
//		2 : 1 line per model			7 : a lot
//		3 : important					8 : Most Everything
//		4 : lite						9 : Everything
//
// MARK: 1.2 Area
//		app	-- APPlication		14	- construction of app
// 		doc	-- DOCument			 0	- construction of document, including mouse
//		bld	-- BuiLD part		54	- building of part
//		ser	-- SERilization		90	- serialization and desrialization of Part
// 		ani	-- phys ANImation	 7	- physical animation events
// 		dat	-- sim DATa			21	- simulation data
// 		eve	-- sim EVEnts		42	- simulation events
// 		ins	-- INSpectors		 0	-
//		men	-- MENus 			 0	- construction of menus
// 		rve	-- ReViEw 			22	- review visual properties
// 		rsi	-- ReSIze 			38	- reSize shapes
// 		rnd	-- ReNDer protocol	 0	-
// 		tst	-- TeSTing			 3
// 		all	-- ALL OF ABOVE		-

// MARK: 2 Generate a Log Event:
 // Sugar to shorten commonly used cliche.
func  logApp(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// APPlication
{ 	Log.shared.at("app", detail, format:format, args:args, terminator:terminator)}
func  logDoc(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// DOCument
{ 	Log.shared.at("doc", detail, format:format, args:args, terminator:terminator)}
func  logBld(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// BuiLD part
{ 	Log.shared.at("bld", detail, format:format, args:args, terminator:terminator)}
func  logSer(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// SERilization
{ 	Log.shared.at("ser", detail, format:format, args:args, terminator:terminator)}
func  logAni(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// phys ANImation
{ 	Log.shared.at("ani", detail, format:format, args:args, terminator:terminator)}
func  logDat(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// sim DATa
{ 	Log.shared.at("dat", detail, format:format, args:args, terminator:terminator)}
func  logEve(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// sim EVEnts
{ 	Log.shared.at("eve", detail, format:format, args:args, terminator:terminator)}
func  logIns(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// INSpectors
{ 	Log.shared.at("ins", detail, format:format, args:args, terminator:terminator)}
func  logMen(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// MENus
{ 	Log.shared.at("men", detail, format:format, args:args, terminator:terminator)}
func  logRve(_ detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// ReViEw
{ 	Log.shared.at("rve", detail, format:format, args:args, terminator:terminator)}
func logRsi(_  detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// ReSIze
{ 	Log.shared.at("rsi", detail, format:format, args:args, terminator:terminator)}
func logRnd(_  detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// ReNDer protocol
{ 	Log.shared.at("rnd", detail, format:format, args:args, terminator:terminator)}
func logTst(_  detail:Int, _ format:String, _ args:CVarArg..., terminator:String?=nil)		// TeSTing
{ 	Log.shared.at("tst", detail, format:format, args:args, terminator:terminator)}

 // MARK: 3 Configure Logs
func logAt(
		app:Int = -1,		doc:Int = -1,		bld:Int = -1,		ser:Int = -1,
		ani:Int = -1,		dat:Int = -1,		eve:Int = -1,		ins:Int = -1,
		men:Int = -1,		rve:Int = -1,		rsi:Int = -1,		rnd:Int = -1,
		tst:Int = -1, 		all:Int = -1				) -> FwConfig {
	var rv : FwConfig		= [:]
	if app >= 0 	{		rv["logPri4app"] = app								}
	if doc >= 0 	{		rv["logPri4doc"] = doc								}
	if bld >= 0 	{		rv["logPri4bld"] = bld								}
	if ser >= 0 	{		rv["logPri4ser"] = ser								}
	if ani >= 0 	{		rv["logPri4ani"] = ani								}
	if dat >= 0 	{		rv["logPri4dat"] = dat								}
	if eve >= 0 	{		rv["logPri4eve"] = eve								}
	if ins >= 0 	{		rv["logPri4ins"] = ins								}
	if men >= 0 	{		rv["logPri4men"] = men								}
	if rve >= 0 	{		rv["logPri4rve"] = rve								}
	if rsi >= 0 	{		rv["logPri4rsi"] = rsi								}
	if rnd >= 0 	{		rv["logPri4rnd"] = rnd								}
	if tst >= 0 	{		rv["logPri4tst"] = ins								}
	if all >= 0 	{		rv["logPri4all"] = all								}
	return rv
}
 // An easy way in source code to disable the logAt(
func logAtX(prefix:String="", // / 3b. Neutered (with suffix X) returns an empty hash
		  con:Int=0, men:Int=0, doc:Int=0, bld:Int=0, ser:Int=0, eve:Int=0, dat:Int=0,
		  rve:Int=0, rsi:Int=0, rnd:Int=0, ani:Int=0, ins:Int=0, tst:Int=0, all:Int=0)
		  -> FwConfig { return [:] }
