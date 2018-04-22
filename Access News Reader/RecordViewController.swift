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

//    private static var playerItemContext = 0

    var recordingSession: AVAudioSession!
    var audioRecorder:    AVAudioRecorder?

    var articleChunks = [AVURLAsset]()
    var queuePlayer:        AVQueuePlayer?

    var articleQueue = [URL]()

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

    // Creates URL relative to apps Document directory
    func createNewRecordingURL(_ filename: String = "") -> URL {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let datetime = dateFormatter.string(from: Date())

        let documentDir =
            FileManager.default.urls(
                            for: .documentDirectory,
                            in:  .userDomainMask
            ).first!

        return documentDir.appendingPathComponent(filename + datetime + ".m4a")
    }

    func startRecorder(publication: String) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000,
            ]
        let url = self.createNewRecordingURL()

        do {
            self.audioRecorder =
                try AVAudioRecorder.init(url: url, settings: settings)
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



        self.queuePlayer = AVQueuePlayer(items: playerItems)
        self.queuePlayer?.actionAtItemEnd = .advance
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
        // Does queuePlayer needs to be nil-led first?

        self.queuePlayer?.play()
//        do {
//            self.audioPlayer = try AVAudioPlayer.init(contentsOf: self.audioRecorder.url)
//        } catch {
//            print("Can't play.")
//        }
        self.updateControlsAndStatus(
            activeControls: [.stop],
            controlStatus:  nil)
    }

    func stopPlayer() {
        self.queuePlayer?.pause()
        self.queuePlayer = nil
    }

    func resetUI() {
        self.selectedPublication = ""
        self.updateControlsAndStatus(
            activeControls: [.record],
            controlStatus:  nil)

        /* Disable "Record" button until publication is selected.
         Enabled in SelectPublication view controller.
         */
        self.toolbarItems?[1].isEnabled = false

        /* TODO Add article title (see issue #14 and #21) */

        self.audioRecorder = nil
        self.queuePlayer = nil

        if self.articleChunks.isEmpty == false {
            self.assembleChunks()
        }
    }

    /* TODO Run in background #22 */
    func assembleChunks() {
        let composition       = AVMutableComposition()

        let compositionTrack  =
            composition.addMutableTrack(
                withMediaType:    .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertAt =
            CMTimeRange(start: kCMTimeZero, end: kCMTimeZero)

        repeat {
            let asset          = self.articleChunks.removeFirst()
            let assetTrack     = asset.tracks(withMediaType: .audio).first!
            let assetTimeRange = CMTimeRange(
                                     start: kCMTimeZero,
                                     end:   asset.duration)
            do {
                /* QUESTION
                   `AVMutableComposition` and `AVMutableCompositionTrack` both
                    have a method called `insertTimeRange`, with the only
                    difference that they take an `AVAsset` and an `AVAssetTrack`
                    respectively.
                    In this app, there is only one track per asset (i.e. the
                    article audio), so could I just skip the part where I am
                    messing with tracks?
                */
                try compositionTrack?.insertTimeRange(assetTimeRange,
                                                      of: assetTrack,
                                                      at: insertAt.end)
            } catch {
                NSLog("Unable to compose asset track.")
            }

            let nextDuration =
                insertAt.duration + assetTimeRange.duration
            insertAt =
                CMTimeRange(start: kCMTimeZero, duration: nextDuration
            )
        } while self.articleChunks.count == 0

        let exportSession = AVAssetExportSession(
                                asset:      composition,
                                presetName: AVAssetExportPresetAppleM4A
        )
        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = self.createNewRecordingURL("exported-")
        // TODO exportSession?.metadata = ...
        exportSession?.canPerformMultiplePassesOverSourceMediaData = true
        /* TODO? According to the docs, if multiple passes are enabled and
                 "When the value of this property is nil, the export session
                 will choose a suitable location when writing temporary files."
         */
        // exportSession?.directoryForTemporaryFiles = ...

        // Listing all cases for completeness sake, but may just use `.completed`
        // and ignore the rest with a `default` clause.
        // OR
        // because the completion handler is run async, KVO would be more appropriate
        exportSession?.exportAsynchronously {

            switch exportSession?.status {
            case .unknown?: break
            case .waiting?: break
            case .exporting?: break
            case .completed?: break
            case .failed?: break
            case .cancelled?: break
            case .none: break
            }
        }

        /* TODO
           Files seem to be exported, but couldn't test the playback. So:
           1. Delete all audio currently in the document folder
           2. Create an export
           3. Play it back
        */
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
        updateControlsAndStatus(
            activeControls: [.stop],
            controlStatus:  nil)
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
        , controlStatus  s: (text: String, colour: UIColor)?
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
