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
    var audioRecorder:    AVAudioRecorder?
    var audioPlayer:      AVAudioPlayer?
    var selectedPublication: String!

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

    func setRecorder(publication: String) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000,
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "_yyyy-MM-dd-HHmmss"

        let publicationCondensed = "\(publication.split(separator: " ").joined(separator: "-"))"
        let datetime = dateFormatter.string(from: Date())
        let filename = publicationCondensed + datetime + ".m4a"
        let file = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        do {
            self.audioRecorder = try AVAudioRecorder.init(url: file, settings: settings)
            // TODO: add audio recorder delegate? Interruptions (e.g., calls)
            //       are handled elsewhere anyway
        } catch {
            print("Unable to init audio recorder.")
        }
    }

    func setPlayer() {
        do {
            self.audioPlayer = try AVAudioPlayer.init(contentsOf: (self.audioRecorder?.url)!)
        } catch {
            print("Can't play.")
        }
    }

    func resetAudioInstances() {

    }

    @IBOutlet weak var publicationPicker: UIPickerView!
    @IBOutlet weak var tooltips: UITextView!
    @IBOutlet weak var audioControlStatus: UILabel!
    @IBOutlet weak var currentFileLabel: UILabel!

// TODO move this to wherever settings will be
//
//    @IBOutlet weak var changeEmailField: UITextField!
//    @IBOutlet weak var submitEmailChange: UIButton!
//    @IBAction func changeEmail(_ sender: Any) {
//        if let newEmail = self.changeEmailField.text {
//            self.appDelegate.authUI?.auth?.currentUser?.updateEmail(to: newEmail)
//        } else {
//            // TODO: modal popup: "Please specify a valid email address."
//        }
//    }

    // https://cocoacasts.com/how-to-work-with-bitmasks-in-swift/
    struct Controls: OptionSet {
        let rawValue: Int

        static let record = Controls(rawValue: 1 << 0)
        static let stop   = Controls(rawValue: 1 << 1)
        static let play   = Controls(rawValue: 1 << 2)
        static let queue  = Controls(rawValue: 1 << 3)
        static let submit = Controls(rawValue: 1 << 4)
    }

    func updateControlsAndStatus
        ( activeControls c: Controls
        , tooltipText    t: NSAttributedString?
        , controlStatus  s: (text: String, colour: UIColor)?
        )
    {
        self.recordButton.isEnabled = c.contains(.record)
        self.stopButton.isEnabled   = c.contains(.stop)
        self.playButton.isEnabled   = c.contains(.play)
        self.queueButton.isEnabled  = c.contains(.queue)
        self.submitButton.isEnabled = c.contains(.submit)

        let str = t != nil ? t : NSAttributedString(string: "")
        self.tooltips.attributedText = str

        if s != nil {
            self.audioControlStatus.textColor = s!.colour
            self.audioControlStatus.text      = s!.text
        }

        // Only querying self.audioRecorder because only the current
        // recording will ever be loaded in here (that is used to
        // instantiate AVAudioPlayer later)
        self.currentFileLabel.text =
            self.audioRecorder?.url.lastPathComponent ?? ""
        self.currentFileLabel.sizeToFit()
    }

    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBAction func recordTapped(_ sender: Any) {
        if self.audioRecorder == nil {
            self.setRecorder(publication: self.selectedPublication)
        }
        self.audioRecorder?.record()

        self.updateControlsAndStatus(
            activeControls: [.stop],
            tooltipText:    nil,
            controlStatus:  ("Recording...", .red))
    }

    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBAction func stopTapped(_ sender: Any) {
        let controlStatus: (String, UIColor)

        if self.audioRecorder?.isRecording == true {
            self.audioRecorder?.stop()
            controlStatus = ("Recording stopped.", .red)
        } else {
            audioPlayer?.stop()
            controlStatus = ("Playback stopped.", .green)
        }

        let tooltip =
            [ "Tap Record to continue recording."
            , "Tap Play to list to your recording so far."
            , "Tap Queue to add file to the list of recordings to be submitted later."
            , "Tap Submit to upload current file and queued recordings right now."
            ].joined(separator: "\n\n")

        self.updateControlsAndStatus(
            activeControls: [.record, .play, .queue, .submit],
            tooltipText:    NSAttributedString(string: tooltip),
            controlStatus:  controlStatus)
    }

    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBAction func playTapped(_ sender: Any) {
        if self.audioPlayer == nil {
            self.setPlayer()
        }
        self.audioPlayer?.play()

        self.updateControlsAndStatus(
            activeControls: [.stop],
            tooltipText:    NSAttributedString(string: "Tap Stop/Pause to halt playback."),
            controlStatus:  ("Playing recording...", .green))
    }

    @IBOutlet weak var queueButton: UIBarButtonItem!
    @IBAction func queueTapped(_ sender: Any) {
        // Tap Record if you would like to read another article from <publication>
        // Or choose another publication to record from another
        self.resetAudioInstances()
    }

    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBAction func submitButton(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isToolbarHidden = false

        self.publicationPicker.dataSource = self
        self.publicationPicker.delegate =   self
        self.publicationPicker.showsSelectionIndicator = true

        self.tooltips.isEditable = false

        // https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    let tooltip: String
                    let controlStatus: (String, UIColor)?

                    if allowed == true {
                        tooltip = "Please choose a publication first to start recording."
                        controlStatus = ("Ready to record.", .gray)
                    } else {
                        tooltip = "Please enable recording at \"Settings > Privacy > Microphone\"."
                        controlStatus = ("Recording disabled.", .magenta)
                    }

                    self.updateControlsAndStatus(
                        activeControls: [],
                        tooltipText:    NSAttributedString(string: tooltip),
                        controlStatus:  controlStatus)
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
        self.selectedPublication = self.publications[row]
        self.recordButton.isEnabled = true
    }
}
