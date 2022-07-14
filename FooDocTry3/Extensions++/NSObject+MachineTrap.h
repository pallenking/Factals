//  NSObject+MachineTrap.h -- a Better Fault Routine C112018PAK
// ///////////////////////////////////////////////////////////////////////
//https://stackoverflow.com/questions/37736320/how-can-i-trap-to-the-debugger-and-continue-on-ios-hardware

#include <stdio.h>
   /// Trap to debugger
  /// * Works in all threads (including background)
 /// * Able to continue after halt
//static inline void machineTrap(void) {
//	//printf("void machineTrap()!\n");
//	//fflush(stdout);
//	asm ("	int3	");			//	asm ("	ud2		");
//}	// Program has TRAPPED to DEBUGGER			//
//	//    Continue past here at your own risk 	//


// Other ways to stop program:
// fatalError()
//	raise(SIGINT) // doesn't work in background thread
//#ifdef __aarch64__	//	asm volatile("BRK 0")
//#else					//	asm volatile("BKPT 0")	//Invalid instruction mnemonic 'bkpt'


#import <Foundation/Foundation.h>    
	 // ///////////////////////////////////////////////////////////////////////
	/// https://stackoverflow.com/questions/24010569/error-handling-in-swift-language
	/// https://stackoverflow.com/questions/32758811/catching-nsexception-in-swift
	/// https://stackoverflow.com/questions/24023112/try-catch-exceptions-in-swift
	/// https://stackoverflow.com/questions/24023112/try-catch-exceptions-in-swift/24023248#24023248
   /// Execute a workClosure, catching objc exceptions by returning non-nil
  /// - Parameter workItem: -- closure to execute
 /// - Returns: NSException if exception, nil if okay
//NS_INLINE NSException * _Nullable 	  						// Return value
//  if_objcException   (										// Function name
//	void(	NS_NOESCAPE ^_Nonnull  workItem   )		(void)	// Arg1:
//){
//	@try {
//		workItem();								// do work item
//	}
//	@catch (NSException *exception) {			// exception thrown
//		return exception;
//	}
//	return nil;									// normal return
//}

/* https://medium.com/swift-programming/adding-try-catch-to-swift-71ab27bcb5b8
see ~/src/SwiftTryCatch 
+ (void)
	try:	void (^)()				)try 
	catch:	void (^)(NSException *)	)catch 
	finally:void (^)()				)finally
	{
    @try {
       try ? try() : nil;
    }
    @catch (NSException *exception) {
       catch ? catch(exception) : nil;
    }
    @finally {
       finally ? finally() : nil;
    }
}

+ (void)try:void(^)())try catch:void(^)(NSException*exception))catch finally:void(^)())finally;
+ (void)
	try:void(^)())
	try catch:void(^)(NSException*exception))catch finally:void(^)())finally; {
	@try {
	}
	@catch (NSException *exception) {
	}
	@finally {
	}
*/
