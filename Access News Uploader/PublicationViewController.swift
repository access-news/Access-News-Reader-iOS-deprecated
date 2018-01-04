//
//  PublicationViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/3/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit

class PublicationViewController: UIViewController {

    lazy var publicationPicker: UIPickerView = {
        let frame = CGRect(
            x: self.view.frame.minX,
            y: self.view.frame.minY,
            width:  self.view.frame.width,
            height: self.view.frame.height
        )

        let picker = UIPickerView(frame: frame)
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        /* TODO:
         Figure out what the difference is between `text` and `insertText`.

         * `text`       is defined by UITextView whereas
         * `insertText` is declared by the UIKeyInput protocol (that is adopted by
         UIResponder, but the fact is never mentioned in the docs)

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

        // Do any additional setup after loading the view.
        self.title = "Choose a publication"
        
    }

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
