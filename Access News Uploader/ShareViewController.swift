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

    var images = [(String,URL)]()

    var currentConfigurationTuple: ConfigurationTuple?

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the
        // sheet, return an array of SLComposeSheetConfigurationItem here.
        return self.configurationTuples.map { $0.configurationItem }
    }

    override func presentationAnimationDidFinish() {
        self.placeholder = "Send us a message!"

        FirebaseApp.configure()
        self.storage = Storage.storage()
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext
        // attachments here
        return true
    }

    func postCompletionHandler(item: NSSecureCoding?, error: Error!) {
        guard let img = item as? URL else { return }
        let imgBaseName = String(describing: img).split(separator: "/").last!
        let storageRef = self.storage.reference().child("images/\(imgBaseName)")
        self.images.append((String(imgBaseName),img))

        /*
         -> a BREAK here and then STEP OVER produced the following errors:

             2018-01-13 04:55:06.659471-0800 Access News Uploader[34111:1940054] [default] [ERROR] Could not create a bookmark: Error Domain=NSFileProviderInternalErrorDomain Code=0 "NoValidProviderFound_url" UserInfo={NSLocalizedDescription=NoValidProviderFound_url}

             2018-01-13 04:55:06.659712-0800 Access News Uploader[34111:1940054] [default] [ERROR] Failed to determine whether URL /Users/societyfortheblind/Library/Developer/CoreSimulator/Devices/CDA87780-870F-4601-83B5-94F838588204/data/Media/PhotoData/OutgoingTemp/8776A35D-4413-427E-B3A4-FA9CB32BB4F2/IMG_0004.JPG (s) is managed by a file provider

             2018-01-13 04:55:06.667768-0800 Access News Uploader[34111:1939985] Can't endBackgroundTask: no background task exists with identifier 2, or it may have already been ended. Break in UIApplicationEndBackgroundTaskError() to debug.

             2018-01-13 04:55:06.669585-0800 Access News Uploader[34111:1940036] Cannot get file size: Error Domain=NSCocoaErrorDomain Code=260 "The file “IMG_0003.JPG” couldn’t be opened because there is no such file." UserInfo={NSURL=file:///Users/societyfortheblind/Library/Developer/CoreSimulator/Devices/CDA87780-870F-4601-83B5-94F838588204/data/Media/PhotoData/OutgoingTemp/DC7ED051-7421-4398-8E91-A9D4670FB2B7/IMG_0003.JPG, NSFilePath=/Users/societyfortheblind/Library/Developer/CoreSimulator/Devices/CDA87780-870F-4601-83B5-94F838588204/data/Media/PhotoData/OutgoingTemp/DC7ED051-7421-4398-8E91-A9D4670FB2B7/IMG_0003.JPG, NSUnderlyingError=0x600000241e30 {Error Domain=NSPOSIXErrorDomain Code=2 "No such file or directory"}}

             /Users/societyfortheblind/Library/Developer/CoreSimulator/Devices/CDA87780-870F-4601-83B5-94F838588204/data/Media/PhotoData/OutgoingTemp/DC7ED051-7421-4398-8E91-A9D4670FB2B7/IMG_0003.JPG
        */
        storageRef.putFile(from: img)
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of
        // contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI.
        // Note: Alternatively you could call super's -didSelectPost,
        // which will similarly complete the extension context.

        // p ((self.extensionContext?.inputItems[0] as! NSExtensionItem).attachments?.first as! NSItemProvider).loadFileRepresentation(forTypeIdentifier: "public.jpeg") { url, error in if let u = url { print("\n\(u)\n") }}

        guard let ec = self.extensionContext else { return }
        guard let input = ec.inputItems[0] as? NSExtensionItem else { return }
        guard let attachments = input.attachments as? [NSItemProvider] else { return }

        print(self.configurationTuples.map { ($0.configurationItem.value, $0.configurationItem.title) })

        attachments.forEach { itemProvider in
            if itemProvider.hasItemConformingToTypeIdentifier("public.jpeg") {
                itemProvider.loadItem(forTypeIdentifier: "public.jpeg", options: nil, completionHandler: postCompletionHandler)
            }

//            itemProvider.loadItem(forTypeIdentifier: "public.jpeg", options: nil) { data, error in
//                self.images.append(data as! Data)
//            }
//            self.urlProgress.append(
//                itemProvider.loadFileRepresentation(forTypeIdentifier: "public.jpeg") {url, error in
////                    self.imageURLs.append(url)
//                    if let e = error {
//                        print("\n\(e.localizedDescription)\n")
//                    }
//                    let imgName = String(describing: url!.description.split(separator: "/").last!)
//                    let storageRef = self.storage.reference().child("images/\(imgName)")
//                    storageRef.putFile(from: url!)
//                    print("\n\n===\n\n")
//                }
//            )
        }

        self.extensionContext!.completeRequest(
            returningItems:    [],
            completionHandler: nil
            )
    }

    // TODO: Is there anything that needs to be cleaned up?
//    override func didSelectCancel() {
//
//    }

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


