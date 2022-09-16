//
//  AppDelegateFoo.swift
//  FooDocTry3
//
//  Created by Allen King on 9/16/22.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
		// Note: This is NOT set as the actual app delegate. The actual delegate is
		//       a SwiftUI thing, which calls into this thing here.

		private let aboutWindow : NSWindow? = nil//makeAboutWindow()

	override init() {
		super.init()
//		_ = SVGShaperConfiguration.defaultConfig // make sure it is loaded
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
//		SVGShaperConfiguration.registerForChangeNotifications()
//		SVGConverterService.activate()
	}

	@objc func orderFrontStandardAboutPanel(_ sender: Any?) {
bug;	let val : (Any)? = nil						// PW: eliminate this line
//		aboutWindow.makeKeyAndOrderFront(nil)
		aboutWindow!.makeKeyAndOrderFront(val)
	}

	@objc
	func application(_ application: NSApplication, open urls: [ URL ]) {
bug;	let dc = NSDocumentController.shared
		print("open URLs:", urls, "in:", dc)		// console.error("...")
		for url in urls {
			do {
				let values = try url.resourceValues(forKeys: [ .contentTypeKey ])
				guard let type = values.contentType else { continue }

				if type.conforms(to: .svg) {
					print("  open SVG:", type, url.lastPathComponent)
//					SVGShaperDocument.openSVG(url: url) { error in
//						if let error = error {
//							print("Failed to open SVG URL:", url.absoluteString, "\n  error:", error)
//							return
//						}
//						do {
//							try dc.openUntitledDocumentAndDisplay(true)
//						}
//						catch {
//							print("Failed to open untitled document for loaded SVG?:",  error, url)
//						}
//					}
				}
				else { // TODO: should we still just try?!
				  print("  cannot open non-SVG file:", url.lastPathComponent)
				}
			}
			catch {
				print("failed to open:", error, url)
			}
		}
	}
}
