//
//  PlaySoundsVC.swift
//  Voice Twister
//
//  Created by Spencer Halverson on 2/3/16.
//  Copyright © 2016 Spencer Halverson. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsVC: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudioUrl = ""
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(receivedAudioUrl)
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let audioUrl = URL(fileURLWithPath: documents).appendingPathComponent(receivedAudioUrl)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl, fileTypeHint: ".wav")
        } catch {
            print("Could not locate file path")
        }
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: audioUrl)
    }
    
    @IBAction func playRecordingSlow(_ sender: UIButton) {
        playbackSpeed(0.5)
    }
    
    @IBAction func playRecordingFast(_ sender: UIButton) {
        playbackSpeed(2.0)
    }
    
    func playbackSpeed(_ rate: Float){
        stopAudio()
        audioPlayer.currentTime = 0.0
        audioPlayer.rate = rate
        audioPlayer.setVolume(5.0, fadeDuration: 0.5)
        audioPlayer.play()
    }
    
    func stopAudio(){
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        audioEngine.stop()
        audioEngine.reset()
    }
    
    @IBAction func playRecordingChipMunk(_ sender: UIButton) {
        playAudioWithVariablePitch(1300)
    }
    
    @IBAction func playRecordingDarthVader(_ sender: UIButton) {
        playAudioWithVariablePitch(-1300)
    }
    
    func playAudioWithVariablePitch(_ pitch: Float){
        stopAudio() 
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        
        changePitchEffect.pitch = pitch
        audioEngine.attach(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        try! audioEngine.start()
        
        audioPlayerNode.play()
    }
    
    @IBAction func stopPlaying(_ sender: UIButton) {
        stopAudio()
    }
}
