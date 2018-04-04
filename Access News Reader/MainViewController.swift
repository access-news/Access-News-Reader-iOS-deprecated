//
//  MainViewController.swift
//  Access News Reader
//
//  Created by Society for the Blind on 12/31/17.
//  Copyright © 2017 Society for the Blind. All rights reserved.
//

import UIKit
import AVFoundation

import Firebase
import FirebaseAuthUI

class MainViewController: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!

    var recordingSession: AVAudioSession!
    var audioRecorder:    AVAudioRecorder!
    var audioPlayer:      AVAudioPlayer!

    let publications = ["Mad River Union", "Sacramento Bee", "Sacramento Business Journal", "Santa Rosa Press Democrat", "Senior News"]

    var loginNC: UINavigationController {
        get {
            let rootVC = FUIEmailEntryViewController(authUI: FUIAuth.defaultAuthUI()!)
            return UINavigationController(rootViewController: rootVC)
        }
    }

    @objc func showLogin() {
        self.appDelegate.defaults.set(false, forKey: Constants.userLoggedIn)

        do {
            try self.appDelegate.authUI?.auth?.signOut()
        } catch {
            print(error)
        }
        self.present(loginNC, animated: true, completion: nil)
    }

    func prepareAudioRecorder(publication: String) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000,
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "-yyyyMMdd_HHmmss"

        let recordingFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(publication)\(dateFormatter.string(from: Date())).m4a")

        do {
            self.audioRecorder = try AVAudioRecorder.init(url: recordingFilename, settings: settings)
            // TODO: add audio recorder delegate? Interruptions (e.g., calls)
            //       handled elsewhere
            self.recordButton.isEnabled = true
            self.audioRecorder.prepareToRecord()
        } catch {
            print("Unable to init audio recorder.")
        }
    }

    @IBOutlet weak var publicationPicker: UIPickerView!

    @IBOutlet weak var changeEmailField: UITextField!
    @IBOutlet weak var submitEmailChange: UIButton!
    @IBAction func changeEmail(_ sender: Any) {
        if let newEmail = self.changeEmailField.text {
            self.appDelegate.authUI?.auth?.currentUser?.updateEmail(to: newEmail)
        } else {
            // TODO: modal popup: "Please specify a valid email address."
        }
    }

    @IBOutlet weak var recordButton: UIButton!
    @IBAction func recordTapped(_ sender: Any) {
        self.audioRecorder.record()

        self.recordButton.isEnabled = false
        self.recordButton.setTitle("Recording...", for: .disabled)
        self.recordButton.sizeToFit()

        self.stopButton.isEnabled = true
        self.stopButton.setTitle("Stop and save recording", for: .normal)
        self.stopButton.sizeToFit()

        self.pauseButton.isEnabled = true

        self.playButton.isEnabled = false
    }

    @IBOutlet weak var pauseButton: UIButton!
    @IBAction func pauseTapped(_ sender: Any) {
        self.audioRecorder.pause()

        self.pauseButton.isEnabled = false

        self.recordButton.isEnabled = true
        self.recordButton.setTitle("Resume recording", for: .normal)
        self.recordButton.sizeToFit()
    }

    @IBOutlet weak var stopButton: UIButton!
    @IBAction func stopTapped(_ sender: Any) {
        self.audioRecorder.stop()

        self.recordButton.isEnabled = true
        self.recordButton.setTitle("Record", for: .normal)

        self.pauseButton.isEnabled = false

        self.stopButton.isEnabled = false
        self.stopButton.setTitle("Stop", for: .disabled)

        self.playButton.isEnabled = true
    }

    @IBOutlet weak var playButton: UIButton!
    @IBAction func playTapped(_ sender: Any) {
        do {
            self.audioPlayer = try AVAudioPlayer.init(contentsOf: self.audioRecorder.url)
            self.audioPlayer.play()
        } catch {
            print("Can't play.")
        }
//        self.audioRecorder = nil

        self.pauseButton.isEnabled = true
        self.stopButton.isEnabled  = true
        self.recordButton.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.publicationPicker.dataSource = self
        self.publicationPicker.delegate =   self
        self.publicationPicker.showsSelectionIndicator = true

        // None of the controls should be enabled until a publication is selected.
        self.pauseButton.isEnabled  = false
        self.recordButton.isEnabled = false
        self.playButton.isEnabled   = false
        self.stopButton.isEnabled   = false

        // https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed == false {
                        self.recordButton.setTitle("Please enable recording at \"Settings > Privacy > Microphone\".", for: .disabled)
                        self.recordButton.sizeToFit()
                    }
                }
            }
        } catch {
            print("Setting up audiosession failed somehow.")
        }

//        self.navigationItem.leftBarButtonItem?.target = self
//        self.navigationItem.leftBarButtonItem?.action = #selector(showLogin)
//        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.publications.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.publications[row]
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel  = UILabel()
        let titleData    = publications[row]
        let pubToTheLeft = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "TimesNewRomanPS-BoldMT", size: 21.0)!,NSAttributedStringKey.foregroundColor:UIColor.darkGray])
        pickerLabel.attributedText = pubToTheLeft
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.prepareAudioRecorder(publication: self.publications[row])
        self.recordButton.isEnabled = true
    }
}
