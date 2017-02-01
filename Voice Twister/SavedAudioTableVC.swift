//
//  SavedAudioTableVC.swift
//  Voice Twister
//
//  Created by Spencer Halverson on 1/29/17.
//  Copyright © 2017 Spencer Halverson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum AudioStyle: String {
    case Chipmunk = "Chipmunk"
    case Rabbit = "Rabbit"
    case Darthvader = "Darthvader"
    case Snail = "Snail"
    case Custom = "Custom"
}

class SavedAudioTableVC: UITableViewController {
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var audioFiles = [RecordedAudio]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedAudio()
    }
    
    func fetchSavedAudio() {
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "RecordedAudio")
        do {
            audioFiles = try context.fetch(request) as! [RecordedAudio]
        } catch {
            print("Could not load saved audio files")
        }
        tableView.reloadData()
    }
    
    func setImageForCell(style: AudioStyle) -> UIImage {
        switch style {
        case .Chipmunk:
            return UIImage(named: "chipmunk")!
        case .Darthvader:
            return UIImage(named: "darthvader")!
        case .Rabbit:
            return UIImage(named: "rabbit")!
        case .Snail:
            return UIImage(named: "snail")!
        default:
            return UIImage(named: "microphone")!
        }
    }
    
    func formatTimestamp(date: Date, desiredFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = desiredFormat
        let string = formatter.string(from: date)
        return string
    }
    
}

extension SavedAudioTableVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedAudioCell")!
        let audio = audioFiles[indexPath.row]
        cell.textLabel?.text = audio.title
        cell.detailTextLabel?.text = formatTimestamp(date: audio.timestamp as! Date, desiredFormat: "MMM dd, yyyy")
        let style = AudioStyle(rawValue: audio.style ?? "Custom")
        cell.imageView?.image = setImageForCell(style: style!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = audioFiles[indexPath.row]
        let playSoundVC = storyboard?.instantiateViewController(withIdentifier: "PlaySoundsVC") as! PlaySoundsVC
        playSoundVC.receivedAudioUrl = audio.filePathUrl ?? ""
        navigationController?.pushViewController(playSoundVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
