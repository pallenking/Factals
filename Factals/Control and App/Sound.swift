//  Sound.swift -- Support the playing sounds during simulation ©2020PAK
import SceneKit
import AVFoundation

protocol SoundProtocol {
	func play(sound:String?)
}
let knownSounds  : [String:String] = [	// name -> fileName in Assets
		   "tick":	  "tick-sound",
		   "tock":	  "tock-sound",
			  "t":		 "t-sound",
			  "b":		 "b-sound",
		"forward": "forward-sound",
	   "backward":"backward-sound",
			 "da":		"da-sound",
			 "di":		"di-sound",
]
extension SCNNode : SoundProtocol {
	func play(sound:String?) {
		print("\(wallTime()):\t\t--- \(sound ?? "nil") ---")
		guard let sound								 else { return 				}// no sound specified
		guard let fileName 		= knownSounds[sound] else { return 				}// a known sound

		 // SCNAudioSource(url:) fetches from assets (others initializers don't)
		guard let audioDataAsset = NSDataAsset(name:fileName) else
		{	print("Failed to load file '\(fileName)' audio asset");	return		}
		let t1URL 				= FileManager.default.temporaryDirectory
								   .appendingPathComponent("t1URL")
		do
		{	try audioDataAsset.data.write(to:t1URL)								}
		 catch
		 {	print("Failed to write audio data to URL '\(fileName)': ERROR \(error)")}

/**/	guard let audioSource	= SCNAudioSource(url:t1URL) else { return		}
		audioSource.isPositional = true
		audioSource.shouldStream = false
		audioSource.volume 		= 1//10//bug; APPDEL?.config4app.float("soundVolume") ?? 1
		audioSource.rate 		= 1//0.1
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
class Sound : Logd {
	let nameTag					= getNametag()
	// NEVER NSCopying, Equatable
	 // MARK: - 5.4 Sound
	var knownSources : [String:SCNAudioSource] = [:]
	init(configure:FwConfig) {
		nop
	}
}




// Garbage:
//extension Part {
//	func applyProp(_ prop:String, withVal val:String) {
//		let dummy = Atom()
//		if prop == "sound" {	// e.g. "sound:di-sound" or
//			let soundPort		= dummy.port(named:"SND")					//Port *sndPPort		= [self port4leafBinding:@"SND"];
//			let soundAtom		= soundPort?.atom as? PortSound				//SoundAtom *sndAtom	= mustBe(SoundAtom, sndPPort.atom);
//bug;		soundAtom!.sounds	= [val]
//		}
//		if prop == "sounds" {	// e.g. "sound:di-sound" or
//bug
//		}
//	}
//}
