//  Sounds.swift -- Support the playing sounds during simulation ©2020PAK

import SceneKit
import AVFoundation

extension Part {
	func applyProp(_ prop:String, withVal val:String) {
		let dummy = Atom()
		if prop == "sound" {	// e.g. "sound:di-sound" or
			let soundPort		= dummy.port(named:"SND")					//Port *sndPPort		= [self port4leafBinding:@"SND"];
			let soundAtom		= soundPort?.atom as? SoundAtom				//SoundAtom *sndAtom	= mustBe(SoundAtom, sndPPort.atom);
			soundAtom!.sound	= val;
		}
	}
}
/// Let scnScene's do play
protocol SoundPro  {
	func play(sound:String)
}
//extension SoundPro {
//	func play(sound:String) {
//		FactalsApp.sounds.play(sound:sound, onNode:self)
//	}
//}
extension SCNNode : SoundPro {
	func play(sound:String) {
//		FactalsApp.sounds.play(sound:sound, onNode:self)
	}
//	func play(sound: String) {
//		print("::::::::::::::::: PLAYING SOUND \(sound) :::::::::::")
//		assert(APPDEL != nil, "play(sound:\(sound)), but APPDEL is nil")
//		APPDEL!.appSounds.play(sound:sound, onNode:self)
//	}
}
class Sounds : Logd {
	let nameTag					= getNametag()
	// NEVER NSCopying, Equatable
	 // MARK: - 5.4 Sound
	var knownSources : [String:SCNAudioSource] = [:]

	init(configure:FwConfig) {
		nop
	}


//		if let pathsUrl 		= Foundation.Bundle.main.url(forResource: "di-sound", withExtension: "m4a"),

								//
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
	//	nop
		//		 let pathsUrl1 			= Foundation.Bundle.main.url(forResource:"da-sound", withExtension: "m4a")
		//		let audioSource1		= SCNAudioSource(url:(pathsUrl1 ?? URL(string:""))!)
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
		let audioSource			= SCNAudioSource(named:"di-sound.m4a")!
		 // exists: "file:///Users/allen/Library/Developer/Xcode/DerivedData/Factals-gctqvjjuzubwpfhbgdfehqxdqwpg/Build/Products/Debug/Factals.app/Contents/Resources/di-sound.m4a"
		
		audioSource.isPositional = false//true
		audioSource.volume 		= 1
		audioSource.rate 		= 1
		audioSource.shouldStream = true//false
		audioSource.load() // Preload the audio for smoother playback
		
		let audioPlayer			= SCNAudioPlayer(source:audioSource)
		let audioScn 			= SCNNode()
		audioScn.addAudioPlayer(audioPlayer)	// place this in active tree:
		rootScn.addChildNode(audioScn)

		let moveAction 			= SCNAction.move(by: SCNVector3(0, 1, 0), duration: 2.0)
		audioScn.runAction(moveAction) {
			print("Movement action completed.")		// NEVER HITS
		}

		let playAction			= SCNAction.playAudio(audioSource, waitForCompletion:false)
		audioScn.runAction(playAction)	{
			print("Audio action completed or interrupted.")
		}
		nop
		// run action play
	}
/*
AddInstanceForFactory: No factory registered for id <CFUUID 0x60000347f140> F8BB1C28-BAE8-11D6-9C31-00039315CD46
170,759 HALC_ProxyIOContext.cpp:1,621 HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
 */
	func load(name:String, path:String) {
		if let pathsUrl 		= Foundation.Bundle.main.url(forResource:path, withExtension: "m4a"),
		   let source			= SCNAudioSource(url:pathsUrl) {
			assert(knownSources[name] == nil, "Redefinition of sounds not suported!")
			knownSources[name] 	= source// register soundSource
			source.isPositional = true
			source.shouldStream = false
			source.volume 		= 1//bug; APPDEL?.config4app.float("soundVolume") ?? 1
		  //source.rate 		= 1
			source.load() // Preload the audio for smoother playback
			
			// Attach the audio to a SceneKit node
			let audioNode 		= SCNNode()
			audioNode.addAudioPlayer(SCNAudioPlayer(source: source))
			if let scene		= FACTALSMODEL?.vewBases.first?.scnBase.tree {
				scene.rootNode.addChildNode(audioNode)
			}
		} else {
			print("Error: Failed to find da-sound.m4a in the app bundle.")
		}
		return
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
	func play(sound:String, onNode:SCNNode?=nil) {
		let node 				= onNode ??	{			// 1. SCNNode supplied else
			for vew in FACTALSMODEL?.vewBases ?? [] {	// 2. Search through vewBases for SCNNode
				if let node 	= vew.scnBase.tree?.rootNode {
					return node
				}
			}
			fatalError("###### Couldn't find SCNNode to play sound")
		} ()

		 // Get audio source:
		guard let source		= knownSources[sound] else {
			atAni(6, logd("###### Sound source '\(sound)' unknow"))
			return
		}
		let audioPlayer			= SCNAudioPlayer(source:source)
		node.addAudioPlayer(audioPlayer)										// let x1 = node.audioPlayers
		 // Command it to play:
		let playAction			= SCNAction.playAudio(source, waitForCompletion:false)
		node.runAction(playAction)

	//	logg("\(node.fullName) play \"\(sound)\"")
//		node.removeAudioPlayer(audioPlayer)
	}
}
