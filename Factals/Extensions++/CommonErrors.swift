//
//  CommonErrors.swift
//  SwiftFactals
//
//  Created by Allen King on 10/30/21.
//  Copyright © 2021 Allen King. All rights reserved.
//

//CustomError.message("a is nil")
//NS

import Foundation

var bug : () 			{
	print("""
		  \t--------------------------------
		  \t---   a   B U G   to fix!    ---
		  \t--------------------------------
		  """)

	fatalError("")
//	for i in 1...100 {
//		print("Bug, HIT BREAK QUICK!!")
//		for i in 1...1000000 { nop }			//		sleep(2)
//	}

//	builtin_debugtrap()
//	__builtin_trap()
	Thread.callStackSymbols.map {		print($0)								}
	print("\t--------------------------------")
	while true {	nop }
	machineTrap()				// transfer control to debugger	// fatalError("###")
	return
}
var bug0 : Bool			{
	bug
	return false
}

func panic(_ message: @autoclosure () -> String="(No message supplied)") {
	print("\n\n" + """
		  \t---- FATAL ERROR --------------------------------
		  \t\(message())
		  \t-------------------------------------------------\n\n
		  """)
	machineTrap()				// transfer control to debugger
}

	  /// Check that a condition is true. Trap to debugger if it isn't
	 ///  - Parameters:
	///   - truthValue: must be true
   ///    - message: description of proplem if truthValue == false. Message is only evaluated if that error occurs.
  /// Neither truthValue nor message should cause any side effects.
 ///	//https://medium.com/@johnsundell/using-autoclosure-when-designing-swift-apis-67fe20a8b2e
#if DEBUG
func assert(_ truthValue:Bool, _ message:@autoclosure()-> String="assert failure") {
	if truthValue == false {
		guard let log 			= FACTALSMODEL?.log else { fatalError("klwjowjvo")}
		let pre 				= fmt("%03d", log.eventNumber) + log.ppCurThread + log.ppCurLock
		print("\n\n" + """
			\t\(pre) ERROR ------------
			\t\(message())
			\t----------- -------------------\n
			""")
		machineTrap()			// transfer control to debugger
	}
}
#else
func assert(_ truthValue:Bool, _ message:@autoclosure()-> String="assert used in non DEBUG execution") {}
#endif

   /// Warn if a condition is not true
  /// - parameters:
 ///   - truthValue: = Should be true
///   - message: = Pass your alert message in String
func assertWarn(_ truthValue:Bool, _ message:@autoclosure()->String="assert failure") {
	if truthValue == false {
		let msg					= message()
		warningLog.append(msg)
		print("\n############# WARNING: \(msg) #############")
	}
}
 // Get thee to a debugger.  Should:
 // 1. Work without lldb breakpoints enabled
 // 2. Allow continue operation
 // 3. Work in all threads
 // 4. Leave the stack so symbols are accessable.
 //		Best if no pop required
 // 5. Does not involve machine language (so Rosetta won't be needed)
 //			See INSTALL.md and TO_DO.md for bug
func machineTrap() {
	raise(SIGINT)
//	raise(SIGTRAP)
}

   /// Clock time
  /// - parameters:
 /// - truthValue:  -- Should be true
/// - message:  -- Closure to execute if false
func wallTime(_ format:String="%c") -> String	{
	let dateFormatter 			= DateFormatter()
	dateFormatter.dateFormat = format
	let x						= dateFormatter.string(from: NSDate() as Date)
	return x
}

 /// a shortcut for sprintf
func fmt(_ format:String, _ args:CVarArg...) -> String {
	return  String(format:format, arguments:args)
}
