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
    }

    @IBOutlet weak var pauseButton: UIButton!
    @IBAction func pauseTapped(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.publicationPicker.dataSource = self
        self.publicationPicker.delegate =   self

        // https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed == false {
                        self.pauseButton.isEnabled  = false
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Please enable recording at \"Settings > Privacy > Microphone\".", for: .disabled)
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
        let pubToTheLeft = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Courier-Bold", size: 21.0)!,NSAttributedStringKey.foregroundColor:UIColor.gray])
        pickerLabel.attributedText = pubToTheLeft
        return pickerLabel
    }
}
