//  Sound.swift -- Support the playing sounds during simulation ©2020PAK
import SceneKit
import AVFoundation

protocol SoundProtocol {
	func play(sound:String?)
}
let audioSources : [String:SCNAudioSource] = [	// name -> fileName in Assets
		   "tick": source(name:    "tick-sound"),
		   "tock": source(name:    "tock-sound"),
			  "t": source(name:       "t-sound"),
			  "b": source(name:       "b-sound"),
		"forward": source(name: "forward-sound"),
	   "backward": source(name:"backward-sound"),
			 "da": source(name:      "da-sound"),
			 "di": source(name:      "di-sound"),
]
func source(name:String) -> SCNAudioSource {

	 // SCNAudioSource(url:) fetches from assets (others initializers don't)
	guard let audioDataAsset 	= NSDataAsset(name:name) else
	{	fatalError("Failed to load file '\(name)' audio asset")			}
	let url 					= FileManager.default.temporaryDirectory.appendingPathComponent("temp.data\(name)")
	do
	{	try audioDataAsset.data.write(to:url)									}
	 catch
	 {	print("Failed to write audio data to URL '\(name)': ERROR \(error)")	}

	guard let source			= SCNAudioSource(url:url) else { fatalError()	}
	source.isPositional 		= true
	source.shouldStream 		= false
	source.volume 				= 1//10//bug; APPDEL?.config4app.float("soundVolume") ?? 1
	source.rate 				= 1//0.1
	source.load() // Preload the audio for smoother playback
	return source
}
//testSounds() {
//
//}

extension SCNNode : SoundProtocol {
	func play(sound:String?) {
		guard let sound, sound != ""	 			 else { return 				}// no sound specified
		audioPlayers.forEach({self.removeAudioPlayer($0)})
		let audioSource			= audioSources[sound]!
		let audioPlayer			= SCNAudioPlayer(source:audioSource)
		addAudioPlayer(audioPlayer)								// let x1 = node.audioPlayers

		 // Command it to play:
		print("\(wallTime()):\t\t--- \(sound) ---,  \(audioPlayers.count) audioPlayer(s)")
		let playAction			= SCNAction.playAudio(audioSource, waitForCompletion:false)
		runAction(playAction)
		audioPlayer.didFinishPlayback = { //[weak self] in
	//		self?.removeAudioPlayer(audioPlayer)
			print("\(wallTime()):\t\t\t--- Audio playback is complete.")
		}
	}
}
