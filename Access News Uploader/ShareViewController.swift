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

    var images = [Data]()

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

        /* CAVEMAN */ print(self.configurationTuples.map { ($0.configurationItem.value, $0.configurationItem.title) })

        attachments.forEach { itemProvider in
            if itemProvider.hasItemConformingToTypeIdentifier("public.jpeg") {
                itemProvider.loadItem(forTypeIdentifier: "public.jpeg", options: nil, completionHandler: postCompletionHandler)
            }
        }

        print(self.images)

        self.extensionContext!.completeRequest(
            returningItems:    [],
            completionHandler: nil
            )
    }

    func postCompletionHandler(item: NSSecureCoding?, error: Error!) {

        guard let itemData = try? Data(contentsOf: item as! URL) else { return }
        self.images.append(itemData)

        guard let itemURL = item as? URL else { return }
        let itemFileName = String(describing: itemURL).split(separator: "/").last!
        let storageRef = self.storage.reference().child("images/\(itemFileName)")

        // Large audio files are involved therefore `putFile` would be recommended,
        // I can't do it from the simulator (or maybe it's something else).
        storageRef.putData(itemData)
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


