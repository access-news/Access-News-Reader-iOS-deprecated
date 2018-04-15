//
//  MainViewController.swift
//  Access News Reader
//
//  Created by Society for the Blind on 12/31/17.
//  Copyright © 2017 Society for the Blind. All rights reserved.
//

import UIKit
//import AVFoundation

//import Firebase
//import FirebaseAuthUI

class MainTableViewController: UITableViewController {

//    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!

//    let publications = ["Mad River Union", "Sacramento Bee", "Sacramento Business Journal", "Santa Rosa Press Democrat", "Senior News"]

//    var loginNC: UINavigationController {
//        get {
//            let rootVC = FUIEmailEntryViewController(authUI: FUIAuth.defaultAuthUI()!)
//            return UINavigationController(rootViewController: rootVC)
//        }
//    }

//    @objc func showLogin() {
//        self.appDelegate.defaults.set(false, forKey: Constants.userLoggedIn)
//
//        do {
//            try self.appDelegate.authUI?.auth?.signOut()
//        } catch {
//            print(error)
//        }
//        self.present(loginNC, animated: true, completion: nil)
//    }

    @IBOutlet weak var tooltips: UITextView!

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

//    @IBOutlet weak var recordButton: UIBarButtonItem!
//    @IBAction func recordTapped(_ sender: Any) {
//        if self.audioRecorder == nil {
//            self.setRecorder(publication: self.selectedPublication)
//        }
//        self.audioRecorder?.record()
//
//        self.updateControlsAndStatus(
//            activeControls: [.stop],
//            tooltipText:    nil,
//            controlStatus:  ("Recording...", .red))
//    }
//
//    @IBOutlet weak var stopButton: UIBarButtonItem!
//    @IBAction func stopTapped(_ sender: Any) {
//        let controlStatus: (String, UIColor)
//
//        if self.audioRecorder?.isRecording == true {
//            self.audioRecorder?.stop()
//            controlStatus = ("Recording stopped.", .red)
//        } else {
//            audioPlayer?.stop()
//            controlStatus = ("Playback stopped.", .green)
//        }
//
//        let tooltip =
//            [ "Tap Record to continue recording."
//            , "Tap Play to list to your recording so far."
//            , "Tap Queue to add file to the list of recordings to be submitted later."
//            , "Tap Submit to upload current file and queued recordings right now."
//            ].joined(separator: "\n\n")
//
//        self.updateControlsAndStatus(
//            activeControls: [.record, .play, .queue, .submit],
//            tooltipText:    NSAttributedString(string: tooltip),
//            controlStatus:  controlStatus)
//    }
//
//    @IBOutlet weak var playButton: UIBarButtonItem!
//    @IBAction func playTapped(_ sender: Any) {
//        if self.audioPlayer == nil {
//            self.setPlayer()
//        }
//        self.audioPlayer?.play()
//
//        self.updateControlsAndStatus(
//            activeControls: [.stop],
//            tooltipText:    NSAttributedString(string: "Tap Stop/Pause to halt playback."),
//            controlStatus:  ("Playing recording...", .green))
//    }
//
//    @IBOutlet weak var queueButton: UIBarButtonItem!
//    @IBAction func queueTapped(_ sender: Any) {
//        // Tap Record if you would like to read another article from <publication>
//        // Or choose another publication to record from another
//        self.resetAudioInstances()
//    }
//
//    @IBOutlet weak var submitButton: UIBarButtonItem!
//    @IBAction func submitButton(_ sender: Any) {
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tooltips.isEditable = false


//        self.navigationItem.leftBarButtonItem?.target = self
//        self.navigationItem.leftBarButtonItem?.action = #selector(showLogin)
//        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* Could just connect cell with SelectPublication on storyboard,
       but then row wouldn't be deselected, and probably cleaner this way.
    */	
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)

//        if self.tableView.visibleCells[0].isSelected {
//            self.navigationController?.pushViewController(SelectPublication(), animated: true)
//        }
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
