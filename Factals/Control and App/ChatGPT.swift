//	//
//	//  ChatGPT.swift
//	//  Factals
//	//
//	//  Created by Allen King on 2/9/23.
//	//
	import SwiftUI
	import SceneKit

struct SceneView1: NSViewRepresentable {
	func makeNSView(context: Context) -> SCNView {
		let view = SCNView()
		let scene = SCNScene()
		view.scene = scene
		return view
	}
	
//
//		func makeNSView(context: Context) -> SCNView {
//			let view = SCNView()
//			let scene = SCNScene()
//			view.scene = scene
//
//			let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
//			let boxNode = SCNNode(geometry: boxGeometry)
//			scene.rootNode.addChildNode(boxNode)
//
//			let cameraNode = SCNNode()
//			cameraNode.camera = SCNCamera()
//			cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
//			scene.rootNode.addChildNode(cameraNode)
//
//			let lightNode = SCNNode()
//			lightNode.light = SCNLight()
//			lightNode.light!.type = .omni
//			lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//			scene.rootNode.addChildNode(lightNode)
//
//	//		let rotator = MouseRotator(view: view)
//	//		view.addGestureRecognizer(rotator)
//
//			return view
//		}

		func updateNSView(_ nsView: SCNView, context: Context) {}
	}
//
//	//class MouseRotator: NSGestureRecognizer {
//	//	let view_: SCNView
//	//	var previousLocation = CGPoint.zero
//	//
//	//	init(view: SCNView) {
//	//		self.view_ = view
//	//		super.init(target: nil, action: nil)
//	//	}
//	//	required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")	}
//	//
//	//	override func mouseDown(with event: NSEvent) {
//	//		previousLocation = event.locationInWindow
//	//	}
//	//
//	//	override func mouseDragged(with event: NSEvent) {
//	//		let location = event.locationInWindow
//	//		let dx = CGFloat(location.x - previousLocation.x)
//	//		let dy = CGFloat(location.y - previousLocation.y)
//	//		let camera = view_.pointOfView!
//	//		camera.eulerAngles.y -= dx / 100
//	//		camera.eulerAngles.x -= dy / 100
//	//		previousLocation = location
//	//	}
//	//}
//
//	////struct ContentView: View {
//	////	var body: some View {
//	////		SceneView()
//	////	}
//	////}
//	////
//	////struct ContentView_Previews: PreviewProvider {
//	////	static var previews: some View {
//	////		ContentView()
//	////	}
//	////}
