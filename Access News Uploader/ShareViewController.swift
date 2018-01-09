//
//  ShareViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/1/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Social

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

    var currentConfigurationTuple: ConfigurationTuple?

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the
        // sheet, return an array of SLComposeSheetConfigurationItem here.
        return self.configurationTuples.map { $0.configurationItem }
    }

    override func presentationAnimationDidFinish() {
        self.placeholder = "Send us a message!"
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


