//
//  HoursViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/3/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Social

class HoursViewController: ConfigurationItemViewController {

//    weak var delegate: ConfigurationItemDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let doneButton = UIBarButtonItem(title:   "Done"
            , style:  .done
            , target: self
            , action: #selector(doneButtonClicked)
        )
        self.navigationItem.rightBarButtonItem = doneButton
    }

    @objc func doneButtonClicked() {
        self.delegate.updateValue("27")
        self.delegate.backToMain()
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
