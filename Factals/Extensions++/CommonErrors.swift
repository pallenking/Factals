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

 // Get thee to a debugger.  Should:
 // 1. Work without lldb breakpoints enabled
 // 2. Allow continue operation
 // 3. Work in all threads
 // 4. Leave the stack so symbols are accessable.
 //		Best if no pop required
 // 5. Does not involve machine language (so Rosetta won't be needed)
 //			See INSTALL.md and TO_DO.md for bug
func fatal (_ message:String,			file:StaticString = #file, line:UInt = #line ) -> Never
{					//	value: @autoclosure () -> Value ) 		  -> Value
	let m						= message + Thread.callStackSymbols.prefix(50).joined(separator:"\n")

#if DEBUG
	fatalError(m)				// transfer control to debugger	// fatalError("###")
#else
	reportErrorToServer(m)
					// return value()
#endif

	 // Should never get here, but historically helpful:
	raise(SIGINT)		//	builtin_debugtrap() __builtin_trap()
	raise(SIGTRAP)
	while true { print("\t--------------------------------") 					}
}

var bug : () { //(file:String /*= #file*/, line:UInt /*= #line*/) 			{
	fatal("""
		  \t--------------------------------
		  \t---   a   B U G   to fix!    ---
		  \t--------------------------------
		  """, file:#file, line:#line)
}

func panic(_ message: @autoclosure () -> String="(No message supplied)",
	file:StaticString = #file,	line:UInt = #line)
{
	fatal("\n\n" + """
		  \t---- FATAL ERROR --------------------------------
		  \t\("\(file):\(line) -- \(message())")
		  \t-------------------------------------------------\n\n
		  """)
}

	  /// Check that a condition is true. Trap to debugger if it isn't
	 ///  - Parameters:
	///   - truthValue: must be true
   ///    - message: description of proplem if truthValue == false. Message is only evaluated if that error occurs.
  /// Neither truthValue nor message should cause any side effects.
 ///	//https://medium.com/@johnsundell/using-autoclosure-when-designing-swift-apis-67fe20a8b2e
//func assert(_ truthValue:Bool, _ message:@autoclosure()-> String="assert failure",
//	file:StaticString = #file,	line:UInt = #line)
//{
//	if truthValue == false {
//		guard let log 			= FACTALSMODEL?.log else { fatal("klwjowjvo");return}
//		let pre 				= fmt("%03d", log.eventNumber) + log.ppCurThread + log.ppCurLock
//		fatal("\n\n" + """
//			\t\(pre) ERROR ------------
//			\t\(message())
//			\t----------- -------------------\n
//			""")
//	}
//}

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
