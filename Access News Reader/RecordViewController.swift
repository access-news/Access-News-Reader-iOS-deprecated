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

    @IBOutlet weak var articleStatus: UILabel!
    @IBOutlet weak var controlStatus: UILabel!

    var mainTVCCells: [UITableViewCell] {
        get {
            return self.mainTVC.tableView.visibleCells
        }
    }

    var selectedPublication: String {
        get {
            return (mainTVCCells[0].textLabel?.text)!
        }
        set(newPublication) {
            mainTVCCells[0].textLabel?.text = newPublication
        }
    }

    var documentDir: URL {
        get {
            let documentURLs = FileManager.default.urls(
                for: .documentDirectory,
                in:  .userDomainMask
            )
            return documentURLs.first!
        }
    }

    var recordings: [URL] {
        get {
            let fileURLs = try? FileManager.default.contentsOfDirectory(at: self.documentDir, includingPropertiesForKeys: nil, options: [])
            return fileURLs ?? []
        }
    }
//    var articleTitle: String {
//        get {
//            return mainTVCCells[1].text...
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isToolbarHidden = false
        self.mainTVC = self.childViewControllers.first as! MainTableViewController

        /* https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
        */
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    let controlStatus: (String, UIColor)?

                    if allowed == true {
//                        tooltip = "Please choose a publication first to start recording."
                        controlStatus = ("Please select a publication.", .black)
                    } else {
//                        tooltip = "Please enable recording at \"Settings > Privacy > Microphone\"."
                        controlStatus = ("Recording disabled.", .magenta)
                    }

                    /* Disable "Record" button until publication is selected. Enabled in SelectPublication view controller.
                     */

                    self.setUI(
                        navLeftButton:        ("Profile", true),
                        navRightButton:       ("Queued Recordings", self.recordings.isEmpty),
                        selectedPublication:  "",
                        articleStatus:        "",
                        controlStatus:        controlStatus!,
                        visibleControls:      [.record : ("Start Recording", false)]
                    )
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

        let fileURL = filename + datetime + ".m4a"

        return self.documentDir.appendingPathComponent(fileURL)
    }

    func startRecorder(publication: String) {
        let settings =
            [ AVFormatIDKey:             Int(kAudioFormatMPEG4AAC)
            , AVSampleRateKey:           44100
            , AVNumberOfChannelsKey:     1
            , AVEncoderAudioQualityKey:  AVAudioQuality.high.rawValue
            , AVEncoderBitRateKey:       128000
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

//        self.updateControlsAndStatus(
//            activeControls: [.stop],
//            controlStatus:  nil)
    }

    func stopPlayer() {
        self.queuePlayer?.pause()
        self.queuePlayer = nil
    }

    func newArticleReset(activeControls: Controls) {

//        self.updateControlsAndStatus(
//            activeControls: activeControls,
//            controlStatus:  nil)

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

//        self.updateControlsAndStatus(
//            activeControls: [.pause, .stop],
//            controlStatus: ("Recording...", .red)
//        )
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

//        self.updateControlsAndStatus(
//            activeControls: [.record, .play, .stop],
//            controlStatus:  status)
    }

    @objc func playTapped() {
        self.startPlayer()
//        updateControlsAndStatus(
//            activeControls: [.pause, .stop],
//            controlStatus:  nil)
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
//            self.updateControlsAndStatus(
//                activeControls: [.record, .play, .submit],
//                controlStatus: nil)
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

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension RecordViewController: RecordUIDelegate {

    /* Not messing around conditionals and default parameters,
       requiring everything explicit. The rationale is the same
       as with `updateControlsAndStatus`: if I come back to this
       after months, I don't have to track down state changes,
       but just look at the calls.
    */
    // MARK: - RecordUIDelegate implementation
    func setUI
        ( navLeftButton:       (title: String, active: Bool)
        , navRightButton:      (title: String, active: Bool)
        , selectedPublication: String
        , articleStatus:       String
        , controlStatus:       (text: String, colour: UIColor)
        , visibleControls:     [Controls: (title: String, isEnabled: Bool)]
      //, articleTitle:        String /* needs to be wired up */
        )
    {
        let navItem = self.navigationItem
        /* left */
        navItem.leftBarButtonItem?.title = navLeftButton.title
        navItem.leftBarButtonItem?.isEnabled = navLeftButton.active
        /* right */
        navItem.rightBarButtonItem?.title = navRightButton.title
        navItem.rightBarButtonItem?.isEnabled = navRightButton.active

        self.updateControlsAndStatus(
            visibleControls:  visibleControls,
            controlStatus:    controlStatus
        )

        self.selectedPublication = selectedPublication
        self.articleStatus.text  = articleStatus

    }

    // MARK: RecordUIDelegate helpers
    func updateControlsAndStatus
        ( visibleControls: [Controls: (title: String, isEnabled: Bool)]
        , controlStatus:   (text: String, colour: UIColor)
        )
    {
        func flexSpace() -> UIBarButtonItem {
            return UIBarButtonItem(
                       barButtonSystemItem: .flexibleSpace,
                       target: nil,
                       action: nil
                   )
        }

        var buttons: [UIBarButtonItem] = [flexSpace()]

        let actions: [Controls: Selector] =
            [ .record : #selector(self.recordTapped)
            , .pause  : #selector(self.pauseTapped)
            , .play   : #selector(self.playTapped)
            , .stop   : #selector(self.stopTapped)
            , .submit : #selector(self.submitTapped)
            ]

        for c in visibleControls.keys {
            let control = visibleControls[c]!
            let button = UIBarButtonItem(
                             title: control.title,
                             style: .plain,
                             target: self,
                             action: actions[c]
                         )
            button.isEnabled = control.isEnabled
            buttons += [button, flexSpace()]
        }
        /* There are more clever ways to do this, but this solution is
            + easy on the eyes
            + quickly updateable
            + there is a finite number of items
            + (so far) not used anywhere else in the UI
            + and, most importantly, I will know what I did when I return to this
           ¡¡¡¡¡   after months
        */
        // if visibleControls.controls.contains(.record) {
        //     buttons +=
        //         [ UIBarButtonItem(title: titles.removeFirst(),
        //                           style: .plain,
        //                           target: self,
        //                           action: #selector(self.recordTapped))
        //         , flexSpace()
        //         ]
        // }

        // if visibleControls.controls.contains(.pause) {
        //     buttons +=
        //         [ UIBarButtonItem(title: titles.removeFirst(),
        //                           style: .plain,
        //                           target: self,
        //                           action: #selector(self.pauseTapped))
        //         , flexSpace()
        //         ]
        // }

        // if visibleControls.controls.contains(.play) {
        //     buttons +=
        //         [ UIBarButtonItem(title: titles.removeFirst(),
        //                           style: .plain,
        //                           target: self,
        //                           action: #selector(self.playTapped))
        //         , flexSpace()
        //         ]
        // }

        // if visibleControls.controls.contains(.stop) {
        //     buttons +=
        //         [ UIBarButtonItem(title: titles.removeFirst(),
        //                           style: .plain,
        //                           target: self,
        //                           action: #selector(self.stopTapped))
        //         , flexSpace()
        //         ]
        // }

        // if visibleControls.controls.contains(.submit) {
        //     buttons +=
        //         [ UIBarButtonItem(title: titles.removeFirst(),
        //                           style: .plain,
        //                           target: self,
        //                           action: #selector(self.submitTapped))
        //         , flexSpace()
        //         ]
        // }

        // https://stackoverflow.com/questions/10825572/uitoolbar-not-showing-uibarbuttonitem
        self.setToolbarItems(buttons, animated: false)

        self.controlStatus.textColor = controlStatus.colour
        self.controlStatus.text      = controlStatus.text
    }

}
