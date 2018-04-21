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

    private static var playerItemContext = 0

    var recordingSession: AVAudioSession!
    var audioRecorder:    AVAudioRecorder?

    var articleChunks = [AVURLAsset]()
    var qPlayer:        AVQueuePlayer?

    @IBOutlet weak var controlStatus: UILabel!

    var publicationCell: UITableViewCell {
        get {
            let mainTVC = self.childViewControllers.first as! MainTableViewController
            return mainTVC.tableView.visibleCells.first!
        }
    }

    var selectedPublication: String {
        get {
            return (publicationCell.textLabel?.text)!
        }
        set(newPublication) {
            publicationCell.textLabel?.text = newPublication
        }
    }

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

                    self.resetUI()
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

    func startRecorder(publication: String) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000,
            ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let datetime = dateFormatter.string(from: Date())

//        let publicationCondensed = "\(publication.split(separator: " ").joined(separator: "-"))"

//        let filename = publicationCondensed + datetime + ".m4a"
        let documentDir = FileManager.default.urls(
                              for: .documentDirectory,
                              in:  .userDomainMask
                          ).first!
        let file = documentDir.appendingPathComponent(datetime + ".m4a")

        do {
            self.audioRecorder =
                try AVAudioRecorder.init(url: file, settings: settings)
            self.audioRecorder?.record()
            // TODO: add audio recorder delegate? Interruptions (e.g., calls)
            //       are handled elsewhere anyway
        } catch {
            NSLog("Unable to init audio recorder.")
        }
    }

    func stopRecorder() {
        self.audioRecorder?.stop()
        let assetURL  = self.audioRecorder!.url
        self.audioRecorder = nil

        /* https://developer.apple.com/documentation/avfoundation/avurlassetpreferprecisedurationandtimingkey
         "If you intend to insert the asset into an AVMutableComposition
         object, precise random access is typically desirable, and the
         value of true is recommended."
         */
        let assetOpts = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset     = AVURLAsset(url: assetURL, options: assetOpts)

        self.articleChunks.append(asset)

        let assetKeys = ["playable"]
        let playerItems = self.articleChunks.map {
            AVPlayerItem(asset: $0, automaticallyLoadedAssetKeys: assetKeys)
        }

//        playerItem.addObserver(
//            self,
//            forKeyPath: #keyPath(AVPlayerItem.status),
//            options:    [.old, .new],
//            context:    &RecordViewController.playerItemContext)



        self.qPlayer = AVQueuePlayer(items: playerItems)
        self.qPlayer?.actionAtItemEnd = .advance
    }

//    override func observeValue(forKeyPath keyPath: String?,
//                               of object: Any?,
//                               change: [NSKeyValueChangeKey : Any]?,
//                               context: UnsafeMutableRawPointer?) {
//        // Only handle observations for the playerItemContext
//        guard context == &RecordViewController.playerItemContext else {
//            super.observeValue(forKeyPath: keyPath,
//                               of: object,
//                               change: change,
//                               context: context)
//            return
//        }
//
//        if keyPath == #keyPath(AVPlayerItem.status) {
//            let status: AVPlayerItemStatus
//
//            // Get the status change from the change dictionary
//            if let statusNumber = change?[.newKey] as? NSNumber {
//                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
//            } else {
//                status = .unknown
//            }
//
//            // Switch over the status
//            switch status {
//            case .readyToPlay:
////                self.toolbarItems?[3].isEnabled = true
//                print("lofa")
//            case .failed:
//            // Player item failed. See error.
//                print("failed")
//            case .unknown:
//                // Player item is not yet ready.
//                print("unknown")
//            }
//        }
//    }

    func startPlayer() {
        // Does qPlayer needs to be nil-led first?

        self.qPlayer?.play()
//        do {
//            self.audioPlayer = try AVAudioPlayer.init(contentsOf: self.audioRecorder.url)
//        } catch {
//            print("Can't play.")
//        }
        self.updateControlsAndStatus(activeControls: [.stop])
    }

    func stopPlayer() {
        self.qPlayer?.pause()
        self.qPlayer = nil
    }

    func resetUI() {
        self.selectedPublication = ""
        self.updateControlsAndStatus(activeControls: [.record])

        /* Disable "Record" button until publication is selected.
         Enabled in SelectPublication view controller.
         */
        self.toolbarItems?[1].isEnabled = false

        /* TODO Add article title (see issue #14 and #21) */

        self.audioRecorder = nil
        self.qPlayer = nil

        if self.articleChunks.isEmpty == false {
            self.assembleChunks()
        }
    }

    /* TODO Run in background #22 */
    func assembleChunks() {
        let composition = AVMutableComposition()
        let audioTrack  = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertAt =
            CMTimeRange(start: kCMTimeZero, end: kCMTimeZero)

        repeat {
            let asset = self.articleChunks.removeFirst()
            let assetTimeRange = CMTimeRange(start: kCMTimeZero, end: asset.duration)
            do {
                try audioTrack?.insertTimeRange(
                    assetTimeRange,
                    of: asset.tracks(withMediaType: .audio).first!,
                    at: insertAt.end)
            } catch {
                NSLog("Unable to compose asset track.")
            }

            let nextDuration =
                insertAt.duration + assetTimeRange.duration
            insertAt =
                CMTimeRange(start: kCMTimeZero, duration: nextDuration)
        } while self.articleChunks.count == 0
    }

    @objc func recordTapped() {
        if self.audioRecorder == nil {
            self.startRecorder(publication: self.selectedPublication)
        }

        self.updateControlsAndStatus(
            activeControls: [.stop],
            controlStatus: ("Recording...", .red)
        )
    }

    @objc func stopTapped() {
        let status: (String, UIColor)

        if self.audioRecorder?.isRecording == true {
            self.stopRecorder()
            status = ("Recording stopped.", .red)
        } else {
            self.stopPlayer()
            status = ("Playback paused.", .green)
        }

        self.updateControlsAndStatus(
            activeControls: [.record, .play, .queue, .submit],
            controlStatus:  status)

        /* Disable "Play" button until AVPlayerItemStatus comes up as
           `readyToPlay`. Enabled in `observeValue`.
        */
//        self.toolbarItems?[3].isEnabled = false
    }

    @objc func playTapped() {
        self.startPlayer()
        updateControlsAndStatus(activeControls: [.stop])
    }

    @objc func queueTapped() {
        self.resetUI()
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
        , controlStatus  s: (text: String, colour: UIColor)? = nil
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
                                  target: self,
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
        self.setToolbarItems(buttons, animated: false)
//
//        let str = t != nil ? t : NSAttributedString(string: "")
//        self.tooltips.attributedText = str

        if s != nil {
            self.controlStatus.textColor = s!.colour
            self.controlStatus.text      = s!.text
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
