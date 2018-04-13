//
//  RecordViewController.swift
//  Access News Reader
//
//  Created by Society for the Blind on 4/12/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    var recordingSession: AVAudioSession!
    var audioRecorder:    AVAudioRecorder?
    var audioPlayer:      AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isToolbarHidden = false

        // https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
//                    let tooltip: String
//                    let controlStatus: (String, UIColor)?

//                    if allowed == true {
//                        tooltip = "Please choose a publication first to start recording."
//                        controlStatus = ("Ready to record.", .gray)
//                    } else {
//                        tooltip = "Please enable recording at \"Settings > Privacy > Microphone\"."
//                        controlStatus = ("Recording disabled.", .magenta)
//                    }

                    self.updateControlsAndStatus(
                        activeControls:[.record, .play, .submit])
//                    self.updateControlsAndStatus(
//                        activeControls: [],
//                        tooltipText:    NSAttributedString(string: tooltip),
//                        controlStatus:  controlStatus)
                }
            }
        } catch {
            print("Setting up audiosession failed somehow.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Helper functions

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

    @objc func recordTapped() {
        print("\n\nbalabab")
    }

    @objc func stopTapped() {
        print("works\\n\n")
    }

    @objc func playTapped() {
        print("works\\n\n")
    }

    @objc func queueTapped() {
        print("works\\n\n")
    }

    @objc func submitTapped() {
        print("works\\n\n")
    }

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
//        , tooltipText    t: NSAttributedString?
//        , controlStatus  s: (text: String, colour: UIColor)?
        )
    {

        func flexSpace() -> UIBarButtonItem {
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }

        var buttons: [UIBarButtonItem] = [flexSpace()]

        /* There are more clever ways to do this, but this solution is
            + easy on the eyes
            + quickly updateable
            + there is a finite number of items
            + (so far) not used anywhere else in the UI
            + and, most importantly, I will know what I did when I return to this
              after months
        */
        if c.contains(.record) {
            buttons +=
                [ UIBarButtonItem(title: "Record",
                                  style: .plain,
                                  target: target,
                                  action: #selector(self.recordTapped))
                    , flexSpace()]
        }

        if c.contains(.stop) {
            buttons +=
                [ UIBarButtonItem(title: "Stop/Pause",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.stopTapped))
                    , flexSpace()]
        }

        if c.contains(.play) {
            buttons +=
                [ UIBarButtonItem(title: "Play",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.playTapped))
                    , flexSpace()]
        }

        if c.contains(.queue) {
            buttons +=
                [ UIBarButtonItem(title: "Queue",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.queueTapped))
                    , flexSpace()]
        }

        if c.contains(.submit) {
            buttons +=
                [ UIBarButtonItem(title: "Submit",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.submitTapped))
                    , flexSpace()]
        }

        // https://stackoverflow.com/questions/10825572/uitoolbar-not-showing-uibarbuttonitem
        self.setToolbarItems(buttons, animated: true)

//        self.recordButton.isEnabled = c.contains(.record)
//        self.stopButton.isEnabled   = c.contains(.stop)
//        self.playButton.isEnabled   = c.contains(.play)
//        self.queueButton.isEnabled  = c.contains(.queue)
//        self.submitButton.isEnabled = c.contains(.submit)
//
//        let str = t != nil ? t : NSAttributedString(string: "")
//        self.tooltips.attributedText = str
//
//        if s != nil {
//            self.audioControlStatus.textColor = s!.colour
//            self.audioControlStatus.text      = s!.text
//        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
