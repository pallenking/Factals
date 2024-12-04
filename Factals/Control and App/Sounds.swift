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

		let url 				= Foundation.Bundle.main.url(forResource: "da-sound",
									withExtension: "m4a", subdirectory: "Assets.xcassets/da-sound.dataset")
		if url == nil {			print("Failed to find audio file at expected path")	}

		let source2 = SCNAudioSource(named: "da-sound.dataset/da-sound.m4a")
		if let source = SCNAudioSource(named:"da-sound") {
			source.load()
			nop
		} else {
			print("Failed to load audio source 'da-sound'")
		}


		if let source:SCNAudioSource = SCNAudioSource(named:path) {
			assert(knownSources[name] == nil, "Redefinition of sounds not suported!")
			knownSources[name] 	= source// register soundSource
			source.isPositional = false
			source.volume 		= 1//bug; APPDEL?.config4app.float("soundVolume") ?? 1
		//	source.rate 		= 1
			source.load()				// load audio data into soundSource
			atApp(6, logd("SUCCEEDED loading name:\(name.field(-20)) path:\"\(path)\""))
		}
		else {
			panic("FAILED loading sound \(name.field(-20)) \"\(path)\"")
		}
	}
	func play(sound:String, onNode:SCNNode?=nil) {
		//return
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
