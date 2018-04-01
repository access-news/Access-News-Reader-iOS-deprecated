//
//  MainViewController.swift
//  Access News Reader
//
//  Created by Society for the Blind on 12/31/17.
//  Copyright © 2017 Society for the Blind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class MainViewController: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!

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
    
    @IBOutlet weak var changeEmailField: UITextField!
    @IBOutlet weak var submitEmailChange: UIButton!
    @IBAction func changeEmail(_ sender: Any) {
        self.appDelegate.authUI?.auth?.currentUser?.updateEmail(to: self.changeEmailField.text!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem?.target = self
        self.navigationItem.leftBarButtonItem?.action = #selector(showLogin)
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
