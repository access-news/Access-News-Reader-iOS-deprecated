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

    lazy var durationPicker: UIDatePicker = {

        let picker = self.createView(from: UIDatePicker.self)
        picker.datePickerMode = .countDownTimer
        picker.minuteInterval = 5

        /* 3/4/2018 0635
           Ran into an issue where the time wouldn't update if only one dial is
           turned, but this solves it:
           https://stackoverflow.com/questions/28295013/
        */
        let calendar = Calendar(identifier: .gregorian)
        let date = DateComponents(calendar: calendar, hour: 0, minute: 5).date!
        picker.setDate(date, animated: true)

        return picker
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up initial value.
        self.delegate?.hours = "5m"

        self.title = "Time spent reading?"
        self.view.addSubview(self.durationPicker)

        self.durationPicker.addTarget(
            self,
            action: #selector(durationPickerValueChanged),
            for:    .valueChanged
            )
    }

    @objc func durationPickerValueChanged(sender: UIDatePicker) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated

        self.delegate?.hours = formatter.string(from: sender.countDownDuration)!
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
