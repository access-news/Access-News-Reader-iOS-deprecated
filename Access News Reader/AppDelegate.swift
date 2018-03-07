//
//  AppDelegate.swift
//  Access News Reader
//
//  Created by Society for the Blind on 12/14/17.
//  Copyright © 2017 Society for the Blind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

// TODO:
//      * refactor and DRY up
//      * remove implicitly unwrapped optionals (these were used to speed things
//        up, but fairly unsafe)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authUI: FUIAuth?
    let defaults = UserDefaults.init(suiteName: "group.org.societyfortheblind.access-news-reader-ag")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self

        if self.defaults.bool(forKey: Constants.userLoggedIn) {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            fatalError()
        }
        if user != nil {
            self.defaults.set(true, forKey: Constants.userLoggedIn)

            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }
    }
}
// Implementing app delegate methods for share extension (upload)
//extension AppDelegate {
//    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
//        //placeholder
//    }
//}

