//
//  ShareViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/1/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    lazy var publicationConfigurationItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Publication:"
        item.value = ""
        item.tapHandler = {
            let publicationPickerViewController = PublicationPickerViewController()
            publicationPickerViewController.delegate             = self
            publicationPickerViewController.forConfigurationItem = item

            self.pushConfigurationViewController(publicationPickerViewController)
        }
        return item
    }()

    lazy var hoursConfigurationItem: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Time spent reading:"
        item.value = ""
        item.tapHandler = { print("hours")}
        return item
    }()

    var publicationPickerData: [String] = ["Safeway ads", "Walmart ads", "Ferndale Enterprise"]

    override func presentationAnimationDidFinish() {
        self.placeholder = "Send us a message!"
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    // TODO: Is there anything that needs to be cleaned up?
//    override func didSelectCancel() {
//
//    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [ publicationConfigurationItem
               , hoursConfigurationItem
               ]
    }
}

extension ShareViewController: ConfigurationItemDelegate {

    func updateValue(newValue: String, of configItem: SLComposeSheetConfigurationItem) {
        configItem.value = newValue
    }

    func nextConfigurationItemViewController() {
        /* TODO
         Instead of simply popping the current config item's view controller,
         would be transition to the other conditionally? By that I mean that
         because both are mandatory, starting with either one would transition
         to the next, creating a workflow. Don't sweat too much on it.
        */
        self.popConfigurationViewController()
    }
}

