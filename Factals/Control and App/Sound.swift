//  Sound.swift -- Support the playing sounds during simulation ©2020PAK

import SceneKit
import AVFoundation
/*
	Design:
	part.vew0.scn.play
 */

extension Part {
	func applyProp(_ prop:String, withVal val:String) {
		let dummy = Atom()
		if prop == "sound" {	// e.g. "sound:di-sound" or
			let soundPort		= dummy.port(named:"SND")					//Port *sndPPort		= [self port4leafBinding:@"SND"];
			let soundAtom		= soundPort?.atom as? SoundAtom				//SoundAtom *sndAtom	= mustBe(SoundAtom, sndPPort.atom);
bug;		soundAtom!.sounds	= [val]
		}
		if prop == "sounds" {	// e.g. "sound:di-sound" or
bug
		}
	}
}
/// Let scnScene's do play
protocol SoundProtocol {
	func play(sound:String?)
}
extension SCNNode : SoundProtocol {
	func play(sound:String?) {
		print("\(wallTime()):\t\t--- \(sound ?? "nil") ---")
		guard let sound								 else { return 				}// no sound specified
		guard let path 			= knownSounds[sound] else { return 				}// a known sound

		 // SCNAudioSource(url:) fetches from assets (others initializers don't)
		guard let audioDataAsset = NSDataAsset(name:path) else
		{	print("Failed to load '\(path)' audio asset");	return				}
		let t1URL 				= FileManager.default.temporaryDirectory
			.appendingPathComponent("t1URL")
		do
		{	try audioDataAsset.data.write(to:t1URL)								}
		 catch
		 {	print("Failed to write audio data to URL '\(path)': ERROR \(error)")}

/**/	guard let audioSource	= SCNAudioSource(url:t1URL) else { return		}
		audioSource.isPositional = true
		audioSource.shouldStream = false
		audioSource.volume 		= 10//bug; APPDEL?.config4app.float("soundVolume") ?? 1
		audioSource.rate 		= 0.1
		audioSource.load() // Preload the audio for smoother playback

		let audioPlayer			= SCNAudioPlayer(source:audioSource)
		addAudioPlayer(audioPlayer)										// let x1 = node.audioPlayers

		 // Command it to play:
		let playAction			= SCNAction.playAudio(audioSource, waitForCompletion:false)
		runAction(playAction)
	//	audioPlayer.didFinishPlayback = {
	//		print("Audio playback is complete.")
	//	}
	}
}
let knownSounds : [String:String] = [
									   "tick":	 "tick-sound",
									   "tock":	 "tock-sound",
										  "t":		"t-sound",
										  "b":		"b-sound",
								    "forward":"forward-sound",
								   "backward":"backward-sound",
										 "da":	   "da-sound",
										 "di":	   "di-sound",
]

class Sound : Logd {
	let nameTag					= getNametag()
	// NEVER NSCopying, Equatable
	 // MARK: - 5.4 Sound
	var knownSources : [String:SCNAudioSource] = [:]

	init(configure:FwConfig) {
		nop
	}
//	func loadAllSounds(to docSound:Sound) {
//		docSound.load(name:	   "tick", path:	 "tick-sound")
//		docSound.load(name:	   "tock", path:	 "tock-sound")
//		docSound.load(name:		  "t", path:		"t-sound")
//		docSound.load(name:		  "b", path:		"b-sound")//, playOn:scn0tree)
//		docSound.load(name: "forward", path:  "forward-sound")
//		docSound.load(name:"backward", path: "backward-sound")
//		docSound.load(name:		 "da", path:	   "da-sound")
//		docSound.load(name:		 "di", path:	   "di-sound")
//	}
//	func load(name:String, path:String, playOn rootScn:SCNNode?=nil) {
//		guard let audioDataAsset = NSDataAsset(name:path) else
//		{	print("Failed to load '\(name)' audio asset");	return			}
//		let t1URL 				= FileManager.default.temporaryDirectory
//			.appendingPathComponent("t1URL")
//		do
//		{	try audioDataAsset.data.write(to:t1URL)							}
//		 catch
//		 {	print("Failed to write audio data to URL '\(name)': ERROR \(error)")}
//
//		if let audioSource 		= SCNAudioSource(url:t1URL) {
//			audioSource.isPositional = true
//			audioSource.shouldStream = false
//			audioSource.volume 	= 1//bug; APPDEL?.config4app.float("soundVolume") ?? 1
//		  //source.rate 		= 1
//			audioSource.load() // Preload the audio for smoother playback
//
//			assert(knownSources[name] == nil, "Redefinition of sounds (here '\(name)') not suported!")
///**/		knownSources[name] 	= audioSource// register soundSource
//		}
//		return
//	}
	func play(sound:String, onNode:SCNNode?=nil) {
bug
//		let node 				= onNode ??	{			// 1. SCNNode supplied else
//			for vew in FACTALSMODEL?.vewBases ?? [] {	// 2. Search through vewBases for SCNNode
//				if let node 	= vew.scnBase.roots?.rootNode {
//					return node
//				}
//			}
//			debugger("###### Couldn't find SCNNode to play sound")
//		} ()
//
//		 // Get audio source:
//		guard let source		= knownSources[sound] else {
//			atAni(6, logd("###### Sound source '\(sound)' unknow"))
//			return
//		}
//		let audioPlayer			= SCNAudioPlayer(source:source)
//		node.addAudioPlayer(audioPlayer)										// let x1 = node.audioPlayers
//		 // Command it to play:
//		let playAction			= SCNAction.playAudio(source, waitForCompletion:false)
//		node.runAction(playAction)
//		audioPlayer.didFinishPlayback = {
//			print("Audio playback is complete.")
//		}
//
//	//	logg("\(node.fullName) play \"\(sound)\"")
////		node.removeAudioPlayer(audioPlayer)
	}


