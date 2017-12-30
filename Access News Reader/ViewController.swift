//
//  ViewController.swift
//  Access News Reader
//
//  Created by Society for the Blind on 12/14/17.
//  Copyright © 2017 Society for the Blind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseAuthUI

class ViewController: UIViewController {

    /* Tapping the login button will ask user for email & password

        (Instead of going through the default FirebaseUI flow and asking new
         users to sign up. There wouldn't be no harm, but every new volunteer
         needs to go through the usual channels anyway.

         If the service grows, this can always be extended to the original flow.
        )

        Tried to present the `FUIPasswordSignInViewController` as the initial
        screen for the app (i.e., directly from `viewDidLoad` in `ViewController`
        or anywhere from `AppDelegate`), but `FUIAuthDelegate` methods never got
        called once the user have been authenticated.
        See https://stackoverflow.com/questions/48012332/

        TODO: dig deeper in FUIAuth.m: `invokeResultCallbackWithAuthDataResult`
              seems to be the key. Many calls are wrapped in `dispatch_async`
              all throughout FirebaseUI's codebase, could be it? (e.g., Matt
              Neuburg mentions this to be used as workarounds for race conditions.
              Check out.)
                                        OR
              Cherry-pick FirebaseUI's codebase and implement it from scratch.
    */
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonTapped(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self

        let rootVC = FUIPasswordSignInViewController(authUI: authUI!, email: nil)
        let navVC = UINavigationController(rootViewController: rootVC)
        self.present(navVC, animated: true, completion: nil)
    }
    //-----------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print("                27")
    }


}
