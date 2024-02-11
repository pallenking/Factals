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
/// Let scn's do play
protocol SoundFoo  {
	func play(sound:String)
}
//extension SoundFoo {
//	func play(sound:String) {
//		APP.appSounds.play(sound:sound, onNode:self)
//	}
//}
extension SCNNode : SoundFoo {
	func play(sound:String) {
bug
//		APP.appSounds.play(sound:sound, onNode:self)
	}
//	func play(sound: String) {
//		print("::::::::::::::::: PLAYING SOUND \(sound) :::::::::::")
//bug;//	assert(APPDEL != nil, "play(sound:\(sound)), but APPDEL is nil")
//	//	APPDEL!.appSounds.play(sound:sound, onNode:self)
//	}
}
class Sounds : Logd {
	var uid: UInt16				= randomUid()
	// NEVER NSCopying, Equatable
	 // MARK: - 5.4 Sound
	var knownSources : [String:SCNAudioSource] = [:]
	func configure(from:FwConfig) {
		print("Sounds.configure UNIPLMEMENTED")
	}
	func load(name:String, path:String) {
		if let source:SCNAudioSource = SCNAudioSource(fileNamed: path) {
			assert(knownSources[name] == nil, "Redefinition of sounds not suported!")
			knownSources[name] 	= source// register soundSource
			source.isPositional = false
bug//		source.volume 		= APPDEL?.config4app.float("soundVolume") ?? 1
		//	source.rate 		= 1
			source.load()				// load audio data into soundSource
			atApp(6, logd("SUCCEEDED loading name:\(name.field(-20)) path:\"\(path)\""))
		}
		else {
			panic("FAILED loading sound \(name.field(-20)) \"\(path)\"")
		}
	}
	func play(sound:String, onNode onNode_:SCNNode?=nil) {
		if falseF /* Disable? trueF*//*falseF*/ {		return					}
				
		let node : SCNNode		= onNode_ ??	// 1. SCNNode supplied else
		{										// 2. Search through rootVews for SCNNode
			for rootVew in FACTALSMODEL?.rootVews ?? [] {
				return rootVew.scn				// found
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
		
//		logg("\(node.fullName) play \"\(sound)\"")
//		node.removeAudioPlayer(audioPlayer)
	}
}
