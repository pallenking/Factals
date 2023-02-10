//
//  ChatGPT.swift
//  Factals
//
//  Created by Allen King on 2/9/23.
//
import SwiftUI
import SceneKit

struct SceneView1: NSViewRepresentable {
	typealias NSViewType 		= SCNView	// represent SCNView inside

	 // 1. On creation, save the args for later
	init(_ args:SceneKitArgs)	{
		self.args				= args
		atRnd(4, DOClog.log("=== Slot \(args.sceneIndex): ========= SceneKitHostingView title:'\(args.title)'"))
	}
	var args					: SceneKitArgs

	func makeNSView(context: Context) -> SCNView {
		guard let fwGuts		= args.rootPart?.fwGuts else { fatalError("got no fwGuts!")}
		atRnd(4, DOClog.log("=== Slot \(args.sceneIndex): ========== makeNSView         title:'\(args.title)'"))

		let scnScene 			= args.scnScene ?? SCNScene()
		let rootScn	: RootScn	= RootScn(scnScene:scnScene, args:args)

		 // Make a new RootVew:
		let rootVew				= RootVew(forPart:fwGuts.rootPart, rootScn:rootScn)
		rootVew.keyIndex		= args.sceneIndex
		rootVew.fwGuts			= fwGuts

		 // Get index :
		let i					= args.sceneIndex
		assert(i >= 0 && i < 4, "Illegal args.sceneIndex:\(i)")

		 // SAVE in array:					// print(fwGuts.rootVews[0].debugDescriaption)
		fwGuts.rootVews[i]		= rootVew


		let view = SCNView()
		let scene = SCNScene()
		view.scene = scene

		let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
		let boxNode = SCNNode(geometry: boxGeometry)
		scene.rootNode.addChildNode(boxNode)

		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
		scene.rootNode.addChildNode(cameraNode)

		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = .omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode)

		let rotator = MouseRotator(view: view)
		view.addGestureRecognizer(rotator)
		
		let keyboardRecognizer = KeyboardRecognizer(view: view)
		view.addGestureRecognizer(keyboardRecognizer)

		return view
	}

	func foo() {
	}
	func updateNSView(_ nsView: SCNView, context: Context) {}
}

class MouseRotator : NSGestureRecognizer {
	let view_: SCNView
	var previousLocation = CGPoint.zero

	init(view: SCNView) {
		self.view_ = view
		super.init(target: nil, action: nil)
	}
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}

	override func mouseDown(with event: NSEvent) {
		previousLocation = event.locationInWindow
	}

	override func mouseDragged(with event: NSEvent) {
		let location = event.locationInWindow
		let dx = CGFloat(location.x - previousLocation.x)
		let dy = CGFloat(location.y - previousLocation.y)
		let camera = view_.pointOfView!
		camera.eulerAngles.y -= dx / 100
		camera.eulerAngles.x -= dy / 100
		previousLocation = location
	}
}

class KeyboardRecognizer: NSGestureRecognizer {
	let view_: SCNView
	
	init(view: SCNView) {
		self.view_ = view
		super.init(target: nil, action: nil)
	}
	
	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
	
	override func keyDown(with event: NSEvent) {
		switch event.charactersIgnoringModifiers!.lowercased() {
		case "w":
			view_.pointOfView!.position.z -= 0.1
		case "s":
			view_.pointOfView!.position.z += 0.1
		case "a":
			view_.pointOfView!.position.x -= 0.1
		default:
			print("unknown key")
		}
	}
}
//	////struct ContentView: View {
//	////	var body: some View {
//	////		SceneView1()
//	////	}
//	////}
//	////
//	////struct ContentView_Previews: PreviewProvider {
//	////	static var previews: some View {
//	////		ContentView()
//	////	}
//	////}
/*
import SwiftUI
import SceneKit

struct SceneView: NSViewRepresentable {
	func makeNSView(context: Context) -> SCNView {
		let view = SCNView()
		let scene = SCNScene()
		view.scene = scene
		
		let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
		let boxNode = SCNNode(geometry: boxGeometry)
		scene.rootNode.addChildNode(boxNode)
		
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
		scene.rootNode.addChildNode(cameraNode)
		
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = .omni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		scene.rootNode.addChildNode(lightNode)
		
		let mouseRotator = MouseRotator(view: view)
		view.addGestureRecognizer(mouseRotator)
		
		let keyboardRecognizer = KeyboardRecognizer(view: view)
		view.addGestureRecognizer(keyboardRecognizer)
		
		return view
	}
	
	func updateNSView(_ nsView: SCNView, context: Context) {}
}

class MouseRotator: NSGestureRecognizer {
	let view: SCNView
	var previousLocation = CGPoint.zero
	
	init(view: SCNView) {
		self.view = view
		super.init(target: nil, action: nil)
	}
	
	override func mouseDown(with event: NSEvent) {
		previousLocation = event.locationInWindow
	}
	
	override func mouseDragged(with event: NSEvent) {
		let location = event.locationInWindow
		let dx = Float(location.x - previousLocation.x)
		let dy = Float(location.y - previousLocation.y)
		let camera = view.pointOfView!
		camera.eulerAngles.y -= dx / 100
		camera.eulerAngles.x -= dy / 100
		previousLocation = location
	}
}

class KeyboardRecognizer: NSGestureRecognizer {
	let view: SCNView
	
	init(view: SCNView) {
		self.view = view
		super.init(target: nil, action: nil)
	}
	
	override func keyDown(with event: NSEvent) {
		switch event.charactersIgnoringModifiers!.lowercased() {
		case "w":
			view.pointOfView!.position.z -= 0.1
		case "s":
			view.pointOfView!.position.z += 0.1
		case "a":
			view.pointOfView!.position.x -= 0.1
		case

 */
