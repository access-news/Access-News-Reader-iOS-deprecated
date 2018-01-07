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

//    lazy var publicationConfigurationItem: SLComposeSheetConfigurationItem = {
//        let item = SLComposeSheetConfigurationItem()!
//        item.title = "Publication:"
//        item.value = ""
//        item.tapHandler = {
//            let publicationPickerViewController = PublicationPickerViewController()
//            publicationPickerViewController.delegate             = self
//            // TODO: Remove coupling.
//            publicationPickerViewController.forConfigurationItem = item
//
//            self.pushConfigurationViewController(publicationPickerViewController)
//        }
//        return item
//    }()
//
//    lazy var hoursConfigurationItem: SLComposeSheetConfigurationItem = {
//        let item = SLComposeSheetConfigurationItem()!
//        item.title = "Time spent reading:"
//        item.value = ""
//        item.tapHandler = { print("hours")}
//        return item
//    }()

    typealias ConfigurationTuple =
        ( itemTitle:         String
        , viewController:    ConfigurationItemViewController
        , configurationItem: SLComposeSheetConfigurationItem
        )

    // Using IUO because this has to be set and the method `configurationItems:`
    // used to set it always returns a value.
    // It also cannot be set within `configurationItems:` because its order depends
    // on which configuration item has been clicked first.
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

    var nextConfigurationTuples:    [ConfigurationTuple]!
    var previousConfigurationTuple: ConfigurationTuple!

    override func presentationAnimationDidFinish() {
        self.placeholder = "Send us a message!"
//        self.configurationItemsAsSegues = self.configurationItems() as! [SLComposeSheetConfigurationItem]
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
            viewController.forConfigurationItem = configurationItem

            self.reorderNextConfigurationTuples(configurationItem)
            self.startReport()
        }
        return tapHandler
    }

    private func reorderNextConfigurationTuples
        (_ tappedItem: SLComposeSheetConfigurationItem)
    {
        /* Using IUO because this always returns an index.
           ( Every configuration item has been initialized in `configurationTuples`
           ( and this function is called in a configuration item's taphandler
           ( that hands its own containing configuration item as tappedItem.
           ( Full circle.
        */
        self.nextConfigurationTuples = self.configurationTuples

        let tappedItemIndex =
            self.nextConfigurationTuples.index(
                where: { $0.itemTitle == tappedItem.title }
                )!

        let removedTuple = self.nextConfigurationTuples.remove(at: tappedItemIndex)
        self.nextConfigurationTuples.insert(removedTuple, at: 0)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return [ publicationConfigurationItem
//               , hoursConfigurationItem
//               ]
        return self.configurationTuples.map { $0.configurationItem }

    }
}

extension ShareViewController: ConfigurationItemDelegate {

    func startReport() {
        self.previousConfigurationTuple =
            self.nextConfigurationTuples.removeFirst()

        self.pushConfigurationViewController(
            self.previousConfigurationTuple.viewController
        )
    }

    func continueReport(newValue: String) {

        self.previousConfigurationTuple.configurationItem.value = newValue

        if self.nextConfigurationTuples.count != 0 {

            self.previousConfigurationTuple =
                self.nextConfigurationTuples.removeFirst()

            let nextViewController =
                self.previousConfigurationTuple.viewController
            nextViewController.delegate = self

            self.pushConfigurationViewController(nextViewController)
            
        } else {
            self.popConfigurationViewController()
        }
    }


//    func updateValue(newValue: String, of configItem: SLComposeSheetConfigurationItem) {
//        configItem.value = newValue
//    }

//    func c() {
//        /* TODO
//         Instead of simply popping the current config item's view controller,
//         would be transition to the other conditionally? By that I mean that
//         because both are mandatory, starting with either one would transition
//         to the next, creating a workflow. Don't sweat too much on it.
//        */
////        self.popConfigurationViewController()
//        let vc = HoursViewController()
//        self.pushConfigurationViewController(vc)
    }


