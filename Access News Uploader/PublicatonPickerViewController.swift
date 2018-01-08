//
//  PublicationViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/3/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Social

class PublicationPickerViewController: ConfigurationItemViewController {

    lazy var publicationPicker: UIPickerView = {

        let picker = self.createView(from: UIPickerView.self)

        /* TODO
           Figure out how to move this to the `createView` method. See
           "how-to-assign-delegate-to-dynamically-generated-view" branch
           initial work, but I needed to move on.
        */
        picker.delegate   = self
        picker.dataSource = self

        return picker
    }()

    /* TODO
       Volunteers should only see there assigned publications. (This will
       probably change after the complete overhaul of TR2.)

         I think this should be taken care of in
         * Userdefaults

           Pointers:
           see MainViewController and
           https://www.makeschool.com/online-courses/tutorials/build-a-photo-sharing-app-9f153781-8df0-4909-8162-bb3b3a2f7a81/keeping-users-logged-in

         * firebase realtime database
           https://www.makeschool.com/online-courses/tutorials/build-a-photo-sharing-app-9f153781-8df0-4909-8162-bb3b3a2f7a81/managing-user-accounts
    */
    /* TODO
       Make this an enum? Or is a simple array enough here?
     */
    var pickerData: [String] = ["Safeway ads", "Walmart ads", "Ferndale Enterprise"]

    lazy var currentlyPicked = self.pickerData[0]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

/* ===========================================================================
 TODO: DRY up:

 This block is the same for any configuration item. How could this be
 moved up to ConfigurationItemViewController? The button pushes the
 new value back to main interface. */
        
        self.title = "Choose a publication"
        self.view.addSubview(self.publicationPicker)

        let doneButton = UIBarButtonItem(title:   "Done"
                                        , style:  .done
                                        , target: self
                                        , action: #selector(doneButtonClicked)
                                        )
        self.navigationItem.rightBarButtonItem = doneButton
    }

    @objc func doneButtonClicked() {
        self.delegate.updateValue(self.currentlyPicked)
        self.delegate.backToMain()
    }
/* ===========================================================================*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PublicationPickerViewController: UIPickerViewDelegate {

    func pickerView
        ( _            pickerView: UIPickerView
        , titleForRow  row:        Int
        , forComponent component:  Int
        )
        -> String?
    {
        return pickerData[row]
    }

    func pickerView
        (_             pickerView: UIPickerView
        , didSelectRow row:        Int
        , inComponent  component:  Int
        )
    {
        self.currentlyPicked = pickerData[row]
    }
}

extension PublicationPickerViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView
        (_                        pickerView: UIPickerView
        , numberOfRowsInComponent component:  Int
        )
        -> Int
    {
        return pickerData.count
    }
}

/* HISTORICAL NOTES FOR delegate AND forConfigurationItem (may help later)
   ======================================================

 Implicitly unwrapped optionals are used, because these need to be set
 set for proper functionality.

 //    weak var delegate: ConfigurationItemDelegate!
 //    weak var forConfigurationItem: SLComposeSheetConfigurationItem!

 tl;dr
 The tutorials that pertain to this specific view controller are:
 * http://www.talkmobiledev.com/2017/01/22/create-a-custom-share-extension-in-swift/
 * https://codewithchris.com/uipickerview-example/

 The default share extension pop-up (`SLComposeServiceViewController`) can
 be extended with extra choice menus (`SLComposeSheetConfigurationItem` or
 configuration items; see `lazy var` declarations in `ShareViewController`).

 The configuration item has 3 properties that are relevant here:

 * title (to display what the menu is for)
 * value (that will be updated with a new value after tapping this menu or
 configuration item and choosing/inputing a new value in the subsequent
 view)
 * tapHandler
 It, at least in this app, is used to instantiate and configure
 the subsequent view controller when the menu choice is tapped,
 that will provide the interface to choose a new value. In order
 to exchange data between the view controllers, the stored
 properties below need to be set:

 * `delegate`             - to provide a callback
 * `forConfigurationItem` - it is mostly used to DRY up the code (otherwise
 a new delegate protocol would be necessary for
 every menu choice view controller.

 TODO:                        ^^^ is this assumption correct? ^^^
 TODO: Am I creating a retention cycle as it is implemented right now?

 UPDATE#1: Just realized that delegate may not even be necessary if I am
 going to use `forConfigurationItem` because then the value can
 be set directly.
 Is this a bad idea?

 UPDATE#2: So delegate IS needed (or passing `ShareViewController` instance
 itself) as `popViewController` is not defined in this context. On
 the other hand I also don't like the tight coupling by using
 `forConfigurationItem` stored property.

 -> Make use of `ShareViewController`'s (i.e.,
 `SLComposeServiceViewController`'s) configurationItems:` method?

 UPDATE#3: (1) `popViewController` issues solved by adding `nextConfigurationItemViewController`
 to the `ConfigurationItemDelegate` protocol (now transitions
 can be customized)

 (2) Stayed with `forConfigurationItem` for now. There may be some
 typelevel sorcery with enums and associated types etc., but
 have to have this up and running sooner rather than later.
 */

/* HISTORICAL NOTES #2
 ===================

 Figure out what the difference is between `text` and `insertText`.

 * `text`       is defined by UITextView whereas
 * `insertText` is declared by the UIKeyInput protocol (that is adopted
 by UIResponder, but the fact is never mentioned in the docs)

 See the tutorial and a related SO thread where I commented:
 (1) http://www.talkmobiledev.com/2017/01/22/create-a-custom-share-extension-in-swift/
 (2) https://stackoverflow.com/questions/2792589/uitextview-insert-text-in-the-textview-text

 (1) uses `insertText` on a UITextView instance and later calls
 `becomeFirstResponder` on it, so I guess UIKeyInput has to do with it
 based on its description:

 > When instances of this subclass are the first responder,
 > the system keyboard is displayed. Only a small subset of
 > the available keyboards and languages are available to
 > classes that adopt this protocol.
 */

