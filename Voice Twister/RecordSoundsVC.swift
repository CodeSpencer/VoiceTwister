//
//  RecordSoundsVC.swift
//  Voice Twister
//
//  Created by Spencer Halverson on 2/2/16.
//  Copyright © 2016 Spencer Halverson. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class RecordSoundsVC: UIViewController, AVAudioRecorderDelegate {
    let appDel = UIApplication.shared.delegate as! AppDelegate

    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var beginText = "Tap To Record"
    var recordingText = "Recording In Progress"
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordButton.isEnabled = true
        recordingInProgress.text = beginText
        recordButton.setImage(UIImage(named: "stop_button"), for: .selected)
    }

    @IBAction func recordAudioButtonTapped(_ sender: UIButton) {
        if recordingInProgress.text == beginText {
            recordingInProgress.text = recordingText
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM-dd-yyy"
            let timestamp = formatter.string(from: date)
            let recordingName = "/\(timestamp)/my_audio.wav"
    //        let pathArray = [dirPath, recordingName]
    //        let filePath = URL.fileURL(withPathComponents: pathArray)
            let filePath = URL(fileURLWithPath: dirPath + recordingName)
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } else {
            recordingInProgress.text = beginText
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let context = appDel.persistentContainer.viewContext
            if let entity = NSEntityDescription.entity(forEntityName: "RecordedAudio", in: context) {
                let recordedAudio = NSManagedObject(entity: entity, insertInto: context)
                recordedAudio.setValue(NSDate(), forKey: "timestamp")
                recordedAudio.setValue(recorder.url.absoluteString, forKey: "filePathUrl")
                recordedAudio.setValue("No Title", forKey: "title")
                recordedAudio.setValue("Custom", forKey: "style")
                
                do {
                    try context.save()
                } catch {
                    print("Unable to save context of new audio recording")
                }
            }
            
            let playSoundsVC = storyboard?.instantiateViewController(withIdentifier: "PlaySoundsVC") as! PlaySoundsVC
            playSoundsVC.receivedAudioUrl = recorder.url.description
            navigationController?.pushViewController(playSoundsVC, animated: true)
        }else{
            print("recording was not successful")
            recordButton.setImage(UIImage(named: "microphone"), for: .normal)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error")
    }
}

