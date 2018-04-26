//
//  RecordViewController.swift
//  Access News Reader
//
//  Created by Society for the Blind on 4/12/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class RecordViewController: UIViewController {

//    private static var playerItemContext = 0

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mainTVC: UITableViewController!

    var recordingSession: AVAudioSession!
    var audioRecorder:    AVAudioRecorder?
    var queuePlayer:      AVQueuePlayer?

    var articleChunks = [AVURLAsset]()

    @IBOutlet weak var controlStatus: UILabel!

    var publicationCell: UITableViewCell {
        get {
            return self.mainTVC.tableView.visibleCells.first!
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
        self.mainTVC = self.childViewControllers.first as! MainTableViewController
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

                    self.newArticleReset(activeControls: [.record])

                    /* Disable "Record" button until publication is selected.
                     Enabled in SelectPublication view controller.

                     Not pretty, because the assumption that the "Record" button is the
                     first is hard coded, but no point in making `updateControlsAndStatus`
                     more general, because
                     + this is the only control that is disabled conditionally
                     + `updateControlAndStatus` is internal (i.e., private to this module),
                     and this exception is noted here
                     */
                    self.toolbarItems?[1].isEnabled = false
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

        self.queuePlayer?.play()

        self.updateControlsAndStatus(
            activeControls: [.stop],
            controlStatus:  nil)
    }

    func stopPlayer() {
        self.queuePlayer?.pause()
        self.queuePlayer = nil
    }

    func newArticleReset(activeControls: Controls) {

        self.updateControlsAndStatus(
            activeControls: activeControls,
            controlStatus:  nil)

        /* TODO Add article title (see issue #14 and #21) */

        self.audioRecorder = nil
        self.queuePlayer   = nil
    }

    func newPublicationReset(activeControls: Controls) {
        self.selectedPublication = ""
        self.newArticleReset(activeControls: activeControls)
    }

    func concatChunks() {
        let composition = AVMutableComposition()

        var insertAt = CMTimeRange(start: kCMTimeZero, end: kCMTimeZero)

        for asset in self.articleChunks {
            let assetTimeRange = CMTimeRange(start: kCMTimeZero, end: asset.duration)

            do {
                try composition.insertTimeRange(assetTimeRange,
                                                of: asset,
                                                at: insertAt.end)
            } catch {
                NSLog("Unable to compose asset track.")
            }

            let nextDuration = insertAt.duration + assetTimeRange.duration
            insertAt = CMTimeRange(start: kCMTimeZero, duration: nextDuration)
        }

        let exportSession =
            AVAssetExportSession(
                asset:      composition,
                presetName: AVAssetExportPresetAppleM4A)

        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = self.createNewRecordingURL("exported-")

        // TODO exportSession?.metadata = ...

        exportSession?.canPerformMultiplePassesOverSourceMediaData = true
        /* TODO? According to the docs, if multiple passes are enabled and
                 "When the value of this property is nil, the export session
                 will choose a suitable location when writing temporary files."
         */
        // exportSession?.directoryForTemporaryFiles = ...

        /* TODO?
           Listing all cases for completeness sake, but may just use `.completed`
           and ignore the rest with a `default` clause.
           OR
           because the completion handler is run async, KVO would be more appropriate
        */
        exportSession?.exportAsynchronously {

            switch exportSession?.status {
            case .unknown?: break
            case .waiting?: break
            case .exporting?: break
            case .completed?:
                /* Cleaning up partial recordings
                */
                for asset in self.articleChunks {
                    try! FileManager.default.removeItem(at: asset.url)
                }
                /* Resetting `articleChunks` here, because this function is
                   called asynchronously and calling it from `queueTapped` or
                   `submitTapped` may delete the files prematurely.
                */
                self.articleChunks = [AVURLAsset]()
            case .failed?: break
            case .cancelled?: break
            case .none: break
            }
        }
    }

    func upload() {
        //        let storage = Storage.storage()
        //        let storageRef = storage.reference()
        //        let audioRef = storageRef.child("audio/")
        //
        //        for n in 1..<self.recordings.count {
        //            audioRef.child(String(n) + ".m4a").putFile(from: self.recordings[n])
        //        }
    }

    @objc func recordTapped() {
        if self.audioRecorder == nil {
            self.startRecorder(publication: self.selectedPublication)
        }

        self.updateControlsAndStatus(
            activeControls: [.pause, .stop],
            controlStatus: ("Recording...", .red)
        )
    }

    @objc func pauseTapped() {
        let status: (String, UIColor)

        if self.audioRecorder?.isRecording == true {
            self.stopRecorder()
            status = ("Recording paused.", .red)
        } else {
            self.queuePlayer?.pause()
            status = ("Playback paused.", .green)
        }

        self.updateControlsAndStatus(
            activeControls: [.record, .play, .stop],
            controlStatus:  status)
    }

    @objc func playTapped() {
        self.startPlayer()
        updateControlsAndStatus(
            activeControls: [.pause, .stop],
            controlStatus:  nil)
    }

    /* Issue #27: Allow appending to finalized (i.e. exported) recordings
     */
    @objc func stopTapped() {
        let status: (String, UIColor)

        if self.audioRecorder?.isRecording == true {
            self.stopRecorder()
            self.concatChunks()
            self.newArticleReset(activeControls: [.record, .submit])
        } else {
            self.stopPlayer()
            status = ("Playback stopped.", .green)
            self.updateControlsAndStatus(
                activeControls: [.record, .play, .submit],
                controlStatus: nil)
        }
    }

    /* Issue #26 - cellular upload considerations
    */
    @objc func submitTapped() {
        self.upload()

        /* + https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html#//apple_ref/doc/uid/TP40007457-CH11-SW12
           + https://developer.apple.com/documentation/uikit/uiviewcontroller#1652844
           + https://stackoverflow.com/questions/37370801/how-to-add-a-container-view-programmatically
        */
        func changeViewControllers          // no animation
            ( from oldVC: UIViewController
            , to   newVC: UIViewController
            )
        {
            /* 1. Add new view controller to container view controller's children */
            self.addChildViewController(newVC)
            /* 2. Add the child’s root view to your container’s view hierarchy. */
            self.view.addSubview(newVC.view)
            /* 3. Add any constraints for managing the size and position of
                  the child’s root view (i.e., making it the same position and
                  dimensions of the old view controller's view).

                  The definition of a view frame: "a rectangle, which describes
                  the view’s location and size in its superview’s coordinate
                  system".
             */
            newVC.view.frame = oldVC.view.frame
            /* 4. Remove the currently visible view controller from the container. */
            oldVC.removeFromParentViewController()
            /* 5. Finishing the transition */
            newVC.didMove(toParentViewController: self)
        }

        let listRecordingsTVC = self.appDelegate.storyboard.instantiateViewController(withIdentifier: "ListRecordings")

        changeViewControllers(from: self.mainTVC, to: listRecordingsTVC)
    }

    // https://cocoacasts.com/how-to-work-with-bitmasks-in-swift/
    struct Controls: OptionSet {
        let rawValue: Int

        static let record = Controls(rawValue: 1 << 0)
        static let pause  = Controls(rawValue: 1 << 1)
        static let play   = Controls(rawValue: 1 << 2)
        static let stop   = Controls(rawValue: 1 << 3)
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

        if c.contains(.pause) {
            buttons +=
                [ UIBarButtonItem(title: "Pause",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.pauseTapped))
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

        if c.contains(.stop) {
            buttons +=
                [ UIBarButtonItem(title: "Stop",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.stopTapped))
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
