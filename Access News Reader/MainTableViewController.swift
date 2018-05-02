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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.articleTitle.delegate = self
        self.articleTitle.clearButtonMode = .always
        self.articleTitle.spellCheckingType = .yes
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
