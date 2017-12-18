//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Rigoberto Sáenz Imbacuán on 12/17/17.
//  Copyright © 2017 Rigoberto Saenz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    // MARK: Actions
    @IBAction func recordAudio(_ sender: AnyObject) {
        configureUI(.recording)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: AnyObject) {
        configureUI(.notRecording)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func openProfile(_ sender: UIButton) {
        guard let url = URL(string: "https://www.linkedin.com/in/rsaenzi/") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
            
        } else {
            // Shows the error on recording
            let okAction = UIAlertAction(title: Alerts.OK, style: .default, handler: nil)
            let alert = UIAlertController(title: Alerts.Error, message: Alerts.AudioRecordingError, preferredStyle: .alert)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    // MARK: Alerts
    struct Alerts {
        static let OK = "OK"
        static let Error = "Error"
        static let AudioRecordingError = "There was an error when recording audio. Please try again later..."
    }
    
    // MARK: UI Functions
    enum RecordingState { case recording, notRecording }
    
    func configureUI(_ recordState: RecordingState) {
        switch recordState {
        case .recording:
            recordingLabel.text = "Recording in progress"
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            
        case .notRecording:
            recordingLabel.text = "Tap to Record"
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
        }
    }
}
