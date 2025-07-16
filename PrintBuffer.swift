override func reVewPost(vew:Vew) 	{	// Add constraints
	vew.pCon2Vew		= vewConnected(toPortNamed:"P", inViewHier:vew)
	vew.sCon2Vew		= vewConnected(toPortNamed:"S", inViewHier:vew)
	if linkVew.scnRoot.constraints == nil {
		let pConstraint = SCNTransformConstraint.positionConstraint(inWS:f)
***		{(n,p) in vew.pCon2Vew.part.portConSpot(inVew: parentVew).center}
		let sConstraint = SCNTransformConstraint.positionConstraint(inWS:f)
***		{(n,p) in vew.sCon2Vew.part.portConSpot(inVew: parentVew).center}
		vew.find(name:"_P").scnRoot.constraints = [pConstraint]
		vew.find(name:"_S").scnRoot.constraints = [sConstraint]
	}	}
override func reSize(vew:Vew) {	reSkin(expose:.same, vew:vew) }
override func reSkin(fullOnto vew:Vew) -> BBox  {
***	let sLink			= SCNNode()				// transform
	 vew.scnRoot.addChild(node:sLink, atIndex:0)
***	let sRay			= SCNNode(g:Geo.lines(lines:[0,1],wPts:[.zero,-.uZ])
	 sLink.addChild(node:sRay)
override func reSizePost(vew:Vew) {				//  find endpoints
	vew.scnRoot.position= .zero
	let pCon2SIp 		= linkVew.pCon2Vew?.part.portConSpot(inVew:pVew)
	 let sCon2SIp		= linkVew.sCon2Vew?.part.portConSpot(inVew:pVew)
	let  pCon2VIp 		= pCon2SIp.center
	 let sCon2VIp		= sCon2SIp.center
	let unitRay			= (sCon2VIp - pCon2VIp)/(sCon2VIp - pCon2VIp).length
	linkVew.pEndVip		= pCon2VIp + pCon2SIp.radius * unitRay
***	linkVew.find(name:"_P")!.scnRoot.position	= linkVew.pEndVip										// -> Port
	linkVew.sEndVip		= sCon2VIp - sCon2SIp.radius * unitRay
***	linkVew.find(name:"_S")!.scnRoot.position	= linkVew.sEndVip
}
 // MARK: - 9.5.4: will Render Scene -- Rotate Links toward camera
override func rotateLinkSkins(vew:Vew) {	// create Line transform
	let linkVectIp	= linkVew.sEndVip - linkVew.pEndVip
	let cameraPosnIp= vew.parent?.scn.convertPosition(vew.vewBase().cameraSc
***	transform		= SCNMatrix4(r1:f, r2:g, r3:-linkVectIp, r4:pEndVectIp)
	let sLink		= linkVew.scnRoot.findScn(named:"s-Link")!
***	sLink.transform = transform
}

