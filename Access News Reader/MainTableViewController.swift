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

    @IBOutlet weak var articleTitle: UITextField!
    @IBOutlet weak var selectedPublication: UILabel!

    var recordVC: RecordViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.articleTitle.delegate = self
        self.articleTitle.clearButtonMode = .always
        self.articleTitle.spellCheckingType = .yes
    }

    /* An otherwise unnecessary override to fix a stupid issue, where
       the intermediate view controller (i.e., MainViewController) would
       mask the publication field after setting it in RecordVC. This
       function would actually fire sooner than the UI update in
       RecordVC#viewDidLoad, as it is called async.

       Anyway, this works. (Until introducing some other changes probably.)
    */
    override func viewWillAppear(_ animated: Bool) {
        let t = self.selectedPublication.text

        if t == "" {
            self.selectedPublication.text = "temp"
        } else {
            self.selectedPublication.text = self.selectedPublication.text
        }
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

extension MainTableViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        /* Navbar buttons set to 'Profile' and 'Queued Recordings' because
           this is the initial screen so if you edit the title, you would get
           to the initial screen. */
        self.recordVC.setUI([
            .navRightButton:
                /* See 7631a88 */
                [ "type":   Controls.ControlUINavButton.queued
                , "status": false
                ],
            .navLeftButton:
                /* See 7631a88 */
                [ "type":   Controls.ControlUINavButton.profile		
                , "status": false
                ],
            ],
            controls: nil
        )

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        self.recordVC.setUI([
            .navRightButton:
                /* See 7631a88 */
                [ "type":   Controls.ControlUINavButton.none
                , "status": true
                ],
            .navLeftButton:
                /* See 7631a88 */
                [ "type":   Controls.ControlUINavButton.none
                , "status": true
                ],
            .articleStatus:
                /* See ee836c0 */
                [ "update": true],
            .controlStatus:
                [ "title":  ""
                , "colour": UIColor.black
                ],
            ],
            controls: [(.record, "Start Recording", true)]
        )
    }
}
