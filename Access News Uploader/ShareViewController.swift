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

    // Using IUO because this has to be set and the method `configurationItems:`
    // used to set it always returns a value.
    // It also cannot be set within `configurationItems:` because its order depends
    // on which configuration item has been clicked first.
    var configurationItemsOrderedByInitialTap: [SLComposeSheetConfigurationItem]!

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

    private func makeConfigurationItem
        ( title:          String
        , viewController: ConfigurationItemViewController
        )
        -> SLComposeSheetConfigurationItem
    {
        let item = SLComposeSheetConfigurationItem()!
        item.title      = title
        item.value      = ""
        item.tapHandler =
            configurationItemTapHandler( for:      item
                                       , usedWith: viewController
                                       )
        return item
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

            let arr = self.configurationItems() as! [SLComposeSheetConfigurationItem]

            self.configurationItemsOrderedByInitialTap =
                self.putTappedConfigurationItemFirstInArray(
                    tappedItem:         configurationItem
                  , configurationItems: arr
                  )

            self.pushConfigurationViewController(viewController)
        }
        return tapHandler
    }

    private func putTappedConfigurationItemFirstInArray
        ( tappedItem:             SLComposeSheetConfigurationItem
        , configurationItems arr: [SLComposeSheetConfigurationItem]
        )
        -> [SLComposeSheetConfigurationItem]
    {
        let tappedItemIndex = arr.index { (elem) -> Bool
                                          in
                                          elem.title == tappedItem.title
                                        }

        guard let tix = tappedItemIndex else { return [] }

        var result = arr
        result.remove(at: tix)
        result.insert(tappedItem, at: 0)

        return result
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return [ publicationConfigurationItem
//               , hoursConfigurationItem
//               ]
        return
            [ makeConfigurationItem( title:          "Publication:"
                                   , viewController: PublicationPickerViewController()
                                   )
            , makeConfigurationItem( title:          "Time spent reading:"
                                   , viewController: HoursViewController()
                                   )
            ]
    }
}

extension ShareViewController: ConfigurationItemDelegate {

    /* TODO Get rid of coupling.

       The current solution is less then ideal, because `configurationItemsAsSegues`
       is used and it is defined in `ShareViewController`. Using a protocol should
       mean that it is agnostic about what construct is adopting it.

       Anyhow, if this works, figure out a way to clean this up.
    */
    func continueReport() {
        // 1 keep popping configureationitemsassegues
        // 2 popvc when it is empty

        if self.configurationItemsOrderedByInitialTap.count != 0 {
            
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


