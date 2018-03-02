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

/* TODO - Restrict to audio files only (i.e. m4a)
   https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html#//apple_ref/doc/uid/TP40014214-CH21-SW8
 */

/* TODO - Check whether user is authenticated.

          This would require sharing information with the main app.
 */

/* TODO - Volunteers should only see their assigned publications.

          See TODO in PublicationPickerViewController.
 */

class ShareViewController: SLComposeServiceViewController {

    func delay(_ delay:Double, closure:@escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }

    typealias ConfigurationTuple =
        ( itemTitle:         String
        , viewController:    ConfigurationItemViewController
        , configurationItem: SLComposeSheetConfigurationItem
        )

    lazy var configurationTuples =
        [ makeConfigurationItemTuple(
            itemTitle:      "Publication:",
            viewController: PublicationPickerViewController()
            )
        , makeConfigurationItemTuple(
            itemTitle:      "Time spent reading:",
            viewController: HoursViewController()
            )
    ]

//    var imageURLs = [URL?]()
//    var urlProgress = [Progress]()

    var storage: Storage!

    var images = [Data]()

    var currentConfigurationTuple: ConfigurationTuple?

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the
        // sheet, return an array of SLComposeSheetConfigurationItem here.
        return self.configurationTuples.map { $0.configurationItem }
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
        self.storage = Storage.storage()
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext
        // attachments here
        return true
    }

    /* 2/26/2018 7:52       INVESTIGATE

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
        delay(0.1) {
            guard let ec = self.extensionContext else { return }
            guard let input = ec.inputItems[0] as? NSExtensionItem else { return }
            guard let attachments = input.attachments as? [NSItemProvider] else { return }

    //        /* CAVEMAN */ print(self.configurationTuples.map { ($0.configurationItem.value, $0.configurationItem.title) })

            attachments.forEach { itemProvider in
                if itemProvider.hasItemConformingToTypeIdentifier("public.jpeg") {

                    // for some reason, Firebase' putData works, but not putFile
                    itemProvider.loadItem(forTypeIdentifier: "public.jpeg", options: nil, completionHandler: self.postCompletionHandler)
    //                itemProvider.loadFileRepresentation(forTypeIdentifier: "public.jpeg", completionHandler: postFileCompletionHandler)
                }
            }

    //        print(self.images)

            self.extensionContext!.completeRequest(
                returningItems:    [],
                completionHandler: nil
                )
        }
    }

//    func postFileCompletionHandler(item: URL?, error: Error!) {
//
//        if error != nil {
//            print("\n\nerror\n\n")
//        }
//        guard let fileURL = item else { return }
//
//        let itemFileName = String(describing: fileURL).split(separator: "/").last!
//        let storageRef = self.storage.reference().child("img/\(String(describing: itemFileName))")
//
//        // Large audio files are involved therefore `putFile` would be recommended,
//        // I can't do it from the simulator (or maybe it's something else).
//        storageRef.putFile(from: fileURL)
//    }


    func postCompletionHandler(item: NSSecureCoding?, error: Error!) {

        guard let itemData = try? Data(contentsOf: item as! URL) else { return }
        self.images.append(itemData)

        guard let itemURL = item as? URL else { return }
        let itemFileName = String(describing: itemURL).split(separator: "/").last!
        let storageRef = self.storage.reference().child("img/\(itemFileName)")

        // Large audio files are involved therefore `putFile` would be recommended,
        // I can't do it from the simulator (or maybe it's something else).
        storageRef.putData(itemData)
    }

    // TODO: Is there anything that needs to be cleaned up?
//    override func didSelectCancel() {
//
//    }

    /* TODO:
       This pretty and all, but
       (1) hard to read
       (2) may be leaking
       -> (2.1) How to know for sure?
       -> (2.2) It probably wouldn't hurt to use [unowned self]

       For (2) see:
       + https://stackoverflow.com/questions/24320347/shall-we-always-use-unowned-self-inside-closure-in-swift
       + https://www.uraimo.com/2016/10/27/unowned-or-weak-lifetime-and-performance/
       + Matt Neuburg - Programming iOS 11 (page 815, share extension example)
       + follow up with Matt Neuburg - iOS 11 Programming Fundamentals with Swift
    */
    private func makeConfigurationItemTuple
        ( itemTitle:      String
        , viewController: ConfigurationItemViewController
        )
        -> ConfigurationTuple
    {
        let item = SLComposeSheetConfigurationItem()!
        item.title      = itemTitle
        item.value      = ""
        item.tapHandler =
            configurationItemTapHandler( for:      item
                                       , usedWith: viewController
                                       )
        return (itemTitle, viewController, item)
    }

    private func configurationItemTapHandler
        ( for configurationItem:   SLComposeSheetConfigurationItem
        , usedWith viewController: ConfigurationItemViewController
        )
        -> SLComposeSheetConfigurationItemTapHandler
    {
        func tapHandler() {
            viewController.delegate             = self
            
            self.setCurrentConfigurationTuple(using: configurationItem)
            self.forward(to: viewController)
        }
        return tapHandler
    }

    private func setCurrentConfigurationTuple
        (using configurationItem: SLComposeSheetConfigurationItem)
    {
        self.currentConfigurationTuple =
            self.configurationTuples.first {
                $0.itemTitle == configurationItem.title
        }
    }
}

extension ShareViewController: ConfigurationItemDelegate {
    func updateValue(_ newValue: String) {
        self.currentConfigurationTuple!.configurationItem.value = newValue
        self.currentConfigurationTuple = nil
    }

    func backToMain() {
        self.popConfigurationViewController()
    }

    func forward(to configurationItem: ConfigurationItemViewController) {
        self.pushConfigurationViewController(configurationItem)
    }

}


