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

    override func didSelectCancel() {

    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [ publicationConfigurationItem
               , hoursConfigurationItem
               ]
    }
}
