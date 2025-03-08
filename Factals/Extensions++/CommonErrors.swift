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
//Usage:

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
var bug : () { //(file:String /*= #file*/, line:UInt /*= #line*/) 			{
	panic("""
		  \t--------------------------------
		  \t---   a   B U G   to fix!    ---
		  \t--------------------------------
		  """, file:#file, line:#line)
}
func debugger(_ message:String, file:StaticString = #file, line:UInt = #line ) -> Never {
	let callStack = ""//Thread.callStackSymbols.prefix(50).joined(separator:"\n")
	#if DEBUG
		// Get thee to a debugger.  Should:
			// 1. Work without lldb breakpoints enabled
			// 2. Allow continue operation
			// 3. Work in all threads
			// 4. Leave the stack so symbols are accessable.
			//		Best if no pop required
			// 5. Does not involve machine language (so Rosetta won't be needed)
			//			See INSTALL.md and TO_DO.md for bug
		raise(SIGTRAP)	//debugger()
	#else
		reportErrorToServer(message + callStack)
	#endif
	fatalError("debugger(\(message))")
}
func panic(_ message: @autoclosure () -> String="Panic with No message",
								file:StaticString = #file,	line:UInt = #line) {
	print("\n\n" + """
		  \t---- FATAL ERROR --------------------------------
		  \t\("\(file):\(line) -- \(message())")
		  \t-------------------------------------------------\n\n
		  """)
	raise(SIGTRAP)	//raise(SIGINT)	//	builtin_debugtrap() __builtin_trap()//while true { print("\t--------------------------------")}
}
//func fatal (_ message:String,	file:StaticString = #file, line:UInt = #line ) {
//	print(message)
//	raise(SIGTRAP)	//raise(SIGINT)	//	builtin_debugtrap() __builtin_trap()//while true { print("\t--------------------------------")}
//}

   /// Clock time
  /// - parameters:
 /// - truthValue:  -- Should be true
/// - message:  -- Closure to execute if false
func wallTime(_ format:String="yyyy-MM-dd' 'HH:mm: ") -> String	{
	let dateFormatter 			= DateFormatter()
	dateFormatter.dateFormat 	= format
	return dateFormatter.string(from: NSDate() as Date)
}
 /// a shortcut for sprintf
func fmt(_ format:String, _ args:CVarArg...) -> String {
	return  String(format:format, arguments:args)
}
