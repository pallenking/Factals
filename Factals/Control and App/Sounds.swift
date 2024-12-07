//  Sounds.swift -- Support the playing sounds during simulation ©2020PAK

import SceneKit
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

	func load(name:String, path:String) {
		if let pathsUrl 		= Foundation.Bundle.main.url(forResource:path, withExtension: "m4a"),
		   let source			= SCNAudioSource(url:pathsUrl) {
			assert(knownSources[name] == nil, "Redefinition of sounds not suported!")
			knownSources[name] 	= source// register soundSource
			source.isPositional = true
			source.shouldStream = false
//			source.volume 		= 1//bug; APPDEL?.config4app.float("soundVolume") ?? 1
//		  //source.rate 		= 1
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

		//tesSoundLoadding()
//		let b03  				= SCNAudioSource(named: "di-sound.m4a")
//		if let diUrl 			= Foundation.Bundle.main.url(forResource: "di-sound", withExtension: "m4a"),

//		if let source:SCNAudioSource = SCNAudioSource(named:path) {
//			assert(knownSources[name] == nil, "Redefinition of sounds not suported!")
//			knownSources[name] 	= source// register soundSource
//			source.isPositional = false
//			source.volume 		= 1//bug; APPDEL?.config4app.float("soundVolume") ?? 1
//		//	source.rate 		= 1
//			source.load()				// load audio data into soundSource
//			atApp(6, logd("SUCCEEDED loading name:\(name.field(-20)) path:\"\(path)\""))
//		}
//		else {
//			panic("FAILED loading sound \(name.field(-20)) \"\(path)\"")
//		}



	//	if let dataAsset 		= NSDataAsset(name:path),
	//	    let source		 	= SCNAudioSource(data: dataAsset.data) {
	//		SCNAudioSource(named: T##String)

//		if let scnAudioSource 	= SCNAudioSource(fileNamed: path) {
//		let path2 				= Bundle.main.path(forResource: "foo", ofType: nil)

		//if let path 			= Bundle.main.path(forResource: "da-sound", ofType: nil) {
		//    print("Sound file exists at path: \(path)")
		//} else {
		//    print("Sound file not found in bundle.")
		//}
		
//		// Assuming you have an SCNScene and an SCNNode you want to play the sound from
//	//	let scene = SCNScene(named: "yourScene.scn")
//	//	let node = scene?.rootNode.childNode(withName: "yourNode", recursively:true)
//
//		// Set up the audio source
//		let audioSource 		= SCNAudioSource(named: "da-sound")! // 'da-sound' should be in the project assets
//		audioSource.loops 		= false  // Set to true if you want the sound to loop
//		audioSource.isPositional = true  // Positional audio based on 3D location
//		audioSource.shouldStream = false  // Load sound into memory for low-latency playback
//		audioSource.volume 		= 1.0  // Adjust volume as needed
//		audioSource.load()
//
//		// Create an audio player with the audio source
//		let audioPlayer = SCNAudioPlayer(source: audioSource)
//
//		// Add the audio player to the node to play the sound
//	//	node?.addAudioPlayer(audioPlayer)



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
