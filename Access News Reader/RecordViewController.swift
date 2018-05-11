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
    var mainTVC: MainTableViewController!
    var listRecordings: ListRecordings!

    var recordingSession: AVAudioSession!
    var audioRecorder:    AVAudioRecorder?
    var queuePlayer:      AVQueuePlayer?

    var articleChunks = [AVURLAsset]()

    @IBOutlet weak var publicationStatus: UILabel!
    @IBOutlet weak var articleStatus:     UILabel!
    @IBOutlet weak var controlStatus:     UILabel!

    var isRecordEnabled: Bool {
        get {
            let isPublicationSelected = self.publicationStatus.text! != ""
            let hasArticleTitle       = self.articleStatus.text! != ""

            return isPublicationSelected && hasArticleTitle
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isToolbarHidden = false
//        self.navigationItem.rightBarButtonItem!.action = #selector(self.navRightButtonTapped)

        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title:  "",
                            style:  .plain,
                            target: self,
                            action: #selector(self.navRightButtonTapped))

        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(title:  "",
                            style:  .plain,
                            target: self,
                            action: #selector(self.navLeftButtonTapped))

        self.mainTVC =
            self.childViewControllers.first
            as! MainTableViewController

        self.listRecordings =
            self.appDelegate.storyboard.instantiateViewController(
                withIdentifier: "ListRecordings")
                as! ListRecordings

        // https://stackoverflow.com/questions/4865458/dynamically-changing-font-size-of-uilabel
        self.controlStatus.numberOfLines = 1
        self.controlStatus.minimumScaleFactor =
            8.0 / self.controlStatus.font.pointSize
        self.controlStatus.adjustsFontSizeToFitWidth = true

        /* https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
        */
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    let controlStatus: (title: String, colour: UIColor)

                    if allowed == true {
                        controlStatus =
                            ( "Please select a publication first."
                            , Constants.noTitleColor
                            )
                    } else {
                        controlStatus =
                            ( "Recording disabled."
                            , .magenta
                            )
                    }

                    /* Disable "Record" button until publication is selected.
                       Enabled in SelectPublication view controller.
                     */

                    self.setUI([
                        .navLeftButton:
                            [ "type":   Constants.RecordUINavButton.profile
                            , "status": true
                            ],
                        .navRightButton:
                            [ "type":   Constants.RecordUINavButton.queued
                            , "status": !Constants.recordings.isEmpty
                            ],
                        .selectedPublication:
                            [ "type": Constants.PublicationLabelType.not_selected
                            , "title": "None selected"
                            ],
                        .articleTitle:
                            [ "title" : "Please choose a publication first"
                            , "status": false
                            , "colour": Constants.noTitleColor
                            ],
                        .controlStatus:
                            [ "title":  controlStatus.title
                            , "colour": controlStatus.colour
                            ],
                        ],
                        controls:
                            [( .record
                             , "Start Recording"
                             , false )
                            ]
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

    // MARK: - Audio & Main UI Control Actions

    @objc func recordTapped() {

        if self.audioRecorder == nil {
            self.startRecorder()
        }

        self.showListRecordings()

        self.toggleCells(
            of: self.listRecordings,
            to: false)

        self.setUI([
            .navLeftButton:
                [ "type":   Constants.RecordUINavButton.profile
                , "status": false
                ],
            .navRightButton:
                [ "type":   Constants.RecordUINavButton.edit
                , "status": false
                ],
            .controlStatus:
                [ "title":  "Recording"
                , "colour": UIColor.red
                ],
            ],
            controls:
                [ (.pause, "Pause", true)
                , (.stop,  "Stop",  true)
                ]
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

        self.toggleCells(
            of: self.listRecordings,
            to: true)

        if self.audioRecorder?.isRecording == true {

            self.stopRecorder()

            /* `ListRecordings` is updated in `self.concatChunks` as temporary
               files are deleted there asynchronously, and calling `reloadData`
               here would result in runtime crash.
            */
            self.concatChunks()

            self.setUI([
                .navLeftButton:
                    [ "type":   Constants.RecordUINavButton.profile
                    , "status": true
                    ],
                .navRightButton:
                    [ "type":   Constants.RecordUINavButton.edit
                    , "status": true
                    ],
                .controlStatus:
                    [ "title":  "Finished recording article"
                    , "colour": UIColor.red
                    ],
                ],
                controls:
                    [ (.record, "Record new", true)
                    , (.submit, "Submit",     true)
                    ]
            )
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
    }


    // MARK: - Audio Helpers

    // Creates URL relative to apps Document directory
    func createNewRecordingURL(_ filename: String = "") -> URL {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let datetime = dateFormatter.string(from: Date())

        let fileURL = filename + datetime + ".m4a"

        return Constants.documentDir.appendingPathComponent(fileURL)
    }

    func startRecorder() {
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

    func concatChunks() {
        let composition = AVMutableComposition()

        var insertAt = CMTimeRange(start: kCMTimeZero, end: kCMTimeZero)

        for asset in self.articleChunks {
            let assetTimeRange = CMTimeRange(
                start: kCMTimeZero,
                end:   asset.duration)

            do {
                try composition.insertTimeRange(assetTimeRange,
                                                of: asset,
                                                at: insertAt.end)
            } catch {
                NSLog("Unable to compose asset track.")
            }

            let nextDuration = insertAt.duration + assetTimeRange.duration
            insertAt = CMTimeRange(
                start:    kCMTimeZero,
                duration: nextDuration)
        }

        let exportSession =
            AVAssetExportSession(
                asset:      composition,
                presetName: AVAssetExportPresetAppleM4A)

        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = self.createNewRecordingURL("exported-")

        // TODO: exportSession?.metadata = ...

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

                /* https://stackoverflow.com/questions/26277371/swift-uitableview-reloaddata-in-a-closure
                */
                DispatchQueue.main.async {
                    self.listRecordings.tableView.reloadData()
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

    // MARK: - General Helpers

    func upload() {
        //        let storage = Storage.storage()
        //        let storageRef = storage.reference()
        //        let audioRef = storageRef.child("audio/")
        //
        //        for n in 1..<self.recordings.count {
        //            audioRef.child(String(n) + ".m4a").putFile(from: self.recordings[n])
        //        }
    }

    func toggleCells
        ( of tableViewController: UITableViewController
        , to status: Bool
        )
    {
        for cell in tableViewController.tableView.visibleCells {
            cell.isUserInteractionEnabled   = status
            cell.textLabel?.isEnabled       = status
            cell.detailTextLabel?.isEnabled = status
        }
    }

    // MARK: - Change View Controllers

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

    func showListRecordings() {
        self.changeViewControllers(
            from: self.mainTVC,
            to:   self.listRecordings)
    }

    func showMainTVC() {
        /* Always go back from the currently loaded subVC */
        self.changeViewControllers(
            from: self.childViewControllers.first!,
            to:   self.mainTVC
        )
    }

    @objc func navLeftButtonTapped() {
        let navLeftButton = self.navigationItem.leftBarButtonItem!

        switch navLeftButton.title! {
        case Constants.RecordUINavButton.profile.rawValue:

            let profile =
                self.appDelegate.storyboard.instantiateViewController(
                    withIdentifier: "Profile")
            self.navigationController?.pushViewController(profile, animated: true)

            self.setUI([
                .navRightButton:
                    [ "type":   Constants.RecordUINavButton.queued
                    , "status": !Constants.recordings.isEmpty
                    ],
                ],
                controls: []
            )

        case Constants.RecordUINavButton.main.rawValue:

            if self.listRecordings.isEditing == true {
                self.listRecordings.setEditing(false, animated: false)
            }

            self.showMainTVC()

            self.setUI([
                .navRightButton:
                    [ "type":   Constants.RecordUINavButton.queued
                    , "status": !Constants.recordings.isEmpty
                    ],
                .navLeftButton:
                    [ "type": Constants.RecordUINavButton.profile
                    , "status": true
                    ]
                ],
                controls:
                    [ (.record, "Start New Recording", self.isRecordEnabled)
                    ]
            )

        default:
            break
        }
    }

    @objc func navRightButtonTapped() {
        let navRightButton = self.navigationItem.rightBarButtonItem!

        switch navRightButton.title! {
        case Constants.RecordUINavButton.queued.rawValue:

            self.showListRecordings()

            self.setUI([
                .navRightButton:
                    [ "type":   Constants.RecordUINavButton.edit
                    , "status": true
                    ],
                .navLeftButton:
                    [ "type": Constants.RecordUINavButton.main
                    , "status": true
                    ]
                ],
                controls:
                    [ (.record, "Start New Recording", self.isRecordEnabled)
                    , (.submit, "Submit", !Constants.recordings.isEmpty)
                    ]
            )

        case Constants.RecordUINavButton.edit.rawValue:

            self.listRecordings.setEditing(true, animated: true)

            self.setUI([
                .navRightButton:
                    [ "type":   Constants.RecordUINavButton.finish
                    , "status": true
                    ],
                .navLeftButton:
                    [ "type":   Constants.RecordUINavButton.main
                    , "status": true
                    ],
                ],
                controls: []
            )

        case Constants.RecordUINavButton.finish.rawValue:

            self.listRecordings.setEditing(false, animated: true)

            self.setUI([
                .navRightButton:
                    [ "type":   Constants.RecordUINavButton.edit
                    , "status": true
                    ],
                ],
                controls:
                    [ (.record, "Start New Recording", self.isRecordEnabled)
                    , (.submit, "Submit", !Constants.recordings.isEmpty)
                    ]
            )

        default:
            break
        }
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
//        self.selectedPublication = ""
        self.newArticleReset(activeControls: activeControls)
    }

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
}

// MARK: - RecordUIDelegate implementation
extension RecordViewController: RecordUIDelegate {

    func setUI
        ( _ components: [Constants.RecordUIComponent : Any]
        , controls:     [(control: Controls, title: String, status: Bool)]?
        )
    {
        if controls != nil {
            self.updateControls(controls!)
        }

        for key in components.keys {

            let value = components[key]! as! [String: Any]

            switch key {

                case .navLeftButton:
                    self.setNavButton(
                        side:   .left,
                        type:   value["type"]   as! Constants.RecordUINavButton,
                        status: value["status"] as! Bool)

                case .navRightButton:
                    self.setNavButton(
                        side:   .right,
                        type:   value["type"]   as! Constants.RecordUINavButton,
                        status: value["status"] as! Bool)

                case .selectedPublication:
                    self.publicationLabel(
                        type:  value["type"]  as! Constants.PublicationLabelType,
                        title: value["title"] as! String)

                case .articleTitle:
                    let t = self.mainTVC.articleTitle!

                    t.text =      (value["title"]  as! String)
                    t.isEnabled = value["status"]  as! Bool
                    t.textColor = (value["colour"] as! UIColor)

                /* For `publicationStatus` and `articleStatus` dict entries:

                   + `[ "update": true ]`
                      Automatically update the status labels with their input
                      counterparts

                   + `[ "title": "whatever" ]`
                     Update the status labels with the provided string.
                 */
                case .publicationStatus:
                    self.updateStatus(
                        of:   self.publicationStatus,
                        with: self.mainTVC.selectedPublication.text!)

                case .articleStatus:
                    self.updateStatus(
                        of:   self.articleStatus,
                        with: self.mainTVC.articleTitle.text!)

                case .controlStatus:
                    self.controlStatus.textColor =
                        value["colour"] as! UIColor
                    self.controlStatus.text =
                        (value["title"] as! String)
            }
        }
    }

    func setNavButton
        ( side:   Constants.RecordUINavButton
        , type:   Constants.RecordUINavButton
        , status: Bool
        )
    {
        let button =
            side == .left
                ? self.navigationItem.leftBarButtonItem!
                : self.navigationItem.rightBarButtonItem!

        button.title =     type.rawValue
        button.isEnabled = status
    }

    // MARK: - RecordUIDelegate helpers

    func updateStatus
        ( of   statusLabel: UILabel
        , with nameOrTitle: String)
    {
        let t: String

        if nameOrTitle != "" {
            t = nameOrTitle
        } else {
            t = "Untitled"
        }

        statusLabel.text = t
    }

    func updateArticleStatus(_ status: Bool) {

        let title: String!
        if self.mainTVC.articleTitle.text != "" {
            title = self.mainTVC.articleTitle.text
        } else {
            title = "Untitled"
        }

        if status == false {
            self.articleStatus.text = ""
        } else {
            self.articleStatus.text =
                self.mainTVC.selectedPublication.text!
                + " - "
                + title
        }
    }

    /* If `.not_selected` is chosen, the `title` argument is ignored.
     */
    func publicationLabel
        ( type:  Constants.PublicationLabelType
        , title: String
        )
    {
        switch type {

        case .not_selected:
            self.mainTVC.selectedPublication.font =
                UIFont.systemFont(ofSize: 14, weight: .bold)
            self.mainTVC.selectedPublication.textColor =
                Constants.noTitleColor

        case .selected:
            self.mainTVC.selectedPublication.font =
                UIFont.systemFont(ofSize: 17, weight: .regular)
            self.mainTVC.selectedPublication.textColor =
                UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        }

        self.mainTVC.selectedPublication.text = title
    }


    func updateControls
        (_ visibleControls:
            [ ( control: Controls
              , title:   String
              , status:  Bool
              )
            ]
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

        for c in visibleControls {
            let button = UIBarButtonItem(
                             title: c.title,
                             style: .plain,
                             target: self,
                             action: actions[c.control]
                         )
            button.isEnabled = c.status
            buttons += [button, flexSpace()]
        }

        // https://stackoverflow.com/questions/10825572/uitoolbar-not-showing-uibarbuttonitem
        self.setToolbarItems(buttons, animated: false)
    }

    // MARK: RecordUI (i.e., main user interface) change shortcuts

}
