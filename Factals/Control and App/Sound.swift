//  Sound.swift -- Support the playing sounds during simulation ©2020PAK
import SceneKit
import AVFoundation

protocol SoundProtocol {
	func play(sound:String?)
}
let scnAudioSources : [String:SCNAudioSource] = [	// name -> fileName in Assets
	// Initial Sound Library, from FactalWorkbench.
		   "tick": scnAudioSource(name:    "tick-sound"),
		   "tock": scnAudioSource(name:    "tock-sound"),
			  "t": scnAudioSource(name:       "t-sound"),
			  "b": scnAudioSource(name:       "b-sound"),
		"forward": scnAudioSource(name: "forward-sound"),
	   "backward": scnAudioSource(name:"backward-sound"),
			 "da": scnAudioSource(name:      "da-sound"),
			 "di": scnAudioSource(name:      "di-sound"),
]
func scnAudioSource(name:String) -> SCNAudioSource {

	 // Uses SCNAudioSource, the _only_ way to fetch sounds in assets!
	guard let audioDataAsset 	= NSDataAsset(name:name) else
	{	fatalError("Failed to load file '\(name)' audio asset")			}
	let fileUrl 				= FileManager.default.temporaryDirectory.appendingPathComponent("temp.data\(name)")
 
	do	// Write to disk
	{	try audioDataAsset.data.write(to:fileUrl)								}
	 catch
	 {	print("Failed to write audio data to URL '\(name)': ERROR \(error)")	}

		// Read from disk
	guard let rv				= SCNAudioSource(url:fileUrl) else { fatalError() }
	rv.isPositional 			= true
	rv.shouldStream 			= false
	rv.volume 					= params4app.float("soundVolume") ?? 1	// = 1//10//
	rv.rate 					= 1 //0.1
	rv.load() // Preload the audio for smoother playback
	return rv
}

extension SCNNode : SoundProtocol {
	func play(sound:String?) {
		guard let sound, sound != ""	 			  else { return 			}// no sound specified
		audioPlayers.forEach({self.removeAudioPlayer($0)})
		guard let audioSource	= scnAudioSources[sound] else { return 			}
		let audioPlayer			= SCNAudioPlayer(source:audioSource)
		addAudioPlayer(audioPlayer)								// let x1 = node.audioPlayers

		 // Command it to play:
		//print("\(wallTime()):\t\t--- \(sound) ---,  \(audioPlayers.count) audioPlayer(s)")
		let playAction			= SCNAction.playAudio(audioSource, waitForCompletion:false)
		runAction(playAction)
		audioPlayer.didFinishPlayback = { //[weak self] in
	//		self?.removeAudioPlayer(audioPlayer)
		//	print("\(wallTime()):\t\t\t--- Audio playback is complete.")
		}
	}
}
