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
protocol SoundFoo : SCNNode  {
	func play(sound:String)
}
extension SCNNode : SoundFoo {
	func play(sound: String) {
		print("::::::::::::::::: PLAYING SOUND \(sound) :::::::::::")
bug//	assert(APPDEL != nil, "play(sound:\(sound)), but APPDEL is nil")
//		APPDEL!.appSounds.play(sound:sound, onNode:self)
	}
}
//extension SoundFoo {
//	func playSound(sound:String) { 
//		AppDel!.appSounds.play(sound:sound, onNode:self)
//	}
//}
class Sounds : NSObject {					// NOT NSObject
	 // MARK: - 5.4 Sound
	var knownSources : [String:SCNAudioSource] = [:]
	func load(name:String, path:String) {
		if let source:SCNAudioSource = SCNAudioSource(fileNamed: path) {
			assert(knownSources[name] == nil, "Redefinition of sounds not suported!")
			knownSources[name] 	= source// register soundSource
			source.isPositional = false
bug//		source.volume 		= APPDEL?.config4app.float("soundVolume") ?? 1
		//	source.rate 		= 1
			source.load()				// load audio data into soundSource
			atCon(6, logd("SUCCEEDED loading name:\(name.field(-20)) path:\"\(path)\""))
		}
		else {
			panic("FAILED loading sound \(name.field(-20)) \"\(path)\"")
		}
	}
	func play(sound:String, onNode:SCNNode?=nil) {
		if trueF {				//trueF//falseF
			return
		}
		guard let node			= onNode ?? DOCfwSceneQ?.rootScn else {
			return print("###### Couldn't find SCNNode to play sound")
		}
bug//	DOC.fwView?.audioListener = node

		 // Get audio source:
		guard let source		= knownSources[sound] else {
			return print("###### Sound source '\(sound)' unknow")
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
