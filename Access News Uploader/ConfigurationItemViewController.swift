//
//  ConfigurationItemViewController.swift
//  Access News Uploader
//
//  Created by Society for the Blind on 1/5/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Social

class ConfigurationItemViewController: UIViewController {

    weak var delegate: ConfigurationItemDelegate!
    weak var forConfigurationItem: SLComposeSheetConfigurationItem!

    /* Create a custom view that conforms to `SLComposeViewController`
       (and thus it will show up in the next window when clicking on
       the configuration item's row).

     TODO-1: Figure out why this is is working.

             The original implementation was
             `func createView<View: UIView>(from view: View) -> View`
             and got all sorts of weird errors when trying to invoke it.

             Finally got it to work by looking at this questions (the
             answer is still above my head) and saw the `Type` property.
             By the way, one of the errors I got was the title of the
             question:
             https://stackoverflow.com/questions/44991116/swift-generics-cannot-convert-value-of-type-to-expected-argument-type

     TODO-2: Figure out a way to check whether an object responds to a
             specific property. (Helpful to take care of delegates here,
             instead of in the view controller subclasses.)

             Things that I tried are below. I'm sure I'm missing something
             basic, read up on it.

             1. `do { object.property } catch { print(error) }`
                 Result:
                 error: value of type X has no member 'property'

                  do { object.property } catch { print(error) }
                  ^~~ ~~~~

                 warning: warning: 'catch' block is unreachable because no errors are thrown in 'do' block

             2. `respond:to:` does not work because properties have to
                conform to objective-c (or something along those lines)
    */
    func createView<View: UIView>(from view:  View.Type) -> View
    {
        let frame = CGRect( x:      self.view.frame.minX
                          , y:      self.view.frame.minY
                          , width:  self.view.frame.width
                          , height: self.view.frame.height
                          )
        let view = View.init(frame: frame)
        view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]

        return view
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
