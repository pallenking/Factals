//
//  ScnView.swift
//  Factals
//
//  Created by Allen King on 10/9/25.
//
import SceneKit
import RealityKit

extension SCNView {		//
	//var scnBase : ScnBase?		{ delegate as? ScnBase						}
	var handler : EventHandler 	{
		get { return			( delegate as! ScnBase).eventHandler			}
		set(val) { }
	}

	 // MARK: - 13.1 Keys
	open override func keyDown(with event:NSEvent) 		{	handler(event)		}
	open override func keyUp(  with event:NSEvent) 		{	handler(event)		}
}
extension SCNView : Gui {
	func makeScenery(anchorEntity:AnchorEntity) { scnBase!.makeScenery(anchorEntity:anchorEntity) }
	func makeAxis()   							{ scnBase!.makeAxis()   		}
	func makeCamera() 							{ scnBase!.makeCamera() 		}
	func makeLights() 							{ scnBase!.makeLights() 		}
	var cameraXform: SCNNode {
		get { bug; return SCNNode()	}
		set { bug	}
	}
	var anchor: SCNNode {
		get { self.scene!.rootNode												}
		set { bug																}
	}
	 // Sugar:
	var scnBase : ScnBase? {  self.delegate as? ScnBase							}
	var gui 	: Gui? 	   { (self.delegate as? ScnBase)?.gui					}
	/// SceneKit's Gui
	var isScnView: Bool		{ true		}
	var vewBase:VewBase! {
		get {	self.gui?.vewBase													}
		set {	gui?.vewBase		= newValue									}
	}
	var getScene : SCNScene? {
		get {	self.scene														}
		set {	self.scene			= newValue									}
	}
	var animatePhysics:Bool {
		get {	gui!.animatePhysics												}
		set {	gui!.animatePhysics	= newValue									}
	}
	func hitTest3D(_ point:NSPoint, options:[SCNHitTestOption:Any]?) -> [HitTestResult] {
		let scnResults = self.hitTest(point, options: options!)
		return scnResults.map { scnHit in
			HitTestResult(
				node: scnHit.node,
				position: SIMD3<Float>(scnHit.worldCoordinates),
//				distance: scnHit.distance
			)
		}
	}
}
/*
			View.convert(_:NSPoint, from:NSView?)
- (NSPoint)convertPoint:(NSPoint)point fromView:(nullable NSView *)view;

Vew.swift:
           localPosition   (of:SCNVector3,inSubVew:Vew)          -> SCNVector3			REFACTOR
		   convert		   (bBox:BBox,       from:Vew)	         -> BBox
SceneKit:
		   convertPosition (_:SCNVector3,    from:SCNNode?)      -> SCNVector3		SCNNode.h
FACTALS ->		nil ==> from scene’s WORLD coordinates.	FAILS _/
	       convertVector   (_:SCNVector3,    from:SCNNode?)      -> SCNVector3		SCNNode.h
	       convertTransform(_:SCNMatrix4,    from:SCNNode?)      -> SCNMatrix4		SCNNode.h
NSView:
		   convert         (_:NSPoint,       from:NSView?)       -> NSPoint			<== SwiftFactals (motionFromLastEvent)
SWIFTFACTALS ->	nil ==> from WINDOW coordinates.		WORKS _/
		   convert		   (_:NSSize,        from:NSView?)       -> NSSize
	       convert         (_:NSRect,        from:NSView?)       -> NSRect
Quartzcore Calayer: UIView:
		   convertPoint    (_:CGPoint,	     fromLayer:CALayer?) -> CGPoint
		   convertRect     (_:CGRect, 	     fromLayer:CALayer?) -> CGRect
		   convertTime     (_:CFTimeInterval,fromLayer:CALayer?) -> CFTimeInterval,
SpriteKit:
		   convertPoint    (fromView:CGPoint)			         -> CGPoint
		   convertPoint    (fromScreen:NSPoint) 		         -> NSPoint
UIView:
		   convert         (_:CGPoint,     from:UIView?)         -> CGPoint
		   convert         (_:CGRect,      from:UIView?)         -> CGRect
AppKit:
		   convert         (_:NSFont                          )  -> NSFont

			convertPointFromBacking:

		   convert        (              to: UnitType)							UnitType conforms to Dimension

https://groups.google.com/a/chromium.org/g/chromium-dev/c/BrmJ3Lt56bo?pli=1
- convertPointToBase:
- convertSizeToBase:
- convertSizeFromBase:
- convertRectToBase:
- convertRectFromBase:

 */