	func tesSoundLoadding() {
		let m = Foundation.Bundle.main
		
		let a00g = m.url(forResource: "di-sound", withExtension: "m4a")
		let a01x = m.url(forResource: "da-sound", withExtension: "m4a")
		let a02g = m.url(forResource: "di-sound", withExtension: "m4a", subdirectory: "")
		let a03x = m.url(forResource: "di-sound", withExtension: "m4a", subdirectory: "Assets")
		let a04x = m.url(forResource: "di-sound", withExtension: "m4a", subdirectory: "Assets.xcassets")
		
		let b00x = SCNAudioSource(named: "di-sound")
		let b01x = SCNAudioSource(named: "da-sound")
		let b02  = SCNAudioSource(named: "da-sound.dataset/da-sound.m4a")
		let b03  = SCNAudioSource(named: "di-sound.m4a")
		
		let _ = (a00g, a01x, a02g, a03x, a04x, b00x, b01x, b02, b03)

		if let source = SCNAudioSource(named:"Assets.xcassets/di-sound.dataset/di-sound") {
			source.load()
			nop
		} else {
			print("Failed to load audio source 'da-sound'")
		}
	}
}











// Garbage:
	//	let path = Foundation.Bundle.main.path(forResource: "di-sound", ofType: "m4a")!
	//	let url = URL(fileURLWithPath:path)
	//	var player: AVAudioPlayer?
	//	do {
	//		player = try AVAudioPlayer(contentsOf:url)
	//		player?.play()
	//		 // AddInstanceForFactory: No factory registered for id <CFUUID 0x60000002b420> F8BB1C28-BAE8-11D6-9C31-00039315CD46
	//	} catch {
	//		print("Error playing audio: \(error)")
	//	}
		//		let audioSource2		= SCNAudioSource(named:"di-sound.m4a")
		//		 let dataAsset3			= NSDataAsset(name:"di-sound.m4a")
		//		let audioSource3		= SCNAudioSource()
		//		 let path4				= Foundation.Bundle.main.path(forResource:"da-sound", ofType:"m4a")
		//	//	let audioSource4 		= SCNAudioSource(path:path4)
		//		let audioSource 		= (audioSource1, audioSource2, audioSource3).2
		//	let rootScn				= SCNScene(named: "yourScene.scn")?.rootNode
		
		//		let pathsUrl 			= Foundation.Bundle.main.url(forResource:"da-sound", withExtension: "m4a")!
		//		let audioSource			= SCNAudioSource(url:pathsUrl)!					// fails
	func playSimple(rootScn:SCNNode) {
		var audioSource : SCNAudioSource?
		var sourceMode					= 1
		switch sourceMode+0 {
		case 0:			// from name, but not in Assets.xcassets				WORKS, bun not in Assets
			audioSource					= SCNAudioSource(named:"di-sound.m4a")//"Assets.xcassets/da-sound.m4a")//
			 // exists: "file:///Users/allen/Library/Developer/Xcode/DerivedData/Factals-gctqvjjuzubwpfhbgdfehqxdqwpg/Build/Products/Debug/Factals.app/Contents/Resources/di-sound.m4a"
		case 1:			// from Assets.xcassets via temp file					 NFG
			guard let audioDataAsset 	= NSDataAsset(name: "t-sound") else
			{	print("Failed to load audio asset");	return					}
			let t1URL 					= FileManager.default.temporaryDirectory
				.appendingPathComponent("t-sound.m4a")
			do
			{	try audioDataAsset.data.write(to: t1URL)						}
			catch
			{	print("Failed to write audio data to temporary file: \(error)")	}
			audioSource 				= SCNAudioSource(url: t1URL)
		case 2:			// Create an SCNAudioSource from the data
			guard let pathsUrl 			= Foundation.Bundle.main.url(forResource:"da-sound", withExtension: "m4a") else
			{	print("Failed to load audio asset");					return	}
			audioSource					= SCNAudioSource(url:pathsUrl)
		default:
			audioSource					= SCNAudioSource()
		}
		guard let audioSource	else {	print("audioSource in nil");	return	}
 		audioSource.isPositional = false//true
 		audioSource.volume 				= 1
 		audioSource.rate 				= 1
 		audioSource.shouldStream = true//false
 		audioSource.load() // Preload the audio for smoother playback
			
		// Attach the audio source to the node
		let audioPlayer 				= SCNAudioPlayer(source:audioSource)
		rootScn.addAudioPlayer(audioPlayer)

// 		let audioScn 					= SCNNode()
// 		audioScn.addAudioPlayer(audioPlayer)	// place this in active tree:
// 		rootScn.addChildNode(audioScn)

	//	 // Test
	//	let moveAction 					= SCNAction.move(by: SCNVector3(0, 1, 0), duration: 2.0)
	//	rootScn/*audioScn*/.runAction(moveAction) {
	//		print("Movement action completed.")
	//	}
 		let playAction					= SCNAction.playAudio(audioSource, waitForCompletion:false)
 		rootScn/*audioScn*/.runAction(playAction)	{
 			print("Audio action completed or interrupted.")
 		}
 		nop
	}
/*
AddInstanceForFactory: No factory registered for id <CFUUID 0x60000347f140> F8BB1C28-BAE8-11D6-9C31-00039315CD46
170,759 HALC_ProxyIOContext.cpp:1,621 HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
 */
