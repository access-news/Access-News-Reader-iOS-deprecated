//
//  ShareViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/1/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Social
import Firebase
import FirebaseAuthUI
import MobileCoreServices

/* TODO - Restrict to audio files only (i.e. m4a)
   https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html#//apple_ref/doc/uid/TP40014214-CH21-SW8
 */

/* TODO - Check whether user is authenticated.

          This would require sharing information with the main app.
 */

/* TODO - Volunteers should only see their assigned publications.

          See TODO in PublicationPickerViewController.
 */

class ShareViewController: SLComposeServiceViewController, ConfigurationItemDelegate {

//    func delay(_ delay:Double, closure:@escaping () -> ()) {
//        let when = DispatchTime.now() + delay
//        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
//    }

    /* ------- CODE TO CONFORM TO ConfigurationItemDelegage PROTOCOL -------
       --------------------------------------------------------------------- */
    /* 3/2/2018 0734
       https://stackoverflow.com/questions/24127587/how-do-i-declare-an-array-of-weak-references-in-swift
       would be an overkill as there is always only going to be a finite low number
       of items
    */
    weak var hoursConfigItem: SLComposeSheetConfigurationItem?
    var hours = "" {
        didSet {
            self.hoursConfigItem?.value = self.hours
        }
    }

    weak var publicationConfigItem: SLComposeSheetConfigurationItem?
    var selectedPublication = "" {
        didSet {
            self.publicationConfigItem?.value = self.selectedPublication
        }
    }

    let defaults = UserDefaults.init(suiteName: "group.org.societyfortheblind.access-news-reader-ag")!
    /* --------------------------------------------------------------------- */
    
    var storage: Storage!
    var images = [Data]()
    var authUI: FUIAuth?
    let desiredType = kUTTypeAudio as String

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the
        // sheet, return an array of SLComposeSheetConfigurationItem here.

        /* TODO:
         This pretty and all, but
         (1) hard to read
         (2) (FIXED) may be leaking
         -> (2.1) How to know for sure?
         -> (2.2) It probably wouldn't hurt to use [unowned self]

         For (2) see:
         + https://stackoverflow.com/questions/24320347/shall-we-always-use-unowned-self-inside-closure-in-swift
         + https://www.uraimo.com/2016/10/27/unowned-or-weak-lifetime-and-performance/
         + Matt Neuburg - Programming iOS 11 (page 815, share extension example)
         + follow up with Matt Neuburg - iOS 11 Programming Fundamentals with Swift
         */
         func initConfigItem
            ( forConfigItem:  inout SLComposeSheetConfigurationItem?
            , title:          String
            , value:          String
            , viewController: ConfigurationItemViewController
            )
            -> SLComposeSheetConfigurationItem
        {
            let item = SLComposeSheetConfigurationItem()!
            item.title      = title
            item.value      = value
            item.tapHandler =
                { [unowned self] in
                    viewController.delegate = self
                    self.pushConfigurationViewController(viewController)
                }
            forConfigItem = item
            return item
        }

