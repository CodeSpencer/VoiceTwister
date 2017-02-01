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

class SavedAudioCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

class SavedAudioTableVC: UITableViewController {
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var audioFiles = [RecordedAudio]()
    var editButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItems))
        navigationItem.leftBarButtonItem = editButton
        fetchSavedAudio()
    }
    
    func editItems() {
        tableView.setEditing(true, animated: true)
        editButton.title = "Done"
        editButton.action = #selector(doneEditing)
    }
    
    func doneEditing() {
        tableView.setEditing(false, animated: true)
        editButton.title = "Edit"
        editButton.action = #selector(editItems)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedAudioCell") as! SavedAudioCell
        let audio = audioFiles[indexPath.row]
        cell.titleLabel.text = audio.title
        cell.dateLabel.text = formatTimestamp(date: audio.timestamp as! Date, desiredFormat: "MMM dd, yyyy")
        let style = AudioStyle(rawValue: audio.style ?? "Custom")
        cell.thumbnailImageView?.image = setImageForCell(style: style!)
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .destructive, title: "Delete") {_ in
            self.appDel.deleteRecording(recordedAudio: self.audioFiles[indexPath.row])
            self.audioFiles.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
        return [action]
    }
}