        /* QUESTION
           Why not this below?
             self.hoursConfigItem =       initConfigItem(...)
             self.publicationConfigItem = initConfigItem(...)
             return [self.hoursConfigItem, self.publicationConfigItem]

            (?) ANSWER
            In `initConfigItem` I could've set up the `forConfigItem` parameter,
            but the variables destined to be passed are defined as *weak*, so
            that would probably complicate things.

            + TRY IT OUT the way it is set in the question. If it works,
            + ask around whether I am missing something.
         */
        return [ initConfigItem(
                   forConfigItem:  &self.publicationConfigItem,
                   title:          "Choose publication:",
                   value:          self.selectedPublication,
                   viewController: PublicationPickerViewController()
                   )
               , initConfigItem(
                   forConfigItem:  &self.hoursConfigItem,
                   title:          "Time spent recording:",
                   value:          self.hours,
                   viewController: HoursViewController())
               ]
    }

    override func presentationAnimationDidFinish() {
        self.placeholder = "Send us a message!"

        /* TODO:
           Should this config be in didSelectPost()`?
           See http://www.talkmobiledev.com/2016/11/19/using-firebase-in-a-share-extension/
         */
        // https://stackoverflow.com/questions/37910766/
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self

        if self.defaults.bool(forKey: Constants.userLoggedIn) == false {
            let fuiSignin     =
                FUIPasswordSignInViewController(
                    authUI: FUIAuth.defaultAuthUI()!,
                    email: nil)
            let navController =
                UINavigationController(rootViewController: fuiSignin)

            self.present(navController, animated: true)
        }

        self.storage = Storage.storage()
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext
        // attachments here
        return true
    }

    /* 2/26/2018 7:52       INVESTIGATE (TODO)

       Only a couple files upload to Firebase from the iPad (simulator is fine).
       + What about other devices?
       + Why?
       + Would background upload solve this? Will the `delay` function still be
         needed afterwards?
         See: https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html#//apple_ref/doc/uid/TP40014214-CH21-SW2
     */
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of
        // contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI.
        // Note: Alternatively you could call super's -didSelectPost,
        // which will similarly complete the extension context.

        // For debugging:
        // p ((self.extensionContext?.inputItems[0] as! NSExtensionItem).attachments?.first as! NSItemProvider).loadFileRepresentation(forTypeIdentifier: "public.jpeg") { url, error in if let u = url { print("\n\(u)\n") }}

        /* 2/26/2018 6:57
           Using the `delay` function from Matt Neuburg's iOS 11 Programming
           Fundamentals with Swift (Part III, Chapter 11. Cocoa Events,
           Delayed Performance, page 534)

           The share extension kept failing on the iPad without any error message,
           but halting execution and being dropped to an assembly code, quitting
           with exit code 0 after that.

           Added a break point and going through line by line, everything worked.
           Assumed it was because of the delay it added, and Matt's solution
           solved it.
        */
//        delay(0.1) {
//        let items = self.extensionContext!.inputItems
//
//        guard let extensionItem

        func finish() {
            self.extensionContext!.completeRequest(
                returningItems:    [],
                completionHandler: nil
            )
        }

        guard let input = self.extensionContext!.inputItems[0] as? NSExtensionItem,
              let attachments = input.attachments as? [NSItemProvider]
        else {
            finish()
            return
        }

        attachments.forEach { provider in
            if provider.hasItemConformingToTypeIdentifier(self.desiredType) {
                provider.loadItem(forTypeIdentifier: self.desiredType) { audio, error in
                    DispatchQueue.main.async {
                        guard let audioURL = audio as? NSURL else { return }
//                        print("\n\n\(audioURL)\n\n")
                        
                    }
                }
            }
        }
    //        /* CAVEMAN */ print(self.configurationTuples.map { ($0.configurationItem.value, $0.configurationItem.title) })

//            attachments.forEach { itemProvider in
//                if itemProvider.hasItemConformingToTypeIdentifier("public.jpeg") {
//
//                    // for some reason, Firebase' putData works, but not putFile
//                    itemProvider.loadItem(forTypeIdentifier: "public.jpeg") {  item, error in
//                        DispatchQueue.main.async {
//                            guard let itemData = try? Data(contentsOf: item as! URL) else { return }
//                            self.images.append(itemData)
//
//                            guard let itemURL = item as? URL else { return }
//                            let itemFileName = String(describing: itemURL).split(separator: "/").last!
//                            let storageRef = self.storage.reference().child("img/\(itemFileName)")
//
//                            // Large audio files are involved therefore `putFile` would be recommended,
//                            // I can't do it from the simulator (or maybe it's something else).
//                            storageRef.putData(itemData)
//                        }
//                    }
    //                itemProvider.loadFileRepresentation(forTypeIdentifier: "public.jpeg", completionHandler: postFileCompletionHandler)
//                }
//            }

            finish()
//        }
    }

//    TODO: Is there anything that needs to be cleaned up?
//    override func didSelectCancel() {
//
//    }
}

extension ShareViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            fatalError()
        }
        if user != nil {
            self.defaults.set(true, forKey: Constants.userLoggedIn)
        }
    }
}
